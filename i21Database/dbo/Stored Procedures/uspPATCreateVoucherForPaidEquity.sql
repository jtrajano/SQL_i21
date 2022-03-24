CREATE PROCEDURE [dbo].[uspPATCreateVoucherForPaidEquity]
	@equityPay INT = NULL,
	@equityPaymentIds NVARCHAR(MAX) = NULL,
	@intUserId INT = NULL,
	@intAPClearing INT = NULL,
	@successfulCount INT = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@bitSuccess BIT = 0 OUTPUT
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
	SELECT	 EP.intEquityPayId
			,EP.strPaymentNumber
			,EP.dtmPaymentDate
			,EPS.intEquityPaySummaryId
			,EPS.intCustomerPatronId
			,EPS.ysnQualified
			,EM.strName
			,ysnVendor = APV.Vendor
			,EPS.dblEquityPaid
			,ysnPriorYear =	CASE WHEN CAST(GLFYP.strFiscalYear AS INT) > CAST(GLFY.strFiscalYear AS INT) THEN 1 ELSE 0 END
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	INNER JOIN tblEMEntity EM
		ON EM.intEntityId = EPS.intCustomerPatronId
	LEFT OUTER JOIN vyuEMEntityType APV 
		ON APV.intEntityId = EPS.intCustomerPatronId
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
	SELECT	 EP.intEquityPayId
			,EP.strPaymentNumber
			,EP.dtmPaymentDate
			,EPS.intEquityPaySummaryId
			,EPS.intCustomerPatronId
			,EPS.ysnQualified
			,EM.strName
			,ysnVendor = APV.Vendor
			,EPS.dblEquityPaid
			,ysnPriorYear =	CASE WHEN CAST(GLFYP.strFiscalYear AS INT) > CAST(GLFY.strFiscalYear AS INT) THEN 1 ELSE 0 END
	FROM tblPATEquityPay EP
	INNER JOIN tblPATEquityPaySummary EPS
		ON EPS.intEquityPayId = EP.intEquityPayId
	INNER JOIN tblEMEntity EM
		ON EM.intEntityId = EPS.intCustomerPatronId
	LEFT OUTER JOIN vyuEMEntityType APV 
		ON APV.intEntityId = EPS.intCustomerPatronId
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
	WHERE EPS.intEquityPaySummaryId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@equityPaymentIds)) 
		AND EPS.intBillId IS NULL
END

	IF NOT EXISTS(SELECT TOP 1 1 FROM #tempEquityPayments)
	BEGIN
		SET @strErrorMessage = 'There are no vouchers to process.';
		RAISERROR(@strErrorMessage, 16, 1);
		GOTO Post_Exit;
	END

	DECLARE @voucherPayable AS VoucherPayable;
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
	SELECT intEquityPaySummaryId FROM #tempEquityPayments
	
	DECLARE @voucherId AS Id;
	
	BEGIN TRAN;

	BEGIN TRY 

		INSERT INTO @voucherPayable(
				[intPartitionId]
				,[intEntityVendorId]
				,[intTransactionType]
				,[strVendorOrderNumber]
				,[strSourceNumber]
				,[strMiscDescription]
				,[intAccountId]
				,[dblQuantityToBill]
				,[dblCost]
				,[int1099Form]
				,[int1099Category]
				,[dbl1099]
				,[ysnStage]
		)
		SELECT	EquityPay.intEquityPaySummaryId
				,EquityPay.intCustomerPatronId
				,intTransactionType = 1
				,strVendorOrderNumber = EquityPay.strPaymentNumber + '-' + CONVERT(NVARCHAR(MAX), EquityPay.intEquityPaySummaryId)
				,strSourceNumber = EquityPay.strPaymentNumber
				,strMiscDescription = 'Patronage Equity Payment'
				,intAccountId = @intAPClearing
				,dblQtyToBill = 1
				,dblCost = ROUND(EquityPay.dblEquityPaid, 2)
				,int1099Form = CASE 
									WHEN EquityPay.ysnQualified = 1 AND EquityPay.ysnPriorYear = 0 THEN 4
									ELSE 0
								END
				,int1099Category = CASE 
									WHEN EquityPay.ysnQualified = 1 AND EquityPay.ysnPriorYear = 0 THEN 5
									ELSE 0
								END
				,dbl1099 = CASE 
								WHEN EquityPay.ysnQualified = 1 THEN ROUND(EquityPay.dblEquityPaid, 2)
								ELSE 0
							END
				,0
		FROM #tempEquityPayments EquityPay

		EXEC [dbo].[uspAPCreateVoucher]
			@voucherPayables = @voucherPayable
			,@userId = @intUserId
			,@throwError = 0
			,@error = @strErrorMessage OUT
			,@createdVouchersId = @createdVouchersId OUT

		IF (@strErrorMessage != '')
		BEGIN
			RAISERROR (@strErrorMessage, 16, 1);
			GOTO Post_Rollback;
		END

		IF(@batchId IS NULL)
			EXEC uspSMGetStartingNumber 3, @batchId OUT

		EXEC [dbo].[uspAPPostBill]
			@batchId = @batchId,
			@billBatchId = NULL,
			@transactionType = NULL,
			@post = 1,
			@recap = 0,
			@isBatch = 0,
			@param = @createdVouchersId,
			@userId = @intUserId,
			@success = @bitSuccess OUTPUT;

		IF(@bitSuccess = 0)
		BEGIN
			SELECT TOP 1 @strErrorMessage = strMessage FROM tblAPPostResult WHERE intTransactionId = @intCreatedBillId;
			RAISERROR (@strErrorMessage, 16, 1);
			GOTO Post_Rollback;
		END

		INSERT INTO #tempVoucherReference(intBillId, intPatronageId)
		SELECT	intBillId
				,CAST(SUBSTRING([strVendorOrderNumber], CHARINDEX('-', [strVendorOrderNumber], CHARINDEX('-',[strVendorOrderNumber])+1) + 1, CHARINDEX('-',REVERSE([strVendorOrderNumber]))) AS INT)
		FROM tblAPBill Bill
		WHERE intBillId IN (SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVouchersId))


		UPDATE EquityPayment
		SET EquityPayment.intBillId = VoucherRef.intBillId
		FROM tblPATEquityPaySummary EquityPayment
		INNER JOIN #tempVoucherReference VoucherRef
			ON VoucherRef.intPatronageId = EquityPayment.intEquityPaySummaryId

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