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

DECLARE @ErrorSeverity INT,
		@ErrorNumber   INT,
		@ErrorState INT

BEGIN TRY

	DECLARE @voucherDetailCC AS VoucherDetailCC
	DECLARE @shipTo INT
	DECLARE @dtmDate DATETIME
	DECLARE @ccdReference NVARCHAR(50)
	DECLARE @vendorId INT
	DECLARE @CCRItemToAPItem TABLE
	(
		intSiteHeaderId int, 
		strItem nvarchar(100)
	)

	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Dealer Sites Net')
	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Gross')
	INSERT INTO @CCRItemToAPItem VALUES (@intSiteHeaderId,'Company Owned Fees')


	SELECT @ccdReference = ccSiteHeader.strCcdReference
		, @dtmDate = ccSiteHeader.dtmDate
		, @shipTo = ccVendorDefault.intCompanyLocationId
		, @vendorId = ccVendorDefault.intVendorId
	FROM tblCCSiteHeader ccSiteHeader
	INNER JOIN tblCCVendorDefault ccVendorDefault ON ccVendorDefault.intVendorDefaultId = ccSiteHeader.intVendorDefaultId
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

	INSERT INTO @voucherDetailCC([intAccountId] 
		,[intSiteDetailId] 
		,[strMiscDescription] 
		,[dblCost]
		,[dblQtyReceived])
	SELECT [intAccountId] = intAccountId
		,[intSiteDetailId] = intSiteDetailId
		,[strMiscDescription] = strItem
		,[dblCost] = SUM(dblCost)
		,[dblQtyReceived]  = CASE WHEN strItem = 'Company Owned Fees' THEN -1 ELSE 1 END
	FROM(
	SELECT 
		 ccSiteDetail.intSiteDetailId
		 ,ccItem.strItem
		 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSite.intAccountId 
			WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intCreditCardReceivableAccountId  
			WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSite.intFeeExpenseAccountId
			ELSE null END) AS intAccountId
		 ,(CASE WHEN ccItem.strItem = 'Dealer Sites Net' AND ccSite.strSiteType = 'Dealer Site' THEN ccSiteDetail.dblNet 
			WHEN ccItem.strItem = 'Company Owned Gross' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblGross 
			WHEN ccItem.strItem = 'Company Owned Fees' AND ccSite.strSiteType = 'Company Owned' THEN ccSiteDetail.dblFees 
			ELSE null END) AS dblCost
	FROM tblCCSiteHeader ccSiteHeader
	LEFT JOIN tblCCSiteDetail ccSiteDetail ON ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
	LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
	LEFT JOIN @CCRItemToAPItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId 
	WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId) A
	WHERE intAccountId IS NOT NULL
	GROUP BY  intAccountId, intSiteDetailId, strItem 

	EXEC [dbo].[uspAPCreateBillData]
		 @userId	= @userId
		,@vendorId = @vendorId
		,@type = 3	
		,@shipTo = @shipTo
		,@vendorOrderNumber = @ccdReference
		,@voucherDate = @dtmDate
		,@voucherDetaiCC = @voucherDetailCC
		,@billId = @createdBillId OUTPUT

		BEGIN TRY
			EXEC [dbo].[uspAPPostBill]
				@batchId = @createdBillId,
				@billBatchId = NULL,
				@transactionType = NULL,
				@post = 1,
				@recap = 0,
				@isBatch = 0,
				@param = NULL,
				@userId = @userId,
				@beginTransaction = @createdBillId,
				@endTransaction = @createdBillId,
				@success = @success OUTPUT
		END TRY
		BEGIN CATCH
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorNumber   = ERROR_NUMBER()
			SET @errorMessage  = ERROR_MESSAGE()
			SET @ErrorState    = ERROR_STATE()
			SET	@success = 0

			IF(@createdBillId IS NOT NULL)
				DELETE tblAPBill WHERE intBillId = @createdBillId

			RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		END CATCH
	
END TRY
BEGIN CATCH
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @errorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@errorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
