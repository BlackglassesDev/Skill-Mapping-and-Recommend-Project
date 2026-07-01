<script>
    // --- 1. สเตตัสและตัวแปรหลัก (Svelte 5 State Runes) ---
    let { data } = $props();

    let showMessage = $state(false);
    let alertMessage = $state("");
    let adminPage = "/adminPage";

    /** @param {string} msg */
    function triggerAlert(msg) {
        alertMessage = msg;
        showMessage = true;
        setTimeout(() => { showMessage = false; }, 3000);
    }

	function exportCSV() {
		const selectedName = skillStatistics[0]?.category || 'หลักสูตร';
		triggerAlert(`📤 ส่งออกข้อมูลไฟล์ CSV ของ: ${selectedName}`);
		window.open('/api/export-course-dashboard-csv', '_blank');
	}

    // --- 2. คลังข้อมูลผลการ Mapping จาก Database ---
    /** @type {any[]} */
    let skillStatistics = $state(data.skillStatistics || []);
    let totalCourses = $derived(data.totalCourses || 0);

    /** @type {any[]} */
    let unmappedCoursesList = $state(data.unmappedCourses || []);
    let totalMappedCount = $derived(data.mappedCourses?.length || 0);
    let totalUnmappedCount = $derived(unmappedCoursesList.length);

    let showAllUnmapped = $state(false);
    let initialUnmappedLimit = 5;

    let visibleUnmappedCourses = $derived(
        showAllUnmapped ? unmappedCoursesList : unmappedCoursesList.slice(0, initialUnmappedLimit)
    );

    $effect(() => {
        skillStatistics = data.skillStatistics || [];
        unmappedCoursesList = data.unmappedCourses || [];
    });

    const totalSkillsInSystem = $derived(skillStatistics.length); // จำนวนทักษะทั้งหมดที่มี

    // --- 3. ⚡️ คำนวณวิเคราะห์หาจุดบกพร่องและจุดเด่น (Svelte 5 Derived Runes) ---
    
    // กรองหาทักษะที่ยังไม่เคยถูกเลือกใช้เลย (Count = 0)
    let unmappedSkills = $derived(
        skillStatistics.filter((/** @type {any} */ s) => s.count === 0)
    );

    // หาชุดทักษะที่มีการ Mapping มากที่สุดและน้อยที่สุด (ไม่นับอันที่เป็น 0)
    let mappedOnlySkills = $derived(
        skillStatistics.filter((/** @type {any} */ s) => s.count > 0)
    );

    let maxCount = $derived(
        mappedOnlySkills.length > 0 ? Math.max(...mappedOnlySkills.map((/** @type {any} */ s) => s.count)) : 0
    );
    
    let minCount = $derived(
        mappedOnlySkills.length > 0 ? Math.min(...mappedOnlySkills.map((/** @type {any} */ s) => s.count)) : 0
    );

    let mostMappedSkills = $derived(
        skillStatistics.filter((/** @type {any} */ s) => s.count === maxCount && maxCount > 0)
    );

    let leastMappedSkills = $derived(
        skillStatistics.filter((/** @type {any} */ s) => s.count === minCount && minCount > 0)
    );

    // คำนวณความสูงของแท่งกราฟแบบไดนามิก (ค่าสูงสุดอิงจาก Max Count)
    let chartMaxHeight = $derived(maxCount > 0 ? maxCount + 2 : 20);
</script>

<div
    class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
    class:translate-y-0={showMessage}
    class:-translate-y-20={!showMessage}
    class:opacity-100={showMessage}
    class:opacity-0={!showMessage}
