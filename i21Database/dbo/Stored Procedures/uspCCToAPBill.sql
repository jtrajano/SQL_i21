CREATE PROCEDURE [dbo].[uspCCTransactionToAPBill]
	 @intSiteHeaderId	INT
	,@userId			INT	
	,@post				BIT	= NULL
	,@recap				BIT	= NULL
	,@billId			INT = 0
	,@success			BIT = NULL OUTPUT
	,@errorMessage NVARCHAR(MAX) = NULL OUTPUT
	,@createdBillId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @voucherDetailCC AS VoucherDetailCC
	DECLARE @shipTo INT
	DECLARE @dtmDate DATETIME
	DECLARE @ccdReference NVARCHAR(50)
	DECLARE @vendorId INT

	SELECT @ccdReference = ccSiteHeader.strCcdReference
		, @dtmDate = ccSiteHeader.dtmDate
		, @shipTo = ccVendorDefault.intCompanyLocationId
		, @vendorId = ccVendorDefault.intVendorId
	FROM tblCCSiteHeader ccSiteHeader
	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

	INSERT INTO @voucherDetailCC([intBillId] 
		,[intAccountId] 
		,[intSiteDetailId] 
		,[strMiscDescription] 
		,[dblCost]
		,[dblQtyReceived])
	SELECT [intBillId] = @billId
		,[intAccountId] = ccSiteHeader.intBankAccountId
		,[intSiteDetailId] = ccSiteDetail.intSiteDetailId
		,[strMiscDescription] = ccSite.strSiteType
		,[dblCost] = ccSiteDetail.dblNet
		,[dblQtyReceived]  = ccSiteDetail.dblFees
	FROM tblCCSiteHeader ccSiteHeader
	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
	LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

	EXEC [dbo].[uspAPCreateBillData]
		 @userId	= @userId
		,@vendorId = @vendorId
		,@type = 3	
		,@shipTo = @shipTo
		,@vendorOrderNumber = @ccdReference
		,@voucherDate = @dtmDate
		,@voucherDetaiCC = @voucherDetailCC
		,@billId = @billId OUTPUT

	EXEC [dbo].[uspAPPostBill]
		@batchId = @billId,
		@billBatchId = NULL,
		@transactionType = NULL,
		@post = 1,
		@recap = 0,
		@isBatch = 0,
		@param = NULL,
		@userId = @userId,
		@beginTransaction = @billId,
		@endTransaction = @billId,
		@success = @success OUTPUT

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorState INT,
			@ErrorProc nvarchar(200);
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
