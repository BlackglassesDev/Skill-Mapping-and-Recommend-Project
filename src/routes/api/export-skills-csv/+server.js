import { pool } from '$lib/server/db';
import { error } from '@sveltejs/kit';

export async function GET() {
    try {
        const [rows] = await pool.execute(
            `SELECT cl.curriculum_name, s.skill_id, s.skill_name, s.curriculum_id
             FROM skills s
             LEFT JOIN curriculum cl ON s.curriculum_id = cl.curriculum_id`
        );

        let csvContent = '\ufeffskill_id,skill_name,curriculum_id,curriculum_name\n';
        //@ts-ignore
        rows.forEach(row => {
            csvContent += `"${row.skill_id || ''}","${row.skill_name || ''}","${row.curriculum_id || ''}","${row.curriculum_name || ''}"\n`;
        });

        return new Response(csvContent, {
            status: 200,
            headers: {
                'Content-Type': 'text/csv; charset=utf-8;',
                'Content-Disposition': 'attachment; filename=skills_export.csv'
            }
        });
    } catch (err) {
        console.error(err);
        throw error(500, 'เกิดข้อผิดพลาดในการส่งออกข้อมูล');
    }
}