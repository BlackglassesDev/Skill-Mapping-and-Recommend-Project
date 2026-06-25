import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ locals }) {
    // 🎯 ดักเช็ค: ถ้าไม่ได้ล็อกอิน หรือ สิทธิ์ (Role) ไม่ใช่ admin
    if (!locals.user || locals.user.role !== 'admin') {
        // ดีดกลับไปหน้าแรก (หรือหน้าเลือกรrole) ทันที
        throw redirect(303, '/'); 
    }
    return {
        message: 'ผ่านการตรวจสอบสิทธิ์แล้ว ✅'
    };
}