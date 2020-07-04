CREATE PROCEDURE [dbo].[uspAPImportVoucherFromAPTRXMST]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@totalHeaderImported INT OUTPUT,
	@totalDetailImported INT OUTPUT,
	@totalUnpostedVoucher DECIMAL(18,6) OUTPUT
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
DECLARE @enforceControlTotal BIT = 0;

SELECT TOP 1 @enforceControlTotal =  pref.ysnEnforceControlTotal FROM tblAPCompanyPreference pref

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPImportVoucherFromAPTRXMST

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
WHERE intEntityId = @UserId

--GET DEFAULT TERM TO USE
SELECT TOP 1 @defaultTermId = intTermID FROM tblSMTerm WHERE strTerm = 'Due on Receipt'

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

IF OBJECT_ID(N'tempdb..#tmpVoucherTransactions') IS NOT NULL DROP TABLE #tmpVoucherTransactions
CREATE TABLE #tmpVoucherTransactions(intBillId INT, intBackupId INt);

MERGE INTO tblAPBill AS destination
USING
(
SELECT
	[intEntityVendorId]			=	D.intEntityId,
	[strVendorOrderNumber] 		=	A.aptrx_ivc_no,
	[intTermsId] 				=	ISNULL((SELECT TOP 1 intTermsId FROM tblEMEntityLocation
											WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor
												WHERE strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no)), @defaultTermId),
	[dtmDate] 					=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE 
										(CASE WHEN ISDATE(A.aptrx_ivc_rev_dt) = 1 THEN  CONVERT(DATE, CAST(A.aptrx_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
									 END,
	[dtmDateCreated] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmBillDate] 				=	CASE WHEN ISDATE(A.aptrx_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmDueDate] 				=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[intAccountId] 				=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
	[strReference] 				=	A.aptrx_pur_ord_no,
	[strRemarks]				=	A.aptrx_comment,
	[dblSubtotal] 				=	CASE WHEN A.aptrx_trans_type = 'C' OR A.aptrx_trans_type = 'A' THEN A.aptrx_orig_amt 
										ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
	[dblTotal] 					=	CASE WHEN A.aptrx_trans_type = 'C' OR A.aptrx_trans_type = 'A' THEN A.aptrx_orig_amt 
										ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
	[dblAmountDue]				=	CASE WHEN A.aptrx_trans_type = 'C' OR A.aptrx_trans_type = 'A' THEN A.aptrx_orig_amt 
										ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
	[intEntityId]				=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.aptrx_user_id)),@UserId),
	[ysnPosted]					=	0,
	[ysnPaid]					=	0,
	[intTransactionType]		=	CASE WHEN A.aptrx_trans_type = 'I' AND A.aptrx_orig_amt > 0 THEN 1
										WHEN A.aptrx_trans_type = 'O' AND A.aptrx_orig_amt > 0 THEN 1
									WHEN A.aptrx_trans_type = 'A' THEN 3
									WHEN A.aptrx_trans_type = 'C' OR A.aptrx_orig_amt < 0 THEN 3
									ELSE 
										CASE WHEN A.aptrx_orig_amt = 0 THEN 
											CASE A.aptrx_trans_type 
												WHEN 'I' THEN 1
												WHEN 'O' THEN 1
												WHEN 'A' THEN 3
												WHEN 'C' THEN 3
											ELSE 1
											END
										ELSE 1
										END
									END,
	[dblDiscount]				=	ISNULL(A.aptrx_disc_amt,0),
	[dblWithheld]				=	A.aptrx_wthhld_amt,
	[intShipToId]				=	@userLocation,
	[intStoreLocationId]		=	@userLocation,
	[intShipFromId]				=	loc.intEntityLocationId,
	[intPayToAddressId]			=	loc.intEntityLocationId,
	[intShipFromEntityId]		=	D.intEntityId,
	[strShipFromAddress]		=	loc.strAddress,
	[strShipFromCity]			=	loc.strCity,
	[strShipFromCountry]		=	loc.strCountry,
	[strShipFromPhone]			=	loc.strPhone,
	[strShipFromState]			=	loc.strState,
	[strShipFromZipCode]		=	loc.strZipCode,
	[strShipToAddress]			=	@shipToAddress,
	[strShipToCity]				=	@shipToCity,
	[strShipToCountry]			=	@shipToCountry,
	[strShipToPhone]			=	@shipToPhone,
	[strShipToState]			=	@shipToState,
	[strShipToZipCode]			=	@shipToZipCode,
	[intCurrencyId]				=	@defaultCurrencyId,
	[ysnOrigin]					=	1,
	[intBackupId]				=	A.intBackupId
