import { redirect, fail } from '@sveltejs/kit';

export async function load({ locals }) {
	if (locals.user) {
		throw redirect(302, '/home');
	}
	return {};
}

// let email = $state('');

export const actions = {
	login: async ({ request, fetch }) => {
		const data = await request.formData();
		const username = data.get('username');
		const password = data.get('password');

		try {
			const res = await fetch('/api/auth/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({
					username: username,
					password: password
				})
			});

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status, {
					success: false,
					message: result.message
				});
			}
			return { success: true, message: result.message };
		} catch (error) {
			console.error(error);
			return fail(500, {
				success: false,
				message: 'การเชื่อมต่อขัดข้อง'
			});
		}
	},

	sendOTP: async ({ request, fetch }) => {
		const data = await request.formData();
		const email = data.get('email');

		try {
			const res = await fetch('/api/auth/send-otp', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ email })
			});

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status, {
					success: false,
					boxinfo: result.boxinfo
				});
			}
			return { success: true, boxinfo: result.boxinfo };
		} catch (error) {
			console.error(error);
			return fail(500, {
				success: false,
				boxinfo: 'การเชื่อมต่อขัดข้อง'
			});
		}
	},

	verifyOTP: async ({ request, fetch }) => {
		const data = await request.formData();
		const otp = data.get('otp');

		try {
			const res = await fetch('/api/auth/verify-otp', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ otp })
			});

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status, {
					success: false,
					boxinfo: result.boxinfo || 'ตรวจสอบรหัสผ่านไม่สำเร็จ'
				});
			}
			return { success: true, boxinfo: result.boxinfo };
		} catch (error) {
			console.error(error);
			return fail(500, {
				boxinfo: 'การเชื่อมต่อขัดข้อง',
				success: false
			});
		}
	},

	resetpass: async ({ request, fetch }) => {
		const data = await request.formData();
		const email = data.get('email');
		const newPassword = data.get('newPassword');

		try {
			const res = await fetch('/api/auth/reset-password', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ newPassword, email })
			});

			const result = await res.json();
			if (!res.ok) {
				return fail(res.status, {
					boxinfo: result.boxinfo || 'ดำเนินการไม่สำเร็จ',
					success: false
				});
			}
			return { success: true, boxinfo: result.boxinfo };
		} catch (error) {
			console.error(error);
			return fail(500,{
                success: false,
                boxinfo: 'การเชื่อมต่อขัดข้อง'
            })
		}
	}
};
