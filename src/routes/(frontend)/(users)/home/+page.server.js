import { redirect,fail } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

/**@param {import('./$types').PageServerLoad} props */
//@ts-ignore
export async function load({ url }) {
	const id = url.searchParams.get('curriculum');

	if(!id){
		throw redirect(302, '/');
	}else{
		try{
			const [rows] = await pool.execute(
				'SELECT course_id, course_code, course_name FROM courses WHERE curriculum_id = ?',
				[id]
			);

			const [jobRows] = await pool.execute(
				'SELECT job_id, name_job FROM job WHERE curriculum_id = ?',[id]
			);

			const [course_skills] = await pool.execute(
				`SELECT cs.course_id, s.skill_name FROM course_skills cs
				INNER JOIN skills s ON cs.skill_id = s.skill_id
				INNER JOIN courses c ON cs.course_id = c.course_id
				WHERE c.curriculum_id = ?`,[id]
			);

			const [Curriculum_name] = await pool.execute(
				'SELECT curriculum_name FROM curriculum WHERE curriculum_id = ?',[id]
			);

			return {
				courses: rows,
				jobs: jobRows,
				course_skills: course_skills,
				curriculum_name: Curriculum_name
			};
		}catch(error){
			console.log('Error: Check Curriculum', error);
			return {
				courses: [],
				jobs: [],
				course_skills: []
			};
		}
	}
}

/**@type {import('./$types').Actions} */
export const actions = {
	call_jobs: async ({request,fetch}) => {
		const data = await request.formData();
		const id = data.get('id');

		try {
			const res = await fetch('/api/job_skill', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ id })
			});

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status,{
					success: false,
					boxinfo: result.boxinfo || 'ระบบข้อมูลเกิดข้อผิดพลาด'
				});
			}
			return {success: true, Skills: result.skills}
		} catch (error) {
			console.error(error);
			return fail(500,{
				boxinfo: 'การเชื่อมต่อขัดข้อง'
			});
		}
	}
}
