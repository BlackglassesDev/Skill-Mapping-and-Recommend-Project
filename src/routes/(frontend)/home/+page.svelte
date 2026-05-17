<script>
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	/** @type {{ data: { courses: any[], jobs: any[], user: any } }} */
	let { data } = $props();

	// บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length
	let courses = $derived(Array.isArray(data.courses) ? data.courses.slice(0.8) : []);
	let allcourses = $derived(Array.isArray(data.courses) ? data.courses : []);
	let jobs = $derived(Array.isArray(data.jobs) ? data.jobs.slice(0, 5) : []);
	let alljobs = $derived(Array.isArray(data.jobs) ? data.jobs : []);
	let boxinfo = $state('');
	let job_skill_Modal = $state(false);
	let jobs_more = $state(false);
	/** @type {any[]} */
	let selectedJobSkills = $state([]); // ตัวแปรเก็บรายการ Skill ที่ดึงมา

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
				<div class="flex flex-col items-center gap-3">
					<div
						class="flex h-24 w-24 items-center justify-center rounded-full border-4 border-[#443210] bg-white shadow-lg md:h-32 md:w-32"
					>
						<span class="text-3xl md:text-4xl">{step.icon}</span>
					</div>
					<span class="text-sm font-bold text-[#443210] md:text-base">{step.text}</span>
				</div>
			{/each}
		</div>
	</section>

	<section class="space-y-8">
		<h2 class="text-xl font-bold text-[#443210] md:text-2xl">เรียนจบแล้วเป็นอะไรได้บ้าง ?</h2>
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			{#if jobs.length == 0}
				<div class="col-span-full rounded-xl border-2 border-dashed bg-gray-100 p-10 text-center">
					<p class="text-gray-500">ไม่พบข้อมูลอาชีพ</p>
				</div>
			{/if}
			{#each jobs as job (job.job_id)}
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
					<input type="hidden" name="id" value={job.job_id} />
					<button type="submit" class=" group flex w-full cursor-pointer items-center gap-3">
						<div
							class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-[#443210] font-bold text-[#dca11d] shadow-md"
						>
							{job.job_id}
						</div>
						<div
							class="flex-1 cursor-pointer rounded-lg bg-[#dca11d] px-5 py-3 font-bold text-[#443210] shadow transition-transform hover:translate-x-1"
						>
							{job.name_job}
						</div>
					</button>
				</form>
			{/each}
			{#if jobs.length > 0}
				<div class="flex items-center justify-end">
					<button
						type="button"
						onclick={() => (jobs_more = true)}
						class="text-sm font-bold text-[#443210] hover:underline">ดูเพิ่มเติม</button
					>
				</div>
			{/if}
		</div>
	</section>

	<section class="space-y-8">
		<h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
			รายวิชาในหลักสูตร 📖
		</h2>
		<div class="grid grid-cols-2 gap-4 sm:grid-cols-2 md:grid-cols-4">
			<!-- ถ้าไม่มีรายวิชา -->
			{#if courses.length == 0}
				<div class="rounded-xl border-2 border-dashed bg-gray-100 p-10 text-center">
					<p class="text-gray-500">ไม่พบรายวิชาในหลักสูตรของคุณ</p>
				</div>
			{/if}

			{#each courses as course (course.course_id)}
				<button
					type="button"
					onclick={() => info_subject(course.course_id)}
					class="btn cursor-pointer rounded-xl border border-[#c58f1a] bg-[#dca11d] p-5 shadow-md transition-shadow hover:shadow-lg"
				>
					<div class="mb-3">
						<h3 class="text-lg leading-tight font-bold text-[#443210]">{course.course_code}</h3>
						<p class="h-10 overflow-hidden text-sm leading-tight font-medium text-[#443210]">
							{course.course_name}
						</p>
					</div>
					<div class="border-t border-[#443210]/20 pt-2">
						<span class="text-[10px] font-bold text-[#ffff]/70 uppercase">Skills</span>
						<p class="text-xs leading-tight font-light text-[#ffff] italic">111111</p>
					</div>
				</button>
			{/each}
		</div>
	</section>
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
					class="group mb-3 rounded-xl border-b-2 border-[#443210]/20 bg-[#dca11d] p-4 shadow-sm transition-all hover:bg-[#443210]"
				>
					<div class="flex items-center justify-between gap-3">
						<p
							class="text-base font-bold text-[#443210] transition-colors group-hover:text-white md:text-lg"
						>
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
		box-shadow: 2px 3px 6px rgba(129, 64, 0, 0.765);
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
