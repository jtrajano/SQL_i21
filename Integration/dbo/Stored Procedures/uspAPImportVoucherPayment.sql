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
DECLARE @check INT, @eft INT, @wire INT, @withdrawal INT, @deposit INT;
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

IF OBJECT_ID('tempdb..#tmpPaymentCreated') IS NOT NULL DROP TABLE #tmpPaymentCreated
CREATE TABLE #tmpPaymentCreated(intPaymentId INT, intId INT);

ALTER TABLE tblAPPayment DROP CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum]

--CREATE PAYMENT
MERGE INTO tblAPPayment AS destination
USING
(
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
								END,
	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = D.intBankAccountId), @defaultCurrencyId),
	[intEntityVendorId]		= B.intEntityVendorId,
	[strPaymentInfo]		= A.apivc_chk_no,
	[strNotes]				= NULL,
	[dtmDatePaid]			= CASE WHEN ISDATE(A.apivc_chk_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_chk_rev_dt AS CHAR(12)), 112) 
									WHEN ISDATE(A.apivc_gl_rev_dt) = 1 
										THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) --USE VOUCHER DATE IF CHECK DATE IS INVALID
									ELSE GETDATE() END,
	[dblAmountPaid]			= ISNULL(E.apchk_chk_amt, A.apivc_net_amt), --IF MISSING PAYMENT, USE THE NET AMOUNT (THE DISCOUNT IS DEDUCTED)
	[dblUnapplied]			= 0,
	[ysnPosted]				= 1,
	[dblWithheld]			= 0,
	[intEntityId]			= @UserId,
	[intConcurrencyId]		= 0,
	[intId]					= A.intId,
	[ysnOrigin]				= 1,
	[intPaymentRecordNum]	= (@paymentRecordNum + ROW_NUMBER() OVER(ORDER BY A.intId))
FROM tmp_apivcmstImport A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
LEFT JOIN apchkmst E ON A.apchk_A4GLIdentity = E.A4GLIdentity
WHERE A.apivc_status_ind = 'P' AND ISNULL(A.apivc_chk_no,'') != ''
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
	[strPaymentRecordNum],
	[strNotes],
	[dtmDatePaid],
	[dblAmountPaid],
	[dblUnapplied],
	[ysnPosted],
	[dblWithheld],
	[intEntityId],
	[intConcurrencyId],
	[ysnOrigin]
)
VALUES
(
	[intAccountId],
	[intBankAccountId],
	[intPaymentMethodId],
	[intCurrencyId],
	[intEntityVendorId],
	[strPaymentInfo],
	@pay + CAST(intPaymentRecordNum AS NVARCHAR),
	[strNotes],
	[dtmDatePaid],
	[dblAmountPaid],
	[dblUnapplied],
	[ysnPosted],
	[dblWithheld],
	[intEntityId],
	[intConcurrencyId],
	[ysnOrigin]
)
OUTPUT inserted.intPaymentId, SourceData.intId INTO #tmpPaymentCreated;

SET @totalCreated = @@ROWCOUNT;

ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);

IF @totalCreated <= 0 
BEGIN
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

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
		[dblPayment]	= A.apivc_net_amt,
		[dblInterest]	= 0,
		[dblTotal]		= D.dblTotal
	FROM tmp_apivcmstImport A
	INNER JOIN #tmpPaymentCreated B ON A.intId = B.intId
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
