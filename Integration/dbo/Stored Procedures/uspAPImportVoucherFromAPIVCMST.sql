﻿/**
	EXECUTE THIS SCRIPT AFTER THE uspAPImportVoucherBackUpFromAPIVCMST
	RULES ON IMPORTING VOUCHERS FROM ORIGIN
	Voucher Header
	1. If transaction type is 'C' it is Debit Memo
	2. If amount is negative, it is Debit Memo
	Voucher Detail
	1. If transaction type is 'I' and amount is negative, amount should be positive.
*/
CREATE PROCEDURE [dbo].[uspAPImportVoucherFromAPIVCMST]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@totalHeaderImported INT OUTPUT,
	@totalDetailImported INT OUTPUT,
	@totalPostedVoucher DECIMAL(18,6) OUTPUT
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
DECLARE @totalInsertedBillDetail INT;
DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()
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
DECLARE @nextVoucherNumber INT;
DECLARE @nextPrePayNumber INT;
DECLARE @nextDebitNumber INT;

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPImportVoucherFromAPIVCMST

--SET STARTING RECORD NUMBER PREFIX
SELECT
	@voucher = strPrefix,
	@nextVoucherNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 9

SELECT
	@prepay = strPrefix,
	@nextPrePayNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 20

SELECT
	@debitMemo = strPrefix,
	@nextDebitNumber = A.intNumber
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

IF OBJECT_ID(N'tempdb..#tmpVoucherTransactions') IS NOT NULL DROP TABLE #tmpVoucherTransactions
CREATE TABLE #tmpVoucherTransactions(intBillId INT, intBackupId INT);

MERGE INTO tblAPBill AS destination
USING
(
SELECT
	[intEntityVendorId]		=	D.intEntityVendorId, 
	[strVendorOrderNumber] 	=	A.apivc_ivc_no,
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
	[dblSubtotal]			=	CASE WHEN A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A' THEN A.apivc_orig_amt
									ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END,
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
	[intTransactionType]	=	(CASE WHEN A.apivc_trans_type = 'I' AND A.apivc_orig_amt > 0 THEN 1
										WHEN A.apivc_trans_type = 'O' AND A.apivc_orig_amt > 0 THEN 1
									WHEN A.apivc_trans_type = 'A' THEN 2
									WHEN A.apivc_trans_type = 'C' OR A.apivc_orig_amt < 0 THEN 3
									ELSE 0 END),
	[dblDiscount]			=	ISNULL(A.apivc_disc_taken,0),
	[dblWithheld]			=	A.apivc_wthhld_amt,
	[intShipToId]			=	@userLocation,
	[intShipFromId]			=	loc.intEntityLocationId,
	[intPayToAddressId]		=	loc.intEntityLocationId,
	[strShipFromAddress]	=	loc.strAddress,
	[strShipFromCity]		=	loc.strCity,
	[strShipFromCountry]	=	loc.strCountry,
	[strShipFromPhone]		=	loc.strPhone,
	[strShipFromState]		=	loc.strState,
	[strShipFromZipCode]	=	loc.strZipCode,
	[strShipToAddress]		=	@shipToAddress,
	[strShipToCity]			=	@shipToCity,
	[strShipToCountry]		=	@shipToCountry,
	[strShipToPhone]		=	@shipToPhone,
	[strShipToState]		=	@shipToState,
	[strShipToZipCode]		=	@shipToZipCode,
	[intCurrencyId]			=	@defaultCurrencyId,
	[ysnOrigin]				=	1,
	[intBackupId]			=	A.intBackupId
FROM tmp_apivcmstImport A
	LEFT JOIN apcbkmst B
		ON A.apivc_cbk_no = B.apcbk_no
	INNER JOIN tblAPVendor D
		ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
	LEFT JOIN tblEMEntityLocation loc
		ON D.intEntityVendorId = loc.intEntityId AND loc.ysnDefaultLocation = 1
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	[intEntityVendorId],
	[strVendorOrderNumber], 
	[intTermsId], 
	[dtmDate], 
	[dtmDateCreated], 
	[dtmBillDate],
	[dtmDueDate], 
	[intAccountId], 
	[strReference], 
	[strPONumber],
	[dblSubtotal],
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
	[intPayToAddressId],
	[strShipFromAddress]	,	
	[strShipFromCity],		
	[strShipFromCountry]	,	
	[strShipFromPhone],		
	[strShipFromState],		
	[strShipFromZipCode],		
	[strShipToAddress],		
	[strShipToCity],			
	[strShipToCountry],		
	[strShipToPhone]	,		
	[strShipToState]	,		
	[strShipToZipCode],		
	[intCurrencyId],
	[ysnOrigin]
)
VALUES
(
	[intEntityVendorId],
	[strVendorOrderNumber], 
	[intTermsId], 
	[dtmDate], 
	[dtmDateCreated], 
	[dtmBillDate],
	[dtmDueDate], 
	[intAccountId], 
	[strReference], 
	[strPONumber],
	[dblSubtotal],
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
	[intPayToAddressId],
	[strShipFromAddress]	,	
	[strShipFromCity],		
	[strShipFromCountry]	,	
	[strShipFromPhone],		
	[strShipFromState],		
	[strShipFromZipCode],		
	[strShipToAddress],		
	[strShipToCity],			
	[strShipToCountry],		
	[strShipToPhone]	,		
	[strShipToState]	,		
	[strShipToZipCode],		
	[intCurrencyId],
	[ysnOrigin]
)
OUTPUT inserted.intBillId, SourceData.intBackupId INTO #tmpVoucherTransactions;

