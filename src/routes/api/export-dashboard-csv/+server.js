import { pool } from '$lib/server/db';
import { error } from '@sveltejs/kit';


export async function GET() {
    try {
        const [summaryRows] = await pool.execute(`
            SELECT 
                (SELECT COUNT(*) FROM users) AS total_users,
                (SELECT COUNT(*) FROM curriculum) AS total_curriculums,
                (SELECT COUNT(*) FROM courses) AS total_courses,
                (SELECT SUM(credits) FROM courses) AS total_credits
        `);
        //@ts-ignore
        const summary = summaryRows[0];

        const [latestCourses] = await pool.execute(`
            SELECT course_code, course_name, credits 
            FROM courses 
            ORDER BY course_id DESC 
            LIMIT 5
        `);

        const [allCourses] = await pool.execute(`
            SELECT cl.curriculum_name, c.course_id, c.course_name, c.course_code, c.credits
            FROM courses c
            LEFT JOIN curriculum cl ON c.curriculum_id = cl.curriculum_id
            ORDER BY cl.curriculum_name ASC, c.course_code ASC
        `);

        // ใส่ BOM (\ufeff) เพื่อให้ Excel เปิดภาษาไทยได้ถูกต้อง ไม่เป็นต่างดาว
        let csvContent = '\ufeff';

        // SECTION A: รายงานสรุปภาพรวม (Dashboard Summary)
        csvContent += '=== รายงานสรุปภาพรวมระบบ ===\n';
        csvContent += 'จำนวนผู้ใช้ทั้งหมด,จำนวนหลักสูตรทั้งหมด,จำนวนรายวิชาทั้งหมด,จำนวนหน่วยกิตรวมในระบบ\n';
        csvContent += `"${summary.total_users || 0}","${summary.total_curriculums || 0}","${summary.total_courses || 0}","${summary.total_credits || 0}"\n`;
        csvContent += '\n'; // เว้นบรรทัดเพื่อความสวยงาม

        // SECTION B: รายวิชาที่เพิ่มล่าสุด 5 รายวิชา
        csvContent += '=== รายวิชาที่เพิ่มล่าสุด 5 รายวิชา ===\n';
        csvContent += 'รหัสวิชา,ชื่อรายวิชา,หน่วยกิต\n';
        //@ts-ignore
        latestCourses.forEach(row => {
            csvContent += `"${row.course_code || ''}","${row.course_name || ''}","${row.credits}"\n`;
        });
        csvContent += '\n'; // เว้นบรรทัดก่อนขึ้นตารางใหญ่

        // SECTION C: รายชื่อรายวิชาทั้งหมดในระบบ (Main Data)
        csvContent += '=== รายชื่อหลักสูตรและรายวิชาทั้งหมด ===\n';
        csvContent += 'ชื่อหลักสูตร,รหัสวิชาภายใน (ID),รหัสวิชา,ชื่อรายวิชา,หน่วยกิต\n';
        //@ts-ignore
        allCourses.forEach(row => {
            csvContent += `"${row.curriculum_name || ''}","${row.course_id}","${row.course_code || ''}","${row.course_name || ''}","${row.credits}"\n`;
        });

        // ส่ง Response กลับไปเป็นไฟล์ CSV ให้ดาวน์โหลด
        return new Response(csvContent, {
            status: 200,
            headers: {
                'Content-Type': 'text/csv; charset=utf-8;',
                'Content-Disposition': 'attachment; filename=system-summary-dashboard.csv'
            }
        });

    } catch (err) {
        console.error(err);
        throw error(500, 'เกิดข้อผิดพลาดในการส่งออกข้อมูลแดชบอร์ด');
    }
}