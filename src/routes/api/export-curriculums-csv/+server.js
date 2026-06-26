import { pool } from '$lib/server/db';
import { error } from '@sveltejs/kit';

export async function GET() {
    try {
        const [rows] = await pool.execute(
            `SELECT cl.curriculum_name, c.course_id, c.course_name, c.course_code, c.credits
             FROM courses c
             LEFT JOIN curriculum cl ON c.curriculum_id = cl.curriculum_id`
        );

        let csvContent = '\ufeffcurriculum_name,course_id,course_code,course_name,credits\n';
        //@ts-ignore
        rows.forEach(row => {
            csvContent += `"${row.curriculum_name || ''}","${row.course_id}","${row.course_code || ''}","${row.course_name || ''}","${row.credits}"\n`;
        });

        return new Response(csvContent, {
            status: 200,
            headers: {
                'Content-Type': 'text/csv; charset=utf-8;',
                'Content-Disposition': 'attachment; filename=curriculums_export.csv'
            }
        });
    } catch (err) {
        console.error(err);
        throw error(500, 'เกิดข้อผิดพลาดในการส่งออกข้อมูล');
    }
}