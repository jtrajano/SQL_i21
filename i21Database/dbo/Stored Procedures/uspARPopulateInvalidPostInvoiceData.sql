CREATE PROCEDURE [dbo].[uspARPopulateInvalidPostInvoiceData]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
	,@strSessionId		NVARCHAR(50) 	= NULL
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000 

DECLARE	@ZeroBit BIT
       ,@OneBit BIT       
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

DECLARE @ItemsForContracts [InvoicePostingTable]
EXEC dbo.uspARPostItemReservation @strSessionId = @strSessionId
EXEC [dbo].[uspARPopulateContractDetails] @Post = @Post, @strSessionId = @strSessionId

DECLARE @strDatabaseName NVARCHAR(50)
DECLARE @strCompanyName NVARCHAR(50)
DECLARE @intInvoiceId INT = 0

SELECT @intInvoiceId = intInvoiceId FROM tblARPostInvoiceHeader WHERE strSessionId = @strSessionId
SELECT @strDatabaseName = strDatabaseName, @strCompanyName = strCompanyName FROM [dbo].[fnARGetInterCompany](@intInvoiceId)

IF @Post = @OneBit
BEGIN
    DECLARE @InvoiceIds 						InvoiceId
	DECLARE @PostInvoiceDataFromIntegration		InvoicePostingTable
	DECLARE @ItemsForCosting 					ItemCostingTableType
	DECLARE @ItemsForCostingZeroCostValidation 	ItemCostingTableType
	DECLARE @ItemsForInTransitCosting 			ItemInTransitCostingTableType
	DECLARE @ItemsForStoragePosting 			ItemCostingTableType
	DECLARE  @DueToAccountId				INT
			,@DueFromAccountId				INT
			,@AllowSingleLocationEntries	BIT
			,@AllowIntraCompanyEntries		BIT
			,@AllowIntraLocationEntries		BIT
			,@FreightRevenueAccount			INT
			,@FreightExpenseAccount			INT
			,@SurchargeRevenueAccount		INT
			,@SurchargeExpenseAccount		INT
			,@OverrideLineOfBusinessSegment	BIT
			,@OverrideCompanySegment		BIT
			,@OverrideLocationSegment		BIT

	IF @Recap = @ZeroBit	
		EXEC dbo.uspARPostItemReservation
	
	EXEC [dbo].[uspARPopulateItemsForCosting] @strSessionId = @strSessionId
	EXEC [dbo].[uspARPopulateItemsForInTransitCosting] @strSessionId = @strSessionId
	EXEC [dbo].[uspARPopulateItemsForStorageCosting] @strSessionId = @strSessionId
	EXEC [dbo].[uspARGenerateEntriesForAccrual] @strSessionId = @strSessionId
	EXEC [dbo].[uspARGenerateGLEntriesForInvoices] @strSessionId = @strSessionId

	SELECT TOP 1
		 @AllowSingleLocationEntries	= ISNULL([ysnAllowSingleLocationEntries], 0)
		,@AllowIntraCompanyEntries		= ISNULL(ysnAllowIntraCompanyEntries, 0)
		,@AllowIntraLocationEntries		= ISNULL(ysnAllowIntraLocationEntries, 0)
		,@DueToAccountId				= ISNULL([intDueToAccountId], 0)
		,@DueFromAccountId				= ISNULL([intDueFromAccountId], 0)
		,@FreightRevenueAccount			= ISNULL([intFreightRevenueAccount], 0)
		,@FreightExpenseAccount			= ISNULL([intFreightExpenseAccount], 0)
		,@SurchargeRevenueAccount		= ISNULL([intSurchargeRevenueAccount], 0)
		,@SurchargeExpenseAccount		= ISNULL([intSurchargeExpenseAccount], 0)
		,@OverrideLineOfBusinessSegment	= ISNULL([ysnOverrideLineOfBusinessSegment], 0)
		,@OverrideCompanySegment		= ISNULL([ysnOverrideCompanySegment], 0)
		,@OverrideLocationSegment		= ISNULL([ysnOverrideLocationSegment], 0)
	FROM tblARCompanyPreference
	
	INSERT INTO tblARPostInvalidInvoiceData (
		  [intInvoiceId]
		, [strInvoiceNumber]
		, [strTransactionType]
		, [intInvoiceDetailId]
		, [intItemId]
		, [strBatchId]
		, [strPostingError]
		, [strSessionId]
	)
	SELECT [intInvoiceId]			= I.[intInvoiceId]
		 , [strInvoiceNumber]		= I.[strInvoiceNumber]		
		 , [strTransactionType]		= I.[strTransactionType]
		 , [intInvoiceDetailId]		= I.[intInvoiceDetailId] 
		 , [intItemId]				= I.[intItemId] 
		 , [strBatchId]				= I.[strBatchId]
		 , [strPostingError]		= 'Negative stock quantity is not allowed for Negative Stock at In-Transit Location.'
		 , [strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I WITH (NOLOCK)
	INNER JOIN (
		SELECT DISTINCT COSTING.intTransactionId
		     		  , COSTING.strTransactionId
		FROM tblARPostItemsForInTransitCosting COSTING WITH (NOLOCK)
		INNER JOIN (
			SELECT ICT.strTransactionId
				 , ICT.intTransactionId
				 , ICT.intLotId
				 , ICT.intItemId
				 , dblAvailableQty	= SUM(CASE WHEN ICT.intLotId IS NULL THEN ISNULL(IAC.dblStockIn, 0) - ISNULL(IAC.dblStockOut, 0) ELSE ISNULL(IL.dblStockIn, 0) - ISNULL(IL.dblStockOut, 0) END)
			FROM tblICInventoryTransaction ICT WITH (NOLOCK)
			LEFT JOIN tblICInventoryActualCost IAC WITH (NOLOCK) ON ICT.strTransactionId = IAC.strTransactionId AND ICT.intTransactionId = IAC.intTransactionId AND ICT.intTransactionDetailId = IAC.intTransactionDetailId
			LEFT JOIN tblICInventoryLot IL WITH (NOLOCK) ON ICT.strTransactionId = IL.strTransactionId AND ICT.intTransactionId = IL.intTransactionId AND ICT.intTransactionDetailId = IL.intTransactionDetailId AND ICT.intLotId = IL.intLotId AND ICT.intItemLocationId = IL.intItemLocationId
			WHERE ICT.ysnIsUnposted = 0
			  AND ISNULL(IL.ysnIsUnposted, 0) = 0
  			  AND ISNULL(IAC.ysnIsUnposted, 0) = 0  
			  AND ICT.intInTransitSourceLocationId IS NOT NULL
			GROUP BY ICT.strTransactionId, ICT.intTransactionId, ICT.intLotId, ICT.intItemId
		) ICT ON ICT.strTransactionId = COSTING.strSourceTransactionId	
		     AND ICT.intTransactionId = COSTING.intSourceTransactionId
			 AND (ICT.intLotId IS NULL OR (ICT.intLotId IS NOT NULL AND ICT.intLotId = COSTING.intLotId))
			 AND ABS(COSTING.dblQty) > dbo.fnRoundBanker(ICT.dblAvailableQty,6)
			 AND ICT.intItemId = COSTING.intItemId
		WHERE COSTING.strSessionId = @strSessionId
	) INTRANSIT ON I.intInvoiceId = INTRANSIT.intTransactionId AND I.strInvoiceNumber = INTRANSIT.strTransactionId
	OUTER APPLY (
		SELECT intLoadId
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		WHERE ARI.intInvoiceId = I.intOriginalInvoiceId
	) IL
	WHERE I.strTransactionType = 'Invoice'
	AND (I.[ysnFromProvisional] = 0 OR (I.[ysnFromProvisional] = 1 AND IL.[intLoadId] IS NULL))
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--ALREADY POSTED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The transaction is already posted.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[ysnPosted] = @OneBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData (
		  [intInvoiceId]
		, [strInvoiceNumber]
		, [strTransactionType]
		, [intInvoiceDetailId]
		, [intItemId]
		, [strBatchId]
		, [strPostingError]
		,[strSessionId]
	)
	SELECT [intInvoiceId]			= I.[intInvoiceId]
		 , [strInvoiceNumber]		= I.[strInvoiceNumber]		
		 , [strTransactionType]		= I.[strTransactionType]
		 , [intInvoiceDetailId]		= I.[intInvoiceDetailId] 
		 , [intItemId]				= I.[intItemId] 
		 , [strBatchId]				= I.[strBatchId]
		 , [strPostingError]		= 'Post date cannot be earlier than load shipment scheduled date.'
		 ,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	INNER JOIN tblLGLoadDetail LGLD ON I.intLoadDetailId = LGLD.intLoadDetailId
	INNER JOIN tblLGLoad LGL ON LGLD.intLoadId = LGL.intLoadId
	WHERE I.dtmPostDate < CAST(LGL.dtmScheduledDate AS DATE)

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--DUPLICATE BATCH ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Duplicate Batch ID'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE EXISTS(SELECT strBatchId FROM tblGLDetail WHERE strBatchId = @BatchId)
	  AND I.strSessionId = @strSessionId
	
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Recurring Invoice
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Posting recurring invoice(' + I.[strInvoiceNumber] + ') is not allowed.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[ysnRecurring] = @OneBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Inactive Ship to or Bill to Location
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN SHIPTO.ysnActive = 0 THEN 'Ship to Location ' + SHIPTO.strLocationName + ' is not active.'
									   WHEN BILLTO.ysnActive = 0 THEN 'Bill to Location ' + BILLTO.strLocationName + ' is not active.'
								  END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblEMEntityLocation SHIPTO ON INV.intShipToLocationId = SHIPTO.intEntityLocationId
	INNER JOIN tblEMEntityLocation BILLTO ON INV.intBillToLocationId = BILLTO.intEntityLocationId
	WHERE (SHIPTO.ysnActive = 0 OR BILLTO.ysnActive = 0)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--If ysnAllowUserSelfPost is True in User Role
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot Post transactions you did not create.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intEntityId] <> I.[intUserId]
	  AND I.[ysnUserAllowedToPostOtherTrans] = 1
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	-- Tank consumption site
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find a tank consumption site for item no. ' + I.[strItemNo]
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[intSiteId] IS NULL
	  AND I.[strType] = 'Tank Delivery'
	  AND I.[ysnTankRequired] = @OneBit
	  AND I.[strItemType] <> 'Comment'
	  AND I.strSessionId = @strSessionId
		
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--zero amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice ' THEN 'You cannot post an ' + I.[strTransactionType] + ' with zero amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with zero amount.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I					
	WHERE I.[dblInvoiceTotal] = @ZeroDecimal
	  AND I.[strTransactionType] <> 'Cash Refund'
	  AND (I.[strImportFormat] IS NULL OR I.[strImportFormat] <> 'CarQuest')
	  AND NOT EXISTS(SELECT NULL FROM tblARPostInvoiceDetail ARID WHERE ARID.[intInvoiceId] = I.[intInvoiceId] AND ARID.[intItemId] IS NOT NULL AND ARID.strSessionId = @strSessionId)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--zero amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice' THEN 'You cannot post an ' + I.[strTransactionType] + ' with negative amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with negative amount.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I					
	WHERE I.[dblInvoiceTotal] < @ZeroDecimal
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Zero Quantity
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot post an ' + I.[strTransactionType] + ' with a inventory item(' + I.[strItemDescription] + ') of zero quantity.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[dblQtyShipped] = @ZeroDecimal 
	  AND I.[ysnStockTracking] = @OneBit
	  AND I.[strType] NOT IN ('Transport Delivery', 'Tank Delivery')
	  AND I.strSessionId = @strSessionId
		
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Inactive Customer
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Customer - ' + I.[strCustomerNumber] + ' is not active!'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I	
	WHERE I.[ysnCustomerActive] = @ZeroBit
	  AND I.strSessionId = @strSessionId

	IF(ISNULL(@strDatabaseName, '') <> '')
	BEGIN
		--Check if vendor exists
		DECLARE @ysnVendorExistQuery nvarchar(500)
		DECLARE @ysnVendorExistParam NVARCHAR(500)
		DECLARE @ysnVendorExist BIT = 0 
		DECLARE @intInterCompanyVendorId INT
		DECLARE @strInterCompanyVendorId NVARCHAR(50)

		SELECT @strInterCompanyVendorId = [strInterCompanyVendorId], @intInterCompanyVendorId = [intInterCompanyVendorId] FROM tblARPostInvoiceHeader
		SELECT @ysnVendorExistQuery = N'SELECT @ysnVendorExist = 1 FROM [' + @strDatabaseName + '].[dbo].tblAPVendor WHERE intEntityId = ''' + CAST(@intInterCompanyVendorId AS NVARCHAR(50)) + ''''

		SET @ysnVendorExistParam = N'@ysnVendorExist int OUTPUT'

		EXEC sp_executesql @ysnVendorExistQuery, @ysnVendorExistParam, @ysnVendorExist = @ysnVendorExist OUTPUT

		IF(@ysnVendorExist = 0)
		BEGIN
			INSERT INTO tblARPostInvalidInvoiceData
				([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError]
				,[strSessionId])
			--Vendor not existing in inter-company database
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= 'Vendor - ' + I.strInterCompanyVendorId + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
				,[strSessionId]			= @strSessionId
			FROM tblARPostInvoiceHeader I
			WHERE strSessionId = @strSessionId
		END

		--Check if all items exists
		DECLARE @ysnAllItemsExistQuery nvarchar(500)
		DECLARE @ysnAllItemsExistParam NVARCHAR(500)
		DECLARE @ysnAllItemsExist BIT = 0
		DECLARE @intInterCompanyAllItemsId INT
		DECLARE @strInterCompanyAllItemsId NVARCHAR(50)

		IF(OBJECT_ID('tempdb..#ARInterCompanyItem') IS NOT NULL)
		BEGIN
			DROP TABLE #ARInterCompanyItem
		END

		CREATE TABLE #ARInterCompanyItem (
			[strItemNo]	NVARCHAR(25)
		)

		INSERT INTO #ARInterCompanyItem
		SELECT DISTINCT PID.strItemNo
		FROM tblARPostInvoiceDetail PID
		INNER JOIN tblICItem ICI
		ON PID.intItemId = ICI.intItemId

		WHILE EXISTS(SELECT TOP 1 NULL FROM #ARInterCompanyItem)
		BEGIN
			DECLARE @strInterCompanyItemNo NVARCHAR(50)
															
			SELECT TOP 1 @strInterCompanyItemNo = [strItemNo] 
			FROM #ARInterCompanyItem 

			SELECT @ysnAllItemsExistQuery = N'SELECT @ysnAllItemsExist = 1 FROM [' + @strDatabaseName + '].[dbo].tblICItem WHERE strItemNo = ''' + CAST(@strInterCompanyItemNo AS NVARCHAR(25)) + ''''

			SET @ysnAllItemsExistParam = N'@ysnAllItemsExist int OUTPUT'

			EXEC sp_executesql @ysnAllItemsExistQuery, @ysnAllItemsExistParam, @ysnAllItemsExist = @ysnAllItemsExist OUTPUT

			IF(@ysnAllItemsExist = 0)
			BEGIN
				INSERT INTO tblARPostInvalidInvoiceData
					([intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError]
					,[strSessionId])
				--Item not existing in inter-company database
				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= 'Item - ' + @strInterCompanyItemNo + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
					,[strSessionId]			= @strSessionId
				FROM tblARPostInvoiceHeader I
				WHERE strSessionId = @strSessionId
			END

			SET @ysnAllItemsExist = 0
												
			DELETE FROM #ARInterCompanyItem WHERE [strItemNo] = @strInterCompanyItemNo
		END

		--Check if all freight term exists
		DECLARE @ysnAllFreightTermsExistQuery nvarchar(500)
		DECLARE @ysnAllFreightTermsExistParam NVARCHAR(500)
		DECLARE @ysnAllFreightTermsExist BIT = 0
		DECLARE @intInterCompanyAllFreightTermsId INT
		DECLARE @strInterCompanyAllFreightTermsId NVARCHAR(50)

		IF(OBJECT_ID('tempdb..#ARInterCompanyFreightTerm') IS NOT NULL)
		BEGIN
			DROP TABLE #ARInterCompanyFreightTerm
		END

		CREATE TABLE #ARInterCompanyFreightTerm (
			[strFreightTerm]	NVARCHAR(100)
		)

		INSERT INTO #ARInterCompanyFreightTerm
		SELECT DISTINCT SMFT.strFreightTerm
		FROM tblARPostInvoiceDetail PID
		INNER JOIN tblSMFreightTerms SMFT
		ON PID.intFreightTermId = SMFT.intFreightTermId

		WHILE EXISTS(SELECT TOP 1 NULL FROM #ARInterCompanyFreightTerm)
		BEGIN
			DECLARE @strInterCompanyFreightTerm NVARCHAR(50)
															
			SELECT TOP 1 @strInterCompanyFreightTerm = [strFreightTerm] 
			FROM #ARInterCompanyFreightTerm 

			SELECT @ysnAllFreightTermsExistQuery = N'SELECT @ysnAllFreightTermsExist = 1 FROM [' + @strDatabaseName + '].[dbo].tblSMFreightTerms WHERE strFreightTerm = ''' + CAST(@strInterCompanyFreightTerm AS NVARCHAR(50)) + ''''

			SET @ysnAllFreightTermsExistParam = N'@ysnAllFreightTermsExist int OUTPUT'

			EXEC sp_executesql @ysnAllFreightTermsExistQuery, @ysnAllFreightTermsExistParam, @ysnAllFreightTermsExist = @ysnAllFreightTermsExist OUTPUT

			IF(@ysnAllFreightTermsExist = 0)
			BEGIN
				INSERT INTO tblARPostInvalidInvoiceData
					([intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError]
					,[strSessionId])
				--Freight term not existing in inter-company database
				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= 'Freight term - ' + @strInterCompanyFreightTerm + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
					,[strSessionId]			= @strSessionId
				FROM tblARPostInvoiceHeader I
				WHERE strSessionId = @strSessionId
			END

			SET @ysnAllFreightTermsExist = 0
												
			DELETE FROM #ARInterCompanyFreightTerm WHERE [strFreightTerm] = @strInterCompanyFreightTerm
		END
	END
			
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Customer Credit Limit
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]        
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]            = I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Customer credit limit is either blank or COD! Only Cash Sale transaction is allowed.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I 
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARCustomer CUS ON I.intEntityCustomerId = CUS.intEntityId
	WHERE CUS.strCreditCode = 'COD'
	  AND I.[strTransactionType] NOT IN ('Cash', 'Cash Refund')
	  AND I.[strType] != 'POS'	
	  AND INV.[ysnValidCreditCode] <> 1
	  AND I.strSessionId = @strSessionId

	---REMOVING THIS VALIDATION SINCE THIS LOGIC WILL BE CHANGED IN AR-14378
	-- INSERT INTO tblARPostInvalidInvoiceData
	-- 	([intInvoiceId]
	-- 	,[strInvoiceNumber]
	-- 	,[strTransactionType]
	-- 	,[intInvoiceDetailId]
	-- 	,[intItemId]
	-- 	,[strBatchId]
	-- 	,[strPostingError]
	-- 	,[strSessionId])
	-- --Approval
	-- SELECT
	-- 	 [intInvoiceId]			= I.[intInvoiceId]
	-- 	,[strInvoiceNumber]		= I.[strInvoiceNumber]        
	-- 	,[strTransactionType]	= I.[strTransactionType]
	-- 	,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
	-- 	,[intItemId]            = I.[intItemId]
	-- 	,[strBatchId]			= I.[strBatchId]
	-- 	,[strPostingError]		= CASE WHEN VI.ysnHasCreditApprover = 0 THEN 'The Customer''s credit limit has been reached but there is no approver configured. This invoice cannot be posted without an authorized approver.' ELSE ISNULL(SMT.strApprovalStatus, 'Not Yet Approved') END
	-- 	,[strSessionId]			= @strSessionId
	-- FROM tblARPostInvoiceHeader I 
	-- INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	-- INNER JOIN tblSMTransaction SMT ON SMT.intRecordId = INV.intInvoiceId
	-- INNER JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'Invoice'
	-- INNER JOIN vyuARGetInvoice VI ON VI.intInvoiceId = INV.intInvoiceId
	-- WHERE ISNULL(SMT.strApprovalStatus, '') <> 'Approved'
	--   AND VI.ysnHasCreditApprover = 0
    --   AND ISNULL(VI.strCreditCode, '') NOT IN ('', 'Always Allow', 'Normal', 'Reject Orders', 'COD')
    --   AND ((I.dblInvoiceTotal + VI.dblARBalance > VI.dblCreditLimit) OR ISNULL(VI.dblCreditStopDays, 0) > 0)
	--   AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Approval
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]        
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]            = I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= ISNULL(SMT.strApprovalStatus, 'Not Yet Approved')
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I 
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblARCustomer CUS ON I.intEntityCustomerId = CUS.intEntityId
	INNER JOIN tblSMTransaction SMT ON SMT.intRecordId = INV.intInvoiceId
	INNER JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'Invoice'
	WHERE SMT.strApprovalStatus IN  ('Waiting for Approval', 'Waiting for Submit')
      AND (CUS.strCreditCode IS NOT NULL AND CUS.strCreditCode NOT IN ('', 'Always Allow', 'Normal', 'Reject Orders', 'COD'))
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--UOM is required
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'UOM is required for item ' + ISNULL(NULLIF(I.[strItemDescription], ''), I.[strItemNo]) + '.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I	
	WHERE I.[strTransactionType] = 'Invoice'	
	  AND I.[intItemUOMId] IS NULL
	  AND I.[intInventoryShipmentItemId] IS NULL
	  AND I.[intSalesOrderDetailId] IS NULL
	  AND I.[intLoadDetailId] IS NULL
	  AND I.[intItemId] IS NOT NULL
	  AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software', 'Comment', '')
	  AND I.strSessionId = @strSessionId	

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Dsicount Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN ' The Receivable Discount account assigned to item ' + I.[strItemNo] + ' is not valid.' ELSE 'Receivable Discount account was not set up for item ' + I.[strItemNo] END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I	
	LEFT OUTER JOIN tblARPostInvoiceItemAccount IST ON I.[intItemId] = IST.[intItemId]  AND I.[intCompanyLocationId] = IST.[intLocationId] 
	LEFT OUTER JOIN dbo.tblGLAccount GLA ON ISNULL(IST.[intDiscountAccountId], I.[intDiscountAccountId]) = GLA.[intAccountId]		 
	WHERE ((IST.[intDiscountAccountId] IS NULL AND I.[intDiscountAccountId] IS NULL) OR GLA.[intAccountId] IS NULL)
	  AND I.[dblDiscount] <> @ZeroDecimal		
	  AND I.[strItemType] <> 'Comment'
	  AND I.strSessionId = @strSessionId
	  AND IST.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Currency is required
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'No currency has been specified.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intCurrencyId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--No Terms specified
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'No terms has been specified.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I			 
	WHERE I.[intTermId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Header Account ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The AR account is not valid.' ELSE 'The AR account is not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount GLA ON I.[intAccountId] = GLA.[intAccountId]		 
	WHERE (I.[intAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Undeposited Fund Account ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' is using invalid account. Undeposited Fund Account is for Cash and Cash Refund transactions only.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN vyuGLAccountDetail GLA ON I.[intAccountId] = GLA.[intAccountId]		 
	WHERE I.strTransactionType NOT IN ('Cash', 'Cash Refund')
	  AND GLA.strAccountCategory = 'Undeposited Funds'
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CASH TRANSASCTIONS USING OTHER ACCOUNT
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' is using invalid account. Use Undeposited Fund Account for Cash transactions.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN vyuGLAccountDetail GLA ON I.[intAccountId] = GLA.[intAccountId]		 
	WHERE I.strTransactionType = 'Cash'
	  AND GLA.strAccountCategory <> 'Undeposited Funds'
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Location
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Company location of ' + I.[strInvoiceNumber] + ' was not set.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intCompanyLocationId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Freight Expenses Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Freight Income account is not valid.' ELSE 'The Freight Income account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount GLA ON I.[intFreightIncome] = GLA.[intAccountId]						
	WHERE (I.[intFreightIncome] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.[dblShipping] <> @ZeroDecimal
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Undeposited Funds Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Undeposited Funds account of Company Location ' + I.[strCompanyLocationName] + ' is not valid.' ELSE 'The Undeposited Funds account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount  GLA ON I.[intUndepositedFundsId] = GLA.[intAccountId]					
	WHERE (I.[intUndepositedFundsId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND (
			I.[strTransactionType] = 'Cash'
			OR
			(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.[intInvoiceId] = I.[intInvoiceId] AND tblARPrepaidAndCredit.[ysnApplied] = 1 AND tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount] <> 0 ))
			)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--AP Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The AP account of Company Location ' + I.[strCompanyLocationName] + ' is not valid.' ELSE 'The AP account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount  GLA ON I.[intAPAccount] = GLA.[intAccountId]					
	WHERE (I.[intAPAccount] IS NULL OR GLA.[intAccountId] IS NULL)
	   AND I.[strTransactionType] = 'Cash Refund'
	   AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Prepayment Date vs Invoice Post Date
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]	
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]      = 'Payment Date(' + CONVERT(NVARCHAR(30), I.dtmPostDate, 101) + ') cannot be earlier than the Invoice(' + CREDIT.strInvoiceNumber + ') Post Date(' + CONVERT(NVARCHAR(30), CREDIT.dtmPostDate, 101) + ')!'
		,[strSessionId]
	FROM 
		tblARPostInvoiceHeader I
	INNER JOIN tblARPrepaidAndCredit ARPAC ON I.intInvoiceId = ARPAC.intInvoiceId
	INNER JOIN tblARInvoice CREDIT ON ARPAC.intPrepaymentId = CREDIT.intInvoiceId
    WHERE CAST(CREDIT.dtmPostDate AS DATE) > CAST(I.dtmPostDate AS DATE)
	AND ARPAC.dblAppliedInvoiceDetailAmount > 0

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Accrual Not in Fiscal Year
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' has an Accrual setup up to ' + CONVERT(NVARCHAR(30),DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate])), 101) + ' which does not fall into a valid Fiscal Period.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intPeriodsToAccrue] > 1  
	  AND ISNULL(dbo.isOpenAccountingDate(DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate]))), @ZeroBit) = @ZeroBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Payment Method
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Check Number is required for Cash transaction type and Check payment method.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblSMPaymentMethod SM ON INV.intPaymentMethodId = SM.intPaymentMethodID	
	WHERE SM.strPaymentMethod = 'Check'
	  AND INV.strTransactionType = 'Cash'
	  AND ISNULL(INV.strPaymentInfo, '') = ''
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Deferred Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Deferred Revenue account in the Company Configuration was not set.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.intPeriodsToAccrue > 1
	  AND I.[intDeferredRevenueAccountId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Deferred Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Deferred Revenue account is not valid.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intPeriodsToAccrue] > 1
	  AND I.[intDeferredRevenueAccountId] IS NULL
	  AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WITH (NOLOCK) WHERE GLA.[intAccountId] = I.[intDeferredRevenueAccountId])
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Invoice for accrual with Inventory Items
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Invoice : ' + I.[strInvoiceNumber] + ' is for accrual and must not include an inventory item : ' + I.[strItemNo] + '.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I			
	WHERE I.[intPeriodsToAccrue] > 1
	  AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Provisional Invoice Posting
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Posting Provisional Invoice is disabled in Company Configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I					
	WHERE I.[strType] = 'Provisional'
	  AND I.[ysnProvisionalWithGL] = @ZeroBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Sales Account of item - ' + I.[strItemNo] + ' was not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	LEFT OUTER JOIN tblARPostInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId]
											  AND I.[intItemId] = Acct.[intItemId] 		
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intSalesAccountId] = GLA.[intAccountId]
	LEFT OUTER JOIN tblGLAccount GLAGA ON Acct.[intGeneralAccountId] = GLAGA.[intAccountId]
	WHERE I.[strItemType] = 'Non-Inventory'
	  AND I.[strItemType] <> 'Comment'
	  AND (Acct.[intSalesAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND (Acct.[intGeneralAccountId] IS NULL OR GLAGA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId
	  AND Acct.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The General Account of item - ' + I.[strItemNo] + ' was not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	LEFT OUTER JOIN tblARPostInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId] AND I.[intItemId] = Acct.[intItemId] 		
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intGeneralAccountId] = GLA.[intAccountId]
	WHERE I.[strItemType] = 'Service'
	  AND I.[strItemType] <> 'Comment'
	  AND (Acct.[intGeneralAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId
	  AND Acct.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Misc Item Sales Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Sales Account of item - ' + I.[strItemDescription] + ' was not specified in ' + CL.strLocationName + '.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	INNER JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	WHERE I.intItemId IS NULL
	  AND I.strItemDescription IS NOT NULL
	  AND I.intSalesAccountId IS NULL
	  AND CL.intSalesAccount IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Type
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Type of item - ' + I.[strItemNo] + ' is not valid.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
	  AND ISNULL(I.[strMaintenanceType], '') NOT IN ('License/Maintenance', 'Maintenance Only', 'SaaS', 'License Only')
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Frequency
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Frequency of item - ' + I.[strItemNo] + ' is not valid.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
	  AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	  AND ISNULL(I.[strFrequency], '') NOT IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Date
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Start Date of item - ' + I.[strItemNo] + ' is required.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
	  AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	  AND I.[strFrequency] IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
	  AND I.[dtmMaintenanceDate] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - License Amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The License Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
	  AND I.[strMaintenanceType] IN ('License Only')
	  AND I.[strFrequency] IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
	  AND I.[dblLicenseAmount] <> I.[dblPrice]
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
	  AND I.[strMaintenanceType] IN ('Maintenance Only', 'SaaS')
	  AND I.[strFrequency] IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
	  AND I.[dblMaintenanceAmount] <> I.[dblPrice]
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Amount + License
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Amount + License Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'
	  AND I.[strMaintenanceType] IN ('License/Maintenance')
	  AND I.[strFrequency] IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
	  AND ((I.[dblMaintenanceAmount] + I.[dblLicenseAmount]) <> I.[dblPrice])
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - Maintenance Sales
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Maintenance Sales account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Maintenance Sales of item - ' + I.[strItemNo] + ' were not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	LEFT OUTER JOIN tblARPostInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId] AND I.[intItemId] = Acct.[intItemId]
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intMaintenanceSalesAccountId] = GLA.[intAccountId]
	WHERE I.[strItemType] = 'Software'	
	  AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	  AND (Acct.[intMaintenanceSalesAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId
	  AND Acct.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Software - General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The General Accounts of item - ' + I.[strItemNo] + ' were not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	LEFT OUTER JOIN tblARPostInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId] AND I.[intItemId] = Acct.[intItemId]
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intGeneralAccountId] = GLA.[intAccountId]
	WHERE I.[strItemType] = 'Software'
	  AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
	  AND (Acct.[intGeneralAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId
	  AND Acct.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Other Charge Income Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Other Charge Income account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Other Charge Income Account of item - ' + I.[strItemNo] + ' was not specified.' END
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	LEFT OUTER JOIN tblARPostInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId] AND I.[intItemId] = Acct.[intItemId] 		 	
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.intOtherChargeIncomeAccountId = GLA.[intAccountId]
	WHERE I.[strItemType] = 'Other Charge'
	  AND (Acct.[intOtherChargeIncomeAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId
	  AND Acct.strSessionId = @strSessionId
	
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Sales Tax Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' is not valid.' ELSE 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.' END
		,[strSessionId]			= @strSessionId
	FROM tblARInvoiceDetailTax ARIDT
	INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]		
	LEFT OUTER JOIN tblSMTaxCode SMTC ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]
	LEFT OUTER JOIN tblGLAccount GLA ON ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) = GLA.[intAccountId]	
	WHERE ARIDT.[dblAdjustedTax] <> @ZeroDecimal
	  AND (ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Tax Adjustment Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Tax Adjustment account of Tax Code - ' + SMTC.[strTaxCode] + ' is not valid.' ELSE 'The Tax Adjustment account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.' END
		,[strSessionId]			= @strSessionId
	FROM tblARInvoiceDetailTax ARIDT
	INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]		
	LEFT OUTER JOIN tblSMTaxCode SMTC ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]
	LEFT OUTER JOIN tblGLAccount GLA ON ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) = GLA.[intAccountId]	
	WHERE ARIDT.[dblAdjustedTax] <> @ZeroDecimal
	  AND (SMTC.[intTaxAdjustmentAccountId] IS NULL OR GLA.[intAccountId] IS NULL)
	  AND I.strType = 'Tax Adjustment'
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Sales Tax Exempt Account
	SELECT
		[intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Tax Exemption Account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.'
		,[strSessionId]			= @strSessionId
	FROM tblARInvoiceDetailTax ARIDT
	INNER JOIN tblARPostInvoiceDetail I ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]		
	LEFT OUTER JOIN tblSMTaxCode  SMTC ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]	
	WHERE ARIDT.[dblAdjustedTax] <> @ZeroDecimal
	  AND SMTC.[ysnAddToCost] = 1
	  AND SMTC.[intSalesTaxExemptionAccountId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Zero Contract Item Price
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The contract item - ' + I.[strItemNo] + ' price cannot be zero.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	INNER JOIN tblCTContractDetail CD ON I.intContractDetailId = CD.intContractDetailId AND I.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblCTPricingType PT ON CD.intPricingTypeId = CD.intPricingTypeId		
	WHERE I.[strItemType] <> 'Other Charge'
	  AND I.strTransactionType <> 'Credit Memo'
	  AND I.[dblPrice] = @ZeroDecimal			
	  AND PT.[strPricingType] <> 'Index'
	  AND I.[intLoadDetailId] IS NULL
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Contract Item Price not Equal to Contract Sequence Cash Price
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The contract item - ' + I.[strItemNo] + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(I.[dblUnitPrice],@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY),2) + ').'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	INNER JOIN vyuCTCustomerContract ARCC ON I.[intContractHeaderId] = ARCC.[intContractHeaderId] AND I.[intContractDetailId] = ARCC.[intContractDetailId]
	WHERE I.[dblUnitPrice] <> @ZeroDecimal				
	  AND I.[strItemType] <> 'Other Charge'
	  AND I.strTransactionType NOT IN ('Credit Memo', 'Debit Memo')
	  AND CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY) <> CAST(ISNULL(I.[dblUnitPrice], @ZeroDecimal) AS MONEY)
	  AND ARCC.[strPricingType] <> 'Index'
	  AND I.[intLoadDetailId] IS NULL
	  AND I.[intShipmentId] IS NULL
	  AND I.[intInventoryShipmentItemId] IS NULL
	  AND I.[strPricing] NOT IN ('Contracts-Max Price','Contracts-Pricing Level')
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Lot Tracked
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= ARID.[intInvoiceDetailId]
		,[intItemId]			= ARID.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Qty Ship for ' + ARID.[strItemDescription] + ' is ' + CONVERT(NVARCHAR(50), CAST(ARID.dblQtyShipped AS DECIMAL(16, 2))) + '. Total Lot Qty is ' + CONVERT(NVARCHAR(50), CAST(ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2))) + ' The difference is ' + CONVERT(NVARCHAR(50), ABS(CAST(ARID.dblQtyShipped - ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2)))) + '.' 
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I	
	INNER JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON I.[intInvoiceId] = ARID.[intInvoiceId]
	INNER JOIN tblICItem ITEM ON ARID.intItemId = ITEM.intItemId	
	LEFT JOIN tblLGLoad LG WITH (NOLOCK) ON I.[intLoadId] = LG.[intLoadId]
	OUTER APPLY (
		SELECT [dblTotalQtyShipped] = SUM(ISNULL(dblQuantityShipped, 0))
		FROM dbo.tblARInvoiceDetailLot ARIDL WITH (NOLOCK)
		WHERE ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId
	) LOT
	WHERE ARID.dblQtyShipped <> ISNULL(LOT.[dblTotalQtyShipped], 0)
	  AND I.[intLoadDistributionHeaderId] IS NULL
	  AND ((I.[intLoadId] IS NOT NULL AND ISNULL(LG.[intPurchaseSale], 0) NOT IN (2, 3)) OR I.[intLoadId] IS NULL)
	  AND ARID.[intItemId] IS NOT NULL
	  AND ITEM.strLotTracking IN ('Yes - Manual', 'Yes - Serial Number', 'Yes - Manual/Serial Number')
	  AND ARID.[intInventoryShipmentItemId] IS NULL
	  AND ARID.[intLoadDetailId] IS NULL
	  AND ARID.[ysnBlended] <> 1
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CASH REFUND AMOUNT IS NOT EQUAL TO PREPAIDS
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Cash Refund amount is not equal to prepaids/credits applied.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	OUTER APPLY (
		SELECT dblAppliedInvoiceAmount	= SUM(ISNULL(dblAppliedInvoiceDetailAmount, 0))
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE intInvoiceId = I.intInvoiceId 
		  AND ysnApplied = @OneBit
		  AND dblAppliedInvoiceDetailAmount > 0			
	) PREPAIDS
	WHERE I.strTransactionType = 'Cash Refund'
	  AND I.dblInvoiceTotal <> ISNULL(PREPAIDS.dblAppliedInvoiceAmount, 0)
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
	(
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
	)
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= NULL
		,[intItemId]			= NULL
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Storage Location field is required if the Storage Unit field is populated.  Please review these fields for Item(s) (' + 
								  STUFF((
										SELECT ', ' + strItemNo
										FROM tblICItem ICI
										INNER JOIN tblARInvoiceDetail ARID ON ICI.intItemId = ARID.intItemId
										WHERE ARID.intInvoiceId = I.intInvoiceId
										GROUP BY strItemNo
										FOR XML PATH('')
								  ), 1, 1, '') 
								  + ') and make the appropriate edits.'
	FROM tblARPostInvoiceDetail I
	WHERE ISNULL(I.intStorageLocationId, 0) > 0
	AND ISNULL(I.intSubLocationId, 0) = 0
	GROUP BY 
		 I.intInvoiceId
		,I.strInvoiceNumber
		,I.strTransactionType
		,I.strBatchId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--FISCAL PERIOD CLOSED INVENTORY
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find an open fiscal year period for Inventory module to match the transaction date.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE dbo.isOpenAccountingDateByModule(ISNULL(dtmPostDate, dtmDate), 'Inventory') = 0
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CREDITS APPLIED IS OVER AMOUNT DUE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Applied credits for ' + I.[strInvoiceNumber] + ' is more than the amount due.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN (
		SELECT intInvoiceId			= APC.intInvoiceId
			 , dblCreditsApplied	= SUM(APC.dblAppliedInvoiceDetailAmount)
		FROM tblARPrepaidAndCredit APC
		WHERE APC.ysnApplied = 1
		  AND ISNULL(APC.dblAppliedInvoiceDetailAmount, 0) <> 0
		GROUP BY intInvoiceId
	) CREDITS ON CREDITS.intInvoiceId = I.intInvoiceId
	WHERE CREDITS.dblCreditsApplied > I.dblAmountDue
	  AND I.strSessionId = @strSessionId

	--TM Sync
	DELETE FROM @PostInvoiceDataFromIntegration
	INSERT INTO @PostInvoiceDataFromIntegration (
		  intInvoiceId
		, dtmDate
		, strInvoiceNumber
		, strTransactionType
		, intInvoiceDetailId
		, intItemId
		, strBatchId
		, intEntityId
		, intUserId
		, intSiteId
		, intPerformerId
		, ysnLeaseBilling
	)
    SELECT intInvoiceId			= PID.intInvoiceId
		, dtmDate				= PID.dtmDate
		, strInvoiceNumber		= PID.strInvoiceNumber
		, strTransactionType	= PID.strTransactionType
		, intInvoiceDetailId	= PID.intInvoiceDetailId
		, intItemId				= PID.intItemId
		, strBatchId			= PID.strBatchId
		, intEntityId			= PID.intEntityId
		, intUserId				= PID.intUserId
		, intSiteId				= PID.intSiteId
		, intPerformerId		= PID.intPerformerId
		, ysnLeaseBilling		= PID.ysnLeaseBilling
	FROM tblARPostInvoiceDetail PID 
	INNER JOIN tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID]
	WHERE PID.strSessionId = @strSessionId
	  AND PID.intSiteId IS NOT NULL

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])

	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnTMGetInvalidInvoicesForSync](@PostInvoiceDataFromIntegration, @OneBit)

	--MFG Auto Blend
	DELETE FROM @PostInvoiceDataFromIntegration
	INSERT INTO @PostInvoiceDataFromIntegration (
		  intInvoiceId
		, dtmDate
		, strInvoiceNumber
		, strTransactionType
		, intInvoiceDetailId
		, intItemId
		, strBatchId
		, intEntityId
		, intUserId
		, intCompanyLocationId
		, intItemUOMId
		, intSubLocationId
		, intStorageLocationId
		, dblQuantity
	)
    SELECT intInvoiceId			= PID.intInvoiceId
		, dtmDate				= PID.dtmDate
		, strInvoiceNumber		= PID.strInvoiceNumber
		, strTransactionType	= PID.strTransactionType
		, intInvoiceDetailId	= PID.intInvoiceDetailId
		, intItemId				= PID.intItemId
		, strBatchId			= PID.strBatchId
		, intEntityId			= PID.intEntityId
		, intUserId				= PID.intUserId
		, intCompanyLocationId	= PID.intCompanyLocationId
		, intItemUOMId			= PID.intItemUOMId
		, intSubLocationId		= PID.intSubLocationId
		, intStorageLocationId	= PID.intStorageLocationId
		, dblQuantity			= PID.dblQuantity
	FROM tblARPostInvoiceDetail PID 
	WHERE PID.[ysnBlended] <> @OneBit AND PID.[ysnAutoBlend] = @OneBit
	  AND PID.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnMFGetInvalidInvoicesForPosting](@PostInvoiceDataFromIntegration, @OneBit)

	-- IC Costing Negative inventory
	DELETE FROM @ItemsForCosting	
	INSERT INTO @ItemsForCosting
		([intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate])
	SELECT
		 [intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
	FROM tblARPostItemsForCosting COSTING
	WHERE ISNULL([ysnAutoBlend], 0) = 0
	  AND ISNULL(ysnGLOnly, 0) = 0
	  AND COSTING.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnICGetInvalidInvoicesForCosting](@ItemsForCosting, @OneBit)

	-- IC Zero Cost
	INSERT INTO @ItemsForCostingZeroCostValidation
		([intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate])
	SELECT
		 [intItemId]
		,[intItemLocationId]
		,ISNULL(dbo.fnGetMatchingItemUOMId([intItemId], ICIUOM.intUnitMeasureId), COSTING.intItemUOMId)
		,[dtmDate]
		,ABS([dblQty])
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
	FROM tblARPostItemsForCosting COSTING
	LEFT OUTER JOIN 
	(SELECT intUnitMeasureId,intItemUOMId FROM tblICItemUOM ICUOM  WITH (NOLOCK)
		) ICIUOM
		ON COSTING.intItemUOMId = ICIUOM.intItemUOMId
	WHERE ISNULL([ysnAutoBlend], 0) = 0
	AND COSTING.intTransactionId NOT IN (SELECT intInvoiceId FROM tblARPostInvalidInvoiceData)
	AND COSTING.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnICGetInvalidInvoicesForCosting](@ItemsForCosting, @OneBit)

	--INVOICE HAS EARLIER DATE COMPARE TO STOCK DATE
		INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= COSTING.[intTransactionDetailId]
		,[intItemId]			= COSTING.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Stock is not available for ' + ITEM.strItemNo + ' at ' + CLOC.strLocationName + ' as of ' + CONVERT(NVARCHAR(30), CAST(COSTING.dtmDate AS DATETIME), 101) + '. Use the nearest stock available date of ' + CONVERT(NVARCHAR(30), CAST(STOCKDATE.dtmDate AS DATETIME), 101) + ' or later.'	
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
		INNER JOIN tblARPostItemsForCosting COSTING  ON I.intInvoiceId =  COSTING.intTransactionId
		INNER JOIN  
		(
		SELECT intItemId,intItemLocationId,intItemUOMId,MAX(dtmDate)[dtmDate] 
		FROM tblICInventoryStockAsOfDate 
		GROUP BY  intItemId,intItemLocationId,intItemUOMId
	) STOCKDATE ON COSTING.intItemId = STOCKDATE.intItemId AND COSTING.intItemUOMId = STOCKDATE.intItemUOMId AND STOCKDATE.intItemLocationId = COSTING.intItemLocationId
	INNER JOIN tblICItem ITEM ON  ITEM.intItemId = COSTING.intItemId
	INNER JOIN tblICItemLocation LOC ON COSTING.intItemLocationId = LOC.intItemLocationId
	INNER JOIN tblSMCompanyLocation CLOC ON LOC.intLocationId = CLOC.intCompanyLocationId
	WHERE COSTING.dtmDate < STOCKDATE.dtmDate
	AND I.[strType] = 'POS'	

	-- IC In Transit Costing
	DELETE FROM @ItemsForInTransitCosting
	INSERT INTO @ItemsForInTransitCosting
		([intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intSourceTransactionDetailId]
		,[intFobPointId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate])
	SELECT
		 [intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intSourceTransactionDetailId]
		,[intFobPointId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
	FROM tblARPostItemsForInTransitCosting
	WHERE strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnICGetInvalidInvoicesForInTransitCosting](@ItemsForInTransitCosting, @OneBit)

	-- IC Item Storage
	DELETE FROM @ItemsForStoragePosting
	INSERT INTO @ItemsForStoragePosting
		([intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate])
	SELECT
		 [intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblQty]
		,[dblUOMQty]
		,[dblCost]
		,[dblValue]
		,[dblSalesPrice]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[strActualCostId]
		,[intSourceTransactionId]
		,[strSourceTransactionId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId]
		,[dblForexRate]
	FROM tblARPostItemsForStorageCosting
	WHERE strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnICGetInvalidInvoicesForItemStoragePosting](@ItemsForStoragePosting, @OneBit)

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]			= IFC.intTransactionId
		,[strInvoiceNumber]		= IFC.strTransactionId
		,[strTransactionType]	= 'Invoice'
		,[intInvoiceDetailId]	= IFC.intTransactionDetailId
		,[intItemId]			= IFC.intItemId
		,[strBatchId]			= @BatchId
		,[strPostingError]		= 'Unable to find the account of item ' + ITEM.strItemNo + ' that matches the segment of AR Account for ' + GLAC.strAccountCategory + ' account category. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM @ItemsForCosting IFC
	INNER JOIN tblARPostInvoiceDetail ARPID ON IFC.intTransactionDetailId = ARPID.intInvoiceDetailId AND strSessionId = @strSessionId
	INNER JOIN tblARPostInvoiceHeader ARPIH ON ARPID.intInvoiceId = ARPIH.intInvoiceId
	INNER JOIN tblICItem ITEM ON IFC.intItemId = ITEM.intItemId
	INNER JOIN tblICItemLocation IL ON IFC.intItemLocationId = IL.intItemLocationId
	INNER JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
	INNER JOIN tblICItemAccount ICIA ON IFC.intItemId = ICIA.intItemId
	INNER JOIN tblGLAccountCategory GLAC ON ICIA.intAccountCategoryId = GLAC.intAccountCategoryId
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](ARPIH.[intAccountId], [dbo].[fnGetItemBaseGLAccount](IFC.intItemId, IFC.intItemLocationId, GLAC.strAccountCategory), @OverrideCompanySegment, @OverrideLocationSegment, 0)
	) OVERRIDESEGMENT
	WHERE (
		(@OverrideCompanySegment = 1 AND OVERRIDESEGMENT.bitSameCompanySegment = 0)
		OR
		(@OverrideLocationSegment = 1 AND OVERRIDESEGMENT.bitSameLocationSegment = 0)
	)
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND GLAC.strAccountCategory IN ('Cost of Goods', 'Sales Account', 'Inventory')

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]			= IFITC.intTransactionId
		,[strInvoiceNumber]		= IFITC.strTransactionId
		,[strTransactionType]	= 'Invoice'
		,[intInvoiceDetailId]	= IFITC.intTransactionDetailId
		,[intItemId]			= IFITC.intItemId
		,[strBatchId]			= @BatchId
		,[strPostingError]		= 'Unable to find the account of item ' + ITEM.strItemNo + ' that matches the segment of AR Account for ' + GLAC.strAccountCategory + ' account category. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM @ItemsForInTransitCosting IFITC
	INNER JOIN tblARPostInvoiceDetail ARPID ON IFITC.intTransactionDetailId = ARPID.intInvoiceDetailId AND strSessionId = @strSessionId
	INNER JOIN tblARPostInvoiceHeader ARPIH ON ARPID.intInvoiceId = ARPIH.intInvoiceId
	INNER JOIN tblICItem ITEM ON IFITC.intItemId = ITEM.intItemId
	INNER JOIN tblICItemLocation IL ON IFITC.intItemLocationId = IL.intItemLocationId
	INNER JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
	INNER JOIN tblICItemAccount ICIA ON IFITC.intItemId = ICIA.intItemId
	INNER JOIN tblGLAccountCategory GLAC ON ICIA.intAccountCategoryId = GLAC.intAccountCategoryId
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](ARPIH.[intAccountId], [dbo].[fnGetItemBaseGLAccount](IFITC.intItemId, IFITC.intItemLocationId, GLAC.strAccountCategory), @OverrideCompanySegment, @OverrideLocationSegment, 0)
	) OVERRIDESEGMENT
	WHERE (
		(@OverrideCompanySegment = 1 AND OVERRIDESEGMENT.bitSameCompanySegment = 0)
		OR
		(@OverrideLocationSegment = 1 AND OVERRIDESEGMENT.bitSameLocationSegment = 0)
	)
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND GLAC.strAccountCategory = 'Inventory In-Transit'

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Due From Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The due from account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE (I.dblFreightCharge > 0 OR (@AllowIntraCompanyEntries = 1 OR @AllowIntraLocationEntries = 1))
	AND @DueFromAccountId = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Due To Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The due to account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE (I.dblFreightCharge > 0 OR (@AllowIntraCompanyEntries = 1 OR @AllowIntraLocationEntries = 1))
	AND @DueToAccountId = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Overridden Due From Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the due from account that matches the segment of the Sales Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](I.[intSalesAccountId], @DueFromAccountId, @AllowIntraCompanyEntries, @AllowIntraLocationEntries, 0)
	) OVERRIDESEGMENT
	WHERE (
		(@AllowIntraCompanyEntries = 1 AND OVERRIDESEGMENT.bitSameCompanySegment = 0)
		OR
		(@AllowIntraLocationEntries = 1 AND OVERRIDESEGMENT.bitSameLocationSegment = 0)
	)
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Overridden Due To Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the due to account that matches the segment of the AR Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment
		FROM dbo.[fnARGetOverrideAccount](I.[intAccountId], @DueToAccountId, @AllowIntraCompanyEntries, @AllowIntraLocationEntries, 0)
	) OVERRIDESEGMENT
	WHERE OVERRIDESEGMENT.bitOverriden = 0
	AND (@AllowIntraCompanyEntries = 1 OR @AllowIntraLocationEntries = 1)
	AND OVERRIDESEGMENT.bitSameCompanySegment = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	-- Check Sales and AR Account egment
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Sales and AR Account should have the same segment.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE @AllowSingleLocationEntries = 1
	AND ([dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 3) = 0
	OR [dbo].[fnARCompareAccountSegment](I.[intAccountId], I.[intSalesAccountId], 6) = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Freight Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The freight revenue account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.dblFreightCharge > 0
	AND @FreightRevenueAccount = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Freight Expense Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The freight expense account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.dblFreightCharge > 0
	AND @FreightExpenseAccount = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Freight Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the freight revenue account that matches the freight company and location segment of transport load. Please add ' + dbo.fnGLGetOverrideAccountBySegment(@FreightRevenueAccount, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment]) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	OUTER APPLY (
		SELECT intAccountId
		FROM tblGLAccount
		WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@FreightRevenueAccount, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment])
	) GLACCOUNT
	OUTER APPLY (
		SELECT bitOverriden, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](@FreightRevenueAccount, ISNULL(GLACCOUNT.intAccountId, 0), 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE I.dblFreightCharge > 0
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Due From Account For Freight Charge
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the due from account that matches the freight company and location segment of transport load. Please add ' + dbo.fnGLGetOverrideAccountBySegment(@DueFromAccountId, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment]) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	OUTER APPLY (
		SELECT intAccountId
		FROM tblGLAccount
		WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@DueFromAccountId, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment])
	) GLACCOUNT
	OUTER APPLY (
		SELECT bitOverriden, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](@DueFromAccountId, ISNULL(GLACCOUNT.intAccountId, 0), 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE I.dblFreightCharge > 0
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Freight Expense Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the freight expense account that matches the company and location segment of the AR Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](I.[intAccountId], @FreightExpenseAccount, 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE OVERRIDESEGMENT.bitOverriden = 0 
	AND I.dblFreightCharge > 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Due To Account For Freight Charge and Surcharge
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the due to account that matches the company and location segment of the AR Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](I.[intAccountId], @DueToAccountId, 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE OVERRIDESEGMENT.bitOverriden = 0 
	AND (I.dblFreightCharge > 0 OR I.dblSurcharge > 0)
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Surcharge Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The surcharge revenue account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.dblSurcharge > 0
	AND @SurchargeRevenueAccount = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Company Configuration Surcharge Expense Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The surcharge expense account is not yet configured in company configuration.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	WHERE I.dblSurcharge > 0
	AND @SurchargeExpenseAccount = 0
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Surcharge Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the surcharge revenue account that matches the freight company and location segment of transport load. Please add ' + dbo.fnGLGetOverrideAccountBySegment(@SurchargeRevenueAccount, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment]) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	OUTER APPLY (
		SELECT intAccountId
		FROM tblGLAccount
		WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@SurchargeRevenueAccount, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment])
	) GLACCOUNT
	OUTER APPLY (
		SELECT bitOverriden, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](@SurchargeRevenueAccount, ISNULL(GLACCOUNT.intAccountId, 0), 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE I.dblSurcharge > 0
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Due From Account For Surcharge
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the due from account that matches the freight company and location segment of transport load. Please add ' + dbo.[fnGLGetOverrideAccountBySegment](@DueFromAccountId, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment]) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	OUTER APPLY (
		SELECT intAccountId
		FROM tblGLAccount
		WHERE strAccountId = dbo.fnGLGetOverrideAccountBySegment(@DueFromAccountId, I.[intFreightLocationSegment], NULL, I.[intFreightCompanySegment])
	) GLACCOUNT
	OUTER APPLY (
		SELECT bitOverriden, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](@DueFromAccountId, ISNULL(GLACCOUNT.intAccountId, 0), @OverrideCompanySegment, @OverrideLocationSegment, 0)
	) OVERRIDESEGMENT
	WHERE I.dblSurcharge > 0
	AND OVERRIDESEGMENT.bitOverriden = 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Surcharge Expense Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find the Freight Expense Account that matches the company and location segment of the AR Account. Please add ' + OVERRIDESEGMENT.strOverrideAccount + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail I
	OUTER APPLY (
		SELECT bitOverriden, strOverrideAccount, bitSameCompanySegment, bitSameLocationSegment
		FROM dbo.[fnARGetOverrideAccount](I.[intAccountId], @SurchargeExpenseAccount, 1, 1, 0)
	) OVERRIDESEGMENT
	WHERE OVERRIDESEGMENT.bitOverriden = 0 
	AND I.dblSurcharge > 0
	AND (OVERRIDESEGMENT.bitSameCompanySegment = 0 OR OVERRIDESEGMENT.bitSameLocationSegment = 0)
	AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	-- Check line of business segment
	SELECT
		 [intInvoiceId]			= ARPID.[intInvoiceId]
		,[strInvoiceNumber]		= ARPID.[strInvoiceNumber]		
		,[strTransactionType]	= ARPID.[strTransactionType]
		,[intInvoiceDetailId]	= ARPID.[intInvoiceDetailId] 
		,[intItemId]			= ARPID.[intItemId] 
		,[strBatchId]			= ARPID.[strBatchId]
		,[strPostingError]		= 'Unable to find the due to account that matches the line of business. Please add ' + dbo.[fnGLGetOverrideAccountBySegment](ARPID.[intSalesAccountId], NULL, LOB.intSegmentCodeId, NULL) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader ARPIH
	INNER JOIN tblARPostInvoiceDetail ARPID ON ARPIH.intInvoiceId = ARPID.intInvoiceId
	OUTER APPLY (
		SELECT TOP 1 
			 intAccountId		= ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](ARPID.[intSalesAccountId], ISNULL(intSegmentCodeId, 0)), 0)
			,intSegmentCodeId
		FROM tblSMLineOfBusiness
		WHERE intLineOfBusinessId = ISNULL(ARPIH.intLineOfBusinessId, 0)
	) LOB
	WHERE @OverrideLineOfBusinessSegment = 1
	AND ISNULL(LOB.intAccountId, 0) = 0
	AND ISNULL(ARPIH.intLineOfBusinessId, 0) <> 0
	AND ARPID.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Location Account Override For Freight and Surcharge (Item > Setup > Cost Tab)
	SELECT
		 [intInvoiceId]			= ARID.[intInvoiceId]
		,[strInvoiceNumber]		= ARID.[strInvoiceNumber]		
		,[strTransactionType]	= ARID.[strTransactionType]
		,[intInvoiceDetailId]	= ARID.[intInvoiceDetailId] 
		,[intItemId]			= ARID.[intItemId] 
		,[strBatchId]			= ARID.[strBatchId]
		,[strPostingError]		= 'Unable to find the account that matches the location segment of freight override. Please add ' + dbo.[fnGLGetOverrideAccountBySegment](IA.intOtherChargeIncomeAccountId, OVERRIDEFREIGHTLOCATION.intSegmentCodeId, NULL, NULL) + ' to the chart of accounts.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId AND ARID.strSessionId = @strSessionId
	INNER JOIN tblARPostInvoiceItemAccount IA ON ARID.[intItemId] = IA.[intItemId] AND ARID.[intCompanyLocationId] = IA.[intLocationId] AND IA.strSessionId = @strSessionId
	OUTER APPLY (
		SELECT TOP 1 
			 intItemId			= ISNULL(ICFO.intItemId, 0)
			,intAccountId		= ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](IA.intOtherChargeIncomeAccountId, ISNULL(SMCL.intProfitCenter, 0)), 0)
			,intSegmentCodeId	= ISNULL(SMCL.intProfitCenter, 0)
		FROM tblICFreightOverride ICFO
		INNER JOIN (
			SELECT ARPID2.intItemId
			FROM tblARPostInvoiceDetail ARPID1
			CROSS JOIN tblARPostInvoiceDetail ARPID2
			WHERE ARPID1.intLoadDistributionDetailId = ARID.intLoadDistributionDetailId
			AND ARPID2.intLoadDistributionDetailId = ARID.intLoadDistributionDetailId
			AND ARPID1.intItemId = ARID.intItemId
			AND ARPID1.strSessionId = @strSessionId
			AND ARPID2.strSessionId = @strSessionId
			AND ISNULL(ARPID1.intLoadDistributionDetailId, 0) <> 0
		) ITEMFREIGHT 
		ON ICFO.intItemId = ARID.intItemId
		AND ICFO.intFreightOverrideItemId = ITEMFREIGHT.intItemId
		INNER JOIN tblSMCompanyLocation SMCL ON ICFO.intCompanyLocationId = SMCL.intCompanyLocationId
		GROUP BY ICFO.intItemId, ICFO.intFreightOverrideItemId, ICFO.intCompanyLocationId, SMCL.intProfitCenter
	) OVERRIDEFREIGHTLOCATION
	WHERE ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')
	AND ISNULL(OVERRIDEFREIGHTLOCATION.intItemId, 0) <> 0
	AND ISNULL(OVERRIDEFREIGHTLOCATION.intAccountId, 0) = 0

	--VALIDATE INVENTORY ACCOUNTS
	DECLARE @InvalidItemsForPosting TABLE (
		  intInvoiceId				INT
		, intInvoiceDetailId		INT
		, intItemId					INT
		, intItemLocationId			INT
		, strInvoiceNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strAccountCategory		NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)

	INSERT INTO @InvalidItemsForPosting (
		  intInvoiceId
		, intInvoiceDetailId
		, intItemId
		, intItemLocationId
		, strInvoiceNumber
		, strAccountCategory
	)
	SELECT intInvoiceId			= IC.intTransactionId
		, intInvoiceDetailId	= IC.intTransactionDetailId		
		, intItemId				= IC.intItemId
		, intItemLocationId		= IC.intItemLocationId
		, strInvoiceNumber		= IC.strTransactionId
		, strAccountCategory	= 'Inventory'
	FROM @ItemsForCosting IC
	WHERE dbo.fnGetItemGLAccount(IC.intItemId, IC.intItemLocationId, 'Inventory') IS NULL	

	UNION ALL

	SELECT intInvoiceId			= IC.intTransactionId
		, intInvoiceDetailId	= IC.intTransactionDetailId		
		, intItemId				= IC.intItemId
		, intItemLocationId		= IC.intItemLocationId
		, strInvoiceNumber		= IC.strTransactionId
		, strAccountCategory	= 'Cost of Goods'
	FROM @ItemsForCosting IC
	WHERE dbo.fnGetItemGLAccount(IC.intItemId, IC.intItemLocationId, 'Cost of Goods') IS NULL

	UNION ALL
	
	SELECT intInvoiceId			= IC.intTransactionId
		, intInvoiceDetailId	= IC.intTransactionDetailId		
		, intItemId				= IC.intItemId
		, intItemLocationId		= IC.intItemLocationId
		, strInvoiceNumber		= IC.strTransactionId
		, strAccountCategory	= 'Sales Account'
	FROM @ItemsForCosting IC
	WHERE dbo.fnGetItemGLAccount(IC.intItemId, IC.intItemLocationId, 'Sales Account') IS NULL

	UNION ALL

	SELECT intInvoiceId			= IC.intTransactionId
		, intInvoiceDetailId	= IC.intTransactionDetailId		
		, intItemId				= IC.intItemId
		, intItemLocationId		= IC.intItemLocationId
		, strInvoiceNumber		= IC.strTransactionId
		, strAccountCategory	= 'Inventory In-Transit'
	FROM @ItemsForInTransitCosting IC
	WHERE dbo.fnGetItemGLAccount(IC.intItemId, IC.intItemLocationId, 'Inventory In-Transit') IS NULL	
	
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]			= IC.intInvoiceId
		,[strInvoiceNumber]		= IC.strInvoiceNumber
		,[strTransactionType]	= 'Invoice'
		,[intInvoiceDetailId]	= IC.intInvoiceDetailId
		,[intItemId]			= IC.intItemId
		,[strBatchId]			= @BatchId
		,[strPostingError]		= ITEM.strItemNo + ' in ' + CL.strLocationName + ' is missing a GL account setup for ' + IC.strAccountCategory + ' account category.'
		,[strSessionId]			= @strSessionId
	FROM @InvalidItemsForPosting IC
	INNER JOIN tblICItem ITEM ON IC.intItemId = ITEM.intItemId
	INNER JOIN tblICItemLocation IL ON IC.intItemLocationId = IL.intItemLocationId
	INNER JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
END

IF @Post = @ZeroBit
BEGIN
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--NOT YET POSTED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The transaction has not been posted yet.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[ysnPosted] = @ZeroBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT [intInvoiceId]			= C.[intInvoiceId]
		, [strInvoiceNumber]		= C.[strInvoiceNumber]		
		, [strTransactionType]		= C.[strTransactionType]
		, [intInvoiceDetailId]		= C.[intInvoiceDetailId]
		, [intItemId]				= C.[intItemId]
		, [strBatchId]				= C.[strBatchId]
		, [strPostingError]			= 'You cannot unpost an Invoice with Service Charge Invoice created-' + B.strInvoiceNumber +  '.'
		, [strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader C
	INNER JOIN tblARInvoiceDetail A ON C.intInvoiceId = A.intSCInvoiceId
	INNER JOIN tblARInvoice B ON A.intInvoiceId = B.intInvoiceId
	WHERE A.intSCInvoiceId IS NOT NULL
	  AND C.strSessionId = @strSessionId
			
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT 
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost an Invoice with ' + ISNULL(I2.strTransactionType,'') + ' created- ' + ISNULL(I2.strInvoiceNumber ,'')
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblARInvoiceDetail D2 ON D2.intOriginalInvoiceDetailId = I.[intInvoiceDetailId]
	INNER JOIN tblARInvoice I2 ON I2.intInvoiceId = D2.intInvoiceId
	WHERE D2.intOriginalInvoiceDetailId IS NOT NULL
	  AND I.strSessionId = @strSessionId

	IF(ISNULL(@strDatabaseName, '') <> '')
	BEGIN
		DECLARE @ysnVoucherExistQuery nvarchar(MAX)
		DECLARE @ysnVoucherExistParam NVARCHAR(500)
		DECLARE @strBillId NVARCHAR(500) = ''
		DECLARE @strInterCompanyReceiptNumber NVARCHAR(50)

		SELECT @strInterCompanyReceiptNumber = [strReceiptNumber] FROM tblARPostInvoiceHeader
		SELECT @ysnVoucherExistQuery = N'SELECT @strBillId = APB.strBillId 
										 FROM [' + @strDatabaseName + '].[dbo].tblICInventoryReceipt ICIR 
										 INNER JOIN [' + @strDatabaseName + '].[dbo].tblICInventoryReceiptItem ICIRI 
										 ON ICIR.intInventoryReceiptId = ICIRI.intInventoryReceiptId 
										 INNER JOIN [' + @strDatabaseName + '].[dbo].tblAPBillDetail APBD
										 ON ICIRI.intInventoryReceiptItemId = APBD.intInventoryReceiptItemId
										 INNER JOIN [' + @strDatabaseName + '].[dbo].tblAPBill APB
										 ON APBD.intBillId = APB.intBillId
										 WHERE ICIR.strReceiptNumber = ''' + @strInterCompanyReceiptNumber + ''''

		SET @ysnVoucherExistParam = N'@strBillId NVARCHAR(500) OUTPUT'

		EXEC sp_executesql @ysnVoucherExistQuery, @ysnVoucherExistParam, @strBillId = @strBillId OUTPUT

		IF(@strBillId <> '')
		BEGIN
			INSERT INTO #ARInvalidInvoiceData
				([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError]
				,[strSessionId])
			--Inventory receipt has voucher already in inter-company database
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= 'Unable to unpost. The inventory receipt (' + @strInterCompanyReceiptNumber + ') has a voucher (' + @strBillId + ') in company ' + ISNULL(@strCompanyName, '') + '.'
				,[strSessionId]			= @strSessionId
			FROM tblARPostInvoiceHeader I
			WHERE I.ysnInterCompany = 1
		END
	END

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--If ysnAllowUserSelfPost is True in User Role
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot Unpost transactions you did not create.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	WHERE I.[intEntityId] <> I.[intUserId]
	  AND (I.[ysnUserAllowedToPostOtherTrans] IS NOT NULL AND I.[ysnUserAllowedToPostOtherTrans] = @OneBit)	
	  AND I.strSessionId = @strSessionId		

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--ALREADY HAVE PAYMENTS
	--AR-5542 added the additional comment for have payments
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= ARP.[strRecordNumber] + ' payment was already made on this ' + I.strTransactionType + '.' + CASE WHEN I.strTransactionType = 'Credit Memo' THEN ' Please remove payment record and try again.' ELSE '' END
		,[strSessionId]			= @strSessionId
	FROM tblARPayment ARP
	INNER JOIN tblARPaymentDetail ARPD ON ARP.[intPaymentId] = ARPD.[intPaymentId]						
	INNER JOIN tblARPostInvoiceHeader I ON ARPD.[intInvoiceId] = I.[intInvoiceId]
	WHERE @Recap = @ZeroBit
	  AND I.strTransactionType <> 'Cash Refund'
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Payments from Pay Voucher
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= APP.[strPaymentRecordNum] + ' payment was already made on this ' + I.strTransactionType + '.' + CASE WHEN I.strTransactionType = 'Credit Memo' THEN ' Please remove payment record and try again.' ELSE '' END
		,[strSessionId]			= @strSessionId
	FROM tblAPPayment APP
	INNER JOIN tblAPPaymentDetail APPD ON APP.[intPaymentId] = APPD.[intPaymentId]
	INNER JOIN tblARPostInvoiceHeader I ON APPD.[intInvoiceId] = I.[intInvoiceId]
	WHERE @Recap = @ZeroBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--Invoice with created Bank Deposit
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost invoice with created Bank Deposit.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblCMUndepositedFund CMUF ON I.[intInvoiceId] = CMUF.[intSourceTransactionId] AND I.[strInvoiceNumber] = CMUF.[strSourceTransactionId]
	INNER JOIN tblCMBankTransactionDetail CMBTD ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
	WHERE @Recap = @ZeroBit
	  AND CMUF.[strSourceSystem] = 'AR'
	  AND I.strTransactionType = 'Cash'
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--INVOICE CREATED FROM PATRONAGE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'This Invoice was created from Patronage > Issue Stock - ' + ISNULL(PAT.strIssueNo, '') + '. Unpost it from there.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	CROSS APPLY (
		SELECT TOP 1 P.strIssueNo
		FROM dbo.tblPATIssueStock P WITH (NOLOCK)
		WHERE P.intInvoiceId = I.intInvoiceId
			AND P.ysnPosted = @OneBit
	) PAT
	WHERE @Recap = @ZeroBit
	  AND I.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CASH REFUND ALREADY APPLIED IN PAY VOUCHER
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'This ' + I.[strTransactionType] + ' was already applied in ' + ISNULL(VOUCHER.strPaymentRecordNum, '') + '.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	CROSS APPLY (
		SELECT TOP 1 P.strPaymentRecordNum
		FROM dbo.tblAPPayment P WITH (NOLOCK)
		INNER JOIN tblAPPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
		WHERE PD.intInvoiceId = I.intInvoiceId
	) VOUCHER
	WHERE @Recap = @ZeroBit
	  AND I.strSessionId = @strSessionId
	
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CREDIT MEMO FROM FORGIVEN SERVICE CHARGE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost this Credit Memo (' + INV.strInvoiceNumber + '). Please unforgive the Service Charge.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON INV.intInvoiceId = I.intInvoiceId	
	WHERE @Recap = @ZeroBit
	  AND INV.ysnServiceChargeCredit = @OneBit
	  AND INV.strTransactionType = 'Credit Memo'
	  AND I.strSessionId = @strSessionId
	
	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	--CREDIT MEMO WITH CASH REFUND
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost this Credit Memo (' + I.strInvoiceNumber + '). Cash Refund(' + INV.strInvoiceNumber + ') created.'
		,[strSessionId]			= @strSessionId
	FROM tblARPostInvoiceHeader I
	LEFT OUTER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intOriginalInvoiceId
	WHERE @Recap = @ZeroBit
	  AND I.[ysnRefundProcessed] = @OneBit
	  AND I.strTransactionType = 'Credit Memo'
	  AND I.strSessionId = @strSessionId

	--TM Sync
	DELETE FROM @PostInvoiceDataFromIntegration
	INSERT INTO @PostInvoiceDataFromIntegration (
		  intInvoiceId
		, dtmDate
		, strInvoiceNumber
		, strTransactionType
		, intInvoiceDetailId
		, intItemId
		, strBatchId
		, intEntityId
		, intUserId
		, intSiteId
		, intPerformerId
		, ysnLeaseBilling
	)
    SELECT intInvoiceId			= PID.intInvoiceId
		, dtmDate				= PID.dtmDate
		, strInvoiceNumber		= PID.strInvoiceNumber
		, strTransactionType	= PID.strTransactionType
		, intInvoiceDetailId	= PID.intInvoiceDetailId
		, intItemId				= PID.intItemId
		, strBatchId			= PID.strBatchId
		, intEntityId			= PID.intEntityId
		, intUserId				= PID.intUserId
		, intSiteId				= PID.intSiteId
		, intPerformerId		= PID.intPerformerId
		, ysnLeaseBilling		= PID.ysnLeaseBilling
	FROM tblARPostInvoiceDetail PID 
	INNER JOIN tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID]
	WHERE PID.intSiteId IS NOT NULL
	  AND PID.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnTMGetInvalidInvoicesForSync](@PostInvoiceDataFromIntegration, @ZeroBit)

	--MFG Auto Blend
	DELETE FROM @PostInvoiceDataFromIntegration
	INSERT INTO @PostInvoiceDataFromIntegration (
		  intInvoiceId
		, dtmDate
		, strInvoiceNumber
		, strTransactionType
		, intInvoiceDetailId
		, intItemId
		, strBatchId
		, intEntityId
		, intUserId
		, intCompanyLocationId
		, intItemUOMId
		, intSubLocationId
		, intStorageLocationId
		, dblQuantity
	)
    SELECT intInvoiceId			= PID.intInvoiceId
		, dtmDate				= PID.dtmDate
		, strInvoiceNumber		= PID.strInvoiceNumber
		, strTransactionType	= PID.strTransactionType
		, intInvoiceDetailId	= PID.intInvoiceDetailId
		, intItemId				= PID.intItemId
		, strBatchId			= PID.strBatchId
		, intEntityId			= PID.intEntityId
		, intUserId				= PID.intUserId
		, intCompanyLocationId	= PID.intCompanyLocationId
		, intItemUOMId			= PID.intItemUOMId
		, intSubLocationId		= PID.intSubLocationId
		, intStorageLocationId	= PID.intStorageLocationId
		, dblQuantity			= PID.dblQuantity
	FROM tblARPostInvoiceDetail PID 
	WHERE PID.[ysnBlended] <> @ZeroBit 
	  AND PID.[ysnAutoBlend] = @OneBit
	  AND PID.strSessionId = @strSessionId

	INSERT INTO tblARPostInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
		,[strSessionId]			= @strSessionId
	FROM 
		[dbo].[fnMFGetInvalidInvoicesForPosting](@PostInvoiceDataFromIntegration, @ZeroBit)

	--Don't allow Imported Invoice from Origin to be unposted
	DECLARE @IsAG BIT = @ZeroBit
	DECLARE @IsPT BIT = @ZeroBit

	IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'coctlmst')
		SELECT TOP 1 
			@IsAG	= CASE WHEN ISNULL(coctl_ag, '') = 'Y' AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst') THEN @OneBit ELSE @ZeroBit END
			,@IsPT	= CASE WHEN ISNULL(coctl_pt, '') = 'Y' AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst') THEN @OneBit ELSE @ZeroBit END 
		FROM
			coctlmst

	IF @IsAG = @OneBit
		BEGIN
			INSERT INTO tblARPostInvalidInvoiceData
		        ([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError]
				,[strSessionId])
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]	
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= I.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
				,[strSessionId]			= @strSessionId
			FROM tblARPostInvoiceHeader I
			INNER JOIN agivcmst OI WITH (NOLOCK) ON I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[agivc_ivc_no] COLLATE Latin1_General_CI_AS
			WHERE I.[ysnPosted] = @OneBit
			  AND I.[ysnImportedAsPosted] = @OneBit 
			  AND I.[ysnImportedFromOrigin] = @OneBit
			  AND I.strSessionId = @strSessionId
		END

	IF @IsPT = @OneBit
		BEGIN
			INSERT INTO tblARPostInvalidInvoiceData
		        ([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError]
				,[strSessionId])
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= I.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
				,[strSessionId]			= @strSessionId
			FROM tblARPostInvoiceHeader I
			INNER JOIN ptivcmst OI WITH (NOLOCK) ON I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[ptivc_invc_no] COLLATE Latin1_General_CI_AS
			WHERE I.[ysnPosted] = @OneBit
			  AND I.[ysnImportedAsPosted] = @OneBit 
			  AND I.[ysnImportedFromOrigin] = @OneBit
			  AND I.strSessionId = @strSessionId
		END

	INSERT INTO tblARPostInvoiceGLEntries
        ([dtmDate]
        ,[strBatchId]
        ,[intAccountId]
        ,[dblDebit]
        ,[dblCredit]
        ,[dblDebitUnit]
        ,[dblCreditUnit]
        ,[strDescription]
        ,[strCode]
        ,[strReference]
        ,[intCurrencyId]
        ,[dblExchangeRate]
        ,[dtmDateEntered]
        ,[dtmTransactionDate]
        ,[strJournalLineDescription]
        ,[intJournalLineNo]
        ,[ysnIsUnposted]
        ,[intUserId]
        ,[intEntityId]
        ,[strTransactionId]
        ,[intTransactionId]
        ,[strTransactionType]
        ,[strTransactionForm]
        ,[strModuleName]
        ,[intConcurrencyId]
        ,[dblDebitForeign]
        ,[dblDebitReport]
        ,[dblCreditForeign]
        ,[dblCreditReport]
        ,[dblReportingRate]
        ,[dblForeignRate]
        ,[strDocument]
        ,[strComments]
        ,[strSourceDocumentId]
        ,[intSourceLocationId]
        ,[intSourceUOMId]
        ,[dblSourceUnitDebit]
        ,[dblSourceUnitCredit]
        ,[intCommodityId]
        ,[intSourceEntityId]
		,[strSessionId])
    SELECT 
         [dtmDate]						= GLD.[dtmDate]
        ,[strBatchId]					= @BatchId
        ,[intAccountId]					= GLD.[intAccountId]
        ,[dblDebit]						= GLD.[dblCredit]
        ,[dblCredit]					= GLD.[dblDebit]
        ,[dblDebitUnit]					= GLD.[dblCreditUnit]
        ,[dblCreditUnit]				= GLD.[dblDebitUnit]
        ,[strDescription]				= GLD.[strDescription]
        ,[strCode]						= GLD.[strCode]
        ,[strReference]					= GLD.[strReference]
        ,[intCurrencyId]				= GLD.[intCurrencyId]
        ,[dblExchangeRate]				= GLD.[dblExchangeRate]
        ,[dtmDateEntered]				= PID.[dtmDatePosted]
        ,[dtmTransactionDate]			= GLD.[dtmTransactionDate]
        ,[strJournalLineDescription]	= REPLACE(GLD.[strJournalLineDescription], 'Posted ', 'Unposted ')
        ,[intJournalLineNo]				= GLD.[intJournalLineNo]
        ,[ysnIsUnposted]				= 1
        ,[intUserId]					= GLD.[intUserId]
        ,[intEntityId]					= GLD.[intUserId]
        ,[strTransactionId]				= GLD.[strTransactionId]
        ,[intTransactionId]				= GLD.[intTransactionId]
        ,[strTransactionType]			= GLD.[strTransactionType]
        ,[strTransactionForm]			= GLD.[strTransactionForm]
        ,[strModuleName]				= GLD.[strModuleName]
        ,[intConcurrencyId]				= 1
        ,[dblDebitForeign]				= GLD.[dblCreditForeign]
        ,[dblDebitReport]				= GLD.[dblCreditReport]
        ,[dblCreditForeign]				= GLD.[dblDebitForeign]
        ,[dblCreditReport]				= GLD.[dblDebitReport]
        ,[dblReportingRate]				= GLD.[dblReportingRate]
        ,[dblForeignRate]				= GLD.[dblForeignRate]
        ,[strDocument]					= GLD.[strDocument]
        ,[strComments]					= GLD.[strComments]
        ,[strSourceDocumentId]			= GLD.[strSourceDocumentId]
        ,[intSourceLocationId]			= GLD.[intSourceLocationId]
        ,[intSourceUOMId]				= GLD.[intSourceUOMId]
        ,[dblSourceUnitDebit]			= GLD.[dblSourceUnitCredit]
        ,[dblSourceUnitCredit]			= GLD.[dblSourceUnitDebit]
        ,[intCommodityId]				= GLD.[intCommodityId]
        ,[intSourceEntityId]			= GLD.[intSourceEntityId]
		,[strSessionId]					= @strSessionId
    FROM tblARPostInvoiceHeader PID
    INNER JOIN tblGLDetail GLD ON PID.[intInvoiceId] = GLD.[intTransactionId] AND PID.[strInvoiceNumber] = GLD.[strTransactionId]							 
    WHERE GLD.[ysnIsUnposted] = 0
	  AND PID.strSessionId = @strSessionId
    ORDER BY GLD.[intGLDetailId]
END

--Contract Schedule/Balance Validation
INSERT INTO @ItemsForContracts (
	intInvoiceId
	, intInvoiceDetailId	
	, intEntityId
	, intUserId
	, intContractDetailId
	, intContractHeaderId
	, dtmDate
	, dblQuantity
	, dblQtyShipped
	, strInvoiceNumber
	, strTransactionType
	, intItemId
	, strItemNo
	, strBatchId
	, ysnFromReturn
)
SELECT intInvoiceId			= intInvoiceId
	, intInvoiceDetailId	= intInvoiceDetailId
	, intEntityId			= intEntityId
	, intUserId				= intUserId
	, intContractDetailId	= intContractDetailId
	, intContractHeaderId	= intContractHeaderId
	, dtmDate				= dtmDate
	, dblQuantity			= dblQuantity
	, dblQtyShipped			= dblQuantity
	, strInvoiceNumber		= strInvoiceNumber
	, strTransactionType	= strTransactionType
	, intItemId				= intItemId
	, strItemNo				= strItemNo
	, strBatchId			= strBatchId
	, ysnFromReturn			= ysnFromReturn
FROM tblARPostItemsForContracts
WHERE strType = 'Contract Balance'
  AND ysnFromReturn = 0
  AND strSessionId = @strSessionId

INSERT INTO tblARPostInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]
)
SELECT [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]			= @strSessionId
FROM dbo.fnCTValidateInvoiceContract(@ItemsForContracts)

--VALIDATE INVOICE GL ENTRIES
INSERT INTO tblARPostInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Debit and credit amounts are not balanced.'
	, [strSessionId]		= @strSessionId
FROM tblARPostInvoiceGLEntries GL
INNER JOIN tblARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
WHERE I.strSessionId = @strSessionId
  AND GL.strSessionId = @strSessionId
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId
HAVING SUM(GL.dblDebit) - SUM(GL.dblCredit) <> 0

INSERT INTO tblARPostInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Foreign Debit and credit amounts are not balanced.'
	, [strSessionId]		= @strSessionId
FROM tblARPostInvoiceGLEntries GL
INNER JOIN tblARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
WHERE I.strSessionId = @strSessionId
  AND GL.strSessionId = @strSessionId
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId
HAVING SUM(GL.dblDebitForeign) - SUM(GL.dblCreditForeign) <> 0

INSERT INTO tblARPostInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Unable to find an open fiscal year period for Accounts Receivable module to match the transaction date.'
	, [strSessionId]		= @strSessionId
FROM tblARPostInvoiceGLEntries GL
INNER JOIN tblARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
INNER JOIN tblGLFiscalYearPeriod FYP ON GL.dtmDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
WHERE FYP.ysnAROpen = 0 
  AND I.strSessionId = @strSessionId
  AND GL.strSessionId = @strSessionId
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId

INSERT INTO tblARPostInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
	, [strSessionId]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= II.[strBatchId]
	, [strPostingError]		= I.strInvoiceNumber + ' has discrepancy on ' + GL.strAccountCategory + ' of ' + LTRIM(STR(ISNULL(I.dblBaseInvoiceTotal, 0), 16, 2))
	, [strSessionId]		= @strSessionId
FROM tblARInvoice I
INNER JOIN tblARPostInvoiceHeader II ON I.intInvoiceId = II.intInvoiceId AND I.strInvoiceNumber = II.strInvoiceNumber
INNER JOIN (
	SELECT intTransactionId		= GL.intTransactionId
	     , strTransactionId		= GL.strTransactionId
		 , strAccountCategory	= GLAC.strAccountCategory
	     , dblAmount			= SUM(dblDebit - dblCredit)
	FROM tblGLDetail GL
	INNER JOIN tblGLAccount GLA ON GL.intAccountId = GLA.intAccountId
	INNER JOIN tblGLAccountSegmentMapping GLSM ON GLA.intAccountId = GLSM.intAccountId
	INNER JOIN tblGLAccountSegment GLS ON GLSM.intAccountSegmentId = GLS.intAccountSegmentId
	INNER JOIN tblGLAccountStructure GLAST ON GLS.intAccountStructureId = GLAST.intAccountStructureId AND GLAST.strType = 'Primary'
	INNER JOIN tblGLAccountCategory GLAC ON GLS.intAccountCategoryId = GLAC.intAccountCategoryId
	INNER JOIN tblARPostInvoiceHeader IH ON IH.intInvoiceId = GL.intTransactionId AND IH.strInvoiceNumber = GL.strTransactionId	
	WHERE GLAC.strAccountCategory IN ('AR Account', 'Undeposited Funds')
	  AND GL.ysnIsUnposted = 0
	  AND GL.strCode = 'AR'
	  AND IH.ysnPost = 1
	  AND IH.strSessionId = @strSessionId
	GROUP BY GL.intTransactionId, GL.strTransactionId, GLAC.strAccountCategory
	HAVING SUM(dblDebit - dblCredit) <> 0 
) GL ON I.intInvoiceId = GL.intTransactionId
    AND I.strInvoiceNumber = GL.strTransactionId
	AND ((I.strTransactionType <> 'Cash' AND GL.strAccountCategory = 'AR Account') OR (I.strTransactionType = 'Cash' AND GL.strAccountCategory = 'Undeposited Funds'))	
WHERE II.ysnPost = 1
  AND II.strSessionId = @strSessionId

UPDATE tblARPostInvalidInvoiceData
SET [strBatchId] = @BatchId
WHERE LTRIM(RTRIM(ISNULL([strBatchId],''))) = ''
  AND strSessionId = @strSessionId

RETURN 1