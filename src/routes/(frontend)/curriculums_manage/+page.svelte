<script>
    //@ts-nocheck
    import { resolve } from '$app/paths';

    // 1. รับข้อมูลจาก data prop ที่ส่งมาจาก page.server.js
    let { data } = $props();
    
    // 2. แปลงและจัดการข้อมูล Array
    let curriculumList = $derived(Array.isArray(data?.curriculumRows) ? data.curriculumRows : []);
    let allCourses = $derived(Array.isArray(data?.courseRows) ? data.courseRows : []);

    // 3. สเตตและตัวแปรควบคุม (ค้นหา, เลือกหลักสูตร, หน้าปัจจุบัน)
    let selectedCurriculum = $state(curriculumList[0]?.curriculum_id ?? '');
    let searchQuery = $state(''); // สำหรับเก็บค่าคำค้นหา
    let currentPage = $state(1); // หน้าปัจจุบันเริ่มต้นที่หน้า 1
    const itemsPerPage = 10; // จำนวนรายการที่แสดงต่อ 1 หน้า (ปรับเปลี่ยนได้ตามใจชอบ)
    
    // 4. 🔥 กรองขั้นที่ 1: กรองรายวิชาตามหลักสูตรที่เลือกก่อน
    let coursesInCurriculum = $derived(
        allCourses.filter(course => course.curriculum_id === selectedCurriculum)
    );

    // 5. 🔥 กรองขั้นที่ 2: กรองตามช่องค้นหา (ค้นหาได้ทั้ง รหัสวิชา และ ชื่อวิชา)
    let filteredCourses = $derived(
        coursesInCurriculum.filter(course => {
            const code = (course.course_code || '').toLowerCase();
            const name = (course.course_name || '').toLowerCase();
            const query = searchQuery.toLowerCase().trim();
            return code.includes(query) || name.includes(query);
        })
    );

    // 6. คำนวณหน้าทั้งหมด (Total Pages) บนฐานข้อมูลที่ถูกกรองแล้ว
    let totalPages = $derived(Math.max(1, Math.ceil(filteredCourses.length / itemsPerPage)));

    // 7. 🔥 ตัดสไลด์ข้อมูลเอาเฉพาะรายการที่จะแสดงในหน้านั้นๆ (Paginated Data)
    let paginatedCourses = $derived(
        filteredCourses.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
    );

    // รีเซ็ตหน้ากลับไปหน้า 1 เสมอเมื่อมีการเปลี่ยนแผนกหลักสูตร หรือเริ่มค้นหาใหม่
    $effect(() => {
        if (selectedCurriculum || searchQuery) {
            currentPage = 1;
        }
    });

    let adminPage = resolve('/adminPage');
</script>

<svelte:head>
    <title>Skill Mapping | Manage Curriculums |</title>
</svelte:head>

