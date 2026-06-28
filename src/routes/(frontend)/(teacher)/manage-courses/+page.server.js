import { pool } from "$lib/server/db";
import { error, redirect } from "@sveltejs/kit";

/** @type {import('./$types').PageServerLoad} */
export async function load({locals}) {
    if(!locals.user){
        throw redirect(302,'/');
    }
    try{
        const [userRows] = await pool.query('SELECT id, curriculum_id FROM users WHERE username = ?',[locals.user.username]);
        //@ts-ignore
        const user = userRows[0];

        const [coursesRows] = await pool.execute(
            `SELECT course_id, course_code, course_name, credits, description, curriculum_id FROM courses WHERE curriculum_id = ?`,
            [user.curriculum_id]
        );
        const [curriculumRows] = await pool.execute(
            `SELECT curriculum_id, curriculum_name FROM curriculum`
        );
        return {
            user,
            courses: coursesRows,
            curriculums: curriculumRows
        }
    }catch(error){
        console.error('Error fetching courses:',error);
        return {
            user: null,
            courses: [],
            curriculums: []
        }
    }
};

/** @type {import('./$types').Actions} */
export const actions = {
    updateCourse: async ({ request }) => {
        const data = await request.formData();
        const course_id = data.get('course_id');
        const curriculum_id = data.get('curriculum_id');
        const course_code = data.get('course_code');
        const credits = data.get('credits');
        const course_name = data.get('course_name');
        const description = data.get('description');

        try {
            if (!course_id || !curriculum_id || !course_code || !credits || !course_name) {
                return { success: false, message: 'กรุณากรอกข้อมูลให้ครบถ้วน 📋' };
            }

            // ตรวจสอบวิชาซ้ำที่ไม่ใช่รายการของตัวเอง
            /** @type {[any, any]} */
            const [courseRows] = await pool.execute(
                `SELECT course_code, course_name, curriculum_id FROM courses
                WHERE ((course_code = ? AND curriculum_id = ?) 
                    OR (course_name = ? AND curriculum_id = ?))
                    AND course_id != ?`,
                [course_code, curriculum_id, course_name, curriculum_id, course_id]
            );

            if (courseRows.length > 0) {
                const matched = courseRows[0];
                if (matched.course_code === course_code) {
                    return { success: false, message: 'รหัสวิชานี้มีอยู่แล้วในแผนก/หลักสูตรรวมนี้ ❌' };
                }
                if (matched.course_name === course_name) {
                    return { success: false, message: 'ชื่อวิชานี้มีอยู่แล้วในแผนก/หลักสูตรรวมนี้ ❌' };
                }
                return { success: false, message: 'วิชานี้ซ้ำในแผนกนี้แล้ว ❌' };
            }

            await pool.execute(
                `UPDATE courses 
                SET curriculum_id = ?, course_code = ?, credits = ?, course_name = ?, description = ? 
                WHERE course_id = ?`,
                [curriculum_id, course_code, credits, course_name, description, course_id]
            );

            return { success: true, message: 'แก้ไขข้อมูลวิชาเรียนสำเร็จ ✅' };
        } catch (err) {
            console.error('err in update course', err);
            return { success: false, message: 'เกิดปัญหาการบันทึกข้อมูล' };
        }
    },

    createCourse: async ({request}) =>{
        const data = await request.formData();
        const curriculum_id = data.get('curriculum_id');
        const course_code = data.get('course_code');
        const credits = data.get('credits');
        const course_name = data.get('course_name');
        const description = data.get('description');

        try{
            /** @type {[any, any]} */
            const [courseRows] = await pool.execute(
                `SELECT course_code, course_name, curriculum_id FROM courses
                WHERE (course_code = ? AND curriculum_id = ?) 
                    OR (course_name = ? AND curriculum_id = ?)`,
                [course_code, curriculum_id, course_name, curriculum_id]
            );

            if (courseRows.length > 0) {
                const matched = courseRows[0];
                
                if (matched.course_code === course_code) {
                    return { success: false, message: 'รหัสวิชานี้มีอยู่แล้วในแผนก/หลักสูตรรวมนี้ ❌' };
                }
                if (matched.course_name === course_name) {
                    return { success: false, message: 'ชื่อวิชานี้มีอยู่แล้วในแผนก/หลักสูตรรวมนี้ ❌' };
                }
                return { success: false, message: 'วิชานี้ซ้ำในแผนกนี้แล้ว ❌' };
            }

            await pool.execute(
                `INSERT INTO courses (curriculum_id, course_code, credits, course_name, description) 
                VALUES (?, ?, ?, ?, ?)`,[curriculum_id,course_code,credits,course_name,description]
            );
            return{success: true, message: 'เพิ่มวิชาเรียนสำเร็จ✅'}
        }catch(err){
            console.error('err in create course',err);
            return{success: false, message:'เกิดปัญหาการบันทึกข้อมูล'}
        }
    },

    deleteCourse: async ({ request }) => {
        const data = await request.formData();
        const course_id = data.get('course_id');

        try {
            if (!course_id) {
                return { success: false, message: 'ไม่พบรหัสวิชาที่จะลบ' };
            }

            await pool.execute('DELETE FROM courses WHERE course_id = ?', [course_id]);
            return { success: true, message: 'ลบวิชาเรียนสำเร็จ ✅' };
        } catch (err) {
            console.error('err in delete course', err);
            return { success: false, message: 'เกิดปัญหาในการลบข้อมูล' };
        }
    }
};