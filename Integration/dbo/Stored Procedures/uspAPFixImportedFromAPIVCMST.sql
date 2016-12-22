GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPFixImportedFromAPIVCMST')
	DROP PROCEDURE uspAPFixImportedFromAPIVCMST
GO

IF   EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[apivc_disc_taken]') AND type IN (N'U'))
BEGIN
		EXEC ('
		CREATE PROCEDURE [dbo].[uspAPFixImportedFromAPIVCMST]
			AS

			UPDATE A
				SET A.dblPayment = CASE WHEN A.apivc_status_ind = ''P'' THEN
												(CASE WHEN (A.apivc_trans_type = ''C''  OR A.apivc_trans_type = ''A'' ) THEN A.apivc_orig_amt
													ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END)
												- A.apivc_disc_taken --DO NOT USE apivc_net_amt directly as there are origin transaction that the net amount do not subtract the discount
											ELSE 0 END,
					A.dblDiscount = ISNULL(B.apivc_disc_taken,0)
			FROM tblAPBill A
			INNER JOIN tblAPapivcmst B ON A.intBillId = B.intBillId
			WHERE A.ysnOrigin = 1 AND A.ysnPosted = 1
			AND NOT EXISTS ( --MAKE SURE IT HAS NO PAYMENT
				SELECT 1 FROM tblAPPaymentDetail C
				WHERE C.intBillId = A.intBillId
			)

			UPDATE A
				SET A.dblTotal = B.dblTotal,
				A.dblPayment = B.dblPayment,
				A.dblDiscount = B.dblDiscount
			FROM tblAPPaymentDetail A
			INNER JOIN tblAPPayment A2 ON A.intPaymentId = A2.intPaymentId
			INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
			WHERE EXISTS (
				SELECT 1
				FROM tblAPBill C
				INNER JOIN tblAPapivcmst D ON C.intBillId = D.intBillId
				WHERE C.ysnOrigin = 1 AND C.ysnPosted = 1
				AND C.intBillId = B.intBillId
			)
			AND A2.ysnOrigin = 1
	')
END
