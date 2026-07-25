import { pool } from '$lib/server/db';

export const load = async () => {
    try {
        /** @type {any[]} */
        // 1. นับจำนวนผู้ใช้ทั้งหมด (แกะ rows ออกมาตัวเดียวก่อน)
        const [userRows] = await pool.execute('SELECT COUNT(*) as totalUsers FROM users');
        const totalUsers = userRows[0]?.totalUsers ?? 0;
        
        // 2. นับจำนวนวิชาทั้งหมด
        /** @type {any[]} */
        const [courseRows] = await pool.execute('SELECT COUNT(*) as totalCourses FROM courses');
        const totalCourses = courseRows[0]?.totalCourses ?? 0;
        
        // 3. นับจำนวนหลักสูตร/แผนก
        /** @type {any[]} */
        const [curriculumRows] = await pool.execute('SELECT COUNT(*) as totalCurriculums FROM curriculum');
        const totalCurriculums = curriculumRows[0]?.totalCurriculums ?? 0;
        
        // 4. สรุปผลรวมหน่วยกิตทั้งหมดในระบบ
        /** @type {any[]} */
        const [creditRows] = await pool.execute('SELECT SUM(credits) as totalCredits FROM courses');
        const totalCredits = creditRows[0]?.totalCredits ?? 0;

        // 5. นับจำนวนทักษะทั้งหมดในระบบ
        /** @type {any[]} */
        const [skillRows] = await pool.execute('SELECT COUNT(*) as totalSkills FROM skills');
        const totalSkills = skillRows[0]?.totalSkills ?? 0;

        // 6. นับจำนวนอาชีพ/สายงานทั้งหมดในระบบ
        /** @type {any[]} */
        const [jobRows] = await pool.execute('SELECT COUNT(*) as totalJobs FROM job');
        const totalJobs = jobRows[0]?.totalJobs ?? 0;

        // 7. ดึงวิชาล่าสุด 5 วิชามาโชว์ที่ Sidebar
        const [recentCourses] = await pool.execute(
            'SELECT course_code, course_name, credits FROM courses ORDER BY curriculum_id DESC LIMIT 5'
        );

        // 8. การกระจายระดับทักษะที่อาชีพเรียกร้อง (ฝั่งอาชีพ) แยกตามเลเวล 1-6
        const [jobSkillLevelRows] = await pool.execute(
            'SELECT level_skill, COUNT(*) as count FROM job_skills GROUP BY level_skill ORDER BY level_skill'
        );

        // 9. การกระจายระดับทักษะที่รายวิชาสอน (ฝั่งรายวิชา) แยกตามเลเวล 1-6
        const [courseSkillLevelRows] = await pool.execute(
            'SELECT skill_level as level_skill, COUNT(*) as count FROM course_skills GROUP BY skill_level ORDER BY skill_level'
        );

        return {
            stats: {
                totalUsers,
                totalCourses,
                totalCurriculums,
                totalCredits: totalCredits || 0,
                totalSkills,
                totalJobs
            },
            recentCourses: recentCourses || [],
            jobSkillDistribution: jobSkillLevelRows || [],
            courseSkillDistribution: courseSkillLevelRows || []
        };
    } catch (err) {
        console.error('Dashboard Load Error:', err);
        return {
            stats: { totalUsers: 0, totalCourses: 0, totalCurriculums: 0, totalCredits: 0, totalSkills: 0, totalJobs: 0 },
            recentCourses: [],
            jobSkillDistribution: [],
            courseSkillDistribution: []
        };
    }
};