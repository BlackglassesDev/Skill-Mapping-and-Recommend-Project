<script>
	//@ts-nocheck
	import { resolve } from '$app/paths';
	import { invalidateAll } from '$app/navigation';
	import { enhance } from '$app/forms';

	// 1. รับข้อมูลจาก data prop
	let { data } = $props();

	// 2. แปลงข้อมูล
	let skillList = $derived(Array.isArray(data?.skills) ? data.skills : []);
	let curriculumList = $derived(Array.isArray(data?.curriculums) ? data.curriculums : []);

	// 3. สถานะการค้นหาและ Pagination
	let searchQuery = $state('');
	let currentPage = $state(1);
	const itemsPerPage = 10;

	// 4. สถานะควบคุม Modal และ Form
	let isAddModalOpen = $state(false);
	let isEditModalOpen = $state(false);
	let isDeleteModalOpen = $state(false);

	let showMessage = $state(false);
	let alertMessage = $state('');

	let skillToEdit = $state({
		skill_id: '',
		skill_name: '',
		curriculum_id: ''
	});

	let skillToDelete = $state({
		skill_id: '',
		skill_name: ''
	});

	// เปิดหน้าต่างแก้ไข
	function openEditModal(skill) {
		skillToEdit = {
			skill_id: skill.skill_id || '',
			skill_name: skill.skill_name || '',
			curriculum_id: skill.curriculum_id !== null ? String(skill.curriculum_id) : ''
		};
		isEditModalOpen = true;
	}

	// เปิดหน้าต่างลบ
	function openDeleteModal(skill) {
		skillToDelete = {
			skill_id: skill.skill_id || '',
			skill_name: skill.skill_name || ''
		};
		isDeleteModalOpen = true;
	}

	// 5. การกรองข้อมูลด้วยคำค้นหา
	let filteredSkills = $derived(
		skillList.filter((skill) => {
			const name = (skill.skill_name || '').toLowerCase();
			const dept = (skill.curriculum_name || '').toLowerCase();
			const query = searchQuery.toLowerCase().trim();
			return name.includes(query) || dept.includes(query);
		})
	);

	// 6. คำนวณหน้าทั้งหมด
	let totalPages = $derived(Math.max(1, Math.ceil(filteredSkills.length / itemsPerPage)));

	// 7. แบ่งข้อมูลแสดงเฉพาะหน้าปัจจุบัน
	let paginatedSkills = $derived(
		filteredSkills.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
	);

	// รีเซ็ตไปหน้าแรกเมื่อเปลี่ยนคำค้นหา
	$effect(() => {
		if (searchQuery) {
			currentPage = 1;
		}
	});

	let adminPage = resolve('/adminPage');
</script>

<svelte:head>
    <title>แผงควบคุมผู้ดูแลระบบ | Skill Mapping</title>
</svelte:head>

<!-- แถบแจ้งเตือน Notification Alert -->
<div
    class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
    class:translate-y-0={showMessage}
    class:-translate-y-20={!showMessage}
    class:opacity-100={showMessage}
    class:opacity-0={!showMessage}
