/** @type {import('./$types').PageServerLoad} */
import { pool } from '$lib/server/db';
export async function load() {
    try{
        const [curriculumRows] = await pool.execute(
            `SELECT curriculum_id, curriculum_name FROM curriculum`
        );

        const [courseRows] = await pool.execute(
            `SELECT course_id, course_code, course_name, curriculum_id FROM courses`
        );
        return{
            curriculumRows: curriculumRows,
            courseRows: courseRows
        }
    }catch(error){
        console.error('err in load curriculum manage',error);
        return{
            curriculumRows:[],
            courseRows:[]
        }
    }
};