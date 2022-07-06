CREATE PROCEDURE [dbo].[uspPATCreateVoucherForPaidEquity]
	@equityPay				INT = NULL,
	@equityPaymentIds		NVARCHAR(MAX) = NULL,
	@intUserId				INT = NULL,
	@intAPClearing			INT = NULL,
	@successfulCount		INT = 0 OUTPUT,
	@strErrorMessage		NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount			INT = 0 OUTPUT,
	@bitSuccess				BIT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tempEquityPayments(
	[intEquityPayId] INT,
	[strPaymentNumber] NVARCHAR(50),
	[dtmPaymentDate] DATETIME,
	[intEquityPaySummaryId] INT,
	[intCustomerPatronId] INT,
	[ysnQualified] BIT,
	[strName] NVARCHAR(100),
	[ysnVendor] BIT,
	[dblEquityPaid] NUMERIC(18,6),
	[ysnPriorYear] BIT
)

CREATE TABLE #tempVoucherReference(
	[intBillId] INT NOT NULL,
	[intPatronageId] INT NOT NULL
)

IF(@equityPaymentIds = 'all')
	BEGIN
		INSERT INTO #tempEquityPayments
		SELECT intEquityPayId			= EP.intEquityPayId
			 , strPaymentNumber			= EP.strPaymentNumber
			 , dtmPaymentDate			= EP.dtmPaymentDate
			 , intEquityPaySummaryId	= EPS.intEquityPaySummaryId
			 , intCustomerPatronId		= EPS.intCustomerPatronId
			 , ysnQualified				= EPS.ysnQualified
			 , strName					= EM.strName
			 , ysnVendor				= APV.Vendor
			 , dblEquityPaid			= EPS.dblEquityPaid
			 , ysnPriorYear =	CASE WHEN CAST(GLFYP.strFiscalYear AS INT) > CAST(GLFY.strFiscalYear AS INT) THEN 1 ELSE 0 END
		FROM tblPATEquityPay EP
		INNER JOIN tblPATEquityPaySummary EPS ON EPS.intEquityPayId = EP.intEquityPayId
		INNER JOIN tblEMEntity EM ON EM.intEntityId = EPS.intCustomerPatronId
		LEFT OUTER JOIN vyuEMEntityType APV ON APV.intEntityId = EPS.intCustomerPatronId
		OUTER APPLY (
			SELECT TOP 1 strFiscalYear
			FROM tblGLFiscalYear
			WHERE intFiscalYearId = EP.intFiscalYearId
		) GLFY
		OUTER APPLY (
			SELECT TOP 1 strFiscalYear
			FROM tblGLFiscalYear
			WHERE EP.dtmPaymentDate BETWEEN dtmDateFrom AND dtmDateTo
		) GLFYP
		WHERE EP.intEquityPayId = @equityPay
		  AND EPS.intBillId IS NULL
	END
ELSE
	BEGIN
		INSERT INTO #tempEquityPayments
		SELECT intEquityPayId			= EP.intEquityPayId
			 , strPaymentNumber			= EP.strPaymentNumber
			 , dtmPaymentDate			= EP.dtmPaymentDate
			 , intEquityPaySummaryId	= EPS.intEquityPaySummaryId
			 , intCustomerPatronId		= EPS.intCustomerPatronId
			 , ysnQualified				= EPS.ysnQualified
			 , strName					= EM.strName
			 , ysnVendor				= APV.Vendor
			 , dblEquityPaid			= EPS.dblEquityPaid
			 , ysnPriorYear =	CASE WHEN CAST(GLFYP.strFiscalYear AS INT) > CAST(GLFY.strFiscalYear AS INT) THEN 1 ELSE 0 END
		FROM tblPATEquityPay EP
		INNER JOIN tblPATEquityPaySummary EPS ON EPS.intEquityPayId = EP.intEquityPayId
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@equityPaymentIds) DV ON EPS.intEquityPaySummaryId = DV.intID
		INNER JOIN tblEMEntity EM ON EM.intEntityId = EPS.intCustomerPatronId
		LEFT OUTER JOIN vyuEMEntityType APV ON APV.intEntityId = EPS.intCustomerPatronId
		OUTER APPLY (
			SELECT TOP 1 strFiscalYear
			FROM tblGLFiscalYear
			WHERE intFiscalYearId = EP.intFiscalYearId
		) GLFY
		OUTER APPLY (
			SELECT TOP 1 strFiscalYear
			FROM tblGLFiscalYear
			WHERE EP.dtmPaymentDate BETWEEN dtmDateFrom AND dtmDateTo
		) GLFYP
		WHERE EPS.intBillId IS NULL
	END

