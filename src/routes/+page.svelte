<script>
	import './layout.css';
	import { resolve } from '$app/paths';

	const test = resolve('/');

    const steps = [
		{ icon: '🎯', text: 'รู้จักตัวเอง' },
		{ icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
		{ icon: '💡', text: 'แนะนำรายวิชา' }
	];

</script>

<svelte:head><title>RMUTL | Skill Mapping</title></svelte:head>

<div class="mx-auto max-w-6xl space-y-20 px-4 py-10 md:py-16">
	<div class="flex justify-center">
		<img src="/img/rmutl20_logo.webp" alt="มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา" class="rounded-lg w-40">
	</div>
	<section class="space-y-4 text-center">
		<h1 class="text-2xl font-bold text-[#443210] md:text-4xl">
			เตรียมความพร้อมทักษะ <br> และเส้นทางอาชีพของคุณ
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

    <section>
        
    </section>
</div>
