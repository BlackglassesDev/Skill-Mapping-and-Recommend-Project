<script>
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	/** @type {{ data: { courses: any[], jobs: any[], user: any } }} */
	let { data } = $props();

	// บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length
	let courses = $derived(Array.isArray(data.courses) ? data.courses.slice(0, 8) : []);
	let allcourses = $derived(Array.isArray(data.courses) ? data.courses : []);
	let allcourses_more = $state(false);
	let displayCourses = $derived(allcourses_more ? allcourses : courses);
	let jobs = $derived(Array.isArray(data.jobs) ? data.jobs.slice(0, 5) : []);
	let alljobs = $derived(Array.isArray(data.jobs) ? data.jobs : []);
	let boxinfo = $state('');
	let job_skill_Modal = $state(false);
	let jobs_more = $state(false);
	/** @type {any[]} */
	let selectedJobSkills = $state([]); // ตัวแปรเก็บรายการ Skill ที่ดึงมา
	let courseSkillsList = $derived(Array.isArray(data.course_skills) ? data.course_skills : []);

	// ข้อมูลจำลองสำหรับวนลูป
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

<svelte:head><title>Skill Mapping | RMUTL | Home</title></svelte:head>

<div
	class="min-h-screen bg-slate-50 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"
>
	<div class="mx-auto max-w-6xl space-y-20 px-4 py-10 md:py-16">
		<section class="space-y-4 text-center">
			<h1 class="text-2xl font-bold text-[#443210] md:text-4xl">
				เตรียมความพร้อมทักษะ <br /> และเส้นทางอาชีพของคุณ
			</h1>
			<p class="text-sm text-gray-600 md:text-base">
				สำรวจอาชีพในสายงาน และประเมินช่องว่างทักษะของคุณ อ้างอิงตามหลักสูตร มทร.ล้านนา
			</p>

			<div class="flex flex-wrap justify-center gap-6 pt-10 md:gap-16">
				{#each steps as step (step.text)}
					<div class="flex flex-col items-center gap-4">
						<div
							class="flex h-28 w-28 items-center justify-center rounded-full bg-white text-[#443210] shadow-[0_8px_30px_rgb(0,0,0,0.08)] ring-4 ring-[#dca11d]/20 transition-all duration-300 hover:-translate-y-2 hover:shadow-[0_8px_30px_rgb(220,161,29,0.3)] hover:ring-[#dca11d] md:h-36 md:w-36"
						>
							<span class="text-4xl transition-transform duration-300 hover:scale-110 md:text-5xl"
								>{step.icon}</span
							>
						</div>
						<span class="text-base font-bold text-[#443210] md:text-lg">{step.text}</span>
					</div>
				{/each}
			</div>
		</section>

		<section class="space-y-6 py-6">
			<h2 class="text-xl font-bold text-[#443210] md:text-2xl">เรียนจบแล้วเป็นอะไรได้บ้าง ?</h2>

			{#if jobs.length === 0}
				<div
					class="col-span-full rounded-2xl border-2 border-dashed border-gray-200 bg-[#FAF9F6] p-12 text-center"
				>
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
							<div
								class="flex h-11 w-11 shrink-0 items-center justify-center rounded-full border-2 border-amber-500/70 bg-white font-bold text-[#443210]/60 shadow-sm transition-colors group-hover:border-[#DCA11D] group-hover:bg-[#DCA11D]/70 group-hover:text-white md:h-12 md:w-12"
							>
								{job.job_id}
							</div>

							<div
								class="flex-1 rounded-2xl border border-amber-500/60 bg-[#fefefe] px-5 py-3.5 text-base font-bold text-[#443210]/90 shadow-sm transition-all duration-300 group-hover:-translate-y-0.5 group-hover:border-[#DCA11D]/80 group-hover:bg-white group-hover:text-[#443210] group-hover:shadow-md md:text-lg"
							>
								{job.name_job}
							</div>
						</button>
					</form>
				{/each}
			</div>

			{#if jobs.length > 0}
				<div class="flex items-center justify-end pt-2">
					<button
						type="button"
						onclick={() => (jobs_more = true)}
						class="flex items-center gap-1 rounded-xl border border-gray-300/70 bg-[#ffffff] px-5 py-2.5 text-sm font-bold text-[#443210]/80 shadow-sm transition-colors hover:bg-[#443210] hover:text-[#ffffff] hover:underline hover:shadow-md"
					>
						ดูเพิ่มเติม
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
								d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"
							/>
						</svg>
					</button>
				</div>
			{/if}
		</section>

		<section class="space-y-6 py-4">
			<h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
				<span class="text-2xl">📖</span> รายวิชาในหลักสูตร
			</h2>

			{#if displayCourses.length === 0}
				<div
					class="rounded-2xl border-2 border-dashed border-gray-300 bg-gray-50/50 p-12 text-center backdrop-blur-sm"
				>
					<p class="font-medium text-gray-500">ไม่พบรายวิชาในหลักสูตรของคุณ</p>
				</div>
			{/if}

			<div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
				{#each displayCourses as course (course.course_id)}
				{@const currentSkills = courseSkillsList.filter(s => s.course_id === course.course_id)}
					<button
						type="button"
						onclick={() => info_subject(course.course_id)}
						class="group btn flex cursor-pointer flex-col justify-between rounded-2xl border border-amber-500/60 bg-[#ffffff] p-5 text-left shadow-sm transition-all duration-300 hover:-translate-y-1 hover:border-[#DCA11D]/80 hover:bg-white hover:shadow-md"
					>
						<div class="mb-4">
							<span
								class="inline-block rounded-lg bg-[#654e21]/10 px-2 py-0.5 text-xs font-bold text-amber-500"
							>
								{course.course_code}
							</span>
							<h3
								class="mt-2 line-clamp-2 h-11 text-sm leading-tight font-bold text-[#443210]/90 transition-colors group-hover:text-[#443210] md:text-base"
							>
								{course.course_name}
							</h3>
						</div>

						<div class="border-t border-[#443210]/15 pt-3">
							<span class="text-[10px] font-bold tracking-wider text-gray-400 uppercase"
								>Skills</span
							>
							{#if currentSkills.length > 0}
								<p class="mt-0.5 line-clamp-1 text-xs font-medium text-[#443210]/70 italic">
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
				<div class="flex justify-center pt-4">
					<button
						type="button"
						onclick={() => (allcourses_more = !allcourses_more)}
						class="flex cursor-pointer items-center gap-1.5 rounded-xl border border-gray-300/70 bg-[#ffffff] px-5 py-2.5 text-sm font-bold text-[#443210] shadow-sm transition-all hover:bg-[#443210] hover:text-white hover:shadow-md"
					>
						{#if allcourses_more}
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
									d="m4.5 15.75 7.5-7.5 7.5 7.5"
								/>
							</svg>
							ซ่อนรายวิชาบางส่วน
						{:else}
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
							ดูรายวิชาทั้งหมดเพิ่มเติม
						{/if}
					</button>
				</div>
			{/if}
		</section>
	</div>
</div>

{#if job_skill_Modal}
	<div class="transition:fade fixed inset-0 z-50 flex items-center justify-center bg-black/60">
		<div class="w-full max-w-md rounded-2xl border border-gray-700 bg-white p-8 shadow-2xl">
			<h2 class="pb-6 text-center text-xl font-bold text-amber-950">ทักษะที่ต้องมี</h2>
			{#if boxinfo}
				<h1 class="mb-3 rounded-2xl border border-amber-800 bg-amber-200 p-2 text-center font-bold">
					{boxinfo}
				</h1>
			{/if}

			{#each selectedJobSkills as item, i (i)}
				<div
					class="group mb-3 rounded-xl border border-amber-500/60 bg-[#ffffff] p-4 shadow-sm transition-all hover:-translate-y-1 hover:shadow-md"
				>
					<div class="flex items-center justify-between gap-3">
						<p class="text-base font-bold text-[#443210] transition-colors md:text-lg">
							{item.skill_name}
						</p>

						<div
							class="shrink-0 rounded-full bg-[#443210] px-3 py-1 text-[10px] font-bold text-[#dca11d] transition-colors group-hover:bg-[#dca11d] group-hover:text-[#443210] md:text-xs"
						>
							Level: {item.level_skill}
						</div>
					</div>
				</div>
			{/each}

			<button
				onclick={() => (job_skill_Modal = false)}
				class="mt-4 w-full cursor-pointer text-sm text-gray-500">ยกเลิก</button
			>
		</div>
	</div>
{/if}

{#if jobs_more}
	<div class="fixed inset-0 z-40 flex items-center justify-center bg-black/60 p-4">
		<div
			class="relative w-full max-w-sm rounded-[24px] bg-[#ffffff] p-6 shadow-2xl sm:max-w-md md:max-w-lg"
		>
			<button
				type="button"
				onclick={() => (jobs_more = false)}
				class="absolute top-5 right-5 cursor-pointer text-gray-500 transition-colors hover:text-gray-800"
				aria-label="ปิดหน้าต่าง"
				title="ปิดหน้าต่าง"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					fill="none"
					viewBox="0 0 24 24"
					stroke-width="1.5"
					stroke="currentColor"
					class="h-6 w-6"
				>
					<path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
				</svg>
			</button>

			<h2 class="pt-6 pb-6 text-center text-lg font-bold text-[#443210] sm:pt-0 sm:text-2xl">
				อาชีพที่เรียนจบแล้วสามารถเป็นได้
			</h2>

			{#if boxinfo}
				<h1
					class="mb-3 rounded-xl border border-amber-800 bg-amber-200 p-2 text-center text-sm font-bold text-amber-950"
				>
					{boxinfo}
				</h1>
			{/if}

			<div class="scrollbar-thin flex max-h-[60vh] flex-col gap-3 overflow-y-auto pr-1">
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
						<button type="submit" class=" group flex w-full cursor-pointer items-center gap-3">
							<div
								class="group w-full cursor-pointer rounded-[14px] border border-[#f0ac2c] bg-[#ffffff] p-4 shadow-sm transition-all hover:shadow-amber-500"
							>
								<div class="flex items-center justify-between gap-3">
									<p class="font-bold text-[#443210] transition-colors md:text-lg">
										{item.name_job}
									</p>

									<div
										class="shrink-0 rounded-full bg-[#443210] px-3 py-1 text-[10px] font-bold text-[#dca11d] transition-colors group-hover:bg-[#dca11d] group-hover:text-[#443210] md:text-xs"
									>
										Level: {item.level_skill}
									</div>
								</div>
							</div>
						</button>
					</form>
				{/each}
			</div>

			<!-- <button
                type="button"
                onclick={() => (jobs_more = false)}
                class="mt-6 w-full cursor-pointer text-sm font-medium text-gray-500 transition-colors hover:text-gray-800"
            >
                ยกเลิก
            </button> -->
		</div>
	</div>
{/if}

<style>
	.btn:hover {
		box-shadow:
			0 20px 25px -5px rgba(220, 161, 29, 0.4),
			0 8px 10px -6px rgba(220, 161, 29, 0.2);
		translate: 0 -5px; /* ขยับขึ้นข้างบน 5px */
		transition: all 0.3s ease; /* เพิ่มความนุ่มนวล */
	}

	/* CSS เพิ่มเติมสำหรับ Modal */
	.modal-content {
		animation: modalScaleIn 0.3s ease-out; /* เพิ่ม Effect ค่อยๆ ขยายตอนเปิด */
	}

	/* CSS สำหรับ Hover Effect บนรายการทักษะ */
	.skill-item:hover {
		background-color: #443210;
		cursor: default;
		box-shadow: 2px 3px 6px rgba(129, 64, 0, 0.5);
	}

	/* Keyframes สำหรับ Effect การขยาย */
	@keyframes modalScaleIn {
		from {
			opacity: 0;
			transform: scale(0.9);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}
</style>
