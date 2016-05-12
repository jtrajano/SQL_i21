﻿/**
	EXECUTE THIS SCRIPT AFTER THE uspAPImportVoucherBackUpFromAPIVCMST
*/
CREATE PROCEDURE [dbo].[uspAPImportVoucherFromAPIVCMST]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@creditCardOnly BIT = 0,
	@totalImported INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @userLocation INT;
DECLARE @defaultTermId INT;
DECLARE @defaultCurrencyId INT;
DECLARE @totalInsertedBill INT;
DECLARE @transCount INT = @@TRANCOUNT;
--LOCATION VARIABLES
DECLARE @shipToAddress NVARCHAR(200)
DECLARE @shipToCity NVARCHAR(50)
DECLARE @shipToState NVARCHAR(50)
DECLARE @shipToZipCode NVARCHAR(12)
DECLARE @shipToCountry NVARCHAR(25)
DECLARE @shipToPhone NVARCHAR(25)
DECLARE @shipToAttention NVARCHAR(200)
--STARTING RECORD NUMBER
DECLARE @voucher NVARCHAR(5)
DECLARE @prepay NVARCHAR(5)
DECLARE @debitMemo NVARCHAR(5)

IF @transCount = 0 BEGIN TRANSACTION

--SET STARTING RECORD NUMBER PREFIX
SELECT
	@voucher = strPrefix
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 9

SELECT
	@prepay = strPrefix
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 20

SELECT
	@debitMemo = strPrefix
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 18

--GET THE USER LOCATION
SELECT 
	@userLocation		= A.intCompanyLocationId ,
	@shipToAddress		= A.strAddress,
	@shipToCity			= A.strCity,
	@shipToState		= A.strStateProvince,
	@shipToZipCode		= A.strZipPostalCode,
	@shipToCountry		= A.strCountry,
	@shipToPhone		= A.strPhone,
	@shipToAttention	= A.strAddress
FROM tblSMCompanyLocation A
	INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

--GET DEFAULT TERM TO USE
SELECT TOP 1 @defaultTermId = intTermID FROM tblSMTerm WHERE strTerm = 'Due on Receipt'

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

INSERT INTO tblAPBill
(
	[intEntityVendorId],
	[strVendorOrderNumber], 
	[strBillId],
	[intTermsId], 
	[dtmDate], 
	[dtmDateCreated], 
	[dtmBillDate],
	[dtmDueDate], 
	[intAccountId], 
	[strReference], 
	[strPONumber],
	[dblTotal], 
	[dbl1099],
	[dblPayment], 
	[dblAmountDue],
	[intEntityId],
	[ysnPosted],
	[ysnPaid],
	[intTransactionType],
	[dblDiscount],
	[dblWithheld],
	[intShipToId],
	[intShipFromId],
	[intShipFromId],
	[intPayToAddressId],
	[intCurrencyId],
	[ysnOrigin]
)
SELECT
	[intEntityVendorId]		=	D.intEntityVendorId, 
	[strVendorOrderNumber] 	=	A.apivc_ivc_no,
	[strBillId]				=	(CASE WHEN A.apivc_trans_type = 'I' AND A.apivc_orig_amt > 0 THEN @voucher
										WHEN A.apivc_trans_type = 'O' AND A.apivc_orig_amt > 0 THEN @voucher
									WHEN A.apivc_trans_type = 'A' THEN @prepay
									WHEN A.apivc_trans_type = 'C' OR A.apivc_orig_amt < 0 THEN @debitMemo
									ELSE 0 END) + CAST(A.intNextNumber AS VARCHAR),
	[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEMEntityLocation 
									WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor 
										WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), @defaultTermId),
	[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmDateCreated] 		=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
	[strReference] 			=	A.apivc_comment,
	[strPONumber]			=	A.apivc_pur_ord_no,
	[dbl1099]				=	A.apivc_1099_amt,
	[dblTotal] 				=	CASE WHEN A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A' THEN A.apivc_orig_amt
									ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END,
	[dblPayment]			=	CASE WHEN A.apivc_status_ind = 'P' THEN
									CASE WHEN (A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A') THEN A.apivc_orig_amt
										ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
								ELSE 0 END,
	[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = 'P' THEN 0 ELSE 
										CASE WHEN A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A' THEN A.apivc_orig_amt
											ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
									END,
	[intEntityId]			=	ISNULL((SELECT intEntityUserSecurityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.apivc_user_id)),@UserId),
	[ysnPosted]				=	1,
	[ysnPaid]				=	CASE WHEN A.apivc_status_ind = 'P' THEN 1 ELSE 0 END,
	[intTransactionType]	=	CASE WHEN A.apivc_trans_type = 'I' AND A.apivc_orig_amt > 0 THEN 1
										WHEN A.apivc_trans_type = 'O' AND A.apivc_orig_amt > 0 THEN 1
									WHEN A.apivc_trans_type = 'A' THEN 2
									WHEN A.apivc_trans_type = 'C' OR A.apivc_orig_amt < 0 THEN 3
									ELSE 0 END,
	[dblDiscount]			=	ISNULL(A.apivc_disc_avail,0),
	[dblWithheld]			=	A.apivc_wthhld_amt,
	[ysnOrigin]				=	1,
	[intCurrencyId]			=	@defaultCurrencyId,
	[intShipToId]			=	@userLocation,
	[intShipFromId]			=	loc.intEntityLocationId,
	[intPayToAddressId]		=	loc.intEntityLocationId,
	[strShipFromAddress]	=	loc.strAddress,
	[strShipFromCity]		=	loc.strCity,
	[strShipFromCountry]	=	loc.strCountry,
	[strShipFromPhone]		=	loc.strPhone,
	[strShipFromState]		=	loc.strState,
	[strShipFromZipCode]	=	loc.strZipCode,
	strShipToAddress		=	@shipToAddress,
	[strShipToCity]			=	@shipToCity,
	[strShipToCountry]		=	@shipToCountry,
	[strShipToPhone]		=	@shipToPhone,
	[strShipToState]		=	@shipToState,
	[strShipToZipCode]		=	@shipToZipCode,
	[A4GLIdentity]			=	A.[A4GLIdentity]
FROM ##tmp_apivcmstImport A
	LEFT JOIN apcbkmst B
		ON A.apivc_cbk_no = B.apcbk_no
	INNER JOIN tblAPVendor D
		ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
	LEFT JOIN tblEMEntityLocation loc
		ON D.intEntityVendorId = loc.intEntityId AND loc.ysnDefaultLocation = 1

SET @totalInsertedBill = @@ROWCOUNT

IF @totalInsertedBill <= 0 
BEGIN
	ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);
	SET @totalImported = 0;
	RETURN;
