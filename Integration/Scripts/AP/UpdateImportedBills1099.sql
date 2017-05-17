IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'intBillId' AND [object_id] = OBJECT_ID(N'tblAPBill'))
BEGIN

	EXEC ('
	IF EXISTS(SELECT 1 FROM tblAPBill WHERE ysnOrigin = 1)
	BEGIN
		UPDATE A
			SET A.dbl1099 = ((A.dblTotal + A.dblTax) / B.dblTotal) * Origin1099Amount.aptrx_1099_amt
		FROM tblAPBillDetail A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
		INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.intEntityId
		CROSS APPLY (
			SELECT * FROM (
				SELECT 
					D1.aptrx_1099_amt
					,D1.aptrx_vnd_no
					,D1.aptrx_ivc_no
				FROM tblAPaptrxmst D1
				WHERE D1.aptrx_1099_amt > 0
				UNION ALL
				SELECT 
					D1.apivc_1099_amt
					,D1.apivc_vnd_no
					,D1.apivc_ivc_no
				FROM tblAPapivcmst D1
				WHERE D1.apivc_1099_amt > 0
			) OriginData
			WHERE OriginData.aptrx_ivc_no = B.strVendorOrderNumber COLLATE Latin1_General_CS_AS
			AND OriginData.aptrx_vnd_no = C.strVendorId COLLATE Latin1_General_CS_AS
		) Origin1099Amount
		WHERE B.ysnOrigin = 1
	END
	')

END