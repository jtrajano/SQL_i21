CREATE PROCEDURE [dbo].[uspAPImportVoucherPayment]
	@UserId INT,
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@totalCreated INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @defaultCurrencyId INT;
--PAYMENT METHOD ID
DECLARE @check INT, @eft INT, @wire INT, @withdrawal INT, @deposit INT, @debitmemosandpayments INT;
--MISSING PAYMENT VARIABLES
DECLARE @defaultBankAccountId INT, @defaultBankGLAccountId INT;

DECLARE @pay NVARCHAR(50);
DECLARE @paymentRecordNum INT;

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPImportVoucherPayment

SELECT
	@pay = strPrefix,
	@paymentRecordNum = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 8

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

--MAKE SURE PAYMENT METHOD EXISTS BEFORE IMPORTING
MERGE INTO tblSMPaymentMethod AS Destination
USING
(
	SELECT strPaymentMethod = 'EFT', ysnActive = 1
	UNION ALL
	SELECT strPaymentMethod = 'Wire', ysnActive = 1
	UNION ALL
	SELECT strPaymentMethod = 'Check', ysnActive = 1
	UNION ALL
	SELECT strPaymentMethod = 'Withdrawal', ysnActive = 1
	UNION ALL
	SELECT strPaymentMethod = 'Deposit', ysnActive = 1
	UNION ALL
	SELECT strPaymentMethod = 'Debit memos and payments', ysnActive = 1
) AS SourceData
ON (LOWER(Destination.strPaymentMethod) = LOWER(SourceData.strPaymentMethod))
WHEN NOT MATCHED THEN
INSERT
(
	strPaymentMethod,
	ysnActive
)
VALUES
(
	strPaymentMethod,
	ysnActive
);

SELECT @check = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'
SELECT @eft = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'eft'
SELECT @wire = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'wire'
SELECT @withdrawal = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'withdrawal'
SELECT @deposit = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'deposit'
SELECT @debitmemosandpayments = intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'debit memos and payments'

IF OBJECT_ID('tempdb..#tmpPaymentCreated') IS NOT NULL DROP TABLE #tmpPaymentCreated
CREATE TABLE #tmpPaymentCreated(
		intPaymentId INT,
		--intId INT
		 --apivc_ivc_no CHAR(18) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_vnd_no CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_chk_rev_dt INT,
		 apivc_cbk_no CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_chk_no CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS
);
CREATE INDEX IDX_tmpPaymentCreated_Primary ON #tmpPaymentCreated(apivc_vnd_no, apivc_chk_rev_dt, apivc_cbk_no, apivc_chk_no)

IF OBJECT_ID('dbo.[UK_dbo.tblAPPayment_strPaymentRecordNum]', 'UQ') IS NOT NULL 
ALTER TABLE tblAPPayment DROP CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum];

