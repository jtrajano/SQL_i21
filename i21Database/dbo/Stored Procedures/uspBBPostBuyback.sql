﻿
CREATE PROCEDURE [dbo].[uspBBPostBuyback]
	@intBuyBackId INT
	,@intUserId INT
	,@strPostingError NVARCHAR(MAX) OUTPUT
	,@strCreatedInvoices NVARCHAR(MAX) OUTPUT
AS
	--DECLARE @intBuyBackId INT
	--DECLARE @intUserId INT

	--SET @intBuyBackId = 29
	--SET @intUserId =1

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @LineItemTaxEntries LineItemTaxDetailStagingTable
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @CreatedIvoices NVARCHAR(MAX)
	DECLARE @UpdatedIvoices NVARCHAR(MAX)
	DECLARE @CompanyLocation INT
	DECLARE @ysnSuccess BIT
	DECLARE @strReimbursementType NVARCHAR(5)
	DECLARE @intVendorId INT
	DECLARE @strReimbursementNo NVARCHAR(100)
	DECLARE @voucherNonInvDetails AS VoucherDetailNonInventory
	DECLARE @intCreatedBillId INT
	DECLARE @APbatchIdUsed NVARCHAR(100)
	DECLARE @APDate DATETIME
	DECLARE @intDetailAccount INT
	SET @ysnSuccess = 0

	SET @strReimbursementType = 'AR'
	SELECT TOP 1 
		@strReimbursementType = strReimbursementType
		,@intVendorId = intEntityId
		,@intDetailAccount = intAccountId
	FROM tblVRVendorSetup WHERE intEntityId = (
												SELECT TOP 1 intEntityId 
												FROM tblBBBuyback 
												WHERE intBuybackId = @intBuyBackId
											  )

	--Get Company Location
	SET @CompanyLocation = dbo.fnGetUserDefaultLocation(@intUserId)

	IF(@strReimbursementType = 'AR')
	BEGIN
		INSERT INTO @EntriesForInvoice(
			[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,intEntityCustomerId
			,dtmDate
			,intEntityId
			,intCompanyLocationId
			,ysnPost
			--,intItemId
			,[dblQtyShipped]
			,[dblPrice]
			,[intSalesAccountId]
		)
		SELECT 
			[strSourceTransaction] = 'Direct'
			,[intSourceId] = A.intBuybackId
			,[strSourceId] = A.strReimbursementNo
			,intEntityCustomerId = A.intEntityId
			,dtmDate = GETDATE()
			,intEntityId = @intUserId
			,intCompanyLocationId = CASE WHEN ISNULL(@CompanyLocation,0) = 0
										THEN (SELECT TOP 1 intWarehouseId FROM vyuARCustomerSearch WHERE intEntityId = A.intEntityId) 
									ELSE @CompanyLocation END
			,ysnPost = 1
			--,intItemId = B.intItemId
			,[dblQtyShipped] = 1
			,[dblPrice] = B.dblReimbursementAmount
			,[intSalesAccountId] = @intDetailAccount
		FROM tblBBBuybackCharge B
		INNER JOIN tblBBBuyback A
			ON B.intBuybackId = A.intBuybackId
		WHERE A.intBuybackId = @intBuyBackId

		EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
			,@UserId = @intUserId
			,@GroupingOption = 1
			,@RaiseError = 1
			,@LineItemTaxEntries = @LineItemTaxEntries
			,@ErrorMessage = @ErrorMessage OUTPUT
			,@CreatedIvoices = @CreatedIvoices OUTPUT
			,@UpdatedIvoices = @UpdatedIvoices OUTPUT

		IF(ISNULL(@ErrorMessage,'') = '')
		BEGIN
			UPDATE tblBBBuyback
			SET intInvoiceId = @CreatedIvoices
				,ysnPosted = 1
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intBuybackId = @intBuyBackId

			UPDATE tblARInvoiceDetail
			SET dblBuybackAmount = A.dblReimbursementAmount
				,dblBaseBuybackAmount = A.dblReimbursementAmount * dblCurrencyExchangeRate
				,strBuybackSubmitted = 'Y'
			FROM (SELECT 
					dblReimbursementAmount = SUM(dblReimbursementAmount)
					,intInvoiceDetailId
					FROM tblBBBuybackDetail
					WHERE intBuybackId = @intBuyBackId
					GROUP BY intInvoiceDetailId
					) A
			WHERE tblARInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId


			SET @ysnSuccess = 1
		END

		SET @strPostingError = ISNULL(@ErrorMessage,'')
		SET @strCreatedInvoices = ISNULL(@CreatedIvoices,'')
	END
	ELSE 
	BEGIN
		SELECT TOP 1
			@strReimbursementNo = strReimbursementNo
		FROM tblBBBuyback

		INSERT INTO @voucherNonInvDetails(
			[intAccountId]		
			--,[intItemId]			
			,[strMiscDescription]
			,[dblQtyReceived]	
			,[dblCost]			
		)	
		SELECT 
			[intAccountId]	=  ISNULL(@intDetailAccount,[dbo].[fnGetItemGLAccount](1, C.intItemLocationId, 'Other Charge Income'))
			--,[intItemId]	= A.intItemId	
			,[strMiscDescription]  = B.strDescription
			,[dblQtyReceived] = 1	
			,[dblCost]	 = A.dblReimbursementAmount		
		FROM tblBBBuybackCharge A
		INNER JOIN tblICItem B
			ON 1 = B.intItemId
		INNER JOIN tblICItemLocation C
			ON B.intItemId = C.intItemId
				AND intLocationId =  @CompanyLocation
		WHERE intBuybackId = @intBuyBackId

		SET @APDate = GETDATE()
		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intVendorId
			,@type = 3	
			,@vendorOrderNumber = strReimbursementNo
			,@voucherDate = @APDate
			,@voucherNonInvDetails = @voucherNonInvDetails
			,@billId = @intCreatedBillId OUTPUT

		UPDATE tblAPBillDetail
		SET intBuybackChargeId = A.intBuybackChargeId
		FROM tblBBBuybackCharge A
		WHERE A.intBuybackId = @intBuyBackId
			AND tblAPBillDetail.intItemId = 1
			AND tblAPBillDetail.intBillId = @intCreatedBillId

		SET @strCreatedInvoices = @intCreatedBillId

		--Post voucher
		EXEC [dbo].[uspAPPostBill]
		@post = 1
		,@recap = 0
		,@isBatch = 0
		,@param = @intCreatedBillId
		,@userId = @intUserId
		,@success = @ysnSuccess OUTPUT
		,@batchIdUsed = @APbatchIdUsed OUTPUT

		IF(@ysnSuccess = 0)
		BEGIN
			SELECT TOP 1
				@strPostingError = strMessage
			FROM tblAPPostResult
			WHERE strBatchNumber = @APbatchIdUsed
		END
		ELSE
		BEGIN
			--Update BB
			UPDATE tblBBBuyback
			SET intBillId = @intCreatedBillId
				,ysnPosted = 1
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intBuybackId = @intBuyBackId

			UPDATE tblARInvoiceDetail
			SET dblBuybackAmount = A.dblReimbursementAmount
				,dblBaseBuybackAmount = A.dblReimbursementAmount * dblCurrencyExchangeRate
				,strBuybackSubmitted = 'Y'
			FROM (SELECT 
					dblReimbursementAmount = SUM(dblReimbursementAmount)
					,intInvoiceDetailId
					FROM tblBBBuybackDetail
					WHERE intBuybackId = @intBuyBackId
					GROUP BY intInvoiceDetailId
					) A
			WHERE tblARInvoiceDetail.intInvoiceDetailId = A.intInvoiceDetailId
		END
	END
GO