>
    <div class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border border-gray-100 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-[0_10px_30px_rgba(68,50,16,0.05)]">
        <span class="flex h-6 w-6 items-center justify-center rounded-full bg-amber-50 text-base text-[#dca11d]">🔔</span>
        <span class="flex-1 font-medium text-gray-600">{alertMessage}</span>
        <button onclick={() => (showMessage = false)} class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-[#443210]">✕</button>
    </div>
</div>

<div class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-16 selection:bg-amber-100">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm">📊</div>
                <div class="flex-1 space-y-1">
                    <h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
                        แดชบอร์ด<span class="text-[#dca11d]">วิเคราะห์ผลผังทักษะ</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        Course & Skill Dashboard — สรุปสถิติภาพรวมข้อมูลการจัดการหลักสูตร ตรวจสอบความสอดคล้อง ค้นหาจุดเด่นและจุดวิกฤตที่ทักษะขาดหายไป (Gap Analysis)
                    </p>
                </div>
                <div class="flex w-full shrink-0 flex-col gap-2.5 pt-2 md:w-auto md:items-end">
                    <a href={adminPage}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-black text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] md:w-full">
                        ← กลับหน้าควบคุม
                    </a>
					<button
                        type="button"
                        onclick={exportCSV}
                        class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        📤 ส่งออกข้อมูล(CSV)
                    </button>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 mb-8">
            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-gray-50 flex items-center justify-center border border-gray-100 text-xl">📚</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">รายวิชาในหลักสูตรรวม</span>
                    <span class="text-2xl font-black text-[#443210]">{totalCourses} <span class="text-xs font-medium text-gray-400">วิชา</span></span>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-amber-50 flex items-center justify-center border border-amber-100 text-xl text-[#dca11d]">📝</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">รายวิชาที่แมปแล้ว</span>
                    <span class="text-2xl font-black text-[#443210]">{totalMappedCount} <span class="text-xs font-medium text-gray-400">วิชา</span></span>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-[#443210]/5 flex items-center justify-center border border-[#443210]/10 text-xl text-[#443210]">⚠️</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">รายวิชาที่ยังไม่แมพ</span>
                    <span class="text-2xl font-black text-rose-500">{totalUnmappedCount} <span class="text-xs font-medium text-gray-400">วิชา</span></span>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-amber-50 flex items-center justify-center border border-amber-100 text-xl text-[#dca11d]">🎯</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">ทักษะเป้าหมายทั้งหมด</span>
                    <span class="text-2xl font-black text-[#443210]">{totalSkillsInSystem} <span class="text-xs font-medium text-gray-400">ทักษะ</span></span>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-rose-50 flex items-center justify-center border border-rose-100 text-xl text-rose-500">⚠️</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">ทักษะที่ยังไม่ได้แมพ</span>
                    <span class="text-2xl font-black text-rose-500">{unmappedSkills.length} <span class="text-xs font-medium text-gray-400">ทักษะ</span></span>
                </div>
            </div>

            <div class="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm flex items-center gap-4">
                <div class="h-11 w-11 rounded-xl bg-emerald-50 flex items-center justify-center border border-emerald-100 text-xl text-emerald-500">✅</div>
                <div>
                    <span class="block text-xs font-bold text-gray-400 uppercase">อัตราการกระจายทักษะ</span>
                    <span class="text-2xl font-black text-emerald-600">
                        {totalSkillsInSystem > 0 ? Math.round(((totalSkillsInSystem - unmappedSkills.length) / totalSkillsInSystem) * 100) : 0}%
                    </span>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 gap-6 lg:grid-cols-3 mb-8">
            
            <div class="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm flex flex-col">
                <div class="flex items-center gap-2 border-b border-gray-100 pb-3 mb-4">
                    <span class="text-base">🚨</span>
                    <h3 class="text-sm font-black text-[#443210]">ทักษะที่ตกหล่น (ยังไม่ถูกแมพ)</h3>
                </div>
                <div class="flex flex-wrap gap-2 flex-1 items-start content-start">
                    {#each unmappedSkills as skill}
                        <span class="inline-flex items-center gap-1.5 rounded-xl border border-rose-100 bg-rose-50/50 px-3 py-1.5 text-xs font-bold text-rose-600">
                            <span class="h-1.5 w-1.5 rounded-full bg-rose-500"></span>
                            {skill.skill_name}
                        </span>
                    {:else}
                        <p class="text-xs text-gray-400 italic py-4">ยอดเยี่ยม! ทุกทักษะในหลักสูตรถูกนำไปกระจายใช้งานหมดแล้ว</p>
                    {/each}
                </div>
            </div>

            <div class="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm flex flex-col">
                <div class="flex items-center gap-2 border-b border-gray-100 pb-3 mb-4">
                    <span class="text-base">📉</span>
                    <h3 class="text-sm font-black text-[#443210]">ทักษะที่มีการนำไปใช้น้อยที่สุด</h3>
                </div>
                <div class="flex flex-col gap-2.5 flex-1 justify-start">
                    {#each leastMappedSkills as skill}
                        <div class="flex items-center justify-between p-2.5 rounded-xl border border-gray-100 bg-gray-50/70 text-xs">
                            <span class="font-black text-[#443210]">{skill.skill_name}</span>
                            <span class="bg-white border border-gray-200 px-2.5 py-1 rounded-lg font-mono font-bold text-gray-500">ผูกกับ {skill.count} วิชา</span>
                        </div>
                    {:else}
                        <p class="text-xs text-gray-400 italic py-4">ไม่มีข้อมูลสถิติ</p>
                    {/each}
                </div>
            </div>

            <div class="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm flex flex-col">
                <div class="flex items-center gap-2 border-b border-gray-100 pb-3 mb-4">
                    <span class="text-base">📈</span>
                    <h3 class="text-sm font-black text-[#443210]">ทักษะหลักโดดเด่น (ใช้แมพมากที่สุด)</h3>
                </div>
                <div class="flex flex-col gap-2.5 flex-1 justify-start">
                    {#each mostMappedSkills as skill}
                        <div class="flex items-center justify-between p-2.5 rounded-xl border border-amber-100 bg-amber-50/30 text-xs">
                            <span class="font-black text-[#443210]">{skill.skill_name}</span>
                            <span class="bg-[#443210] px-2.5 py-1 rounded-lg font-mono font-bold text-white">ผูกกับ {skill.count} วิชา</span>
                        </div>
                    {:else}
                        <p class="text-xs text-gray-400 italic py-4">ไม่มีข้อมูลสถิติ</p>
                    {/each}
                </div>
            </div>

        </div>

        {#if totalUnmappedCount > 0}
            <div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm">
                <div class="flex items-center gap-2 border-b border-gray-100 pb-3 mb-4">
                    <span class="text-base">⚠️</span>
                    <h3 class="text-base font-black text-[#443210]">รายวิชาที่ยังไม่ได้ระบุทักษะการเรียนรู้ (Unmapped Courses)</h3>
                </div>
                <div class="overflow-x-auto transition-all duration-500 ease-in-out">
                    <table class="min-w-full divide-y divide-gray-100 text-left text-xs">
                        <thead>
                            <tr class="text-gray-400 uppercase font-bold">
                                <th class="py-3 px-4">รหัสวิชา (Course Code)</th>
                                <th class="py-3 px-4">ชื่อรายวิชา (Course Name)</th>
                                <th class="py-3 px-4">สถานะ (Status)</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 font-medium text-gray-600 transition-all duration-500 ease-in-out">
                            {#each visibleUnmappedCourses as course}
                                <tr class="hover:bg-gray-50/50 transition-colors">
                                    <td class="py-3 px-4 font-mono font-bold text-[#dca11d]">{course.course_code}</td>
                                    <td class="py-3 px-4 font-black text-[#443210]">{course.course_name}</td>
                                    <td class="py-3 px-4">
                                        <span class="inline-flex items-center gap-1 rounded-full bg-rose-50 px-2 py-0.5 font-bold text-rose-600 border border-rose-100">
                                            ❌ ยังไม่ได้แมปทักษะ
                                        </span>
                                    </td>
                                </tr>
                            {/each}
                        </tbody>
                    </table>
                </div>

                {#if unmappedCoursesList.length > initialUnmappedLimit}
                    <div class="mt-4 flex justify-center border-t border-gray-100 pt-4">
                        <button
                            type="button"
                            onclick={() => {
                                showAllUnmapped = !showAllUnmapped;
                                if (showAllUnmapped) {
                                    setTimeout(() => {
                                        window.scrollBy({ top: 150, behavior: 'smooth' });
                                    }, 100);
                                }
                            }}
                            class="inline-flex cursor-pointer items-center gap-2 rounded-xl border border-gray-200 bg-white px-4.5 py-2 text-xs font-black text-gray-500 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d]"
                        >
                            {#if !showAllUnmapped}
                                <span class="inline-block animate-bounce">↓</span>
                                <span>ดูวิชาที่เหลือทั้งหมด (Show More)</span>
                            {:else}
                                <span class="inline-block">↑</span>
                                <span>ซ่อนวิชา (Show Less)</span>
                            {/if}
                        </button>
                    </div>
                {/if}
            </div>
        {/if}

        <div class="rounded-3xl border border-gray-200 bg-white p-6 shadow-sm">
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between border-b border-gray-100 pb-4 mb-6 gap-2">
                <div>
                    <h3 class="text-base font-black text-[#443210]">กราฟแสดงความถี่การนำทักษะไปประยุกต์ใช้ในรายวิชา</h3>
                    <p class="text-xs text-gray-400 mt-0.5">แท่งกราฟสะท้อนปริมาณสัดส่วนว่าแต่ละทักษะถูกบรรจุลงไปในแผนการสอนมากน้อยเพียงใด</p>
                </div>
            </div>

            <div class="flex flex-col gap-4">
                {#each skillStatistics as skill}
                    <div class="grid grid-cols-1 md:grid-cols-4 items-center gap-2 text-xs font-medium">
                        <div class="md:col-span-1 flex flex-col">
                            <span class="font-black text-[#443210] tracking-tight">{skill.skill_name}</span>
                            <span class="text-[10px] text-gray-400">{skill.category}</span>
                        </div>
                        
                        <div class="md:col-span-2 w-full bg-gray-100 rounded-lg h-7 overflow-hidden relative border border-gray-200/40">
                            <div 
                                class="h-full transition-all duration-1000 ease-out flex items-center justify-end pr-3
                                {skill.count === 0 ? 'w-0 bg-transparent' : 'bg-[linear-gradient(90deg,#443210,#dca11d)]'}"
                                style="width: {(skill.count / chartMaxHeight) * 100}%"
                            >
                                {#if skill.count > 2}
                                    <span class="text-[10px] font-mono font-bold text-white bg-[#443210]/40 px-1 rounded">
                                        {skill.count}
                                    </span>
                                {/if}
                            </div>
                        </div>

                        <div class="md:col-span-1 pl-1 flex items-center gap-2">
                            {#if skill.count === 0}
                                <span class="text-[10px] font-bold text-rose-500 bg-rose-50 border border-rose-100 px-2 py-0.5 rounded-md">⚠️ ยังขาดหายไป</span>
                            {:else}
                                <span class="font-mono font-bold text-gray-500">พบใน {skill.count} รายวิชา</span>
                            {/if}
                        </div>
                    </div>
                {:else}
                    <p class="text-center text-xs text-gray-400 py-10">ไม่พบทักษะในระบบหลักสูตรนี้</p>
                {/each}
            </div>

        </div>

    </div>
</div>