WITH PaymentSource(
	[intAccountId],
	[intBankAccountId],
	[intPaymentMethodId],
	[intCurrencyId],
	[intEntityVendorId],
	[strPaymentInfo],
	[strNotes],
	[dtmDatePaid],
	[dblAmountPaid],
	[dblUnapplied],
	[ysnPosted],
	[dblWithheld],
	[intEntityId],
	[intConcurrencyId],
	[ysnOrigin],
	[ysnPrepay],
	[apivc_vnd_no],			
	[apivc_chk_rev_dt],		
	[apivc_cbk_no],
	[apivc_chk_no],
	[apchk_A4GLIdentity]			
)
AS (
SELECT DISTINCT
	[intAccountId]			= D.intGLAccountId,
	[intBankAccountId]		= D.intBankAccountId,
	[intPaymentMethodId]	= CASE
									WHEN ISNULL(E.apchk_chk_amt, A.apivc_net_amt) > 0 THEN 
										CASE 
											WHEN LEFT(A.apivc_chk_no, 1) = 'E' THEN @eft
											WHEN LEFT(A.apivc_chk_no, 1) = 'W' THEN @wire
											WHEN ISNULL(E.apchk_trx_ind,'C') = 'C' THEN @check --DEFAULT TO CHECK IF PAYMENT IS MISSING
											ELSE @withdrawal
										END
									WHEN ISNULL(E.apchk_chk_amt, A.apivc_net_amt) < 0 THEN @deposit
									WHEN E.apchk_chk_amt = 0 THEN @debitmemosandpayments
								END,
	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = D.intBankAccountId), @defaultCurrencyId),
	[intEntityVendorId]		= B.intEntityId,
	[strPaymentInfo]		= A.apivc_chk_no,
	[strNotes]				= NULL,
	[dtmDatePaid]			= CASE WHEN ISDATE(A.apivc_chk_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_chk_rev_dt AS CHAR(12)), 112) 
									WHEN ISDATE(A.apivc_gl_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) --USE VOUCHER DATE IF CHECK DATE IS INVALID
									ELSE GETDATE() END,
	[dblAmountPaid]			= ABS(ISNULL(E.apchk_chk_amt, A.apivc_net_amt)), --IF MISSING PAYMENT, USE THE NET AMOUNT (THE DISCOUNT IS DEDUCTED)
	[dblUnapplied]			= 0,
	[ysnPosted]				= 1,
	[dblWithheld]			= 0,
	[intEntityId]			= @UserId,
	[intConcurrencyId]		= 0,
	[ysnOrigin]				= 1,
	[ysnPrepay]				= CASE WHEN A.apivc_trans_type = 'A' AND A.apivc_status_ind = 'U' THEN 1 ELSE 0 END,
	[apivc_vnd_no]			= A.apivc_vnd_no,
	[apivc_chk_rev_dt]		= A.apivc_chk_rev_dt,
	[apivc_cbk_no]			= A.apivc_cbk_no,
	[apivc_chk_no]			= A.apivc_chk_no,
	[apchk_A4GLIdentity]	= A.apchk_A4GLIdentity
FROM tmp_apivcmstImport A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
LEFT JOIN apchkmst E ON A.apchk_A4GLIdentity = E.A4GLIdentity
WHERE ((A.apivc_status_ind = 'P' OR ISNULL(A.apivc_chk_no,'') != '')) AND A.apchk_A4GLIdentity IS NOT NULL
UNION ALL
--FOR MISSING PAYMENT GROUP IT BY VENDOR, CHECKBOOK AND DATE THEN CREATE PAYMENT
SELECT
	[intAccountId]			= D.intGLAccountId,
	[intBankAccountId]		= D.intBankAccountId,
	[intPaymentMethodId]	= CASE
									WHEN ISNULL(E.apchk_chk_amt, A.apivc_net_amt) > 0 THEN 
										CASE 
											WHEN LEFT(A.apivc_chk_no, 1) = 'E' THEN @eft
											WHEN LEFT(A.apivc_chk_no, 1) = 'W' THEN @wire
											WHEN ISNULL(E.apchk_trx_ind,'C') = 'C' THEN @check --DEFAULT TO CHECK IF PAYMENT IS MISSING
											ELSE @withdrawal
										END
									WHEN ISNULL(E.apchk_chk_amt, A.apivc_net_amt) < 0 THEN @deposit
									WHEN ISNULL(E.apchk_chk_amt, A.apivc_net_amt) = 0 THEN @debitmemosandpayments
								END,
	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = D.intBankAccountId), @defaultCurrencyId),
	[intEntityVendorId]		= B.intEntityId,
	[strPaymentInfo]		= A.apivc_chk_no,
	[strNotes]				= NULL,
	[dtmDatePaid]			= CASE WHEN ISDATE(A.apivc_chk_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_chk_rev_dt AS CHAR(12)), 112) 
									WHEN ISDATE(A.apivc_gl_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) --USE VOUCHER DATE IF CHECK DATE IS INVALID
									ELSE GETDATE() END,
	[dblAmountPaid]			= ABS(ISNULL(E.apchk_chk_amt, A.apivc_net_amt)), --IF MISSING PAYMENT, USE THE NET AMOUNT (THE DISCOUNT IS DEDUCTED)
	[dblUnapplied]			= 0,
	[ysnPosted]				= 1,
	[dblWithheld]			= 0,
	[intEntityId]			= @UserId,
	[intConcurrencyId]		= 0,
	[ysnOrigin]				= 1,
	[ysnPrepay]				= CASE WHEN A.apivc_trans_type = 'A' AND A.apivc_status_ind = 'U' THEN 1 ELSE 0 END,
	[apivc_vnd_no]			= A.apivc_vnd_no,
	[apivc_chk_rev_dt]		= A.apivc_chk_rev_dt,
	[apivc_cbk_no]			= A.apivc_cbk_no,
	[apivc_chk_no]			= A.apivc_chk_no,
	[apchk_A4GLIdentity]	= A.apchk_A4GLIdentity