<div class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-16">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
            <div class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left">
                <div class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-2xl text-[#dca11d] shadow-sm">
                    📚
                </div>
                
                <div class="flex-1 space-y-1.5">
                    <h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
                        จัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
                    </h1>
                    <p class="max-w-2xl text-sm font-medium leading-relaxed text-gray-500">
                        Curriculum Management — บริหารจัดการโครงสร้างรายวิชาของแผนก เพื่อนำข้อมูลไปเชื่อมโยงและประเมินผลระดับทักษะ (Skill Mapping)
                    </p>
                    <div class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-2.5 py-0.5 text-xs font-semibold text-red-600">
                        <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
                        Admin Mode Only
                    </div>
                </div>
                
                <div class="flex w-full shrink-0 flex-col gap-3 pt-2 md:w-auto md:items-end">
                    <a
                        href={adminPage}
                        class="inline-flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-xs font-bold text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50 md:w-full"
                    >
                        ← กลับหน้าควบคุม
                    </a>
                    <button
                        type="button"
                        onclick={() => window.open('/api/export-curriculums', '_blank')}
                        class="inline-flex items-center justify-center gap-2 rounded-2xl border-2 border-gray-200 bg-white px-5 py-2.5 text-sm font-bold text-[#443210] shadow-sm transition-all hover:-translate-y-0.5 hover:bg-gray-50 md:w-full"
                    >
                        📤 ส่งออกหลักสูตร (Export CSV)
                    </button>
                </div>
            </div>
        </div>

        <div class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <div class="grid flex-1 grid-cols-1 gap-4 sm:grid-cols-2 lg:max-w-3xl">
                <div class="flex flex-col gap-1.5">
                    <label class="text-xs font-bold tracking-wider text-gray-400 uppercase pl-1">หลักสูตร / ภาควิชาที่เลือก</label>
                    <div class="relative">
                        <select
                            bind:value={selectedCurriculum}
                            class="w-full appearance-none rounded-2xl border-2 border-gray-200 bg-white pl-4 pr-10 py-2.5 text-sm font-bold text-[#443210] outline-none transition-all focus:border-[#dca11d] cursor-pointer shadow-sm"
                        >
                            {#each curriculumList as item (item.curriculum_id)}
                                <option value={item.curriculum_id}>{item.curriculum_name}</option>
                            {:else}
                                <option value="">❌ ไม่มีข้อมูลหลักสูตรในระบบ</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-xs text-gray-400">
                            ▼
                        </div>
                    </div>
                </div>

                <div class="flex flex-col gap-1.5">
                    <label class="text-xs font-bold tracking-wider text-gray-400 uppercase pl-1">ค้นหารายวิชา</label>
                    <div class="relative">
                        <input
                            type="text"
                            bind:value={searchQuery}
                            placeholder="พิมพ์รหัสวิชา หรือ ชื่อวิชาที่ต้องการ..."
                            class="w-full rounded-2xl border-2 border-gray-200 bg-white pl-10 pr-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 outline-none transition-all focus:border-[#dca11d] shadow-sm"
                        />
                        <div class="pointer-events-none absolute inset-y-0透 inset-y-0 left-0 flex items-center pl-3.5 text-base text-gray-400">
                            🔍
                        </div>
                        {#if searchQuery}
                            <button 
                                type="button" 
                                onclick={() => searchQuery = ''} 
                                class="absolute inset-y-0 right-0 flex items-center pr-3 text-xs text-gray-400 hover:text-gray-600 font-bold"
                            >
                                ✕ ล้าง
                            </button>
                        {/if}
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
                <button
                    type="button"
                    class="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-[#443210] px-6 py-3 text-sm font-black text-white shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-300 hover:-translate-y-1 hover:bg-[#2d210a] hover:shadow-[0_8px_20px_rgba(68,50,16,0.25)] sm:w-auto"
                >
                    ➕ เพิ่มรายวิชาใหม่
                </button>
            </div>
        </div>

        <div class="overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.04)]">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-sm text-gray-500">
                    <thead class="bg-gray-50/70 text-xs font-black uppercase tracking-wider text-gray-400 border-b-2 border-gray-100">
                        <tr>
                            <th class="px-8 py-5 w-1/4">รหัสวิชา</th>
                            <th class="px-8 py-5 w-1/2">ชื่อรายวิชา (TH / EN)</th>
                            <th class="px-8 py-5 w-1/4">โครงสร้างหลักสูตร</th>
                            <th class="px-8 py-5 text-right">การจัดการ</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 font-medium text-[#443210]">
                        
                        {#each paginatedCourses as course (course.course_id)}
                            <tr class="odd:bg-white even:bg-gray-50/40 hover:bg-amber-50/30 transition-colors duration-200">
                                <td class="px-8 py-5 font-mono font-black text-gray-500 tracking-wide">
                                    {course.course_code}
                                </td>
                                <td class="px-8 py-5">
                                    <div class="space-y-0.5">
                                        <span class="block text-sm font-extrabold text-[#443210]">{course.course_name}</span>
                                    </div>
                                </td>
                                <td class="px-8 py-5">
                                    <span class="inline-flex items-center rounded-xl bg-amber-50 px-3 py-1 text-xs font-black text-[#dca11d] border border-amber-100/70">
                                        {curriculumList.find(c => c.curriculum_id === course.curriculum_id)?.curriculum_name || 'วิศวกรรมคอมพิวเตอร์'}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center whitespace-nowrap">
									<div class="flex items-center justify-center gap-2">
										<button
											onclick={() => openEditModal(user)}
											class="rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-gray-600 shadow-sm transition-colors hover:border-[#dca11d] hover:text-[#dca11d]"
										>
											✏️ แก้ไข
										</button>
										<button
											class="rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-rose-500 shadow-sm transition-colors hover:border-rose-400 hover:bg-rose-50/50"
											onclick={() => openDeleteModal(user)}
										>
											🗑️ ลบวิชาเรียน
										</button>
									</div>
								</td>
                            </tr>
                        {:else}
                            <tr>
                                <td colspan="4" class="px-8 py-20">
                                    <div class="mx-auto flex max-w-sm flex-col items-center text-center">
                                        <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-50 text-3xl text-gray-400 border border-gray-100 shadow-inner mb-4 animate-pulse">
                                            💨
                                        </div>
                                        <h3 class="text-base font-black text-[#443210]">ไม่พบข้อมูลรายวิชา</h3>
                                        <p class="mt-2 text-xs leading-relaxed font-medium text-gray-400">
                                            ไม่พบข้อมูลวิชาตามเงื่อนไขหลักสูตรหรือคำค้นหาดังกล่าว พี่สามารถลองพิมพ์คำอื่นหรือกดปุ่มเพิ่มรายวิชาได้เลยครับ
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        {/each}

                    </tbody>
                </table>
            </div>

            {#if filteredCourses.length > 0}
                <div class="flex flex-col items-center justify-between gap-4 border-t border-gray-100 bg-gray-50/50 px-8 py-4 sm:flex-row">
                    <span class="text-xs font-bold text-gray-400">
                        แสดงข้อมูลหน้า <span class="text-[#443210]">{currentPage}</span> จากทั้งหมด <span class="text-[#443210]">{totalPages}</span> หน้า (รวม {filteredCourses.length} วิชา)
                    </span>

                    <div class="inline-flex items-center gap-1.5">
                        <button
                            type="button"
                            onclick={() => currentPage = 1}
                            disabled={currentPage === 1}
                            class="rounded-xl border border-gray-200 bg-white p-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                            title="หน้าแรกสุด"
                        >
                            «
                        </button>

                        <button
                            type="button"
                            onclick={() => currentPage = Math.max(1, currentPage - 1)}
                            disabled={currentPage === 1}
                            class="inline-flex items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ◀ ก่อนหน้า
                        </button>

                        <button
                            type="button"
                            onclick={() => currentPage = Math.min(totalPages, currentPage + 1)}
                            disabled={currentPage === totalPages}
                            class="inline-flex items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ถัดไป ▶
                        </button>

                        <button
                            type="button"
                            onclick={() => currentPage = totalPages}
                            disabled={currentPage === totalPages}
                            class="rounded-xl border border-gray-200 bg-white p-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                            title="หน้าสุดท้าย"
                        >
                            »
                        </button>
                    </div>
                </div>
            {/if}
        </div>

    </div>
</div>