>
    <div
        class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border border-gray-100 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-[0_10px_30px_rgba(68,50,16,0.05)]"
    >
        <span
            class="flex h-6 w-6 items-center justify-center rounded-full bg-amber-50 text-base text-[#dca11d]"
            >🔔</span
        >
        <span class="flex-1 font-medium text-gray-600">{alertMessage}</span>
        <button
            onclick={() => (showMessage = false)}
            class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-[#443210]"
        >
            ✕
        </button>
    </div>
</div>

<div
    class="min-h-screen bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-size-[16px_16px] py-16 selection:bg-amber-100"
>
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        
        <div class="mb-8 rounded-3xl border border-gray-200 bg-white p-6 shadow-sm sm:p-8">
            <div
                class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
            >
                <div
                    class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-gray-100 bg-gray-50 text-2xl shadow-sm"
                >
                    🎯
                </div>

                <div class="flex-1 space-y-1">
                    <h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
                        จัดการ<span class="text-[#dca11d]">คลังทักษะมาตรฐาน</span>
                    </h1>
                    <p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
                        Skill Framework — บริหารจัดการชุดทักษะความเชี่ยวชาญกลาง เพื่อเชื่อมโยงกับรายวิชาและเกณฑ์ประเมินของหลักสูตร
                    </p>

                    <div
                        class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-3 py-0.5 text-[10px] font-bold tracking-wider text-red-600 uppercase"
                    >
                        <span class="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500"></span>
                        Admin Mode Only
                    </div>
                </div>

                <div class="flex w-full shrink-0 flex-col gap-2.5 pt-2 md:w-auto md:items-end">
					<a
						href={adminPage}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-black text-gray-500 shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] md:w-full"
					>
						← กลับหน้าควบคุม
					</a>

					<button
						type="button"
						onclick={() => window.open('/api/export-skill', '_blank')}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
					>
						📤 ส่งออกข้อมูลรายวิชา (CSV)
					</button>
				</div>
            </div>
        </div>

        <div class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <div class="flex flex-col gap-1.5 flex-1 lg:max-w-md">
                <span class="pl-1 text-xs font-medium text-gray-400"> ค้นหาทักษะ </span>
                <div class="relative">
                    <input
                        type="text"
                        bind:value={searchQuery}
                        placeholder="พิมพ์ชื่อทักษะ หรือชื่อหลักสูตรที่ต้องการ..."
                        class="w-full rounded-xl border border-gray-200 bg-white py-2.5 pr-4 pl-10 text-sm font-medium text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d] focus:ring-1 focus:ring-[#dca11d]"
                    />
                    <div
                        class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-sm text-gray-400"
                    >
                        🔍
                    </div>
                    {#if searchQuery}
                        <button
                            type="button"
                            onclick={() => (searchQuery = '')}
                            class="absolute inset-y-0 right-0 flex items-center pr-3 text-xs font-bold text-gray-400 hover:text-gray-600"
                        >
                            ✕ ล้าง
                        </button>
                    {/if}
                </div>
            </div>

            <div class="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-end">
                <button
                    type="button"
                    onclick={() => (isAddModalOpen = true)}
                    class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] sm:w-auto"
                >
                    ➕ เพิ่มทักษะใหม่
                </button>
            </div>
        </div>

        <div class="overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-sm text-gray-500">
                    <thead
                        class="border-b border-gray-200 bg-gray-50/70 text-xs font-bold tracking-wider text-gray-400 uppercase"
                    >
                        <tr>
                            <th class="w-24 px-6 py-4 font-bold text-center">รหัสอ้างอิง</th>
                            <th class="w-1/2 px-6 py-4 font-bold">ชื่อทักษะความชำนาญ (Skill)</th>
                            <th class="w-1/4 px-6 py-4 font-bold">หลักสูตร / สาขาวิชาที่เกี่ยวข้อง</th>
                            <th class="px-6 py-4 text-center font-bold">การจัดการ</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 font-medium text-gray-700">
                        {#each paginatedSkills as skill (skill.skill_id)}
                            <tr
                                class="transition-colors duration-150 odd:bg-white even:bg-gray-50/30 hover:bg-gray-50"
                            >
                                <td class="px-6 py-4 text-center font-mono font-bold tracking-wide text-gray-500">
                                    {skill.skill_id}
                                </td>
                                <td class="px-6 py-4">
                                    <span class="block text-sm font-black text-[#443210]">
                                        {skill.skill_name}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    {#if skill.curriculum_name}
                                        <span
                                            class="inline-flex items-center rounded-lg border border-gray-200 bg-gray-50 px-2.5 py-1 text-xs font-bold text-gray-600"
                                        >
                                            {skill.curriculum_name}
                                        </span>
                                    {:else}
                                        <span
                                            class="inline-flex items-center rounded-lg border border-transparent bg-gray-100 px-2.5 py-1 text-xs font-bold text-gray-400"
                                        >
                                            🌍 ทักษะสากล (ส่วนกลาง)
                                        </span>
                                    {/if}
                                </td>
                                <td class="px-6 py-4 text-center whitespace-nowrap">
                                    <div class="flex items-center justify-center gap-2">
                                        <button
                                            onclick={() => openEditModal(skill)}
                                            class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-gray-600 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d]"
                                        >
                                            ✏️ แก้ไข
                                        </button>
                                        <button
                                            onclick={() => openDeleteModal(skill)}
                                            class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-rose-500 shadow-sm transition-all hover:border-rose-400 hover:bg-rose-50/50"
                                        >
                                            🗑️ ลบทักษะ
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        {:else}
                            <tr>
                                <td colspan="4" class="px-6 py-20">
                                    <div class="mx-auto flex max-w-sm flex-col items-center text-center">
                                        <div
                                            class="flex h-12 w-12 items-center justify-center rounded-xl bg-gray-50 text-xl border border-gray-100 text-gray-400 mb-3"
                                        >
                                            💨
                                        </div>
                                        <h3 class="text-sm font-bold text-[#443210]">ไม่พบข้อมูลทักษะ</h3>
                                        <p class="mt-1 text-xs leading-relaxed text-gray-400">
                                            ไม่พบข้อมูลทักษะที่เกี่ยวข้องกับแผนกหลักสูตรหรือคำค้นหาดังกล่าว <br />
                                            กรุณาลองระบุคำค้นหาใหม่อีกครั้ง หรือเพิ่มทักษะใหม่เข้าสู่ระบบ
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>

            {#if filteredSkills.length > 0}
                <div
                    class="flex flex-col items-center justify-between gap-4 border-t border-gray-200 bg-gray-50/50 px-6 py-4 sm:flex-row"
                >
                    <span class="text-xs font-medium text-gray-400">
                        แสดงข้อมูลหน้า <span class="font-semibold text-gray-700">{currentPage}</span> จากทั้งหมด
                        <span class="font-semibold text-gray-700">{totalPages}</span> หน้า (รวมทั้งสิ้น {filteredSkills.length} ทักษะ)
                    </span>

                    <div class="inline-flex items-center gap-1.5">
                        <button
                            type="button"
                            onclick={() => (currentPage = 1)}
                            disabled={currentPage === 1}
                            class="cursor-pointer rounded-lg border border-gray-200 bg-white p-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                            title="หน้าแรกสุด"
                        >
                            «
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = Math.max(1, currentPage - 1))}
                            disabled={currentPage === 1}
                            class="inline-flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ◀ ก่อนหน้า
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = Math.min(totalPages, currentPage + 1))}
                            disabled={currentPage === totalPages}
                            class="inline-flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
                        >
                            ถัดไป ▶
                        </button>

                        <button
                            type="button"
                            onclick={() => (currentPage = totalPages)}
                            disabled={currentPage === totalPages}
                            class="cursor-pointer rounded-lg border border-gray-200 bg-white p-2 text-xs font-bold text-gray-700 shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
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