FROM tmp_apivcmstImport A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
LEFT JOIN apchkmst E ON A.apchk_A4GLIdentity = E.A4GLIdentity
WHERE (A.apivc_status_ind = 'P' OR ISNULL(A.apivc_chk_no,'') != '') AND A.apchk_A4GLIdentity IS NULL
--UNION ALL
----CREATE UNPAID PREPAYMENT RECORD (ysnPrepay) 
--SELECT
--	[intAccountId]			= D.intGLAccountId,
--	[intBankAccountId]		= D.intBankAccountId,
--	[intPaymentMethodId]	= CASE
--									WHEN ISNULL(E.apchk_chk_amt,0) > 0 THEN 
--										CASE 
--											WHEN LEFT(E.apchk_chk_no, 1) = 'E' THEN @eft
--											WHEN LEFT(E.apchk_chk_no, 1) = 'W' THEN @wire
--											WHEN ISNULL(E.apchk_trx_ind,'C') = 'C' THEN @check --DEFAULT TO CHECK IF PAYMENT IS MISSING
--											ELSE @withdrawal
--										END
--									WHEN ISNULL(E.apchk_chk_amt,0) < 0 THEN @deposit
--									WHEN ISNULL(E.apchk_chk_amt,0) = 0 THEN @debitmemosandpayments
--								END,
--	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = D.intBankAccountId), @defaultCurrencyId),
--	[intEntityVendorId]		= B.intEntityVendorId,
--	[strPaymentInfo]		= A.apivc_chk_no,
--	[strNotes]				= NULL,
--	[dtmDatePaid]			= CASE WHEN ISDATE(E.apchk_rev_dt) = 1 
--										THEN CONVERT(DATE, CAST(E.apchk_rev_dt AS CHAR(12)), 112) 
--									WHEN ISDATE(A.apivc_gl_rev_dt) = 1 
--										THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) --USE VOUCHER DATE IF CHECK DATE IS INVALID
--									ELSE GETDATE() END,
--	[dblAmountPaid]			= ABS((E.apchk_chk_amt)), --IF MISSING PAYMENT, USE THE NET AMOUNT (THE DISCOUNT IS DEDUCTED)
--	[dblUnapplied]			= 0,
--	[ysnPosted]				= 1,
--	[dblWithheld]			= 0,
--	[intEntityId]			= @UserId,
--	[intConcurrencyId]		= 0,
--	[ysnOrigin]				= 1,
--	[ysnPrepay]				= 1,
--	[apivc_vnd_no]			= E.apchk_vnd_no,
--	[apivc_chk_rev_dt]		= E.apchk_rev_dt,
--	[apivc_cbk_no]			= E.apchk_cbk_no,
--	[apivc_chk_no]			= E.apchk_chk_no,
--	[apchk_A4GLIdentity]	= E.A4GLIdentity
--FROM tmp_apivcmstImport A
--INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
--INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no COLLATE Latin1_General_CS_AS
--INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
--INNER JOIN apchkmst E ON E.apchk_chk_no = A.apivc_chk_no COLLATE Latin1_General_CS_AS
--WHERE (A.apivc_status_ind = 'U' AND A.apivc_trans_type = 'A' AND E.apchk_adv_chk_yn = 'Y')
UNION ALL
--CREATE PAID PREPAYMENT RECORD (ysnPrepay)
SELECT
	[intAccountId]			= D.intGLAccountId,
	[intBankAccountId]		= D.intBankAccountId,
	[intPaymentMethodId]	= CASE
									WHEN ISNULL(E.apchk_chk_amt,0) > 0 THEN 
										CASE 
											WHEN LEFT(E.apchk_chk_no, 1) = 'E' THEN @eft
											WHEN LEFT(E.apchk_chk_no, 1) = 'W' THEN @wire
											WHEN ISNULL(E.apchk_trx_ind,'C') = 'C' THEN @check --DEFAULT TO CHECK IF PAYMENT IS MISSING
											ELSE @withdrawal
										END
									WHEN ISNULL(E.apchk_chk_amt,0) < 0 THEN @deposit
									WHEN ISNULL(E.apchk_chk_amt,0) = 0 THEN @debitmemosandpayments
								END,
	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = D.intBankAccountId), @defaultCurrencyId),
	[intEntityVendorId]		= B.intEntityId,
	[strPaymentInfo]		= E.apchk_chk_no,
	[strNotes]				= NULL,
	[dtmDatePaid]			= CASE WHEN ISDATE(E.apchk_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(E.apchk_rev_dt AS CHAR(12)), 112) 
									WHEN ISDATE(A.apivc_gl_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) --USE VOUCHER DATE IF CHECK DATE IS INVALID
									ELSE GETDATE() END,
	[dblAmountPaid]			= ABS((E.apchk_chk_amt)), --IF MISSING PAYMENT, USE THE NET AMOUNT (THE DISCOUNT IS DEDUCTED)
	[dblUnapplied]			= 0,
	[ysnPosted]				= 1,
	[dblWithheld]			= 0,
	[intEntityId]			= @UserId,
	[intConcurrencyId]		= 0,
	[ysnOrigin]				= 1,
	[ysnPrepay]				= 1,
	[apivc_vnd_no]			= E.apchk_vnd_no,
	[apivc_chk_rev_dt]		= E.apchk_rev_dt,
	[apivc_cbk_no]			= E.apchk_cbk_no,
	[apivc_chk_no]			= E.apchk_chk_no,
	[apchk_A4GLIdentity]	= E.A4GLIdentity
