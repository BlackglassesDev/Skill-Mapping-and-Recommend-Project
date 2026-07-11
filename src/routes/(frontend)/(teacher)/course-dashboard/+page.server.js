import { pool } from '$lib/server/db';
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ locals }) {
	if (!locals.user) {
		throw redirect(302, '/');
	}

	try {
		const [userRows] = await pool.execute(
			'SELECT id, curriculum_id FROM users WHERE username = ?',
			[locals.user.username]
		);
		/** @type {any} */
		const finalUserRows = userRows;
		const user = finalUserRows[0];

		if (!user) {
			return {
				totalCourses: 0,
				skillStatistics: [],
				skillCompareStats: []
			};
		}

		const [totalCoursesRows] = await pool.execute(
			'SELECT COUNT(course_id) AS count FROM courses WHERE curriculum_id = ?',
			[user.curriculum_id]
		);
		/** @type {any} */
		const finalTotalCoursesRows = totalCoursesRows;
		const totalCourses = finalTotalCoursesRows[0]?.count || 0;

		const [statsRows] = await pool.execute(
			`
            SELECT s.skill_name, COUNT(cs.course_id) AS count, curr.curriculum_name AS category
            FROM skills s
            LEFT JOIN course_skills cs ON s.skill_id = cs.skill_id
            LEFT JOIN curriculum curr ON s.curriculum_id = curr.curriculum_id
            WHERE s.curriculum_id = ?
            GROUP BY s.skill_id, s.skill_name, curr.curriculum_name
            ORDER BY s.skill_name
        `,
			[user.curriculum_id]
		);

		/** @type {any} */
		const finalStats = statsRows;

		const [coursesRows] = await pool.execute(
			'SELECT course_id, course_code, course_name FROM courses WHERE curriculum_id = ?',
			[user.curriculum_id]
		);
		/** @type {any} */
		const finalCoursesRows = coursesRows;

		const [mappedCoursesRows] = await pool.execute('SELECT DISTINCT course_id FROM course_skills');
		/** @type {any} */
		const finalMappedCoursesRows = mappedCoursesRows;

		const mappedIds = new Set(finalMappedCoursesRows.map((/** @type {any} */ r) => r.course_id));
		const mappedCourses = finalCoursesRows.filter((/** @type {any} */ course) =>
			mappedIds.has(course.course_id)
		);
		const unmappedCourses = finalCoursesRows.filter(
			(/** @type {any} */ course) => !mappedIds.has(course.course_id)
		);

		// 📊 เปรียบเทียบระดับทักษะสูงสุด ฝั่งอาชีพ (job) vs ฝั่งรายวิชา (course) รายทักษะ
		const [skillCompareRows] = await pool.execute(
			`
				SELECT
					s.skill_id,
					s.skill_name,
					COALESCE((
						SELECT MAX(js.level_skill)
						FROM job_skills js
						INNER JOIN job j ON j.job_id = js.job_id
						WHERE js.skill_id = s.skill_id AND j.curriculum_id = ?
					), 0) AS job_max_level,
					COALESCE((
						SELECT MAX(cs.skill_level)
						FROM course_skills cs
						INNER JOIN courses c ON c.course_id = cs.course_id
						WHERE cs.skill_id = s.skill_id AND c.curriculum_id = ?
					), 0) AS course_max_level
				FROM skills s
				WHERE s.curriculum_id = ?
				ORDER BY s.skill_name
			`,
			[user.curriculum_id, user.curriculum_id, user.curriculum_id]
		);
		/** @type {any} */
		const finalSkillCompareRows = skillCompareRows;

		return {
			totalCourses,
			skillStatistics: finalStats,
			mappedCourses,
			unmappedCourses,
			skillCompareStats: finalSkillCompareRows
		};
	} catch (error) {
		console.error('Error loading course dashboard data:', error);
		return {
			totalCourses: 0,
			skillStatistics: [],
			mappedCourses: [],
			unmappedCourses: [],
			skillCompareStats: []
		};
	}
}
