<script>
    import { goto } from '$app/navigation';
    import { resolve } from '$app/paths';

    /** @type {{ data: { curriculum: any[], user: any } }} */
    let { data } = $props();

    // บังคับให้เป็น Array เสมอเพื่อป้องกัน Error .length (คงตรรกะสำคัญไว้ทั้งหมด)
    let curriculum = $derived(Array.isArray(data.curriculum) ? data.curriculum : []);
    // let user = $derived(data.user);

    const steps = [
        { icon: '🎯', text: 'รู้จักตัวเอง' },
        { icon: '🔍', text: 'วิเคราะห์ช่องว่าง' },
        { icon: '💡', text: 'แนะนำรายวิชา' }
    ];

    /** @param {string} id */
    async function send_to_home(id) {
        const home = resolve(`/home?curriculum=${id}`);
        goto(home);
    }
</script>

<svelte:head>
    <title>Skill Mapping | RMUTL</title>
</svelte:head>

<div class="min-h-screen bg-gradient-to-b from-amber-50/40 via-gray-50 to-gray-100/50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] py-12 md:py-20">
    <div class="mx-auto max-w-6xl space-y-16 px-4">
        
        <div class="flex justify-center">
            <img
                src="/img/rmutl20_logo.webp"
                alt="มหาวิทยาลัยเทคโนโลยีราชมงคลล้านนา"
                class="w-56 md:w-64 rounded-xl drop-shadow-sm"
            />
        </div>

        <section class="space-y-6 text-center max-w-3xl mx-auto">
            <h1 class="text-3xl font-extrabold tracking-tight text-[#443210] sm:text-4xl md:text-5xl leading-tight">
                เตรียมความพร้อมทักษะ <br />
                <span class="bg-gradient-to-r from-[#443210] to-[#dca11d] bg-clip-text text-transparent">และเส้นทางอาชีพของคุณ</span>
            </h1>
            <p class="text-base text-gray-600 max-w-xl mx-auto font-medium">
                สำรวจอาชีพในสายงาน และประเมินช่องว่างทักษะของคุณ อ้างอิงตามโครงสร้างหลักสูตร มทร.ล้านนา
            </p>

            <div class="flex flex-wrap justify-center gap-8 pt-12 md:gap-16">
                {#each steps as step (step.text)}
                    <div class="flex flex-col items-center gap-4 group/step">
                        <div class="flex h-28 w-28 items-center justify-center rounded-full bg-white text-[#443210] shadow-[0_10px_30px_rgba(68,50,16,0.06)] ring-1 ring-gray-100 transition-all duration-500 group-hover/step:-translate-y-2 group-hover/step:shadow-[0_20px_40px_rgba(220,161,29,0.2)] group-hover/step:ring-2 group-hover/step:ring-[#dca11d]/50 md:h-32 md:w-32">
                            <span class="text-4xl transition-transform duration-500 group-hover/step:scale-110 md:text-5xl">
                                {step.icon}
                            </span>
                        </div>
                        <span class="text-sm font-bold text-[#443210]/90 md:text-base tracking-wide transition-colors group-hover/step:text-[#dca11d]">
                            {step.text}
                        </span>
                    </div>
                {/each}
            </div>
        </section>

        <section class="space-y-6">
            <h2 class="flex items-center gap-2 text-xl font-bold text-[#443210] md:text-2xl">
                <span class="text-2xl">📖</span> เลือกดูหลักสูตรเพื่อเริ่มต้น
            </h2>
            
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
                {#if curriculum.length === 0}
                    <div class="col-span-full rounded-2xl border-2 border-dashed border-gray-200 bg-white p-12 text-center shadow-sm">
                        <p class="font-medium text-gray-400">เกิดข้อผิดพลาด ไม่พบข้อมูลหลักสูตรในขณะนี้</p>
                    </div>
                {/if}

                {#each curriculum as curriculums (curriculums.curriculum_id)}
                    <button
                        type="button"
                        onclick={() => send_to_home(curriculums.curriculum_id)}
                        class="group btn flex h-full cursor-pointer flex-col justify-between rounded-2xl border border-gray-200/80 bg-white p-6 text-left shadow-sm transition-all duration-300 hover:border-[#DCA11D]/40"
                    >
                        <div class="flex w-full flex-1 flex-col items-center">
                            <div class="mb-4 flex h-20 w-full items-center justify-center rounded-xl bg-gray-50/50 p-2 border border-gray-100 transition-colors group-hover:bg-amber-50/30">
                                <img
                                    class="h-full max-w-[100px] object-contain opacity-80 group-hover:opacity-100 transition-opacity"
                                    src="/img/rmutl20_logo.webp"
                                    alt="pic_curriculum"
                                />
                            </div>

                            <span class="mb-4 text-center text-base font-bold break-words text-[#443210]/90 transition-colors group-hover:text-[#dca11d] line-clamp-3 leading-snug">
                                {curriculums.curriculum_name}
                            </span>
                        </div>

                        <div class="mt-auto w-full border-t border-gray-100 pt-3 flex justify-center">
                            <span class="text-xs text-amber-700 font-semibold opacity-0 group-hover:opacity-100 transition-all transform translate-y-1 group-hover:translate-y-0 flex items-center gap-1">
                                เข้าสู่ระบบ Skill Mapping ➔
                            </span>
                        </div>
                    </button>
                {/each}
            </div>
        </section>
    </div>
</div>

<style>
    /* อนิเมชันล็อกอินการโฮเวอร์การ์ดระบบ มอบฟีลเดียวกับหน้าแรก */
    .btn:hover {
        box-shadow: 0 15px 30px -5px rgba(220, 161, 29, 0.15);
        transform: translateY(-4px);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
</style>