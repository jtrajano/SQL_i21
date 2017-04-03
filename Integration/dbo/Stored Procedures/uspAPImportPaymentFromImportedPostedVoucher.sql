/*
	This will import payment from imported posted voucher without payment.
*/
CREATE PROCEDURE [dbo].[uspAPImportPaymentFromImportedPostedVoucher]
	@UserId INT
AS

BEGIN TRY

--DECLARE @UserId INT = 1
DECLARE @totalCreated INT
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION importMissingPayment

IF OBJECT_ID('dbo.tmp_apivcmstImport2') IS NOT NULL DROP TABLE tmp_apivcmstImport2

CREATE TABLE tmp_apivcmstImport2(
	[apivc_vnd_no] [char](10) NOT NULL,
	[apivc_ivc_no] [char](18) NOT NULL,
	[apivc_status_ind] [char](1) NOT NULL,
	[apivc_cbk_no] [char](2) NOT NULL,
	[apivc_chk_no] [char](50) NOT NULL,
	[apivc_trans_type] [char](1) NULL,
	[apivc_pay_ind] [char](1) NULL,
	[apivc_ap_audit_no] [smallint] NULL,
	[apivc_pur_ord_no] [char](8) NULL,
	[apivc_po_rcpt_seq] [smallint] NULL,
	[apivc_ivc_rev_dt] [int] NULL,
	[apivc_disc_rev_dt] [int] NULL,
	[apivc_due_rev_dt] [int] NULL,
	[apivc_chk_rev_dt] [int] NULL,
	[apivc_gl_rev_dt] [int] NULL,
	[apivc_orig_amt] [decimal](11, 2) NULL,
	[apivc_disc_avail] [decimal](11, 2) NULL,
	[apivc_disc_taken] [decimal](11, 2) NULL,
	[apivc_wthhld_amt] [decimal](11, 2) NULL,
	[apivc_net_amt] [decimal](11, 2) NULL,
	[apivc_1099_amt] [decimal](11, 2) NULL,
	[apivc_comment] [char](30) NULL,
	[apivc_adv_chk_no] [int] NULL,
	[apivc_recur_yn] [char](1) NULL,
	[apivc_currency] [char](3) NULL,
	[apivc_currency_rt] [decimal](15, 8) NULL,
	[apivc_currency_cnt] [char](8) NULL,
	[apivc_user_id] [char](16) NULL,
	[apivc_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[apchk_A4GLIdentity] INT NULL,
	[intBackupId]			INT NULL, --Use this to update the linking between the back up and created voucher
	[intId]			INT IDENTITY(1,1) NOT NULL,
	 CONSTRAINT [k_tmpapivcmst2] PRIMARY KEY NONCLUSTERED 
	(
		[apivc_vnd_no] ASC,
		[apivc_ivc_no] ASC
	)
)

DECLARE @totalVoucher INT

--GET ALL VOUCHERS
INSERT INTO tmp_apivcmstImport2
(
	[apivc_vnd_no]			,
	[apivc_ivc_no]			,
	[apivc_status_ind]		,
	[apivc_cbk_no]			,
	[apivc_chk_no]			,
	[apivc_trans_type]		,
	[apivc_pay_ind]			,
	[apivc_ap_audit_no]		,
	[apivc_pur_ord_no]		,
	[apivc_po_rcpt_seq]		,
	[apivc_ivc_rev_dt]		,
	[apivc_disc_rev_dt]		,
	[apivc_due_rev_dt]		,
	[apivc_chk_rev_dt]		,
	[apivc_gl_rev_dt]		,
	[apivc_orig_amt]		,
	[apivc_disc_avail]		,
	[apivc_disc_taken]		,
	[apivc_wthhld_amt]		,
	[apivc_net_amt]			,
	[apivc_1099_amt]		,
	[apivc_comment]			,
	[apivc_adv_chk_no]		,
	[apivc_recur_yn]		,
	[apivc_currency]		,
	[apivc_currency_rt]		,
	[apivc_currency_cnt]	,
	[apivc_user_id]			,
	[apivc_user_rev_dt]		,
	[A4GLIdentity]			,
	[apchk_A4GLIdentity]	
)
SELECT
	[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
	[apivc_ivc_no]			=	A.[apivc_ivc_no]		,
	[apivc_status_ind]		=	A.[apivc_status_ind]	,
	[apivc_cbk_no]			=	A.[apivc_cbk_no]		,
	[apivc_chk_no]			=	CASE WHEN PaymentInfo.A4GLIdentity IS NULL 
									THEN dbo.fnTrim(A.apivc_vnd_no) + '-' + dbo.fnTrim(A.apivc_ivc_no) + '-' + dbo.fnTrim(A.apivc_cbk_no)
								ELSE A.[apivc_chk_no] END,
	[apivc_trans_type]		=	A.[apivc_trans_type]	,
	[apivc_pay_ind]			=	A.[apivc_pay_ind]		,
	[apivc_ap_audit_no]		=	A.[apivc_ap_audit_no]	,
	[apivc_pur_ord_no]		=	A.[apivc_pur_ord_no]	,
	[apivc_po_rcpt_seq]		=	A.[apivc_po_rcpt_seq]	,
	[apivc_ivc_rev_dt]		=	A.[apivc_ivc_rev_dt]	,
	[apivc_disc_rev_dt]		=	A.[apivc_disc_rev_dt]	,
	[apivc_due_rev_dt]		=	A.[apivc_due_rev_dt]	,
	[apivc_chk_rev_dt]		=	A.[apivc_chk_rev_dt]	,
	[apivc_gl_rev_dt]		=	A.[apivc_gl_rev_dt]		,
	[apivc_orig_amt]		=	A.[apivc_orig_amt]		,
	[apivc_disc_avail]		=	A.[apivc_disc_avail]	,
	[apivc_disc_taken]		=	A.[apivc_disc_taken]	,
	[apivc_wthhld_amt]		=	A.[apivc_wthhld_amt]	,
	[apivc_net_amt]			=	A.[apivc_net_amt]		,
	[apivc_1099_amt]		=	A.[apivc_1099_amt]		,
	[apivc_comment]			=	A.[apivc_comment]		,
	[apivc_adv_chk_no]		=	A.[apivc_adv_chk_no]	,
	[apivc_recur_yn]		=	A.[apivc_recur_yn]		,
	[apivc_currency]		=	A.[apivc_currency]		,
	[apivc_currency_rt]		=	A.[apivc_currency_rt]	,
	[apivc_currency_cnt]	=	A.[apivc_currency_cnt]	,
	[apivc_user_id]			=	A.[apivc_user_id]		,
	[apivc_user_rev_dt]		=	A.[apivc_user_rev_dt]	,
	[A4GLIdentity]			=	A.[A4GLIdentity]		,
	[apchk_A4GLIdentity]	=	PaymentInfo.A4GLIdentity
FROM apivcmst A
OUTER APPLY (
	SELECT 
		G.A4GLIdentity
	FROM apchkmst G
	WHERE G.apchk_vnd_no = A.apivc_vnd_no
		AND G.apchk_chk_no = A.apivc_chk_no
		AND G.apchk_rev_dt = A.apivc_chk_rev_dt
		AND G.apchk_cbk_no = A.apivc_cbk_no
		AND G.apchk_alt_trx_ind != 'O'
) PaymentInfo
WHERE A.apivc_trans_type IN ('I', 'C', 'A')
AND A.apivc_pay_ind IS NULL AND A.apivc_chk_no IS NOT NULL AND A.apivc_trans_type != 'O' AND A.apivc_status_ind != 'R'
AND EXISTS (
	SELECT 1
	FROM tblAPBill B
	INNER JOIN tblAPVendor B2 ON B.intEntityVendorId = B2.intEntityId
	INNER JOIN tblAPapivcmst C ON B.intBillId = C.intBillId
	INNER JOIN apivcmst D ON B.strVendorOrderNumber = D.apivc_ivc_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND B2.strVendorId = D.apivc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE D.apivc_ivc_no = A.apivc_ivc_no AND D.apivc_vnd_no = A.apivc_vnd_no 
	AND B.ysnOrigin = 1 AND B.ysnPosted = 1 AND B.dblPayment > 0
	AND NOT EXISTS( --NO PAYMENT CREATED
		SELECT 1
		FROM tblAPPaymentDetail C
		WHERE C.intBillId = B.intBillId
	)
)

SET @totalVoucher = @@ROWCOUNT

PRINT CAST(@totalVoucher AS NVARCHAR) + ' total voucher.'

DECLARE @totalBackupIdUpdate INT;

--UPDATE BACK UP ID
UPDATE A
	SET A.intBackupId = A2.intId
FROM tmp_apivcmstImport2 A
INNER JOIN tblAPapivcmst A2 ON A.apivc_ivc_no = A2.apivc_ivc_no AND A.apivc_vnd_no = A2.apivc_vnd_no
AND EXISTS(
	SELECT 1
	FROM tblAPBill B
	INNER JOIN tblAPVendor B2 ON B.intEntityVendorId = B2.intEntityId
	WHERE B.ysnOrigin = 1 AND B.ysnPosted = 1 AND B.dblPayment > 0
	AND B.strVendorOrderNumber = A2.apivc_ivc_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND B2.strVendorId = A2.apivc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND NOT EXISTS( --NO PAYMENT
		SELECT 1
		FROM tblAPPaymentDetail C
		WHERE C.intBillId = B.intBillId
	)
)

SET @totalBackupIdUpdate = @@ROWCOUNT

PRINT CAST(@totalBackupIdUpdate AS NVARCHAR) + ' total backup id updated.'

DECLARE @totalCheckPayment INT;

--UPDATE ORIGIN PAYMENT ID
UPDATE A
	SET A.apchk_A4GLIdentity = A2.apchk_A4GLIdentity
FROM tblAPapivcmst A
INNER JOIN tmp_apivcmstImport2 A2 ON A.apivc_ivc_no = A2.apivc_ivc_no AND A.apivc_vnd_no = A2.apivc_vnd_no
AND EXISTS(
	SELECT 1
	FROM tblAPBill B
	INNER JOIN tblAPVendor B2 ON B.intEntityVendorId = B2.intEntityId
	WHERE B.ysnOrigin = 1 AND B.ysnPosted = 1 AND B.dblPayment > 0
	AND B.strVendorOrderNumber = A.apivc_ivc_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND B2.strVendorId = A.apivc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND NOT EXISTS( --NO PAYMENT
		SELECT 1
		FROM tblAPPaymentDetail C
		WHERE C.intBillId = B.intBillId
	)
)

SET @totalCheckPayment = @@ROWCOUNT

PRINT CAST(@totalCheckPayment AS NVARCHAR) + ' total records updated A4GL of check payment.'

--START CREATING PAYMENT
DECLARE @defaultCurrencyId INT;
--PAYMENT METHOD ID
DECLARE @check INT, @eft INT, @wire INT, @withdrawal INT, @deposit INT, @debitmemosandpayments INT;
--MISSING PAYMENT VARIABLES
DECLARE @defaultBankAccountId INT, @defaultBankGLAccountId INT;

DECLARE @pay NVARCHAR(50);
DECLARE @paymentRecordNum INT;

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

IF OBJECT_ID('tempdb..#tmpPaymentCreated2') IS NOT NULL DROP TABLE #tmpPaymentCreated2
CREATE TABLE #tmpPaymentCreated2(
		intPaymentId INT,
		--intId INT
		 --apivc_ivc_no CHAR(18) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_vnd_no CHAR(10) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_chk_rev_dt INT,
		 apivc_cbk_no CHAR(2) COLLATE SQL_Latin1_General_CP1_CS_AS,
		 apivc_chk_no CHAR(50) COLLATE SQL_Latin1_General_CP1_CS_AS
);
CREATE INDEX IDX_tmpPaymentCreated_Primary2 ON #tmpPaymentCreated2(apivc_vnd_no, apivc_chk_rev_dt, apivc_cbk_no, apivc_chk_no)

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
	--[intId]					= A.intId
	--[apivc_ivc_no]			= A.apivc_ivc_no,	
	[apivc_vnd_no]			= A.apivc_vnd_no,
	[apivc_chk_rev_dt]		= A.apivc_chk_rev_dt,
	[apivc_cbk_no]			= A.apivc_cbk_no,
	[apivc_chk_no]			= A.apivc_chk_no,
	[apchk_A4GLIdentity]	= A.apchk_A4GLIdentity
	--[intPaymentRecordNum]	= (@paymentRecordNum + ROW_NUMBER() OVER(ORDER BY A.intId))
FROM tmp_apivcmstImport2 A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
LEFT JOIN apchkmst E ON A.apchk_A4GLIdentity = E.A4GLIdentity
WHERE (A.apivc_status_ind = 'P' OR A.apivc_chk_no IS NOT NULL) AND A.apchk_A4GLIdentity IS NOT NULL
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
	--[intId]					= A.intId
	--[apivc_ivc_no]			= A.apivc_ivc_no,	
	[apivc_vnd_no]			= A.apivc_vnd_no,
	[apivc_chk_rev_dt]		= A.apivc_chk_rev_dt,
	[apivc_cbk_no]			= A.apivc_cbk_no,
	[apivc_chk_no]			= A.apivc_chk_no,
	[apchk_A4GLIdentity]	= A.apchk_A4GLIdentity
	--[intPaymentRecordNum]	= (@paymentRecordNum + ROW_NUMBER() OVER(ORDER BY A.intId))
FROM tmp_apivcmstImport2 A
INNER JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
INNER JOIN apcbkmst C ON A.apivc_cbk_no = C.apcbk_no
INNER JOIN tblCMBankAccount D ON A.apivc_cbk_no = D.strCbkNo COLLATE Latin1_General_CS_AS
LEFT JOIN apchkmst E ON A.apchk_A4GLIdentity = E.A4GLIdentity
WHERE (A.apivc_status_ind = 'P' OR A.apivc_chk_no IS NOT NULL) AND A.apchk_A4GLIdentity IS NULL
)

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
	--@pay + CAST(intPaymentRecordNum AS NVARCHAR),
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
OUTPUT 
	inserted.intPaymentId,
	--SourceData.intId
	--SourceData.apivc_ivc_no,
	SourceData.apivc_vnd_no,
	SourceData.apivc_chk_rev_dt,
	SourceData.apivc_cbk_no,
	SourceData.apivc_chk_no
