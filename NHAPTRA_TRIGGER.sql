CREATE TRIGGER nhaptra_trigger
ON dbo.NHAPTRA_CHITIET
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @thoigian char (6), @sophieu char(10), @mathuoc char(8), @soluong numeric(10,2), @thanhtien numeric(10,0), @makho char(8)
	DECLARE nhaptra_inserted CURSOR FOR
	SELECT Thoigian, Sophieu, Mathuoc, Soluong, Thanhtien
	FROM inserted

	OPEN nhaptra_inserted
		FETCH NEXT FROM nhaptra_inserted
		INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @makho=Makhonhap
				FROM NHAPTRA
				WHERE Thoigian=@thoigian AND Sophieu=@sophieu

				IF NOT EXISTS (
				SELECT *
				FROM TONKHO
				WHERE THOIGIAN=@thoigian and @makho=MAKHO and MATHUOC=@mathuoc)
				BEGIN
				INSERT INTO TONKHO(THOIGIAN, MAKHO, MATHUOC, SLD, TTD, SLN, TTN, SLX, TTX, SLC, TTC)
				VALUES (@thoigian, @makho, @mathuoc, @soluong, @thanhtien, 0, 0, 0, 0, 0, 0)
				END	

				ELSE 
				BEGIN
				UPDATE TONKHO SET SLN=SLN+@soluong, TTN=TTC+@thanhtien
				WHERE THOIGIAN=@thoigian and @makho=MAKHO and MATHUOC=@mathuoc
				END;

				FETCH NEXT FROM nhaptra_inserted
				INTO @thoigian, @sophieu, @mathuoc, @soluong, @thanhtien
			END;

	CLOSE nhaptra_inserted;
	DEALLOCATE nhaptra_inserted;
END;
