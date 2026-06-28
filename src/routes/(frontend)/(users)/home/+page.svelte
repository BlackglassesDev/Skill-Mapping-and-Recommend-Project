<script>
    import { enhance } from '$app/forms';
    import { goto } from '$app/navigation';
    import { resolve } from '$app/paths';

    /** @type {{ data: { courses: any[], jobs: any[], user: any } }} */
    let { data } = $props();

    // บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length (คงตรรกะเดิมไว้ทั้งหมด)
    let courses = $derived(Array.isArray(data.courses) ? data.courses.slice(0, 8) : []);
    let allcourses = $derived(Array.isArray(data.courses) ? data.courses : []);
    let allcourses_more = $state(false);
    let displayCourses = $derived(allcourses_more ? allcourses : courses);
    let jobs = $derived(Array.isArray(data.jobs) ? data.jobs.slice(0, 5) : []);
    let alljobs = $derived(Array.isArray(data.jobs) ? data.jobs : []);
    let curriculum_name = $derived(Array.isArray(data.curriculum_name) ? data.curriculum_name : []);
    let boxinfo = $state('');
    let job_skill_Modal = $state(false);
    let jobs_more = $state(false);
    /** @type {any[]} */
    let selectedJobSkills = $state([]); 
    // @ts-ignore
    let courseSkillsList = $derived(Array.isArray(data.course_skills) ? data.course_skills : []);

    const steps = [
        { icon: '🎯', text: 'รู้จักตัวเอง' },
        { icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
        { icon: '💡', text: 'แนะนำรายวิชา' }
    ];

    /** @param {string} id */
    async function info_subject(id) {
        const info = resolve(`/info_subject?info=${id}`);
        goto(info);
    }
</script>

<svelte:head>
    <title>Skill Mapping | RMUTL | Home</title>
</svelte:head>

<div class="min-h-screen bg-gradient-to-b from-amber-50/40 via-gray-50 to-gray-100/50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-size-[16px_16px] py-12 md:py-20">
    <div class="mx-auto max-w-6xl space-y-20 px-4">
        
        <section class="space-y-6 text-center max-w-3xl mx-auto">
            <h1 class="text-3xl font-extrabold tracking-tight text-[#443210] sm:text-4xl md:text-5xl leading-tight">
                หลักสูตร 
                <span class="bg-gradient-to-r from-[#443210] to-[#dca11d] bg-clip-text text-transparent">{data.curriculum_name}</span>
            </h1>
            <p class="text-base text-gray-600 max-w-xl mx-auto font-medium">
                อ้างอิงตามโครงสร้างหลักสูตร มทร.ล้านนา
            </p>

            <div class="flex flex-wrap justify-center gap-8 pt-12 md:gap-16">
                {#each steps as step (step.text)}
                    <div class="flex flex-col items-center gap-4 group/step">
                        <div class="flex h-28 w-28 items-center justify-center rounded-full bg-white text-[#443210] shadow-[0_10px_30px_rgba(68,50,16,0.06)] ring-1 ring-gray-100 transition-all duration-500 group-hover/step:-translate-y-2 group-hover/step:shadow-[0_20px_40px_rgba(220,161,29,0.2)] group-hover/step:ring-2 group-hover/step:ring-[#dca11d]/50 md:h-32 md:w-32">
                            <span class="text-4xl transition-transform duration-500 group-hover/step:scale-110 md:text-5xl">
                                {step.icon}
                            </span>
                        </div>
                        <span class="text-sm font-bold text-[#443210]/90 md:text-base tracking-wide transition-colors group-hover/step:text-[#dca11d]">
                            {step.text}
                        </span>
                    </div>
                {/each}
            </div>
        </section>

        <section class="space-y-6 bg-white/60 p-6 md:p-8 rounded-3xl border border-gray-200/60 backdrop-blur-md shadow-sm">
            <div class="flex items-center justify-between border-b border-gray-100 pb-4">
                <h2 class="text-xl font-bold text-[#443210] md:text-2xl flex items-center gap-2">
                    <span class="text-2xl">💼</span> เรียนจบแล้วเป็นอะไรได้บ้าง ?
                </h2>
            </div>

            {#if jobs.length === 0}
                <div class="col-span-full rounded-2xl border-2 border-dashed border-gray-200 bg-gray-50/50 p-12 text-center">
                    <p class="font-medium text-gray-400">ไม่พบข้อมูลอาชีพในขณะนี้</p>
                </div>
            {/if}

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                {#each jobs as job (job.job_id)}
                    <form
                        class="w-full"
                        method="POST"
                        action="?/call_jobs"
                        use:enhance={() => {
                            job_skill_Modal = true;
                            return async ({ result }) => {
                                if (result.type === 'success') {
                                    // @ts-ignore
                                    selectedJobSkills = result.data?.Skills;
                                } else {
                                    // @ts-ignore
                                    boxinfo = result.data?.boxinfo;
                                }
                            };
                        }}
                    >
                        <input type="hidden" name="id" value={job.job_id} />

                        <button
                            type="submit"
                            class="group flex w-full cursor-pointer items-center gap-4 text-left focus:outline-none"
                        >
                            <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-amber-600/20 bg-amber-50 text-sm font-bold text-[#443210] shadow-sm transition-all duration-300 group-hover:border-[#DCA11D] group-hover:bg-[#443210] group-hover:text-white md:h-12 md:w-12">
                                {job.job_id}
                            </div>

                            <div class="flex-1 rounded-xl border border-gray-200/80 bg-white px-5 py-4 text-base font-bold text-[#443210]/90 shadow-sm transition-all duration-300 group-hover:-translate-y-0.5 group-hover:border-[#DCA11D]/40 group-hover:text-[#443210] group-hover:shadow-md md:text-lg flex justify-between items-center">
                                <span>{job.name_job}</span>
                                <span class="text-xs text-[#DCA11D] opacity-0 group-hover:opacity-100 transition-opacity font-medium flex items-center gap-1">
                                    ดูทักษะ <span class="text-[10px]">➔</span>
                                </span>
                            </div>
                        </button>
                    </form>
                {/each}
            </div>

            {#if jobs.length > 0}
                <div class="flex items-center justify-center pt-2">
                    <button
                        type="button"
                        onclick={() => (jobs_more = true)}
                        class="flex items-center gap-2 rounded-xl border border-gray-300/80 bg-white px-6 py-2.5 text-sm font-bold text-[#443210]/80 shadow-sm transition-all hover:bg-[#443210] hover:text-white hover:shadow-md"
                    >
                        ดูเพิ่มเติมทั้งหมด
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
                        </svg>
                    </button>
                </div>
            {/if}
        </section>

        <section class="space-y-6">
            <h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
                <span class="text-2xl">📖</span> รายวิชาในหลักสูตร
            </h2>

            {#if displayCourses.length === 0}
                <div class="rounded-2xl border-2 border-dashed border-gray-200 bg-white p-12 text-center shadow-sm">
                    <p class="font-medium text-gray-400">ไม่พบรายวิชาในหลักสูตรของคุณ</p>
                </div>
            {/if}

            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                {#each displayCourses as course (course.course_id)}
                    {@const currentSkills = courseSkillsList.filter((s) => s.course_id === course.course_id)}
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
                            <span class="text-[10px] font-bold tracking-wider text-gray-400 uppercase">Mapped Skills</span>
                            {#if currentSkills.length > 0}
                                <p class="mt-0.5 line-clamp-1 text-xs font-medium text-gray-500 italic">
                                    {currentSkills.map((s) => s.skill_name).join(', ')}
                                </p>
                            {:else}
                                <p class="mt-0.5 text-xs font-medium text-gray-400 italic">ไม่มีข้อมูลทักษะ</p>
                            {/if}
                        </div>
                    </button>
                {/each}
            </div>

            {#if courses.length !== allcourses.length}
                <div class="flex justify-center pt-6">
                    <button
                        type="button"
                        onclick={() => (allcourses_more = !allcourses_more)}
                        class="flex cursor-pointer items-center gap-2 rounded-xl border border-gray-300/80 bg-white px-6 py-2.5 text-sm font-bold text-[#443210] shadow-sm transition-all hover:bg-[#443210] hover:text-white hover:shadow-md"
                    >
                        {#if allcourses_more}
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5" />
                            </svg>
                            ซ่อนรายวิชาบางส่วน
                        {:else}
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="h-4 w-4 animate-bounce">
                                <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                            </svg>
                            ดูรายวิชาทั้งหมดเพิ่มเติม
                        {/if}
                    </button>
                </div>
            {/if}
        </section>
    </div>
</div>

{#if job_skill_Modal}
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm transition-opacity">
        <div class="w-full max-w-md rounded-2xl border border-gray-100 bg-white p-6 shadow-2xl modal-content mx-4">
            <h2 class="pb-4 text-center text-xl font-bold text-[#443210] border-b border-gray-100">🎯 ทักษะสำคัญที่ต้องมี</h2>
            
            {#if boxinfo}
                <div class="my-3 rounded-xl border border-amber-200 bg-amber-50/70 p-3 text-center text-sm font-semibold text-amber-900">
                    {boxinfo}
                </div>
            {/if}

            <div class="mt-4 max-h-[40vh] overflow-y-auto space-y-2 pr-1 custom-scrollbar">
                {#each selectedJobSkills as item, i (i)}
                    <div class="group rounded-xl border border-gray-100 bg-gray-50/50 p-3.5 transition-all hover:bg-white hover:border-amber-200 hover:shadow-sm">
                        <div class="flex items-center justify-between gap-3">
                            <p class="text-sm font-bold text-[#443210]">
                                {item.skill_name}
                            </p>
                            <span class="shrink-0 rounded-md bg-[#443210] px-2.5 py-1 text-[11px] font-bold text-[#dca11d]">
                                Level: {item.level_skill}
                            </span>
                        </div>
                    </div>
                {/each}
                {#if selectedJobSkills.length === 0 && !boxinfo}
                    <p class="text-center py-6 text-gray-400 text-sm">ไม่พบข้อมูลรายละเอียดทักษะ</p>
                {/if}
            </div>

            <button
                onclick={() => (job_skill_Modal = false)}
                class="mt-5 w-full cursor-pointer rounded-xl bg-gray-100 py-2.5 text-sm font-bold text-gray-600 transition-colors hover:bg-gray-200"
            >
                ปิดหน้าต่าง
            </button>
        </div>
    </div>
{/if}

{#if jobs_more}
    <div class="fixed inset-0 z-40 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
        <div class="relative w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl modal-content max-h-[85vh] flex flex-col">
            
            <button
                type="button"
                onclick={() => (jobs_more = false)}
                class="absolute top-4 right-4 cursor-pointer p-1 rounded-lg text-gray-400 hover:bg-gray-100 hover:text-gray-700 transition-colors"
                aria-label="ปิดหน้าต่าง"
                title="ปิดหน้าต่าง"
            >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="h-5 w-5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                </svg>
            </button>

            <h2 class="pb-4 text-center text-xl font-bold text-[#443210] border-b border-gray-100">
                💼 อาชีพทั้งหมดในสายงาน
            </h2>

            {#if boxinfo}
                <div class="my-2 rounded-xl border border-amber-200 bg-amber-50 p-2.5 text-center text-xs font-bold text-amber-950">
                    {boxinfo}
                </div>
            {/if}

            <div class="mt-4 flex-1 overflow-y-auto space-y-2 pr-1 custom-scrollbar">
                {#each alljobs as item, i (i)}
                    <form
                        class="w-full"
                        method="POST"
                        action="?/call_jobs"
                        use:enhance={() => {
                            job_skill_Modal = true;
                            return async ({ result }) => {
                                if (result.type === 'success') {
                                    //@ts-ignore
                                    selectedJobSkills = result.data?.Skills;
                                } else {
                                    // @ts-ignore
                                    boxinfo = result.data?.boxinfo;
                                }
                            };
                        }}
                    >
                        <input type="hidden" name="id" value={item.job_id} />
                        <button type="submit" class="w-full cursor-pointer text-left focus:outline-none block">
                            <div class="group rounded-xl border border-gray-200/80 bg-white p-4 transition-all hover:border-[#f0ac2c]/60 hover:shadow-sm flex items-center justify-between gap-3">
                                <p class="font-bold text-[#443210] group-hover:text-[#dca11d] transition-colors text-base sm:text-lg">
                                    {item.name_job}
                                </p>
                                <span class="shrink-0 rounded-lg bg-amber-50 px-2.5 py-1 text-[11px] font-bold text-amber-700 border border-amber-200/40 group-hover:bg-[#dca11d] group-hover:text-white transition-colors">
                                    ดูทักษะ
                                </span>
                            </div>
                        </button>
                    </form>
                {/each}
            </div>
        </div>
    </div>
{/if}

<style>
    /* อนิเมชันการโฮเวอร์การ์ดรายวิชา */
    .btn:hover {
        box-shadow: 0 15px 30px -5px rgba(220, 161, 29, 0.15);
        transform: translateY(-4px);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }

    /* ตกแต่งแถบ Scrollbar ภายใน Modal ให้ดูเรียบร้อย */
    .custom-scrollbar::-webkit-scrollbar {
        width: 5px;
    }
    .custom-scrollbar::-webkit-scrollbar-track {
        background: transparent;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb {
        background: #e5e7eb;
        border-radius: 10px;
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover {
        background: #dca11d;
    }

    /* Keyframes สำหรับการเปิดปิด Modal อย่างนุ่มนวล */
    .modal-content {
        animation: modalScaleIn 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
    }

    @keyframes modalScaleIn {
        from {
            opacity: 0;
            transform: scale(0.95) translateY(10px);
        }
        to {
            opacity: 1;
            transform: scale(1) translateY(0);
        }
    }
</style>