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

	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory;
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

	DECLARE @voucherId as Id;

	INSERT INTO @dividendCustomerIds
	SELECT intDividendCustomerId FROM #tempDivCust
	
	BEGIN TRY

	SELECT TOP 1 @intAPClearingId = intAPClearingGLAccount FROM tblPATCompanyPreference;

	WHILE EXISTS(SELECT 1 FROM @dividendCustomerIds)
	BEGIN
		
		SELECT TOP 1 
			@intDivCustId = T.intDividendCustomerId,
			@intCustomerId = T.intCustomerId, 
			@dblDividentAmt = ROUND(T.dblDividendAmount, 2),
			@strVenderOrderNumber = '' + T.strDividendNo + '-' + CONVERT(NVARCHAR(MAX),T.intDividendCustomerId)
			FROM @dividendCustomerIds Div INNER JOIN #tempDivCust T ON T.intDividendCustomerId = Div.intId

		INSERT INTO @voucherDetailNonInventory([intAccountId],[intItemId],[strMiscDescription],[dblQtyReceived],[dblDiscount],[dblCost],[intTaxGroupId])
			VALUES(@intAPClearingId,NULL,'Patronage Dividend', 1, 0, @dblDividentAmt, NULL)
			
		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intCustomerId
			,@type = 1	
			,@voucherNonInvDetails = @voucherDetailNonInventory
			,@shipTo = NULL
			,@vendorOrderNumber = @strVenderOrderNumber
			,@voucherDate = @dtmDate
			,@billId = @intCreatedBillId OUTPUT

			
		UPDATE tblPATDividendsCustomer SET intBillId = @intCreatedBillId WHERE intDividendCustomerId = @intDivCustId;
		UPDATE tblAPBillDetail SET int1099Form = 5, int1099Category = 0, dbl1099 = @dblDividentAmt WHERE intBillId = @intCreatedBillId;

		IF EXISTS(SELECT 1 FROM tblAPBillDetailTax WHERE intBillDetailId IN (SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = @intCreatedBillId))
		BEGIN
			INSERT INTO @voucherId SELECT intBillId FROM tblAPBill where intBillId = @intCreatedBillId;

			EXEC [dbo].[uspAPDeletePatronageTaxes] @voucherId;

			UPDATE tblAPBill SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);
			UPDATE tblAPBillDetail SET dblTax = 0 WHERE intBillId IN (SELECT intBillId FROM @voucherId);

			EXEC [dbo].[uspAPUpdateVoucherTotal] @voucherId;
			DELETE FROM @voucherId;
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
			@param = NULL,
			@userId = @intUserId,
			@beginTransaction = @intCreatedBillId,
			@endTransaction = @intCreatedBillId,
			@success = @bitSuccess OUTPUT


		DELETE FROM @dividendCustomerIds WHERE intId = @intDivCustId;
		DELETE FROM @voucherDetailNonInventory;
		SET @intCreatedBillId = NULL;

		SET @totalRecords = @totalRecords + 1;
	END
	
	IF @@ERROR <> 0	GOTO Post_Rollback;

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
	ROLLBACK TRANSACTION	
	SET @bitSuccess = 0
	GOTO Post_Exit
Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tempDivCust')) DROP TABLE #tempDivCust
GO