FROM tmp_apivcmstImport A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no COLLATE Latin1_General_CS_AS
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
INNER JOIN apchkmst E ON A.apivc_ivc_rev_dt = E.apchk_rev_dt 
	AND E.apchk_vnd_no = A.apivc_vnd_no COLLATE Latin1_General_CS_AS
	AND A.apivc_orig_amt = E.apchk_chk_amt
WHERE (A.apivc_status_ind = 'P' AND A.apivc_trans_type = 'A' AND E.apchk_adv_chk_yn = 'Y')
)

--TODO CREATE PAYMENT FOR PREPAYMENT

--CREATE PAYMENT
MERGE INTO tblAPPayment AS destination
USING
(
	SELECT 
		A.* 
	FROM PaymentSource A
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	[intAccountId],
	[intBankAccountId],
	[intPaymentMethodId],
	[intCurrencyId],
	[intEntityVendorId],
	[strPaymentInfo],
	--[strPaymentRecordNum],
	[strNotes],
	[dtmDatePaid],
	[dblAmountPaid],
	[dblUnapplied],
	[ysnPosted],
	[dblWithheld],
	[intEntityId],
	[intConcurrencyId],
	[ysnOrigin],
	[ysnPrepay]
)
VALUES
(
	[intAccountId],
	[intBankAccountId],
	[intPaymentMethodId],
	[intCurrencyId],
	[intEntityVendorId],
	[strPaymentInfo],
	--@pay + CAST(intPaymentRecordNum AS NVARCHAR),
	[strNotes],
	[dtmDatePaid],
	[dblAmountPaid],
	[dblUnapplied],
	[ysnPosted],
	[dblWithheld],
	[intEntityId],
	[intConcurrencyId],
	[ysnOrigin],
	[ysnPrepay]
)
OUTPUT 
	inserted.intPaymentId,
	--SourceData.intId
	--SourceData.apivc_ivc_no,
	SourceData.apivc_vnd_no,
	SourceData.apivc_chk_rev_dt,
	SourceData.apivc_cbk_no,
	SourceData.apivc_chk_no
INTO #tmpPaymentCreated;

SET @totalCreated = @@ROWCOUNT;

IF @totalCreated <= 0 
BEGIN
	ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

IF OBJECT_ID('tempdb..#tmpPaymentsWithRecordNumber') IS NOT NULL DROP TABLE #tmpPaymentsWithRecordNumber

--UPDATE THE PAYMENT METHOD FOR THOSE VOUCHERS THAT HAS BEEN PAID BUT NO PAYMENT RECORD ASSOCIATED

