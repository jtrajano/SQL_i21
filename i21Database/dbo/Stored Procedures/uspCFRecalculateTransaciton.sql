CREATE PROCEDURE [dbo].[uspCFRecalculateTransaciton] 

 @ProductId				INT    
,@CardId				INT				
,@SiteId				INT    
,@TransactionDate		DATETIME			    
,@Quantity				NUMERIC(18,6)     
,@OriginalPrice			NUMERIC(18,6)    
,@TransactionType		NVARCHAR(MAX)
,@NetworkId				INT
,@TransferCost			NUMERIC(18,6)   
,@TransactionId			INT				=   NULL
,@PumpId				INT				=	NULL
,@CreditCardUsed		BIT				=	0
,@PostedOrigin			BIT				=	0
,@PostedCSV				BIT				=	0
,@IsImporting			BIT				=	0
-------------REMOTE TAXES-------------
--  1. REMOTE TRANSACTION			--
--  2. EXT. REMOTE TRANSACTION 		--
--------------------------------------
,@TaxState							NVARCHAR(MAX)	= ''
,@FederalExciseTaxRate        		NUMERIC(18,6)	= 0.000000
,@StateExciseTaxRate1         		NUMERIC(18,6)	= 0.000000
,@StateExciseTaxRate2         		NUMERIC(18,6)	= 0.000000
,@CountyExciseTaxRate         		NUMERIC(18,6)	= 0.000000
,@CityExciseTaxRate           		NUMERIC(18,6)	= 0.000000
,@StateSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000
,@CountySalesTaxPercentageRate		NUMERIC(18,6)	= 0.000000
,@CitySalesTaxPercentageRate  		NUMERIC(18,6)	= 0.000000
,@OtherSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000

AS

