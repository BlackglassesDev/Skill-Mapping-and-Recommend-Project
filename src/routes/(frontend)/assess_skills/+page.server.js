import { pool } from '$lib/server/db.js';
import { fail } from '@sveltejs/kit';

export const load = async ({ locals }) => {
	// 1. เช็คก่อนว่ามี locals.user ไหม (เข้าสู่ระบบหรือยัง)
	if (!locals.user) {
		return {
			currentUserCurriculumId: null,
			hasCurriculum: false,
			curriculum: [],
			users: [],
			allCourse: []
		};
	}

	try {
		// 2. Query ดูข้อมูลของผู้ใช้ที่ล็อกอินอยู่
		const [rows_user] = await pool.execute('SELECT curriculum_id FROM users WHERE username = ?', [
			locals.user.username
		]);

		// 3. ดึงค่าจากแถวแรก (Index 0) ออกมาดู
		// ถ้าใน DB เป็น NULL ตัวแปร userCurriculumId จะได้ค่าเป็น null
		// @ts-ignore
		const userCurriculumId = rows_user[0] ? rows_user[0].curriculum_id : null;

		// 4. เช็คสถานะ: ถ้า userCurriculumId ไม่ใช่ null และไม่ใช่ค่าว่าง แปลว่า "เลือกหลักสูตรแล้ว"
		const hasCurriculum = userCurriculumId !== null && userCurriculumId !== '';

		// 5. ดึงรายชื่อหลักสูตรทั้งหมดเตรียมไว้ให้เลือกใน Dropdown
		const [curriculumRows] = await pool.execute('SELECT * FROM curriculum');

		const [courseRows] = await pool.execute(
			'SELECT course_id, course_code, course_name, curriculum_id FROM courses'
		);

		const [userRows] = await pool.execute(
			'SELECT id, full_name, username FROM users WHERE username = ?',
			[locals.user.username]
		);

		// 6. ส่งค่าทั้งหมดกลับไปที่หน้าบ้าน (+page.svelte)
		return {
			currentUserCurriculumId: userCurriculumId, // ส่งไปดูตรงๆ ว่าเป็นไอดีอะไร หรือเป็น null
			hasCurriculum: hasCurriculum, // ส่งไปเป็น true / false เพื่อใช้คุมเปิดปิดมอดอล
			users: userRows, // ข้อมูล users
			allCourses: courseRows, // ดึงวิชาทุกหลักสูตร
			curriculum: JSON.parse(JSON.stringify(curriculumRows)) // รายชื่อหลักสูตรทั้งหมดในตาราง curriculum
		};
	} catch (error) {
		console.error('Error fetching user curriculum:', error);
		return {
			currentUserCurriculumId: null,
			hasCurriculum: false,
			curriculum: [],
			users: [],
			allCourse: []
		};
	}
};

const gradeValues = {
	'A':  4.0,
    'B+': 3.5,
    'B':  3.0,
    'C+': 2.5,
    'C':  2.0,
    'D+': 1.5,
    'D':  1.0,
    'F':  0.0
};

export const actions = {
	saveCurriculumAndGrades: async ({ request, locals }) => {
		if (!locals.user?.username) {
			return fail(401, {
				success: false,
				message: 'ไม่พบข้อมูลผู้ใช้งาน กรุณาล็อกอินใหม่อีกครั้ง'
			});
		}

		const data = await request.formData();
		const curriculum_id = data.get('curriculum_id');
		const course_ids = data.getAll('course_id');
		const course_grades = data.getAll('course_grades');

		try {
            /** @type {[any, any]} */
			const [userRows] = await pool.execute(
				'SELECT id, full_name, username FROM users WHERE username = ?',
				[locals.user?.username]
			);

			if (userRows.length === 0) {
				return fail(404, { success: false, message: 'ไม่พบข้อมูลผู้ใช้งาน' });
			}
			const userId = userRows[0].id;

            if(curriculum_id){
                await pool.execute('UPDATE users SET curriculum_id = ? WHERE id = ?',[curriculum_id,userId])
            }

            for (let i = 0; i < course_ids.length ; i++){
                const courseId = course_ids[i];
                const gradeLetter = course_grades[i];

                if (gradeLetter === 'NOT_TAKEN' || !gradeLetter) {
                    continue;
                }

                //@ts-ignore
                const gradePoint = gradeValues[gradeLetter] || 0.0;

                await pool.execute(`
                    INSERT INTO student_grades (user_id, course_id, grade_letter, grade_point)
                    VALUES (?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        grade_letter = VALUES(grade_letter),
                        grade_point = VALUES(grade_point)
                `, [userId, courseId, gradeLetter, gradePoint]);
            }

            return { message: 'ดำเนินการบันทึกสำเร็จ', success: true}
		} catch (error) {
			console.error('err save grades', error);
			return fail(500, {
				success: false,
				message: 'การเชื่อมต่อขัดข้อง'
			});
		}
	}
};