IF NOT EXISTS(SELECT TOP 1 1 FROM #tempEquityPayments)
	BEGIN
		SET @strErrorMessage = 'There are no vouchers to process.';
		RAISERROR(@strErrorMessage, 16, 1);
		GOTO Post_Exit;
	END

DECLARE @voucherPayable AS VoucherPayable;
DECLARE @voucherPayableTax AS VoucherDetailTax;
DECLARE @createdVouchersId AS NVARCHAR(MAX);
DECLARE @dtmDate DATETIME = GETDATE();
DECLARE @intEquityPaySummaryId INT;
DECLARE @intCustomerPatronId INT;
DECLARE @dblEquityPay NUMERIC(18,6);
DECLARE @strVenderOrderNumber NVARCHAR(MAX);
DECLARE @intCreatedBillId INT;
DECLARE @batchId AS NVARCHAR(40);
DECLARE @qualified BIT;
DECLARE @shipToLocation INT = [dbo].[fnGetUserDefaultLocation](@intUserId);
DECLARE @equityPayments AS Id;
DECLARE @totalRecords AS INT = 0;
DECLARE @voucherId AS Id;
DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
DECLARE @PAID_EQUITY NVARCHAR(25) = 'Paid Equity';

SELECT @invalidCount = COUNT(*) FROM #tempEquityPayments WHERE ysnVendor = 0;

IF(@invalidCount > 0)
BEGIN
	DECLARE @customerName NVARCHAR(50);
	SELECT TOP 1 @customerName = strName FROM #tempEquityPayments WHERE ysnVendor = 0;
	SET @strErrorMessage = 'Cannot create voucher for <strong>'+ @customerName +'</strong> as the entity is not marked as vendor';
	RAISERROR(@strErrorMessage, 16, 1);
	GOTO Post_Exit;
END

INSERT INTO @equityPayments
SELECT intEquityPaySummaryId 
FROM #tempEquityPayments
	
BEGIN TRAN;

BEGIN TRY
	--CREATE AND POST VOUCHER
	INSERT INTO @voucherPayable(
		  [intPartitionId]
		, [intEntityVendorId]
		, [intTransactionType]
		, [strVendorOrderNumber]
		, [strSourceNumber]
		, [strMiscDescription]
		, [intAccountId]
		, [dblQuantityToBill]
		, [dblCost]
		, [int1099Form]
		, [int1099Category]
		, [dbl1099]
		, [ysnStage]
	)
	SELECT [intPartitionId]			= EquityPay.intEquityPaySummaryId
		, [intEntityVendorId]		= EquityPay.intCustomerPatronId
		, [intTransactionType]		= 1
		, [strVendorOrderNumber]	= EquityPay.strPaymentNumber + '-' + CONVERT(NVARCHAR(MAX), EquityPay.intEquityPaySummaryId)
		, [strSourceNumber]			= EquityPay.strPaymentNumber
		, [strMiscDescription]		= 'Patronage Equity Payment'
		, [intAccountId]			= @intAPClearing
		, [dblQuantityToBill]		= 1
		, [dblCost]					= ROUND(EquityPay.dblEquityPaid, 2)
		, [int1099Form]				= CASE WHEN EquityPay.ysnQualified = 1 AND EquityPay.ysnPriorYear = 0 THEN 4 ELSE 0 END
		, [int1099Category]			= CASE WHEN EquityPay.ysnQualified = 1 AND EquityPay.ysnPriorYear = 0 THEN 5 ELSE 0 END
		, [dbl1099]					= CASE WHEN EquityPay.ysnQualified = 1 THEN ROUND(EquityPay.dblEquityPaid, 2) ELSE 0 END
		, [ysnStage]				= 0
	FROM #tempEquityPayments EquityPay	
			
	EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayable
									, @voucherPayableTax = @voucherPayableTax
									, @userId = @intUserId
									, @throwError = 0
									, @error = @strErrorMessage OUT
									, @createdVouchersId = @createdVouchersId OUT

	IF (@strErrorMessage != '')
	BEGIN
		RAISERROR (@strErrorMessage, 16, 1);
		GOTO Post_Rollback;
	END

	IF(@batchId IS NULL)
		EXEC uspSMGetStartingNumber 3, @batchId OUT

	EXEC [dbo].[uspAPPostBill] @batchId = @batchId
							 , @billBatchId = NULL
							 , @transactionType = NULL
							 , @post = 1
							 , @recap = 0
							 , @isBatch = 0
							 , @param = @createdVouchersId
							 , @userId = @intUserId
							 , @success = @bitSuccess OUTPUT

	IF(@bitSuccess = 0)
	BEGIN
		SELECT TOP 1 @strErrorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intCreatedBillId;
		RAISERROR (@strErrorMessage, 16, 1);
		GOTO Post_Rollback;
	END

	--UPDATE EQUITY PAYMENT LINK
	INSERT INTO #tempVoucherReference (
		  intBillId
		, intPatronageId
	)
	SELECT intBillId		= BILL.intBillId
		 , intPatronageId	= CAST(SUBSTRING([strVendorOrderNumber], CHARINDEX('-', [strVendorOrderNumber], CHARINDEX('-',[strVendorOrderNumber])+1) + 1, CHARINDEX('-',REVERSE([strVendorOrderNumber]))) AS INT)
	FROM tblAPBill BILL
	INNER JOIN [dbo].fnGetRowsFromDelimitedValues(@createdVouchersId) DV ON BILL.intBillId = DV.intID

	UPDATE EquityPayment
	SET EquityPayment.intBillId = VoucherRef.intBillId
	FROM tblPATEquityPaySummary EquityPayment
	INNER JOIN #tempVoucherReference VoucherRef ON VoucherRef.intPatronageId = EquityPayment.intEquityPaySummaryId

	--LINK TRANSACTION
	DECLARE @tblTransactionLinks    udtICTransactionLinks

	INSERT INTO @tblTransactionLinks (
		  intSrcId
		, strSrcTransactionNo
		, strSrcTransactionType
		, strSrcModuleName
		, intDestId
		, strDestTransactionNo
		, strDestTransactionType
		, strDestModuleName
		, strOperation
	)
	SELECT intSrcId					= EP.intEquityPayId
		, strSrcTransactionNo       = EP.strPaymentNumber
		, strSrcTransactionType     = @PAID_EQUITY
		, strSrcModuleName          = @MODULE_NAME
		, intDestId                 = BILL.intBillId
		, strDestTransactionNo      = BILL.strBillId
		, strDestTransactionType    = 'Voucher'
		, strDestModuleName         = 'Purchasing'
		, strOperation              = 'Process'
	FROM tblPATEquityPaySummary EPS
	INNER JOIN tblPATEquityPay EP ON EPS.intEquityPayId = EP.intEquityPayId
	INNER JOIN tblAPBill BILL ON BILL.intBillId = EPS.intBillId	
	WHERE EP.intEquityPayId = @equityPay
			
	EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks

	SELECT @totalRecords = COUNT(*)
	FROM #tempEquityPayments
END TRY

BEGIN CATCH
DECLARE @intErrorSeverity INT,
		@intErrorNumber   INT,
		@intErrorState INT;
		
SET @intErrorSeverity = ERROR_SEVERITY()
SET @intErrorNumber   = ERROR_NUMBER()
SET @strErrorMessage  = ERROR_MESSAGE()
SET @intErrorState    = ERROR_STATE()
RAISERROR (@strErrorMessage , @intErrorSeverity, @intErrorState, @intErrorNumber)
GOTO Post_Rollback
END CATCH

IF @@ERROR <> 0	GOTO Post_Rollback;

Post_Commit:
	COMMIT TRAN;
	SET @bitSuccess = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRAN;	
	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
END