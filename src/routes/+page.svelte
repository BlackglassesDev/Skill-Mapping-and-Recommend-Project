<script>
	import './layout.css';
	import { resolve } from '$app/paths';
	import { goto } from '$app/navigation';

	/** @type {{ data: { curriculum: any[], user: any } }} */
	let { data } = $props();
	let curriculum = $derived(Array.isArray(data.curriculum) ? data.curriculum : []);

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

<svelte:head><title>RMUTL | Skill Mapping</title></svelte:head>

<div class="mx-auto max-w-6xl space-y-20 px-4 py-10 md:py-16">
	<div class="flex justify-center">
		<img
			src="/img/rmutl20_logo.webp"
			alt="มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา"
			class="w-40 rounded-lg"
		/>
	</div>
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
		<h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
			เลือกดูหลักสูตร 📖
		</h2>
		<div class="grid grid-cols-2 gap-4 sm:grid-cols-2 md:grid-cols-4">
			<!-- ถ้าไม่พบหลักสูตร -->
			{#if curriculum.length == 0}
				<div class="rounded-xl border-2 border-dashed bg-gray-100 p-10 text-center">
					<p class="text-gray-500">ไม่พบหลักสูตร การเชื่อมต่ออาจมีปัญหา</p>
				</div>
			{/if}

			{#each curriculum as curriculums (curriculums.curriculum_id)}
				<button
					type="button"
					onclick={() => send_to_home(curriculums.curriculum_id)}
					class="hover-curri cursor-pointer rounded-xl border border-[#c58f1a] bg-[#dca11d] p-5 shadow-md transition-shadow hover:shadow-lg"
				>
					<div class="mb-3">
						<img
							class="w-full leading-tight"
							src="/img/rmutl20_logo.webp"
							alt="pic_curriculum"
						/>
					</div>
					<div class="border-t border-[#443210]/20 pt-2 min-h-[80px] flex justify-center">
						<span class="leading-tight text-center text-lg font-bold text-[#ffff]/70 uppercase"
							>{curriculums.curriculum_name}</span
						>
					</div>
				</button>
			{/each}
		</div>
	</section>
</div>

<style>
	.hover-curri:hover {
		box-shadow: 2px 3px 6px rgba(129, 64, 0, 0.765);
		translate: 0 -5px; /* ขยับขึ้นข้างบน 5px */
		transition: all 0.3s ease; /* เพิ่มความนุ่มนวล */
	}
</style>
