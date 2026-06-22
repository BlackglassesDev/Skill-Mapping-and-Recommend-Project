<script>
	import { enhance } from '$app/forms';
	import { goto, invalidateAll } from '$app/navigation';
	import { resolve } from '$app/paths';

	const home = resolve('/home');
	const regis = resolve('/register');

	let showModal = $state(false);
	let step = $state(1);
	let backup_email = $state('');
	let boxinfo = $state('');
	let message = $state('');
	let isloading = $state(false);
</script>

<svelte:head><title>เข้าสู่ระบบ</title></svelte:head>

<article
	class="flex min-h-screen items-center justify-center bg-gradient-to-b from-gray-50/50 to-gray-100/30 bg-[linear-gradient(to_right,#80808012_1px,transparent_1px),linear-gradient(to_bottom,#80808012_1px,transparent_1px)] bg-[size:24px_24px] p-4"
>
	<article
		class="w-full max-w-lg overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-xl"
	>
		<header
			class="bgcolor-uni flex items-center justify-between gap-3 p-4 text-lg sm:p-6 sm:text-xl md:text-2xl"
		>
			<div class="flex items-center gap-2 sm:gap-3">
				<a
					href={home}
					class="text-white transition-transform hover:scale-110 hover:text-amber-400"
					title="กลับหน้าหลัก"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
						stroke-width="2"
						stroke="currentColor"
						class="h-7 w-7"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							d="m11.25 9-3 3m0 0 3 3m-3-3h7.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
						/>
					</svg>
				</a>

				<span class="font-bold whitespace-nowrap text-amber-400">Skill Mapping</span>
			</div>
			<span class="font-bold whitespace-nowrap text-white">เข้าสู่ระบบ</span>
		</header>

		{#if message}
			<h1 class="m-2 rounded-2xl border border-amber-800 bg-amber-200 p-2 text-center font-bold">
				{message}
			</h1>
		{/if}

		<form
			method="POST"
			action="?/login"
			use:enhance={() => {
				isloading = true;
				message = 'กำลังตรวจสอบข้อมูล...';

				return async ({ result }) => {
					if (result.type === 'success') {
						// @ts-ignore
						message = result.data?.message;

						setTimeout(async () => {
							await invalidateAll();
							goto(home);
						}, 1000);
					} else {
						// @ts-ignore
						message = result.data?.message || 'เกิดข้อผิดพลาด';
						isloading = false;
					}
				};
			}}
		>
			<section class="p-8">
				<label for="user" class="text-md font-semibold text-slate-700">ชื่อผู้ใช้งาน</label>
				<input
					type="text"
					placeholder="StudentRMUTL"
					id="user"
					name="username"
					required
					class="mt-3 mb-5 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>
				<label for="pass" class="text-md font-semibold text-slate-700">รหัสผ่าน</label>
				<input
					type="password"
					placeholder="รหัสผ่านของคุณ"
					id="pass"
					name="password"
					required
					class="mt-3 mb-3 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>

				<button
					type="submit"
					disabled={isloading}
					class="btn-submit bgcolor-uni mt-2 mb-4 w-full cursor-pointer rounded-lg py-3 text-2xl font-bold text-amber-400 shadow-md transition-all hover:bg-amber-800 active:scale-[0.98] disabled:scale-100 disabled:cursor-not-allowed disabled:opacity-50 disabled:grayscale"
				>
					{#if isloading}
						กำลังประมวลผล...
					{:else}
						เข้าสู่ระบบ
					{/if}
				</button>
				<div class="mt-2 flex w-full items-center justify-between">
					<a
						href={regis}
						class="font-bold text-amber-900 underline transition hover:text-amber-600"
					>
						ลงทะเบียน
					</a>

					<button
						type="button"
						onclick={() => (showModal = true)}
						class="flex cursor-pointer items-center gap-1 font-bold text-amber-900 transition hover:text-amber-600"
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							fill="none"
							viewBox="0 0 24 24"
							stroke-width="1.5"
							stroke="currentColor"
							class="size-5"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z"
							/>
						</svg>
						ลืมรหัสผ่าน
					</button>
				</div>
			</section>
		</form>
	</article>
</article>

{#if showModal}
	<div class="transition:fade fixed inset-0 z-50 flex items-center justify-center bg-black/60">
		<div class="w-full max-w-md rounded-2xl border border-gray-700 bg-white p-8 shadow-2xl">
			<h2 class="mb-6 text-xl font-bold text-amber-950">กู้คืนรหัสผ่าน</h2>
			{#if boxinfo}
				<h1 class="rounded-2xl border border-amber-800 bg-amber-200 p-2 text-center font-bold">
					{boxinfo}
				</h1>
			{/if}

			{#if step === 1}
				<form
					method="POST"
					action="?/sendOTP"
					use:enhance={() => {
						isloading = true;
						boxinfo = 'กำลังดำเนินการ';

						return async ({ result }) => {
							if (result.type === 'success') {
								// @ts-ignore
								boxinfo = result.data?.boxinfo;
								step = 2;
								isloading = false;
								boxinfo = '';
							} else {
								// @ts-ignore
								boxinfo = result.data?.boxinfo || 'ส่งไม่สำเร็จ';
								isloading = false;
							}
						};
					}}
				>
					<p class="mb-4 text-gray-400">กรอกอีเมลเพื่อรับรหัสยืนยัน</p>
					<input
						type="email"
						name="email"
						bind:value={backup_email}
						placeholder="StudentRmutl@live.rmutl.ac.th"
						class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
					<button
						type="submit"
						disabled={isloading}
						class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400 hover:bg-amber-500 active:scale-[0.98] disabled:scale-100 disabled:cursor-not-allowed disabled:opacity-50 disabled:grayscale"
						>{isloading ? 'กำลังส่ง...' : 'ส่งขอรหัสยืนยัน'}</button
					>
				</form>
			{:else if step === 2}
				<form
					method="POST"
					action="?/verifyOTP"
					use:enhance={() => {
						isloading = true;
						boxinfo = 'กำลังดำเนินการ';

						return async ({ result }) => {
							if (result.type === 'success') {
								// @ts-ignore
								boxinfo = result.data?.boxinfo;
								step = 3;
								isloading = false;
								boxinfo = '';
							} else {
								// @ts-ignore
								boxinfo = result.data?.boxinfo || 'ดำเนินการไม่สำเร็จ';
								isloading = false;
							}
						};
					}}
				>
					<p class="mb-4 text-gray-400">กรอกรหัส 6 หลักที่ได้รับในอีเมล</p>
					<input type="hidden" name="email" value={backup_email}>
					<input
						type="text"
						name="otp"
						maxlength="6"
						class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
					<button
						type="submit"
						disabled={isloading}
						class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400 active:scale-[0.98] disabled:scale-100 disabled:cursor-not-allowed disabled:opacity-50 disabled:grayscale"
						>{isloading ? 'กำลังตรวจสอบ..' : 'ตรวจสอบรหัส'}</button
					>
				</form>
			{:else if step === 3}
				<form
					method="POST"
					action="?/resetpass"
					use:enhance={() => {
						isloading = true;
						boxinfo = 'กำลังดำเนินการ';

						return async ({ result }) => {
							if (result.type === 'success') {
								// @ts-ignore
								boxinfo = result.data?.boxinfo;
								setTimeout(() => {
									showModal = false;
									isloading = false;
									boxinfo = '';
								}, 1500);
							} else {
								// @ts-ignore
								boxinfo = result.data?.boxinfo || 'ดำเนินการไม่สำเร็จ';
								isloading = false;
							}
						};
					}}
				>
					<p class="mb-4 text-gray-400">ตั้งรหัสผ่านใหม่</p>
					<input type="hidden" name="email" value={backup_email}>
					<input
						type="password"
						name="newPassword"
						placeholder="รหัสผ่านใหม่ 8 หลัก"
						class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
					/>
					<button
						type="submit"
						disabled={isloading}
						class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400 active:scale-[0.98] disabled:scale-100 disabled:cursor-not-allowed disabled:opacity-50 disabled:grayscale"
						>{isloading? 'กำลังเปลี่ยนรหัสผ่าน...' : 'ยืนยันรหัสใหม่'}</button
					>
				</form>
			{/if}

			<button
				onclick={() => (showModal = false)}
				class="mt-4 w-full cursor-pointer text-sm text-gray-500">ยกเลิก</button
			>
		</div>
	</div>
{/if}

<style>
	.bgcolor-uni {
		background-color: #443210;
	}
	.btn-submit:hover {
		/* background-color: rgb(81, 44, 1); */
		box-shadow: 2px 3px 6px rgba(129, 64, 0, 0.765);
	}
</style>
