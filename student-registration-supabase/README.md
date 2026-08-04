# ระบบลงทะเบียน ปวช./ปวส. — Supabase + GitHub Pages

เว็บ Static แยกหน้า User/Admin ใช้ Supabase เป็นฐานข้อมูลและระบบล็อกอิน จึงเผยแพร่ผ่าน GitHub Pages ได้โดยไม่ต้องมี Node.js server

## ความสามารถ
- User ลงทะเบียน: ชื่อ ชั้น ปวช/ปวส และเลขท้ายนักศึกษา
- User ตรวจสอบคะแนนด้วยชั้นและเลขท้ายนักศึกษา
- Admin เพิ่ม แก้ไข ลบข้อมูล และปรับคะแนน 0–100
- Admin ดาวน์โหลดข้อมูลเป็น CSV ซึ่งเปิดด้วย Excel ได้
- ใช้ Row Level Security (RLS) ป้องกันไม่ให้บุคคลทั่วไปอ่านตารางทั้งหมด
- เก็บหน้า HTML Quest เดิมไว้ที่ `html-quest.html`

## 1. สร้างฐานข้อมูล Supabase
1. สร้าง Project ที่ Supabase
2. ไปที่ **SQL Editor** แล้วคัดลอกทั้งหมดจาก `setup.sql` ไปรัน
3. ไปที่ **Authentication > Users** แล้วสร้างผู้ใช้ Admin ด้วยอีเมลและรหัสผ่าน
4. คัดลอก UUID ของผู้ใช้ Admin
5. กลับไป SQL Editor แล้วรัน:

```sql
insert into public.admins(user_id) values ('UUID_ของผู้ใช้_Admin');
```

## 2. ตั้งค่าเว็บไซต์
ไปที่ **Project Settings > API** แล้วนำ Project URL และ Publishable/anon key ใส่ใน `config.js`

```js
window.APP_CONFIG = {
  SUPABASE_URL: 'https://xxxxx.supabase.co',
  SUPABASE_ANON_KEY: 'ใส่_publishable_หรือ_anon_key'
};
```

ห้ามนำ `service_role` หรือ secret key ใส่ในหน้าเว็บ

## 3. อัปโหลดขึ้น GitHub Pages
1. สร้าง GitHub Repository
2. อัปโหลดไฟล์ทั้งหมดในโฟลเดอร์นี้ไว้ที่ root ของ repository
3. ไปที่ **Settings > Pages**
4. เลือก **Deploy from a branch**
5. เลือก branch `main` และโฟลเดอร์ `/ (root)`
6. เปิด URL GitHub Pages ที่ระบบแสดง

## หมายเหตุด้านความปลอดภัย
- Publishable/anon key เปิดเผยใน browser ได้เมื่อใช้ RLS ตาม `setup.sql`
- Admin ต้องอยู่ในตาราง `admins` เท่านั้นจึงจัดการข้อมูลได้
- บุคคลทั่วไปเรียกดูคะแนนได้ทีละรายการผ่าน RPC แต่ไม่สามารถอ่านรายชื่อทั้งหมดโดยตรง
