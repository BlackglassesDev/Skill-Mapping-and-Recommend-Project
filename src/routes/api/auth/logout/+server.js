import { json } from '@sveltejs/kit';

export async function POST({ cookies, locals }) {
    // 1. ลบคุกกี้ session ออกจากเบราว์เซอร์
    cookies.delete('session', {
        path: '/',
        httpOnly: true,
        secure: true,
        sameSite: 'strict'
    });

    // 2. เคลียร์ค่า locals ให้กลับเป็น null
    locals.user = null;

    // 3. ส่งกลับไปบอกหน้าบ้านว่าสำเร็จแล้ว
    return json({ success: true, message: 'ออกจากระบบสำเร็จ' },{status: 200 });
}