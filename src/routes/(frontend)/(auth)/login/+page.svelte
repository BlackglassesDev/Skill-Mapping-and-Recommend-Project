<script>
	import { goto , invalidateAll } from '$app/navigation';
	import { resolve } from '$app/paths';

	let username = $state('');
	let password = $state('');
	let message = $state('');

	const home = resolve('/home');
	const regis = resolve('/register');

	/** @param {any} e */
	const handleLogin = async (e) => {
		e.preventDefault();

		const res = await fetch('/api/auth/login', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({
				username: username,
				password: password
			})
		});

		const data = await res.json();
		if (res.ok) {
			message = data.message;
			await invalidateAll();
			setTimeout(() => {
				goto(home);
			}, 1300);
		} else {
			message = data.message || 'เกิดข้อผิดพลาดไม่สามารถเข้าสู่ระบบได้';
		}
	};

	let showModal = $state(false);
	let step = $state(1);
	let email = $state('');
	let otp = $state('');
	let newPassword = $state('');
	let boxinfo = $state('');

	async function sendOTP() {
		const res = await fetch('/api/auth/send-otp', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({ email })
		});

		const data = await res.json();
		if (res.ok) {
			step = 2;
			boxinfo = '';
		} else boxinfo = data.boxinfo || 'เกิดข้อผิดพลาด ไม่สามารถดำเนินการต่อได้';
	}

	async function verifyOTP() {
		const res = await fetch('/api/auth/verify-otp', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({ otp })
		});

		const data = await res.json();
		if (res.ok) {
			step = 3;
			boxinfo = '';
		}else boxinfo = data.boxinfo || 'ตรวจสอบรหัสผ่านไม่สำเร็จ';
	}

	async function resetPassword() {
		const res = await fetch('/api/auth/reset-password',{
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({newPassword , email})
        });

        const data = await res.json();
        if(res.ok){
            boxinfo = data.boxinfo;
            setTimeout(() => {
                showModal = false;
            }, 1500);
        }else boxinfo = data.boxinfo || 'ดำเนินการไม่สำเร็จ';
	}
</script>

<svelte:head><title>เข้าสู่ระบบ</title></svelte:head>

<article class="flex min-h-screen items-center justify-center p-4">
	<article
		class="w-full max-w-lg overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-xl"
	>
		<header class="bgcolor-uni flex items-baseline justify-between gap-3 p-6 text-2xl">
			<span class="font-bold text-amber-400">Skill Mapping</span>
			<span class="font-bold text-white">เข้าสู่ระบบ</span>
		</header>

		{#if message}
			<h1 class="m-2 rounded-2xl border border-amber-800 bg-amber-200 p-2 text-center font-bold">
				{message}
			</h1>
		{/if}

		<form onsubmit={handleLogin}>
			<section class="p-8">
				<label for="user" class="text-md font-semibold text-slate-700">ชื่อผู้ใช้งาน</label>
				<input
					type="text"
					placeholder="StudentRMUTL"
					id="user"
					bind:value={username}
					required
					class="mt-3 mb-5 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>
				<label for="pass" class="text-md font-semibold text-slate-700">รหัสผ่าน</label>
				<input
					type="password"
					placeholder="รหัสผ่านของคุณ"
					id="pass"
					bind:value={password}
					required
					class="mt-3 mb-3 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>

				<article>
					<button
						type="button"
						onclick={() => (showModal = true)}
						class="cursor-pointer font-bold text-amber-900">ลืมรหัสผ่าน ?</button
					>
				</article>

				<button
					type="submit"
					class="btn-submit bgcolor-uni mt-6 w-full cursor-pointer rounded-lg py-1 text-2xl font-bold text-amber-400 shadow-md transition-all hover:bg-amber-800 active:scale-[0.98]"
				>
					เข้าสู่ระบบ
				</button>
			</section>
		</form>

		<div class="text-md pb-2.5 text-center text-amber-950">
			<span>ยังไม่มีบัญชีผู้ใช้งาน ?</span>
			<a href={regis} class="text-amber-400">สมัครเลย!</a>
		</div>
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
				<p class="mb-4 text-gray-400">กรอกอีเมลเพื่อรับรหัสยืนยัน</p>
				<input
					type="email"
					bind:value={email}
					placeholder="StudentRmutl@live.rmutl.ac.th"
					class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>
				<button
					onclick={sendOTP}
					class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400 hover:bg-amber-500"
					>ส่งรหัสยืนยัน</button
				>
			{:else if step === 2}
				<p class="mb-4 text-gray-400">กรอกรหัส 6 หลักที่ได้รับในอีเมล</p>
				<input
					type="text"
					bind:value={otp}
					maxlength="6"
					class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>
				<button
					onclick={verifyOTP}
					class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400"
					>ตรวจสอบรหัส</button
				>
			{:else if step === 3}
				<p class="mb-4 text-gray-400">ตั้งรหัสผ่านใหม่</p>
				<input
					type="password"
					bind:value={newPassword}
					placeholder="รหัสผ่านใหม่ 8 หลัก"
					class="mb-2 w-full rounded-lg border border-slate-500 p-3 text-amber-900 transition outline-none focus:border-amber-600 focus:ring-2 focus:ring-amber-100"
				/>
				<button
					onclick={resetPassword}
					class="bgcolor-uni btn-submit w-full cursor-pointer rounded-xl py-3 font-bold text-amber-400"
					>ยืนยันรหัสใหม่</button
				>
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
