IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	--Update new fields in tblAPBill
	--Update transaction as Debit Memo
	UPDATE tblAPBill
	SET intTransactionType = (CASE WHEN C.aptrx_trans_type = 'I' THEN 1 
									WHEN C.aptrx_trans_type = 'C' THEN 3
								ELSE 0 END),
	dblWithheld = C.aptrx_wthhld_amt,
	dblDiscount = C.aptrx_disc_amt,
	dblTotal = CASE WHEN C.aptrx_trans_type = 'C' THEN (A.dblTotal * -1) ELSE A.dblTotal END,
	dblAmountDue = CASE WHEN C.aptrx_trans_type = 'C' THEN (A.dblAmountDue * -1) ELSE A.dblAmountDue END
	FROM tblAPBill A
		INNER JOIN tblAPVendor B
			ON A.intVendorId = B.intEntityId AND A.intTransactionType = 0
		INNER JOIN aptrxmst C
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aptrx_ivc_no COLLATE Latin1_General_CI_AS
			AND B.strVendorId COLLATE Latin1_General_CI_AS = C.aptrx_vnd_no COLLATE Latin1_General_CI_AS

	UPDATE tblAPBill
	SET intTransactionType = (CASE WHEN C.apivc_trans_type = 'I' THEN 1 
									WHEN C.apivc_trans_type = 'C' THEN 3
								ELSE 0 END),
	dblWithheld = C.apivc_wthhld_amt,
	dblDiscount = C.apivc_disc_avail,
	dblTotal = CASE WHEN C.apivc_trans_type = 'C' THEN (A.dblTotal * -1) ELSE A.dblTotal END,
	dblAmountDue = CASE WHEN C.apivc_trans_type = 'C' THEN (A.dblAmountDue * -1) ELSE A.dblAmountDue END
	FROM tblAPBill A
		INNER JOIN tblAPVendor B
			ON A.intVendorId = B.intEntityId AND A.intTransactionType = 0
		INNER JOIN apivcmst C
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apivc_ivc_no COLLATE Latin1_General_CI_AS
			AND B.strVendorId COLLATE Latin1_General_CI_AS = C.apivc_vnd_no COLLATE Latin1_General_CI_AS
END