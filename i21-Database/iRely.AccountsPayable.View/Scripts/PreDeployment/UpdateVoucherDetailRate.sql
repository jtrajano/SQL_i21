--DEFAULT OF tblAPBillDetail.dblRate should be 1
IF OBJECT_ID('tblAPBill') IS NOT NULL
BEGIN
	EXEC('
		UPDATE voucherDetail
			SET voucherDetail.dblRate = 1
		FROM tblAPBillDetail voucherDetail
		WHERE voucherDetail.dblRate = 0
	')
END