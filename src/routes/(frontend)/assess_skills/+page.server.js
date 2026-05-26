import { pool } from '$lib/server/db.js';

export const load = async ({ locals }) => {
    // 1. เช็คก่อนว่ามี locals.user ไหม (เข้าสู่ระบบหรือยัง)
    if (!locals.user) {
        return { currentUserCurriculumId: null, hasCurriculum: false, curriculum: [], users: [], allCourse: [] };
    }

    try {
        // 2. Query ดูข้อมูลของผู้ใช้ที่ล็อกอินอยู่
        const [rows_user] = await pool.execute(
            'SELECT curriculum_id FROM users WHERE username = ?',
            [locals.user.username]
        );

        // 3. ดึงค่าจากแถวแรก (Index 0) ออกมาดู
        // ถ้าใน DB เป็น NULL ตัวแปร userCurriculumId จะได้ค่าเป็น null
		// @ts-ignore
        const userCurriculumId = rows_user[0] ? rows_user[0].curriculum_id : null;

        // 4. เช็คสถานะ: ถ้า userCurriculumId ไม่ใช่ null และไม่ใช่ค่าว่าง แปลว่า "เลือกหลักสูตรแล้ว"
        const hasCurriculum = userCurriculumId !== null && userCurriculumId !== '';

        // 5. ดึงรายชื่อหลักสูตรทั้งหมดเตรียมไว้ให้เลือกใน Dropdown
        const [curriculumRows] = await pool.execute('SELECT * FROM curriculum');

		const [courseRows] = await pool.execute('SELECT course_code, course_name, curriculum_id FROM courses')

		const [userRows] = await pool.execute('SELECT id, full_name, username FROM users WHERE username = ?',[locals.user.username])

        // 6. ส่งค่าทั้งหมดกลับไปที่หน้าบ้าน (+page.svelte)
        return {
            currentUserCurriculumId: userCurriculumId, // ส่งไปดูตรงๆ ว่าเป็นไอดีอะไร หรือเป็น null
            hasCurriculum: hasCurriculum,              // ส่งไปเป็น true / false เพื่อใช้คุมเปิดปิดมอดอล
			users: userRows,						   // ข้อมูล users
			allCourses: courseRows,					   // ดึงวิชาทุกหลักสูตร
            curriculum: JSON.parse(JSON.stringify(curriculumRows))                 // รายชื่อหลักสูตรทั้งหมดในตาราง curriculum
        };

    } catch (error) {
        console.error('Error fetching user curriculum:', error);
        return { currentUserCurriculumId: null, hasCurriculum: false, curriculum: [], users: [], allCourse: [] };
    }
};