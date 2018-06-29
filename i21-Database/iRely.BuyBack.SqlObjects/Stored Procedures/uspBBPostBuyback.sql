CREATE PROCEDURE [dbo].[uspBBPostBuyback]
	@intBuyBackId INT
	,@intUserId INT
	,@strPostingError NVARCHAR(MAX) OUTPUT
	,@strCreatedInvoices NVARCHAR(MAX) OUTPUT
AS
	--DECLARE @intBuyBackId INT
	--DECLARE @intUserId INT
	--DECLARE @strPostingError NVARCHAR(MAX) 
 --   DECLARE @strCreatedInvoices NVARCHAR(MAX) 

	--SET @intBuyBackId = 2
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
	DECLARE @batchIdUsed NVARCHAR(100)
	DECLARE @APDate DATETIME
	DECLARE @intDetailAccount INT
	DECLARE @intAPAccount INT
	DECLARE @strCompanyLocation NVARCHAR(100)
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
			[strTransactionType]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,intEntityCustomerId
			,dtmDate
			,intEntityId
			,intCompanyLocationId
			,ysnPost
			,intItemId
			,[dblQtyShipped]
			,[dblPrice]
			,[intSalesAccountId]
			,[strItemDescription]
		)
		SELECT 
			[strTransactionType] = 'Debit Memo'
			,[strSourceTransaction] = 'Direct'
			,[intSourceId] = A.intBuybackId
			,[strSourceId] = A.strReimbursementNo
			,intEntityCustomerId = A.intEntityId
			,dtmDate = GETDATE()
			,intEntityId = @intUserId
			,intCompanyLocationId = CASE WHEN ISNULL(@CompanyLocation,0) = 0
										THEN (SELECT TOP 1 intWarehouseId FROM vyuARCustomerSearch WHERE intEntityId = A.intEntityId) 
									ELSE @CompanyLocation END
			,ysnPost = 1
			,intItemId = CASE WHEN B.strCharge = 'Inventory' THEN B.intItemId ELSE NULL END
			,[dblQtyShipped] = B.dblBuybackQuantity
			,[dblPrice] = B.dblBuybackRate
			,[intSalesAccountId] = ISNULL(@intDetailAccount,[dbo].[fnGetItemGLAccount](	B.intItemId
																						, (SELECT TOP 1 intItemLocationId FROM tblICItemLocation WHERE intItemId = B.intItemId AND intLocationId = @CompanyLocation)
																						, 'Sales Account'))
			,[strItemDescription] = CASE WHEN B.strCharge = 'Inventory' THEN NULL ELSE B.strCharge END
		FROM tblBBBuybackDetail B
		INNER JOIN tblBBBuyback A
			ON B.intBuybackId = A.intBuybackId
		INNER JOIN tblVRVendorSetup C
			ON A.intEntityId = C.intEntityId
		WHERE A.intBuybackId = @intBuyBackId

		EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries = @EntriesForInvoice
			,@UserId = @intUserId
			,@GroupingOption = 1
			,@RaiseError = 0
			,@LineItemTaxEntries = @LineItemTaxEntries
			,@ErrorMessage = @ErrorMessage OUTPUT
			,@CreatedIvoices = @CreatedIvoices OUTPUT
			,@UpdatedIvoices = @UpdatedIvoices OUTPUT
			,@BatchIdForNewPost = @batchIdUsed OUTPUT

		SELECT TOP 1 @ErrorMessage = strMessage 
		FROM tblARPostResult 
		WHERE strBatchNumber = @batchIdUsed

		IF(@ErrorMessage LIKE '%successfully posted%')
		BEGIN
			SET @ErrorMessage = ''
		END


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
		-----AP Reimbursement Type
		SELECT TOP 1
			@strReimbursementNo = strReimbursementNo
		FROM tblBBBuyback

		---Check for AP account int company location
		SELECT TOP 1 
			@intAPAccount = intAPAccount 
			,@strCompanyLocation = strLocationName
		FROM tblSMCompanyLocation WHERE intCompanyLocationId =  @CompanyLocation

		IF(@intAPAccount IS NULL)
		BEGIN
			SET @strPostingError = 'Invalid default AP Account for company location "' + @strCompanyLocation + '".'
			GOTO ENDPOST
		END

		---Staging 
		SELECT 
			[intAccountId]	=  ISNULL(@intDetailAccount,[dbo].[fnGetItemGLAccount](	B.intItemId
																						, C.intItemLocationId
																						, 'Sales Account'))
			,[intItemId]	= CASE WHEN A.strCharge = 'Inventory' THEN A.intItemId ELSE NULL END
			,[strMiscDescription]  = CASE WHEN A.strCharge = 'Inventory' THEN B.strDescription ELSE A.strCharge END
			,[dblQtyReceived] = A.dblBuybackQuantity	
			,[dblCost]	 = A.dblBuybackRate	
		INTO #tmpStagingInsert
		FROM tblBBBuybackDetail A
		INNER JOIN tblICItem B
			ON A.intItemId = B.intItemId
		INNER JOIN tblICItemLocation C
			ON B.intItemId = C.intItemId
				AND intLocationId =  @CompanyLocation
		WHERE intBuybackId = @intBuyBackId


		---Check for Other Charge income account.
		IF EXISTS(SELECT TOP 1 1 FROM #tmpStagingInsert WHERE intAccountId IS NULL)
		BEGIN
			SET @strPostingError = 'Invalid G/L account id found.'
			GOTO ENDPOST
		END


		-- insert
		INSERT INTO @voucherNonInvDetails(
			[intAccountId]		
			,[intItemId]			
			,[strMiscDescription]
			,[dblQtyReceived]	
			,[dblCost]			
		)	
		SELECT 
			[intAccountId]	
			,[intItemId]
			,[strMiscDescription]
			,[dblQtyReceived]
			,[dblCost]
		FROM #tmpStagingInsert 
		
	

		SET @APDate = GETDATE()
		EXEC [dbo].[uspAPCreateBillData]
			@userId	= @intUserId
			,@vendorId = @intVendorId
			,@type = 3	
			,@vendorOrderNumber = @strReimbursementNo
			,@voucherDate = @APDate
			,@voucherNonInvDetails = @voucherNonInvDetails
			,@billId = @intCreatedBillId OUTPUT
			,@error = @ErrorMessage OUTPUT
			,@throwError = 0
		
		IF(ISNULL(@ErrorMessage,'') <> '')
		BEGIN
			SET @strPostingError = @ErrorMessage
			GOTO ENDPOST
		END


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
		,@batchIdUsed = @batchIdUsed OUTPUT

		IF(@ysnSuccess = 0)
		BEGIN
			SELECT TOP 1
				@strPostingError = strMessage
			FROM tblAPPostResult
			WHERE strBatchNumber = @batchIdUsed
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
		ENDPOST:

	END
GO