SET @totalInsertedBill = @@ROWCOUNT;

IF OBJECT_ID('tempdb..#tmpVouchersWithRecordNumber') IS NOT NULL DROP TABLE #tmpVouchersWithRecordNumber

--UPDATE strBillId
CREATE TABLE #tmpVouchersWithRecordNumber
(
	intBillId INT NOT NULL,
	intTransactionType INT NOT NULL,
	intRecordNumber INT NOT NULL
)

INSERT INTO #tmpVouchersWithRecordNumber
SELECT
	A.intBillId,
	A.intTransactionType,
	(CASE A.intTransactionType 
		WHEN 1 
			THEN @nextVoucherNumber 
		WHEN 2
			THEN @nextPrePayNumber
		WHEN 3
			THEN @nextDebitNumber END) +
		ROW_NUMBER() OVER(PARTITION BY A.intTransactionType ORDER BY A.intBillId)
FROM tblAPBill A
INNER JOIN #tmpVoucherTransactions B ON A.intBillId = B.intBillId

UPDATE A
	SET A.strBillId = (CASE A.intTransactionType
						WHEN 1
							THEN @voucher
						WHEN 2
							THEN @prepay
						WHEN 3
							THEN @debitMemo
						END) + (CAST(B.intRecordNumber AS NVARCHAR))
FROM tblAPBill A
INNER JOIN #tmpVouchersWithRecordNumber B ON A.intBillId = B.intBillId

ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

--UPDATE THE BACK UP TABLE FOREIGN KEY
UPDATE A
	SET A.intBillId = B.intBillId
FROM tblAPapivcmst A
INNER JOIN #tmpVoucherTransactions B ON A.intId = B.intBackupId

IF @totalInsertedBill <= 0 
BEGIN
	SET @totalHeaderImported = 0;
	SET @totalDetailImported = 0;
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

--UPDATE STARTING NUMBER
UPDATE A
	SET A.intNumber = ISNULL(totalVoucher.dblTotalVoucher + 1, A.intNumber)
FROM tblSMStartingNumber A
CROSS APPLY (
	SELECT MAX(intRecordNumber) AS dblTotalVoucher FROM #tmpVouchersWithRecordNumber WHERE intTransactionType = 1
) totalVoucher
WHERE A.intStartingNumberId = 9

UPDATE A
	SET A.intNumber = ISNULL(totalDebitMemo.dblTotalDebitMemo + 1, A.intNumber)
FROM tblSMStartingNumber A
CROSS APPLY (
	SELECT MAX(intRecordNumber) AS dblTotalDebitMemo FROM #tmpVouchersWithRecordNumber WHERE intTransactionType =3
) totalDebitMemo
WHERE A.intStartingNumberId = 18

UPDATE A
	SET A.intNumber = ISNULL(totalPrepay.dblTotalPrepay + 1, A.intNumber)
FROM tblSMStartingNumber A
CROSS APPLY (
	SELECT MAX(intRecordNumber) AS dblTotalPrepay FROM #tmpVouchersWithRecordNumber WHERE intTransactionType = 2
) totalPrepay
WHERE A.intStartingNumberId = 20

SET @totalHeaderImported = @totalInsertedBill;

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
											WHEN C.aphgl_gl_amt < 0 AND C2.apivc_trans_type = 'I' THEN C.aphgl_gl_amt * -1
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
	[intLineNo]				=	C.aphgl_dist_no
FROM tblAPBill A
INNER JOIN tblAPVendor B
	ON A.intEntityVendorId = B.intEntityVendorId
INNER JOIN (tmp_apivcmstImport C2 INNER JOIN tmp_aphglmstImport C 
			ON C2.apivc_ivc_no = C.aphgl_ivc_no 
			AND C2.apivc_vnd_no = C.aphgl_vnd_no)
ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.apivc_ivc_no
	AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.apivc_vnd_no
ORDER BY C.aphgl_dist_no

SET @totalInsertedBillDetail = @@ROWCOUNT;

SET @totalDetailImported = @totalInsertedBillDetail;

--UPDATE THE intBillId of tblAPapivcmst
UPDATE A
	SET A.intBillId = B.intBillId
FROM tblAPapivcmst A
INNER JOIN #tmpVoucherTransactions B ON A.intId = B.intBackupId

--GET TOTAL POSTED VOUCHER
SELECT 
	@totalPostedVoucher = 
	SUM(
		(CASE WHEN A.apivc_trans_type IN ('C','A') AND A.apivc_orig_amt > 0
				THEN A.apivc_orig_amt * -1 
			WHEN A.apivc_trans_type IN ('I') AND A.apivc_orig_amt < 0
				THEN A.apivc_orig_amt * -1 
			ELSE A.apivc_orig_amt END))
	- SUM(ISNULL(A.apivc_disc_taken,0))
FROM tmp_apivcmstImport A

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate],
	[strLogKey]
)
SELECT
	CAST(@totalHeaderImported AS NVARCHAR) + ' records imported from apivcmst.'
	,@UserId
	,@logDate
	,@key
UNION ALL
SELECT
	CAST(@totalDetailImported AS NVARCHAR) + ' records imported from aphglmst.'
	,@UserId
	,@logDate
	,@key

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorImport NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION uspAPImportVoucherFromAPIVCMST
	RAISERROR(@errorImport, 16, 1);
END CATCH
