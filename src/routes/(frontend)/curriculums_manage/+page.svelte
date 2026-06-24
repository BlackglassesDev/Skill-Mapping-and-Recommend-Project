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

	// ฟังก์ชันสำหรับกดปุ่มแก้ไขแล้วให้เอาข้อมูลวิชานั้นๆ มายัดใส่โครงสร้างรอไว้
	function openEditModal(course) {
		courseToEdit = { ...course }; // Clone ข้อมูลวิชาป้องกันการทับซ้อนข้อมูลตัวจริงบนตาราง
		isEditCourseModalOpen = true;
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
	<title>Skill Mapping | Manage Curriculums |</title>
</svelte:head>

<div
	class="pointer-events-none fixed top-6 right-0 left-0 z-50 flex justify-center p-4 transition-all duration-500 ease-out"
	class:translate-y-0={showMessage}
	class:-translate-y-20={!showMessage}
	class:opacity-100={showMessage}
	class:opacity-0={!showMessage}
>
	<div
		class="pointer-events-auto flex max-w-md items-center gap-3 rounded-2xl border border-gray-200 bg-white px-5 py-3.5 text-sm font-semibold text-[#443210] shadow-2xl"
	>
		<span class="flex h-6 w-6 items-center justify-center rounded-full bg-[#dca11d]/10 text-base"
			>🔔</span
		>
		<span class="flex-1 text-gray-700">{alertMessage}</span>
		<button
			onclick={() => (showMessage = false)}
			class="ml-2 p-1 text-xs text-gray-400 transition-colors hover:text-gray-600"
		>
			✕
		</button>
	</div>
</div>

<div
	class="min-h-screen bg-gray-50 bg-[linear-gradient(to_right,#80808018_1px,transparent_1px),linear-gradient(to_bottom,#80808018_1px,transparent_1px)] bg-[size:24px_24px] py-16"
>
	<div class="mx-auto max-w-7xl px-6 lg:px-8">
		<div class="mb-8 rounded-3xl border-2 border-gray-100 bg-white p-6 shadow-sm sm:p-8">
			<div
				class="flex flex-col items-center gap-5 text-center md:flex-row md:items-start md:gap-6 md:text-left"
			>
				<div
					class="inline-flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-amber-100 bg-amber-50 text-2xl text-[#dca11d] shadow-sm"
				>
					📚
				</div>

				<div class="flex-1 space-y-1.5">
					<h1 class="text-2xl font-extrabold tracking-tight text-[#443210] sm:text-3xl">
						จัดการ<span class="text-[#dca11d]">หลักสูตรและรายวิชา</span>
					</h1>
					<p class="max-w-2xl text-sm leading-relaxed font-medium text-gray-500">
						Curriculum Management — บริหารจัดการโครงสร้างรายวิชาของแผนก
						เพื่อนำข้อมูลไปเชื่อมโยงและประเมินผลระดับทักษะ (Skill Mapping)
					</p>
					<div
						class="mt-2 inline-flex items-center gap-1.5 rounded-full border border-red-100 bg-red-50 px-2.5 py-0.5 text-xs font-semibold text-red-600"
					>
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
					<span class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>หลักสูตร / ภาควิชาที่เลือก</span
					>
					<div class="relative">
						<select
							bind:value={selectedCurriculum}
							class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d]"
						>
							{#each curriculumList as item (item.curriculum_id)}
								<option value={item.curriculum_id}>{item.curriculum_name}</option>
							{:else}
								<option value="">❌ ไม่มีข้อมูลหลักสูตรในระบบ</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-xs text-gray-400"
						>
							▼
						</div>
					</div>
				</div>

				<div class="flex flex-col gap-1.5">
					<span class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>ค้นหารายวิชา</span
					>
					<div class="relative">
						<input
							type="text"
							bind:value={searchQuery}
							placeholder="พิมพ์รหัสวิชา หรือ ชื่อวิชาที่ต้องการ..."
							class="w-full rounded-2xl border-2 border-gray-200 bg-white py-2.5 pr-4 pl-10 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
						/>
						<div
							class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3.5 text-base text-gray-400"
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

			<div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-end">
				<button
					type="button"
					onclick={() => (isAddCourseModalOpen = true)}
					class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-2xl bg-[#634c20] px-6 py-3 text-sm font-black text-white shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-300 hover:-translate-y-1 hover:bg-[#2d210a] hover:shadow-[0_8px_20px_rgba(68,50,16,0.25)] sm:w-auto"
				>
					➕ เพิ่มรายวิชาใหม่
				</button>

				<button
					type="button"
					onclick={() => (isAddCurriculumModalOpen = true)}
					class="inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-2xl bg-[#634c20] px-6 py-3 text-sm font-black text-white shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-300 hover:-translate-y-1 hover:bg-[#2d210a] hover:shadow-[0_8px_20px_rgba(68,50,16,0.25)] sm:w-auto"
				>
					➕ เพิ่มหลักสูตร
				</button>
			</div>
		</div>

		<div
			class="overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.04)]"
		>
			<div class="overflow-x-auto">
				<table class="w-full border-collapse text-left text-sm text-gray-500">
					<thead
						class="border-b-2 border-gray-100 bg-gray-50/70 text-xs font-black tracking-wider text-gray-400 uppercase"
					>
						<tr>
							<th class="w-1/4 px-8 py-5">รหัสวิชา</th>
							<th class="w-1/2 px-8 py-5">ชื่อรายวิชา (TH / EN)</th>
							<th class="w-1/4 px-8 py-5">โครงสร้างหลักสูตร</th>
							<th class="px-8 py-5 text-right">การจัดการ</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-100 font-medium text-[#443210]">
						{#each paginatedCourses as course (course.course_id)}
							<tr
								class="transition-colors duration-200 odd:bg-white even:bg-gray-50/40 hover:bg-amber-50/30"
							>
								<td class="px-8 py-5 font-mono font-black tracking-wide text-gray-500">
									{course.course_code}
								</td>
								<td class="px-8 py-5">
									<div class="space-y-0.5">
										<span class="block text-sm font-extrabold text-[#443210]"
											>{course.course_name}</span
										>
									</div>
								</td>
								<td class="px-8 py-5">
									<span
										class="inline-flex items-center rounded-xl border border-amber-100/70 bg-amber-50 px-3 py-1 text-xs font-black text-[#dca11d]"
									>
										{curriculumList.find((c) => c.curriculum_id === course.curriculum_id)
											?.curriculum_name || 'วิศวกรรมคอมพิวเตอร์'}
									</span>
								</td>
								<td class="px-6 py-4 text-center whitespace-nowrap">
									<div class="flex items-center justify-center gap-2">
										<button
											onclick={() => openEditModal(course)}
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-gray-600 shadow-sm transition-colors hover:border-[#dca11d] hover:text-[#dca11d]"
										>
											✏️ แก้ไข
										</button>
										<button
											class="cursor-pointer rounded-xl border border-gray-200 bg-white px-3 py-1.5 text-xs font-bold text-rose-500 shadow-sm transition-colors hover:border-rose-400 hover:bg-rose-50/50"
											onclick={() => openDeleteModal(course)}
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
										<div
											class="flex h-16 w-16 items-center justify-center rounded-2xl bg-gray-50 text-3xl text-gray-400 border border-gray-100 shadow-inner mb-4 animate-pulse"
										>
											💨
										</div>
										<h3 class="text-base font-black text-[#443210]">ไม่พบข้อมูลรายวิชา</h3>
										<p class="mt-2 text-xs leading-relaxed font-medium text-gray-400">
											ไม่พบข้อมูลวิชาตามเงื่อนไขหลักสูตรหรือคำค้นหาดังกล่าว
											พี่สามารถลองพิมพ์คำอื่นหรือกดปุ่มเพิ่มรายวิชาได้เลยครับ
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
					class="flex flex-col items-center justify-between gap-4 border-t border-gray-100 bg-gray-50/50 px-8 py-4 sm:flex-row"
				>
					<span class="text-xs font-bold text-gray-400">
						แสดงข้อมูลหน้า <span class="text-[#443210]">{currentPage}</span> จากทั้งหมด
						<span class="text-[#443210]">{totalPages}</span>
						หน้า (รวม {filteredCourses.length} วิชา)
					</span>

					<div class="inline-flex items-center gap-1.5">
						<button
							type="button"
							onclick={() => (currentPage = 1)}
							disabled={currentPage === 1}
							class="rounded-xl border border-gray-200 bg-white p-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
							title="หน้าแรกสุด"
						>
							«
						</button>

						<button
							type="button"
							onclick={() => (currentPage = Math.max(1, currentPage - 1))}
							disabled={currentPage === 1}
							class="inline-flex items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
						>
							◀ ก่อนหน้า
						</button>

						<button
							type="button"
							onclick={() => (currentPage = Math.min(totalPages, currentPage + 1))}
							disabled={currentPage === totalPages}
							class="inline-flex items-center justify-center gap-1.5 rounded-xl border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-[#443210] shadow-sm transition-all hover:bg-gray-50 disabled:opacity-40 disabled:hover:bg-white"
						>
							ถัดไป ▶
						</button>

						<button
							type="button"
							onclick={() => (currentPage = totalPages)}
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

{#if isAddCurriculumModalOpen}
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4 backdrop-blur-sm"
	>
		<div
			class="w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_24px_48px_rgba(0,0,0,0.05)]"
		>
			<div class="flex items-center gap-3 border-b-2 border-gray-50 bg-amber-50/30 px-6 py-5">
				<span
					class="flex h-10 w-10 items-center justify-center rounded-xl border border-amber-100 bg-amber-50 text-xl text-[#dca11d]"
					>📚</span
				>
				<div>
					<h2 class="text-lg font-black text-[#443210]">เพิ่มหลักสูตรใหม่</h2>
					<p class="mt-0.5 text-xs font-bold text-gray-400">ระบุชื่อหลักสูตรเพื่อเริ่มต้นใช้งาน</p>
				</div>
			</div>

			<form method="POST" action="?/createCurriculum" class="space-y-5 p-6">
				<div class="flex flex-col gap-1.5">
					<label
						for="curriculumName"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						ชื่อหลักสูตร / ภาควิชา <span class="text-red-500">*</span>
					</label>
					<input
						type="text"
						id="curriculumName"
						name="curriculum_name"
						placeholder="เช่น วิศวกรรมคอมพิวเตอร์ (หลักสูตรปรับปรุง 2565)"
						required
						class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
					/>
				</div>

				<div class="flex justify-end gap-3 pt-2">
					<button
						type="button"
						onclick={() => (isAddCurriculumModalOpen = false)}
						class="cursor-pointer rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-[#443210] transition-colors hover:bg-gray-50"
					>
						ยกเลิก
					</button>
					<button
						type="submit"
						class="cursor-pointer rounded-xl border-2 border-[#634c20] bg-[#634c20] px-5 py-2 text-xs font-bold text-white shadow-sm transition-colors hover:border-[#2d210a] hover:bg-[#2d210a]"
					>
						💾 บันทึกข้อมูล
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

{#if isAddCourseModalOpen}
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4 backdrop-blur-sm"
	>
		<div
			class="w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_24px_48px_rgba(0,0,0,0.05)]"
		>
			<div class="flex items-center gap-3 border-b-2 border-gray-50 bg-amber-50/30 px-6 py-5">
				<span
					class="flex h-10 w-10 items-center justify-center rounded-xl border border-amber-100 bg-amber-50 text-xl text-[#dca11d]"
					>📝</span
				>
				<div>
					<h2 class="text-lg font-black text-[#443210]">เพิ่มรายวิชาใหม่</h2>
					<p class="mt-0.5 text-xs font-bold text-gray-400">
						กรอกข้อมูลรายวิชาเพื่อเชื่อมโยงกับระบบ Skill Mapping
					</p>
				</div>
			</div>

			<form
				method="POST"
				action="?/createCourse"
				class="max-h-[75vh] space-y-4 overflow-y-auto p-6"
			>
				<div class="flex flex-col gap-1.5">
					<label
						for="modalCurriculumId"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						หลักสูตร / ภาควิชาที่สังกัด <span class="text-red-500">*</span>
					</label>
					<div class="relative">
						<select
							id="modalCurriculumId"
							name="curriculum_id"
							required
							class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d]"
						>
							<option value="" disabled selected>-- เลือกหลักสูตรที่วิชานี้สังกัด --</option>
							{#each curriculumList as item (item.curriculum_id)}
								<option value={item.curriculum_id}>{item.curriculum_name}</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-xs text-gray-400"
						>
							▼
						</div>
					</div>
				</div>

				<div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
					<div class="flex flex-col gap-1.5 sm:col-span-2">
						<label
							for="modalCourseCode"
							class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>
							รหัสวิชา <span class="text-red-500">*</span>
						</label>
						<input
							type="text"
							id="modalCourseCode"
							name="course_code"
							placeholder="เช่น 04113101"
							required
							class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
						/>
					</div>

					<div class="flex flex-col gap-1.5">
						<label
							for="modalCredits"
							class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>
							หน่วยกิต <span class="text-red-500">*</span>
						</label>
						<input
							type="number"
							id="modalCredits"
							name="credits"
							min="1"
							max="10"
							placeholder="3"
							required
							class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
						/>
					</div>
				</div>

				<div class="flex flex-col gap-1.5">
					<label
						for="modalCourseName"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						ชื่อรายวิชา <span class="text-red-500">*</span>
					</label>
					<input
						type="text"
						id="modalCourseName"
						name="course_name"
						placeholder="เช่น Object-Oriented Programming"
						required
						class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
					/>
				</div>

				<div class="flex flex-col gap-1.5">
					<label
						for="modalDescription"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						คำอธิบายรายวิชา (Description)
					</label>
					<textarea
						id="modalDescription"
						name="description"
						rows="3"
						placeholder="อธิบายเนื้อหาโดยย่อ หรือสมรรถนะรายวิชา..."
						class="w-full resize-none rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
					></textarea>
				</div>

				<div class="flex justify-end gap-3 border-t border-gray-50 pt-3">
					<button
						type="button"
						onclick={() => (isAddCourseModalOpen = false)}
						class="rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-[#443210] transition-colors hover:bg-gray-50"
					>
						ยกเลิก
					</button>
					<button
						type="submit"
						class="rounded-xl border-2 border-[#634c20] bg-[#634c20] px-5 py-2 text-xs font-bold text-white shadow-sm transition-colors hover:border-[#2d210a] hover:bg-[#2d210a]"
					>
						💾 บันทึกรายวิชา
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

{#if isEditCourseModalOpen}
	<div
		class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4 backdrop-blur-sm"
	>
		<div
			class="w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-100 bg-white shadow-[0_24px_48px_rgba(0,0,0,0.05)]"
		>
			<div class="flex items-center gap-3 border-b-2 border-gray-50 bg-amber-50/30 px-6 py-5">
				<span
					class="flex h-10 w-10 items-center justify-center rounded-xl border border-amber-200 bg-amber-50 text-xl text-[#dca11d]"
					>✏️</span
				>
				<div>
					<h2 class="text-lg font-black text-[#443210]">แก้ไขข้อมูลรายวิชา</h2>
					<p class="mt-0.5 text-xs font-bold text-gray-400">
						อัปเดตข้อมูลรายละเอียดวิชาในระบบ Skill Mapping
					</p>
				</div>
			</div>

			<form
				method="POST"
				action="?/updateCourse"
				class="max-h-[75vh] space-y-4 overflow-y-auto p-6"
			>
				<input type="hidden" name="course_id" value={courseToEdit.course_id} />

				<div class="flex flex-col gap-1.5">
					<label
						for="editCurriculumId"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						หลักสูตร / ภาควิชาที่สังกัด <span class="text-red-500">*</span>
					</label>
					<div class="relative">
						<select
							id="editCurriculumId"
							name="curriculum_id"
							bind:value={courseToEdit.curriculum_id}
							required
							class="w-full cursor-pointer appearance-none rounded-2xl border-2 border-gray-200 bg-white py-2.5 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d]"
						>
							<option value="" disabled>-- เลือกหลักสูตรที่วิชานี้สังกัด --</option>
							{#each curriculumList as item (item.curriculum_id)}
								<option value={item.curriculum_id}>{item.curriculum_name}</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-4 text-xs text-gray-400"
						>
							▼
						</div>
					</div>
				</div>

				<div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
					<div class="flex flex-col gap-1.5 sm:col-span-2">
						<label
							for="editCourseCode"
							class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>
							รหัสวิชา <span class="text-red-500">*</span>
						</label>
						<input
							type="text"
							id="editCourseCode"
							name="course_code"
							bind:value={courseToEdit.course_code}
							placeholder="เช่น 04113101"
							required
							class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
						/>
					</div>

					<div class="flex flex-col gap-1.5">
						<label
							for="editCredits"
							class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
						>
							หน่วยกิต <span class="text-red-500">*</span>
						</label>
						<input
							type="number"
							id="editCredits"
							name="credits"
							bind:value={courseToEdit.credits}
							min="1"
							max="10"
							required
							class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] shadow-sm transition-all outline-none focus:border-[#dca11d]"
						/>
					</div>
				</div>

				<div class="flex flex-col gap-1.5">
					<label
						for="editCourseName"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						ชื่อรายวิชา <span class="text-red-500">*</span>
					</label>
					<input
						type="text"
						id="editCourseName"
						name="course_name"
						bind:value={courseToEdit.course_name}
						placeholder="เช่น Object-Oriented Programming"
						required
						class="w-full rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
					/>
				</div>

				<div class="flex flex-col gap-1.5">
					<label
						for="editDescription"
						class="pl-1 text-xs font-bold tracking-wider text-gray-400 uppercase"
					>
						คำอธิบายรายวิชา (Description)
					</label>
					<textarea
						id="editDescription"
						name="description"
						bind:value={courseToEdit.description}
						rows="3"
						placeholder="อธิบายเนื้อหาโดยย่อ หรือสมรรถนะรายวิชา..."
						class="w-full resize-none rounded-2xl border-2 border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-[#443210] placeholder-gray-400 shadow-sm transition-all outline-none focus:border-[#dca11d]"
					></textarea>
				</div>

				<div class="flex justify-end gap-3 border-t border-gray-50 pt-3">
					<button
						type="button"
						onclick={() => (isEditCourseModalOpen = false)}
						class="rounded-xl border-2 border-gray-200 bg-white px-4 py-2 text-xs font-bold text-[#443210] transition-colors hover:bg-gray-50"
					>
						ยกเลิก
					</button>
					<button
						type="submit"
						class="rounded-xl border-2 border-[#634c20] bg-[#634c20] px-5 py-2 text-xs font-bold text-white shadow-sm transition-colors hover:border-[#2d210a] hover:bg-[#2d210a]"
					>
						💾 บันทึกการแก้ไข
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}
