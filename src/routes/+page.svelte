<script>
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	/** @type {{ data: { courses: any[], user: any } }} */
	let { data } = $props();

	// บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length
	let courses = $derived(Array.isArray(data.courses) ? data.courses : []);
	// let user = $derived(data.user);
	let job_skill_Modal = $state(false);
	let selectedJobSkills = $state([]); // ตัวแปรเก็บรายการ Skill ที่ดึงมา
	let selectedJobName = $state(''); // เก็บชื่ออาชีพเพื่อโชว์บนหัว Modal

	// ข้อมูลจำลองสำหรับวนลูป
	const steps = [
		{ icon: '🎯', text: 'รู้จักตัวเอง' },
		{ icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
		{ icon: '💡', text: 'แนะนำรายวิชา' }
	];

	const jobs = [
		{ id: 1, name: 'วิศวกรปัญญาประดิษฐ์และข้อมูล' },
		{ id: 2, name: 'วิศวกรสมองกลฝังตัวและไอโอที' },
		{ id: 3, name: 'ผู้ดูแลระบบเครือข่ายและคลาวด์' },
		{ id: 4, name: 'นักพัฒนาซอฟต์แวร์' },
		{ id: 5, name: 'วิศวกรรมคอมพิวเตอร์' }
	];

	/** @param {string} id */
	async function info_subject(id) {
		const info = resolve(`/info_subject?id=${id}`);
		goto(info);
	}

	async function call_job(id) {
		try {
			const res = await fetch('/api/job_skill', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ id })
			});

			const data = await res.json();
			if (res.ok) {
				job_skill_Modal = true;
			}
		} catch (error) {
			console.error(error);
		}
	}
</script>

<svelte:head><title>Skill Mapping | RMUTL | Home</title></svelte:head>

<div
	class="min-h-screen bg-slate-50 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"
>
	<div class="mx-auto max-w-6xl space-y-24 px-4 py-16 md:py-24">
		<section class="space-y-6 text-center">
			<h1 class="text-3xl font-extrabold text-[#443210] drop-shadow-sm md:text-5xl">
				เตรียมความพร้อมทักษะ <br /> และเส้นทางอาชีพของคุณ
			</h1>
			<p class="mx-auto max-w-2xl text-base text-gray-600 md:text-lg">
				สำรวจอาชีพในสายงาน และประเมินช่องว่างทักษะของคุณ อ้างอิงตามหลักสูตร มทร.ล้านนา
			</p>

			<div class="mt-8 flex justify-center">
				<a
					href="/job"
					class="group inline-flex items-center gap-2 rounded-full bg-[#dca11d] px-8 py-3.5 text-lg font-bold text-[#443210] shadow-lg transition-all duration-300 hover:-translate-y-1 hover:bg-[#eab308] hover:shadow-xl"
				>
					เริ่มสำรวจอาชีพเลย
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="2.5"
						stroke="currentColor"
						class="size-5 transition-transform group-hover:translate-x-1"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"
						/>
					</svg>
				</a>
			</div>

			<div class="flex flex-wrap justify-center gap-8 pt-12 md:gap-20">
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

		<section
			class="space-y-8 rounded-3xl bg-white p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] ring-1 ring-slate-100 md:p-12"
		>
			<h2 class="text-2xl font-bold text-[#443210] md:text-3xl">เรียนจบแล้วเป็นอะไรได้บ้าง ?</h2>
			<div class="grid grid-cols-1 gap-5 md:grid-cols-2">
				{#each jobs as job (job.id)}
					<button
						type="button"
						onclick={() => call_job(job.id)}
						class="group flex items-center gap-4 rounded-xl border border-transparent bg-slate-50 p-2 pr-6 transition-all duration-300 hover:-translate-y-1 hover:border-[#dca11d]/30 hover:bg-[#dca11d]/5 hover:shadow-md"
					>
						<div
							class="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-[#443210] font-bold text-[#dca11d] shadow-sm transition-colors group-hover:bg-[#dca11d] group-hover:text-[#443210]"
						>
							{job.id}
						</div>
						<div class="flex-1 text-left font-bold text-[#443210]">
							{job.name}
						</div>
					</button>
				{/each}
				<div class="flex items-center justify-end pt-2 pr-2">
					<a
						href="/job"
						class="group flex items-center gap-1 text-sm font-bold text-gray-500 transition-colors hover:text-[#dca11d]"
					>
						ดูอาชีพทั้งหมด
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="2"
							stroke="currentColor"
							class="size-4 transition-transform group-hover:translate-x-1"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
						</svg>
					</a>
				</div>
			</div>
		</section>

		<section class="space-y-8">
			<h2 class="flex items-center gap-3 text-2xl font-bold text-[#443210] md:text-3xl">
				รายวิชาในหลักสูตร 📖
			</h2>
			<div class="grid grid-cols-2 gap-4 sm:grid-cols-2 md:gap-6 lg:grid-cols-4">
				{#if courses.length == 0}
					<div
						class="col-span-full rounded-2xl border-2 border-dashed border-gray-300 bg-white py-16 text-center"
					>
						<p class="text-lg text-gray-500">ไม่พบรายวิชาในหลักสูตรของคุณ</p>
					</div>
				{/if}

				{#each courses as course (course.course_id)}
					<button
						type="button"
						onclick={() => info_subject(course.course_id)}
						class="btn flex cursor-pointer flex-col justify-between rounded-2xl border border-[#c58f1a] bg-gradient-to-br from-[#eab308] to-[#dca11d] p-6 text-left shadow-lg transition-all duration-300"
					>
						<div class="mb-4">
							<h3 class="mb-2 text-xl font-black text-[#443210] drop-shadow-sm">
								{course.course_code}
							</h3>
							<p class="line-clamp-2 text-sm font-semibold text-[#443210]/90">
								{course.course_name}
							</p>
						</div>
						<div class="w-full border-t border-[#443210]/20 pt-3">
							<span class="text-[10px] font-bold tracking-wider text-white/80 uppercase"
								>Skills Covered</span
							>
							<p class="text-xs font-medium text-white shadow-black/10 drop-shadow-sm">111111</p>
						</div>
					</button>
				{/each}
			</div>
		</section>
	</div>
</div>

<style>
	/* ปรับแต่ง CSS เดิมให้ลอยเนียนขึ้น */
	.btn:hover {
		box-shadow:
			0 20px 25px -5px rgba(220, 161, 29, 0.4),
			0 8px 10px -6px rgba(220, 161, 29, 0.2);
		transform: translateY(-6px);
	}
</style>
