import { redirect } from '@sveltejs/kit';
import { pool } from '$lib/server/db.js';

export async function load({ url }) {
	const id = url.searchParams.get('id');

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

			return {
				courses: rows,
				jobs: jobRows
			};
		}catch(error){
			console.log('Error: Check Curriculum', error);
			return {
				courses: [],
				jobs: []
			};
		}
	}
}
