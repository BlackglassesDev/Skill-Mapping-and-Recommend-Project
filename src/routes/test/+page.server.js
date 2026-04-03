import { pool } from '$lib/server/db';

export async function load() {
	console.log('🔥 TEST ENV & DB');

	const [rows] = await pool.query('SELECT 1 as test');

	console.log('DB RESULT:', rows);

	return {
		test: rows
	};
}