END

--IMPORT DETAIL
INSERT INTO tblAPBillDetail
(
	[intBillId],
	[strMiscDescription],
	[dblQtyOrdered],
	[dblQtyReceived],
	[intAccountId],
	[dblTotal],
	[dblCost],
	[dbl1099],
	[int1099Form],
	[int1099Category],
	[intLineNo]
)
SELECT 
	[intBillId]				=	A.intBillId,
	[strMiscDescription]	=	A.strReference,
	[dblQtyOrdered]			=	(CASE WHEN C2.apivc_trans_type IN ('C','A') AND C.aphgl_gl_amt > 0 THEN
									(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END) * (-1) --make it negative if detail of debit memo is positive
								ELSE 
									(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 
										ELSE 
											(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_un * -1 ELSE C.aphgl_gl_un END)
									END) 
								END),
	[dblQtyReceived]		=	(CASE WHEN C2.apivc_trans_type IN ('C','A') AND C.aphgl_gl_amt > 0 THEN
									(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END) * (-1)
								ELSE 
									(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 
									ELSE 
										(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_un * -1 ELSE C.aphgl_gl_un END)
									END) 
								END),
	[intAccountId]			=	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.aphgl_gl_acct AS NVARCHAR(MAX))), 0),
	[dblTotal]				=	CASE WHEN C2.apivc_trans_type IN ('C','A') THEN C.aphgl_gl_amt * -1
										--(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
									ELSE C.aphgl_gl_amt END,
	[dblCost]				=	(CASE WHEN C2.apivc_trans_type IN ('C','A','I') THEN
										(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END) --Cost should always positive
									ELSE C.aphgl_gl_amt END) / (CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END),
	[dbl1099]				=	(CASE WHEN (A.dblTotal > 0 AND C2.apivc_1099_amt > 0)
								THEN 
									(
										((CASE WHEN C2.apivc_trans_type IN ('C','A') THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
											/
											(A.dblTotal)
										)
										*
										A.dblTotal
									)
								ELSE 0 END), --COMPUTE WITHHELD ONLY IF TOTAL IS POSITIVE
	[int1099Form]			=	(CASE WHEN C2.apivc_1099_amt > 0 THEN 1 ELSE 0 END),
	[int1099Category]		=	(CASE WHEN C2.apivc_1099_amt > 0 THEN 8 ELSE 0 END),
	[intLineNo]				=	C.aphgl_dist_no,
	[A4GLIdentity]			=	C.[A4GLIdentity]
FROM tblAPBill A
INNER JOIN tblAPVendor B
	ON A.intEntityVendorId = B.intEntityVendorId
INNER JOIN (##tmp_apivcmstImport C2 INNER JOIN aphglmst C 
			ON C2.apivc_ivc_no = C.aphgl_ivc_no 
			AND C2.apivc_vnd_no = C.aphgl_vnd_no)
ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.apivc_ivc_no
	AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.apivc_vnd_no
ORDER BY C.aphgl_dist_no

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorBackingUp NVARCHAR(500) = ERROR_MESSAGE();
	ROLLBACK TRANSACTION
	RAISERROR(@errorBackingUp, 16, 1);
END CATCH