--UPDATE strPaymentRecordNumber
CREATE TABLE #tmpPaymentsWithRecordNumber
(
	intPaymentId INT NOT NULL,
	intRecordNumber INT NOT NULL
)

INSERT INTO #tmpPaymentsWithRecordNumber
SELECT
	A.intPaymentId,
	@paymentRecordNum + ROW_NUMBER() OVER(ORDER BY A.intPaymentId)
FROM tblAPPayment A
INNER JOIN #tmpPaymentCreated B ON A.intPaymentId = B.intPaymentId

UPDATE A
	SET A.strPaymentRecordNum = @pay + CAST(B.intRecordNumber AS NVARCHAR)
FROM tblAPPayment A
INNER JOIN #tmpPaymentsWithRecordNumber B ON A.intPaymentId = B.intPaymentId

ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);

--UPDATE STARTING NUMBER
UPDATE A
	SET A.intNumber = @paymentRecordNum + @totalCreated + 1
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 8

--INSERT PAYMENT DETAIL
MERGE INTO tblAPPaymentDetail AS destination
USING
(
	SELECT 
		[intPaymentId]	= B.intPaymentId,
		[intBillId]		= D.intBillId,
		[intAccountId]	= D.intAccountId,
		[dblDiscount]	= D.dblDiscount,
		[dblWithheld]	= A.apivc_wthhld_amt,
		[dblAmountDue]	= D.dblAmountDue,
		[dblPayment]	= ABS(A.apivc_net_amt),
		[dblInterest]	= D.dblInterest,
		[dblTotal]		= D.dblTotal
	FROM tmp_apivcmstImport A
	INNER JOIN #tmpPaymentCreated B 
		ON A.apivc_vnd_no = B.apivc_vnd_no
		AND A.apivc_chk_rev_dt = B.apivc_chk_rev_dt
		AND A.apivc_cbk_no = B.apivc_cbk_no
		AND A.apivc_chk_no = B.apivc_chk_no
	INNER JOIN tblAPapivcmst C ON A.intBackupId = C.intId
	INNER JOIN tblAPBill D ON C.intBillId = D.intBillId
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	[intPaymentId],
	[intBillId],
	[intAccountId],
	[dblDiscount],
	[dblWithheld],
	[dblAmountDue],
	[dblPayment],
	[dblInterest],
	[dblTotal]
)
VALUES
(
	[intPaymentId],
	[intBillId],
	[intAccountId],
	[dblDiscount],
	[dblWithheld],
	[dblAmountDue],
	[dblPayment],
	[dblInterest],
	[dblTotal]
);


--UPDATE ysnPrepay
--UPDATE A
--	SET A.ysnPrepay = CASE WHEN (SELECT intTransactionType 
--										FROM tblAPBill C INNER JOIN tblAPPaymentDetail D ON C.intBillId = D.intBillId 
--										WHERE D.intPaymentId = B.intPaymentId) = 2 
--								THEN 1 ELSE 0 END
--FROM tblAPPayment A
--INNER JOIN #tmpPaymentCreated B ON A.intPaymentId = B.intPaymentId
--CROSS APPLY (
--	SELECT 
--		COUNT(intPaymentDetailId) AS intCount
--	FROM tblAPPaymentDetail E
--	WHERE E.intPaymentId = B.intPaymentId
--) DetailCount
--WHERE DetailCount.intCount = 1

--UPDATE Bank Transaction
UPDATE tblCMBankTransaction
SET strTransactionId = B.strPaymentRecordNum,
	intPayeeId = C.intEntityId
FROM tblCMBankTransaction A
INNER JOIN tblAPPayment B
	ON A.dblAmount = (CASE WHEN A.intBankTransactionTypeId = 11 THEN (B.dblAmountPaid) * -1 ELSE B.dblAmountPaid END)
	AND A.dtmDate = B.dtmDatePaid
	AND A.intBankAccountId = B.intBankAccountId
	AND A.strReferenceNo = B.strPaymentInfo
INNER JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId)
	ON B.intEntityVendorId = C.intEntityId 
	--AND A.strPayee = D.strName
WHERE A.strSourceSystem IN ('AP','CW')
AND A.strTransactionId <> B.strPaymentRecordNum

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorImport NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION uspAPImportVoucherPayment
	RAISERROR(@errorImport, 16, 1);
END CATCH
