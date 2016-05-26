CREATE PROCEDURE [dbo].[uspAPImportVoucherPayment]
	@UserId INT,
	@dateFrom DATETIME,
	@dateTo DATETIME
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @defaultCurrencyId INT;
DECLARE @check INT, @eft INT, @wire INT, @withdrawal INT, @deposit INT;

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspAPImportVoucherPayment

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

--MAKE SURE PAYMENT METHOD EXISTS BEFORE IMPORTING
MERGE INTO tblSMPaymentMethod AS Destination
USING
(
	SELECT strPaymentMethod = 'EFT', 1
	UNION ALL
	SELECT strPaymentMethod = 'Wire', 1
	UNION ALL
	SELECT strPaymentMethod = 'Check', 1
	UNION ALL
	SELECT strPaymentMethod = 'Withdrawal', 1
	UNION ALL
	SELECT strPaymentMethod = 'Deposit', 1
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

SELECT @check = intPaymentMethodId FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check'
SELECT @eft = intPaymentMethodId FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'eft'
SELECT @wire = intPaymentMethodId FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'wire'
SELECT @withdrawal = intPaymentMethodId FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'withdrawal'
SELECT @deposit = intPaymentMethodId FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'deposit'

--CREATE PAYMENT
CREATE TABLE #tmpBillsPayment
(
	[id] INT IDENTITY(1,1),
	[strCheckBookNo] NVARCHAR(4),
	[strVendorId] NVARCHAR(10),
	[dblAmount] DECIMAL(18,6),
	[dtmDate] DATETIME,
	[strCheckNo] NVARCHAR(16),
	[dblDiscount] DECIMAL(18,6),
	[strPaymentMethod] NVARCHAR(20),
	[strBills] NVARCHAR(MAX),
	CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([id] ASC)
);
CREATE NONCLUSTERED INDEX [IX_tmpBillsPayment_strVendorId] ON #tmpBillsPayment([strVendorId]);

INSERT INTO tblAPPayment
(
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
	[intConcurrencyId]
)
SELECT
	[intAccountId]			= E.intGLAccountId,
	[intBankAccountId]		= E.intBankAccountId,
	[intPaymentMethodId]	= CASE
									WHEN A.apchk_chk_amt > 0 THEN 
										CASE 
											WHEN LEFT(A.apchk_chk_no, 1) = 'E' THEN @eft
											WHEN LEFT(A.apchk_chk_no, 1) = 'W' THEN @wire
											WHEN A.apchk_trx_ind = 'C' THEN @check
											ELSE @withdrawal
										END
									WHEN A.apchk_chk_amt < 0 THEN @deposit
								END,
	[intCurrencyId]			= ISNULL((SELECT TOP 1 intCurrencyId FROM tblCMBankAccount WHERE intBankAccountId = E.intBankAccountId), @defaultCurrencyId),
	[intEntityVendorId]		= C.intEntityVendorId,
	[strPaymentInfo]		= B.apchk_chk_no,
	[strNotes]				= NULL,
	[dtmDatePaid]			= CASE WHEN ISDATE(B.apchk_rev_dt) = 1 THEN CONVERT(DATE, CAST(B.apchk_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dblAmountPaid]			= B.apchk_chk_amt,
	[dblUnapplied]			= 0,
	[ysnPosted]				= 1,
	[dblWithheld]			= 0,
	[intEntityId]			= @UserId,
	[intConcurrencyId]		= 0
FROM tmp_apivcmstImport A
INNER JOIN apchkmst D ON A.apchk_A4GLIdentity = D.A4GLIdentity
INNER JOIN tblAPapivcmst B ON A.intBackupId = B.intId
INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
INNER JOIN tblCMBankAccount E ON D.apchk_cbk_no = E.strCbkNo COLLATE Latin1_General_CS_AS

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
