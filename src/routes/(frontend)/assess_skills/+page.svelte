<script>
	//
	import { resolve } from '$app/paths';
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';

	// 🎯 1. ดึงข้อมูลประยุกต์ใช้ผ่าน Props (Svelte 5 Rune)
	let { data } = $props();

	let login = resolve('/login');
	let home = resolve('/home');

	// 🎯 2. สเตทควบคุมการแสดงผลมอดอล
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

<svelte:head><title>Skill Mapping | AssesssSkills |</title></svelte:head>

{#if authModalOpen}
	<div class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm">
		<div
			class="w-full max-w-sm rounded-[24px] border border-gray-200 bg-[#FAF9F6] p-6 text-center shadow-2xl"
		>
			<div
				class="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-amber-100 text-[#DCA11D]"
			>
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
			<h3 class="text-xl font-bold text-[#443210]">กรุณาเข้าสู่ระบบ</h3>
			<p class="mt-2 text-sm leading-relaxed text-gray-500">
				คุณจำเป็นต้องเข้าสู่ระบบก่อน เพื่อทำการวิเคราะห์และตรวจสอบช่องว่างทักษะตามรายวิชาเลือก
			</p>
			<div class="mt-6 flex flex-col gap-2">
				<a
					href={login}
					class="flex w-full items-center justify-center rounded-xl bg-[#443210] py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15]"
				>
					เข้าสู่ระบบตอนนี้
				</a>
				<a
					href={home}
					class="py-2 text-xs font-semibold text-gray-400 hover:text-gray-700 hover:underline"
				>
					กลับหน้าหลัก
				</a>
			</div>
		</div>
	</div>
{/if}

{#if curriculumModalOpen && !authModalOpen}
	<div class="fixed inset-0 z-40 flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm">
		<div
			class="max-h-[90vh] w-full max-w-xl overflow-y-auto rounded-[24px] border border-gray-200 bg-[#FAF9F6] p-6 text-left shadow-2xl"
		>
			<div class="mb-6 text-center">
				<h3 class="text-xl font-bold tracking-tight text-[#443210]">บันทึกข้อมูลการเรียน</h3>
				<p class="mt-1 text-xs text-gray-500">
					กรุณาระบุหลักสูตรเพื่อดึงข้อมูลวิชาในการเลือกบันทึกเกรดสะสมของคุณ
				</p>
			</div>

			<form
				method="POST"
				action="?/saveCurriculumAndGrades"
				use:enhance={() => {
					return async ({ result }) => {
						if (result.type === 'success') {
							curriculumModalOpen = false; // ปิดมอดอลทันทีเมื่อบันทึกผ่านสำเร็จ
							await invalidateAll();
						}
					};
				}}
				class="space-y-5"
			>
				<div class="space-y-2">
					<label for="curriculum" class="block text-sm font-bold text-[#443210]/90">
						1. เลือกหลักสูตรสาขาวิชา <span class="text-red-500">*</span>
					</label>
					<div class="relative">
						<select
							id="curriculum"
							name="curriculum_id"
							bind:value={selectedCurriculumId}
							required
							class="w-full appearance-none rounded-xl border border-gray-300 bg-white py-3 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm focus:border-[#DCA11D] focus:ring-1 focus:ring-[#DCA11D] focus:outline-none"
						>
							<option value="" disabled selected>-- กรุณาเลือกหลักสูตร --</option>
							{#each curriculumList as curri (curri.curriculum_id)}
								<option value={String(curri.curriculum_id)}>{curri.curriculum_name}</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								fill="none"
								viewBox="0 0 24 24"
								stroke-width="2.5"
								stroke="currentColor"
								class="h-4 w-4"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									d="m19.5 8.25-7.5 7.5-7.5-7.5"
								/>
							</svg>
						</div>
					</div>
				</div>

				<hr class="border-gray-200" />

				<div class="space-y-3">
					<span class="block text-sm font-bold text-[#443210]/90">
						2. เลือกเกรดรายวิชาที่เรียนผ่านมาแล้ว
					</span>

					{#if filteredCourses.length > 0}
						<div class="max-h-[40vh] space-y-2 overflow-y-auto pr-1">
							{#each filteredCourses as course (course.course_code)}
								{@const oldGrade = data.savedGrades?.find(
									(g) => g.course_id === course.course_id
								)?.grade_letter}
								<div
									class="flex items-center justify-between gap-4 rounded-xl border border-gray-100 bg-white p-3.5 shadow-sm"
								>
									<div class="min-w-0 flex-1">
										<p class="text-xs font-bold tracking-wide text-[#DCA11D] uppercase">
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
											class="w-full appearance-none rounded-lg border border-gray-300 bg-[#FAF9F6] px-3 py-2 text-sm font-bold text-[#443210] focus:border-[#DCA11D] focus:outline-none"
										>
											<option value="" disabled selected={!oldGrade}>เลือกเกรด</option>
											<option value="NOT_TAKEN" selected={oldGrade === 'NOT_TAKEN'}
												>ยังไม่ได้เรียน</option
											>
											<option value="A" selected={oldGrade === 'A'}>A</option>
											<option value="B+" selected={oldGrade === 'B+'}>B+</option>
											<option value="B" selected={oldGrade === 'B'}>B</option>
											<option value="C+" selected={oldGrade === 'C+'}>C+</option>
											<option value="C" selected={oldGrade === 'C'}>C</option>
											<option value="D+" selected={oldGrade === 'D+'}>D+</option>
											<option value="D" selected={oldGrade === 'D'}>D</option>
											<option value="F" selected={oldGrade === 'F'}>F</option>
										</select>
										<div
											class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2 text-gray-400"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												fill="none"
												viewBox="0 0 24 24"
												stroke-width="2"
												stroke="currentColor"
												class="h-3 w-3"
											>
												<path
													stroke-linecap="round"
													stroke-linejoin="round"
													d="m19.5 8.25-7.5 7.5-7.5-7.5"
												/>
											</svg>
										</div>
									</div>
								</div>
							{/each}
						</div>
					{:else}
						<div
							class="rounded-xl border border-dashed border-gray-200 bg-white p-8 text-center text-sm text-gray-400 italic"
						>
							{selectedCurriculumId
								? 'ไม่พบรายวิชาในหลักสูตรนี้'
								: 'กรุณาเลือกหลักสูตรด้านบนก่อน เพื่อให้ระบบแสดงรายวิชา'}
						</div>
					{/if}
				</div>

				<div class="mt-6 flex flex-col gap-2">
					<button
						type="submit"
						disabled={filteredCourses.length === 0}
						class="w-full cursor-pointer rounded-xl bg-[#443210] py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15] disabled:cursor-not-allowed disabled:bg-gray-300 disabled:text-gray-500"
					>
						บันทึกหลักสูตรและเกรดรายวิชา
					</button>

					{#if curriculumModalOpen && data.hasCurriculum}
						<button
							type="button"
							class="cursor-pointer py-2 text-center text-xs font-semibold text-gray-400 hover:text-gray-700 hover:underline"
							onclick={() => (curriculumModalOpen = false)}>ย้อนกลับ</button
						>
					{/if}
				</div>
			</form>
		</div>
	</div>
{/if}

<div
	class="min-h-screen bg-gradient-to-b bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] from-gray-50/50 to-gray-100/30 bg-[size:24px_24px] py-16"
>
	<main class="container mx-auto max-w-7xl space-y-10 px-4 py-8 md:px-8">
		<section class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
			<div
				class="flex items-center gap-5 rounded-2xl border border-[#DCA11D] bg-[#ffffff] p-6 shadow-sm transition-all hover:shadow-md"
			>
				<div
					class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full border-2 border-[#DCA11D] bg-[#DCA11D] text-3xl font-bold text-white shadow-md md:h-20 md:w-20 md:text-4xl"
				>
					{data.completedCoursesCount || 0}
				</div>
				<div>
					<h4 class="text-sm font-medium tracking-wider text-gray-500 uppercase">
						รายวิชาที่ผ่านแล้ว
					</h4>
					<p class="mt-0.5 text-xl font-bold text-[#443210]">วิชา</p>
				</div>
			</div>

			<div
				class="flex items-center gap-5 rounded-2xl border border-[#DCA11D] bg-[#ffffff] p-6 shadow-sm transition-all hover:shadow-md"
			>
				<div
					class="flex h-16 w-16 shrink-0 items-center justify-center rounded-full border-2 border-[#DCA11D] bg-[#DCA11D] text-3xl font-bold text-white shadow-md md:h-20 md:w-20 md:text-4xl"
				>
					{data.passedSkillsCount || 0}
				</div>
				<div>
					<h4 class="text-sm font-medium tracking-wider text-gray-500 uppercase">
						ทักษะที่สะสมได้
					</h4>
					<p class="mt-0.5 text-xl font-bold text-[#443210]">ทักษะ</p>
				</div>
			</div>

			<div
				class="flex flex-col justify-center rounded-2xl border border-[#DCA11D] bg-[#ffffff] p-6 shadow-sm transition-all hover:shadow-md sm:col-span-2 lg:col-span-1"
			>
				<div class="space-y-3">
					<div class="flex items-start gap-2">
						<span class="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-[#DCA11D]"></span>
						<p class="text-sm font-medium text-[#443210]/80">
							ทักษะที่โดดเด่นที่สุด: <strong class="block text-lg font-bold text-[#443210]"
								>รอกรอกยังไม่ได้ทำ</strong
							>
						</p>
					</div>
					<div class="flex items-start gap-2 border-t border-gray-200/60 pt-2">
						<span class="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-[#443210]/50"></span>
						<p class="text-sm font-medium text-[#443210]/70">
							ทักษะที่เป็นรอง: <strong class="block text-base font-bold text-[#443210]/90"
								>รอกรอกยังไม่ได้ทำ</strong
							>
						</p>
					</div>
				</div>
			</div>
		</section>

		<section class="grid grid-cols-1 items-start gap-8 lg:grid-cols-12">
			<div class="space-y-6 lg:col-span-7">
				<h2 class="text-2xl font-bold tracking-tight text-[#443210]">สำรวจทักษะของคุณ</h2>

				<div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-4">
					<label for="career-dropdown" class="shrink-0 text-base font-bold text-[#443210]/90">
						เปรียบเทียบทักษะกับตำแหน่ง:
					</label>
					<div class="relative max-w-xs flex-1">
						<select
							id="career-dropdown"
							bind:value={selectedCareerId}
							class="w-full appearance-none rounded-xl border border-[#DCA11D] bg-[#ffffff] py-3 pr-10 pl-4 text-sm font-bold text-[#443210] shadow-sm transition-all focus:border-[#DCA11D] focus:ring-1 focus:ring-[#DCA11D] focus:outline-none"
						>
							<option value="" disabled>-- กรุณาเลือกตำแหน่งงาน --</option>
							{#each joblist as job (job.job_id)}
								<option value={String(job.job_id)}>{job.name_job}</option>
							{/each}
						</select>
						<div
							class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 text-gray-500"
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								fill="none"
								viewBox="0 0 24 24"
								stroke-width="2.5"
								stroke="currentColor"
								class="h-4 w-4"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									d="m19.5 8.25-7.5 7.5-7.5-7.5"
								/>
							</svg>
						</div>
					</div>
				</div>

				<div class="rounded-2xl border border-[#DCA11D] bg-[#ffffff] p-6 shadow-sm">
					<h3 class="text-sm font-bold tracking-wider text-gray-400 uppercase">
						ทักษะที่ต้องศึกษาเพิ่ม
					</h3>
					<p class="mt-2 text-xl font-bold tracking-tight text-[#DCA11D] md:text-2xl">
						รอกรอกยังไม่ได้ทำ
					</p>
				</div>
			</div>

			<div
				class="flex flex-col items-center rounded-3xl border border-gray-100 bg-white p-6 shadow-md lg:col-span-5"
			>
				<h3 class="mb-4 text-base font-bold text-[#443210]/90">กราฟวิเคราะห์ทักษะ (Radar Chart)</h3>

				<div
					class="flex h-64 w-full items-center justify-center rounded-xl border-2 border-dashed border-gray-200 bg-gray-100"
				>
					<p class="text-sm font-medium text-gray-400 italic">
						[ ส่วนสำหรับเรนเดอร์ Radar Chart Canvas ]
					</p>
				</div>

				<div class="mt-5 flex gap-6 text-xs font-semibold">
					<div class="flex items-center gap-2">
						<span class="h-3 w-3 rounded-full bg-[#DCA11D]"></span>
						<span class="text-gray-600">ทักษะของคุณ</span>
					</div>
					<div class="flex items-center gap-2">
						<span class="h-3 w-3 rounded-full bg-[#443210]"></span>
						<span class="text-gray-600">ทักษะของอาชีพ</span>
					</div>
				</div>
			</div>
		</section>

		<section class="space-y-6">
			<h2 class="text-xl font-bold text-[#443210] md:text-2xl">แนะนำวิชาเลือก</h2>

			<!-- <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
				{#each data.recommendedCourses as course (course.id)}
					<div
						class="group flex flex-col justify-between rounded-2xl border border-gray-200 bg-[#FAF9F6] p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#DCA11D]/60 hover:bg-white hover:shadow-md"
					>
						<div>
							<div
								class="flex h-12 w-12 items-center justify-center rounded-full border border-[#DCA11D]/30 bg-[#DCA11D]/10 text-sm font-bold text-[#DCA11D] shadow-inner"
							>
								{course.group}
							</div>
							<h4 class="mt-4 text-xs font-bold tracking-wider text-gray-400 uppercase">
								{course.code}
							</h4>
							<h3
								class="mt-1 text-base leading-tight font-bold text-[#443210] group-hover:text-amber-950"
							>
								{course.name}
							</h3>
						</div>

						<div class="mt-6 border-t border-gray-100 pt-3">
							<span class="text-[10px] font-bold tracking-wider text-gray-400 uppercase"
								>ทักษะที่เกี่ยวข้อง:</span
							>
							<div class="mt-2 flex flex-wrap gap-1.5">
								{#each course.skills as skill}
									<span
										class="rounded-lg bg-[#443210]/5 px-2.5 py-1 text-xs font-semibold text-[#443210]/80 transition-colors group-hover:bg-[#DCA11D]/10 group-hover:text-[#DCA11D]"
									>
										{skill}
									</span>
								{/each}
							</div>
						</div>
					</div>
				{/each}
			</div> -->

			<div class="flex justify-end pt-2">
				<button
					type="button"
					class="cursor-pointer rounded-xl bg-[#443210] px-6 py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15] hover:shadow-lg focus:outline-none"
				>
					แนะนำสายงานที่ถนัด
				</button>
				<button
					type="button"
					class="mx-3 cursor-pointer rounded-xl bg-[#443210] px-6 py-3 text-sm font-bold text-[#DCA11D] shadow-md transition-all hover:bg-[#543f15] hover:shadow-lg focus:outline-none"
					onclick={() => (curriculumModalOpen = true)}>ปรับปรุงเกรด</button
				>
			</div>
		</section>
	</main>
</div>
