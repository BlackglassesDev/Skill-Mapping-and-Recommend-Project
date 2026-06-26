<script>
	//@ts-nocheck
	import { resolve } from '$app/paths';
	import { invalidateAll } from '$app/navigation';
	import { enhance } from '$app/forms';

	// 1. รับข้อมูลจาก data prop ที่ส่งมาจาก page.server.js
	let { data } = $props();

	// 2. แปลงและจัดการข้อมูล Array
	let curriculumList = $derived(Array.isArray(data?.curriculumRows) ? data.curriculumRows : []);
	let allCourses = $derived(Array.isArray(data?.courseRows) ? data.courseRows : []);

	// 3. สเตตและตัวแปรควบคุม (ค้นหา, เลือกหลักสูตร, หน้าปัจจุบัน)
	let selectedCurriculum = $state(curriculumList[0]?.curriculum_id ?? '');
	let searchQuery = $state(''); // สำหรับเก็บค่าคำค้นหา
	let currentPage = $state(1); // หน้าปัจจุบันเริ่มต้นที่หน้า 1
	const itemsPerPage = 10; // จำนวนรายการที่แสดงต่อ 1 หน้า

	let isAddCurriculumModalOpen = $state(false);
	let isAddCourseModalOpen = $state(false);
	let showMessage = $state(false);
	let alertMessage = $state('');

	// ประกาศ State สำหรับเปิด/ปิด และเก็บข้อมูลวิชาที่จะแก้ไข
	let isEditCourseModalOpen = $state(false);
	let courseToEdit = $state({
		course_id: '',
		course_code: '',
		course_name: '',
		credits: 3,
		description: '',
		curriculum_id: ''
	});

	let isDeleteCourseModalOpen = $state(false);
	let courseToDelete = $state({
		course_id: '',
		course_code: '',
		course_name: ''
	});

	// ฟังก์ชันสำหรับกดปุ่มแก้ไขแล้วให้เอาข้อมูลวิชานั้นๆ มายัดใส่โครงสร้างรอไว้
	function openEditModal(course) {
		courseToEdit = { ...course }; // Clone ข้อมูลวิชาป้องกันการทับซ้อนข้อมูลตัวจริงบนตาราง
		isEditCourseModalOpen = true;
	}

	function openDeleteModal(course) {
		if (!course) return;
		courseToDelete = {
			course_id: course.course_id || '',
			course_code: course.course_code || '',
			course_name: course.course_name || ''
		};
		isDeleteCourseModalOpen = true;
	}

	// 4. 🔥 กรองขั้นที่ 1: กรองรายวิชาตามหลักสูตรที่เลือกก่อน
	let coursesInCurriculum = $derived(
		allCourses.filter((course) => course.curriculum_id === selectedCurriculum)
	);

	// 5. 🔥 กรองขั้นที่ 2: กรองตามช่องค้นหา (ค้นหาได้ทั้ง รหัสวิชา และ ชื่อวิชา)
	let filteredCourses = $derived(
		coursesInCurriculum.filter((course) => {
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

	$effect(() => {
		if (data?.message) {
			alertMessage = data.message;
			showMessage = true;

			// ตั้งเวลานับถอยหลัง 4 วินาที (4000ms) แล้วทำการปิดแถบสไลด์
			const timer = setTimeout(() => {
				showMessage = false;
			}, 4000);

			// คืนค่าฟังก์ชันเพื่อเคลียร์ timeout ป้องกันบั๊กหน่วยความจำซ้อนทับกัน
			return () => clearTimeout(timer);
		}
	});

	let adminPage = resolve('/adminPage');
</script>

<svelte:head>
	<title>แผงควบคุมผู้ดูแลระบบ | Skill Mapping</title>
</svelte:head>

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
					📚
				</div>

				<div class="flex-1 space-y-1">
					<h1 class="text-2xl font-black tracking-tight text-[#443210] sm:text-3xl">
						ระบบจัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
					</h1>
					<p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-400">
						Curriculum Management — บริหารจัดการโครงสร้างรายวิชาของภาควิชา
						เพื่อนำข้อมูลไปประมวลผลและการจัดทำแผนผังทักษะ (Skill Mapping)
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
						onclick={() => window.open('/api/export-curriculums-csv', '_blank')}
						class="inline-flex items-center justify-center gap-2 rounded-xl border-2 border-[#443210] bg-[#443210] px-5 py-2.5 text-xs font-black text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d]"
					>
						📤 ส่งออกข้อมูลรายวิชา (CSV)
					</button>
				</div>
			</div>
		</div>

		<div class="mb-6 flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
			<div class="grid flex-1 grid-cols-1 gap-4 sm:grid-cols-2 lg:max-w-3xl">
				<div class="flex flex-col gap-1.5">
					<span class="pl-1 text-xs font-medium text-gray-400"> หลักสูตร / ภาควิชาที่เลือก </span>
					<div class="relative">
						<select
							bind:value={selectedCurriculum}
							class="w-full cursor-pointer appearance-none rounded-xl border border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-black text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d] focus:ring-1 focus:ring-[#dca11d]"
						>
							{#each curriculumList as item (item.curriculum_id)}
								<option value={item.curriculum_id}>{item.curriculum_name}</option>
							{:else}
								<option value="">❌ ไม่พบข้อมูลหลักสูตรในระบบ</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400"
						>
							▼
						</div>
					</div>
				</div>

				<div class="flex flex-col gap-1.5">
					<span class="pl-1 text-xs font-medium text-gray-400"> ค้นหารายวิชา </span>
					<div class="relative">
						<input
							type="text"
							bind:value={searchQuery}
							placeholder="พิมพ์รหัสวิชา หรือ ชื่อวิชา..."
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
			</div>

			<div class="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-end">
				<button
					type="button"
					onclick={() => (isAddCourseModalOpen = true)}
					class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] sm:w-auto"
				>
					➕ เพิ่มรายวิชาใหม่
				</button>

				<button
					type="button"
					onclick={() => (isAddCurriculumModalOpen = true)}
					class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-xl bg-[#443210] px-5 py-2.5 text-sm font-bold text-white shadow-sm transition-all hover:-translate-y-0.5 hover:border-[#dca11d] hover:text-[#dca11d] sm:w-auto"
				>
					➕ เพิ่มหลักสูตร
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
							<th class="w-1/4 px-6 py-4 font-bold">รหัสวิชา</th>
							<th class="w-1/2 px-6 py-4 font-bold">ชื่อรายวิชา (TH / EN)</th>
							<th class="w-1/4 px-6 py-4 font-bold">โครงสร้างหลักสูตร</th>
							<th class="px-6 py-4 text-center font-bold">การจัดการ</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-100 font-medium text-gray-700">
						{#each paginatedCourses as course (course.course_id)}
							<tr
								class="transition-colors duration-150 odd:bg-white even:bg-gray-50/30 hover:bg-gray-50"
							>
								<td class="px-6 py-4 font-mono font-bold tracking-wide text-gray-500">
									{course.course_code}
								</td>
								<td class="px-6 py-4">
									<span class="block text-sm font-black text-[#443210]">
										{course.course_name}
									</span>
								</td>
								<td class="px-6 py-4">
									<span
										class="inline-flex items-center rounded-lg border border-gray-200 bg-gray-50 px-2.5 py-1 text-xs font-bold text-gray-600"
									>
										{curriculumList.find((c) => c.curriculum_id === course.curriculum_id)
											?.curriculum_name || 'วิศวกรรมคอมพิวเตอร์'}
									</span>
								</td>
								<td class="px-6 py-4 text-center whitespace-nowrap">
									<div class="flex items-center justify-center gap-2">
										<button
											onclick={() => openEditModal(course)}
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-gray-600 shadow-sm transition-all hover:border-[#dca11d] hover:text-[#dca11d]"
										>
											✏️ แก้ไขข้อมูล
										</button>
										<button
											onclick={() => openDeleteModal(course)}
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-black text-rose-500 shadow-sm transition-all hover:border-rose-400 hover:bg-rose-50/50"
										>
											🗑️ ลบรายวิชา
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
										<h3 class="text-sm font-bold text-[#443210]">ไม่พบข้อมูลรายวิชา</h3>
										<p class="mt-1 text-xs leading-relaxed text-gray-400">
											ไม่พบข้อมูลที่ตรงกับเงื่อนไขหลักสูตรหรือคำค้นหาของคุณ <br />
											กรุณาลองระบุคำค้นหาใหม่อีกครั้ง หรือเพิ่มรายวิชาเข้าสู่ระบบ
										</p>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>

			{#if filteredCourses.length > 0}
				<div
					class="flex flex-col items-center justify-between gap-4 border-t border-gray-200 bg-gray-50/50 px-6 py-4 sm:flex-row"
				>
					<span class="text-xs font-medium text-gray-400">
						แสดงข้อมูลหน้า <span class="font-semibold text-gray-700">{currentPage}</span> จากทั้งหมด
						<span class="font-semibold text-gray-700">{totalPages}</span> หน้า (รวมทั้งสิ้น {filteredCourses.length}
						รายวิชา)
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

{#if isAddCurriculumModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isAddCurriculumModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">📚 เพิ่มหลักสูตรใหม่</h3>
            </div>

            <form
                method="POST"
                action="?/createCurriculum"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isAddCurriculumModalOpen = false;
                                await invalidateAll();
                            } else {
                                isAddCurriculumModalOpen = true;
                            }
                        }
                    };
                }}
            >
                <div
                    class="max-h-[70vh] space-y-4 overflow-y-auto p-6 text-xs font-bold text-[#443210]"
                >
                    <div class="space-y-1.5">
                        <label for="curriculumName" class="text-gray-400">
                            ชื่อหลักสูตร / ภาควิชา (Curriculum Name)
                        </label>
                        <input
                            type="text"
                            id="curriculumName"
                            name="curriculum_name"
                            placeholder="เช่น วิศวกรรมคอมพิวเตอร์ (หลักสูตรปรับปรุง พ.ศ. 2565)"
                            required
                            class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                        />
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 p-6">
                    <button
                        type="button"
                        onclick={() => (isAddCurriculumModalOpen = false)}
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

{#if isAddCourseModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isAddCourseModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">📝 เพิ่มรายวิชาใหม่</h3>
            </div>

            <form
                method="POST"
                action="?/createCourse"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isAddCourseModalOpen = false;
                                await invalidateAll();
                            } else {
                                isAddCourseModalOpen = true;
                            }
                        }
                    };
                }}
            >
                <div
                    class="max-h-[70vh] space-y-4 overflow-y-auto p-6 text-xs font-bold text-[#443210]"
                >
                    <div class="space-y-1.5">
                        <label for="modalCurriculumId" class="text-gray-400">
                            หลักสูตร / ภาควิชาที่สังกัด <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <select
                                id="modalCurriculumId"
                                name="curriculum_id"
                                required
                                class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none focus:border-[#dca11d] focus:bg-white"
                            >
                                <option value="" disabled selected>-- เลือกหลักสูตรที่รายวิชานี้สังกัด --</option>
                                {#each curriculumList as item (item.curriculum_id)}
                                    <option value={item.curriculum_id}>{item.curriculum_name}</option>
                                {/each}
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                                ▼
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div class="space-y-1.5 sm:col-span-2">
                            <label for="modalCourseCode" class="text-gray-400">
                                รหัสวิชา <span class="text-rose-500">*</span>
                            </label>
                            <input
                                type="text"
                                id="modalCourseCode"
                                name="course_code"
                                placeholder="เช่น ENGCE174"
                                required
                                class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                            />
                        </div>

                        <div class="space-y-1.5">
                            <label for="modalCredits" class="text-gray-400">
                                หน่วยกิต <span class="text-rose-500">*</span>
                            </label>
                            <input
                                type="number"
                                id="modalCredits"
                                name="credits"
                                min="1"
                                max="10"
                                placeholder="3"
                                required
                                class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                            />
                        </div>
                    </div>

                    <div class="space-y-1.5">
                        <label for="modalCourseName" class="text-gray-400">
                            ชื่อรายวิชา <span class="text-rose-500">*</span>
                        </label>
                        <input
                            type="text"
                            id="modalCourseName"
                            name="course_name"
                            placeholder="เช่น Object-Oriented Programming"
                            required
                            class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                        />
                    </div>

                    <div class="space-y-1.5">
                        <label for="modalDescription" class="text-gray-400">
                            คำอธิบายรายวิชา (Description)
                        </label>
                        <textarea
                            id="modalDescription"
                            name="description"
                            rows="3"
                            placeholder="ระบุเนื้อหาโดยย่อ หรือสมรรถนะรายวิชา..."
                            class="w-full resize-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                        ></textarea>
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 p-6">
                    <button
                        type="button"
                        onclick={() => (isAddCourseModalOpen = false)}
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

{#if isEditCourseModalOpen}
    <div class="fixed inset-0 z-30 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isEditCourseModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">✏️ แก้ไขข้อมูลรายวิชา</h3>
            </div>

            <form
                method="POST"
                action="?/updateCourse"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isEditCourseModalOpen = false;
                                await invalidateAll();
                            }
                        }
                    };
                }}
            >
                <div
                    class="max-h-[70vh] space-y-4 overflow-y-auto p-6 text-xs font-bold text-[#443210]"
                >
                    <input type="hidden" name="course_id" value={courseToEdit.course_id} />

                    <div class="space-y-1.5">
                        <label for="editCurriculumId" class="text-gray-400">
                            หลักสูตร / ภาควิชาที่สังกัด <span class="text-rose-500">*</span>
                        </label>
                        <div class="relative">
                            <select
                                id="editCurriculumId"
                                name="curriculum_id"
                                bind:value={courseToEdit.curriculum_id}
                                required
                                class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-black outline-none focus:border-[#dca11d] focus:bg-white"
                            >
                                <option value="" disabled>-- เลือกหลักสูตรที่รายวิชานี้สังกัด --</option>
                                {#each curriculumList as item (item.curriculum_id)}
                                    <option value={item.curriculum_id}>{item.curriculum_name}</option>
                                {/each}
                            </select>
                            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-[10px] text-gray-400">
                                ▼
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
                        <div class="space-y-1.5 sm:col-span-2">
                            <label for="editCourseCode" class="text-gray-400">
                                รหัสวิชา <span class="text-rose-500">*</span>
                            </label>
                            <input
                                type="text"
                                id="editCourseCode"
                                name="course_code"
                                bind:value={courseToEdit.course_code}
                                placeholder="เช่น 04113101"
                                required
                                class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                            />
                        </div>

                        <div class="space-y-1.5">
                            <label for="editCredits" class="text-gray-400">
                                หน่วยกิต <span class="text-rose-500">*</span>
                            </label>
                            <input
                                type="number"
                                id="editCredits"
                                name="credits"
                                bind:value={courseToEdit.credits}
                                min="1"
                                max="10"
                                placeholder="3"
                                required
                                class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                            />
                        </div>
                    </div>

                    <div class="space-y-1.5">
                        <label for="editCourseName" class="text-gray-400">
                            ชื่อรายวิชา <span class="text-rose-500">*</span>
                        </label>
                        <input
                            type="text"
                            id="editCourseName"
                            name="course_name"
                            bind:value={courseToEdit.course_name}
                            placeholder="เช่น Object-Oriented Programming"
                            required
                            class="w-full rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                        />
                    </div>

                    <div class="space-y-1.5">
                        <label for="editDescription" class="text-gray-400">
                            คำอธิบายรายวิชา (Description)
                        </label>
                        <textarea
                            id="editDescription"
                            name="description"
                            bind:value={courseToEdit.description}
                            rows="3"
                            placeholder="ระบุเนื้อหาโดยย่อ หรือสมรรถนะรายวิชา..."
                            class="w-full resize-none rounded-2xl border-2 border-gray-200 bg-gray-50 p-3 font-medium outline-none focus:border-[#dca11d] focus:bg-white"
                        ></textarea>
                    </div>
                </div>

                <div class="flex justify-end gap-3 border-t border-gray-100 p-6">
                    <button
                        type="button"
                        onclick={() => (isEditCourseModalOpen = false)}
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

{#if isDeleteCourseModalOpen}
    <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <button
            type="button"
            class="fixed inset-0 bg-[#443210]/20 backdrop-blur-sm"
            onclick={() => (isDeleteCourseModalOpen = false)}
        >
            ✕
        </button>

        <div
            class="relative w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] transition-all"
        >
            <div class="border-b border-gray-100 px-6 py-4.5">
                <h3 class="text-base font-black text-[#443210]">🚫 ยืนยันการลบรายวิชา</h3>
            </div>

            <div class="p-6">
                <div class="flex items-center gap-4 rounded-2xl border border-amber-100 bg-amber-50/60 p-4">
                    <span class="text-3xl">⚠️</span>
                    <p class="text-xs leading-relaxed font-bold text-[#443210]">
                        คุณกำลังทำรายการลบรายวิชาออกจากระบบสารสนเทศหลักสูตร 
                        โปรดตรวจสอบข้อมูลความถูกต้องก่อนทำการยืนยัน
                    </p>
                </div>

                <div class="mt-5 space-y-1.5 rounded-2xl border-2 border-gray-100 bg-gray-50/50 p-4">
                    <p class="text-[10px] font-bold text-gray-400 uppercase">
                        รายวิชาที่เลือกทำรายการ:
                    </p>
                    <p class="text-xs font-black text-[#443210]">
                        รหัสวิชา: <span class="font-mono text-gray-600">{courseToDelete.course_code}</span>
                    </p>
                    <p class="text-xs font-black text-[#443210]">
                        ชื่อรายวิชา: <span class="text-gray-600">{courseToDelete.course_name}</span>
                    </p>
                </div>

                <p class="mt-4 rounded-xl border border-rose-100 bg-rose-50 p-3 text-[11px] leading-relaxed font-black text-rose-500">
                    คำเตือน: การลบข้อมูลนี้จะเป็นการลบถาวรออกจากระบบฐานข้อมูล โดยระบบจะถอนรายวิชานี้รวมถึงแผนผังทักษะ (Skill Mapping) ทั้งหมดที่เกี่ยวข้องโดยทันทีและไม่สามารถกู้คืนได้
                </p>
            </div>

            <form
                method="POST"
                action="?/deleteCourse"
                use:enhance={() => {
                    return async ({ result }) => {
                        if (result.data) {
                            alertMessage = result.data.message ?? 'เกิดข้อผิดพลาด';
                            showMessage = true;

                            setTimeout(() => {
                                showMessage = false;
                            }, 4000);

                            if (result.data.success === true) {
                                isDeleteCourseModalOpen = false;
                                await invalidateAll();
                            }
                        }
                    };
                }}
                class="flex justify-end gap-3 px-6 pb-6"
            >
                <input type="hidden" name="course_id" value={courseToDelete.course_id} />

                <button
                    type="button"
                    onclick={() => (isDeleteCourseModalOpen = false)}
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