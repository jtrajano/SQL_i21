CREATE PROCEDURE [dbo].[uspCFRecalculateTransaciton] 

 @ProductId				INT							
,@CardId				INT	
,@VehicleId				INT				
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
--  1. REMOTE TRANSACTION			--transactiontax
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
,@FederalExciseTax1					NUMERIC(18,6)	= 0.000000
,@FederalExciseTax2					NUMERIC(18,6)	= 0.000000
,@StateExciseTax1					NUMERIC(18,6)	= 0.000000
,@StateExciseTax2					NUMERIC(18,6)	= 0.000000
,@StateExciseTax3					NUMERIC(18,6)	= 0.000000
,@CountyTax1						NUMERIC(18,6)	= 0.000000
,@CityTax1							NUMERIC(18,6)	= 0.000000
,@StateSalesTax						NUMERIC(18,6)	= 0.000000
,@CountySalesTax					NUMERIC(18,6)	= 0.000000
,@CitySalesTax						NUMERIC(18,6)	= 0.000000

,@strGUID							NVARCHAR(MAX)	= ''
,@strProcessDate					NVARCHAR(MAX)	= ''

,@BatchRecalculate					BIT				=	0

,@Tax1								NVARCHAR(MAX)	= ''
,@Tax2								NVARCHAR(MAX)	= ''
,@Tax3								NVARCHAR(MAX)	= ''
,@Tax4								NVARCHAR(MAX)	= ''
,@Tax5								NVARCHAR(MAX)	= ''
,@Tax6								NVARCHAR(MAX)	= ''
,@Tax7								NVARCHAR(MAX)	= ''
,@Tax8								NVARCHAR(MAX)	= ''
,@Tax9								NVARCHAR(MAX)	= ''
,@Tax10								NVARCHAR(MAX)	= ''
,@TaxValue1							NUMERIC(18,6)	= 0.000000
,@TaxValue2							NUMERIC(18,6)	= 0.000000
,@TaxValue3							NUMERIC(18,6)	= 0.000000
,@TaxValue4							NUMERIC(18,6)	= 0.000000
,@TaxValue5							NUMERIC(18,6)	= 0.000000
,@TaxValue6							NUMERIC(18,6)	= 0.000000
,@TaxValue7							NUMERIC(18,6)	= 0.000000
,@TaxValue8							NUMERIC(18,6)	= 0.000000
,@TaxValue9							NUMERIC(18,6)	= 0.000000
,@TaxValue10						NUMERIC(18,6)	= 0.000000
,@DevMode							BIT				= 0

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
	DECLARE @intVehicleId					INT
	DECLARE @intTaxGroupId					INT

	DECLARE @dblPrice						NUMERIC(18,6)
	DECLARE @strPriceBasis					NVARCHAR(MAX)
	DECLARE @strPriceMethod					NVARCHAR(MAX)
	DECLARE @intContractHeaderId			INT	
	DECLARE @intContractDetailId			INT
	DECLARE @strContractNumber				NVARCHAR(MAX)
	DECLARE @intContractSeq					INT
	DECLARE @dblAvailableQuantity			NUMERIC(18,6)

	DECLARE @intTransactionId				INT
	DECLARE @ysnCreditCardUsed				BIT
	DECLARE @ysnPostedOrigin				BIT
	DECLARE @ysnPostedCSV					BIT
	DECLARE @guid							NVARCHAR(MAX)
	DECLARE	@runDate						DATETIME

	DECLARE @intPriceProfileId				INT
	DECLARE @intPriceProfileDetailId		INT
	DECLARE @intPriceIndexId 				INT
	DECLARE @intSiteGroupId 				INT

	DECLARE @ysnForceRounding				BIT
	DECLARE @strPriceProfileId				NVARCHAR(MAX)
	DECLARE @strPriceIndexId				NVARCHAR(MAX)
	DECLARE @strSiteGroup					NVARCHAR(MAX)
	DECLARE @dblPriceProfileRate			NUMERIC(18,6)
	DECLARE @dblPriceIndexRate				NUMERIC(18,6)
	DECLARE @dblAdjustmentRate				NUMERIC(18,6)
	
	DECLARE	@dtmPriceIndexDate				DATETIME		
	
				
	DECLARE @intProductId					INT
	DECLARE @strProductNumber				NVARCHAR(MAX)
	DECLARE @strItemId						NVARCHAR(MAX)

	DECLARE @ysnBackoutDueToRouding			BIT	= 0

	DECLARE @intPriceRuleGroup				INT
	
	DECLARE @dblGrossTransferCost			NUMERIC(18,6)
	DECLARE @dblNetTransferCost				NUMERIC(18,6)
	DECLARE @dblAdjustments					NUMERIC(18,6)
	DECLARE @dblAdjustmentWithIndex			NUMERIC(18,6)

	
	DECLARE @ysnCaptiveSite					BIT
	DECLARE @ysnActive						BIT

	DECLARE @companyConfigFreightTermId	INT = NULL
	SELECT TOP 1 @companyConfigFreightTermId = intFreightTermId FROM tblCFCompanyPreference


	

	-- IF RECALCULATE FROM IMPORTING--
	-- SAVE RESULT ON GLOBAL TEMP TABLE
	IF(@IsImporting = 1)
	BEGIN

	--IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionPricingType') = 1)
	--BEGIN
	--	DROP TABLE ##tblCFTransactionPricingType
	--END
	--	CREATE TABLE ##tblCFTransactionPricingType (
	--	 intItemId						INT
	--	,intProductId					INT
	--	,strProductNumber				NVARCHAR(MAX)
	--	,strItemId						NVARCHAR(MAX)
	--	,intCustomerId					INT
	--	,intLocationId					INT
	--	,dblQuantity					NUMERIC(18,6)
	--	,intItemUOMId					INT
	--	,dtmTransactionDate				DATETIME
	--	,strTransactionType				NVARCHAR(MAX)
	--	,intNetworkId					INT
	--	,intSiteId						INT
	--	,dblTransferCost				NUMERIC(18,6)
	--	,dblInventoryCost				NUMERIC(18,6)
	--	,dblOriginalPrice				NUMERIC(18,6)
	--	,dblPrice						NUMERIC(18,6)
	--	,strPriceMethod					NVARCHAR(MAX)
	--	,dblAvailableQuantity			NUMERIC(18,6)
	--	,intContractHeaderId			INT
	--	,intContractDetailId			INT
	--	,strContractNumber				NVARCHAR(MAX)
	--	,intContractSeq					INT
	--	,strPriceBasis					NVARCHAR(MAX)
	--	,intPriceProfileId				INT
	--	,intPriceIndexId 				INT
	--	,intSiteGroupId 				INT
	--	,strPriceProfileId				NVARCHAR(MAX)
	--	,strPriceIndexId				NVARCHAR(MAX)
	--	,strSiteGroup					NVARCHAR(MAX)
	--	,dblPriceProfileRate			NUMERIC(18,6)
	--	,dblPriceIndexRate				NUMERIC(18,6)
	--	,dtmPriceIndexDate				DATETIME
	--	,dblMargin						NUMERIC(18,6)
	--	,dblAdjustmentRate				NUMERIC(18,6)
	--	,ysnDuplicate					BIT
	--	,ysnInvalid						BIT
	--	,dblGrossTransferCost			NUMERIC(18,6)
	--	,dblNetTransferCost				NUMERIC(18,6)
	--	,intFreightTermId				INT
	--);

	DELETE FROM tblCFTransactionPricingType

	--IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionTaxType') = 1)
	--BEGIN
	--	DROP TABLE ##tblCFTransactionTaxType
	--END
	--	CREATE TABLE ##tblCFTransactionTaxType (
	--	 [dblTaxCalculatedAmount]		NUMERIC(18,6)
	--	,[dblTaxOriginalAmount]			NUMERIC(18,6)
	--	,[intTaxCodeId]					INT
	--	,[dblTaxRate]					NUMERIC(18,6)
	--	,[strTaxCode]					NVARCHAR(MAX)
	--);

	DELETE FROM tblCFTransactionTaxType

	--IF ((SELECT COUNT(*) FROM tempdb..sysobjects WHERE name = '##tblCFTransactionPriceType') = 1)
	--BEGIN
	--	DROP TABLE ##tblCFTransactionPriceType
	--END
	--	CREATE TABLE ##tblCFTransactionPriceType (
	--	 [strTransactionPriceId]		NVARCHAR(MAX)
	--	,[dblTaxOriginalAmount]			NUMERIC(18,6)
	--	,[dblTaxCalculatedAmount]		NUMERIC(18,6)
	--);

	DELETE FROM tblCFTransactionPriceType

	END

	
	IF(@strGUID IS NULL OR @strGUID = '')
	BEGIN
		SET @guid		= NEWID()
	END
	ELSE
	BEGIN
		SET @guid		= @strGUID
	END

	IF(@strProcessDate IS NULL OR @strProcessDate = '')
	BEGIN
		SET @runDate		= GETDATE()
	END
	ELSE
	BEGIN
		SET @runDate		= @strProcessDate
	END

	 
	SET @ysnPostedOrigin	= @PostedOrigin
	SET @ysnPostedCSV		= @PostedCSV	
	SET @ysnCreditCardUsed = @CreditCardUsed
	SET @intVehicleId = @VehicleId
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
		


	--GET CAPTIVE SITE--
	SELECT TOP 1 
	@ysnCaptiveSite = ysnCaptiveSite
	FROM tblCFSite WHERE intSiteId = @intSiteId

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
		,@intPriceRuleGroup = cfAccount.intPriceRuleGroup
		FROM tblCFCard as cfCard
		INNER JOIN tblCFAccount as cfAccount
		ON cfCard.intAccountId = cfAccount.intAccountId
		WHERE cfCard.intCardId = @intCardId
	END


	--GET @ysnActive CUSTOMER--

		SELECT TOP 1
		@ysnActive = ysnActive
		FROM tblARCustomer
		WHERE intEntityId = @intCustomerId

	--GET @ysnActive CUSTOMER--

	
	
	--GET COMPANY LOCATION ID--
	SELECT TOP 1
		@intLocationId = intARLocationId,
		@intSiteGroupId = intAdjustmentSiteGroupId
	FROM tblCFSite as cfSite
	WHERE cfSite.intSiteId = @intSiteId

	------------ORIGINAL VALUE----------
	DECLARE @strOriginalProduct NVARCHAR(MAX)
	IF(@ProductId = 0 AND @TransactionId IS NOT NULL)
	BEGIN
		SELECT TOP 1 @strOriginalProduct = strOriginalProductNumber 
		FROM tblCFTransaction 
		WHERE intTransactionId = @TransactionId

		--GET IC ITEM ID BY SITE--
		SELECT TOP 1
			@intItemId = cfItem.intARItemId,
			@intProductId = cfItem.intItemId,
			@strProductNumber = cfItem.strProductNumber,
			@strItemId = icItem.strItemNo
		FROM tblCFItem as cfItem 
		INNER JOIN tblICItem as icItem
		ON cfItem.intARItemId = icItem.intItemId
		WHERE cfItem.intSiteId = @intSiteId
		AND cfItem.intNetworkId = @intNetworkId
		AND cfItem.strProductNumber = @strOriginalProduct
	
		--GET IC ITEM ID BY NETWORK--
		IF (@intItemId IS NULL)
		BEGIN
			SELECT TOP 1
				@intItemId = cfItem.intARItemId,
				@intProductId = cfItem.intItemId,
				@strProductNumber = cfItem.strProductNumber,
				@strItemId = icItem.strItemNo
			FROM tblCFItem as cfItem 
			INNER JOIN tblICItem as icItem
			ON cfItem.intARItemId = icItem.intItemId
			WHERE cfItem.intNetworkId = @intNetworkId
			AND cfItem.strProductNumber = @strOriginalProduct
		END

		IF (@intItemId IS NULL)
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
				,'Unable to find product number ' + @strOriginalProduct + ' into i21 item list'
				,@guid
		END

	END
	ELSE
	BEGIN
		--GET IC ITEM ID BY SITE--
		SELECT TOP 1
			@intItemId = cfItem.intARItemId,
			@intProductId = cfItem.intItemId,
			@strProductNumber = cfItem.strProductNumber,
			@strItemId = icItem.strItemNo
		FROM tblCFItem as cfItem 
		INNER JOIN tblICItem as icItem
		ON cfItem.intARItemId = icItem.intItemId
		WHERE cfItem.intSiteId = @intSiteId
		AND cfItem.intNetworkId = @intNetworkId
		AND cfItem.intItemId = @ProductId
	
		--GET IC ITEM ID BY NETWORK--
		IF (@intItemId IS NULL)
		BEGIN
			SELECT TOP 1
				@intItemId = cfItem.intARItemId,
				@intProductId = cfItem.intItemId,
				@strProductNumber = cfItem.strProductNumber,
				@strItemId = icItem.strItemNo
			FROM tblCFItem as cfItem 
			INNER JOIN tblICItem as icItem
			ON cfItem.intARItemId = icItem.intItemId
			WHERE cfItem.intNetworkId = @intNetworkId
			AND cfItem.intItemId = @ProductId
		END
	END

	------------ORIGINAL VALUE----------

	--GET IC ITEM UOM ID--
	SELECT TOP 1
		@intItemUOMId = icItemLocation.intIssueUOMId
	FROM tblICItemLocation as icItemLocation
	WHERE icItemLocation.intItemId = @intItemId
	AND icItemLocation.intLocationId = @intLocationId


	--DECLARE @ysnNetworkTaxOverride BIT	= 0
	DECLARE @strNetworkType NVARCHAR(MAX)


	SELECT TOP 1 @strNetworkType = strNetworkType 
	FROM tblCFNetwork
	WHERE intNetworkId = @NetworkId

	--IF(@strTransactionType != 'Local/Network')
	--BEGIN
	--	IF(@strNetworkType = 'CFN' OR @strNetworkType = 'PacPride')
	--	BEGIN
	--		IF(ISNULL(@intTaxGroupId,0) > 0)
	--		BEGIN
	--			SET @ysnNetworkTaxOverride = 1
	--		END
	--	END
	--END

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
	@CFPriceOut					=	@dblPrice					output,
	@CFPricingOut				=	@strPriceMethod				output,
	@CFAvailableQuantity		=	@dblAvailableQuantity		output,
	@CFContractHeaderId			=	@intContractHeaderId		output,
	@CFContractDetailId			=	@intContractDetailId		output,
	@CFContractNumber			=	@strContractNumber			output,
	@CFContractSeq				=	@intContractSeq				output,
	@CFPriceBasis				=	@strPriceBasis				output,
	@CFCreditCard				=	@ysnCreditCardUsed,      
	@CFPostedOrigin				=	@ysnPostedOrigin,      
	@CFPostedCSV				=	@ysnPostedCSV,      
	@CFPriceProfileId			=	@intPriceProfileId			output,
	@CFPriceProfileDetailId		=	@intPriceProfileDetailId	output,
	@CFPriceIndexId				=	@intPriceIndexId 			output,
	@CFSiteGroupId				= 	@intSiteGroupId,				
	@CFPriceRuleGroup			=	@intPriceRuleGroup,
	@CFAdjustmentRate			=	@dblAdjustmentRate			output

	

	SELECT TOP 1 
	@strPriceProfileId = cfPriceProfile.strPriceProfile
	,@dblPriceProfileRate = cfPriceProfileDetail.dblRate
	,@ysnForceRounding =ysnForceRounding
	FROM tblCFPriceProfileHeader AS cfPriceProfile
	INNER JOIN tblCFPriceProfileDetail AS cfPriceProfileDetail 
	ON cfPriceProfile.intPriceProfileHeaderId = cfPriceProfileDetail.intPriceProfileHeaderId
	WHERE cfPriceProfile.intPriceProfileHeaderId = @intPriceProfileId
	AND cfPriceProfileDetail.intPriceProfileDetailId = @intPriceProfileDetailId

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
	AND cfIndexPricingHeader.dtmDate <= @dtmTransactionDate
	ORDER BY cfIndexPricingHeader.dtmDate DESC

	SELECT TOP 1
	@strSiteGroup = strSiteGroup
	FROM tblCFSiteGroup
	WHERE intSiteGroupId = @intSiteGroupId


	--IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
	--BEGIN
	--	SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
	--END

	TAXCOMPUTATION:
	
	---------------------------------------------------
	--				TAX COMPUTATION					 --
	---------------------------------------------------
	
	DECLARE @tblCFOriginalTax				TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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
	DECLARE @tblCFCalculatedTax				TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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
	
	DECLARE @tblCFCalculatedTaxExempt				TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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

	DECLARE @tblCFRemoteOriginalTax			TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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
	DECLARE @tblCFRemoteCalculatedTax		TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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
	DECLARE @tblCFTransactionTax			TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnTaxOnly]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
		,[dblCalculatedTax]					NUMERIC(18,6)
		,[dblOriginalTax]					NUMERIC(18,6)
	)
	DECLARE @tblCFBackoutTax				TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
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
	DECLARE @tblCFRemoteTax					TABLE
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
		,[dblBaseRate]						NUMERIC(18,6)
		,[dblTax]							NUMERIC(18,6)
		,[dblAdjustedTax]					NUMERIC(18,6)
		,[dblExemptionPercent]				NUMERIC(18,6)
		,[intSalesTaxAccountId]    			INT
		,[intTaxAccountId]    				INT
		,[ysnSeparateOnInvoice]				BIT
		,[ysnCheckoffTax]					BIT
		,[strTaxCode]						NVARCHAR(MAX)
		,[ysnTaxExempt]						BIT		
		,[ysnTaxOnly]						BIT		
		,[ysnInvalidSetup]					BIT
		,[strTaxGroup]						NVARCHAR(MAX)
		,[ysnInvalid]						BIT
		,[strReason]						NVARCHAR(MAX)
		,[strNotes]							NVARCHAR(MAX)
		,[strTaxExemptReason]				NVARCHAR(MAX)
		,[dblCalculatedTax]					NUMERIC(18,6)
		,[dblOriginalTax]					NUMERIC(18,6)
	)
	DECLARE @LineItemTaxDetailStagingTable LineItemTaxDetailStagingTable


	DECLARE @strTaxCodes					VARCHAR(MAX) 
	DECLARE @intLoopTaxGroupID 				INT
	DECLARE @intLoopTaxCodeID 				INT
	DECLARE @intLoopTaxClassID				INT
	DECLARE @DisregardExemptionSetup		BIT

	DECLARE @ysnApplyTaxExemption		BIT = 1
	DECLARE @strSiteApplyExemption		NVARCHAR(5)
	DECLARE @strNetworkApplyExemption	NVARCHAR(5)


	SELECT TOP 1 @strSiteApplyExemption		= strAllowExemptionsOnExtAndRetailTrans FROM tblCFSite	  WHERE intSiteId	 = @intSiteId
	SELECT TOP 1 @strNetworkApplyExemption	= strAllowExemptionsOnExtAndRetailTrans FROM tblCFNetwork WHERE intNetworkId = @intNetworkId

	IF(LOWER(@strTransactionType) = 'extended remote')
	BEGIN
		IF(LOWER(ISNULL(@strNetworkApplyExemption,'no')) = 'yes' AND LOWER(ISNULL(@strSiteApplyExemption,'no')) = 'yes')
		BEGIN
			SET @ysnApplyTaxExemption = 0
		END
		ELSE IF(LOWER(ISNULL(@strNetworkApplyExemption,'no')) = 'no' AND LOWER(ISNULL(@strSiteApplyExemption,'no')) = 'yes')
		BEGIN
			SET @ysnApplyTaxExemption = 0
		END
		ELSE IF(LOWER(ISNULL(@strNetworkApplyExemption,'no')) = 'no' AND LOWER(ISNULL(@strSiteApplyExemption,'no')) = 'no')
		BEGIN
			SET @ysnApplyTaxExemption = 1
		END
		ELSE IF(LOWER(ISNULL(@strNetworkApplyExemption,'no')) = 'yes' AND LOWER(ISNULL(@strSiteApplyExemption,'no')) = 'no')
		BEGIN
			SET @ysnApplyTaxExemption = 1
		END
	END
	ELSE
	BEGIN
		SET @ysnApplyTaxExemption = 0
	END

	IF((@ysnPostedCSV IS NULL OR @ysnPostedCSV = 0 ) AND (@ysnPostedOrigin = 0 OR @ysnPostedCSV IS NULL))
	BEGIN
		IF (LOWER(@strTransactionType) like '%remote%')
		BEGIN
			IF(ISNULL(@intTaxGroupId,0) = 0)
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

				INSERT INTO @tblCFRemoteTax(
				 [intTransactionDetailTaxId]	
				,[intTransactionDetailId]  		
				,[intTaxGroupMasterId]			
				,[intTaxGroupId]				
				,[intTaxCodeId]					
				,[intTaxClassId]				
				,[strTaxableByOtherTaxes]		
				,[strCalculationMethod]			
				,[dblRate]						
				--,[dblBaseRate]						
				,[dblTax]						
				,[dblAdjustedTax]				
				,[intTaxAccountId]    			
				,[ysnSeparateOnInvoice]			
				,[ysnCheckoffTax]				
				,[strTaxCode]					
				,[ysnTaxExempt]			
				,[ysnTaxOnly]			
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
				,@FederalExciseTax1				=@FederalExciseTax1	
				,@FederalExciseTax2				=@FederalExciseTax2	
				,@StateExciseTax1				=@StateExciseTax1	
				,@StateExciseTax2				=@StateExciseTax2	
				,@StateExciseTax3				=@StateExciseTax3	
				,@CountyTax1					=@CountyTax1		
				,@CityTax1						=@CityTax1			
				,@StateSalesTax					=@StateSalesTax		
				,@CountySalesTax				=@CountySalesTax	
				,@CitySalesTax					=@CitySalesTax
				,@Tax1							=@Tax1		
				,@Tax2							=@Tax2		
				,@Tax3							=@Tax3		
				,@Tax4							=@Tax4		
				,@Tax5							=@Tax5		
				,@Tax6							=@Tax6		
				,@Tax7							=@Tax7		
				,@Tax8							=@Tax8		
				,@Tax9							=@Tax9		
				,@Tax10							=@Tax10		
				,@TaxValue1						=@TaxValue1	
				,@TaxValue2						=@TaxValue2	
				,@TaxValue3						=@TaxValue3	
				,@TaxValue4						=@TaxValue4	
				,@TaxValue5						=@TaxValue5	
				,@TaxValue6						=@TaxValue6	
				,@TaxValue7						=@TaxValue7	
				,@TaxValue8						=@TaxValue8	
				,@TaxValue9						=@TaxValue9	
				,@TaxValue10					=@TaxValue10

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					SELECT '@tblCFRemoteTax1', * from @tblCFRemoteTax --HERE
				END

				--COMPUTE REMOTE TAX--
				IF(@strNetworkType = 'CFN')
				BEGIN
					
					--SELECT @strNetworkType

					UPDATE @tblCFRemoteTax 
					SET dblAdjustedTax = dblRate , dblTax = dblRate

					--BACKOUT TAX--
					IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
					OR CHARINDEX('pump price adjustment',LOWER(@strPriceBasis)) > 0 
					OR CHARINDEX('transfer cost',LOWER(@strPriceBasis)) > 0 
					OR @strPriceMethod = 'Import File Price' 
					OR @strPriceMethod = 'Credit Card' 
					OR @strPriceMethod = 'Posted Trans from CSV'
					OR @strPriceMethod = 'Origin History'
					OR @strPriceMethod = 'Network Cost')
					BEGIN
						UPDATE @tblCFRemoteTax 
						SET dblRate = CASE 
							WHEN LOWER(strCalculationMethod) = 'percentage' 
							THEN ((ISNULL(dblRate,0) / @dblQuantity) / (ISNULL(@dblOriginalPrice,0) - (ISNULL(dblRate,0) / @dblQuantity))) * 100
							--THEN ((ISNULL(@dblOriginalPrice,0) * ISNULL(@dblQuantity,0)) * (1 +(ISNULL(dblRate,0) / 100)) /@dblQuantity)
							ELSE ISNULL(dblRate,0) / ISNULL(@dblQuantity,0)
							END
					END

					ELSE
					BEGIN
						UPDATE @tblCFRemoteTax 
						SET dblRate = CASE 
							WHEN LOWER(strCalculationMethod) = 'percentage' 
							THEN (ISNULL(dblRate,0) / @dblQuantity) / (ISNULL(@dblOriginalPrice,0)) * 100
							--THEN ((ISNULL(@dblOriginalPrice,0) * ISNULL(@dblQuantity,0)) * (1 +(ISNULL(dblRate,0) / 100)) /@dblQuantity)
							ELSE ISNULL(dblRate,0) / ISNULL(@dblQuantity,0)
							END
					END

				END

				
			

				IF(@IsImporting = 0)
				BEGIN

					SELECT * 
					INTO #ItemTax
					FROM @tblCFRemoteTax
					WHERE (strCalculationMethod != '' OR strCalculationMethod IS NOT NULL)
					AND	  (ysnInvalidSetup = 0)

					WHILE exists (SELECT * FROM #ItemTax)
					BEGIN
						SELECT TOP 1 
							 @intLoopTaxGroupID = intTaxGroupId
							,@intLoopTaxCodeID = intTaxCodeId
							,@intLoopTaxClassID = intTaxClassId
						FROM #ItemTax


						UPDATE @tblCFRemoteTax 
						SET 
						 dblRate = (SELECT TOP 1 dblTaxRate FROM tblCFTransactionTax WHERE intTaxCodeId = @intLoopTaxCodeID AND intTransactionId = @intTransactionId)
						,dblTax = (SELECT TOP 1 dblTaxOriginalAmount FROM tblCFTransactionTax WHERE intTaxCodeId = @intLoopTaxCodeID AND intTransactionId = @intTransactionId)
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

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					SELECT '@tblCFRemoteTax1', * from @tblCFRemoteTax --HERE
				END

				--LOG INVALID TAX SETUP--
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
						,ISNULL(strReason,'Invalid Setup -' + strTaxCode)
						,@guid
					FROM @tblCFRemoteTax
					WHERE (ysnInvalidSetup =1 AND LOWER(strReason) NOT LIKE '%item category%') AND (ysnTaxExempt IS NULL OR  ysnTaxExempt = 0)
				END
				--LOG INVALID TAX SETUP--

				--@LineItemTaxDetailStagingTable--
				INSERT INTO @LineItemTaxDetailStagingTable(
					 [intDetailTaxId]	
					,[intDetailId]  		
					,[intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]			
					,[dblBaseRate]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intTaxAccountId]    			
					,[ysnSeparateOnInvoice]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]			
					,[ysnTaxOnly]			
					,[strNotes]			
				)	
				SELECT 
					 [intTransactionDetailTaxId]
					,[intInvoiceDetailId]  		
					,[intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]			
					,[dblBaseRate]			
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intSalesTaxAccountId]    	
					,[ysnSeparateOnInvoice]		
					,[ysnCheckoffTax]			
					,[ysnTaxExempt]		
					,ISNULL([ysnTaxOnly],0)	
					,[strNotes]  				
					
				FROM
				@tblCFRemoteTax
				WHERE ysnInvalidSetup = 0
				--@LineItemTaxDetailStagingTable--

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					--DEBUGGER HERE--  
					SELECT '@LineItemTaxDetailStagingTable',* FROM @LineItemTaxDetailStagingTable --HERE--
				END

				--Backout tax--
				IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('pump price adjustment',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('transfer cost',LOWER(@strPriceBasis)) > 0 
				OR @strPriceMethod = 'Import File Price' 
				OR @strPriceMethod = 'Credit Card' 
				OR @strPriceMethod = 'Posted Trans from CSV'
				OR @strPriceMethod = 'Origin History'
				OR @strPriceMethod = 'Network Cost')
				BEGIN

					IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
					BEGIN
						SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
					END


					IF(ISNULL(@ysnApplyTaxExemption,0) = 1)
					BEGIN
						update @LineItemTaxDetailStagingTable set ysnTaxExempt = 0
					END
					ELSE
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
						(
						 [intTaxGroupId]				
						,[intTaxCodeId]					
						,[intTaxClassId]				
						,[strTaxableByOtherTaxes]		
						,[strCalculationMethod]			
						,[dblRate]			
						,[dblExemptionPercent]			
						,[dblTax]						
						,[dblAdjustedTax]				
						,[intSalesTaxAccountId]    			
						,[ysnCheckoffTax]
						,[ysnTaxExempt]
						,[ysnInvalidSetup]				
						,[strNotes]							
						)	
						SELECT 
						 [intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]					
						,[dblExemptionPercent]		
						,[dblTax]					
						,[dblAdjustedTax]			
						,[intTaxAccountId]			
						,[ysnCheckoffTax]				
						,[ysnTaxExempt]					
						,[ysnInvalidSetup]				
						,[strNotes]						
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,(@dblPrice * @dblQuantity)
							,@LineItemTaxDetailStagingTable
							,1
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,NULL
							,0
							,@dtmTransactionDate
							,NULL
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1 -- @DisregardExemptionSetup
							,0
							,@intItemUOMId	--intItemUOMId
							,@intSiteId
							,0		--@IsDeliver
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate			
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END
					
					INSERT INTO @tblCFCalculatedTax	
					(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]			
					,[dblBaseRate]
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
					)	
					SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]					
					,[dblBaseRate]
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
					FROM [fnConstructLineItemTaxDetail] 
					(
						 @dblQuantity
						,(@dblPrice * @dblQuantity)
						,@LineItemTaxDetailStagingTable
						,1
						,@intItemId
						,@intCustomerId
						,@intLocationId
						,NULL
						,0
						,@dtmTransactionDate
						,NULL
						,1
						,NULL
						,@companyConfigFreightTermId
						,@intCardId		
						,@intVehicleId
						,@ysnApplyTaxExemption -- @DisregardExemptionSetup
						,0
						,@intItemUOMId	--intItemUOMId
						,@intSiteId
						,0		--@IsDeliver
						,NULL --@CurrencyId
						,NULL -- @CurrencyExchangeRateTypeId
						,NULL -- @@CurrencyExchangeRate
					)


					update @LineItemTaxDetailStagingTable set ysnTaxExempt = 0
					INSERT INTO @tblCFOriginalTax	
					(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
					)	
					SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
					FROM [fnConstructLineItemTaxDetail] 
					(
						@dblQuantity										 
						,(@dblOriginalPrice * @dblQuantity)					 
						,@LineItemTaxDetailStagingTable						 
						,1													 
						,@intItemId											 
						,@intCustomerId										 
						,@intLocationId										 
						,NULL												 
						,0													 
						,@dtmTransactionDate								 
						,NULL												 
						,1													 
						,NULL												 
						,@companyConfigFreightTermId												 
						,@intCardId												 
						,@intVehicleId												 
						, 1 --@DisregardExemptionSetup						 
						, 0	
						, @intItemUOMId	--intItemUOMId		
						,@intSiteId
						,0		--@IsDeliver		
						,NULL --@CurrencyId
						,NULL -- @CurrencyExchangeRateTypeId
						,NULL -- @@CurrencyExchangeRate								 
					)



				END

			ELSE
			--Normal calc--
			BEGIN


				IF(ISNULL(@ysnApplyTaxExemption,0) = 1)
				BEGIN
					update @LineItemTaxDetailStagingTable set ysnTaxExempt = 0
				END
				ELSE
				BEGIN
					INSERT INTO @tblCFCalculatedTaxExempt	
					(
						 [intTaxGroupId]				
						,[intTaxCodeId]					
						,[intTaxClassId]				
						,[strTaxableByOtherTaxes]		
						,[strCalculationMethod]			
						,[dblRate]			
						,[dblExemptionPercent]			
						,[dblTax]						
						,[dblAdjustedTax]				
						,[intSalesTaxAccountId]    			
						,[ysnCheckoffTax]
						,[ysnTaxExempt]
						,[ysnInvalidSetup]				
						,[strNotes]							
					)	
					SELECT 
						 [intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]					
						,[dblExemptionPercent]		
						,[dblTax]					
						,[dblAdjustedTax]			
						,[intTaxAccountId]			
						,[ysnCheckoffTax]				
						,[ysnTaxExempt]					
						,[ysnInvalidSetup]				
						,[strNotes]						
					FROM [fnConstructLineItemTaxDetail] 
					(
						 @dblQuantity
						,0
						,@LineItemTaxDetailStagingTable
						,0
						,@intItemId
						,@intCustomerId
						,@intLocationId
						,NULL
						,@dblPrice
						,@dtmTransactionDate
						,NULL
						,1
						,NULL
						,@companyConfigFreightTermId
						,@intCardId		
						,@intVehicleId
						,1 --@DisregardExemptionSetup
						,0
						, @intItemUOMId	--intItemUOMId			
						,@intSiteId
						,0		--@IsDeliver	
						,NULL --@CurrencyId
						,NULL -- @CurrencyExchangeRateTypeId
						,NULL -- @@CurrencyExchangeRate											 
					)
					IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
				END

				INSERT INTO @tblCFCalculatedTax	
			(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]	
					,[dblBaseRate]		
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]	
					,[dblBaseRate]				
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,NULL
					,@dblPrice
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId			
					,@intSiteId
					,0		--@IsDeliver	
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate								 
				)

				
				update @LineItemTaxDetailStagingTable set ysnTaxExempt = 0
				INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]	
					,[dblBaseRate]		
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,NULL
					,@dblOriginalPrice
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver		
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate								 
				)

				END

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					--DEBUGGER HERE-- 
					SELECT '@tblCFOriginalTax1',* FROM @tblCFOriginalTax --HERE--
					--DEBUGGER HERE-- 
					SELECT '@tblCFCalculatedTax1',* FROM @tblCFCalculatedTax --HERE--
				END
				

				
				IF(@strNetworkType = 'CFN')
				BEGIN
					UPDATE @tblCFOriginalTax 
					SET dblTax = li.dblTax,
						dblAdjustedTax = li.dblAdjustedTax
					FROM @tblCFOriginalTax AS ot
					INNER JOIN @LineItemTaxDetailStagingTable AS li
				    ON ot.intTaxGroupId		= li.intTaxGroupId
					AND ot.intTaxCodeId		= li.intTaxCodeId
					AND ot.intTaxClassId	= li.intTaxClassId
					AND ot.dblRate			= li.dblRate
					WHERE ISNULL(ot.ysnTaxExempt,0) = 0
					AND ISNULL(ot.ysnInvalidSetup,0) = 0
					

					-- UPDATE @tblCFOriginalTaxZeroQuantity 
					-- SET dblTax = (li.dblTax / @dblQuantity) * @dblZeroQuantity,
					-- 	dblAdjustedTax = (li.dblAdjustedTax / @dblQuantity) * @dblZeroQuantity
					-- FROM @tblCFOriginalTaxZeroQuantity AS ct
					-- INNER JOIN @LineItemTaxDetailStagingTable AS li
					-- ON ct.intTaxGroupId		= li.intTaxGroupId
					-- AND ct.intTaxCodeId		= li.intTaxCodeId
					-- AND ct.intTaxClassId	= li.intTaxClassId
					-- AND ct.dblRate			= li.dblRate
					-- WHERE ISNULL(ct.ysnTaxExempt,0) = 0
					-- AND ISNULL(ct.ysnInvalidSetup,0) = 0


					UPDATE @tblCFCalculatedTax 
					SET dblTax = li.dblTax,
						dblAdjustedTax = li.dblAdjustedTax
					FROM @tblCFCalculatedTax AS ct
					INNER JOIN @LineItemTaxDetailStagingTable AS li
					ON ct.intTaxGroupId		= li.intTaxGroupId
					AND ct.intTaxCodeId		= li.intTaxCodeId
					AND ct.intTaxClassId	= li.intTaxClassId
					AND ct.dblRate			= li.dblRate
					WHERE ISNULL(ct.ysnTaxExempt,0) = 0
					AND ISNULL(ct.ysnInvalidSetup,0) = 0


					UPDATE @tblCFCalculatedTaxExempt 
					SET dblTax = li.dblTax,
						dblAdjustedTax = li.dblAdjustedTax
					FROM @tblCFCalculatedTaxExempt AS ct
					INNER JOIN @LineItemTaxDetailStagingTable AS li
					ON ct.intTaxGroupId		= li.intTaxGroupId
					AND ct.intTaxCodeId		= li.intTaxCodeId
					AND ct.intTaxClassId	= li.intTaxClassId
					AND ct.dblRate			= li.dblRate
					WHERE ISNULL(ct.ysnTaxExempt,0) = 1
					AND ISNULL(ct.ysnInvalidSetup,0) = 0


					-- UPDATE @tblCFCalculatedTaxExemptZeroQuantity 
					-- SET dblTax = (li.dblTax / @dblQuantity) * @dblZeroQuantity,
					-- 	dblAdjustedTax = (li.dblAdjustedTax / @dblQuantity) * @dblZeroQuantity
					-- FROM @tblCFCalculatedTaxExemptZeroQuantity AS ct
					-- INNER JOIN @LineItemTaxDetailStagingTable AS li
					-- ON ct.intTaxGroupId		= li.intTaxGroupId
					-- AND ct.intTaxCodeId		= li.intTaxCodeId
					-- AND ct.intTaxClassId	= li.intTaxClassId
					-- AND ct.dblRate			= li.dblRate
					-- WHERE ISNULL(ct.ysnTaxExempt,0) = 1
					-- AND ISNULL(ct.ysnInvalidSetup,0) = 0
					

					-- UPDATE @tblCFCalculatedTaxZeroQuantity 
					-- SET dblTax = (li.dblTax / @dblQuantity) * @dblZeroQuantity,
					-- 	dblAdjustedTax = (li.dblAdjustedTax / @dblQuantity) * @dblZeroQuantity
					-- FROM @tblCFCalculatedTaxZeroQuantity AS ct
					-- INNER JOIN @LineItemTaxDetailStagingTable AS li
					-- ON ct.intTaxGroupId		= li.intTaxGroupId
					-- AND ct.intTaxCodeId		= li.intTaxCodeId
					-- AND ct.intTaxClassId	= li.intTaxClassId
					-- AND ct.dblRate			= li.dblRate
					-- WHERE ISNULL(ct.ysnTaxExempt,0) = 0
					-- AND ISNULL(ct.ysnInvalidSetup,0) = 0
					
					
				END

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					--DEBUGGER HERE-- 
					SELECT '@tblCFOriginalTax2',* FROM @tblCFOriginalTax --HERE--
					--DEBUGGER HERE-- 
					SELECT '@tblCFCalculatedTax2',* FROM @tblCFCalculatedTax --HERE--
				END

				
				--Set tax to 0 for exemption--
				UPDATE @tblCFOriginalTax SET ysnInvalidSetup = 1, dblTax = 0.0, dblAdjustedTax = 0.0 WHERE ysnTaxExempt = 1 AND strNotes LIKE '%has an exemption set for item category%'

				INSERT INTO @tblCFTransactionTax
				(
					 [intTransactionDetailTaxId]	
					,[intInvoiceDetailId]  		
					,[intTaxGroupMasterId]			
					,[intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
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
					,[dblCalculatedTax]
					,[dblOriginalTax]	
				)	
				SELECT 
					 originalTax.intTransactionDetailTaxId
					,originalTax.intTransactionDetailId
					,originalTax.intTaxGroupMasterId
					,originalTax.intTaxGroupId
					,originalTax.intTaxCodeId
					,originalTax.intTaxClassId
					,originalTax.strTaxableByOtherTaxes
					,originalTax.strCalculationMethod
					,originalTax.dblRate
					,originalTax.dblBaseRate
					,originalTax.dblExemptionPercent
					,originalTax.dblTax
					,originalTax.dblAdjustedTax
					,originalTax.intTaxAccountId
					,originalTax.ysnSeparateOnInvoice
					,originalTax.ysnCheckoffTax
					,originalTax.strTaxCode
					,calculatedTax.ysnTaxExempt
					,originalTax.ysnInvalidSetup
					,originalTax.strTaxGroup
					,originalTax.strNotes
					,calculatedTax.dblTax
					,originalTax.dblTax
				FROM @tblCFOriginalTax as originalTax
				INNER JOIN @tblCFCalculatedTax as calculatedTax
				ON originalTax.intTaxGroupId = calculatedTax.intTaxGroupId
				AND originalTax.intTaxCodeId = calculatedTax.intTaxCodeId
				AND originalTax.intTaxClassId = calculatedTax.intTaxClassId

				IF(ISNULL(@DevMode,0) = 1)
				BEGIN
					--DEBUGGER HERE-- 
					SELECT '@tblCFTransactionTax',* FROM @tblCFTransactionTax --HERE--
				END


			END
			ELSE
			BEGIN
				IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('pump price adjustment',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('transfer cost',LOWER(@strPriceBasis)) > 0 
				OR @strPriceMethod = 'Import File Price' 
				OR @strPriceMethod = 'Credit Card' 
				OR @strPriceMethod = 'Posted Trans from CSV'
				OR @strPriceMethod = 'Origin History'
				OR @strPriceMethod = 'Network Cost')
				BEGIN

					IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
					BEGIN
						SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
					END

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]
					,[dblBaseRate]			
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblOriginalPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver	
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate										 
				)
					INSERT INTO @tblCFCalculatedTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]	
					,[dblBaseRate]				
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption -- @DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver		
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate									 
				)

					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
					(
						 [intTaxGroupId]				
						,[intTaxCodeId]					
						,[intTaxClassId]				
						,[strTaxableByOtherTaxes]		
						,[strCalculationMethod]			
						,[dblRate]		
						,[dblBaseRate]	
						,[dblExemptionPercent]			
						,[dblTax]						
						,[dblAdjustedTax]				
						,[intSalesTaxAccountId]    			
						,[ysnCheckoffTax]
						,[ysnTaxExempt]
						,[ysnInvalidSetup]				
						,[strNotes]							
					)	
					SELECT 
						 [intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]		
						,[dblBaseRate]			
						,[dblExemptionPercent]		
						,[dblTax]					
						,[dblAdjustedTax]			
						,[intTaxAccountId]			
						,[ysnCheckoffTax]				
						,[ysnTaxExempt]					
						,[ysnInvalidSetup]				
						,[strNotes]						
					FROM [fnConstructLineItemTaxDetail] 
					(
						 @dblQuantity
						,(@dblPrice * @dblQuantity)
						,@LineItemTaxDetailStagingTable
						,1
						,@intItemId
						,@intCustomerId
						,@intLocationId
						,@intTaxGroupId
						,0
						,@dtmTransactionDate
						,NULL
						,1
						,NULL
						,@companyConfigFreightTermId
						,@intCardId		
						,@intVehicleId
						,1 -- @DisregardExemptionSetup
						,0
						, @intItemUOMId	--intItemUOMId		
						,@intSiteId
						,0		--@IsDeliver			
						,NULL --@CurrencyId
						,NULL -- @CurrencyExchangeRateTypeId
						,NULL -- @@CurrencyExchangeRate							 
					)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END
					

					--SELECT * FROM @tblCFCalculatedTax
					--SELECT * FROM @tblCFOriginalTax

				END
				ELSE IF (LOWER(@strPriceBasis) = 'local index fixed'
				OR @ysnBackoutDueToRouding = 1)
				BEGIN

					IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
					BEGIN
						SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
					END

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]			
					,[dblBaseRate]
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblOriginalPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver		
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate									 
				)
					INSERT INTO @tblCFCalculatedTax	
					(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]	
					,[dblBaseRate]				
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption -- @DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId	
					,@intSiteId
					,0		--@IsDeliver
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate											 
				)
					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
						(
							 [intTaxGroupId]				
							,[intTaxCodeId]					
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]		
							,[strCalculationMethod]			
							,[dblRate]			
							,[dblExemptionPercent]			
							,[dblTax]						
							,[dblAdjustedTax]				
							,[intSalesTaxAccountId]    			
							,[ysnCheckoffTax]
							,[ysnTaxExempt]
							,[ysnInvalidSetup]				
							,[strNotes]							
						)	
						SELECT 
							 [intTaxGroupId]			
							,[intTaxCodeId]				
							,[intTaxClassId]			
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[dblExemptionPercent]		
							,[dblTax]					
							,[dblAdjustedTax]			
							,[intTaxAccountId]			
							,[ysnCheckoffTax]				
							,[ysnTaxExempt]					
							,[ysnInvalidSetup]				
							,[strNotes]						
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,(@dblPrice * @dblQuantity)
							,@LineItemTaxDetailStagingTable
							,1
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,@intTaxGroupId
							,0
							,@dtmTransactionDate
							,NULL
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1 -- @DisregardExemptionSetup
							,0
							, @intItemUOMId	--intItemUOMId	
							,@intSiteId
							,0		--@IsDeliver	
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate																 
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END
				

				END
				ELSE
				BEGIN

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,@dblOriginalPrice
					,@dtmTransactionDate
					,@intLocationId
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId		
					,@intSiteId
					,0		--@IsDeliver			
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate							 
				)
					INSERT INTO @tblCFCalculatedTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]							
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,@dblPrice
					,@dtmTransactionDate
					,@intLocationId
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver	
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate								 
				)
					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
						(
							 [intTaxGroupId]				
							,[intTaxCodeId]					
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]		
							,[strCalculationMethod]			
							,[dblRate]			
							,[dblExemptionPercent]			
							,[dblTax]						
							,[dblAdjustedTax]				
							,[intSalesTaxAccountId]    			
							,[ysnCheckoffTax]
							,[ysnTaxExempt]
							,[ysnInvalidSetup]				
							,[strNotes]							
						)	
						SELECT 
							 [intTaxGroupId]			
							,[intTaxCodeId]				
							,[intTaxClassId]			
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[dblExemptionPercent]		
							,[dblTax]					
							,[dblAdjustedTax]			
							,[intTaxAccountId]			
							,[ysnCheckoffTax]				
							,[ysnTaxExempt]					
							,[ysnInvalidSetup]				
							,[strNotes]							
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,0
							,@LineItemTaxDetailStagingTable
							,0
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,@intTaxGroupId
							,@dblPrice
							,@dtmTransactionDate
							,@intLocationId
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1 --@DisregardExemptionSetup
							,0
							, @intItemUOMId	--intItemUOMId
							,@intSiteId
							,0		--@IsDeliver	
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate														 
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END

				--	SELECT * FROM @tblCFOriginalTax

				END
			
				UPDATE @tblCFOriginalTax SET ysnInvalidSetup = 1, dblTax = 0.0 WHERE ysnTaxExempt = 1 AND strNotes LIKE '%has an exemption set for item category%'

				INSERT INTO @tblCFTransactionTax
				(
					 [intTransactionDetailTaxId]	
					,[intInvoiceDetailId]  		
					,[intTaxGroupMasterId]			
					,[intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
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
					,[dblCalculatedTax]
					,[dblOriginalTax]	
				)	
				SELECT 
					 originalTax.intTransactionDetailTaxId
					,originalTax.intTransactionDetailId
					,originalTax.intTaxGroupMasterId
					,originalTax.intTaxGroupId
					,originalTax.intTaxCodeId
					,originalTax.intTaxClassId
					,originalTax.strTaxableByOtherTaxes
					,originalTax.strCalculationMethod
					,originalTax.dblRate
					,originalTax.dblBaseRate
					,originalTax.dblExemptionPercent
					,originalTax.dblTax
					,originalTax.dblAdjustedTax
					,originalTax.intTaxAccountId
					,originalTax.ysnSeparateOnInvoice
					,originalTax.ysnCheckoffTax
					,originalTax.strTaxCode
					,calculatedTax.ysnTaxExempt
					,originalTax.ysnInvalidSetup
					,originalTax.strTaxGroup
					,originalTax.strNotes
					,calculatedTax.dblTax
					,originalTax.dblTax
				FROM @tblCFOriginalTax as originalTax
				INNER JOIN @tblCFCalculatedTax as calculatedTax
				ON originalTax.intTaxGroupId = calculatedTax.intTaxGroupId
				AND originalTax.intTaxCodeId = calculatedTax.intTaxCodeId
				AND originalTax.intTaxClassId = calculatedTax.intTaxClassId
			END
		END
		ELSE
		BEGIN
			IF (CHARINDEX('retail',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('pump price adjustment',LOWER(@strPriceBasis)) > 0 
				OR CHARINDEX('transfer cost',LOWER(@strPriceBasis)) > 0 
				OR @strPriceMethod = 'Import File Price' 
				OR @strPriceMethod = 'Credit Card' 
				OR @strPriceMethod = 'Posted Trans from CSV'
				OR @strPriceMethod = 'Origin History'
				OR @strPriceMethod = 'Network Cost')
				BEGIN

					
					IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
					BEGIN
						SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
					END

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]
					,[dblBaseRate]			
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblOriginalPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver		
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate									 
				)
					INSERT INTO @tblCFCalculatedTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]	
					,[dblBaseRate]				
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption -- @DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId		
					,@intSiteId
					,0		--@IsDeliver			
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate							 
				)
					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
						(
							 [intTaxGroupId]				
							,[intTaxCodeId]					
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]		
							,[strCalculationMethod]			
							,[dblRate]			
							,[dblExemptionPercent]			
							,[dblTax]						
							,[dblAdjustedTax]				
							,[intSalesTaxAccountId]    			
							,[ysnCheckoffTax]
							,[ysnTaxExempt]
							,[ysnInvalidSetup]				
							,[strNotes]							
						)	
						SELECT 
							 [intTaxGroupId]			
							,[intTaxCodeId]				
							,[intTaxClassId]			
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[dblExemptionPercent]		
							,[dblTax]					
							,[dblAdjustedTax]			
							,[intTaxAccountId]			
							,[ysnCheckoffTax]				
							,[ysnTaxExempt]					
							,[ysnInvalidSetup]				
							,[strNotes]						
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,(@dblPrice * @dblQuantity)
							,@LineItemTaxDetailStagingTable
							,1
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,@intTaxGroupId
							,0
							,@dtmTransactionDate
							,NULL
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1 -- @DisregardExemptionSetup
							,0
							, @intItemUOMId	--intItemUOMId		
							,@intSiteId
							,0		--@IsDeliver	
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate															 
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END

					--SELECT * FROM @tblCFCalculatedTaxExempt
					--SELECT * FROM @tblCFCalculatedTax
					--SELECT * FROM @tblCFOriginalTax

				END
				ELSE IF (LOWER(@strPriceBasis) = 'local index fixed'
				OR @ysnBackoutDueToRouding = 1)
				BEGIN

					IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
					BEGIN
						SELECT @dblPrice = dbo.fnCFForceRounding(@dblPrice)
					END

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]	
					,[dblBaseRate]		
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblOriginalPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver											 
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate
				)
					INSERT INTO @tblCFCalculatedTax	
					(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,(@dblPrice * @dblQuantity)
					,@LineItemTaxDetailStagingTable
					,1
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,0
					,@dtmTransactionDate
					,NULL
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption-- @DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver			
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate							 
				)
					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
							(
							 [intTaxGroupId]				
							,[intTaxCodeId]					
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]		
							,[strCalculationMethod]			
							,[dblRate]			
							,[dblExemptionPercent]			
							,[dblTax]						
							,[dblAdjustedTax]				
							,[intSalesTaxAccountId]    			
							,[ysnCheckoffTax]
							,[ysnTaxExempt]
							,[ysnInvalidSetup]				
							,[strNotes]							
						)	
						SELECT 
							 [intTaxGroupId]			
							,[intTaxCodeId]				
							,[intTaxClassId]			
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[dblExemptionPercent]		
							,[dblTax]					
							,[dblAdjustedTax]			
							,[intTaxAccountId]			
							,[ysnCheckoffTax]				
							,[ysnTaxExempt]					
							,[ysnInvalidSetup]				
							,[strNotes]						
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,(@dblPrice * @dblQuantity)
							,@LineItemTaxDetailStagingTable
							,1
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,@intTaxGroupId
							,0
							,@dtmTransactionDate
							,NULL
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1-- @DisregardExemptionSetup
							,0
							, @intItemUOMId	--intItemUOMId
							,@intSiteId
							,0		--@IsDeliver	
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate															 
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END
					
					

				END
				ELSE
				BEGIN

					INSERT INTO @tblCFOriginalTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]	
					,[dblBaseRate]				
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]						
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,@dblOriginalPrice
					,@dtmTransactionDate
					,@intLocationId
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,1 --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver			
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate								 
				)
					INSERT INTO @tblCFCalculatedTax	
				(
					 [intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnInvalidSetup]				
					,[strNotes]							
				)	
				SELECT 
					 [intTaxGroupId]			
					,[intTaxCodeId]				
					,[intTaxClassId]			
					,[strTaxableByOtherTaxes]	
					,[strCalculationMethod]		
					,[dblRate]		
					,[dblBaseRate]			
					,[dblExemptionPercent]		
					,[dblTax]					
					,[dblAdjustedTax]			
					,[intTaxAccountId]			
					,[ysnCheckoffTax]				
					,[ysnTaxExempt]					
					,[ysnInvalidSetup]				
					,[strNotes]							
				FROM [fnConstructLineItemTaxDetail] 
				(
					 @dblQuantity
					,0
					,@LineItemTaxDetailStagingTable
					,0
					,@intItemId
					,@intCustomerId
					,@intLocationId
					,@intTaxGroupId
					,@dblPrice
					,@dtmTransactionDate
					,@intLocationId
					,1
					,NULL
					,@companyConfigFreightTermId
					,@intCardId		
					,@intVehicleId
					,@ysnApplyTaxExemption --@DisregardExemptionSetup
					,0
					, @intItemUOMId	--intItemUOMId
					,@intSiteId
					,0		--@IsDeliver										 
					,NULL --@CurrencyId
					,NULL -- @CurrencyExchangeRateTypeId
					,NULL -- @@CurrencyExchangeRate
				)
					IF(ISNULL(@ysnApplyTaxExemption,0) = 0)
					BEGIN
						INSERT INTO @tblCFCalculatedTaxExempt	
						(
							 [intTaxGroupId]				
							,[intTaxCodeId]					
							,[intTaxClassId]				
							,[strTaxableByOtherTaxes]		
							,[strCalculationMethod]			
							,[dblRate]			
							,[dblExemptionPercent]			
							,[dblTax]						
							,[dblAdjustedTax]				
							,[intSalesTaxAccountId]    			
							,[ysnCheckoffTax]
							,[ysnTaxExempt]
							,[ysnInvalidSetup]				
							,[strNotes]							
						)	
						SELECT 
							 [intTaxGroupId]			
							,[intTaxCodeId]				
							,[intTaxClassId]			
							,[strTaxableByOtherTaxes]	
							,[strCalculationMethod]		
							,[dblRate]					
							,[dblExemptionPercent]		
							,[dblTax]					
							,[dblAdjustedTax]			
							,[intTaxAccountId]			
							,[ysnCheckoffTax]				
							,[ysnTaxExempt]					
							,[ysnInvalidSetup]				
							,[strNotes]							
						FROM [fnConstructLineItemTaxDetail] 
						(
							 @dblQuantity
							,0
							,@LineItemTaxDetailStagingTable
							,0
							,@intItemId
							,@intCustomerId
							,@intLocationId
							,@intTaxGroupId
							,@dblPrice
							,@dtmTransactionDate
							,@intLocationId
							,1
							,NULL
							,@companyConfigFreightTermId
							,@intCardId		
							,@intVehicleId
							,1 --@DisregardExemptionSetup
							,0
							, @intItemUOMId	--intItemUOMId
							,@intSiteId
							,0		--@IsDeliver	
							,NULL --@CurrencyId
							,NULL -- @CurrencyExchangeRateTypeId
							,NULL -- @@CurrencyExchangeRate															 
						)
						IF(ISNULL(@DevMode,0) = 1)
						BEGIN
						SELECT '@tblCFCalculatedTaxExempt',* FROM @tblCFCalculatedTaxExempt
						END
					END
				

				--	SELECT * FROM @tblCFOriginalTax

				END
			
				UPDATE @tblCFOriginalTax SET ysnInvalidSetup = 1, dblTax = 0.0 WHERE ysnTaxExempt = 1 AND strNotes LIKE '%has an exemption set for item category%'

				INSERT INTO @tblCFTransactionTax
				(
					 [intTransactionDetailTaxId]	
					,[intInvoiceDetailId]  		
					,[intTaxGroupMasterId]			
					,[intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]		
					,[dblBaseRate]	
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
					,[dblCalculatedTax]
					,[dblOriginalTax]	
				)	
				SELECT 
					 originalTax.intTransactionDetailTaxId
					,originalTax.intTransactionDetailId
					,originalTax.intTaxGroupMasterId
					,originalTax.intTaxGroupId
					,originalTax.intTaxCodeId
					,originalTax.intTaxClassId
					,originalTax.strTaxableByOtherTaxes
					,originalTax.strCalculationMethod
					,originalTax.dblRate
					,originalTax.dblBaseRate
					,originalTax.dblExemptionPercent
					,originalTax.dblTax
					,originalTax.dblAdjustedTax
					,originalTax.intTaxAccountId
					,originalTax.ysnSeparateOnInvoice
					,originalTax.ysnCheckoffTax
					,originalTax.strTaxCode
					,calculatedTax.ysnTaxExempt
					,originalTax.ysnInvalidSetup
					,originalTax.strTaxGroup
					,originalTax.strNotes
					,calculatedTax.dblTax
					,originalTax.dblTax
				FROM @tblCFOriginalTax as originalTax
				INNER JOIN @tblCFCalculatedTax as calculatedTax
				ON originalTax.intTaxGroupId = calculatedTax.intTaxGroupId
				AND originalTax.intTaxCodeId = calculatedTax.intTaxCodeId
				AND originalTax.intTaxClassId = calculatedTax.intTaxClassId
			END

		
		---SPECIAL TAX RULE--
				
		DECLARE @tblCFTaxCodeList		TABLE
		(
			 [strTaxCode]				NVARCHAR(MAX) NULL
			,[intTaxCodeId]				INT NULL
			,[strTaxRule]				NVARCHAR(MAX) NULL
			,[intTaxRuleId]				INT NULL
			,[ysnApplyTaxRule]			BIT NULL
		)


		DELETE FROM @tblCFTaxCodeList

		INSERT INTO @tblCFTaxCodeList 
		(strTaxCode,intTaxCodeId)
		SELECT strTaxCode,intTaxCodeId
		FROM @tblCFCalculatedTax

		INSERT INTO @tblCFTaxCodeList 
		(intTaxCodeId,strTaxCode)
		SELECT strTaxCode,intTaxCodeId
		FROM @tblCFOriginalTax 
		WHERE strTaxCode NOT IN 
		(SELECT strTaxCode FROM @tblCFTaxCodeList)


		UPDATE @tblCFTaxCodeList 
		SET 
		 ysnApplyTaxRule = 1
		,strTaxRule = tblCFTaxRules.strDescription
		,intTaxRuleId = tblCFTaxRules.intSpecialTaxingRuleId
		FROM 
		(
		SELECT 
		strDescription, 
		strType, 
		sptrh.intSpecialTaxingRuleId,
		intSiteGroupId,
		intSiteId,
		intTaxCodeId as intTaxId
		FROM tblCFSpecialTaxingRuleHeader as sptrh
		INNER JOIN tblCFSpecialTaxingRuleSite as sptrs
		ON sptrh.intSpecialTaxingRuleId = sptrs.intSpecialTaxingRuleId
		INNER JOIN tblCFSpecialTaxingRuleTax as sptrt
		ON sptrh.intSpecialTaxingRuleId = sptrt.intSpecialTaxingRuleId
		WHERE intSiteId = @intSiteId OR intSiteGroupId = @intSiteGroupId) AS tblCFTaxRules
		WHERE intTaxCodeId = tblCFTaxRules.intTaxId


		--UPDATE ORIGINAL TAX (FROM TAX GROUP) FOR TAXES THAT HAVE SPECIAL TAX RULE --
		UPDATE @tblCFTransactionTax SET 
		[dblOriginalTax] = 0
		WHERE intTaxCodeId IN (SELECT intTaxCodeId FROM @tblCFTaxCodeList WHERE ISNULL(ysnApplyTaxRule,0) = 1)
		--UPDATE ORIGINAL TAX FOR TAXES THAT HAVE SPECIAL TAX RULE --


		---SPECIAL TAX RULE--


		

	END
	ELSE
	BEGIN
				--POSTED TRANSACTION--

				INSERT INTO @tblCFRemoteTax(
				 [intTransactionDetailTaxId]	
				,[intTransactionDetailId]  		
				,[intTaxGroupMasterId]			
				,[intTaxGroupId]				
				,[intTaxCodeId]					
				,[intTaxClassId]				
				,[strTaxableByOtherTaxes]		
				,[strCalculationMethod]			
				,[dblRate]	
				--,[dblBaseRate]					
				,[dblTax]						
				,[dblAdjustedTax]				
				,[intTaxAccountId]    			
				,[ysnSeparateOnInvoice]			
				,[ysnCheckoffTax]				
				,[strTaxCode]					
				,[ysnTaxExempt]			
				,[ysnTaxOnly]
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
				,@FederalExciseTax1				=@FederalExciseTax1	
				,@FederalExciseTax2				=@FederalExciseTax2	
				,@StateExciseTax1				=@StateExciseTax1	
				,@StateExciseTax2				=@StateExciseTax2	
				,@StateExciseTax3				=@StateExciseTax3	
				,@CountyTax1					=@CountyTax1		
				,@CityTax1						=@CityTax1			
				,@StateSalesTax					=@StateSalesTax		
				,@CountySalesTax				=@CountySalesTax	
				,@CitySalesTax					=@CitySalesTax
				,@Tax1							=@Tax1		
				,@Tax2							=@Tax2		
				,@Tax3							=@Tax3		
				,@Tax4							=@Tax4		
				,@Tax5							=@Tax5		
				,@Tax6							=@Tax6		
				,@Tax7							=@Tax7		
				,@Tax8							=@Tax8		
				,@Tax9							=@Tax9		
				,@Tax10							=@Tax10		
				,@TaxValue1						=@TaxValue1	
				,@TaxValue2						=@TaxValue2	
				,@TaxValue3						=@TaxValue3	
				,@TaxValue4						=@TaxValue4	
				,@TaxValue5						=@TaxValue5	
				,@TaxValue6						=@TaxValue6	
				,@TaxValue7						=@TaxValue7	
				,@TaxValue8						=@TaxValue8	
				,@TaxValue9						=@TaxValue9	
				,@TaxValue10					=@TaxValue10

				UPDATE @tblCFRemoteTax SET ysnInvalidSetup = 1 , dblTax = 0.0 WHERE ysnTaxExempt = 1 AND strNotes LIKE '%has an exemption set for item category%'

				INSERT INTO @tblCFTransactionTax
				(
					 [intTransactionDetailTaxId]	
					,[intInvoiceDetailId]  		
					,[intTaxGroupMasterId]			
					,[intTaxGroupId]				
					,[intTaxCodeId]					
					,[intTaxClassId]				
					,[strTaxableByOtherTaxes]		
					,[strCalculationMethod]			
					,[dblRate]			
					,[dblBaseRate]
					,[dblExemptionPercent]			
					,[dblTax]						
					,[dblAdjustedTax]				
					,[intSalesTaxAccountId]    			
					,[ysnSeparateOnInvoice]			
					,[ysnCheckoffTax]				
					,[strTaxCode]					
					,[ysnTaxExempt]	
					,[ysnTaxOnly]		
					,[ysnInvalidSetup]				
					,[strTaxGroup]					
					,[strNotes]			
					,[dblCalculatedTax]
					,[dblOriginalTax]	
				)	
				SELECT 
					 intTransactionDetailTaxId
					,intTransactionDetailId
					,intTaxGroupMasterId
					,intTaxGroupId
					,intTaxCodeId
					,intTaxClassId
					,strTaxableByOtherTaxes
					,strCalculationMethod
					,0
					,0
					,dblExemptionPercent
					,dblTax
					,dblAdjustedTax
					,intTaxAccountId
					,ysnSeparateOnInvoice
					,ysnCheckoffTax
					,strTaxCode
					,ysnTaxExempt
					,[ysnTaxOnly]
					,0
					,strTaxGroup
					,strNotes
					,dblRate
					,dblRate
				FROM @tblCFRemoteTax
				WHERE (intTaxClassId IS NOT NULL AND intTaxClassId > 0)
				AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)


				--SELECT * FROM @tblCFRemoteTax
				
				---------------------------------------------------
				--				LOG INVALID TAX SETUP			 --
				---------------------------------------------------
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
						,'Importing'
						,@runDate
						,ISNULL(strReason,'Invalid Setup -' + strTaxCode)
						,@guid
					FROM @tblCFRemoteTax
					WHERE (intTaxClassId IS NULL OR intTaxClassId = 0)
				AND (intTaxCodeId IS NULL OR intTaxCodeId = 0)
				END
	END
	

	--SELECT * FROM @tblCFBackoutTax
	--SELECT * FROM @tblCFCalculatedTax
	--SELECT * FROM @tblCFOriginalTax
	--SELECT * FROM @tblCFRemoteTax
	--SELECT * FROM @tblCFTransactionTax

	--SET @ysnBackoutDueToRouding = 0

	---------------------------------------------------
	--				TAX COMPUTATION					 --
	---------------------------------------------------


	--SELECT * FROM @tblCFRemoteTax
	--SELECT * FROM @tblCFCalculatedTax
	--SELECT * FROM @tblCFOriginalTax




	---------------------------------------------------
	--				 PRICE CALCULATION				 --
	---------------------------------------------------
	DECLARE @totalCalculatedTax					NUMERIC(18,6) = 0
	DECLARE @totalOriginalTax					NUMERIC(18,6) = 0
	DECLARE @totalCalculatedTaxExempt			NUMERIC(18,6) = 0

	SELECT 
	 @totalCalculatedTax = ISNULL(SUM(dblCalculatedTax),0)
	,@totalOriginalTax = ISNULL(SUM(dblOriginalTax),0)
	FROM
	@tblCFTransactionTax
	WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL

	SELECT 
	 @totalCalculatedTaxExempt = ISNULL(SUM(cftx.dblTax),0)
	FROM
	@tblCFTransactionTax as cft
	INNER JOIN @tblCFCalculatedTaxExempt as cftx
	ON cft.intTaxClassId = cftx.intTaxClassId
	AND cft.intTaxCodeId = cftx.intTaxCodeId
	WHERE cft.ysnTaxExempt = 1 AND 
	(cft.ysnInvalidSetup = 0 OR cft.ysnInvalidSetup IS NULL)
	

	SET @dblGrossTransferCost = ISNULL(@dblTransferCost,0)
	SET @dblNetTransferCost = ISNULL(@dblGrossTransferCost,0) - (ISNULL(@totalOriginalTax,0) / ISNULL(@dblQuantity,0))
	SET @dblAdjustments = ISNULL(@dblPriceProfileRate,0)+ ISNULL(@dblAdjustmentRate	,0)
	SET @dblAdjustmentWithIndex = ISNULL(@dblPriceProfileRate,0) + ISNULL(@dblPriceIndexRate,0)	+ ISNULL(@dblAdjustmentRate	,0)
	

	--select * from @tblCFTransactionTax

	DECLARE @tblTransactionPrice TABLE(
		 strTransactionPriceId		NVARCHAR(MAX)
		,dblOriginalAmount			NUMERIC(18,6)
		,dblCalculatedAmount		NUMERIC(18,6)
	)

	IF (@strPriceMethod = 'Import File Price' 
	OR @strPriceMethod = 'Credit Card' 
	OR @strPriceMethod = 'Posted Trans from CSV'
	OR @strPriceMethod = 'Origin History')
		BEGIN

			DECLARE @dblImportFileGrossPrice NUMERIC(18,6)
			SET @dblImportFileGrossPrice =  ROUND (Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax) / @dblQuantity, 6) + ISNULL(@dblAdjustments,0) + ROUND((ISNULL(@totalCalculatedTax,0) / @dblQuantity),6),6)

			IF(ISNULL(@ysnForceRounding,0) = 1) 
			BEGIN
				SELECT @dblImportFileGrossPrice = dbo.fnCFForceRounding(@dblImportFileGrossPrice)
			END

			INSERT INTO @tblTransactionPrice (strTransactionPriceId	
				,dblOriginalAmount		
				,dblCalculatedAmount	
			)
			VALUES
			(
				 'Gross Price'
				,@dblOriginalPrice
				,@dblImportFileGrossPrice
			),
			(
				 'Net Price'
				 ,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax) / @dblQuantity, 6)
				 ,ROUND(((Round((@dblImportFileGrossPrice * @dblQuantity),2) - (ISNULL(@totalCalculatedTax,0)) ) / @dblQuantity),6)
				--,ROUND((((@dblImportFileGrossPrice * @dblQuantity) - (@totalCalculatedTaxExempt + @totalCalculatedTax) ) / @dblQuantity),6)
			),
			(
				 'Total Amount'
				,ROUND(@dblOriginalPrice * @dblQuantity,2)
				,ROUND((@dblImportFileGrossPrice * @dblQuantity),2)
			)

		END
	ELSE IF @strPriceMethod = 'Network Cost'
	BEGIN

	--Original Net Price = Round( (Round(Gross Transfer Cost * Quantity,2) - Original Taxes) / Quantity, 6)
	--Calc Gross Price = Gross Transfer Cost
	--Calc Net Price = Round( (Round(Gross Transfer Cost * Quantity,2) - (Calc Taxes) )/ Quantity,6)

 
	DECLARE @dblNetworkCostGrossPrice NUMERIC(18,6)
	SET @dblNetworkCostGrossPrice = ISNULL(@TransferCost,0)
	SET @dblImportFileGrossPrice = @dblNetworkCostGrossPrice --ROUND((ISNULL(@TransferCost,0) - (ISNULL(@totalOriginalTax,0) / @dblQuantity)) + ISNULL(@dblAdjustments,0) + (ISNULL(@totalCalculatedTax,0) / @dblQuantity) , 6)
 
	IF(ISNULL(@ysnForceRounding,0) = 1) 
	BEGIN
	SELECT @dblImportFileGrossPrice = dbo.fnCFForceRounding(@dblImportFileGrossPrice)
	END
 
	INSERT INTO @tblTransactionPrice (strTransactionPriceId 
	,dblOriginalAmount 
	,dblCalculatedAmount 
	)
	VALUES
	(
	'Gross Price'
	,@dblNetworkCostGrossPrice
	,@dblImportFileGrossPrice
	),
	(
	'Net Price'
	,ROUND(((ROUND((@dblNetworkCostGrossPrice * @dblQuantity),2) - (ISNULL(@totalOriginalTax,0))) / @dblQuantity),6)
	--,ROUND((((@dblImportFileGrossPrice * @dblQuantity) - (@totalCalculatedTaxExempt + @totalCalculatedTax) ) / @dblQuantity),6)
	,ROUND(((ROUND((@dblImportFileGrossPrice * @dblQuantity),2) - (ISNULL(@totalCalculatedTax,0))) / @dblQuantity),6)
	),
	(
	'Total Amount'
	,ROUND(@dblNetworkCostGrossPrice * @dblQuantity,2)
	,ROUND((@dblImportFileGrossPrice * @dblQuantity),2)
	)
 
	END
	ELSE IF (LOWER(@strPriceBasis) = 'local index cost' OR LOWER(@strPriceBasis) = 'remote index cost'  )
		BEGIN

		DECLARE @dblLocalIndexCostGrossPrice NUMERIC(18,6)
		SET @dblLocalIndexCostGrossPrice = Round((@dblAdjustmentWithIndex + ROUND((@totalCalculatedTax / @dblQuantity),6)),6)

		IF(ISNULL(@ysnForceRounding,0) = 1) 
		BEGIN
			SELECT @dblLocalIndexCostGrossPrice = dbo.fnCFForceRounding(@dblLocalIndexCostGrossPrice)
		END


		--Original Net Price = Round( (Round(Original Gross Price * Quantity,2) - Original Taxes) / Quantity, 6)
		--Calc Gross Price = Round(Index Cost + Profile Rate + Group Adjustment Rate + Round(Calc Taxes / Quantity,6) ,6) + .009 Rounding
		--Calc Net Price = Round( (Round(Calc Gross Price * Quantity,2) - (Calc Taxes) )/ Quantity,6)
		
		INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblLocalIndexCostGrossPrice
		),
		(
			 'Net Price'
			,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax ) / @dblQuantity, 6) 
			,Round((Round((@dblLocalIndexCostGrossPrice * @dblQuantity),2) -  (ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
			--,Round(((@dblLocalIndexCostGrossPrice * @dblQuantity) -  (ISNULL(@totalCalculatedTaxExempt,0) + ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
		),
		(
			 'Total Amount'
			,ROUND(@dblOriginalPrice * @dblQuantity,2)
			,ROUND((@dblLocalIndexCostGrossPrice * @dblQuantity),2)
		)

	END
	ELSE IF (LOWER(@strPriceBasis) = 'local index retail' )
		BEGIN

		DECLARE @dblLocalIndexRetailGrossPrice NUMERIC(18,6)
		SET @dblLocalIndexRetailGrossPrice = Round((@dblAdjustmentWithIndex - ROUND((@totalCalculatedTaxExempt / @dblQuantity),6)),6)

		IF(ISNULL(@ysnForceRounding,0) = 1) 
		BEGIN
			SELECT @dblLocalIndexRetailGrossPrice = dbo.fnCFForceRounding(@dblLocalIndexRetailGrossPrice)
		END

		--Original Net Price = Round( (Round(Original Gross Price * Quantity,2) - Original Taxes) / Quantity, 6)
	--	Calc Gross Price = Round(Index Price + Profile Rate + Group Adjustment Rate - Round(Calc Exempt Taxes / Quantity,6) , 6) + .009 Rounding
		--Calc Net Price = Round( (Round(Calc Gross Price * Quantity,2) - (Calc Taxes) )/ Quantity,6)
		
		INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblLocalIndexRetailGrossPrice
		),
		(
			 'Net Price'
			,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax ) / @dblQuantity, 6) 
			,Round((Round((@dblLocalIndexRetailGrossPrice * @dblQuantity),2) -  (ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
			--,Round(((@dblLocalIndexRetailGrossPrice * @dblQuantity) -  (ISNULL(@totalCalculatedTaxExempt,0) + ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
		),
		(
			 'Total Amount'
			,ROUND(@dblOriginalPrice * @dblQuantity,2)
			,ROUND((@dblLocalIndexRetailGrossPrice * @dblQuantity),2)
		)

	END
	ELSE IF (LOWER(@strPriceBasis) = 'local index fixed')
		BEGIN

		DECLARE @dblLocalIndexFixedGrossPrice NUMERIC(18,6)
		SET @dblLocalIndexFixedGrossPrice = ROUND(@dblAdjustmentWithIndex,6)

		IF(ISNULL(@ysnForceRounding,0) = 1) 
		BEGIN
			SELECT @dblLocalIndexFixedGrossPrice = dbo.fnCFForceRounding(@dblLocalIndexFixedGrossPrice)
		END


		--Original Net Price = Round( (Round(Original Gross Price * Quantity,2) - Original Taxes) / Quantity, 6)
		--Calc Gross Price = Round(Index Cost + Profile Rate + Group Adjustment Rate,6) + .009 Rounding
		--Calc Net Price = Round( (Round(Calc Gross Price * Quantity,2) - (Calc Taxes) )/ Quantity,6)

		INSERT INTO @tblTransactionPrice (
		 strTransactionPriceId	
		,dblOriginalAmount		
		,dblCalculatedAmount	
		)
		VALUES
		(
			 'Gross Price'
			,@dblOriginalPrice
			,@dblLocalIndexFixedGrossPrice
		),
		(
			 'Net Price'
			,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax ) / @dblQuantity, 6) 
			,Round((Round((@dblLocalIndexFixedGrossPrice * @dblQuantity),2) -  (ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
			--,Round(((@dblLocalIndexFixedGrossPrice * @dblQuantity) -  (ISNULL(@totalCalculatedTaxExempt,0) + ISNULL(@totalCalculatedTax,0))) / @dblQuantity,6)
		),
		(
			 'Total Amount'
			,ROUND(@dblOriginalPrice * @dblQuantity,2)
			,ROUND((@dblLocalIndexFixedGrossPrice * @dblQuantity),2)
		)
	END
	ELSE IF (CHARINDEX('pump price adjustment',LOWER(@strPriceBasis)) > 0)
	BEGIN
		IF (@strTransactionType = 'Extended Remote' OR @strTransactionType = 'Local/Network')
		BEGIN

			DECLARE @dblPumpPriceAdjustmentGrossPrice NUMERIC(18,6)
			--SET @dblPumpPriceAdjustmentGrossPrice =  ROUND (Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax) / @dblQuantity, 6) + ISNULL(@dblAdjustments,0) + ROUND((ISNULL(@totalCalculatedTax,0) / @dblQuantity),6),6)

			SET @dblPumpPriceAdjustmentGrossPrice = Round(((@dblAdjustments +  @dblOriginalPrice)- ROUND((@totalCalculatedTaxExempt / @dblQuantity),6)),6)
			--Calc Gross Price = Round(Orig Gross Price + Profile Rate + Group Adjustment Rate - Round(Calc Exempt Taxes / Quantity,6) , 6) + .009 Rounding


			IF(ISNULL(@ysnForceRounding,0) = 1) 
			BEGIN
				SELECT @dblPumpPriceAdjustmentGrossPrice = dbo.fnCFForceRounding(@dblPumpPriceAdjustmentGrossPrice)
			END

			INSERT INTO @tblTransactionPrice (strTransactionPriceId	
				,dblOriginalAmount		
				,dblCalculatedAmount	
			)
			VALUES
			(
				 'Gross Price'
				,@dblOriginalPrice
				,@dblPumpPriceAdjustmentGrossPrice
			),
			(
				 'Net Price'
				 ,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax) / @dblQuantity, 6)
				 ,ROUND(((Round((@dblPumpPriceAdjustmentGrossPrice * @dblQuantity),2) - (ISNULL(@totalCalculatedTax,0)) ) / @dblQuantity),6)
				--,ROUND((((@dblPumpPriceAdjustmentGrossPrice * @dblQuantity) - (@totalCalculatedTaxExempt + @totalCalculatedTax) ) / @dblQuantity),6)
			),
			(
				 'Total Amount'
				,ROUND(@dblOriginalPrice * @dblQuantity,2)
				,ROUND((@dblPumpPriceAdjustmentGrossPrice * @dblQuantity),2)
			)
			
		END
	END
	ELSE IF (CHARINDEX('transfer cost',LOWER(@strPriceBasis)) > 0 )
	BEGIN
		IF (@strTransactionType = 'Remote' OR @strTransactionType = 'Extended Remote' OR @strTransactionType = 'Local/Network')
		BEGIN
			
			DECLARE @dblTransferCostGrossPrice NUMERIC(18,6)
			SET @dblTransferCostGrossPrice = ROUND(ISNULL(@dblNetTransferCost,0) + ISNULL(@dblAdjustments,0) + Round((ISNULL(@totalCalculatedTax,0) / @dblQuantity),6) , 6)

			IF(ISNULL(@ysnForceRounding,0) = 1) 
			BEGIN
				SELECT @dblTransferCostGrossPrice = dbo.fnCFForceRounding(@dblTransferCostGrossPrice)
			END


			INSERT INTO @tblTransactionPrice (
				 strTransactionPriceId	
				,dblOriginalAmount		
				,dblCalculatedAmount	
			)
			VALUES
			(
				 'Gross Price'
				,@dblGrossTransferCost
				,@dblTransferCostGrossPrice
			),
			(
				 'Net Price'
				,@dblNetTransferCost
				,ROUND(((Round((@dblTransferCostGrossPrice * @dblQuantity),2) - (ISNULL(@totalCalculatedTax,0)) ) / @dblQuantity),6)
				--,ROUND((((@dblTransferCostGrossPrice * @dblQuantity) - (@totalCalculatedTaxExempt + @totalCalculatedTax) ) / @dblQuantity),6)
					

			),
			(
				 'Total Amount'
				,ROUND(@dblGrossTransferCost * @dblQuantity,2)
				,ROUND((@dblTransferCostGrossPrice * @dblQuantity),2)
			)
		END
	END
	ELSE
		BEGIN

		IF(@strPriceMethod = 'Price Profile' AND ISNULL(@ysnForceRounding,0) = 1) 
		BEGIN
			SELECT @dblPrice = dbo.fnCFForceRounding((@dblPrice + (@totalCalculatedTax / @dblQuantity)))
			SET @ysnBackoutDueToRouding  = 1
			SET @ysnForceRounding = 0

			------CLEAN TAX TABLE--------
			 DELETE FROM @tblCFOriginalTax				
			 DELETE FROM @tblCFCalculatedTax				
			 DELETE FROM @tblCFTransactionTax			
			 DELETE FROM @tblCFBackoutTax				
			 DELETE FROM @tblCFRemoteTax					
			 DELETE FROM @LineItemTaxDetailStagingTable


			GOTO TAXCOMPUTATION
		END
		ELSE
		BEGIN

		--Contracts (Local/Network)
		--Calc Net Price  = Contract Price
		--Special Pricing (Local/Network)
		--Calc Net Price = Special Pricing Price
		--Inventory Pricing (Local/Network)
		--Calc Net Price = Inventory Price
		--Calc Gross Price = Calc Net Price + Round(Calc Taxes / Quantity, 6)

			INSERT INTO @tblTransactionPrice (
			 strTransactionPriceId	
			,dblOriginalAmount		
			,dblCalculatedAmount	
			)
			VALUES
			(
				 'Gross Price'
				,@dblOriginalPrice
				,@dblPrice + Round((@totalCalculatedTax / @dblQuantity) ,6)
			),
			(
				 'Net Price'
				,Round((Round(@dblOriginalPrice * @dblQuantity,2) - @totalOriginalTax ) / @dblQuantity, 6)  --@dblOriginalPrice - (@totalOriginalTax / @dblQuantity)
				,@dblPrice
			),
			--OLD WAY--
			--(
			--	 'Net Price'
			--	,@dblOriginalPrice - (@totalOriginalTax / @dblQuantity)
			--	,@dblPrice
			--),
			(
				 'Total Amount'
				,ROUND(@dblOriginalPrice * @dblQuantity,2)
				--,ROUND((@dblPrice + Round((@totalCalculatedTax / @dblQuantity) ,6)) * @dblQuantity,2)

				,ROUND(@dblPrice * @dblQuantity,2) + @totalCalculatedTax
			)
		END
	END

	
	---------------------------------------------------
	--				 PRICE CALCULATION				 --
	---------------------------------------------------



	---------------------------------------------------
	--				MARGIN COMPUTATION				 --
	---------------------------------------------------
	DECLARE @dblMargin			NUMERIC(18,6)
	DECLARE @dblInventoryCost	NUMERIC(18,6)
	DECLARE @dblMarginNetPrice	NUMERIC(18,6)

	
	SELECT TOP 1 @dblMarginNetPrice = dblCalculatedAmount 
	FROM @tblTransactionPrice 
	WHERE strTransactionPriceId = 'Net Price'


	IF (@strTransactionType = 'Remote' OR @strTransactionType = 'Extended Remote')
	BEGIN
		SET @dblMargin = ISNULL(@dblMarginNetPrice,0) - ISNULL(@dblNetTransferCost,0)
	END
	ELSE
	BEGIN
		--SELECT TOP 1 @dblInventoryCost = ISNULL(arSalesAnalysisReport.dblUnitCost ,0)
		--FROM tblCFTransaction AS cfTransaction
		--		INNER JOIN tblARInvoice AS arInvoice
		--		ON cfTransaction.intInvoiceId = arInvoice.intInvoiceId
		--		INNER JOIN vyuARSalesAnalysisReport AS arSalesAnalysisReport
		--		ON arInvoice.intInvoiceId = arSalesAnalysisReport.intTransactionId
		--		WHERE cfTransaction.intTransactionId = @intTransactionId

		SELECT
		@dblInventoryCost = dblAverageCost
		FROM vyuICGetItemPricing 
		WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

		SET @dblMargin = ISNULL(@dblMarginNetPrice,0) - ISNULL(@dblInventoryCost,0)
	END


	---------------------------------------------------
	--				MARGIN COMPUTATION				 --
	---------------------------------------------------

	---------------------------------------------------
	--				LOG DUPLICATE TRANS				 --
	---------------------------------------------------
	DECLARE @intDupTransCount INT = 0
	DECLARE @ysnDuplicate BIT = 0
	DECLARE @ysnInvalid	BIT = 0
	DECLARE @intParentId INT = 0

	SELECT @intDupTransCount = COUNT(*)
	FROM tblCFTransaction
	WHERE intNetworkId = @intNetworkId
	AND intSiteId = @intSiteId
	AND dtmTransactionDate = @dtmTransactionDate
	AND intCardId = @intCardId
	AND intProductId = @ProductId
	AND intPumpNumber = @PumpId
	AND intTransactionId != @intTransactionId
	AND (intOverFilledTransactionId IS NULL OR intOverFilledTransactionId = 0)

	SELECT TOP 1 @intParentId = intOverFilledTransactionId 
	FROM tblCFTransaction 
	WHERE intTransactionId = @intTransactionId

	IF(@intDupTransCount > 0 AND ISNULL(@intParentId,0) = 0)
	BEGIN
		--SET @ysnInvalid = 1
		SET @ysnDuplicate = 1
		IF(@ysnDuplicate = 1)
		BEGIN
			--SET @ysnInvalid = 1
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@runDate,@guid, @intTransactionId, 'Duplicate transaction history found.')
		END
	END


	---------------------------------------------------
	--				LOG DUPLICATE TRANS				 --
	---------------------------------------------------

	DECLARE @intItemLocation INT

	SELECT TOP 1 @intItemLocation = intItemLocationId
	FROM tblICItemLocation WHERE intItemId = @intItemId AND intLocationId = @intLocationId

	IF(ISNULL(@intItemLocation,0) = 0)
	BEGIN
		INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'Item does not have setup for specified site location.')
		SET @ysnInvalid = 1
	END

	DECLARE @ysnVehicleRequire BIT = 0

	IF (@intCardId = 0)
	BEGIN
		SET @intCardId = NULL
	END
	ELSE
	BEGIN
		SELECT TOP 1 
			@ysnVehicleRequire = a.ysnVehicleRequire
		FROM tblCFCard as c
		INNER JOIN tblCFAccount as a
		ON c.intAccountId = a.intAccountId
		WHERE intCardId = @intCardId
	END

	IF(@intProductId = 0 OR @intProductId IS NULL)
	BEGIN
		SET @ysnInvalid = 1
	END
	IF(@intCardId = 0 OR @intCardId IS NULL)
	BEGIN
		IF (@TransactionType != 'Foreign Sale')
		BEGIN
			SET @ysnInvalid = 1
		END
	END
	IF(@intNetworkId = 0 OR @intNetworkId IS NULL)
	BEGIN
		SET @intNetworkId = NULL
		SET @ysnInvalid = 1
	END
	IF(@intSiteId = 0 OR @intSiteId IS NULL)
	BEGIN
		SET @intSiteId = NULL
		SET @ysnInvalid = 1
	END
	IF(@intCardId = 0 OR @intCardId IS NULL)
	BEGIN
		SET @intCardId = NULL
		IF (@TransactionType != 'Foreign Sale')
		BEGIN
			SET @ysnInvalid = 1
		END
	END
	IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
	BEGIN
		SET @ysnInvalid = 1
	END
	IF(@intVehicleId = 0 OR @intVehicleId IS NULL)
	BEGIN
		SET @intVehicleId = NULL
		IF(@ysnVehicleRequire = 1)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'Vehicle is required.')
			SET @ysnInvalid = 1
		END
	END

	---------------------------------------------------
	--					ZERO PRICING				 --
	---------------------------------------------------
	IF (ISNULL(@ysnCaptiveSite,0) = 0)
	BEGIN

		DECLARE @dblCalculatedPricing NUMERIC(18,6)
		SELECT TOP 1 @dblCalculatedPricing = dblCalculatedAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Net Price'
		IF (@dblCalculatedPricing IS NULL OR @dblCalculatedPricing <= 0)
		BEGIN		
			SET @ysnInvalid = 1
			--UPDATE tblCFTransaction SET ysnInvalid = 1 WHERE intTransactionId = @intTransactionId
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'Invalid calculated price.')
		END

	
		DECLARE @dblOriginalPricing NUMERIC(18,6)
		SELECT TOP 1 @dblOriginalPricing = dblOriginalAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Net Price'
		IF (@dblOriginalPricing IS NULL OR @dblOriginalPricing <= 0)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'Invalid original price.')
		END

	END
	---------------------------------------------------
	--					ZERO PRICING				 --
	---------------------------------------------------


	IF (ISNULL(@ysnActive,0) = 0)
	BEGIN

			SET @ysnInvalid = 1
			--UPDATE tblCFTransaction SET ysnInvalid = 1 WHERE intTransactionId = @intTransactionId
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'Customer is invalid.')

	END


	--IF (ISNULL(@ysnInvalid,0) = 0)
	--BEGIN
	--	SET @dblTransferCost = @dblCalculatedCost -- calculated based on transaction type. (margin calc)

	--END
	IF(ISNULL(@BatchRecalculate,0) = 1)
	BEGIN

		BEGIN TRY

			

			DECLARE @ysnContractOverfill	AS BIT = 0
			DECLARE @dblOverfillQuantity	AS NUMERIC(18,6)

			DECLARE @strOldPriceMethod		AS NVARCHAR(MAX)
			DECLARE @dblOldQuantity			AS NUMERIC(18,6)
			DECLARE @intOldContractId		AS INT 
			DECLARE @intOldContractDetailId	AS INT 

			BEGIN TRANSACTION


			SELECT TOP 1
			 @strOldPriceMethod			= strPriceMethod
			,@dblOldQuantity			= dblQuantity	
			,@intOldContractId			= intContractId
			,@intOldContractDetailId	= intContractDetailId
			FROM tblCFTransaction
			WHERE intTransactionId = @TransactionId	


			IF(@strOldPriceMethod = 'Contracts' OR @strOldPriceMethod = 'Contract Pricing')
			BEGIN
				-- 1-1 
				IF(@strPriceMethod = 'Contracts' OR @strPriceMethod = 'Contract Pricing')
				BEGIN
					--1-1.1
					IF(@intOldContractId != @intContractDetailId)
					BEGIN
						SET @dblOldQuantity = @dblOldQuantity * -1
						EXEC uspCTUpdateScheduleQuantity 
						 @intContractDetailId = @intOldContractDetailId
						,@dblQuantityToUpdate = @dblOldQuantity
						,@intUserId = 0
						,@intExternalId = @TransactionId
						,@strScreenName = 'Card Fueling Transaction Screen'

						
						IF(@dblAvailableQuantity < @dblQuantity)
						BEGIN
							--TODO: CREATE OVERFILL--
							SET @ysnContractOverfill = 1
							SET @dblOverfillQuantity = @dblQuantity - @dblAvailableQuantity
							SET @dblQuantity = @dblAvailableQuantity

							EXEC uspCTUpdateScheduleQuantity 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblAvailableQuantity
							,@intUserId = 0
							,@intExternalId = @TransactionId
							,@strScreenName = 'Card Fueling Transaction Screen'
						END
						ELSE
						BEGIN
							EXEC uspCTUpdateScheduleQuantity 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblQuantity
							,@intUserId = 0
							,@intExternalId = @TransactionId
							,@strScreenName = 'Card Fueling Transaction Screen'
						END
					END
					--ELSE 
					-- DO NOTHING SINCE QTY WILL NOT CHANGE
				END
				-- 1-0
				ELSE
				BEGIN
					SET @dblOldQuantity = @dblOldQuantity * -1
					EXEC uspCTUpdateScheduleQuantity 
						@intContractDetailId = @intOldContractDetailId
					,@dblQuantityToUpdate = @dblOldQuantity
					,@intUserId = 0
					,@intExternalId = @TransactionId
					,@strScreenName = 'Card Fueling Transaction Screen'
				END
			END
			ELSE
			--0-1
			BEGIN
				IF(@strPriceMethod = 'Contracts' OR @strPriceMethod = 'Contract Pricing')
				BEGIN
						IF(@dblAvailableQuantity < @dblQuantity)
						BEGIN
							--TODO: CREATE OVERFILL--
							SET @ysnContractOverfill = 1
							SET @dblOverfillQuantity = @dblQuantity - @dblAvailableQuantity
							SET @dblQuantity = @dblAvailableQuantity

							EXEC uspCTUpdateScheduleQuantity 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblAvailableQuantity
							,@intUserId = 0
							,@intExternalId = @TransactionId
							,@strScreenName = 'Card Fueling Transaction Screen'
						END
						ELSE
						BEGIN
							
							EXEC uspCTUpdateScheduleQuantity 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblQuantity
							,@intUserId = 0
							,@intExternalId = @TransactionId
							,@strScreenName = 'Card Fueling Transaction Screen'
						END
				END
				--ELSE 
				-- DO NOTHING SINCE ITS NOT CONTRACT
				
			END


			--IF()

			DECLARE @dblCalculatedGrossPrice AS NUMERIC(18,6)
			SELECT TOP 1 @dblCalculatedGrossPrice = dblCalculatedAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Gross Price'

			DECLARE @dblOriginalGrossPrice AS NUMERIC(18,6)
			SELECT TOP 1 @dblOriginalGrossPrice = dblOriginalAmount FROM @tblTransactionPrice WHERE strTransactionPriceId = 'Gross Price'

			UPDATE @tblTransactionPrice 
			SET 
			dblCalculatedAmount = ROUND((@dblCalculatedGrossPrice * @dblQuantity),2) 
			,dblOriginalAmount = ROUND((@dblOriginalGrossPrice * @dblQuantity),2)
			WHERE strTransactionPriceId = 'Total Amount'
			
			--UPDATE @tblTransactionPrice SET dblOriginalAmount = ROUND((@dblOriginalGrossPrice * @dblQuantity),2) WHERE strTransactionPriceId = 'Total Amount'


			
			---------------------------------------------------------------------------
			UPDATE tblCFTransaction
			SET
			 dblTransferCost		   = @dblTransferCost		
			,strPriceMethod			   = @strPriceMethod		
			,intContractId			   = @intContractHeaderId
			,intContractDetailId	   = @intContractDetailId
			,strPriceBasis			   = @strPriceBasis			
			,intPriceProfileId		   = @intPriceProfileId		
			,intPriceIndexId 		   = @intPriceIndexId 		
			,dblPriceProfileRate	   = @dblPriceProfileRate
			,dblPriceIndexRate		   = @dblPriceIndexRate		
			,dtmPriceIndexDate		   = @dtmPriceIndexDate		
			,ysnDuplicate			   = @ysnDuplicate			
			,ysnInvalid				   = @ysnInvalid	
			,dblQuantity			   = @dblQuantity
			,intSiteGroupId			   = @intSiteGroupId
			WHERE intTransactionId	   = @intTransactionId
			---------------------------------------------------------------------------
			DELETE tblCFTransactionTax WHERE intTransactionId = @intTransactionId
			INSERT INTO tblCFTransactionTax
			(
				 dblTaxCalculatedAmount
				,dblTaxOriginalAmount
				,intTaxCodeId
				,dblTaxRate 
				,intTransactionId
			)
			SELECT 
				dblCalculatedTax AS 'dblTaxCalculatedAmount'
				,dblOriginalTax AS 'dblTaxOriginalAmount'
				,intTaxCodeId
				,dblRate AS 'dblTaxRate'
				,intTransactionId = @intTransactionId
			FROM @tblCFTransactionTax AS T
			WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL
			---------------------------------------------------------------------------
			DELETE tblCFTransactionPrice WHERE intTransactionId = @intTransactionId
			INSERT INTO tblCFTransactionPrice
			(
			strTransactionPriceId
			,dblOriginalAmount
			,dblCalculatedAmount
			,intTransactionId
			)
			SELECT 
			[strTransactionPriceId]
			,[dblOriginalAmount]	
			,[dblCalculatedAmount]
			,@intTransactionId
			FROM @tblTransactionPrice

			---------------------------------------------------------------------------

			DECLARE @strNewPriceMethod AS NVARCHAR(MAX)
			DECLARE @dblNewTotalAmount AS NUMERIC(18,6)

			SELECT TOP 1
			@strNewPriceMethod = cfTrans.strPriceMethod
			,@dblNewTotalAmount = cfTransPrice.dblCalculatedAmount
			FROM tblCFTransaction cfTrans
			LEFT OUTER JOIN 
			(SELECT   intTransactionPriceId, intTransactionId, strTransactionPriceId, dblOriginalAmount, dblCalculatedAmount, intConcurrencyId
			FROM         dbo.tblCFTransactionPrice 
			WHERE     (strTransactionPriceId = 'Total Amount')) AS cfTransPrice 
			ON cfTrans.intTransactionId = cfTransPrice.intTransactionId
			WHERE cfTrans.intTransactionId = @intTransactionId

			UPDATE tblCFBatchRecalculateStagingTable 
			SET strNewPriceMethod = @strNewPriceMethod 
			,dblNewTotalAmount = @dblNewTotalAmount 
			,strStatus = 'Done'
			WHERE intTransactionId = @intTransactionId

			COMMIT TRANSACTION


			IF(@ysnContractOverfill = 1)
			BEGIN

				--TODO-- DUPLICATE PRICING AND TAXING
				INSERT INTO tblCFTransaction
				(
				 intPriceIndexId
				,intPriceProfileId
				,intSiteGroupId
				,strPriceProfileId
				,strPriceIndexId
				,strSiteGroup
				,dblPriceProfileRate
				,dblPriceIndexRate
				,dtmPriceIndexDate
				,intContractDetailId
				,intContractId
				,dblQuantity
				,dtmBillingDate
				,dtmTransactionDate
				,intTransTime
				,strSequenceNumber
				,strPONumber
				,strMiscellaneous
				,intOdometer
				,intPumpNumber
				,dblTransferCost
				,strPriceMethod
				,strPriceBasis
				,strTransactionType
				,strDeliveryPickupInd
				,intNetworkId
				,intSiteId
				,intCardId
				,intVehicleId
				,intProductId
				,intARItemId
				,intARLocationId
				,dblOriginalTotalPrice
				,dblCalculatedTotalPrice
				,dblOriginalGrossPrice
				,dblCalculatedGrossPrice
				,dblCalculatedNetPrice
				,dblOriginalNetPrice
				,dblCalculatedPumpPrice
				,dblOriginalPumpPrice
				,intSalesPersonId
				,ysnInvalid
				,ysnCreditCardUsed
				,ysnOriginHistory
				,ysnPosted
				,strTransactionId
				,strPrintTimeStamp
				,strInvoiceReportNumber
				,strTempInvoiceReportNumber
				,intInvoiceId
				,ysnPostedCSV
				,strForeignCardId
				,ysnDuplicate
				,dtmInvoiceDate
				,dtmPostedDate
				,strOriginalProductNumber
				,intOverFilledTransactionId
				,dblInventoryCost
				,dblMargin
				)
				SELECT TOP 1
				 intPriceIndexId
				,intPriceProfileId
				,intSiteGroupId
				,strPriceProfileId
				,strPriceIndexId
				,strSiteGroup
				,dblPriceProfileRate
				,dblPriceIndexRate
				,dtmPriceIndexDate
				,NULL --intContractDetailId
				,NULL --intContractId
				,@dblOverfillQuantity --dblQuantity
				,dtmBillingDate
				,dtmTransactionDate
				,intTransTime
				,strSequenceNumber
				,strPONumber
				,strMiscellaneous
				,intOdometer
				,intPumpNumber
				,dblTransferCost
				,'Overfill'--strPriceMethod
				,strPriceBasis
				,strTransactionType
				,strDeliveryPickupInd
				,intNetworkId
				,intSiteId
				,intCardId
				,intVehicleId
				,intProductId
				,intARItemId
				,intARLocationId
				,dblOriginalTotalPrice
				,dblCalculatedTotalPrice
				,dblOriginalGrossPrice
				,dblCalculatedGrossPrice
				,dblCalculatedNetPrice
				,dblOriginalNetPrice
				,dblCalculatedPumpPrice
				,dblOriginalPumpPrice
				,intSalesPersonId
				,ysnInvalid
				,ysnCreditCardUsed
				,ysnOriginHistory
				,ysnPosted
				,strTransactionId
				,strPrintTimeStamp
				,strInvoiceReportNumber
				,strTempInvoiceReportNumber
				,intInvoiceId
				,ysnPostedCSV
				,strForeignCardId
				,ysnDuplicate
				,dtmInvoiceDate
				,dtmPostedDate
				,strOriginalProductNumber
				,@intTransactionId
				,dblInventoryCost
				,dblMargin
				FROM
				tblCFTransaction
				WHERE intTransactionId = @intTransactionId

				DECLARE @overfillId AS INT
				SET @overfillId = SCOPE_IDENTITY()

				INSERT INTO tblCFTransactionPrice
				(
					intTransactionId
					,strTransactionPriceId
					,dblOriginalAmount
					,dblCalculatedAmount
				)
				SELECT 
					@overfillId
					,strTransactionPriceId
					,dblOriginalAmount
					,dblCalculatedAmount
				FROM
				tblCFTransactionPrice
				WHERE intTransactionId = @intTransactionId


				INSERT INTO tblCFTransactionTax
				(
					 intTransactionId
					,dblTaxOriginalAmount
					,dblTaxCalculatedAmount
					,intTaxCodeId
					,dblTaxRate
				)
				SELECT
					 @overfillId
					,dblTaxOriginalAmount
					,dblTaxCalculatedAmount
					,intTaxCodeId
					,dblTaxRate
				FROM
				tblCFTransactionTax
				WHERE intTransactionId = @intTransactionId




				--select * from tblCFBatchRecalculateStagingTable

				exec uspCFRunRecalculateTransaction @TransactionId=@overfillId , @ContractsOverfill = 1



			END


		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION

			UPDATE tblCFBatchRecalculateStagingTable 
			SET strStatus = 'Error ' + ERROR_MESSAGE()
			WHERE intTransactionId = @intTransactionId




		END CATCH


	END
	ELSE
	BEGIN

	
	
	
	---------------------------------------------------
	--					PRICING OUT					 --
	---------------------------------------------------
	IF(@IsImporting = 1)
		BEGIN
			INSERT INTO tblCFTransactionPricingType
			(
			 intItemId
			,intProductId		
			,strProductNumber	
			,strItemId			
			,intCustomerId
			,intLocationId
			,dblQuantity
			,intItemUOMId
			,dtmTransactionDate
			,strTransactionType
			,intNetworkId
			,intSiteId
			,dblTransferCost
			,dblInventoryCost
			,dblOriginalPrice
			,dblPrice				
			,strPriceMethod		
			,dblAvailableQuantity	
			,intContractHeaderId	
			,intContractDetailId	
			,strContractNumber		
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
			,dblAdjustmentRate
			,ysnDuplicate
			,ysnInvalid
			,dblGrossTransferCost
			,dblNetTransferCost
			,intFreightTermId
			)
			SELECT
			 @intItemId					 AS intItemId
			,@intProductId				 AS intProductId		
			,@strProductNumber			 AS strProductNumber	
			,@strItemId					 AS strItemId			
			,@intCustomerId				 AS intCustomerId
			,@intLocationId				 AS intLocationId
			,@dblQuantity				 AS dblQuantity
			,@intItemUOMId				 AS intItemUOMId
			,@dtmTransactionDate		 AS dtmTransactionDate
			,@strTransactionType		 AS strTransactionType
			,@intNetworkId				 AS intNetworkId
			,@intSiteId					 AS intSiteId
			,@dblTransferCost			 AS dblTransferCost
			,@dblInventoryCost			 AS dblInventoryCost
			,@dblOriginalPrice			 AS dblOriginalPrice
			,@dblPrice					 AS dblPrice				
			,@strPriceMethod			 AS strPriceMethod		
			,@dblAvailableQuantity		 AS dblAvailableQuantity	
			,@intContractHeaderId		 AS intContractHeaderId	
			,@intContractDetailId		 AS intContractDetailId	
			,@strContractNumber			 AS strContractNumber		
			,@intContractSeq			 AS intContractSeq		
			,@strPriceBasis				 AS strPriceBasis	
			,@intPriceProfileId			 AS intPriceProfileId	
			,@intPriceIndexId 			 AS intPriceIndexId 	
			,@intSiteGroupId 			 AS intSiteGroupId 	
			,@strPriceProfileId			 AS strPriceProfileId	
			,@strPriceIndexId			 AS strPriceIndexId	
			,@strSiteGroup				 AS strSiteGroup		
			,@dblPriceProfileRate		 AS dblPriceProfileRate
			,@dblPriceIndexRate			 AS dblPriceIndexRate	
			,@dtmPriceIndexDate			 AS dtmPriceIndexDate	
			,@dblMargin					 AS dblMargin
			,@dblAdjustmentRate			 AS dblAdjustmentRate
			,@ysnDuplicate				 AS ysnDuplicate
			,@ysnInvalid				 AS ysnInvalid
			,@dblGrossTransferCost		 AS dblGrossTransferCost
			,@dblNetTransferCost		 AS dblNetTransferCost
			,@companyConfigFreightTermId AS intFreightTermId
		END
	ELSE
		BEGIN
			SELECT
			 @intItemId					AS intItemId
			,@intProductId				AS intProductId		
			,@strProductNumber			AS strProductNumber	
			,@strItemId					AS strItemId			
			,@intCustomerId				AS intCustomerId
			,@intLocationId				AS intLocationId
			,@dblQuantity				AS dblQuantity
			,@intItemUOMId				AS intItemUOMId
			,@dtmTransactionDate		AS dtmTransactionDate
			,@strTransactionType		AS strTransactionType
			,@intNetworkId				AS intNetworkId
			,@intSiteId					AS intSiteId
			,@dblTransferCost			AS dblTransferCost
			,@dblInventoryCost			AS dblInventoryCost
			,@dblOriginalPrice			AS dblOriginalPrice
			,@dblPrice					AS dblPrice				
			,@strPriceMethod			AS strPriceMethod		
			,@dblAvailableQuantity		AS dblAvailableQuantity	
			,@intContractHeaderId		AS intContractHeaderId	
			,@intContractDetailId		AS intContractDetailId	
			,@strContractNumber			AS strContractNumber		
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
			,@dblAdjustmentRate			AS dblAdjustmentRate
			,@ysnDuplicate				AS ysnDuplicate
			,@ysnInvalid				AS ysnInvalid
			,@dblGrossTransferCost		AS dblGrossTransferCost
			,@dblNetTransferCost		AS dblNetTransferCost
			,@companyConfigFreightTermId AS intFreightTermId
		END
	---------------------------------------------------
	--					PRICING OUT					 --
	---------------------------------------------------


	---------------------------------------------------
	--					TAXES OUT					 --
	---------------------------------------------------
	IF(ISNULL(@DevMode,0) = 1)
	BEGIN
		--DEBUGGER HERE-- 
		SELECT * FROM @tblCFTransactionTax --HERE-- 
	END

	IF(@IsImporting = 1)
		BEGIN
			INSERT INTO tblCFTransactionTaxType
			(
			 dblTaxCalculatedAmount
			,dblTaxOriginalAmount
			,intTaxCodeId
			,dblTaxRate 
			,strTaxCode
			)
			SELECT 
			 ISNULL(dblCalculatedTax,0) AS 'dblTaxCalculatedAmount'
			,ISNULL(dblOriginalTax,0)	AS 'dblTaxOriginalAmount'
			,intTaxCodeId
			,dblRate AS 'dblTaxRate'
			,(SELECT TOP 1 strTaxCode FROM tblSMTaxCode WHERE intTaxCodeId = T.intTaxCodeId) AS 'strTaxCode'
			FROM @tblCFTransactionTax AS T
			WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL
		END
	ELSE
		BEGIN
			SELECT 
			 ISNULL(dblCalculatedTax,0) AS 'dblTaxCalculatedAmount'
			,ISNULL(dblOriginalTax,0)	AS 'dblTaxOriginalAmount'
			,intTaxCodeId
			,dblRate AS 'dblTaxRate'
			,(SELECT TOP 1 strTaxCode FROM tblSMTaxCode WHERE intTaxCodeId = T.intTaxCodeId) AS 'strTaxCode'
			FROM @tblCFTransactionTax AS T
			WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL
		END
	---------------------------------------------------
	--					TAXES OUT					 --
	---------------------------------------------------

	--DEBUGGER HERE-- 
	--SELECT * FROM tblCFTransactionTaxType
	
	---------------------------------------------------
	--					INDEX PRICING				 --
	---------------------------------------------------
	IF((@intPriceIndexId > 0 AND @intPriceIndexId IS NOT NULL) 
	AND (@strPriceIndexId IS NOT NULL) 
	AND (@dblPriceIndexRate <=0 OR @dblPriceIndexRate IS NULL)
	AND (ISNULL(@ysnCaptiveSite,0) = 0))
	BEGIN
		INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		VALUES ('Calculation',@runDate,@guid, @intTransactionId, 'No index price found.')
	END
	---------------------------------------------------
	--					INDEX PRICING				 --
	---------------------------------------------------


	---------------------------------------------------
	--					PRICE OUT					 --
	---------------------------------------------------
	IF(@IsImporting = 1)
	BEGIN
		INSERT INTO tblCFTransactionPriceType
		(
		 [strTransactionPriceId]
		,[dblTaxOriginalAmount]	
		,[dblTaxCalculatedAmount]
		)
		SELECT 
		 [strTransactionPriceId]
		,ISNULL([dblOriginalAmount]	,0)
		,ISNULL([dblCalculatedAmount],0)
		FROM @tblTransactionPrice
	END
	ELSE
	BEGIN
		SELECT * FROM @tblTransactionPrice
	END
	END
	---------------------------------------------------
	--					PRICE OUT					 --
	---------------------------------------------------
	
	END