INTO #tmpPaymentCreated2;

SET @totalCreated = @@ROWCOUNT;

IF @totalCreated <= 0 
BEGIN
	ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

IF OBJECT_ID('tempdb..#tmpPaymentsWithRecordNumber2') IS NOT NULL DROP TABLE #tmpPaymentsWithRecordNumber2

--UPDATE strPaymentRecordNumber
CREATE TABLE #tmpPaymentsWithRecordNumber2
(
	intPaymentId INT NOT NULL,
	intRecordNumber INT NOT NULL
)

INSERT INTO #tmpPaymentsWithRecordNumber2
SELECT
	A.intPaymentId,
	@paymentRecordNum + ROW_NUMBER() OVER(ORDER BY A.intPaymentId)
FROM tblAPPayment A
INNER JOIN #tmpPaymentCreated2 B ON A.intPaymentId = B.intPaymentId

UPDATE A
	SET A.strPaymentRecordNum = @pay + CAST(B.intRecordNumber AS NVARCHAR)
FROM tblAPPayment A
INNER JOIN #tmpPaymentsWithRecordNumber2 B ON A.intPaymentId = B.intPaymentId

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
		[dblPayment]	= D.dblPayment,
		[dblInterest]	= 0,
		[dblTotal]		= D.dblTotal
	FROM tmp_apivcmstImport2 A
	INNER JOIN #tmpPaymentCreated2 B 
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
UPDATE A
	SET A.ysnPrepay = CASE WHEN (SELECT intTransactionType 
										FROM tblAPBill C INNER JOIN tblAPPaymentDetail C2 ON C.intBillId = C2.intBillId 
										WHERE C2.intPaymentId = B.intPaymentId) = 2 
								THEN 1 ELSE 0 END