FROM tmp_aptrxmstImport A
	LEFT JOIN apcbkmst B
		ON A.aptrx_cbk_no = B.apcbk_no
	INNER JOIN tblAPVendor D
		ON A.aptrx_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
	LEFT JOIN tblEMEntityLocation loc
		ON D.intEntityId = loc.intEntityId AND loc.ysnDefaultLocation = 1
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
	[strRemarks],
	[dblSubtotal],
	[dblTotal], 
	[dblAmountDue],
	[intEntityId],
	[ysnPosted],
	[ysnPaid],
	[intTransactionType],
	[dblDiscount],
	[dblWithheld],
	[intShipToId],
	[intStoreLocationId],
	[intShipFromId],
	[intPayToAddressId],
	[intShipFromEntityId],
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
	[strRemarks],
	[dblSubtotal],
	[dblTotal], 
	[dblAmountDue],
	[intEntityId],
	[ysnPosted],
	[ysnPaid],
	[intTransactionType],
	[dblDiscount],
	[dblWithheld],
	[intShipToId],
	[intStoreLocationId],
	[intShipFromId],
	[intPayToAddressId],
	[intShipFromEntityId],
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
OUTPUT inserted.intBillId intBillId, SourceData.intBackupId intBackupId INTO #tmpVoucherTransactions;

SET @totalInsertedBill = @@ROWCOUNT

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
						END) + (CAST(B.intRecordNumber AS NVARCHAR)),
		A.ysnDiscountOverride = CASE WHEN A.dblDiscount != 0 THEN 1 ELSE 0 END,
		A.dblTotalController = CASE WHEN @enforceControlTotal = 1 THEN A.dblTotal ELSE 0 END
FROM tblAPBill A
INNER JOIN #tmpVouchersWithRecordNumber B ON A.intBillId = B.intBillId

ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

--UPDATE THE intBillId of tblAPaptrxmst
UPDATE A
	SET A.intBillId = B.intBillId
FROM tblAPaptrxmst A
INNER JOIN #tmpVoucherTransactions B ON A.intId = B.intBackupId

IF @totalInsertedBill <= 0 
BEGIN
	SET @totalHeaderImported = 0;
	SET @totalDetailImported = 0;
	SET @totalUnpostedVoucher = 0;
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

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
	[dblQtyOrdered]			=	(CASE WHEN C2.aptrx_trans_type IN ('C','A') THEN
									--(CASE WHEN ISNULL(C.apegl_gl_un,0) <= 0 THEN 1 ELSE C.apegl_gl_un END) 
									ISNULL(NULLIF(C.apegl_gl_un,0),1)
									* 
									 (CASE WHEN C.apegl_gl_amt > 0 THEN (-1) ELSE 1 END) --make it negative if detail of debit memo is positive
								ELSE --('I')
									--(CASE WHEN ISNULL(C.apegl_gl_un,0) <= 0 THEN 1 ELSE C.apegl_gl_un END)
									ISNULL(NULLIF(C.apegl_gl_un,0),1)
									*
									(CASE WHEN C.apegl_gl_amt < 0 -- make the quantity negative if amount is negative 
										THEN (CASE WHEN C2.aptrx_net_amt = 0 OR ISNULL(NULLIF(C.apegl_gl_un,0),1) < 0 THEN 1 ELSE -1 END) --If total of voucher is 0, retain the qty as negative, this is offset voucher
										ELSE 1 END) 
								END),
	[dblQtyReceived]		=	(CASE WHEN C2.aptrx_trans_type IN ('C','A') THEN
									--(CASE WHEN ISNULL(C.apegl_gl_un,0) <= 0 THEN 1 ELSE C.apegl_gl_un END) 
									ISNULL(NULLIF(C.apegl_gl_un,0),1)
									* 
									 (CASE WHEN C.apegl_gl_amt > 0 THEN (-1) ELSE 1 END) --make it negative if detail of debit memo is positive
								ELSE --('I')
									--(CASE WHEN ISNULL(C.apegl_gl_un,0) <= 0 THEN 1 ELSE C.apegl_gl_un END)
									ISNULL(NULLIF(C.apegl_gl_un,0),1)
									*
									(CASE WHEN C.apegl_gl_amt < 0 -- make the quantity negative if amount is negative 
										THEN (CASE WHEN C2.aptrx_net_amt = 0 OR ISNULL(NULLIF(C.apegl_gl_un,0),1) < 0 THEN 1 ELSE -1 END) --If total of voucher is 0, retain the qty as negative 
										ELSE 1 END) 
								END),
	[intAccountId]			=	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.apegl_gl_acct AS NVARCHAR(MAX))), 0),
	[dblTotal]				=	CASE WHEN  C2.aptrx_trans_type IN ('C','A') 
											THEN C.apegl_gl_amt * (-1) 
										ELSE C.apegl_gl_amt END,
	[dblCost]				=	ABS((CASE WHEN C2.aptrx_trans_type IN ('C','A','I') 
									THEN
										(CASE 
											WHEN C.apegl_gl_amt < 0 
											THEN C.apegl_gl_amt * -1 
											ELSE C.apegl_gl_amt 
										END) --Cost should always positive
									ELSE C.apegl_gl_amt 
									END) 
									/ 
									(CASE 
										WHEN 
											(CASE WHEN  C2.aptrx_trans_type IN ('C','A') 
												THEN C.apegl_gl_amt * (-1) 
											ELSE C.apegl_gl_amt END) < 0 
										THEN -(ABS(ISNULL(NULLIF(C.apegl_gl_un,0),1))) --when line total is negative, get the cost by dividing to negative as well
										ELSE ISNULL(NULLIF(C.apegl_gl_un,0),1) 
									END)),
	[dbl1099]				=	(CASE WHEN (A.dblTotal > 0 AND C2.aptrx_1099_amt > 0)
								THEN 
									(
										((CASE WHEN C2.aptrx_trans_type IN ('C','A') THEN ISNULL(C.apegl_gl_amt, C2.aptrx_net_amt) * -1 ELSE ISNULL(C.apegl_gl_amt, C2.aptrx_net_amt) END)
											/
											(A.dblTotal)
										)
										*
										A.dblTotal
									)
								ELSE 0 END), --COMPUTE WITHHELD ONLY IF TOTAL IS POSITIVE
	[int1099Form]			=	(CASE WHEN C2.aptrx_1099_amt > 0 
										THEN (
											CASE WHEN entity.str1099Form = '1099-MISC' THEN 1
													WHEN entity.str1099Form = '1099-INT' THEN 2
													WHEN entity.str1099Form = '1099-B' THEN 3
													WHEN entity.str1099Form = '1099-PATR' THEN 4
													WHEN entity.str1099Form = '1099-DIV' THEN 5
											ELSE 0 END
										)
										ELSE 0 
								END),
	[int1099Category]		=	(CASE WHEN C2.aptrx_1099_amt > 0 
										THEN ( 
											CASE WHEN entity.str1099Form = '1099-MISC' THEN category.int1099CategoryId
													WHEN entity.str1099Form = '1099-INT' THEN category.int1099CategoryId
													WHEN entity.str1099Form = '1099-B' THEN category.int1099CategoryId
													WHEN entity.str1099Form = '1099-PATR' THEN categoryPATR.int1099CategoryId
													WHEN entity.str1099Form = '1099-DIV' THEN categoryDIV.int1099CategoryId
											ELSE 0 END
										)
										ELSE 0 
								END),
	[intLineNo]				=	C.apegl_dist_no
