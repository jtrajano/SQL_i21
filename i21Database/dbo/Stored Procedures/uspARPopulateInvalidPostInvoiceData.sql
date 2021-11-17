CREATE PROCEDURE [dbo].[uspARPopulateInvalidPostInvoiceData]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
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

 --IC Reserve Stock
IF @Recap = @ZeroBit	
	EXEC dbo.uspARPostItemResevation

DECLARE @ItemsForContracts					[InvoicePostingTable]
EXEC [dbo].[uspARPopulateContractDetails] @Post = @Post

DECLARE @strDatabaseName NVARCHAR(50)
DECLARE @strCompanyName NVARCHAR(50)
DECLARE @intInvoiceId INT = 0

SELECT @intInvoiceId = intInvoiceId FROM ##ARPostInvoiceHeader
SELECT @strDatabaseName = strDatabaseName, @strCompanyName = strCompanyName FROM [dbo].[fnARGetInterCompany](@intInvoiceId)

IF @Post = @OneBit
BEGIN
    DECLARE @InvoiceIds 						[InvoiceId]
	DECLARE @PostInvoiceDataFromIntegration 	[InvoicePostingTable]
	DECLARE @ItemsForCosting 					[ItemCostingTableType]
	DECLARE @ItemsForCostingZeroCostValidation 	[ItemCostingTableType]
	DECLARE @ItemsForStoragePosting 			[ItemCostingTableType]
	DECLARE @ItemsForInTransitCosting 			[ItemInTransitCostingTableType]
	
	EXEC [dbo].[uspARPopulateItemsForCosting]
	EXEC [dbo].[uspARPopulateItemsForInTransitCosting]
	EXEC [dbo].[uspARPopulateItemsForStorageCosting]
	EXEC [dbo].[uspARGenerateEntriesForAccrual]
	EXEC [dbo].[uspARGenerateGLEntriesForInvoices]
	
	INSERT INTO ##ARInvalidInvoiceData (
		  [intInvoiceId]
		, [strInvoiceNumber]
		, [strTransactionType]
		, [intInvoiceDetailId]
		, [intItemId]
		, [strBatchId]
		, [strPostingError]
	)
	SELECT [intInvoiceId]			= I.[intInvoiceId]
		 , [strInvoiceNumber]		= I.[strInvoiceNumber]		
		 , [strTransactionType]		= I.[strTransactionType]
		 , [intInvoiceDetailId]		= I.[intInvoiceDetailId] 
		 , [intItemId]				= I.[intItemId] 
		 , [strBatchId]				= I.[strBatchId]
		 , [strPostingError]		= 'Negative stock quantity is not allowed for Negative Stock at In-Transit Location.'
	FROM ##ARPostInvoiceHeader I
	INNER JOIN (
		SELECT DISTINCT COSTING.intTransactionId
		     		  , COSTING.strTransactionId
		FROM ##ARItemsForInTransitCosting COSTING
		INNER JOIN (
			SELECT ICT.strTransactionId
				 , ICT.intTransactionId
				 , ICT.intLotId
				 , dblAvailableQty	= SUM(CASE WHEN ICT.intLotId IS NULL THEN ISNULL(IAC.dblStockIn, 0) - ISNULL(IAC.dblStockOut, 0) ELSE ISNULL(IL.dblStockIn, 0) - ISNULL(IL.dblStockOut, 0) END)
			FROM tblICInventoryTransaction ICT 
			LEFT JOIN tblICInventoryActualCost IAC ON ICT.strTransactionId = IAC.strTransactionId AND ICT.intTransactionId = IAC.intTransactionId AND ICT.intTransactionDetailId = IAC.intTransactionDetailId
			LEFT JOIN tblICInventoryLot IL ON ICT.strTransactionId = IL.strTransactionId AND ICT.intTransactionId = IL.intTransactionId AND ICT.intTransactionDetailId = IL.intTransactionDetailId AND ICT.intLotId = IL.intLotId AND ICT.intItemLocationId = IL.intItemLocationId
			WHERE ICT.ysnIsUnposted = 0
			  AND ISNULL(IL.ysnIsUnposted, 0) = 0
  			  AND ISNULL(IAC.ysnIsUnposted, 0) = 0  
			  AND ICT.intInTransitSourceLocationId IS NOT NULL
			GROUP BY ICT.strTransactionId, ICT.intTransactionId, ICT.intLotId
		) ICT ON ICT.strTransactionId = COSTING.strSourceTransactionId	
		     AND ICT.intTransactionId = COSTING.intSourceTransactionId
			 AND (ICT.intLotId IS NULL OR (ICT.intLotId IS NOT NULL AND ICT.intLotId = COSTING.intLotId))
			 AND ABS(COSTING.dblQty) > ICT.dblAvailableQty
	) INTRANSIT ON I.intInvoiceId = INTRANSIT.intTransactionId AND I.strInvoiceNumber = INTRANSIT.strTransactionId
	OUTER APPLY (
		SELECT intLoadId
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		WHERE ARI.intInvoiceId = I.intOriginalInvoiceId
	) IL
	WHERE I.strTransactionType = 'Invoice'
	AND (I.[ysnFromProvisional] = 0 OR (I.[ysnFromProvisional] = 1 AND IL.[intLoadId] IS NULL))

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--ALREADY POSTED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The transaction is already posted.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE  
		I.[ysnPosted] = @OneBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--DUPLICATE BATCH ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Duplicate Batch ID'
	FROM ##ARPostInvoiceHeader I
	WHERE  
		EXISTS(SELECT strBatchId FROM tblGLDetail WHERE strBatchId = @BatchId)
	
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Recurring Invoice
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Posting recurring invoice(' + I.[strInvoiceNumber] + ') is not allowed.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE  
		I.[ysnRecurring] = @OneBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
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
	FROM ##ARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblEMEntityLocation SHIPTO ON INV.intShipToLocationId = SHIPTO.intEntityLocationId
	INNER JOIN tblEMEntityLocation BILLTO ON INV.intBillToLocationId = BILLTO.intEntityLocationId
	WHERE SHIPTO.ysnActive = 0 OR BILLTO.ysnActive = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--If ysnAllowUserSelfPost is True in User Role
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot Post transactions you did not create.'
	FROM 					
		##ARPostInvoiceHeader I
	WHERE  
		I.[intEntityId] <> I.[intUserId]
		AND (I.[ysnUserAllowedToPostOtherTrans] IS NOT NULL AND I.[ysnUserAllowedToPostOtherTrans] = 1)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	-- Tank consumption site
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find a tank consumption site for item no. ' + I.[strItemNo]
	FROM 
		##ARPostInvoiceDetail I					
	WHERE
		I.[intSiteId] IS NULL
		AND I.[strType] = 'Tank Delivery'
		AND I.[ysnTankRequired] = @OneBit
		AND I.[strItemType] <> 'Comment'		
		
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--zero amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice ' THEN 'You cannot post an ' + I.[strTransactionType] + ' with zero amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with zero amount.' END
	FROM 
		##ARPostInvoiceHeader I					
	WHERE
		I.[dblInvoiceTotal] = @ZeroDecimal
		AND I.[strTransactionType] <> 'Cash Refund'
		AND I.[strImportFormat] <> 'CarQuest'		
		AND NOT EXISTS(SELECT NULL FROM ##ARPostInvoiceDetail ARID WHERE ARID.[intInvoiceId] = I.[intInvoiceId] AND ARID.[intItemId] IS NOT NULL)		

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--zero amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice' THEN 'You cannot post an ' + I.[strTransactionType] + ' with negative amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with negative amount.' END
	FROM 
		##ARPostInvoiceHeader I					
	WHERE
		I.[dblInvoiceTotal] < @ZeroDecimal

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Zero Quantity
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot post an ' + I.[strTransactionType] + ' with a inventory item(' + I.[strItemDescription] + ') of zero quantity.'
	FROM 
		##ARPostInvoiceDetail I
	WHERE
		I.[dblQtyShipped] = @ZeroDecimal 
		AND I.[ysnStockTracking] = @OneBit
		AND I.[strType] <> 'Tank Delivery'
		
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Inactive Customer
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Customer - ' + I.[strCustomerNumber] + ' is not active!'
	FROM 
		##ARPostInvoiceHeader I	
	--INNER JOIN dbo.tblARCustomer  ARC
	--		ON I.[intEntityCustomerId] = ARC.[intEntityId]						
	WHERE
		I.[ysnCustomerActive] = @ZeroBit

	IF(ISNULL(@strDatabaseName, '') <> '')
	BEGIN
		--Check if vendor exists
		DECLARE @ysnVendorExistQuery nvarchar(500)
		DECLARE @ysnVendorExistParam NVARCHAR(500)
		DECLARE @ysnVendorExist BIT = 0 
		DECLARE @intInterCompanyVendorId INT
		DECLARE @strInterCompanyVendorId NVARCHAR(50)

		SELECT @strInterCompanyVendorId = [strInterCompanyVendorId], @intInterCompanyVendorId = [intInterCompanyVendorId] FROM #ARPostInvoiceHeader
		SELECT @ysnVendorExistQuery = N'SELECT @ysnVendorExist = 1 FROM [' + @strDatabaseName + '].[dbo].tblAPVendor WHERE intEntityId = ''' + CAST(@intInterCompanyVendorId AS NVARCHAR(50)) + ''''

		SET @ysnVendorExistParam = N'@ysnVendorExist int OUTPUT'

		EXEC sp_executesql @ysnVendorExistQuery, @ysnVendorExistParam, @ysnVendorExist = @ysnVendorExist OUTPUT

		IF(@ysnVendorExist = 0)
		BEGIN
			INSERT INTO #ARInvalidInvoiceData
				([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError])
			--Vendor not existing in inter-company database
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= 'Vendor - ' + I.strInterCompanyVendorId + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
			FROM 
				#ARPostInvoiceHeader I
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
		FROM #ARPostInvoiceDetail PID
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
				INSERT INTO #ARInvalidInvoiceData
					([intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError])
				--Item not existing in inter-company database
				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= 'Item - ' + @strInterCompanyItemNo + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
				FROM 
					#ARPostInvoiceHeader I
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
		FROM #ARPostInvoiceDetail PID
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
				INSERT INTO #ARInvalidInvoiceData
					([intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError])
				--Freight term not existing in inter-company database
				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= 'Freight term - ' + @strInterCompanyFreightTerm + ' is not existing in Company ' + ISNULL(@strCompanyName, '') + '!'
				FROM 
					#ARPostInvoiceHeader I
			END

			SET @ysnAllFreightTermsExist = 0
												
			DELETE FROM #ARInterCompanyFreightTerm WHERE [strFreightTerm] = @strInterCompanyFreightTerm
		END
	END
			
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Customer Credit Limit
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]        
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]            = I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Customer credit limit is either blank or COD! Only Cash Sale transaction is allowed.'
	FROM 
		##ARPostInvoiceHeader I 
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId                      
	WHERE
		I.[dblCustomerCreditLimit] IS NULL 
		AND I.[strTransactionType] NOT IN ('Cash', 'Cash Refund')
		AND I.[strType] != 'POS'	
		AND ISNULL(INV.[ysnValidCreditCode], 0) = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Approval
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]        
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]            = I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN VI.ysnHasCreditApprover = 0 THEN 'The Customer''s credit limit has been reached but there is no approver configured. This invoice cannot be posted without an authorized approver.' ELSE ISNULL(SMT.strApprovalStatus, 'Not Yet Approved') END
	FROM 
		##ARPostInvoiceHeader I 
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblSMTransaction SMT ON SMT.intRecordId = INV.intInvoiceId
	INNER JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'Invoice'
	INNER JOIN vyuARGetInvoice VI ON VI.intInvoiceId = INV.intInvoiceId
	WHERE ISNULL(SMT.strApprovalStatus, '') <> 'Approved'
	AND VI.ysnHasCreditApprover = 0
    AND ISNULL(VI.strCreditCode, '') NOT IN ('', 'Always Allow', 'Normal', 'Reject Orders', 'COD')
    AND ((I.dblInvoiceTotal + VI.dblARBalance > VI.dblCreditLimit) OR ISNULL(VI.dblCreditStopDays, 0) > 0)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Approval
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]        
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]            = I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= ISNULL(SMT.strApprovalStatus, 'Not Yet Approved')
	FROM 
		##ARPostInvoiceHeader I 
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblSMTransaction SMT ON SMT.intRecordId = INV.intInvoiceId
	INNER JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'Invoice'
	INNER JOIN vyuARGetInvoice VI ON VI.intInvoiceId = INV.intInvoiceId
	WHERE ISNULL(SMT.strApprovalStatus, '') IN  ('Waiting for Approval', 'Waiting for Submit')
	AND VI.ysnHasCreditApprover = 1	
    AND ISNULL(VI.strCreditCode, '') NOT IN ('', 'Always Allow', 'Normal', 'Reject Orders', 'COD')

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--UOM is required
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'UOM is required for item ' + ISNULL(NULLIF(I.[strItemDescription], ''), I.[strItemNo]) + '.'
	FROM ##ARPostInvoiceDetail I	
	WHERE I.[strTransactionType] = 'Invoice'	
		AND (I.[intItemUOMId] IS NULL OR I.[intItemUOMId] = 0) 
		AND (I.[intInventoryShipmentItemId] IS NULL OR I.[intInventoryShipmentItemId] = 0)
		AND (I.[intSalesOrderDetailId] IS NULL OR I.[intSalesOrderDetailId] = 0)
		AND (I.[intLoadDetailId] IS NULL OR I.[intLoadDetailId] = 0)
		AND (I.[intItemId] IS NOT NULL OR I.[intItemId] <> 0)
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software', 'Comment', '')	

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Dsicount Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN ' The Receivable Discount account assigned to item ' + I.[strItemNo] + ' is not valid.' ELSE 'Receivable Discount account was not set up for item ' + I.[strItemNo] END
	FROM ##ARPostInvoiceDetail I	
	LEFT OUTER JOIN ##ARInvoiceItemAccount  IST
			ON I.[intItemId] = IST.[intItemId] 
			AND I.[intCompanyLocationId] = IST.[intLocationId] 
	LEFT OUTER JOIN dbo.tblGLAccount GLA
			ON ISNULL(IST.[intDiscountAccountId], I.[intDiscountAccountId]) = GLA.[intAccountId]		 
	WHERE
		((ISNULL(IST.[intDiscountAccountId],0) = 0  AND  ISNULL(I.[intDiscountAccountId],0) = 0) OR GLA.[intAccountId] IS NULL)
		AND I.[dblDiscount] <> @ZeroDecimal		
		AND I.[strItemType] <> 'Comment'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Currency is required
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'No currency has been specified.'
	FROM 
		##ARPostInvoiceHeader I			 
	WHERE
		ISNULL(I.[intCurrencyId], 0) = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--No Terms specified
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'No terms has been specified.'
	FROM 
		##ARPostInvoiceHeader I			 
	WHERE
		ISNULL(I.[intTermId], 0) = 0


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--NOT BALANCE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The debit and credit amounts are not balanced.'
	FROM 
		##ARPostInvoiceHeader I			 
	WHERE
		I.[dblInvoiceTotal] <> ((SELECT SUM([dblTotal]) FROM ##ARPostInvoiceDetail ARID WHERE ARID.[intInvoiceId] = I.[intInvoiceId]) + ISNULL(I.[dblShipping],0.0) + ISNULL(I.[dblTax],0.0))

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Header Account ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The AR account is not valid.' ELSE 'The AR account is not specified.' END
	FROM 
		##ARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount GLA 
			ON ISNULL(I.[intAccountId], 0) = GLA.[intAccountId]		 
	WHERE
		(ISNULL(I.[intAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Undeposited Fund Account ID
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' is using invalid account. Undeposited Fund Account is for Cash and Cash Refund transactions only.'
	FROM ##ARPostInvoiceHeader I
	INNER JOIN vyuGLAccountDetail GLA ON ISNULL(I.[intAccountId], 0) = GLA.[intAccountId]		 
	WHERE I.strTransactionType NOT IN ('Cash', 'Cash Refund')
	  AND GLA.strAccountCategory = 'Undeposited Funds'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CASH TRANSASCTIONS USING OTHER ACCOUNT
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' is using invalid account. Use Undeposited Fund Account for Cash transactions.'
	FROM ##ARPostInvoiceHeader I
	INNER JOIN vyuGLAccountDetail GLA ON ISNULL(I.[intAccountId], 0) = GLA.[intAccountId]		 
	WHERE I.strTransactionType = 'Cash'
	  AND GLA.strAccountCategory <> 'Undeposited Funds'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Company Location
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Company location of ' + I.[strInvoiceNumber] + ' was not set.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE
		I.[intCompanyLocationId] IS NULL


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Freight Expenses Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Freight Income account is not valid.' ELSE 'The Freight Income account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
	FROM 
		##ARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount GLA
			ON I.[intFreightIncome] = GLA.[intAccountId]						
	WHERE
		(ISNULL(I.[intFreightIncome], 0) = 0 OR GLA.[intAccountId] IS NULL)
		AND ISNULL(I.[dblShipping],0) <> @ZeroDecimal

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Undeposited Funds Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Undeposited Funds account of Company Location ' + I.[strCompanyLocationName] + ' is not valid.' ELSE 'The Undeposited Funds account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
	FROM 
		##ARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount  GLA
			ON I.[intUndepositedFundsId] = GLA.[intAccountId]					
	WHERE
		(ISNULL(I.[intUndepositedFundsId], 0) = 0 OR GLA.[intAccountId] IS NULL)
		AND (
			I.[strTransactionType] = 'Cash'
			OR
			(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.[intInvoiceId] = I.[intInvoiceId] AND tblARPrepaidAndCredit.[ysnApplied] = 1 AND tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount] <> 0 ))
			)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--AP Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The AP account of Company Location ' + I.[strCompanyLocationName] + ' is not valid.' ELSE 'The AP account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
	FROM 
		##ARPostInvoiceHeader I
	LEFT OUTER JOIN tblGLAccount  GLA
			ON I.[intAPAccount] = GLA.[intAccountId]					
	WHERE
		(ISNULL(I.[intAPAccount], 0) = 0 OR GLA.[intAccountId] IS NULL)
		AND I.[strTransactionType] = 'Cash Refund'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Sales Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales account of Company Location ' + I.[strCompanyLocationName] + ' is not valid.' ELSE 'The Sales account of Company Location ' + I.[strCompanyLocationName] + ' was not set.' END
	FROM 
		##ARPostInvoiceDetail I				 
	LEFT OUTER JOIN tblGLAccount  GLA
			ON I.[intLocationSalesAccountId] = GLA.[intAccountId]			
	WHERE
		(ISNULL(I.[intLocationSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
		AND ISNULL(I.[intServiceChargeAccountId],0) = 0
		AND ISNULL(I.[intSalesAccountId], 0) = 0
		AND I.[intItemId] IS NULL
		AND I.[dblTotal] <> @ZeroDecimal


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Accrual Not in Fiscal Year
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strInvoiceNumber] + ' has an Accrual setup up to ' + CONVERT(NVARCHAR(30),DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate])), 101) + ' which does not fall into a valid Fiscal Period.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE
		ISNULL(I.[intPeriodsToAccrue],0) > 1  
		AND ISNULL(dbo.isOpenAccountingDate(DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate]))), @ZeroBit) = @ZeroBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Payment Method
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Check Number is required for Cash transaction type and Check payment method.'
	FROM 
		##ARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON I.intInvoiceId = INV.intInvoiceId
	INNER JOIN tblSMPaymentMethod SM ON INV.intPaymentMethodId = SM.intPaymentMethodID	
	WHERE SM.strPaymentMethod = 'Check'
	  AND INV.strTransactionType = 'Cash'
	  AND ISNULL(INV.strPaymentInfo, '') = ''

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Deferred Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Deferred Revenue account in the Company Configuration was not set.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE
		ISNULL(I.intPeriodsToAccrue,0) > 1
		AND ISNULL(I.[intDeferredRevenueAccountId], 0) = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Deferred Revenue Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Deferred Revenue account is not valid.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE
		ISNULL(I.[intPeriodsToAccrue], 0) > 1
		AND ISNULL(I.[intDeferredRevenueAccountId], 0) <> 0
		AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WITH (NOLOCK) WHERE GLA.[intAccountId] = I.[intDeferredRevenueAccountId])


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Invoice for accrual with Inventory Items
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Invoice : ' + I.[strInvoiceNumber] + ' is for accrual and must not include an inventory item : ' + I.[strItemNo] + '.'
	FROM 
		##ARPostInvoiceDetail I			
	WHERE
		I.[intPeriodsToAccrue] > 1
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Provisional Invoice Posting
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Posting Provisional Invoice is disabled in Company Configuration.'
	FROM ##ARPostInvoiceHeader I					
	WHERE I.[strType] = 'Provisional'
	  AND I.[ysnProvisionalWithGL] = @ZeroBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Sales Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM ##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId]
											  AND I.[intItemId] = Acct.[intItemId] 		
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intSalesAccountId] = GLA.[intAccountId]
	LEFT OUTER JOIN tblGLAccount GLAGA ON Acct.[intGeneralAccountId] = GLAGA.[intAccountId]
	WHERE I.[strItemType] = 'Non-Inventory'
	  AND I.[strItemType] <> 'Comment'
	  AND (ISNULL(Acct.[intSalesAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)
	  AND (ISNULL(Acct.[intGeneralAccountId],0) = 0 OR GLAGA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The General Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM ##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct ON I.[intCompanyLocationId] = Acct.[intLocationId]
											  AND I.[intItemId] = Acct.[intItemId] 		
	LEFT OUTER JOIN tblGLAccount GLA ON Acct.[intGeneralAccountId] = GLA.[intAccountId]
	WHERE I.[strItemType] = 'Service'
	  AND I.[strItemType] <> 'Comment'
	  AND (ISNULL(Acct.[intGeneralAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Type
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Type of item - ' + I.[strItemNo] + ' is not valid.'
	FROM ##ARPostInvoiceDetail I
	WHERE I.[strItemType] = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') NOT IN ('License/Maintenance', 'Maintenance Only', 'SaaS', 'License Only')


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Frequency
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Frequency of item - ' + I.[strItemNo] + ' is not valid.'
	FROM ##ARPostInvoiceDetail I
	WHERE
		ISNULL(I.[strItemType],'') = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		AND ISNULL(I.[strFrequency], '') NOT IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Date
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Start Date of item - ' + I.[strItemNo] + ' is required.'
	FROM ##ARPostInvoiceDetail I
	WHERE
		I.[strItemType] = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		AND ISNULL(I.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
		AND I.[dtmMaintenanceDate] IS NULL

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - License Amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The License Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
	FROM ##ARPostInvoiceDetail I
	WHERE
		I.[strItemType] = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') IN ('License Only')
		AND ISNULL(I.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
		AND ISNULL(I.[dblLicenseAmount], @ZeroDecimal) <> ISNULL(I.[dblPrice], @ZeroDecimal)


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Amount
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
	FROM ##ARPostInvoiceDetail I
	WHERE
		I.[strItemType] = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') IN ('Maintenance Only', 'SaaS')
		AND ISNULL(I.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
		AND ISNULL(I.[dblMaintenanceAmount], @ZeroDecimal) <> ISNULL(I.[dblPrice], @ZeroDecimal)


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Amount + License
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Maintenance Amount + License Amount of item - ' + I.[strItemNo] + ' does not match the Price.'
	FROM ##ARPostInvoiceDetail I
	WHERE
		I.[strItemType] = 'Software'	
		AND ISNULL(I.[strMaintenanceType], '') IN ('License/Maintenance')
		AND ISNULL(I.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
		AND ((ISNULL(I.[dblMaintenanceAmount], @ZeroDecimal) + ISNULL(I.[dblLicenseAmount], @ZeroDecimal)) <> ISNULL(I.[dblPrice], @ZeroDecimal))

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - Maintenance Sales
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Maintenance Sales account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Maintenance Sales of item - ' + I.[strItemNo] + ' were not specified.' END
	FROM 
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct
			ON I.[intCompanyLocationId] = Acct.[intLocationId] 
			AND I.[intItemId] = Acct.[intItemId]
	LEFT OUTER JOIN tblGLAccount GLA
			ON Acct.[intMaintenanceSalesAccountId] = GLA.[intAccountId]	 								
	WHERE
		I.[strItemType] = 'Software'	
		AND I.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		AND (ISNULL(Acct.[intMaintenanceSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Software - General Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The General Accounts of item - ' + I.[strItemNo] + ' were not specified.' END
	FROM 
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct
			ON I.[intCompanyLocationId] = Acct.[intLocationId]
			AND I.[intItemId] = Acct.[intItemId]
	LEFT OUTER JOIN tblGLAccount GLA
			ON Acct.[intGeneralAccountId] = GLA.[intAccountId]	 			
	WHERE
		I.[strItemType] = 'Software'	
		AND I.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
		AND (ISNULL(Acct.[intGeneralAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Other Charge Income Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Other Charge Income account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Other Charge Income Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM 
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct
			ON I.[intCompanyLocationId] = Acct.[intLocationId] 
			AND I.[intItemId] = Acct.[intItemId] 		 	
	LEFT OUTER JOIN tblGLAccount GLA
			ON Acct.intOtherChargeIncomeAccountId = GLA.[intAccountId]
	WHERE
		I.[strItemType] = 'Other Charge'
		AND (ISNULL(Acct.[intOtherChargeIncomeAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Sales Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= I.[strItemNo] + ' at ' + SMCL.strLocationName + ' is missing a GL account setup for Sales account category.'
	FROM 
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount Acct
			ON I.[intCompanyLocationId] = Acct.[intLocationId] 
			AND I.[intItemId] = Acct.[intItemId] 	
	LEFT OUTER JOIN tblGLAccount GLA
			ON Acct.[intSalesAccountId] = GLA.[intAccountId]	
	LEFT OUTER JOIN tblSMCompanyLocation SMCL
			ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId] 
	WHERE
		I.[dblTotal] <> @ZeroDecimal 
		AND I.[intItemId] IS NOT NULL
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
		AND (I.[strTransactionType] <> 'Debit Memo' OR (I.[strTransactionType] = 'Debit Memo' AND ISNULL(I.[strType],'') IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
		AND I.[intPeriodsToAccrue] <= 1
		AND (ISNULL(Acct.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)			


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Sales Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Account of line item - ' + I.[strItemDescription] + ' is not valid.' ELSE 'The Sales Account of line item - ' + I.[strItemDescription] + ' was not specified.' END
	FROM ##ARPostInvoiceDetail I
	LEFT OUTER JOIN tblGLAccount GLA
			ON I.[intSalesAccountId] = GLA.[intAccountId]
	WHERE
		I.[dblTotal] <> @ZeroDecimal 
		AND I.[strTransactionType] = 'Debit Memo'
		AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
		AND I.[intPeriodsToAccrue] <= 1
		AND (ISNULL(I.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)			


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Sales Tax Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' is not valid.' ELSE 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.' END
	FROM tblARInvoiceDetailTax ARIDT
	INNER JOIN ##ARPostInvoiceDetail I
			ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]		
	LEFT OUTER JOIN tblSMTaxCode  SMTC
			ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]
	LEFT OUTER JOIN tblGLAccount GLA
			ON ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) = GLA.[intAccountId]	
	WHERE
		ARIDT.[dblAdjustedTax] <> @ZeroDecimal
		AND (ISNULL(ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]), 0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Sales Tax Exempt Account
	SELECT
		[intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Tax Exemption Account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.'
	FROM tblARInvoiceDetailTax ARIDT
	INNER JOIN ##ARPostInvoiceDetail I
			ON ARIDT.[intInvoiceDetailId] = I.[intInvoiceDetailId]		
	LEFT OUTER JOIN tblSMTaxCode  SMTC
			ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]	
	WHERE
		ARIDT.[dblAdjustedTax] <> @ZeroDecimal
		AND ISNULL(SMTC.[ysnAddToCost], 0) = 1
		AND ISNULL(SMTC.[intSalesTaxExemptionAccountId], 0) = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--COGS Account -- SHIPPED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM 	
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount IST
			ON I.[intItemId] = IST.[intItemId] 
			AND I.[intCompanyLocationId] = IST.[intLocationId] 			
	INNER JOIN tblICInventoryShipmentItem ISD
			ON 	I.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
	INNER JOIN tblICInventoryShipment ISH
			ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	INNER JOIN tblICInventoryTransaction ICT
			ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
			AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
			AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						 
	LEFT OUTER JOIN tblGLAccount GLA
			ON IST.[intCOGSAccountId] = GLA.[intAccountId]
	WHERE
		I.[dblTotal] <> @ZeroDecimal
		AND I.[intItemId] IS NOT NULL
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
		AND I.[strTransactionType] <> 'Debit Memo'
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND (ISNULL(IST.[intCOGSAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)			

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Inventory In-Transit Account Account -- SHIPPED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + I.[strItemNo] + ' was not specified.' END	
	FROM			
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount IST
			ON I.[intItemId] = IST.[intItemId] 
			AND I.[intCompanyLocationId] = IST.[intLocationId] 							
	INNER JOIN tblICInventoryShipmentItem  ISD
			ON 	I.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
	INNER JOIN tblICInventoryShipment ISH
			ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
	INNER JOIN tblICInventoryTransaction ICT
			ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
			AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
			AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						  
	LEFT OUTER JOIN tblGLAccount GLA
			ON IST.[intInventoryInTransitAccountId] = GLA.[intAccountId]				
	WHERE
		I.[dblTotal] <> @ZeroDecimal
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND I.[intItemId] IS NOT NULL
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
		AND I.[strTransactionType] <> 'Debit Memo'	
		AND (ISNULL(IST.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--COGS Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM 	
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount ARIA
			ON I.[intItemId] = ARIA.[intItemId] 
			AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
	LEFT OUTER JOIN tblGLAccount GLA
			ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	
	WHERE
		I.[dblTotal] <> @ZeroDecimal
        AND I.[intInventoryShipmentItemId] IS NULL
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND I.[intItemId] IS NOT NULL
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
		AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	
		AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)			
			
			
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--COGS Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of component - ' + ARIA.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of component - ' + ARIA.[strItemNo] + ' was not specified.' END	
	FROM tblICItemBundle ARIC
	INNER JOIN ##ARPostInvoiceDetail I ON ARIC.[intItemId] = I.[intItemId]			
	INNER JOIN tblICItem ICI ON ARIC.[intBundleItemId] = ICI.[intItemId]
	LEFT OUTER JOIN ##ARInvoiceItemAccount ARIA ON ARIC.[intBundleItemId] = ARIA.[intItemId] AND I.[intCompanyLocationId] = ARIA.[intLocationId] 	
	LEFT OUTER JOIN tblGLAccount GLA ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	 
	WHERE I.[dblTotal] <> @ZeroDecimal
        AND I.[intInventoryShipmentItemId] IS NULL
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND I.[intItemId] IS NOT NULL
		AND I.[strTransactionType] <> 'Debit Memo'			
		AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)			

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Inventory In-Transit Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + I.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + I.[strItemNo] + ' was not specified.' END
	FROM 			
		##ARPostInvoiceDetail I
	LEFT OUTER JOIN ##ARInvoiceItemAccount ARIA
			ON I.[intItemId] = ARIA.[intItemId] 
			AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
	LEFT OUTER JOIN tblGLAccount GLA
			ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId]
	WHERE
		I.[dblTotal] <> @ZeroDecimal
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND I.[intItemId] IS NOT NULL
		AND I.[strItemType] NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
		AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	
		AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)			


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Inventory In-Transit Account
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ARIA.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ARIA.[strItemNo] + ' was not specified.' END	
	FROM tblICItemBundle ARIC
	INNER JOIN ##ARPostInvoiceDetail I ON ARIC.[intItemId] = I.[intItemId]
	INNER JOIN tblICItem ICI ON ARIC.[intBundleItemId] = ICI.[intItemId]
	LEFT OUTER JOIN ##ARInvoiceItemAccount ARIA ON ARIC.[intBundleItemId] = ARIA.[intItemId] AND I.[intCompanyLocationId] = ARIA.[intLocationId]
	LEFT OUTER JOIN tblGLAccount GLA ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId] 		 		 
	WHERE I.[dblTotal] <> @ZeroDecimal
		AND (ISNULL(I.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(I.[intLoadDetailId],0) <> 0)
		AND I.[intItemId] IS NOT NULL
		AND I.[strTransactionType] <> 'Debit Memo'
		AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Zero Contract Item Price
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The contract item - ' + I.[strItemNo] + ' price cannot be zero.'
	FROM ##ARPostInvoiceDetail I
	INNER JOIN
		(SELECT [intContractHeaderId], [intContractDetailId], [strPricingType] FROM vyuCTCustomerContract WITH (NOLOCK)) CTCD
			ON I.[intContractHeaderId] = CTCD.[intContractHeaderId] 
			AND I.[intContractDetailId] = CTCD.[intContractDetailId] 
	WHERE
		I.[strItemType] <> 'Other Charge'
		AND I.strTransactionType <> 'Credit Memo'
		AND I.[dblPrice] = @ZeroDecimal			
		AND CTCD.[strPricingType] <> 'Index'
		AND ISNULL(I.[intLoadDetailId],0) = 0


	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Contract Item Price not Equal to Contract Sequence Cash Price
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The contract item - ' + I.[strItemNo] + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(I.[dblUnitPrice],@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY),2) + ').'
	FROM ##ARPostInvoiceDetail I
	INNER JOIN vyuCTCustomerContract ARCC
			ON I.[intContractHeaderId] = ARCC.[intContractHeaderId] 
			AND I.[intContractDetailId] = ARCC.[intContractDetailId] 			 				
	WHERE
		I.[dblUnitPrice] <> @ZeroDecimal				
		AND I.[strItemType] <> 'Other Charge'
		AND I.strTransactionType NOT IN ('Credit Memo', 'Debit Memo')
		AND CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY) <> CAST(ISNULL(I.[dblUnitPrice], @ZeroDecimal) AS MONEY)
		AND ARCC.[strPricingType] <> 'Index'
		AND ISNULL(I.[intLoadDetailId],0) = 0
		AND ISNULL(I.[intShipmentId],0) = 0
		AND ISNULL(I.[intInventoryShipmentItemId],0) = 0
		AND I.[strPricing] NOT IN ('Contracts-Max Price','Contracts-Pricing Level')
			

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Lot Tracked
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= ARID.[intInvoiceDetailId]
		,[intItemId]			= ARID.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The Qty Ship for ' + ARID.[strItemDescription] + ' is ' + CONVERT(NVARCHAR(50), CAST(ARID.dblQtyShipped AS DECIMAL(16, 2))) + '. Total Lot Qty is ' + CONVERT(NVARCHAR(50), CAST(ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2))) + ' The difference is ' + CONVERT(NVARCHAR(50), ABS(CAST(ARID.dblQtyShipped - ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2)))) + '.' 
	FROM ##ARPostInvoiceHeader I	
	INNER JOIN (
		SELECT [intInvoiceId]
				, [intItemId]
				, [intInvoiceDetailId]
				, [strItemDescription]
				, [dblQtyShipped]
		FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
		WHERE ISNULL(ARID.[intItemId],0) <> 0
			AND [dbo].[fnGetItemLotType](ARID.[intItemId]) <> 0
			AND ISNULL(ARID.[intInventoryShipmentItemId],0) = 0
			AND ISNULL(ARID.[intLoadDetailId],0) = 0
			--AND ISNULL(ARID.[intTicketId],0) = 0
			AND ISNULL(ARID.[ysnBlended],0) = 0
	) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
	LEFT JOIN (
		SELECT [intLoadId]
				, [intPurchaseSale]
		FROM dbo.tblLGLoad WITH (NOLOCK)
	) LG ON I.[intLoadId] = LG.[intLoadId]
	OUTER APPLY (
		SELECT [dblTotalQtyShipped] = SUM(ISNULL(dblQuantityShipped, 0))
		FROM dbo.tblARInvoiceDetailLot ARIDL WITH (NOLOCK)
		WHERE ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId
	) LOT
	WHERE
		ARID.dblQtyShipped <> ISNULL(LOT.[dblTotalQtyShipped], 0)
		AND ISNULL(I.[intLoadDistributionHeaderId],0) = 0
		AND ((ISNULL(I.[intLoadId], 0) IS NOT NULL AND ISNULL(LG.[intPurchaseSale], 0) NOT IN (2, 3)) OR ISNULL(I.[intLoadId], 0) IS NULL)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CASH REFUND AMOUNT IS NOT EQUAL TO PREPAIDS
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Cash Refund amount is not equal to prepaids/credits applied.'
	FROM 					
		##ARPostInvoiceHeader I
	OUTER APPLY (
		SELECT dblAppliedInvoiceAmount	= SUM(ISNULL(dblAppliedInvoiceDetailAmount, 0))
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE intInvoiceId = I.intInvoiceId 
			AND ysnApplied = @OneBit
			AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0			
	) PREPAIDS
	WHERE
		I.strTransactionType = 'Cash Refund'
		AND I.dblInvoiceTotal <> ISNULL(PREPAIDS.dblAppliedInvoiceAmount, 0)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--FISCAL PERIOD CLOSED INVENTORY
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Unable to find an open fiscal year period for Inventory module to match the transaction date.'
	FROM ##ARPostInvoiceHeader I
	WHERE dbo.isOpenAccountingDateByModule(ISNULL(dtmPostDate, dtmDate), 'Inventory') = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CREDITS APPLIED IS OVER AMOUNT DUE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Applied credits for ' + I.[strInvoiceNumber] + ' is more than the amount due.'
	FROM ##ARPostInvoiceHeader I
	INNER JOIN (
		SELECT intInvoiceId			= APC.intInvoiceId
			 , dblCreditsApplied	= SUM(APC.dblAppliedInvoiceDetailAmount)
		FROM tblARPrepaidAndCredit APC
		WHERE APC.ysnApplied = 1
		  AND ISNULL(APC.dblAppliedInvoiceDetailAmount, 0) <> 0
		GROUP BY intInvoiceId
	) CREDITS ON CREDITS.intInvoiceId = I.intInvoiceId
	WHERE CREDITS.dblCreditsApplied > I.dblAmountDue

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
	FROM ##ARPostInvoiceDetail PID 
	INNER JOIN (SELECT [intSiteID] FROM tblTMSite WITH (NOLOCK)) TMS ON PID.[intSiteId] = TMS.[intSiteID]

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnTMGetInvalidInvoicesForSync]'
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
	FROM ##ARPostInvoiceDetail PID 
	WHERE PID.[ysnBlended] <> @OneBit AND PID.[ysnAutoBlend] = @OneBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnMFGetInvalidInvoicesForPosting]'
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
		,ISNULL(dbo.fnGetMatchingItemUOMId([intItemId], ICIUOM.intUnitMeasureId), COSTING.intItemUOMId)
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
	FROM ##ARItemsForCosting COSTING
	LEFT OUTER JOIN 
	(SELECT intUnitMeasureId,intItemUOMId FROM tblICItemUOM ICUOM  WITH (NOLOCK)
		) ICIUOM
		ON COSTING.intItemUOMId = ICIUOM.intItemUOMId
	WHERE ISNULL([ysnAutoBlend], 0) = 0

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnICGetInvalidInvoicesForCosting]'
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
	FROM ##ARItemsForCosting COSTING
	LEFT OUTER JOIN 
	(SELECT intUnitMeasureId,intItemUOMId FROM tblICItemUOM ICUOM  WITH (NOLOCK)
		) ICIUOM
		ON COSTING.intItemUOMId = ICIUOM.intItemUOMId
	WHERE ISNULL([ysnAutoBlend], 0) = 0
	AND COSTING.intTransactionId NOT IN (SELECT intInvoiceId FROM ##ARInvalidInvoiceData)

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError]
	FROM 
		[dbo].[fnICGetInvalidInvoicesForCosting](@ItemsForCostingZeroCostValidation, @OneBit)

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
	FROM
		##ARItemsForInTransitCosting

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnICGetInvalidInvoicesForInTransitCosting]'
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
	FROM
		##ARItemsForStorageCosting

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnICGetInvalidInvoicesForItemStoragePosting]'
	FROM 
		[dbo].[fnICGetInvalidInvoicesForItemStoragePosting](@ItemsForStoragePosting, @OneBit)

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
		, strAccountCategory	= 'Inventory In-Transit'
	FROM @ItemsForInTransitCosting IC
	WHERE dbo.fnGetItemGLAccount(IC.intItemId, IC.intItemLocationId, 'Inventory In-Transit') IS NULL	
	
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	SELECT
		 [intInvoiceId]			= IC.intInvoiceId
		,[strInvoiceNumber]		= IC.strInvoiceNumber
		,[strTransactionType]	= 'Invoice'
		,[intInvoiceDetailId]	= IC.intInvoiceDetailId
		,[intItemId]			= IC.intItemId
		,[strBatchId]			= @BatchId
		,[strPostingError]		= ITEM.strItemNo + ' in ' + CL.strLocationName + ' is missing a GL account setup for ' + IC.strAccountCategory + ' account category.'
	FROM @InvalidItemsForPosting IC
	INNER JOIN tblICItem ITEM ON IC.intItemId = ITEM.intItemId
	INNER JOIN tblICItemLocation IL ON IC.intItemLocationId = IL.intItemLocationId
	INNER JOIN tblSMCompanyLocation CL ON IL.intLocationId = CL.intCompanyLocationId
END

IF @Post = @ZeroBit
BEGIN
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	--NOT YET POSTED
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'The transaction has not been posted yet.'
	FROM 
		##ARPostInvoiceHeader I
	WHERE  
		I.[ysnPosted] = @ZeroBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	select
		 [intInvoiceId]			= c.[intInvoiceId]
		,[strInvoiceNumber]		= c.[strInvoiceNumber]		
		,[strTransactionType]	= c.[strTransactionType]
		,[intInvoiceDetailId]	= c.[intInvoiceDetailId]
		,[intItemId]			= c.[intItemId]
		,[strBatchId]			= c.[strBatchId]
		,[strPostingError]		= 'You cannot unpost an Invoice with Service Charge Invoice created-' + b.strInvoiceNumber +  '.'

		from (select intInvoiceDetailId, intItemId, 
					intSCInvoiceId, intInvoiceId from 
						tblARInvoiceDetail) a
			join (select intInvoiceId, strInvoiceNumber,
					strTransactionType from tblARInvoice with (nolock)
				) b on a.intInvoiceId = b.intInvoiceId
			join ##ARPostInvoiceHeader c
				on a.intSCInvoiceId = c.intInvoiceId
			
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	SELECT 
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost an Invoice with ' + ISNULL(I2.strTransactionType,'') + ' created- ' + ISNULL(I2.strInvoiceNumber ,'')
	FROM
		##ARPostInvoiceHeader I
	--INNER JOIN tblARInvoiceDetail D
	--	ON D.intInvoiceId = I.intInvoiceId
	INNER JOIN tblARInvoiceDetail D2
		ON D2.intOriginalInvoiceDetailId = I.[intInvoiceDetailId]
	INNER JOIN tblARInvoice I2
		ON I2.intInvoiceId = D2.intInvoiceId

	IF(ISNULL(@strDatabaseName, '') <> '')
	BEGIN
		DECLARE @ysnVoucherExistQuery nvarchar(MAX)
		DECLARE @ysnVoucherExistParam NVARCHAR(500)
		DECLARE @strBillId NVARCHAR(500) = ''
		DECLARE @strInterCompanyReceiptNumber NVARCHAR(50)

		SELECT @strInterCompanyReceiptNumber = [strReceiptNumber] FROM #ARPostInvoiceHeader
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
				,[strPostingError])
			--Inventory receipt has voucher already in inter-company database
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= 'Unable to unpost. The inventory receipt (' + @strInterCompanyReceiptNumber + ') has a voucher (' + @strBillId + ') in company ' + ISNULL(@strCompanyName, '') + '.'
			FROM 
				#ARPostInvoiceHeader I
			WHERE I.ysnInterCompany = 1
		END
	END

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--If ysnAllowUserSelfPost is True in User Role
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		=  'You cannot Unpost transactions you did not create.'
	FROM 					
		##ARPostInvoiceHeader I
	WHERE  
		I.[intEntityId] <> I.[intUserId]
		AND (I.[ysnUserAllowedToPostOtherTrans] IS NOT NULL AND I.[ysnUserAllowedToPostOtherTrans] = @OneBit)			

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
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
	FROM tblARPayment ARP
	INNER JOIN tblARPaymentDetail ARPD 
			ON ARP.[intPaymentId] = ARPD.[intPaymentId]						
	INNER JOIN 
		##ARPostInvoiceHeader I
			ON ARPD.[intInvoiceId] = I.[intInvoiceId]
	WHERE
		@Recap = @ZeroBit
		AND I.strTransactionType <> 'Cash Refund'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Payments from Pay Voucher
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= APP.[strPaymentRecordNum] + ' payment was already made on this ' + I.strTransactionType + '.' + CASE WHEN I.strTransactionType = 'Credit Memo' THEN ' Please remove payment record and try again.' ELSE '' END
	FROM tblAPPayment APP
	INNER JOIN tblAPPaymentDetail APPD 
			ON APP.[intPaymentId] = APPD.[intPaymentId]						
	INNER JOIN 
		##ARPostInvoiceHeader I
			ON APPD.[intInvoiceId] = I.[intInvoiceId]
	WHERE
		@Recap = @ZeroBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--Invoice with created Bank Deposit
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost invoice with created Bank Deposit.'
	FROM 
		##ARPostInvoiceHeader I
	INNER JOIN tblCMUndepositedFund CMUF 
			ON I.[intInvoiceId] = CMUF.[intSourceTransactionId] 
			AND I.[strInvoiceNumber] = CMUF.[strSourceTransactionId]
	INNER JOIN tblCMBankTransactionDetail CMBTD
			ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
	WHERE 
		@Recap = @ZeroBit
		AND CMUF.[strSourceSystem] = 'AR'

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--INVOICE CREATED FROM PATRONAGE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'This Invoice was created from Patronage > Issue Stock - ' + ISNULL(PAT.strIssueNo, '') + '. Unpost it from there.'
	FROM 
		##ARPostInvoiceHeader I
	CROSS APPLY (
		SELECT TOP 1 P.strIssueNo
		FROM dbo.tblPATIssueStock P WITH (NOLOCK)
		WHERE P.intInvoiceId = I.intInvoiceId
			AND P.ysnPosted = @OneBit
	) PAT
	WHERE
		@Recap = @ZeroBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CASH REFUND ALREADY APPLIED IN PAY VOUCHER
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'This ' + I.[strTransactionType] + ' was already applied in ' + ISNULL(VOUCHER.strPaymentRecordNum, '') + '.'
	FROM 
		##ARPostInvoiceHeader I
	CROSS APPLY (
		SELECT TOP 1 P.strPaymentRecordNum
		FROM dbo.tblAPPayment P WITH (NOLOCK)
		INNER JOIN tblAPPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
		WHERE PD.intInvoiceId = I.intInvoiceId
	) VOUCHER
	WHERE
		@Recap = @ZeroBit
	
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CREDIT MEMO FROM FORGIVEN SERVICE CHARGE
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost this Credit Memo (' + INV.strInvoiceNumber + '). Please unforgive the Service Charge.'
	FROM ##ARPostInvoiceHeader I
	INNER JOIN tblARInvoice INV ON INV.intInvoiceId = I.intInvoiceId	
	WHERE @Recap = @ZeroBit
	  AND ISNULL(INV.ysnServiceChargeCredit, 0) = @OneBit
	  AND INV.strTransactionType = 'Credit Memo'

	
	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	--CREDIT MEMO WITH CASH REFUND
	SELECT
		 [intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
		,[intItemId]			= I.[intItemId]
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'You cannot unpost this Credit Memo (' + I.strInvoiceNumber + '). Cash Refund(' + INV.strInvoiceNumber + ') created.'
	FROM ##ARPostInvoiceHeader I
	LEFT OUTER JOIN tblARInvoice INV 
         ON I.intInvoiceId = INV.intOriginalInvoiceId
	WHERE @Recap = @ZeroBit
	  AND ISNULL(I.[ysnRefundProcessed], 0) = @OneBit
	  AND I.strTransactionType = 'Credit Memo'

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
	FROM ##ARPostInvoiceDetail PID 
	INNER JOIN (SELECT [intSiteID] FROM tblTMSite WITH (NOLOCK)) TMS ON PID.[intSiteId] = TMS.[intSiteID]

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])

	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnTMGetInvalidInvoicesForSync]'
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
	FROM ##ARPostInvoiceDetail PID 
	WHERE PID.[ysnBlended] <> @ZeroBit AND PID.[ysnAutoBlend] = @OneBit

	INSERT INTO ##ARInvalidInvoiceData
		([intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError])
	SELECT
		 [intInvoiceId]
		,[strInvoiceNumber]
		,[strTransactionType]
		,[intInvoiceDetailId]
		,[intItemId]
		,[strBatchId]
		,[strPostingError] -- + '[fnMFGetInvalidInvoicesForPosting]'
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
			INSERT INTO ##ARInvalidInvoiceData
		        ([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError])

			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]	
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= I.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
			FROM 
				##ARPostInvoiceHeader I
			INNER JOIN
				(SELECT [agivc_ivc_no] FROM agivcmst WITH (NOLOCK)) OI
					ON I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[agivc_ivc_no] COLLATE Latin1_General_CI_AS
			WHERE  
				I.[ysnPosted] = @OneBit
				AND I.[ysnImportedAsPosted] = @OneBit 
				AND I.[ysnImportedFromOrigin] = @OneBit														
		END

	IF @IsPT = @OneBit
		BEGIN
			INSERT INTO ##ARInvalidInvoiceData
		        ([intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[intInvoiceDetailId]
				,[intItemId]
				,[strBatchId]
				,[strPostingError])

			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
				,[intItemId]			= I.[intItemId]
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= I.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
			FROM 
				##ARPostInvoiceHeader I
			INNER JOIN
				(SELECT [ptivc_invc_no] FROM ptivcmst WITH (NOLOCK)) OI
					ON I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[ptivc_invc_no] COLLATE Latin1_General_CI_AS
			WHERE
				I.[ysnPosted] = @OneBit
				AND I.[ysnImportedAsPosted] = @OneBit 
				AND I.[ysnImportedFromOrigin] = @OneBit												
		END

	INSERT INTO ##ARInvoiceGLEntries
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
        ,[intSourceEntityId])
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
    FROM ##ARPostInvoiceHeader PID
    INNER JOIN tblGLDetail GLD ON PID.[intInvoiceId] = GLD.[intTransactionId]
                              AND PID.[strInvoiceNumber] = GLD.[strTransactionId]							 
    WHERE GLD.[ysnIsUnposted] = 0
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
FROM ##ARItemsForContracts
WHERE strType = 'Contract Balance'
  AND ysnFromReturn = 0

INSERT INTO ##ARInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
)
SELECT [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
FROM dbo.fnCTValidateInvoiceContract(@ItemsForContracts)

--VALIDATE INVOICE GL ENTRIES
INSERT INTO ##ARInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Debit and credit amounts are not balanced.'
FROM ##ARInvoiceGLEntries GL
INNER JOIN ##ARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId
HAVING SUM(GL.dblDebit) - SUM(GL.dblCredit) <> 0

INSERT INTO ##ARInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Foreign Debit and credit amounts are not balanced.'
FROM ##ARInvoiceGLEntries GL
INNER JOIN ##ARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId
HAVING SUM(GL.dblDebitForeign) - SUM(GL.dblCreditForeign) <> 0

INSERT INTO ##ARInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= I.[strBatchId]
	, [strPostingError]		= 'Unable to find an open fiscal year period for Accounts Receivable module to match the transaction date.'
FROM ##ARInvoiceGLEntries GL
INNER JOIN ##ARPostInvoiceHeader I ON GL.strTransactionId = I.strInvoiceNumber AND GL.intTransactionId = I.intInvoiceId
INNER JOIN tblGLFiscalYearPeriod FYP ON GL.dtmDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
WHERE FYP.ysnAROpen = 0
GROUP BY I.intInvoiceId, I.strInvoiceNumber, I.strTransactionType, I.strBatchId

INSERT INTO ##ARInvalidInvoiceData (
	  [intInvoiceId]
	, [strInvoiceNumber]
	, [strTransactionType]
	, [intInvoiceDetailId]
	, [intItemId]
	, [strBatchId]
	, [strPostingError]
)
SELECT DISTINCT
	  [intInvoiceId]		= I.[intInvoiceId]
	, [strInvoiceNumber]	= I.[strInvoiceNumber]
	, [strTransactionType]	= I.[strTransactionType] 
	, [intInvoiceDetailId]	= NULL
	, [intItemId]			= NULL
	, [strBatchId]			= II.[strBatchId]
	, [strPostingError]		= I.strInvoiceNumber + ' has discrepancy on ' + GL.strAccountCategory + ' of ' + LTRIM(STR(ISNULL(I.dblBaseInvoiceTotal, 0), 16, 2))
FROM tblARInvoice I
INNER JOIN ##ARPostInvoiceHeader II ON I.intInvoiceId = II.intInvoiceId AND I.strInvoiceNumber = II.strInvoiceNumber
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
	INNER JOIN ##ARPostInvoiceHeader IH ON IH.intInvoiceId = GL.intTransactionId AND IH.strInvoiceNumber = GL.strTransactionId	
	WHERE GLAC.strAccountCategory IN ('AR Account', 'Undeposited Funds')
	  AND GL.ysnIsUnposted = 0
	  AND GL.strCode = 'AR'
	  AND IH.ysnPost = 1
	GROUP BY GL.intTransactionId, GL.strTransactionId, GLAC.strAccountCategory
	HAVING SUM(dblDebit - dblCredit) <> 0 
) GL ON I.intInvoiceId = GL.intTransactionId
    AND I.strInvoiceNumber = GL.strTransactionId
	AND ((I.strTransactionType <> 'Cash' AND GL.strAccountCategory = 'AR Account') OR (I.strTransactionType = 'Cash' AND GL.strAccountCategory = 'Undeposited Funds'))	
WHERE II.ysnPost = 1

UPDATE ##ARInvalidInvoiceData
SET [strBatchId] = @BatchId
WHERE 
	LTRIM(RTRIM(ISNULL([strBatchId],''))) = ''

RETURN 1