FROM tblAPPayment A
INNER JOIN #tmpPaymentCreated2 B ON A.intPaymentId = B.intPaymentId
CROSS APPLY (
	SELECT 
		COUNT(intPaymentDetailId) AS intCount
	FROM tblAPPaymentDetail E
	WHERE E.intPaymentId = B.intPaymentId
) DetailCount
WHERE DetailCount.intCount = 1

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

DELETE A
FROM tblAPBill A
WHERE EXISTS(
	SELECT B.intBillId
	FROM tblAPBill B
	INNER JOIN tblAPVendor B2 ON B.intEntityVendorId = B2.intEntityId
	LEFT JOIN apivcmst B3 ON B.strVendorOrderNumber = B3.apivc_ivc_no COLLATE SQL_Latin1_General_CP1_CS_AS
		AND B2.strVendorId = B3.apivc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
	WHERE B.ysnOrigin = 1 AND B.ysnPosted = 1 AND B.dblPayment > 0 
	AND NOT EXISTS( --NO PAYMENT
		SELECT 1
		FROM tblAPPaymentDetail C
		WHERE C.intBillId = B.intBillId
	)
	AND B.intBillId = A.intBillId
)

SELECT 
B3.apivc_trans_type,
B3.apivc_status_ind,
B.*
FROM tblAPBill B
INNER JOIN tblAPVendor B2 ON B.intEntityVendorId = B2.intEntityId
LEFT JOIN apivcmst B3 ON B.strVendorOrderNumber = B3.apivc_ivc_no COLLATE SQL_Latin1_General_CP1_CS_AS
	AND B2.strVendorId = B3.apivc_vnd_no COLLATE SQL_Latin1_General_CP1_CS_AS
WHERE B.ysnOrigin = 1 AND B.ysnPosted = 1 AND B.dblPayment > 0 
AND NOT EXISTS( --NO PAYMENT
	SELECT 1
	FROM tblAPPaymentDetail C
	WHERE C.intBillId = B.intBillId
)

SELECT
	B.strAccountId,
	CAST(SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)AS DECIMAL(18,2)) AS dblBalance
FROM vyuAPPayables A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
GROUP BY B.strAccountId

DECLARE @intPayablesCategory INT, @prepaymentCategory INT;

SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'
SELECT
	B.strAccountId,
	SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0))
FROM tblGLDetail A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
AND A.ysnIsUnposted = 0
GROUP BY B.strAccountId

SELECT * FROM vyuAPBillStatus WHERE strStatus != 'OK'

IF @transCount = 0 ROLLBACK TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorImport NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION importMissingPayment
	RAISERROR(@errorImport, 16, 1);
END CATCH