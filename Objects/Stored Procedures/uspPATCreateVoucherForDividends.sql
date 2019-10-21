CREATE PROCEDURE [dbo].[uspPATCreateVoucherForDividends]
	@intDividendId INT,
	@intUserId INT,
	@ysnPosted BIT,
	@dividendsCustomer NVARCHAR(MAX),
	@successfulCount INT = 0 OUTPUT,
	@strErrorMessage NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount INT = 0 OUTPUT,
	@bitSuccess BIT = 0 OUTPUT 

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


	CREATE TABLE #tempDivCust(
		intDividendId INT,
		strDividendNo NVARCHAR(50),
		intDividendCustomerId INT,
		intCustomerId INT,
		dblDividendAmount NUMERIC(18,6),
		dblLessFWT NUMERIC(18,6),
		dblCheckAmount NUMERIC(18,6)
	);
	
	CREATE TABLE #tempVoucherReference(
		[intBillId] INT NOT NULL,
		[intPatronageId] INT NOT NULL
	)

	BEGIN TRANSACTION

	IF(@dividendsCustomer = 'all')
	BEGIN
		INSERT INTO #tempDivCust 
		SELECT	D.intDividendId,
				D.strDividendNo,
				DC.intDividendCustomerId,
				DC.intCustomerId,
				DC.dblDividendAmount,
				DC.dblLessFWT,
				DC.dblCheckAmount
			FROM tblPATDividends D
		INNER JOIN tblPATDividendsCustomer DC
			ON DC.intDividendId = D.intDividendId
		WHERE D.intDividendId = @intDividendId AND DC.dblDividendAmount <> 0
	END
	ELSE
	BEGIN
		INSERT INTO #tempDivCust
		SELECT	D.intDividendId,
				D.strDividendNo,
				DC.intDividendCustomerId,
				DC.intCustomerId,
				DC.dblDividendAmount,
				DC.dblLessFWT,
				DC.dblCheckAmount
			FROM tblPATDividends D
		INNER JOIN tblPATDividendsCustomer DC
			ON DC.intDividendId = D.intDividendId
		WHERE DC.intDividendCustomerId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@dividendsCustomer)) AND DC.dblDividendAmount <> 0
	END

	DECLARE @voucherPayable AS VoucherPayable;
	DECLARE @createdVouchersId AS NVARCHAR(MAX);
	DECLARE @dtmDate DATETIME = GETDATE();
	DECLARE @intDivCustId INT;
	DECLARE @intPatronageItemId INT;
	DECLARE @intCustomerId INT;
	DECLARE @dblDividentAmt NUMERIC(18,6);
	DECLARE @strVenderOrderNumber NVARCHAR(MAX);
	DECLARE @intCreatedBillId INT;
	DECLARE @dividendCustomerIds AS Id;
	DECLARE @totalRecords AS INT = 0;
	DECLARE @batchId AS NVARCHAR(40);
	DECLARE @intAPClearingId AS INT;
	DECLARE @shipToLocation INT = [dbo].[fnGetUserDefaultLocation](@intUserId);

	DECLARE @voucherId as Id;

	INSERT INTO @dividendCustomerIds
	SELECT intDividendCustomerId FROM #tempDivCust
	
	SELECT TOP 1 @intAPClearingId = intAPClearingGLAccount FROM tblPATCompanyPreference;
	
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
		)
		SELECT	Dividends.intDividendCustomerId
				,Dividends.intCustomerId
				,intTransactionType = 1
				,strVendorOrderNumbe = '' + Dividends.strDividendNo + '-' + CONVERT(NVARCHAR(MAX),Dividends.intDividendCustomerId)
				,Dividends.strDividendNo
				,strMiscDescription = 'Patronage Dividend'
				,intAccountId = @intAPClearingId
				,dblQtyToBill = 1
				,dblCost = ROUND(Dividends.dblDividendAmount, 2)
				,int1099Form = 5
				,int1099Category = 0
				,dbl1099 = ROUND(Dividends.dblDividendAmount, 2)
		FROM #tempDivCust Dividends

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
			@success = @bitSuccess OUTPUT

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

		UPDATE DividendsCustomer
		SET DividendsCustomer.intBillId = VoucherRef.intBillId
		FROM tblPATDividendsCustomer DividendsCustomer
		INNER JOIN #tempVoucherReference VoucherRef
			ON VoucherRef.intPatronageId = DividendsCustomer.intDividendCustomerId

		SELECT @totalRecords = COUNT(*)
		FROM #tempDivCust

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

Post_Commit:
	COMMIT TRANSACTION
	SET @bitSuccess = 1
	SET @successfulCount = @totalRecords
	GOTO Post_Exit

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION	
	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
GO