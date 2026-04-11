-- Realtime'ı aktif etmek için çalıştırın
-- Supabase SQL Editor'a yapıştırın

ALTER PUBLICATION supabase_realtime ADD TABLE uys_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_work_orders;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_orders;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_stok_hareketler;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_operator_notes;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_active_work;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_fire_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_tedarikler;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_sevkler;
ALTER PUBLICATION supabase_realtime ADD TABLE uys_kesim_planlari;
