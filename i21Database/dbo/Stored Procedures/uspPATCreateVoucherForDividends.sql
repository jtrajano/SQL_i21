CREATE PROCEDURE [dbo].[uspPATCreateVoucherForDividends]
	@intDividendId		INT,
	@intUserId			INT,
	@ysnPosted			BIT,
	@dividendsCustomer	NVARCHAR(MAX),
	@successfulCount	INT = 0 OUTPUT,
	@strErrorMessage	NVARCHAR(MAX) = NULL OUTPUT,
	@invalidCount		INT = 0 OUTPUT,
	@bitSuccess			BIT = 0 OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

CREATE TABLE #tempDivCust (
	  intDividendId			INT
	, strDividendNo			NVARCHAR(50)
	, intDividendCustomerId INT
	, intCustomerId			INT
	, dblDividendAmount		NUMERIC(18,6)
	, dblLessFWT			NUMERIC(18,6)
	, dblCheckAmount		NUMERIC(18,6)
)
	
CREATE TABLE #tempVoucherReference(
	  intBillId			INT NOT NULL
	, intPatronageId	INT NOT NULL
)

BEGIN TRANSACTION
	IF(@dividendsCustomer = 'all')
	BEGIN
		INSERT INTO #tempDivCust 
		SELECT intDividendId			= D.intDividendId
			 , strDividendNo			= D.strDividendNo
			 , intDividendCustomerId	= DC.intDividendCustomerId
			 , intCustomerId			= DC.intCustomerId
			 , dblDividendAmount		= DC.dblDividendAmount
			 , dblLessFWT				= DC.dblLessFWT
			 , dblCheckAmount			= DC.dblCheckAmount
		FROM tblPATDividends D
		INNER JOIN tblPATDividendsCustomer DC ON DC.intDividendId = D.intDividendId
		WHERE D.intDividendId = @intDividendId 
		  AND DC.dblDividendAmount <> 0
	END
	ELSE
	BEGIN
		INSERT INTO #tempDivCust
		SELECT intDividendId			= D.intDividendId
			 , strDividendNo			= D.strDividendNo
			 , intDividendCustomerId	= DC.intDividendCustomerId
			 , intCustomerId			= DC.intCustomerId
			 , dblDividendAmount		= DC.dblDividendAmount
			 , dblLessFWT				= DC.dblLessFWT
			 , dblCheckAmount			= DC.dblCheckAmount
		FROM tblPATDividends D
		INNER JOIN tblPATDividendsCustomer DC ON DC.intDividendId = D.intDividendId
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@dividendsCustomer) DV ON DC.intDividendCustomerId = DV.intID
		WHERE DC.dblDividendAmount <> 0
	END

	DECLARE @voucherPayable AS VoucherPayable;
	DECLARE @voucherPayableTax AS VoucherDetailTax;
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
	DECLARE @MODULE_NAME NVARCHAR(25) = 'Patronage';
	DECLARE @DIVIDEND NVARCHAR(25) = 'Dividend';

	INSERT INTO @dividendCustomerIds
	SELECT intDividendCustomerId 
	FROM #tempDivCust
	
	SELECT TOP 1 @intAPClearingId = intAPClearingGLAccount 
	FROM tblPATCompanyPreference
	
	BEGIN TRY	
		INSERT INTO @voucherPayable (
			  intPartitionId
			, intEntityVendorId
			, intTransactionType
			, strVendorOrderNumber
			, strSourceNumber
			, strMiscDescription
			, intAccountId
			, dblQuantityToBill
			, dblCost
			, int1099Form
			, int1099Category
			, dbl1099
		)
		SELECT intDividendCustomerId	= D.intDividendCustomerId
			, intCustomerId				= D.intCustomerId
			, intTransactionType		= 1
			, strVendorOrderNumber		= '' + D.strDividendNo + '-' + CONVERT(NVARCHAR(MAX),D.intDividendCustomerId)
			, strSourceNumber			= D.strDividendNo
			, strMiscDescription		= 'Patronage Dividend'
			, intAccountId				= @intAPClearingId
			, dblQtyToBill				= 1
			, dblCost					= ROUND(D.dblDividendAmount, 2)
			, int1099Form				= 5
			, int1099Category			= 0
			, dbl1099					= ROUND(D.dblDividendAmount, 2)
		FROM #tempDivCust D

		EXEC uspAPCreateVoucher @voucherPayables = @voucherPayable
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

		EXEC uspAPPostBill @batchId = @batchId
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

		INSERT INTO #tempVoucherReference (
			  intBillId
			, intPatronageId
		)
		SELECT intBillId		= BILL.intBillId
		     , intPatronageId	= CAST(SUBSTRING([strVendorOrderNumber], CHARINDEX('-', [strVendorOrderNumber], CHARINDEX('-',[strVendorOrderNumber])+1) + 1, CHARINDEX('-',REVERSE([strVendorOrderNumber]))) AS INT)
		FROM tblAPBill BILL
		INNER JOIN dbo.fnGetRowsFromDelimitedValues(@createdVouchersId) DV ON BILL.intBillId = DV.intID

		UPDATE DC
		SET intBillId = VR.intBillId
		FROM tblPATDividendsCustomer DC
		INNER JOIN #tempVoucherReference VR ON VR.intPatronageId = DC.intDividendCustomerId

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
		SELECT intSrcId					= D.intDividendId
			, strSrcTransactionNo       = D.strDividendNo
			, strSrcTransactionType     = @DIVIDEND
			, strSrcModuleName          = @MODULE_NAME
			, intDestId                 = BILL.intBillId
			, strDestTransactionNo      = BILL.strBillId
			, strDestTransactionType    = 'Voucher'
			, strDestModuleName         = 'Purchasing'
			, strOperation              = 'Process'
		FROM tblPATDividends D
		INNER JOIN tblPATDividendsCustomer DC ON D.intDividendId = DC.intDividendId
		INNER JOIN tblAPBill BILL ON BILL.intBillId = DC.intBillId	
		WHERE D.intDividendId = @intDividendId
			
		EXEC dbo.uspICAddTransactionLinks @tblTransactionLinks

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