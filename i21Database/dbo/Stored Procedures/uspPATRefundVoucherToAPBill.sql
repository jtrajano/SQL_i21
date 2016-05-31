CREATE PROCEDURE [dbo].[uspPATRefundVoucherToAPBill]
	 @intRefundId					INT
	,@intPatronId					INT
	,@dblRefundAmount				DECIMAL
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

	SELECT @strVendorOderNumber = 'PAT-' + CONVERT(VARCHAR,@intRefundId) + '-' + CONVERT(VARCHAR,GETDATE(),112) + CONVERT(VARCHAR,CAST((RAND() * (899999) + 100000) AS INT))

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
		(NULL											
		,@intPaymentItemId							
		,'Patronage Refund Voucher (Tax Inclusive)'		
		,1												
		,0												
		,@dblRefundAmount								
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