FROM tblAPBill A
	INNER JOIN tblAPVendor B
		ON A.intEntityVendorId = B.intEntityId
	INNER JOIN tblEMEntity entity
		ON B.intEntityId = entity.intEntityId
	INNER JOIN #tmpVoucherTransactions tmpCreatedVouchers ON A.intBillId = tmpCreatedVouchers.intBillId
	INNER JOIN (tmp_aptrxmstImport C2 INNER JOIN tmp_apeglmstImport C 
					ON C2.aptrx_ivc_no = C.apegl_ivc_no 
					AND C2.aptrx_vnd_no = C.apegl_vnd_no)
		ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
		AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
	LEFT JOIN tblAP1099Category category ON category.strCategory = entity.str1099Type
	LEFT JOIN tblAP1099PATRCategory categoryPATR ON categoryPATR.strCategory = entity.str1099Type
	LEFT JOIN tblAP1099DIVCategory categoryDIV ON categoryDIV.strCategory = entity.str1099Type
ORDER BY C.apegl_dist_no

SET @totalInsertedBillDetail = @@ROWCOUNT;

SET @totalDetailImported = @totalInsertedBillDetail;

--GET TOTAL UNPOSTED VOUCHER
SELECT 
	@totalUnpostedVoucher = SUM(
		(CASE WHEN A.aptrx_trans_type IN ('C','A') AND A.aptrx_orig_amt > 0
				THEN A.aptrx_orig_amt * -1 
			WHEN A.aptrx_trans_type IN ('I') AND A.aptrx_orig_amt < 0
				THEN A.aptrx_orig_amt * -1 
			ELSE A.aptrx_orig_amt END))
FROM tmp_aptrxmstImport A

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate],
	[strLogKey]
)
SELECT
	CAST(@totalHeaderImported AS NVARCHAR) + ' records imported from aptrxmst.'
	,@UserId
	,@logDate
	,@key
UNION ALL
SELECT
	CAST(@totalDetailImported AS NVARCHAR) + ' records imported from apeglmst.'
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
		ROLLBACK TRANSACTION uspAPImportVoucherFromAPTRXMST
	RAISERROR(@errorImport, 16, 1);
END CATCH
