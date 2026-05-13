-- SQL to setup Payment Proof functionality in Supabase

-- 1. Update orders table to include paymentProofUrl
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS "paymentProofUrl" TEXT;

-- 2. Storage Policies for 'orders' bucket (Bukti Pembayaran)
-- Ensure the bucket 'orders' is created and set to Public in the Supabase Dashboard first.

DROP POLICY IF EXISTS "Public Access Orders" ON storage.objects;
CREATE POLICY "Public Access Orders" ON storage.objects FOR SELECT USING (bucket_id = 'orders');

DROP POLICY IF EXISTS "Authenticated Upload Orders" ON storage.objects;
CREATE POLICY "Authenticated Upload Orders" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'orders' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated Update Orders" ON storage.objects;
CREATE POLICY "Authenticated Update Orders" ON storage.objects FOR UPDATE USING (bucket_id = 'orders' AND auth.role() = 'authenticated');
