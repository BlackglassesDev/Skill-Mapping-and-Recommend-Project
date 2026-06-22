//         ตอนนี้ต้องแก้เรื่อง
//  ผู้ใช้เปลี่ยนหลักสูตรแล้ว นับข้อมูลวิชาของหลักสูตรเก่า

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
			allCourse: [],
			savedGrades: [],
			passedSkillsCount: [],
			completedCoursesCount: [],
			jobs: []
		};
	}

	try {
		// 2. Query ดูข้อมูลของผู้ใช้ที่ล็อกอินอยู่
		const [rows_user] = await pool.execute(
			'SELECT id, full_name, username, curriculum_id FROM users WHERE username = ?',
			[locals.user.username]
		);

		// 3. ดึงค่าจากแถวแรก (Index 0) ออกมาดู
		// ถ้าใน DB เป็น NULL ตัวแปร userCurriculumId จะได้ค่าเป็น null
		// @ts-ignore
		const userCurriculumId = rows_user[0] ? rows_user[0].curriculum_id : null;
		// @ts-ignore
		const userId = rows_user[0] ? rows_user[0].id : null;

		// 4. เช็คสถานะ: ถ้า userCurriculumId ไม่ใช่ null และไม่ใช่ค่าว่าง แปลว่า "เลือกหลักสูตรแล้ว"
		const hasCurriculum = userCurriculumId !== null && userCurriculumId !== '';

		// 5. ดึงรายชื่อหลักสูตรทั้งหมดเตรียมไว้ให้เลือกใน Dropdown
		const [curriculumRows] = await pool.execute('SELECT * FROM curriculum');

		const [courseRows] = await pool.execute(
			'SELECT course_id, course_code, course_name, curriculum_id FROM courses'
		);

		let savedGrades = [];
		let completedCoursesCount = 0;
		let passedSkillsCount = 0;
		let jobRows = [];
		if (userId) {
			// เอาคำว่า const ออก แล้วเปลี่ยนไปยัดค่าใส่ตัวแปร savedGrades ตรงๆ เลยครับ
			const [gradeRows] = await pool.execute(
				'SELECT course_id, grade_letter FROM student_grades WHERE user_id = ?',
				[userId]
			);

			const [skillCountRows] = await pool.execute(
				`SELECT COUNT(DISTINCT cs.skill_id) AS total_skills
                FROM student_grades sg
                INNER JOIN course_skills cs ON sg.course_id = cs.course_id
                WHERE sg.user_id = ? 
                AND sg.grade_letter NOT IN ('NOT_TAKEN', 'F')`,
				[userId]
			);

			if (userCurriculumId) {
				const [countRows] = await pool.execute(
					`SELECT COUNT(*) AS total
                FROM student_grades sg
				INNER JOIN courses c ON sg.course_id = c.course_id
                WHERE sg.user_id = ? AND grade_letter NOT IN ('NOT_TAKEN', 'F') AND c.curriculum_id = ?`,
					[userId, userCurriculumId]
				);

				const [fetchedJobs] = await pool.execute(
					`SELECT job_id, name_job FROM job WHERE curriculum_id = ?`,
					[userCurriculumId]
				);
				//@ts-ignore
				jobRows = fetchedJobs;

				// @ts-ignore
				completedCoursesCount = countRows[0] ? countRows[0].total : 0;
			}

			// @ts-ignore
			passedSkillsCount = skillCountRows[0] ? skillCountRows[0].total_skills : 0;

			//@ts-ignore
			savedGrades = gradeRows;
		}

		// 6. ส่งค่าทั้งหมดกลับไปที่หน้าบ้าน (+page.svelte)
		return {
			currentUserCurriculumId: userCurriculumId, // ส่งไปดูตรงๆ ว่าเป็นไอดีอะไร หรือเป็น null
			hasCurriculum: hasCurriculum, // ส่งไปเป็น true / false เพื่อใช้คุมเปิดปิดมอดอล
			users: rows_user, // ข้อมูล users
			allCourses: courseRows, // ดึงวิชาทุกหลักสูตร
			savedGrades: savedGrades,
			completedCoursesCount: completedCoursesCount,
			passedSkillsCount: passedSkillsCount,
			jobs: jobRows,
			curriculum: JSON.parse(JSON.stringify(curriculumRows)) // รายชื่อหลักสูตรทั้งหมดในตาราง curriculum
		};
	} catch (error) {
		console.error('Error fetching user curriculum:', error);
		return {
			currentUserCurriculumId: null,
			hasCurriculum: false,
			curriculum: [],
			users: [],
			allCourse: [],
			savedGrades: [],
			completedCoursesCount: [],
			passedSkillsCount: [],
			jobs: []
		};
	}
};

const gradeValues = {
	A: 4.0,
	'B+': 3.5,
	B: 3.0,
	'C+': 2.5,
	C: 2.0,
	'D+': 1.5,
	D: 1.0,
	F: 0.0
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

			if (curriculum_id) {
				await pool.execute('UPDATE users SET curriculum_id = ? WHERE id = ?', [
					curriculum_id,
					userId
				]);
			}

			for (let i = 0; i < course_ids.length; i++) {
				const courseId = course_ids[i];
				const gradeLetter = course_grades[i];

				if (gradeLetter === 'NOT_TAKEN') {
					await pool.execute('DELETE FROM student_grades WHERE user_id = ? AND course_id = ?', [
						userId,
						courseId
					]);
					continue; // ลบเสร็จแล้วให้ข้ามลูปวิชานี้ไปได้เลย ไม่ต้องไปทำงานต่อด้านล่าง
				}

				if (gradeLetter === 'NOT_TAKEN' || !gradeLetter) {
					continue;
				}

				//@ts-ignore
				const gradePoint = gradeValues[gradeLetter] || 0.0;

				await pool.execute(
					`
                    INSERT INTO student_grades (user_id, course_id, grade_letter, grade_point)
                    VALUES (?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        grade_letter = VALUES(grade_letter),
                        grade_point = VALUES(grade_point)
                `,
					[userId, courseId, gradeLetter, gradePoint]
				);
			}

			return { message: 'ดำเนินการบันทึกสำเร็จ', success: true };
		} catch (error) {
			console.error('err save grades', error);
			return fail(500, {
				success: false,
				message: 'การเชื่อมต่อขัดข้อง'
			});
		}
	}
};
