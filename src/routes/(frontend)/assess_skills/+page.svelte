<script>
    import { resolve } from '$app/paths';
    import { enhance } from '$app/forms';
    import { invalidateAll } from '$app/navigation';

    // 🎯 1. ดึงข้อมูลประยุกต์ใช้ผ่าน Props (Svelte 5 Rune - คงไว้ห้ามแก้)
    let { data } = $props();

    let login = resolve('/login');
    let home = resolve('/home');

    // 🎯 2. สเตทควบคุมการแสดงผลมอดอล (คงโครงสร้างเดิม)
    let authModalOpen = $state(!data.user);
    let curriculumModalOpen = $state(data.user && data.hasCurriculum === false);
    let curriculumList = $derived(Array.isArray(data?.curriculum) ? data.curriculum : []);

    // ตัวแปรผูกกับ Dropdown หลักสูตรที่เลือก
    let selectedCurriculumId = $state(
        data.currentUserCurriculumId ? String(data.currentUserCurriculumId) : ''
    );
    let allCourses = $derived(Array.isArray(data?.allCourses) ? data.allCourses : []);
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
                        <div class="max-h-[35vh] space-y-2 overflow-y-auto pr-1 scrollbar-thin">
                            {#each filteredCourses as course (course.course_code)}
                                {@const oldGrade = data.savedGrades?.find(
                                    (g) => g.course_id === course.course_id
                                )?.grade_letter}
                                <div class="flex items-center justify-between gap-4 rounded-xl border border-gray-100 bg-gray-50/40 p-4 shadow-sm transition-colors hover:bg-amber-50/20 hover:border-amber-200/50">
                                    <div class="min-w-0 flex-1">
                                        <p class="text-xs font-extrabold tracking-wider text-[#DCA11D] uppercase">
                                            {course.course_code}
                                        </p>
                                        <p class="mt-0.5 truncate text-sm font-bold text-[#443210]">
                                            {course.course_name}
                                        </p>
                                        <input type="hidden" name="course_id" value={course.course_id} />
                                    </div>

                                    <div class="relative w-28 shrink-0">
                                        <select
                                            name="course_grades"
                                            required
                                            class="w-full appearance-none rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm font-bold text-[#443210] shadow-sm focus:border-[#DCA11D] focus:outline-none"
                                        >
                                            <option value="" disabled selected={!oldGrade}>เลือกเกรด</option>
                                            <option value="NOT_TAKEN" selected={oldGrade === 'NOT_TAKEN'}>ยังไม่ได้เรียน</option>
                                            <option value="A" selected={oldGrade === 'A'}>A</option>
                                            <option value="B+" selected={oldGrade === 'B+'}>B+</option>
                                            <option value="B" selected={oldGrade === 'B'}>B</option>
                                            <option value="C+" selected={oldGrade === 'C+'}>C+</option>
                                            <option value="C" selected={oldGrade === 'C'}>C</option>
                                            <option value="D+" selected={oldGrade === 'D+'}>D+</option>
                                            <option value="D" selected={oldGrade === 'D'}>D</option>
                                            <option value="F" selected={oldGrade === 'F'}>F</option>
                                        </select>
                                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-gray-400">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="h-3 w-3">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                                            </svg>
                                        </div>
                                    </div>
                                </div>
                            {/each}
                        </div>
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
                            <span class="block text-base font-extrabold text-[#443210] mt-0.5">รอกรอกยังไม่ได้ทำ</span>
                        </p>
                    </div>
                    <div class="flex items-start gap-2.5 border-t border-gray-100 pt-2.5">
                        <span class="mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full bg-[#443210]/40"></span>
                        <p class="text-sm font-bold text-gray-500">
                            ทักษะที่เป็นรองย่อย: 
                            <span class="block text-base font-bold text-[#443210]/80 mt-0.5">รอกรอกยังไม่ได้ทำ</span>
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
                    <h3 class="text-xs font-bold tracking-wider text-gray-400 uppercase">
                        ทักษะ/สมรรถนะที่ต้องศึกษาเพิ่ม (Skill Gaps)
                    </h3>
                    <p class="mt-3 text-lg font-bold tracking-tight text-[#DCA11D] md:text-xl">
                        รอกรอกยังไม่ได้ทำ
                    </p>
                </div>
            </div>

            <div class="flex flex-col items-center rounded-3xl border border-gray-200/60 bg-white p-6 shadow-sm lg:col-span-5 transition-all hover:shadow-md">
                <h3 class="mb-4 text-sm font-bold text-[#443210]/90 tracking-wide">กราฟวิเคราะห์ทักษะใยแมงมุม (Radar Chart)</h3>

                <div class="flex h-64 w-full items-center justify-center rounded-2xl border border-dashed border-gray-200 bg-gray-50/50">
                    <p class="text-xs font-bold text-gray-400 italic">
                        [ ส่วนสำหรับเรนเดอร์ Radar Chart Canvas ]
                    </p>
                </div>

                <div class="mt-5 flex gap-6 text-xs font-bold">
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-[#DCA11D]"></span>
                        <span class="text-gray-500">ทักษะปัจจุบันของคุณ</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="h-3 w-3 rounded-full bg-[#443210]"></span>
                        <span class="text-gray-500">ความต้องการของสายงาน</span>
                    </div>
                </div>
            </div>
        </section>

        <section class="space-y-6 pt-4 border-t border-gray-200/50">
            <h2 class="text-xl font-bold text-[#443210] md:text-2xl">วิชาเลือกเสรีแนะนำสำหรับคุณ</h2>

            <div class="flex justify-end items-center gap-3 pt-2">
                <button
                    type="button"
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