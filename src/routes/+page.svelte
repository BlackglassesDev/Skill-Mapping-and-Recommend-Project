<script>
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';

	/** @type {{ data: { curriculum: any[], user: any } }} */
	let { data } = $props();

	// บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length
	let curriculum = $derived(Array.isArray(data.curriculum) ? data.curriculum : []);
	// let user = $derived(data.user);

	// ข้อมูลจำลองสำหรับวนลูป
	const steps = [
		{ icon: '🎯', text: 'รู้จักตัวเอง' },
		{ icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
		{ icon: '💡', text: 'แนะนำรายวิชา' }
	];

	/** @param {string} id */
	async function send_to_home(id) {
		const home = resolve(`/home?id=${id}`);
		goto(home);
	}
</script>

<svelte:head><title>Skill Mapping | RMUTL</title></svelte:head>

<div
	class="min-h-screen bg-slate-50 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px]"
>
	<div class="mx-auto max-w-6xl space-y-6 px-4 py-6">
		<div class="flex justify-center">
			<img
				src="/img/rmutl20_logo.webp"
				alt="มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา"
				class="w-65 rounded-lg"
			/>
		</div>
		<section class="space-y-6 text-center">
			<h1 class="text-2xl font-extrabold text-[#443210] drop-shadow-sm md:text-5xl">
				เตรียมความพร้อมทักษะ <br /> และเส้นทางอาชีพของคุณ
			</h1>
			<p class="mx-auto max-w-2xl text-base text-gray-600 md:text-lg">
				สำรวจอาชีพในสายงาน และประเมินช่องว่างทักษะของคุณ อ้างอิงตามหลักสูตร มทร.ล้านนา
			</p>

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

		<section class="space-y-8">
			<h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
				เลือกดูหลักสูตร 📖
			</h2>
			<div class="grid grid-cols-2 gap-4 sm:grid-cols-2 md:grid-cols-4">
				{#if curriculum.length == 0}
					<div class="col-span-full rounded-xl border-2 border-dashed bg-gray-100 p-10 text-center">
						<p class="text-gray-500">เกิดข้อผิดพลาด ไม่พบหลักสูตร</p>
					</div>
				{/if}

				{#each curriculum as curriculums (curriculums.curriculum_id)}
					<button
						type="button"
						onclick={() => send_to_home(curriculums.curriculum_id)}
						class="btn flex h-full cursor-pointer flex-col justify-between rounded-xl border border-[#f0ac2c] bg-[#ffffff] p-5 text-left shadow-md transition-shadow hover:shadow-lg"
					>
						<div class="flex w-full flex-1 flex-col">
							<div class="mb-3 flex justify-center">
								<img
									class="w-full max-w-[120px] object-contain"
									src="/img/rmutl20_logo.webp"
									alt="pic_curriculum"
								/>
							</div>

							<span
								class="mb-4 line-clamp-3 text-center text-lg font-bold break-words text-amber-500 uppercase"
							>
								{curriculums.curriculum_name}
							</span>
						</div>

						<div class="mt-auto w-full border-t border-[#1d1404]/20 pt-2"></div>
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