<!-- Modal เพิ่มทักษะใหม่ -->
{#if isAddModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed cursor-pointer inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isAddModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">🎯 เพิ่มทักษะมาตรฐานใหม่</h3>
            </div>

            <form
                method="POST"
                action="?/createSkill"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isAddModalOpen = false;
                                await invalidateAll();
                            }
                        }
                    };
                }}
                class="space-y-4 p-6 text-xs font-bold text-[#443210]"
            >
                <div class="space-y-1.5">
                    <label for="skillName" class="text-gray-400">
                        ชื่อทักษะความสามารถ <span class="text-rose-500">*</span>
                    </label>
                    <input
                        type="text"
                        id="skillName"
                        name="skill_name"
                        placeholder="เช่น Web Development หรือ Data Analytics"
                        required
                        class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                    />
                </div>

                <div class="space-y-1.5">
                    <label for="curriculumId" class="text-gray-400">
                        หลักสูตร / ภาควิชาที่เกี่ยวข้อง
                    </label>
                    <div class="relative">
                        <select
                            id="curriculumId"
                            name="curriculum_id"
                            class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none focus:border-[#dca11d] focus:bg-white"
                        >
                            <option value="">--เลือกหลักสูตรของทักษะ--</option>
                            {#each curriculumList as item (item.curriculum_id)}
                                <option value={item.curriculum_id}>{item.curriculum_name}</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                            ▼
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                    <button
                        type="button"
                        onclick={() => (isAddModalOpen = false)}
                        class="cursor-pointer rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-xs font-black text-gray-500 shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        ยกเลิกข้อมูล
                    </button>
                    <button
                        type="submit"
                        class="cursor-pointer rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        💾 บันทึกข้อมูล
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<!-- Modal แก้ไขทักษะ -->
{#if isEditModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isEditModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">✏️ แก้ไขข้อมูลทักษะ</h3>
            </div>

            <form
                method="POST"
                action="?/updateSkill"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isEditModalOpen = false;
                                await invalidateAll();
                            }
                        }
                    };
                }}
                class="space-y-4 p-6 text-xs font-bold text-[#443210]"
            >
                <input type="hidden" name="skill_id" value={skillToEdit.skill_id} />

                <div class="space-y-1.5">
                    <label for="editSkillName" class="text-gray-400">
                        ชื่อทักษะความสามารถ <span class="text-rose-500">*</span>
                    </label>
                    <input
                        type="text"
                        id="editSkillName"
                        name="skill_name"
                        bind:value={skillToEdit.skill_name}
                        placeholder="เช่น Web Development หรือ Data Analytics"
                        required
                        class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                    />
                </div>

                <div class="space-y-1.5">
                    <label for="editCurriculumId" class="text-gray-400">
                        หลักสูตร / ภาควิชาที่เกี่ยวข้อง
                    </label>
                    <div class="relative">
                        <select
                            id="editCurriculumId"
                            name="curriculum_id"
                            bind:value={skillToEdit.curriculum_id}
                            class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none focus:border-[#dca11d] focus:bg-white"
                        >
                            <option value="">--เลือกหลักสูตรของทักษะ--</option>
                            {#each curriculumList as item (item.curriculum_id)}
                                <option value={String(item.curriculum_id)}>{item.curriculum_name}</option>
                            {/each}
                        </select>
                        <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                            ▼
                        </div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                    <button
                        type="button"
                        onclick={() => (isEditModalOpen = false)}
                        class="cursor-pointer rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-xs font-black text-gray-500 shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        ยกเลิกข้อมูล
                    </button>
                    <button
                        type="submit"
                        class="cursor-pointer rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                    >
                        💾 บันทึกการแก้ไข
                    </button>
                </div>
            </form>
        </div>
    </div>
{/if}

<!-- Modal ยืนยันการลบ -->
{#if isDeleteModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isDeleteModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">🚫 ยืนยันการลบทักษะมาตรฐาน</h3>
            </div>

            <div class="p-6">
                <div class="flex items-center gap-4 rounded-2xl border border-amber-100 bg-amber-50/60 p-4">
                    <span class="text-3xl">⚠️</span>
                    <p class="text-xs leading-relaxed font-bold text-[#443210]">
                        คุณกำลังทำรายการลบทักษะออกจากระบบสารสนเทศ 
                        โปรดตรวจสอบข้อมูลความถูกต้องก่อนทำการยืนยัน
                    </p>
                </div>

                <div class="mt-5 space-y-1.5 rounded-2xl border-2 border-gray-100 bg-gray-50/50 p-4">
                    <p class="text-[10px] font-bold text-gray-400 uppercase">
                        ทักษะที่เลือกทำรายการ:
                    </p>
                    <p class="text-xs font-black text-[#443210]">
                        รหัสทักษะ: <span class="font-mono text-gray-600">{skillToDelete.skill_id}</span>
                    </p>
                    <p class="text-xs font-black text-[#443210]">
                        ชื่อทักษะ: <span class="text-gray-600">{skillToDelete.skill_name}</span>
                    </p>
                </div>

                <p class="mt-4 rounded-xl border border-rose-100 bg-rose-50 p-3 text-[11px] leading-relaxed font-black text-rose-500">
                    คำเตือน: การลบข้อมูลนี้จะเป็นการลบถาวรออกจากระบบฐานข้อมูล โดยระบบจะตัดการเชื่อมโยงกับรายวิชา (Course Skills) รวมถึงความต้องการในอาชีพ (Job Skills) ทั้งหมดโดยอัตโนมัติและไม่สามารถกู้คืนได้ในภายหลัง
                </p>
            </div>

            <form
                method="POST"
                action="?/deleteSkill"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isDeleteModalOpen = false;
                                await invalidateAll();
                            }
                        }
                    };
                }}
                class="flex justify-end gap-3 px-6 pb-6"
            >
                <input type="hidden" name="skill_id" value={skillToDelete.skill_id} />

                <button
                    type="button"
                    onclick={() => (isDeleteModalOpen = false)}
                    class="cursor-pointer rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-xs font-black text-gray-500 shadow-sm hover:border-[#dca11d] hover:text-[#dca11d]"
                >
                    ยกเลิก
                </button>
                
                <button
                    type="submit"
                    class="cursor-pointer rounded-xl border border-rose-200 bg-rose-500 px-5 py-2.5 text-xs font-black text-white shadow-sm transition-colors hover:bg-rose-600"
                >
                    💥 ยืนยันการลบถาวร
                </button>
            </form>
        </div>
    </div>
{/if}