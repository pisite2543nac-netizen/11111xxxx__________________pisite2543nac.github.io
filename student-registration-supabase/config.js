// นำค่าจาก Supabase Dashboard > Project Settings > API มาใส่ที่นี่
// Publishable/anon key สามารถใช้ในหน้าเว็บได้เมื่อเปิด RLS ตาม setup.sql แล้ว
window.APP_CONFIG = {
  SUPABASE_URL: 'https://YOUR_PROJECT_ID.supabase.co',
  SUPABASE_ANON_KEY: 'YOUR_PUBLISHABLE_OR_ANON_KEY'
};
