import jwt from 'jsonwebtoken'; // 1. นำเข้า JWT
import { env } from '$env/dynamic/private'; // 2. นำเข้า Secret Key
import { redirect } from '@sveltejs/kit';

/** @type {import('@sveltejs/kit').Handle} */
export const handle = async ({ event, resolve }) => {
    // กำหนดค่าเริ่มต้นไว้ก่อนเลย เพื่อความชัวร์
    event.locals.user = null;

    try {
        // ดึง Token ออกจากคุกกี้ (ซึ่งตอนนี้ค่าจะเป็น JWT ไม่ใช่ username แล้ว)
        const token = event.cookies.get('session');

        if (token) {
            // 3. ตรวจสอบลายเซ็นดิจิทัลของ Token
            // ถ้า User แอบแก้ใน F12 บรรทัดนี้จะ Error ทันทีและตกไปที่ catch
            /** @type {any} */
            const decoded = jwt.verify(token, env.APP_SECRET);

            if (decoded) {
                // 4. นำข้อมูลจาก Payload ที่เราฝังไว้ตอน Login มาใส่ใน locals
                // วิธีนี้ทำให้ไม่ต้องไป Query Database ซ้ำ ช่วยให้เว็บไวขึ้นมาก
                event.locals.user = {
                    username: decoded.username,
                    role: decoded.role,
                };
            }
        }
    } catch (error) {
        // ถ้า Token ปลอม, หมดอายุ หรือมีปัญหาอื่นๆ
        console.error('HOOK ERROR (JWT):', error);

        // ลบคุกกี้ทิ้งถ้ามันใช้งานไม่ได้ เพื่อให้ User ต้องล็อกอินใหม่
        event.cookies.delete('session', { path: '/' });
        event.locals.user = null;
    }

    /////////////   check role middleware    /////////////

    const userRole = event.locals.user?.role;
    const currentPath = event.url.pathname;
    // check admin page middleware
    const isAdminPage = currentPath.startsWith('/adminPage') ||
        currentPath.startsWith('/manage_users') ||
        currentPath.startsWith('/curriculums_manage') ||
        currentPath.startsWith('/manage_global_skills') ||
        currentPath.startsWith('/admin_dashboard');
    if (isAdminPage) {
        if (userRole) {
            if (userRole !== 'admin') {
                if (userRole === 'student') {
                    throw redirect(303, '/');
                }
                if (userRole === 'teacher') {
                    throw redirect(303, '/teacherPage');
                }
            }
        } else {
            throw redirect(303, '/');
        }
    }
    // check student page middleware
    const isStudentPage = currentPath.startsWith('/assess_skills') ||
        currentPath.startsWith('/info_subject') ||
        currentPath.startsWith('/home') ||
        currentPath === '/';

    if (isStudentPage) {
        if (userRole) {
            if (userRole !== 'student') {
                if (userRole === 'admin') {
                    throw redirect(303, '/adminPage');
                }
                if (userRole === 'teacher') {
                    throw redirect(303, '/teacherPage');
                }
            }
        }
    }

    // check teacher page middleware
    const isTeacherPage = currentPath.startsWith('/teacherPage');
    if (isTeacherPage) {
        if (userRole) {
            if (userRole !== 'teacher') {
                if (userRole === 'admin') {
                    throw redirect(303, '/adminPage');
                }
                if (userRole === 'student') {
                    throw redirect(303, '/');
                }
            }
        } else {
            throw redirect(303, '/');
        }
    }

    return resolve(event);
};