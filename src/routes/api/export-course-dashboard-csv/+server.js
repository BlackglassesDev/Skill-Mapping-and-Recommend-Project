import { pool } from '$lib/server/db';

/** @type {import('./$types').RequestHandler} */
export async function GET({ locals }) {
    if (!locals.user) {
        return new Response('Unauthorized', { status: 401 });
    }
    
    try {
        const [userRows] = await pool.execute('SELECT id, curriculum_id FROM users WHERE username = ?', [locals.user.username]);
        /** @type {any} */
        const finalUserRows = userRows;
        const user = finalUserRows[0];

        if (!user) {
            return new Response('User not found', { status: 404 });
        }

        const [statsRows] = await pool.execute(`
            SELECT s.skill_name, COUNT(cs.course_id) AS mapped_count, curr.curriculum_name AS category
            FROM skills s
            LEFT JOIN course_skills cs ON s.skill_id = cs.skill_id
            LEFT JOIN curriculum curr ON s.curriculum_id = curr.curriculum_id
            WHERE s.curriculum_id = ?
            GROUP BY s.skill_id, s.skill_name, curr.curriculum_name
            ORDER BY s.skill_name
        `, [user.curriculum_id]);

        /** @type {any} */
        const finalStats = statsRows;

        // Calculate max and min dynamically
        const mappedOnlySkills = finalStats.filter((/** @type {any} */ s) => s.mapped_count > 0);
        const counts = mappedOnlySkills.map((/** @type {any} */ s) => s.mapped_count);
        const maxCount = counts.length > 0 ? Math.max(...counts) : 0;
        const minCount = counts.length > 0 ? Math.min(...counts) : 0;

        // Construct CSV
        let csvContent = "\uFEFF"; // Prepend UTF-8 BOM
        csvContent += "หลักสูตร,ทักษะย่อย,จำนวนวิชาที่นำไปใช้,สถานะการประยุกต์ใช้\n";

        for (const row of finalStats) {
            const category = `"${(row.category || '').replace(/"/g, '""')}"`;
            const skillName = `"${(row.skill_name || '').replace(/"/g, '""')}"`;
            const mappedCount = row.mapped_count;
            
            let status = "";
            if (mappedCount > 0) {
                if (mappedCount === maxCount) {
                    status = "ทักษะที่ใช้บ่อยที่สุด";
                } else if (mappedCount === minCount) {
                    status = "ทักษะที่ใช้บ่อยน้อยที่สุด";
                }
            }
            
            csvContent += `${category},${skillName},${mappedCount},${status}\n`;
        }

        const mostMappedNames = finalStats.filter((/** @type {any} */ s) => s.mapped_count === maxCount && maxCount > 0).map((/** @type {any} */ s) => s.skill_name);
        const leastMappedNames = finalStats.filter((/** @type {any} */ s) => s.mapped_count === minCount && minCount > 0).map((/** @type {any} */ s) => s.skill_name);

        const [coursesRows] = await pool.execute('SELECT course_id, course_code, course_name FROM courses WHERE curriculum_id = ?', [user.curriculum_id]);
        /** @type {any} */
        const finalCoursesRows = coursesRows;

        const [mappedCoursesRows] = await pool.execute('SELECT DISTINCT course_id FROM course_skills');
        /** @type {any} */
        const finalMappedCoursesRows = mappedCoursesRows;

        const mappedIds = new Set(finalMappedCoursesRows.map((/** @type {any} */ r) => r.course_id));
        const mappedCourses = finalCoursesRows.filter((/** @type {any} */ course) => mappedIds.has(course.course_id));
        const unmappedCourses = finalCoursesRows.filter((/** @type {any} */ course) => !mappedIds.has(course.course_id));

        csvContent += "\n";
        csvContent += "สรุปผลวิเคราะห์ทักษะ (Analytics Summary),\n";
        csvContent += `ทักษะที่ใช้บ่อยที่สุด,"${mostMappedNames.join(', ').replace(/"/g, '""')}"\n`;
        csvContent += `ทักษะที่ใช้บ่อยน้อยที่สุด,"${leastMappedNames.join(', ').replace(/"/g, '""')}"\n`;

        csvContent += "\n";
        csvContent += "สรุปสถิติมุมมองรายวิชา (Course Analysis Summary),\n";
        csvContent += `จำนวนรายวิชาที่นำไปใช้,"${mappedCourses.length}"\n`;
        csvContent += `จำนวนรายวิชาที่ยังไม่ได้นำไปใช้,"${unmappedCourses.length}"\n`;
        
        csvContent += "\n";
        csvContent += "รายวิชาที่ยังไม่ได้ทำการ Mapping (Unmapped Courses List),\n";
        csvContent += "ไอดีวิชา (Course ID),รหัสวิชา (Course Code),ชื่อวิชา (Course Name)\n";
        for (const c of unmappedCourses) {
            const code = `"${(c.course_code || '').replace(/"/g, '""')}"`;
            const name = `"${(c.course_name || '').replace(/"/g, '""')}"`;
            csvContent += `${c.course_id},${code},${name}\n`;
        }

        return new Response(csvContent, {
            headers: {
                'Content-Type': 'text/csv; charset=utf-8',
                'Content-Disposition': 'attachment; filename=course-dashboard-report.csv'
            }
        });
    } catch (error) {
        console.error('Error exporting dashboard CSV:', error);
        /** @type {any} */
        const err = error;
        return new Response('Error exporting CSV: ' + err.message, { status: 500 });
    }
}
