CREATE PROCEDURE [dbo].[uspPATRefundVoucherToAPBill]
	 @intRefundId					INT
	,@intRefundCustomerId			INT
	,@intPatronId					INT
	,@dblRefundAmount				NUMERIC(18,6)
	,@dblServiceFee					NUMERIC(18,6)
	,@intUserId						INT
	,@intPaymentItemId				INT	
	,@intBillId						INT = 0
	,@bitSuccess					BIT = NULL OUTPUT
	,@strErrorMessage				NVARCHAR(MAX) = NULL OUTPUT
	,@intCreatedBillId				INT = NULL OUTPUT

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory
	DECLARE @intShipTo INT
	DECLARE @dtmDate DATETIME = GETDATE()
	DECLARE @intPatronageItemId INT 
	DECLARE @intVendorId INT
	DECLARE @strVendorOderNumber NVARCHAR(MAX)
	DECLARE @intAPClearingGLAccount INT
	DECLARE @intServiceFeeIncomeId INT

	SELECT	@strVendorOderNumber = 'PAT-' + CONVERT(VARCHAR, @intRefundId) + CONVERT(NVARCHAR(MAX),@intRefundCustomerId)
	SELECT	@intAPClearingGLAccount = intAPClearingGLAccount,
			@intServiceFeeIncomeId = intServiceFeeIncomeId
	FROM tblPATCompanyPreference

	-- Fill-up voucher details
	INSERT INTO @voucherDetailNonInventory
		([intAccountId] 
		,[intItemId] 
		,[strMiscDescription]
		,[dblQtyReceived]
		,[dblDiscount]
		,[dblCost]
		,[intTaxGroupId])
	VALUES
		(@intAPClearingGLAccount											
		,0					
		,'Patronage Refund'		
		,1												
		,0												
		,@dblRefundAmount								
		,NULL),
		(@intServiceFeeIncomeId
		,0
		,'Service Fee'
		,1
		,0
		,(@dblServiceFee * -1)
		,NULL)

	EXEC [dbo].[uspAPCreateBillData]
		 @userId	= @intUserId
		,@vendorId = @intPatronId
		,@type = 1	
		,@voucherNonInvDetails = @voucherDetailNonInventory
		,@shipTo = NULL
		,@vendorOrderNumber = @strVendorOderNumber
		,@voucherDate = @dtmDate
		,@billId = @intCreatedBillId OUTPUT

	UPDATE tblAPBillDetail SET int1099Form = 4, int1099Category= 0 WHERE intBillId = @intCreatedBillId

	EXEC [dbo].[uspAPPostBill]
		@batchId = @intCreatedBillId,
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

END TRY
BEGIN CATCH
	DECLARE @intErrorSeverity INT,
			@intErrorNumber   INT,
			@intErrorState INT;
		
	SET @intErrorSeverity = ERROR_SEVERITY()
	SET @intErrorNumber   = ERROR_NUMBER()
	SET @strErrorMessage  = ERROR_MESSAGE()
	SET @intErrorState    = ERROR_STATE()
	SET	@bitSuccess = 0
	RAISERROR (@strErrorMessage , @intErrorSeverity, @intErrorState, @intErrorNumber)
END CATCH
GO