BEGIN
	
	------------ GET ITEM PRICE PARAMETERS  ------------
	DECLARE @intItemId						INT
	DECLARE @intCustomerId					INT
	DECLARE @intLocationId					INT		
	DECLARE @intItemUOMId					INT			
	DECLARE @dtmTransactionDate				DATETIME		
	DECLARE @dblQuantity					NUMERIC(18,6)
	DECLARE @strTransactionType				NVARCHAR(MAX)
	DECLARE @intNetworkId					INT
	DECLARE @intSiteId						INT
	DECLARE @dblTransferCost				NUMERIC(18,6)
	DECLARE @dblOriginalPrice				NUMERIC(18,6)
	DECLARE @intCardId						INT
	DECLARE @intTaxGroupId					INT

	DECLARE @dblPrice						NUMERIC(18,6)
	DECLARE @strPriceBasis					NVARCHAR(MAX)
	DECLARE @strPriceMethod					NVARCHAR(MAX)
	DECLARE @intContractHeaderId			INT	
	DECLARE @intContractDetailId			INT
	DECLARE @intContractNumber				INT
	DECLARE @intContractSeq					INT
	DECLARE @dblAvailableQuantity			NUMERIC(18,6)

	DECLARE @intTransactionId				INT
	DECLARE @ysnCreditCardUsed				BIT
	DECLARE @ysnPostedOrigin				BIT
	DECLARE @ysnPostedCSV					BIT
	DECLARE @guid							NVARCHAR(MAX)
	DECLARE	@runDate						DATETIME

	DECLARE @intPriceProfileId				INT
	DECLARE @intPriceIndexId 				INT
	DECLARE @intSiteGroupId 				INT

	DECLARE @strPriceProfileId				NVARCHAR(MAX)
	DECLARE @strPriceIndexId				NVARCHAR(MAX)
	DECLARE @strSiteGroup					NVARCHAR(MAX)
	DECLARE @dblPriceProfileRate			NUMERIC(18,6)
	DECLARE @dblPriceIndexRate				NUMERIC(18,6)
	DECLARE	@dtmPriceIndexDate				DATETIME					



	-- IF RECALCULATE FROM IMPORTING--
	-- SAVE RESULT ON GLOBAL TEMP TABLE
	IF(@IsImporting = 1)
	BEGIN

		IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionPricingType') = 1)
	BEGIN
		DROP TABLE ##tblCFTransactionPricingType
	END
		CREATE TABLE ##tblCFTransactionPricingType (
		 intItemId						INT
		,intCustomerId					INT
		,intLocationId					INT
		,dblQuantity					NUMERIC(18,6)
		,intItemUOMId					INT
		,dtmTransactionDate				DATETIME
		,strTransactionType				NVARCHAR(MAX)
		,intNetworkId					INT
		,intSiteId						INT
		,dblTransferCost				NUMERIC(18,6)
		,dblOriginalPrice				NUMERIC(18,6)
		,dblPrice						NUMERIC(18,6)
		,strPriceMethod					NVARCHAR(MAX)
		,dblAvailableQuantity			NUMERIC(18,6)
		,intContractHeaderId			INT
		,intContractDetailId			INT
		,intContractNumber				INT
		,intContractSeq					INT
		,strPriceBasis					NVARCHAR(MAX)
		,intPriceProfileId				INT
		,intPriceIndexId 				INT
		,intSiteGroupId 				INT
		,strPriceProfileId				NVARCHAR(MAX)
		,strPriceIndexId				NVARCHAR(MAX)
		,strSiteGroup					NVARCHAR(MAX)
		,dblPriceProfileRate			NUMERIC(18,6)
		,dblPriceIndexRate				NUMERIC(18,6)
		,dtmPriceIndexDate				DATETIME
		,dblMargin						NUMERIC(18,6)
		,ysnDuplicate					BIT
	);

		IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionTaxType') = 1)
	BEGIN
		DROP TABLE ##tblCFTransactionTaxType
	END
		CREATE TABLE ##tblCFTransactionTaxType (
		 [dblTaxCalculatedAmount]		NUMERIC(18,6)
		,[dblTaxOriginalAmount]			NUMERIC(18,6)
		,[intTaxCodeId]					INT
		,[dblTaxRate]					NUMERIC(18,6)
		,[strTaxCode]					NVARCHAR(MAX)
	)

		IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionPriceType') = 1)
	BEGIN
		DROP TABLE ##tblCFTransactionPriceType
	END
		CREATE TABLE ##tblCFTransactionPriceType (
		 [strTransactionPriceId]		NVARCHAR(MAX)
		,[dblTaxOriginalAmount]			NUMERIC(18,6)
		,[dblTaxCalculatedAmount]		NUMERIC(18,6)
	)

	END

	SET @guid		= NEWID()
	SET	@runDate	= GETDATE()

	 
	SET @ysnPostedOrigin	= @PostedOrigin
	SET @ysnPostedCSV		= @PostedCSV	
	SET @ysnCreditCardUsed = @CreditCardUsed
	SET @intCardId = @CardId
	SET @dblQuantity = @Quantity
	SET @dtmTransactionDate = @TransactionDate
	SET @strTransactionType = @TransactionType
	SET @intNetworkId = @NetworkId
	SET @intSiteId = @SiteId
	SET @dblTransferCost =@TransferCost
	SET @dblOriginalPrice = @OriginalPrice
	SET @intTransactionId = @TransactionId

	IF (@intTransactionId > 0 AND @IsImporting = 0)
	BEGIN
		DELETE tblCFTransactionNote WHERE intTransactionId = @intTransactionId
	END
	ELSE IF(@intTransactionId = 0)
	BEGIN
		SET @intTransactionId = NULL
	END
		

	--GET TAX GROUP ID--
	SELECT TOP 1 
	@intTaxGroupId = intTaxGroupId
	FROM tblCFSite WHERE intSiteId = @intSiteId


	--GET CUSTOMER ID--
	IF (@TransactionType = 'Foreign Sale')
	BEGIN
		SELECT TOP 1
		@intCustomerId = intCustomerId
		FROM tblCFNetwork 
		WHERE intNetworkId = @intNetworkId
	END
	ELSE
	BEGIN
		SELECT TOP 1
		@intCustomerId = cfAccount.intCustomerId
		FROM tblCFCard as cfCard
		INNER JOIN tblCFAccount as cfAccount
		ON cfCard.intAccountId = cfAccount.intAccountId
		WHERE cfCard.intCardId = @intCardId
	END
	
	


	--GET COMPANY LOCATION ID--
	SELECT TOP 1
		@intLocationId = intARLocationId
	FROM tblCFSite as cfSite
	WHERE cfSite.intSiteId = @intSiteId

	--GET IC ITEM ID BY SITE--
	SELECT TOP 1
		@intItemId = cfItem.intARItemId
	FROM tblCFItem as cfItem 
	WHERE cfItem.intSiteId = @intSiteId
	AND cfItem.intItemId = @ProductId
	
	--GET IC ITEM ID BY NETWORK--
	IF (@intItemId IS NULL)
	BEGIN
		SELECT TOP 1
			@intItemId = cfItem.intARItemId
		FROM tblCFItem as cfItem 
		WHERE cfItem.intNetworkId = @intNetworkId
		AND cfItem.intItemId = @ProductId
	END

	--GET IC ITEM UOM ID--
	SELECT TOP 1
		@intItemUOMId = icItemLocation.intIssueUOMId
	FROM tblICItemLocation as icItemLocation
	WHERE icItemLocation.intItemId = @intItemId
	AND icItemLocation.intLocationId = @intLocationId

	

	--GET ITEM PRICE--
	--if @ysnCreditCardUsed is true then pricing should always from import file
	EXEC dbo.uspCFGetItemPrice 
	@CFItemId					=	@intItemId,
	@CFCustomerId				=	@intCustomerId,
	@CFLocationId				=	@intLocationId,
	@CFQuantity					=	@dblQuantity,
	@CFItemUOMId				=	@intItemUOMId,
	@CFTransactionDate			=	@dtmTransactionDate,
	@CFTransactionType			=	@strTransactionType,
	@CFNetworkId				=	@intNetworkId,
	@CFSiteId					=	@intSiteId,
	@CFTransferCost				=	@dblTransferCost,
	@CFOriginalPrice			=	@dblOriginalPrice,
	@CFPriceOut					=	@dblPrice				output,
	@CFPricingOut				=	@strPriceMethod			output,
	@CFAvailableQuantity		=	@dblAvailableQuantity	output,
	@CFContractHeaderId			=	@intContractHeaderId	output,
	@CFContractDetailId			=	@intContractDetailId	output,
	@CFContractNumber			=	@intContractNumber		output,
	@CFContractSeq				=	@intContractSeq			output,
	@CFPriceBasis				=	@strPriceBasis			output,
	@CFCreditCard				=	@ysnCreditCardUsed,      
	@CFPostedOrigin				=	@ysnPostedOrigin,      
	@CFPostedCSV				=	@ysnPostedCSV,      
	@CFPriceProfileId			=	@intPriceProfileId		output,
	@CFPriceIndexId				=	@intPriceIndexId 		output,
	@CFSiteGroupId				= 	@intSiteGroupId 		output

	SELECT TOP 1 
	@strPriceProfileId = cfPriceProfile.strPriceProfile
	,@dblPriceProfileRate = cfPriceProfileDetail.dblRate
	FROM tblCFPriceProfileHeader AS cfPriceProfile
	INNER JOIN tblCFPriceProfileDetail AS cfPriceProfileDetail 
	ON cfPriceProfile.intPriceProfileHeaderId = cfPriceProfileDetail.intPriceProfileHeaderId
	WHERE cfPriceProfile.intPriceProfileHeaderId = @intPriceProfileId

	SELECT TOP 1
	@strPriceIndexId = strPriceIndex
	FROM
	tblCFPriceIndex
	WHERE intPriceIndexId = @intPriceIndexId

	SELECT TOP 1
	@dblPriceIndexRate = cfIndexPricingDetail.dblIndexPrice
	,@dtmPriceIndexDate = cfIndexPricingHeader.dtmDate
	FROM tblCFIndexPricingBySiteGroupHeader AS cfIndexPricingHeader
	INNER JOIN tblCFIndexPricingBySiteGroup AS cfIndexPricingDetail
	ON cfIndexPricingHeader.intIndexPricingBySiteGroupHeaderId = cfIndexPricingDetail.intIndexPricingBySiteGroupHeaderId
	WHERE cfIndexPricingHeader.intPriceIndexId = @intPriceIndexId 
	AND cfIndexPricingHeader.intSiteGroupId = @intSiteGroupId
	AND cfIndexPricingDetail.intARItemID = @intItemId

	SELECT TOP 1
	@strSiteGroup = strSiteGroup
	FROM tblCFSiteGroup
	WHERE intSiteGroupId = @intSiteGroupId


	-- TAX TABLE --
	DECLARE @tblTransactionTaxOut	TABLE
	(
		 [intTransactionDetailTaxId]		INT
		,[intInvoiceDetailId]				INT
		,[intTransactionDetailId]  			INT
		,[intTaxGroupMasterId]				INT
		,[intTaxGroupId]					INT
		,[intTaxCodeId]						INT
		,[intTaxClassId]					INT
		,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
		,[strCalculationMethod]				NVARCHAR(MAX)
		,[dblRate]							NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
		,[dblCalculatedTax]					NUMERIC(18,6)
		,[dblOriginalTax]					NUMERIC(18,6)
	)
	DECLARE @tblTransactionTax		TABLE
	(
		 [intTransactionDetailTaxId]		INT
		,[intInvoiceDetailId]				INT
		,[intTransactionDetailId]  			INT
		,[intTaxGroupMasterId]				INT
		,[intTaxGroupId]					INT
		,[intTaxCodeId]						INT
		,[intTaxClassId]					INT
		,[strTaxableByOtherTaxes]			NVARCHAR(MAX)
		,[strCalculationMethod]				NVARCHAR(MAX)
		,[dblRate]							NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
	)
	DECLARE @tblTaxRateTable		TABLE
	(
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strReason]					NVARCHAR(MAX)
		,[strNotes]						NVARCHAR(MAX)
		,[strTaxExemptReason]			NVARCHAR(MAX)
	)
	DECLARE @tblTaxUnitTable		TABLE
	(
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[ysnInvalidSetup]				BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[strReason]					NVARCHAR(MAX)
		,[strNotes]						NVARCHAR(MAX)
		,[strTaxExemptReason]			NVARCHAR(MAX)
	)

	DECLARE @strTaxCodes			VARCHAR(MAX) 
	DECLARE @dblOPTotalTax		NUMERIC(18,6) = 0
	DECLARE @dblCPTotalTax		NUMERIC(18,6) = 0
	DECLARE @intLoopTaxGroupID	INT
	DECLARE @intLoopTaxCodeID	INT
	DECLARE @intLoopTaxClassID	INT
	DECLARE	@strLoopTaxCode		NVARCHAR(MAX)
	DECLARE @QxOP				NUMERIC(18,6) = 0
	DECLARE @QxCP				NUMERIC(18,6) = 0
	DECLARE @QxT				NUMERIC(18,6) = 0
	DECLARE @OPTax				NUMERIC(18,6) = 0		
	DECLARE @CPTax				NUMERIC(18,6) = 0	
	DECLARE @Rate				NUMERIC(18,6)
	DECLARE @CalculationMethod  NVARCHAR(MAX)
	DECLARE @ysnLoopTaxExempt	BIT
	DECLARE @ysnLoopTaxCheckOff	BIT

	DECLARE @strTaxExemptReason		NVARCHAR(MAX)
	DECLARE @strNote				NVARCHAR(MAX)
	DECLARE @strReason				NVARCHAR(MAX)
	DECLARE @ysnCheckoffTax			BIT
	DECLARE @ysnTaxExempt			NVARCHAR(MAX)
	DECLARE @ysnInvalidSetup		NVARCHAR(MAX)
	DECLARE @strTaxCode				NVARCHAR(MAX)

	IF((@ysnPostedCSV IS NULL OR @ysnPostedCSV = 0 ) AND (@ysnPostedOrigin = 0 OR @ysnPostedCSV IS NULL))
	BEGIN

	IF (LOWER(@strTransactionType) like '%remote%')
	BEGIN

		IF (@intTransactionId is not null)
		BEGIN
			SELECT @strTaxCodes = COALESCE(@strTaxCodes + ', ', '') + CONVERT(varchar(10), intTaxCodeId)
			FROM tblCFTransactionTax
			WHERE intTransactionId = @intTransactionId

			IF(@IsImporting = 0)
			BEGIN
				--GET TAX STATE FROM SITE
				SET @TaxState = (SELECT TOP 1 strTaxState from tblCFSite where intSiteId = @intSiteId)
			END
		END	

		INSERT INTO @tblTransactionTax(
		 [intTransactionDetailTaxId]	
		,[intTransactionDetailId]  		
		,[intTaxGroupMasterId]			
		,[intTaxGroupId]				
		,[intTaxCodeId]					
		,[intTaxClassId]				
		,[strTaxableByOtherTaxes]		
		,[strCalculationMethod]			
		,[dblRate]						
		,[dblTax]						
		,[dblAdjustedTax]				
		,[intTaxAccountId]    			
		,[ysnSeparateOnInvoice]			
		,[ysnCheckoffTax]				
		,[strTaxCode]					
		,[ysnTaxExempt]			
		,[strTaxGroup]					
		,[ysnInvalidSetup]					
		,[strReason]					
		,[strTaxExemptReason]			
		)	
		EXEC dbo.[uspCFGetItemTaxes] 
		@intNetworkId					=@intNetworkId
		,@intARItemId					=@intItemId
		,@intARItemLocationId			=@intLocationId
		,@intCustomerLocationId			=@intLocationId
		,@dtmTransactionDate			=@dtmTransactionDate
		,@intCustomerId					=@intCustomerId
		,@strTaxCodeId					=@strTaxCodes
		,@TaxState						=@TaxState
		,@FederalExciseTaxRate        	=@FederalExciseTaxRate        	
		,@StateExciseTaxRate1         	=@StateExciseTaxRate1         	
		,@StateExciseTaxRate2         	=@StateExciseTaxRate2         	
		,@CountyExciseTaxRate         	=@CountyExciseTaxRate         	
		,@CityExciseTaxRate           	=@CityExciseTaxRate           	
		,@StateSalesTaxPercentageRate 	=@StateSalesTaxPercentageRate 	
		,@CountySalesTaxPercentageRate	=@CountySalesTaxPercentageRate		
		,@CitySalesTaxPercentageRate  	=@CitySalesTaxPercentageRate  		
		,@OtherSalesTaxPercentageRate 	=@OtherSalesTaxPercentageRate 		

		IF(@IsImporting = 0)
		BEGIN
			SELECT * 
			INTO #ItemTax
			FROM @tblTransactionTax
			WHERE (strCalculationMethod != '' OR strCalculationMethod IS NOT NULL)
			AND	  (ysnInvalidSetup = 0)

			WHILE exists (SELECT * FROM #ItemTax)
			BEGIN
				SELECT TOP 1 
					 @intLoopTaxGroupID = intTaxGroupId
					,@intLoopTaxCodeID = intTaxCodeId
					,@intLoopTaxClassID = intTaxClassId
				FROM #ItemTax


				UPDATE @tblTransactionTax 
				SET dblRate = (SELECT TOP 1 dblTaxRate FROM tblCFTransactionTax WHERE intTaxCodeId = @intLoopTaxCodeID AND intTransactionId = @intTransactionId)
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID

				DELETE #ItemTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID

			END

			DROP TABLE #ItemTax
		END
	END
	ELSE
	BEGIN 
		INSERT INTO @tblTransactionTax(
			 [intTransactionDetailTaxId]	
			,[intInvoiceDetailId]  		
			,[intTaxGroupMasterId]			
			,[intTaxGroupId]				
			,[intTaxCodeId]					
			,[intTaxClassId]				
			,[strTaxableByOtherTaxes]		
			,[strCalculationMethod]			
			,[dblRate]			
			,[dblExemptionPercent]			
			,[dblTax]						
			,[dblAdjustedTax]				
			,[intSalesTaxAccountId]    			
			,[ysnSeparateOnInvoice]			
			,[ysnCheckoffTax]				
			,[strTaxCode]					
			,[ysnTaxExempt]			
			,[ysnInvalidSetup]				
			,[strTaxGroup]					
			,[strNotes]				
		)	
		EXEC uspARGetItemTaxes 
		 @ItemId			=@intItemId
		,@LocationId		=@intLocationId
		,@TransactionDate	=@dtmTransactionDate
		,@TaxGroupId		=@intTaxGroupId
		,@CustomerId		=@intCustomerId
	END

	IF (@intTransactionId is not null)
		BEGIN
			INSERT INTO tblCFTransactionNote (
			intTransactionId
			,strProcess
			,dtmProcessDate
			,strNote
			,strGuid
		)
		SELECT 
		 @intTransactionId
		,'Calculation'
		,@runDate
		,ISNULL(strTaxExemptReason,ISNULL(strNotes,ISNULL(strReason,'Invalid Setup -' + strTaxCode)))
		,@guid
		FROM @tblTransactionTax
		WHERE (intTaxGroupId =0 OR intTaxGroupId IS NULL) 
		AND	  (intTaxClassId =0 OR intTaxClassId IS NULL)
		AND	  (intTaxCodeId =0 OR intTaxCodeId IS NULL)
		AND	  (strCalculationMethod ='' OR strCalculationMethod IS NULL)
		AND	  (ysnInvalidSetup =1)
	END


	INSERT INTO @tblTaxRateTable	
	SELECT 
	 [intTransactionDetailTaxId]
	,[intTransactionDetailId]  AS [intInvoiceDetailId]
	,[intTaxGroupMasterId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[intTaxAccountId]    AS [intSalesTaxAccountId]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[strTaxCode]
	,[ysnTaxExempt]
	,[ysnInvalidSetup]
	,[strTaxGroup]
	,[strReason]					
	,[strNotes]						
	,[strTaxExemptReason]								
	FROM @tblTransactionTax
	WHERE LOWER(strCalculationMethod) = 'percentage'

	INSERT INTO @tblTaxUnitTable	
	SELECT 
	[intTransactionDetailTaxId]
	,[intTransactionDetailId]  AS [intInvoiceDetailId]
	,[intTaxGroupMasterId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[intTaxAccountId]    AS [intSalesTaxAccountId]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[strTaxCode]
	,[ysnTaxExempt]
	,[ysnInvalidSetup]
	,[strTaxGroup]
	,[strReason]		
	,[strNotes]			
	,[strTaxExemptReason]
	FROM @tblTransactionTax
	WHERE LOWER(strCalculationMethod) = 'unit'

	--TAX CALCULATION--
	
	SET @QxOP = @dblQuantity * @dblOriginalPrice
	SET @QxCP = @dblQuantity * @dblPrice

	WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxUnitTable))
	BEGIN
		
		-- SET LOOP VARIABLE--
		SELECT TOP 1
		 @strLoopTaxCode = strTaxCode
		,@Rate = dblRate
		,@CalculationMethod = strCalculationMethod
		,@ysnLoopTaxExempt = ysnCheckoffTax
		,@ysnLoopTaxExempt = ysnTaxExempt
		,@intLoopTaxGroupID = intTaxGroupId
		,@intLoopTaxCodeID = intTaxCodeId
		,@intLoopTaxClassID = intTaxClassId
		,@strTaxExemptReason	= strTaxExemptReason
		,@strNote				= strNotes
		,@strReason				= strReason
		,@ysnCheckoffTax		= ysnCheckoffTax
		,@ysnTaxExempt			= ysnTaxExempt
		,@ysnInvalidSetup		= ysnInvalidSetup
		,@strTaxCode			= strTaxCode
		FROM @tblTaxUnitTable

		IF(@ysnInvalidSetup = 0)
		BEGIN
			IF (@ysnTaxExempt = 1)
				BEGIN

				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Tax Exempt -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId] 	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@QxT
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE IF(@ysnCheckoffTax = 1)
				BEGIN

				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Check Off -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@QxT
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE
				BEGIN
					SELECT TOP 1
					 @QxT = ROUND (@dblQuantity * dblRate,2)
					,@QxOP = @QxOP - (@dblQuantity * dblRate)
					,@dblOPTotalTax = @dblOPTotalTax + (@dblQuantity * dblRate)
					,@dblCPTotalTax = @dblCPTotalTax + (@dblQuantity * dblRate)
					FROM @tblTaxUnitTable

					INSERT INTO @tblTransactionTaxOut
					(
						 [intTransactionDetailTaxId]
						,[intInvoiceDetailId]		
						,[intTransactionDetailId]  	
						,[intTaxGroupMasterId]		
						,[intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]					
						,[dblTax]					
						,[dblAdjustedTax]			
						,[dblExemptionPercent]		
						,[intSalesTaxAccountId]    	
						,[intTaxAccountId]    		
						,[ysnSeparateOnInvoice]		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]		
						,[strTaxGroup]				
						,[ysnInvalidSetup]				
						,[strReason]				
						,[strNotes]					
						,[strTaxExemptReason]		
						,[dblCalculatedTax]	
						,[dblOriginalTax]	
					)
					SELECT TOP 1
						 [intTransactionDetailTaxId]
						,[intInvoiceDetailId]		
						,[intTransactionDetailId]  	
						,[intTaxGroupMasterId]		
						,[intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]					
						,[dblTax]					
						,[dblAdjustedTax]			
						,[dblExemptionPercent]		
						,[intSalesTaxAccountId]    	
						,[intTaxAccountId]    		
						,[ysnSeparateOnInvoice]		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]		
						,[strTaxGroup]				
						,[ysnInvalidSetup]				
						,[strReason]				
						,[strNotes]					
						,[strTaxExemptReason]		
						,@QxT
						,@QxT
					FROM @tblTransactionTax
					WHERE intTaxGroupId = @intLoopTaxGroupID
					AND intTaxClassId = @intLoopTaxClassID
					AND intTaxCodeId = @intLoopTaxCodeID
				END
		END
		ELSE
		BEGIN
			IF (@intTransactionId is not null)
			BEGIN
				INSERT INTO tblCFTransactionNote (
				 intTransactionId
				,strProcess
				,dtmProcessDate
				,strNote
				,strGuid
			)
			VALUES
			(
				@intTransactionId
				, 'Calculation'
				, @runDate
				, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Invalid Setup -' + @strTaxCode)))
				, @guid
			)
			END
		END

		DELETE FROM @tblTaxUnitTable 
		WHERE intTaxGroupId = @intLoopTaxGroupID
		AND intTaxClassId = @intLoopTaxClassID
		AND intTaxCodeId = @intLoopTaxCodeID

	END
	
	WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxRateTable))
	BEGIN
		
		-- SET LOOP VARIABLE--
		SELECT TOP 1
		 @strLoopTaxCode = strTaxCode
		,@Rate = dblRate
		,@CalculationMethod = strCalculationMethod
		,@ysnLoopTaxExempt = ysnCheckoffTax
		,@ysnLoopTaxExempt = ysnTaxExempt
		,@intLoopTaxGroupID = intTaxGroupId
		,@intLoopTaxCodeID = intTaxCodeId
		,@intLoopTaxClassID = intTaxClassId
		,@strTaxExemptReason	= strTaxExemptReason
		,@strNote				= strNotes
		,@strReason				= strReason
		,@ysnCheckoffTax		= ysnCheckoffTax
		,@ysnTaxExempt			= ysnTaxExempt
		,@ysnInvalidSetup		= ysnInvalidSetup
		,@strTaxCode			= strTaxCode
		FROM @tblTaxRateTable

		IF(@ysnInvalidSetup = 0)
		BEGIN

			IF (@ysnTaxExempt = 1)
				BEGIN
				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Tax Exempt -' + @strTaxCode)))
					, @guid
				)
				END

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@OPTax	
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE IF(@ysnCheckoffTax = 1)
				BEGIN
				IF (@intTransactionId is not null)
				BEGIN
					INSERT INTO tblCFTransactionNote 
				(
					 intTransactionId
					,strProcess
					,dtmProcessDate
					,strNote
					,strGuid
				)
				VALUES
				(
					@intTransactionId
					, 'Calculation'
					, @runDate
					, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Check Off -' + @strTaxCode)))
					, @guid
				)
				END
				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,NULL
					,@OPTax	
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
			ELSE
				BEGIN

					IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
					OR @strPriceMethod = 'Import File Price' 
					OR @strPriceMethod = 'Credit Card' 
					OR @strPriceMethod = 'Posted Trans from CSV'
					OR @strPriceMethod = 'Origin History'
					OR @strPriceMethod = 'Network Cost')
					BEGIN
						SELECT TOP 1 
						 @OPTax = ROUND (((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
						,@CPTax = ROUND (((@QxCP / (dblRate/100 +1 )) * (dblRate/100)),2)
						,@dblOPTotalTax = @dblOPTotalTax + ((@QxOP / (dblRate/100 +1 )) * (dblRate/100))
						,@dblCPTotalTax = @dblCPTotalTax + ((@QxCP / (dblRate/100 +1 )) * (dblRate/100))
						FROM @tblTaxRateTable
					END
					ELSE
					BEGIN
						SELECT TOP 1 
						 @OPTax = ROUND (((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
						,@CPTax = ROUND ((@QxCP * (dblRate/100)),2)
						,@dblOPTotalTax = @dblOPTotalTax + ((@QxOP / (dblRate/100 +1 )) * (dblRate/100))
						,@dblCPTotalTax = @dblCPTotalTax + ((@QxCP / (dblRate/100 +1 )) * (dblRate/100))
						FROM @tblTaxRateTable
					END

					

				INSERT INTO @tblTransactionTaxOut
				(
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,[dblCalculatedTax]	
					,[dblOriginalTax]	
				)
				SELECT TOP 1
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]		
					,[intTransactionDetailId]  	
					,[intTaxGroupMasterId]		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblTax]					
					,[dblAdjustedTax]			
					,[dblExemptionPercent]		
					,[intSalesTaxAccountId]    	
					,[intTaxAccountId]    		
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[strTaxCode]				
					,[ysnTaxExempt]		
					,[strTaxGroup]				
					,[ysnInvalidSetup]				
					,[strReason]				
					,[strNotes]					
					,[strTaxExemptReason]		
					,@CPTax
					,@OPTax
				FROM @tblTransactionTax
				WHERE intTaxGroupId = @intLoopTaxGroupID
				AND intTaxClassId = @intLoopTaxClassID
				AND intTaxCodeId = @intLoopTaxCodeID
			END
		END
		ELSE
		BEGIN
			IF (@intTransactionId is not null)
			BEGIN
				INSERT INTO tblCFTransactionNote (
				 intTransactionId
				,strProcess
				,dtmProcessDate
				,strNote
				,strGuid
			)
			VALUES
			(
				@intTransactionId
				, 'Calculation'
				, @runDate
				, ISNULL(@strTaxExemptReason,ISNULL(@strNote,ISNULL(@strReason,'Invalid Setup -' + @strTaxCode)))
				, @guid
			)
			END
		END

		DELETE FROM @tblTaxRateTable 
		WHERE intTaxGroupId = @intLoopTaxGroupID
		AND intTaxClassId = @intLoopTaxClassID
		AND intTaxCodeId = @intLoopTaxCodeID

	END

	---------------------------------------------------
	--				 PRICE CALCULATION				 --
	---------------------------------------------------
	END


	DECLARE @tblTransactionPrice TABLE(
		 strTransactionPriceId		NVARCHAR(MAX)
		,dblOriginalAmount			NUMERIC(18,6)
		,dblCalculatedAmount		NUMERIC(18,6)
	)
	
	IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
	OR @strPriceMethod = 'Import File Price' 
	OR @strPriceMethod = 'Credit Card' 
	OR @strPriceMethod = 'Posted Trans from CSV'
	OR @strPriceMethod = 'Origin History'
	OR @strPriceMethod = 'Network Cost')
		BEGIN
			INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblPrice
		),
		(
			 'Net Price'
			,@dblOriginalPrice - (@dblOPTotalTax / @dblQuantity)
			,@dblPrice - (@dblCPTotalTax / @dblQuantity)
		),
		(
			 'Total Amount'
			,@dblOriginalPrice * @dblQuantity
			,@dblPrice * @dblQuantity
		)
		END
	ELSE
		BEGIN
			INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblPrice + (@dblCPTotalTax / @dblQuantity) 
		),
		(
			 'Net Price'
			,@dblOriginalPrice - (@dblOPTotalTax / @dblQuantity)
			,@dblPrice
		),
		(
			 'Total Amount'
			,@dblOriginalPrice * @dblQuantity
			,(@dblPrice + (@dblCPTotalTax / @dblQuantity)) * @dblQuantity
		)
		END

END
	

	DECLARE @dblMargin NUMERIC(18,6)

	SELECT @dblMargin = dblMargin , @dblTransferCost = dblCost
	FROM [dbo].[fnCFGetTransactionMargin](
	 0
	,@intItemId			
	,@intLocationId	
	,(SELECT TOP 1 dblCalculatedAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Net Price')
	,(SELECT TOP 1 dblCalculatedAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Gross Price')
	,@dblTransferCost	
	,@strTransactionType
	)


	DECLARE @intDupTransCount INT = 0
	DECLARE @ysnDuplicate BIT = 0
	DECLARE @ysnInvalid	BIT = 0

	-- DUPLICATE CHECK -- 
	SELECT @intDupTransCount = COUNT(*)
	FROM tblCFTransaction
	WHERE intNetworkId = @intNetworkId
	AND intSiteId = @intSiteId
	AND dtmTransactionDate = @dtmTransactionDate
	AND intCardId = @intCardId
	AND intProductId = @ProductId
	AND intPumpNumber = @PumpId

	IF(@intDupTransCount > 0)
	BEGIN
		--SET @ysnInvalid = 1
		SET @ysnDuplicate = 1
		IF(@ysnDuplicate = 1)
		BEGIN
			SET @ysnInvalid = 1
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',GETDATE(),NEWID(), @intTransactionId, 'Duplicate transaction history found.')
		END
	END

	--PRICING OUT--
	--if @IsImporting is true then save pricing to global temp table
	IF(@IsImporting = 1)
		BEGIN
			INSERT INTO ##tblCFTransactionPricingType
			(
			 intItemId
			,intCustomerId
			,intLocationId
			,dblQuantity
			,intItemUOMId
			,dtmTransactionDate
			,strTransactionType
			,intNetworkId
			,intSiteId
			,dblTransferCost
			,dblOriginalPrice
			,dblPrice				
			,strPriceMethod		
			,dblAvailableQuantity	
			,intContractHeaderId	
			,intContractDetailId	
			,intContractNumber		
			,intContractSeq		
			,strPriceBasis	
			,intPriceProfileId	
			,intPriceIndexId 	
			,intSiteGroupId 	
			,strPriceProfileId	
			,strPriceIndexId	
			,strSiteGroup		
			,dblPriceProfileRate
			,dblPriceIndexRate	
			,dtmPriceIndexDate
			,dblMargin	
			,ysnDuplicate
			)
			SELECT
			 @intItemId					AS intItemId
			,@intCustomerId				AS intCustomerId
			,@intLocationId				AS intLocationId
			,@dblQuantity				AS dblQuantity
			,@intItemUOMId				AS intItemUOMId
			,@dtmTransactionDate		AS dtmTransactionDate
			,@strTransactionType		AS strTransactionType
			,@intNetworkId				AS intNetworkId
			,@intSiteId					AS intSiteId
			,@dblTransferCost			AS dblTransferCost
			,@dblOriginalPrice			AS dblOriginalPrice
			,@dblPrice					AS dblPrice				
			,@strPriceMethod			AS strPriceMethod		
			,@dblAvailableQuantity		AS dblAvailableQuantity	
			,@intContractHeaderId		AS intContractHeaderId	
			,@intContractDetailId		AS intContractDetailId	
			,@intContractNumber			AS intContractNumber		
			,@intContractSeq			AS intContractSeq		
			,@strPriceBasis				AS strPriceBasis	
			,@intPriceProfileId			AS intPriceProfileId	
			,@intPriceIndexId 			AS intPriceIndexId 	
			,@intSiteGroupId 			AS intSiteGroupId 	
			,@strPriceProfileId			AS strPriceProfileId	
			,@strPriceIndexId			AS strPriceIndexId	
			,@strSiteGroup				AS strSiteGroup		
			,@dblPriceProfileRate		AS dblPriceProfileRate
			,@dblPriceIndexRate			AS dblPriceIndexRate	
			,@dtmPriceIndexDate			AS dtmPriceIndexDate	
			,@dblMargin					AS dblMargin
			,@ysnDuplicate				AS ysnDuplicate
		END
	ELSE
		BEGIN
			SELECT
			 @intItemId					AS intItemId
			,@intCustomerId				AS intCustomerId
			,@intLocationId				AS intLocationId
			,@dblQuantity				AS dblQuantity
			,@intItemUOMId				AS intItemUOMId
			,@dtmTransactionDate		AS dtmTransactionDate
			,@strTransactionType		AS strTransactionType
			,@intNetworkId				AS intNetworkId
			,@intSiteId					AS intSiteId
			,@dblTransferCost			AS dblTransferCost
			,@dblOriginalPrice			AS dblOriginalPrice
			,@dblPrice					AS dblPrice				
			,@strPriceMethod			AS strPriceMethod		
			,@dblAvailableQuantity		AS dblAvailableQuantity	
			,@intContractHeaderId		AS intContractHeaderId	
			,@intContractDetailId		AS intContractDetailId	
			,@intContractNumber			AS intContractNumber		
			,@intContractSeq			AS intContractSeq		
			,@strPriceBasis				AS strPriceBasis	
			,@intPriceProfileId			AS intPriceProfileId	
			,@intPriceIndexId 			AS intPriceIndexId 	
			,@intSiteGroupId 			AS intSiteGroupId 	
			,@strPriceProfileId			AS strPriceProfileId		
			,@strPriceIndexId			AS strPriceIndexId		
			,@strSiteGroup				AS strSiteGroup			
			,@dblPriceProfileRate		AS dblPriceProfileRate	
			,@dblPriceIndexRate			AS dblPriceIndexRate		
			,@dtmPriceIndexDate			AS dtmPriceIndexDate	
			,@dblMargin					AS dblMargin	
			,@ysnDuplicate				AS ysnDuplicate
		END

IF(@IsImporting = 1)
BEGIN
	INSERT INTO ##tblCFTransactionTaxType
	(
	 dblTaxCalculatedAmount
	,dblTaxOriginalAmount
	,intTaxCodeId
	,dblTaxRate 
	,strTaxCode 
	)
	SELECT 
	dblCalculatedTax AS 'dblTaxCalculatedAmount'
	,dblOriginalTax AS 'dblTaxOriginalAmount'
	,intTaxCodeId
	,dblRate AS 'dblTaxRate'
	,strTaxCode AS 'strTaxCode'
	FROM @tblTransactionTaxOut
END
ELSE
BEGIN
	SELECT 
	 dblCalculatedTax AS 'dblTaxCalculatedAmount'
	,dblOriginalTax AS 'dblTaxOriginalAmount'
	,intTaxCodeId
	,dblRate AS 'dblTaxRate'
	,strTaxCode AS 'strTaxCode'
	FROM @tblTransactionTaxOut
END
IF(@IsImporting = 1)
BEGIN
	INSERT INTO ##tblCFTransactionPriceType
	(
	 [strTransactionPriceId]
	,[dblTaxOriginalAmount]	
	,[dblTaxCalculatedAmount]
	)
	SELECT 
	 [strTransactionPriceId]
	,[dblOriginalAmount]	
	,[dblCalculatedAmount]
	FROM @tblTransactionPrice
END
ELSE
BEGIN
	SELECT * FROM @tblTransactionPrice
END