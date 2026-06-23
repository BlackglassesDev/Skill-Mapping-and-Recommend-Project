import { pool } from '$lib/server/db';
import { error } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export async function GET() {
    try {
        // 1. ดึงข้อมูลจาก Database
        const [rows] = await pool.execute(
            `SELECT u.id, u.username, u.full_name, u.email, u.role, cl.curriculum_name
            FROM users u
            LEFT JOIN curriculum cl ON u.curriculum_id = cl.curriculum_id`
        );

        // 2. แปลงข้อมูลเป็น CSV (ใส่ BOM \ufeff ให้ภาษาไทยไม่เพี้ยนใน Excel)
        let csvContent = '\ufeffรหัสผู้ใช้,Username,ชื่อ-นามสกุล,อีเมล,บทบาท,สาขาวิชา\n';
        
        //@ts-ignore
        rows.forEach(row => {
            csvContent += `"${row.id}","${row.username}","${row.full_name || ''}","${row.email || ''}","${row.role}","${row.curriculum_name || ''}"\n`;
        });

        // 3. พ่นสตรีมไฟล์ CSV กลับไปให้บราวเซอร์ดาวน์โหลดทันที
        return new Response(csvContent, {
            status: 200,
            headers: {
                'Content-Type': 'text/csv; charset=utf-8;',
                'Content-Disposition': 'attachment; filename=users_export.csv'
            }
        });

    } catch (err) {
        console.error('Export API Error:', err);
        throw error(500, 'เกิดข้อผิดพลาดในการส่งออกข้อมูล');
    }
}