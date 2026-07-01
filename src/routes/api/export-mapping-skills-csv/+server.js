import { pool } from '$lib/server/db';

/** @type {import('./$types').RequestHandler} */
export async function GET({ url }) {
    try {
        const curriculumId = url.searchParams.get('curriculum_id');
        
        let query = `
            SELECT c.course_code, c.course_name, s.skill_name, cs.skill_level, curr.curriculum_name
            FROM courses c
            INNER JOIN course_skills cs ON c.course_id = cs.course_id
            INNER JOIN skills s ON cs.skill_id = s.skill_id
            INNER JOIN curriculum curr ON c.curriculum_id = curr.curriculum_id
        `;
        const params = [];
        
        if (curriculumId) {
            query += ` WHERE c.curriculum_id = ?`;
            params.push(curriculumId);
        }
        
        query += ` ORDER BY c.course_code, s.skill_name`;
        
        const [rows] = await pool.execute(query, params);
        
        // Construct CSV
        let csvContent = "\uFEFF"; // Prepend UTF-8 BOM
        csvContent += "หลักสูตร,รหัสวิชา,ชื่อวิชา,ทักษะย่อย,ระดับคาดหวัง\n";
        
        /** @type {any} */
        const finalRows = rows;
        for (const row of finalRows) {
            const currName = `"${(row.curriculum_name || '').replace(/"/g, '""')}"`;
            const courseCode = `"${(row.course_code || '').replace(/"/g, '""')}"`;
            const courseName = `"${(row.course_name || '').replace(/"/g, '""')}"`;
            const skillName = `"${(row.skill_name || '').replace(/"/g, '""')}"`;
            const skillLevel = row.skill_level;
            
            csvContent += `${currName},${courseCode},${courseName},${skillName},${skillLevel}\n`;
        }
        
        return new Response(csvContent, {
            headers: {
                'Content-Type': 'text/csv; charset=utf-8',
                'Content-Disposition': 'attachment; filename=mapping-skills-report.csv'
            }
        });
    } catch (error) {
        console.error('Error exporting CSV:', error);
        /** @type {any} */
        const err = error;
        return new Response('Error exporting CSV: ' + err.message, { status: 500 });
    }
}
