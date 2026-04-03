import {pool} from '$lib/server/db';

export async function load() {
    try{
        const [rows] = await pool.execute('SELECT * FROM curriculum');
        return {curriculum: rows};
    }catch(error){
        console.error('เกิดข้อผิดพลาดในการโหลดข้อมูล', error);
    }
}