import {pool} from '$lib/server/db';
import { redirect } from '@sveltejs/kit';

export async function load({locals}) {
    if (locals.user && locals.user.role === 'admin') {
            // ดีดกลับไปหน้าแรก (หรือหน้าเลือกรrole) ทันที
            throw redirect(303, '/adminPage'); 
        }
    try{
        const [rows] = await pool.execute('SELECT * FROM curriculum');
        return {curriculum: rows};
    }catch(error){
        console.error('เกิดข้อผิดพลาดในการโหลดข้อมูล', error);
    }
}