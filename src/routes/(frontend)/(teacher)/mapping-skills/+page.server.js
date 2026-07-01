import { pool } from "$lib/server/db";
import { redirect } from "@sveltejs/kit";

/**@type{import('./$types').PageServerLoad} */
export async function load({locals}) {
    if(!locals.user){
        throw redirect(302,'/');
    }
    try{
        //@ts-ignore
    const [userRows] = await pool.query('SELECT id, curriculum_id FROM users WHERE username = ?',[locals.user.username]);
    //@ts-ignore
    const user = userRows[0];

    const [coursesRows] = await pool.execute(`SELECT course_id,course_code,course_name,curriculum_id 
        FROM courses WHERE curriculum_id = ? ORDER BY course_code`,[user.curriculum_id]);
    /** @type {any} */
    const courses = coursesRows;

    const [skillsRows] = await pool.execute(`
        SELECT s.skill_id, s.skill_name, s.curriculum_id, c.curriculum_name
        FROM skills s
        LEFT JOIN curriculum c ON s.curriculum_id = c.curriculum_id
        WHERE s.curriculum_id = ?
        ORDER BY s.skill_name
    `, [user.curriculum_id]);
    /** @type {any} */
    const finalSkills = skillsRows;

    const [mappingsRows] = await pool.execute('SELECT course_id,skill_id,skill_level FROM course_skills');
    /** @type {any} */
    const mappings = mappingsRows;

    return {
        courses,
        allSkills: finalSkills,
        mappings
    };
    }catch(error){
        console.error('Error fetching courses:',error);
        return {
            courses: [],
            allSkills: [],
            mappings: []
        }
    }
}

/**@type{import('./$types').Actions} */
export const actions = {
    saveMapping: async ({ request }) => {
        try {
            const formData = await request.formData();
            const courseId = Number(formData.get('courseId'));
            const skillsJson = formData.get('skills');
            //@ts-ignore
            const skills = JSON.parse(skillsJson || '[]');

            // Delete existing mappings for this course
            await pool.execute('DELETE FROM course_skills WHERE course_id = ?', [courseId]);

            // Insert new mappings
            for (const skill of skills) {
                // Find skill_id from database
                const [skillRows] = await pool.execute('SELECT skill_id FROM skills WHERE skill_name = ?', [skill.name]);
                /** @type {any} */
                const finalSkillRows = skillRows;
                if (finalSkillRows.length > 0) {
                    const skillId = finalSkillRows[0].skill_id;
                    await pool.execute(
                        'INSERT INTO course_skills (course_id, skill_id, skill_level) VALUES (?, ?, ?)',
                        [courseId, skillId, skill.level]
                    );
                }
            }

            return { success: true };
        } catch (error) {
            console.error('Error saving mapping:', error);
            /** @type {any} */
            //@ts-ignore
            const finalErrorMsg = error.message;
            return { success: false, error: finalErrorMsg };
        }
    }
};
