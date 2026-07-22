<script>
    import { resolve } from '$app/paths';
    import { enhance } from '$app/forms';
    import { invalidateAll } from '$app/navigation';
    import { fade } from 'svelte/transition';

    // 🎯 1. ดึงข้อมูลประยุกต์ใช้ผ่าน Props (Svelte 5 Rune - คงไว้ห้ามแก้)
    let { data } = $props();

    let login = resolve('/login');
    let home = resolve('/home');

    // 🎯 2. สเตทควบคุมการแสดงผลมอดอล (คงโครงสร้างเดิม)
    let authModalOpen = $state(!data.user);
    let curriculumModalOpen = $state(data.user && data.hasCurriculum === false);
    let curriculumList = $derived(Array.isArray(data?.curriculum) ? data.curriculum : []);
    let JobRecommendModal = $state(false);

    // ตัวแปรผูกกับ Dropdown หลักสูตรที่เลือก
    let selectedCurriculumId = $state(
        data.currentUserCurriculumId ? String(data.currentUserCurriculumId) : ''
    );
    /** @type {any[]} */
    let allCourses = $derived(Array.isArray(data?.allCourses) ? data.allCourses : []);
    let courseRecs = $derived(Array.isArray(data?.courseRecs) ? data.courseRecs : []);
    let selectedCareerId = $state('');
    let joblist = $derived(Array.isArray(data.jobs) ? data.jobs : []);

    $effect(() => {
        if (data.currentUserCurriculumId) {
            selectedCurriculumId = String(data.currentUserCurriculumId);
        }
    });

    let filteredCourses = $derived(
        selectedCurriculumId
            ? // @ts-ignore
              allCourses.filter((course) => String(course.curriculum_id) === String(selectedCurriculumId))
            : []
    );

    let courseSearch = $state('');

    let searchedCourses = $derived(
        courseSearch.trim()
            ? filteredCourses.filter((c) => {
                const q = courseSearch.toLowerCase().trim();
                return (
                    String(c.course_code).toLowerCase().includes(q) ||
                    String(c.course_name).toLowerCase().includes(q)
                );
            })
            : filteredCourses
    );

    // 🎯 ตัวเลือกเกรดสำหรับปุ่มกดเร็ว (Radio-style UI)
    const GRADE_OPTIONS = ['NOT_TAKEN', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];
    /** @type {Record<string, string>} */
    let courseGradeMap = $state({});

    /** @param {number|string} courseId @param {string|undefined} oldGrade */
    function currentGrade(courseId, oldGrade) {
        return courseGradeMap[courseId] ?? oldGrade ?? 'NOT_TAKEN';
    }

    /** @param {number|string} courseId @param {string} grade */
    function selectGrade(courseId, grade) {
        courseGradeMap[courseId] = grade;
    }

    // 🎯 3. ข้อมูลทักษะสำหรับเปรียบเทียบ
    let allJobSkills = $derived(Array.isArray(data?.jobSkills) ? data.jobSkills : []);
    let studentSkills = $derived(Array.isArray(data?.studentSkills) ? data.studentSkills : []);

    // แมพระดับทักษะที่นักศึกษาสะสมได้ ตาม skill_id
    let studentSkillMap = $derived.by(() => {
        const map = new Map();
        for (const s of studentSkills) {
            map.set(Number(s.skill_id), Number(s.achieved_level) || 0);
        }
        return map;
    });

    // 🎯 4. เปรียบเทียบทักษะของนักศึกษากับอาชีพที่เลือก
    let skillComparison = $derived.by(() => {
        if (!selectedCareerId) return [];
        // @ts-ignore
        const required = allJobSkills.filter(
            // @ts-ignore
            (js) => String(js.job_id) === String(selectedCareerId)
        );
        return required.map((js) => {
            const requiredLevel = Number(js.level_skill) || 0;
            const achievedLevel = studentSkillMap.get(Number(js.skill_id)) ?? 0;
            const diff = achievedLevel - requiredLevel;
            let status = 'gap';
            if (achievedLevel === 0) status = 'missing';
            else if (diff >= 0) status = 'met';
            else status = 'gap';
            return {
                skill_id: js.skill_id,
                skill_name: js.skill_name,
                requiredLevel,
                achievedLevel,
                diff,
                status
            };
        });
    });

    let matchedCount = $derived(skillComparison.filter((s) => s.status === 'met').length);
    let gapCount = $derived(skillComparison.filter((s) => s.status === 'gap').length);
    let missingCount = $derived(skillComparison.filter((s) => s.status === 'missing').length);
    let topSkill = $derived(data?.highestSkill);
    let secondSkill = $derived(data?.secondSkill);

    // 🎯 5. ข้อมูลสำหรับวาด Radar Chart
    // เมื่อเลือกอาชีพ: ใช้ทักษะของอาชีพนั้น (เทียบ student vs required)
    // เมื่อยังไม่เลือกอาชีพ: ใช้ทักษะทั้งหมดที่นักศึกษามี
    let radarData = $derived.by(() => {
        if (selectedCareerId && skillComparison.length > 0) {
            return {
                labels: skillComparison.map((s) => s.skill_name),
                student: skillComparison.map((s) => s.achievedLevel),
                career: skillComparison.map((s) => s.requiredLevel),
                hasCareer: true
            };
        }
        // ยังไม่เลือกอาชีพ -> แสดงทักษะทั้งหมดของนักศึกษา
        const list = studentSkills.map((s) => ({
            name: s.skill_name || `สกิล ${s.skill_id}`,
            level: Number(s.achieved_level) || 0
        }));
        return {
            labels: list.map((s) => s.name),
            student: list.map((s) => s.level),
            career: list.map(() => 0),
            hasCareer: false
        };
    });

    let radarHasData = $derived(radarData.labels.length > 0);

    // 🎯 7. สวิตช์สลับมุมมอง (ซ้าย = Radar Chart / ขวา = Matrix Table)
    let isMatrix = $state(false);

    // ข้อมูลสำหรับตารางเมทริกซ์ทักษะ (ใช้ข้อมูลเดียวกับเรดาร์)
    let matrixRows = $derived.by(() => {
        if (selectedCareerId && skillComparison.length > 0) {
            return skillComparison.map((s) => ({
                name: s.skill_name,
                required: s.requiredLevel,
                achieved: s.achievedLevel,
                status: s.status
            }));
        }
        return studentSkills.map((s) => ({
            name: s.skill_name || `สกิล ${s.skill_id}`,
            required: '-',
            achieved: Number(s.achieved_level) || 0,
            status: Number(s.achieved_level) > 0 ? 'met' : 'missing'
        }));
    });

    // 🎯 8. คำนวณรายวิชาแนะนำจากช่องว่างทักษะ (Skill Gaps)
    /** @type {any[]} */
    let courseSkills = $derived(Array.isArray(data?.courseSkills) ? data.courseSkills : []);

    let recommendedCourses = $derived.by(() => {
        if (!selectedCareerId || skillComparison.length === 0) return [];

        const gaps = skillComparison.filter(
            (s) => s.status === 'gap' || s.status === 'missing'
        );
        if (gaps.length === 0) return [];

        /** @type {Map<number, {course_id: any, skill_level: number}[]>} */
        const skillToCourses = new Map();
        for (const cs of courseSkills) {
            const sid = Number(cs.skill_id);
            let arr = skillToCourses.get(sid);
            if (!arr) {
                arr = [];
                skillToCourses.set(sid, arr);
            }
            arr.push({
                course_id: cs.course_id,
                skill_level: Number(cs.skill_level) || 0
            });
        }

        /** @type {Map<any, {course: any, fills: any[]}>} */
        const recMap = new Map();

        for (const gap of gaps) {
            const sid = Number(gap.skill_id);
            const required = gap.requiredLevel;
            const candidates = skillToCourses.get(sid) || [];
            if (candidates.length === 0) continue;

            // คัดวิชาที่สอนในระดับเท่ากับหรือสูงกว่าที่ต้องการ
            let matches = candidates.filter((c) => c.skill_level >= required);

            // ถ้าไม่มีวิชาได้ระดับที่ต้องการ ให้เลือกวิชาที่ใกล้เคียงที่สุด (เรียงระดับสูงไปต่ำ)
            const isClosestFallback = matches.length === 0;
            if (isClosestFallback) {
                matches = [...candidates].sort((a, b) => b.skill_level - a.skill_level);
            } else {
                matches.sort((a, b) => b.skill_level - a.skill_level);
            }

            for (const m of matches) {
                let entry = recMap.get(m.course_id);
                if (!entry) {
                    // @ts-ignore
                    const course = courseRecs.find((c) => c.course_id === m.course_id);
                    if (!course) continue;
                    entry = { course, fills: [] };
                    recMap.set(m.course_id, entry);
                }
                entry.fills.push({
                    skill_name: gap.skill_name,
                    required,
                    course_level: m.skill_level,
                    isClosest: isClosestFallback
                });
            }
        }

        return Array.from(recMap.values())
            .map((entry) => ({ ...entry.course, fills: entry.fills }))
            .sort((a, b) => b.fills.length - a.fills.length);
    });

    // 🎯 9. จัดอันดับสายงานที่ถนัด (แนะนำอาชีพที่ตรงทักษะมากที่สุด / เรียนเพิ่มน้อยที่สุด)
    let jobRecommendations = $derived.by(() => {
        if (joblist.length === 0 || allJobSkills.length === 0) return [];

        const ranked = joblist.map((job) => {
            // @ts-ignore
            const required = allJobSkills.filter(
                // @ts-ignore
                (js) => String(js.job_id) === String(job.job_id)
            );

            if (required.length === 0) {
                return {
                    job_id: job.job_id,
                    name_job: job.name_job,
                    totalSkills: 0,
                    metCount: 0,
                    gapCount: 0,
                    missingCount: 0,
                    matchPercent: 0,
                    levelMatchPercent: 0,
                    totalRequired: 0,
                    totalAchieved: 0,
                    skills: []
                };
            }

            let metCount = 0;
            let gapCount = 0;
            let missingCount = 0;
            let totalRequired = 0;
            let totalAchieved = 0;

            const skills = required.map((js) => {
                const requiredLevel = Number(js.level_skill) || 0;
                const achievedLevel = studentSkillMap.get(Number(js.skill_id)) ?? 0;
                const cappedAchieved = Math.min(achievedLevel, requiredLevel);

                totalRequired += requiredLevel;
                totalAchieved += cappedAchieved;

                let status = 'gap';
                if (achievedLevel === 0) {
                    status = 'missing';
                    missingCount++;
                } else if (achievedLevel >= requiredLevel) {
                    status = 'met';
                    metCount++;
                } else {
                    status = 'gap';
                    gapCount++;
                }

                return {
                    skill_id: js.skill_id,
                    skill_name: js.skill_name,
                    requiredLevel,
                    achievedLevel,
                    status
                };
            });

            const matchPercent = Math.round((metCount / required.length) * 100);
            const levelMatchPercent =
                totalRequired > 0 ? Math.round((totalAchieved / totalRequired) * 100) : 0;

            return {
                job_id: job.job_id,
                name_job: job.name_job,
                totalSkills: required.length,
                metCount,
                gapCount,
                missingCount,
                matchPercent,
                levelMatchPercent,
                totalRequired,
                totalAchieved,
                skills
            };
        });

        return ranked.sort((a, b) => {
            if (b.levelMatchPercent !== a.levelMatchPercent)
                return b.levelMatchPercent - a.levelMatchPercent;
            if (b.matchPercent !== a.matchPercent) return b.matchPercent - a.matchPercent;
            return a.gapCount + a.missingCount - (b.gapCount + b.missingCount);
        });
    });

    // 🎯 6. Canvas ref + ฟังก์ชันวาด Radar Chart
    /** @type {HTMLCanvasElement | null} */
    let radarCanvas = $state(null);

    function drawRadar() {
        const canvas = radarCanvas;
        if (!canvas) return;
        const ctx = /** @type {CanvasRenderingContext2D | null} */ (canvas.getContext('2d'));
        if (!ctx) return;

        // รองรับ HiDPI
        const dpr = window.devicePixelRatio || 1;
        const cssW = canvas.clientWidth || 300;
        const cssH = canvas.clientHeight || 256;
        canvas.width = Math.floor(cssW * dpr);
        canvas.height = Math.floor(cssH * dpr);
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

        const W = cssW;
        const H = cssH;
        ctx.clearRect(0, 0, W, H);

        const labels = radarData.labels;
        const student = radarData.student;
        const career = radarData.career;
        const n = labels.length;
        if (n === 0) return;

        const cx = W / 2;
        const cy = H / 2;
        const radius = Math.max(10, Math.min(W, H) / 2 - 54);

        const maxLevel = Math.max(
            5,
            ...student,
            ...(radarData.hasCareer ? career : [0])
        );

        /** @param {number} i */
        const angleFor = (i) => (Math.PI * 2 * i) / n - Math.PI / 2;
        /** @param {number} i @param {number} value */
        const pointFor = (i, value) => {
            const r = (value / maxLevel) * radius;
            const a = angleFor(i);
            return [cx + Math.cos(a) * r, cy + Math.sin(a) * r];
        };

        // ---- วงแหวนกรอบ (grid rings)
        const rings = maxLevel;
        ctx.lineWidth = 1;
        for (let r = 1; r <= rings; r++) {
            const rr = (r / rings) * radius;
            ctx.beginPath();
            for (let i = 0; i < n; i++) {
                const [px, py] = pointFor(i, r);
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.strokeStyle = r === rings ? '#d1d5db' : '#eef0f3';
            ctx.stroke();
        }

        // ---- เส้นแกนจากศูนย์กลาง
        ctx.strokeStyle = '#e5e7eb';
        for (let i = 0; i < n; i++) {
            const [px, py] = pointFor(i, maxLevel);
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.lineTo(px, py);
            ctx.stroke();
        }

        // ---- โพลีกอนของอาชีพ (สีน้ำตาลเข้ม) ถ้ามี
        if (radarData.hasCareer) {
            ctx.beginPath();
            for (let i = 0; i < n; i++) {
                const [px, py] = pointFor(i, career[i]);
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.fillStyle = 'rgba(68, 50, 16, 0.18)';
            ctx.fill();
            ctx.strokeStyle = '#443210';
            ctx.lineWidth = 2;
            ctx.stroke();
        }

        // ---- โพลีกอนของนักศึกษา (สีทอง)
        ctx.beginPath();
        for (let i = 0; i < n; i++) {
            const [px, py] = pointFor(i, student[i]);
            if (i === 0) ctx.moveTo(px, py);
            else ctx.lineTo(px, py);
        }
        ctx.closePath();
        ctx.fillStyle = 'rgba(220, 161, 29, 0.28)';
        ctx.fill();
        ctx.strokeStyle = '#DCA11D';
        ctx.lineWidth = 2;
        ctx.stroke();

        // จุดยอดของนักศึกษา
        ctx.fillStyle = '#DCA11D';
        for (let i = 0; i < n; i++) {
            const [px, py] = pointFor(i, student[i]);
            ctx.beginPath();
            ctx.arc(px, py, 3, 0, Math.PI * 2);
            ctx.fill();
        }

        // ---- ป้ายชื่อทักษะ
        ctx.fillStyle = '#6b7280';
        ctx.font = '600 11px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        for (let i = 0; i < n; i++) {
            const a = angleFor(i);
            const lx = cx + Math.cos(a) * (radius + 20);
            const ly = cy + Math.sin(a) * (radius + 16);
            const label = labels[i] && labels[i].length > 14 ? labels[i].slice(0, 13) + '…' : labels[i];
            ctx.fillText(label, lx, ly);
        }

        // มุมน้อยกว่า 3 ทักษะ วาดไม่ได้รูปทรง จัดการแยก
    }

    $effect(() => {
        // ติดตามการเปลี่ยนแปลงของข้อมูล + canvas
        void radarData;
        void radarCanvas;
        void radarHasData;
        drawRadar();
    });

    // วาดใหม่เมื่อหน้าต่างถูก resize
    $effect(() => {
        const handler = () => drawRadar();
        window.addEventListener('resize', handler);
        return () => window.removeEventListener('resize', handler);
    });
</script>

<svelte:head>
    <title>ประเมินทักษะ | Skill Mapping</title>
</svelte:head>

{#if authModalOpen}
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
        <div class="w-full max-w-md transform rounded-3xl border border-gray-100 bg-white p-8 text-center shadow-2xl transition-all animate-in fade-in zoom-in-95 duration-300">
            <div class="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-full bg-amber-50 text-[#DCA11D] ring-8 ring-amber-500/5">
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="2"
                    stroke="currentColor"
                    class="h-8 w-8"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"
                    />
                </svg>
            </div>
            <h3 class="text-2xl font-extrabold text-[#443210]">กรุณาเข้าสู่ระบบ</h3>
            <p class="mt-3 text-sm leading-relaxed text-gray-500 font-medium px-4">
                คุณจำเป็นต้องเข้าสู่ระบบก่อน เพื่อทำการวิเคราะห์และตรวจสอบช่องว่างทักษะตามรายวิชาเลือกของหลักสูตร
            </p>
            <div class="mt-8 flex flex-col gap-3">
                <a
                    href={login}
                    class="flex w-full items-center justify-center rounded-xl bg-[#443210] py-3.5 text-sm font-bold text-[#DCA11D] shadow-md shadow-amber-950/10 transition-all hover:bg-[#543f15] hover:shadow-lg"
                >
                    เข้าสู่ระบบตอนนี้
                </a>
                <a
                    href={home}
                    class="py-2 text-sm font-semibold text-gray-400 transition-colors hover:text-[#443210] hover:underline"
                >
                    กลับหน้าหลัก
                </a>
            </div>
        </div>
    </div>
{/if}

{#if curriculumModalOpen && !authModalOpen}
    <div class="fixed inset-0 z-40 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
        <div class="max-h-[85vh] w-full max-w-xl overflow-y-auto rounded-3xl border border-gray-100 bg-white p-6 md:p-8 text-left shadow-2xl transition-all animate-in fade-in zoom-in-95 duration-300 scrollbar-thin">
            <div class="mb-6 text-center border-b border-gray-100 pb-4">
                <h3 class="text-xl font-extrabold text-[#443210]">บันทึกข้อมูลการเรียน</h3>
                <p class="mt-1.5 text-xs font-medium text-gray-500">
                    กรุณาระบุหลักสูตรเพื่อดึงข้อมูลวิชาในการเลือกบันทึกเกรดสะสมของคุณ
                </p>
            </div>

            <form
                method="POST"
                action="?/saveCurriculumAndGrades"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.type === 'success') {
                            curriculumModalOpen = false;
                            await invalidateAll();
                        }
                    };
                }}
                class="space-y-6"
            >
                <div class="space-y-2.5">
                    <label for="curriculum" class="block text-sm font-bold text-[#443210]/90">
                        1. เลือกหลักสูตรสาขาวิชา <span class="text-red-500">*</span>
                    </label>
                    <div class="relative">
                        <select
                            id="curriculum"
                            name="curriculum_id"
                            bind:value={selectedCurriculumId}
                            required
                            class="w-full appearance-none rounded-xl border border-gray-200 bg-white py-3 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all focus:border-[#DCA11D] focus:ring-1 focus:ring-[#DCA11D] focus:outline-none"
                        >
                            <option value="" disabled selected>-- กรุณาเลือกหลักสูตร --</option>
                            {#each curriculumList as curri (curri.curriculum_id)}
                                <option value={String(curri.curriculum_id)}>{curri.curriculum_name}</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="space-y-3">
                    <span class="block text-sm font-bold text-[#443210]/90">
                        2. เลือกเกรดรายวิชาที่เรียนผ่านมาแล้ว
                    </span>

                    {#if filteredCourses.length > 0}
                        {#each filteredCourses as course (course.course_id)}
                            {@const oldGrade = data.savedGrades?.find(
                                //@ts-ignore
                                (g) => g.course_id === course.course_id
                            )?.grade_letter}
                            {@const activeGrade = currentGrade(course.course_id, oldGrade)}
                            <input type="hidden" name="course_id" value={course.course_id} />
                            <input type="hidden" name="course_grades" value={activeGrade} />
                        {/each}

                        <div class="relative">
                            <span class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-gray-400">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                                </svg>
                            </span>
                            <input
                                type="text"
                                bind:value={courseSearch}
                                placeholder="ค้นหารหัสวิชา หรือ ชื่อวิชา..."
                                class="w-full rounded-xl border border-gray-200 bg-white py-2.5 pl-10 pr-10 text-sm font-medium text-[#443210] shadow-sm placeholder-gray-400 outline-none transition-all focus:border-[#DCA11D] focus:ring-1 focus:ring-[#DCA11D]"
                            />
                            {#if courseSearch}
                                <button
                                    type="button"
                                    onclick={() => (courseSearch = '')}
                                    class="absolute inset-y-0 right-0 flex items-center pr-3 text-xs font-bold text-gray-400 hover:text-gray-600"
                                >
                                    ✕ ล้าง
                                </button>
                            {/if}
                        </div>

                        {#if searchedCourses.length > 0}
                            <div class="max-h-[35vh] space-y-2 overflow-y-auto pr-1 scrollbar-thin">
                                {#each searchedCourses as course (course.course_id)}
                                    {@const oldGrade = data.savedGrades?.find(
                                        //@ts-ignore
                                        (g) => g.course_id === course.course_id
                                    )?.grade_letter}
                                    {@const activeGrade = currentGrade(course.course_id, oldGrade)}
                                    <div class="rounded-xl border border-gray-100 bg-gray-50/40 p-4 shadow-sm transition-colors hover:bg-amber-50/20 hover:border-amber-200/50">
                                        <div class="flex items-center justify-between gap-4">
                                            <div class="min-w-0 flex-1">
                                                <p class="text-xs font-extrabold tracking-wider text-[#DCA11D] uppercase">
                                                    {course.course_code}
                                                </p>
                                                <p class="mt-0.5 truncate text-sm font-bold text-[#443210]">
                                                    {course.course_name}
                                                </p>
                                            </div>
                                        </div>

                                        <div class="mt-3 flex flex-wrap gap-1">
                                            {#each GRADE_OPTIONS as grade (grade)}
                                                <button
                                                    type="button"
                                                    onclick={() => selectGrade(course.course_id, grade)}
                                                    class="cursor-pointer rounded-lg px-2.5 py-1.5 text-xs font-bold transition-all duration-150 {activeGrade === grade ? 'bg-[#443210] text-[#DCA11D] shadow-sm ring-1 ring-[#DCA11D]/30' : 'border border-gray-200 bg-white text-gray-600 hover:border-[#DCA11D] hover:text-[#443210]'}"
                                                >
                                                    {grade === 'NOT_TAKEN' ? 'ยังไม่ได้เรียน' : grade}
                                                </button>
                                            {/each}
                                        </div>
                                    </div>
                                {/each}
                            </div>
                        {:else}
                            <div class="rounded-xl border border-dashed border-gray-200 bg-gray-50/50 p-8 text-center text-sm font-medium text-gray-400 italic">
                                ไม่พบรายวิชาที่ตรงกับ "{courseSearch.trim()}"
                            </div>
                        {/if}
                    {:else}
                        <div class="rounded-xl border border-dashed border-gray-200 bg-gray-50/50 p-8 text-center text-sm font-medium text-gray-400 italic">
                            {selectedCurriculumId
                                ? 'ไม่พบรายวิชาโครงสร้างในหลักสูตรนี้'
                                : 'กรุณาเลือกหลักสูตรสาขาวิชาด้านบนก่อน เพื่อเริ่มต้นบันทึกเกรด'}
                        </div>
                    {/if}
                </div>

                <div class="mt-6 flex flex-col gap-2 pt-2 border-t border-gray-100">
                    <button
                        type="submit"
                        disabled={filteredCourses.length === 0}
                        class="w-full cursor-pointer rounded-xl bg-[#443210] py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15] disabled:cursor-not-allowed disabled:bg-gray-200 disabled:text-gray-400"
                    >
                        บันทึกโครงสร้างหลักสูตรและเกรด
                    </button>

                    {#if curriculumModalOpen && data.hasCurriculum}
                        <button
                            type="button"
                            class="cursor-pointer py-2 text-center text-xs font-semibold text-gray-400 transition-colors hover:text-gray-700 hover:underline"
                            onclick={() => (curriculumModalOpen = false)}
                        >
                            ย้อนกลับหน้าแดชบอร์ด
                        </button>
                    {/if}
                </div>
            </form>
        </div>
    </div>
{/if}

{#if JobRecommendModal}
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 backdrop-blur-sm">
        <div class="max-h-[88vh] w-full max-w-3xl overflow-y-auto rounded-3xl border border-gray-100 bg-white p-6 md:p-8 shadow-2xl transition-all animate-in fade-in zoom-in-95 duration-300 scrollbar-thin">
            <div class="mb-6 flex items-start justify-between gap-4 border-b border-gray-100 pb-4">
                <div>
                    <h3 class="text-xl font-extrabold text-[#443210]">แนะนำสายงานที่ถนัด</h3>
                    <p class="mt-1.5 text-xs font-medium text-gray-500">
                        จัดอันดับตำแหน่งงานตามทักษะที่คุณมี โดยเรียงจากสายงานที่ตรงที่สุดและต้องเรียนเพิ่มน้อยที่สุด
                    </p>
                </div>
                <button
                    type="button"
                    onclick={() => (JobRecommendModal = false)}
                    class="shrink-0 cursor-pointer rounded-full p-2 text-gray-400 transition-colors hover:bg-gray-100 hover:text-[#443210]"
                    aria-label="ปิด"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-5 w-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>

            {#if jobRecommendations.length > 0}
                {@const top = jobRecommendations[0]}
                <div class="mb-6 rounded-2xl border border-[#DCA11D]/40 bg-gradient-to-br from-amber-50 to-amber-50/30 p-5">
                    <div class="flex flex-wrap items-center gap-2">
                        <span class="inline-flex items-center gap-1 rounded-full bg-[#443210] px-2.5 py-1 text-[10px] font-bold text-[#DCA11D]">
                            🏆 แนะนำอันดับ 1
                        </span>
                        <span class="rounded-full bg-white/70 px-2.5 py-1 text-[10px] font-bold text-amber-700">
                            ตรง {top.levelMatchPercent}%
                        </span>
                    </div>
                    <h4 class="mt-2 text-lg font-black text-[#443210]">{top.name_job}</h4>
                    <p class="mt-1 text-xs font-medium text-gray-500">
                        ตรงเกณฑ์ {top.metCount}/{top.totalSkills} ทักษะ · ต้องเพิ่ม {top.gapCount} · ยังไม่มี {top.missingCount}
                    </p>
                    <div class="mt-3 h-2 w-full overflow-hidden rounded-full bg-white/60">
                        <div class="h-full rounded-full bg-gradient-to-r from-[#DCA11D] to-[#443210] transition-all duration-500" style="width: {top.levelMatchPercent}%"></div>
                    </div>
                </div>

                <div class="space-y-3">
                    <h5 class="text-xs font-bold tracking-wider text-gray-400 uppercase">สรุปทุกตำแหน่งงานในหลักสูตร</h5>
                    {#each jobRecommendations as job, i (job.job_id)}
                        <details class="group rounded-xl border border-gray-100 bg-gray-50/40 transition-colors hover:bg-amber-50/20 {i === 0 ? 'ring-1 ring-[#DCA11D]/30' : ''}" open={i === 0}>
                            <summary class="flex cursor-pointer list-none items-center justify-between gap-3 p-4">
                                <div class="flex min-w-0 items-center gap-3">
                                    <span class="flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-black {i === 0 ? 'bg-[#443210] text-[#DCA11D]' : 'bg-gray-200 text-gray-500'}">
                                        {i + 1}
                                    </span>
                                    <div class="min-w-0">
                                        <p class="truncate text-sm font-bold text-[#443210]">{job.name_job}</p>
                                        <p class="mt-0.5 text-[11px] font-medium text-gray-500">
                                            ระดับที่มี {job.totalAchieved}/{job.totalRequired}
                                        </p>
                                    </div>
                                </div>
                                <div class="flex shrink-0 items-center gap-3">
                                    <div class="text-right">
                                        <p class="text-sm font-black text-[#DCA11D]">{job.levelMatchPercent}%</p>
                                        <p class="text-[10px] font-medium text-gray-400">ตรง {job.metCount}/{job.totalSkills}</p>
                                    </div>
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4 text-gray-400 transition-transform group-open:rotate-180">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                                    </svg>
                                </div>
                            </summary>
                            <div class="border-t border-gray-100 px-4 pb-4 pt-3">
                                <div class="mb-3 flex flex-wrap gap-2 text-[10px] font-bold">
                                    <span class="rounded-full bg-green-100 px-2 py-0.5 text-green-700">ตรง {job.metCount}</span>
                                    <span class="rounded-full bg-amber-100 px-2 py-0.5 text-amber-700">ขาด {job.gapCount}</span>
                                    <span class="rounded-full bg-red-100 px-2 py-0.5 text-red-700">ยังไม่มี {job.missingCount}</span>
                                </div>
                                <ul class="space-y-1.5">
                                    {#each job.skills as sk (sk.skill_id)}
                                        <li class="flex items-center justify-between gap-2 rounded-lg bg-white/70 px-3 py-1.5">
                                            <span class="truncate text-xs font-bold text-[#443210]">{sk.skill_name}</span>
                                            <span class="shrink-0 text-[11px] font-bold {sk.status === 'met' ? 'text-green-600' : sk.status === 'gap' ? 'text-amber-600' : 'text-red-500'}">
                                                {sk.achievedLevel}/{sk.requiredLevel}
                                            </span>
                                        </li>
                                    {/each}
                                </ul>
                            </div>
                        </details>
                    {/each}
                </div>
            {:else}
                <div class="rounded-2xl border border-dashed border-gray-200 bg-gray-50/50 p-10 text-center">
                    <p class="text-sm font-medium text-gray-400">ยังไม่มีข้อมูลสายงานหรือทักษะเพียงพอในการแนะนำ</p>
                </div>
            {/if}

            <div class="mt-6 flex justify-end border-t border-gray-100 pt-4">
                <button
                    type="button"
                    onclick={() => (JobRecommendModal = false)}
                    class="cursor-pointer rounded-xl bg-[#443210] px-6 py-2.5 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15]"
                >
                    ปิดหน้าต่าง
                </button>
            </div>
        </div>
    </div>
{/if}

<div class="min-h-screen bg-gradient-to-b from-amber-50/40 via-gray-50 to-gray-100/50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-12 md:py-16">
    <main class="container mx-auto max-w-7xl space-y-10 px-4 md:px-8">
        
        <section class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <div class="group flex items-center gap-5 rounded-2xl border border-gray-200/80 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#DCA11D]/30 hover:shadow-md">
                <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-[#443210] text-2xl font-black text-[#DCA11D] shadow-md md:h-20 md:w-20 md:text-3xl">
                    {data.completedCoursesCount || 0}
                </div>
                <div>
                    <h4 class="text-xs font-bold tracking-wider text-gray-400 uppercase">
                        รายวิชาที่ผ่านเกณฑ์แล้ว
                    </h4>
                    <p class="mt-0.5 text-2xl font-black text-[#443210]">รายวิชา</p>
                </div>
            </div>

            <div class="group flex items-center gap-5 rounded-2xl border border-gray-200/80 bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#DCA11D]/30 hover:shadow-md">
                <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full bg-[#443210] text-2xl font-black text-[#DCA11D] shadow-md md:h-20 md:w-20 md:text-3xl">
                    {data.passedSkillsCount || 0}
                </div>
                <div>
                    <h4 class="text-xs font-bold tracking-wider text-gray-400 uppercase">
                        สมรรถนะทักษะที่สะสมได้
                    </h4>
                    <p class="mt-0.5 text-2xl font-black text-[#443210]">ทักษะย่อย</p>
                </div>
            </div>

            <div class="flex flex-col justify-center rounded-2xl border border-gray-200/80 bg-white p-6 shadow-sm sm:col-span-2 lg:col-span-1">
                <div class="space-y-3.5">
                    <div class="flex items-start gap-2.5">
                        <span class="mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full bg-[#DCA11D] animate-pulse"></span>
                        <p class="text-sm font-bold text-gray-500">
                            ทักษะที่โดดเด่นที่สุด: 
                            <span class="block text-base font-extrabold text-[#443210] mt-0.5">{topSkill?.skill_name || 'ไม่พบข้อมูล'}
                                <span class="shrink-0 rounded-md border border-amber-400 bg-[#443210]/90 px-2.5 py-1 mx-4 text-[11px] font-bold text-[#dca11d]">
                                    Level: {topSkill?.achieved_level || 'ไม่พบข้อมูล'}
                                </span>
                            </span>
                        </p>
                    </div>
                    <div class="flex items-start gap-2.5 border-t border-gray-100 pt-2.5">
                        <span class="mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full bg-[#443210]/40"></span>
                        <p class="text-sm font-bold text-gray-500">
                            ทักษะที่เป็นรองย่อย: 
                            <span class="block text-base font-extrabold text-[#443210] mt-0.5">{secondSkill?.skill_name || 'ไม่พบข้อมูล'}
                                <span class="shrink-0 rounded-md border border-amber-400 bg-[#443210]/90 px-2.5 py-1 mx-4 text-[11px] font-bold text-[#dca11d]">
                                    Level: {secondSkill?.achieved_level || 'ไม่พบข้อมูล'}
                                </span>
                            </span>
                        </p>
                    </div>
                </div>
            </div>
        </section>

        <section class="grid grid-cols-1 items-start gap-8 lg:grid-cols-12">
            <div class="space-y-6 lg:col-span-7">
                <h2 class="text-2xl font-black tracking-tight text-[#443210]">สำรวจแผนผังทักษะของคุณ</h2>

                <div class="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:gap-4 bg-amber-50/30 p-4 rounded-xl border border-amber-500/10">
                    <label for="career-dropdown" class="shrink-0 text-sm font-extrabold text-[#443210]">
                        เปรียบเทียบช่องว่างกับอาชีพเป้าหมาย:
                    </label>
                    <div class="relative flex-1 max-w-xs">
                        <select
                            id="career-dropdown"
                            bind:value={selectedCareerId}
                            class="w-full appearance-none rounded-xl border border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all focus:border-[#DCA11D] focus:outline-none"
                        >
                            <option value="" disabled>-- กรุณาเลือกตำแหน่งงาน --</option>
                            {#each joblist as job (job.job_id)}
                                <option value={String(job.job_id)}>{job.name_job}</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all hover:border-amber-500/20">
                    <div class="flex items-center justify-between gap-3">
                        <h3 class="text-xs font-bold tracking-wider text-gray-400 uppercase">
                            ทักษะ/สมรรถนะที่ต้องศึกษาเพิ่ม (Skill Gaps)
                        </h3>
                        {#if selectedCareerId}
                            <div class="flex gap-2 text-[10px] font-bold">
                                <span class="rounded-full bg-green-100 px-2 py-0.5 text-green-700">ตรง {matchedCount}</span>
                                <span class="rounded-full bg-amber-100 px-2 py-0.5 text-amber-700">ขาด {gapCount}</span>
                                <span class="rounded-full bg-red-100 px-2 py-0.5 text-red-700">ยังไม่มี {missingCount}</span>
                            </div>
                        {/if}
                    </div>

                    {#if !selectedCareerId}
                        <p class="mt-3 text-sm font-medium text-gray-400 italic">
                            กรุณาเลือกตำแหน่งงานเป้าหมายด้านบน เพื่อเริ่มเปรียบเทียบช่องว่างทักษะ
                        </p>
                    {:else if skillComparison.length === 0}
                        <p class="mt-3 text-sm font-medium text-gray-400 italic">
                            ไม่พบข้อมูลทักษะที่ต้องการสำหรับอาชีพนี้
                        </p>
                    {:else}
                        <ul class="mt-4 space-y-2.5">
                            {#each skillComparison as sk (sk.skill_id)}
                                {@const pct = sk.requiredLevel > 0 ? Math.min(100, Math.round((sk.achievedLevel / sk.requiredLevel) * 100)) : 0}
                                <li class="rounded-xl border border-gray-100 bg-gray-50/40 p-4 transition-colors hover:bg-amber-50/20">
                                    <div class="flex items-center justify-between gap-3">
                                        <div class="min-w-0 flex-1">
                                            <p class="truncate text-sm font-bold text-[#443210]">
                                                {sk.skill_name}
                                            </p>
                                            <p class="mt-0.5 text-xs font-medium text-gray-500">
                                                ระดับที่มี: <span class="font-bold text-[#443210]">{sk.achievedLevel}</span>
                                                / ระดับที่ต้องการ: <span class="font-bold text-[#DCA11D]">{sk.requiredLevel}</span>
                                            </p>
                                        </div>
                                        <div class="shrink-0">
                                            {#if sk.status === 'met'}
                                                {#if sk.diff > 0}
                                                    <span class="inline-flex items-center gap-1 rounded-full bg-green-100 px-2.5 py-1 text-[11px] font-bold text-green-700">
                                                        ✓ เกิน {sk.diff} ระดับ
                                                    </span>
                                                {:else}
                                                    <span class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-1 text-[11px] font-bold text-green-700">
                                                        ✓ ตรงเกณฑ์
                                                    </span>
                                                {/if}
                                            {:else if sk.status === 'gap'}
                                                <span class="inline-flex items-center rounded-full bg-amber-100 px-2.5 py-1 text-[11px] font-bold text-amber-700">
                                                    ต้องเพิ่ม {Math.abs(sk.diff)} ระดับ
                                                </span>
                                            {:else}
                                                <span class="inline-flex items-center rounded-full bg-red-100 px-2.5 py-1 text-[11px] font-bold text-red-700">
                                                    ยังไม่มีทักษะนี้
                                                </span>
                                            {/if}
                                        </div>
                                    </div>
                                    <div class="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-gray-200">
                                        <div
                                            class="h-full rounded-full transition-all duration-500"
                                            class:bg-green-500={sk.status === 'met'}
                                            class:bg-amber-500={sk.status === 'gap'}
                                            class:bg-red-400={sk.status === 'missing'}
                                            style="width: {pct}%"
                                        ></div>
                                    </div>
                                </li>
                            {/each}
                        </ul>
                    {/if}
                </div>
            </div>

            <div class="flex flex-col items-center rounded-3xl border border-gray-200/60 bg-white p-6 shadow-sm lg:col-span-5 transition-all hover:shadow-md">
                <h3 class="mb-4 text-sm font-bold text-[#443210]/90 tracking-wide">
                    {isMatrix ? 'ตารางเมทริกซ์ทักษะ (Matrix Table)' : 'กราฟวิเคราะห์ทักษะใยแมงมุม (Radar Chart)'}
                </h3>

                <!-- 🎛️ สวิตช์สลับมุมมองซ้าย-ขวา -->
                <div class="mb-5 flex select-none items-center justify-center gap-2.5 sm:gap-3">
                    <span class="text-xs font-bold transition-colors duration-300 {isMatrix ? 'text-gray-400' : 'text-[#443210]'}">Radar Chart</span>
                    <button
                        type="button"
                        onclick={() => (isMatrix = !isMatrix)}
                        class="relative inline-flex h-7 w-14 shrink-0 items-center rounded-full transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-[#DCA11D]/40 {isMatrix ? 'bg-[#443210]' : 'bg-[#DCA11D]'}"
                        role="switch"
                        aria-checked={isMatrix}
                        aria-label="สลับมุมมองระหว่างกราฟเรดาร์และตารางเมทริกซ์"
                    >
                        <span class="inline-block h-5 w-5 transform rounded-full bg-white shadow-md transition-transform duration-300 {isMatrix ? 'translate-x-8' : 'translate-x-1'}"></span>
                    </button>
                    <span class="text-xs font-bold transition-colors duration-300 {isMatrix ? 'text-[#443210]' : 'text-gray-400'}">Matrix Table</span>
                </div>

                {#if !isMatrix}
                    <div class="w-full" transition:fade={{ duration: 300 }}>
                        {#if !radarHasData || radarData.labels.length < 3}
                            <div class="flex h-64 w-full flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-red-200 bg-red-50/40 text-center">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="h-10 w-10 text-red-400">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
                                </svg>
                                <p class="px-6 text-xs font-bold text-red-500">
                                    {radarHasData
                                        ? 'ข้อมูลทักษะไม่เพียงพอสำหรับการแสดงผลกราฟ (ต้องมีอย่างน้อย 3 ทักษะ)'
                                        : (selectedCareerId
                                            ? 'ไม่สามารถแสดงผลกราฟได้ เนื่องจากไม่พบข้อมูลทักษะของอาชีพที่เลือก'
                                            : 'ไม่สามารถแสดงผลกราฟได้ เนื่องจากไม่พบข้อมูลทักษะของคุณ กรุณาบันทึกเกรดก่อน')}
                                </p>
                            </div>
                        {:else}
                            <div class="w-full rounded-2xl border border-gray-100 bg-gray-50/40 p-2">
                                <canvas bind:this={radarCanvas} class="h-72 w-full"></canvas>
                            </div>

                            <div class="mt-5 flex gap-6 text-xs font-bold">
                                <div class="flex items-center gap-2">
                                    <span class="h-3 w-3 rounded-full bg-[#DCA11D]"></span>
                                    <span class="text-gray-500">ทักษะปัจจุบันของคุณ</span>
                                </div>
                                {#if radarData.hasCareer}
                                    <div class="flex items-center gap-2">
                                        <span class="h-3 w-3 rounded-full bg-[#443210]"></span>
                                        <span class="text-gray-500">ความต้องการของสายงาน</span>
                                    </div>
                                {/if}
                            </div>
                        {/if}
                    </div>
                {:else}
                    <div class="w-full" transition:fade={{ duration: 300 }}>
                        {#if matrixRows.length === 0}
                            <div class="flex h-64 w-full flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-gray-200 bg-gray-50/40 text-center">
                                <p class="px-6 text-xs font-bold text-gray-400">
                                    ไม่พบข้อมูลทักษะสำหรับแสดงในตาราง
                                </p>
                            </div>
                        {:else}
                            <div class="max-h-72 w-full overflow-auto scrollbar-thin rounded-2xl border border-gray-100">
                                <table class="w-full border-collapse text-left text-xs">
                                    <thead class="sticky top-0 z-10 bg-[#443210] text-[#DCA11D]">
                                        <tr>
                                            <th class="whitespace-nowrap px-3 py-2.5 font-bold">ทักษะ/สมรรถนะ</th>
                                            <th class="whitespace-nowrap px-3 py-2.5 text-center font-bold">ระดับที่มี</th>
                                            <th class="whitespace-nowrap px-3 py-2.5 text-center font-bold">ระดับที่ต้องการ</th>
                                            <th class="whitespace-nowrap px-3 py-2.5 text-center font-bold">สถานะ</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-100">
                                        {#each matrixRows as row (row.name)}
                                            <tr class="transition-colors hover:bg-amber-50/20">
                                                <td class="px-3 py-2.5 font-bold text-[#443210]">{row.name}</td>
                                                <td class="px-3 py-2.5 text-center font-bold text-[#443210]">{row.achieved}</td>
                                                <td class="px-3 py-2.5 text-center font-bold text-[#DCA11D]">{row.required}</td>
                                                <td class="px-3 py-2.5 text-center">
                                                    {#if row.status === 'met'}
                                                        <span class="inline-flex items-center rounded-full bg-green-100 px-2 py-0.5 text-[10px] font-bold text-green-700">ตรงเกณฑ์</span>
                                                    {:else if row.status === 'gap'}
                                                        <span class="inline-flex items-center rounded-full bg-amber-100 px-2 py-0.5 text-[10px] font-bold text-amber-700">ต้องเพิ่ม</span>
                                                    {:else}
                                                        <span class="inline-flex items-center rounded-full bg-red-100 px-2 py-0.5 text-[10px] font-bold text-red-700">ยังไม่มี</span>
                                                    {/if}
                                                </td>
                                            </tr>
                                        {/each}
                                    </tbody>
                                </table>
                            </div>
                        {/if}
                    </div>
                {/if}
            </div>
        </section>

        <section class="space-y-6 pt-4 border-t border-gray-200/50">
            <h2 class="text-xl font-bold text-[#443210] md:text-2xl">วิชาแนะนำสำหรับคุณ</h2>

            {#if !selectedCareerId}
                <div class="rounded-2xl border-2 border-dashed border-gray-200 bg-white p-12 text-center shadow-sm">
                    <p class="font-medium text-gray-400">กรุณาเลือกตำแหน่งงานเป้าหมายด้านบนเพื่อแสดงรายวิชาที่แนะนำ</p>
                </div>
            {:else if skillComparison.length === 0}
                <div class="rounded-2xl border-2 border-dashed border-gray-200 bg-white p-12 text-center shadow-sm">
                    <p class="font-medium text-gray-400">ไม่พบข้อมูลทักษะของอาชีพที่เลือก</p>
                </div>
            {:else if gapCount === 0 && missingCount === 0}
                <div class="rounded-2xl border-2 border-dashed border-green-200 bg-green-50/40 p-12 text-center shadow-sm">
                    <p class="font-bold text-green-600">ยินดีด้วย! คุณมีทักษะครบตามที่อาชีพนี้ต้องการแล้ว</p>
                </div>
            {:else if recommendedCourses.length === 0}
                <div class="rounded-2xl border-2 border-dashed border-gray-200 bg-white p-12 text-center shadow-sm">
                    <p class="font-medium text-gray-400">ไม่พบรายวิชาในหลักสูตรของคุณที่สามารถช่วยเติมเต็มทักษะที่ขาดได้</p>
                </div>
            {:else}
                <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                    {#each recommendedCourses as course (course.course_id)}
                        <button
                            type="button"
                            onclick={() => info_subject(course.course_id)}
                            class="group btn flex cursor-pointer flex-col justify-between rounded-2xl border border-gray-200/80 bg-white p-5 text-left shadow-sm transition-all duration-300 hover:border-[#DCA11D]/40"
                        >
                            <div class="mb-4">
                                <span class="inline-block rounded-md bg-amber-50 px-2.5 py-1 text-xs font-bold text-amber-700 border border-amber-200/40">
                                    {course.course_code}
                                </span>
                                <h3 class="mt-3 line-clamp-2 h-11 text-sm leading-snug font-bold text-[#443210]/90 transition-colors group-hover:text-[#dca11d] md:text-base">
                                    {course.course_name}
                                </h3>
                            </div>

                            <div class="border-t border-gray-100 pt-3">
                                <span class="text-[10px] font-bold tracking-wider text-gray-400 uppercase">ช่วยเติมเต็มทักษะ</span>
                                <div class="mt-1.5 flex flex-wrap gap-1">
                                    {#each course.fills as f (f.skill_name)}
                                        <span
                                            class="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold {f.isClosest ? 'bg-amber-100 text-amber-700' : 'bg-green-100 text-green-700'}"
                                            title={f.isClosest ? 'วิชาที่ใกล้เคียงที่สุด (ยังไม่ถึงระดับที่ต้องการ)' : 'สอนถึงระดับที่ต้องการ'}
                                        >
                                            {f.skill_name} · Lv{f.course_level}/{f.required}
                                        </span>
                                    {/each}
                                </div>
                            </div>
                        </button>
                    {/each}
                </div>
            {/if}

            <div class="flex justify-end items-center gap-3 pt-2">
                <button
                    type="button"
                    onclick={() => (JobRecommendModal = true)}
                    class="cursor-pointer rounded-xl bg-amber-500/10 px-6 py-3 text-sm font-bold text-[#443210] border border-amber-500/20 transition-all hover:bg-amber-500/20"
                >
                    แนะนำสายงานที่ถนัด 💡
                </button>
                <button
                    type="button"
                    class="cursor-pointer rounded-xl bg-[#443210] px-6 py-3 text-sm font-bold text-[#DCA11D] shadow-md shadow-amber-950/10 transition-all hover:bg-[#543f15] hover:shadow-lg"
                    onclick={() => (curriculumModalOpen = true)}
                >
                    ปรับปรุงข้อมูลเกรด 📝
                </button>
            </div>
        </section>
    </main>
</div>

<style>
    /* ซ่อนแถบเลื่อนให้เรียบหรูตามคอนเซปต์พรีเมียม */
    .scrollbar-thin::-webkit-scrollbar {
        width: 5px;
    }
    .scrollbar-thin::-webkit-scrollbar-track {
        background: transparent;
    }
    .scrollbar-thin::-webkit-scrollbar-thumb {
        background: #e5e7eb;
        border-radius: 99px;
    }
    .scrollbar-thin::-webkit-scrollbar-thumb:hover {
        background: #DCA11D;
    }
</style>