
CREATE PROCEDURE [dbo].[uspCFCalculateTransaction] 
	 @strGUID						NVARCHAR(MAX)
	,@intUserId						INT				
	,@dtmProcessDate				DATETIME
	,@IsImporting					BIT
	
AS

BEGIN


	--ALTER TABLE tblCFImportTransactionOriginalTaxExemptZeroQuantity
	----DROP COLUMN strGuid 
	--ADD strGUID NVARCHAR(MAX) COLLATE Latin1_General_CI_AS	NULL

	DECLARE @ysnReRunCalcTax BIT = 0
	SELECT 'id',@strGUID

	/*
	--DECLARE @dblAuditOriginalTotalPrice	    NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditOriginalGrossPrice		NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditOriginalNetPrice		NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditCalculatedTotalPrice	NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditCalculatedGrossPrice	NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditCalculatedNetPrice		NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditCalculatedTotalTax		NVARCHAR(MAX) = 0.000000
	--DECLARE @dblAuditOriginalTotalTax		NVARCHAR(MAX) = 0.000000
	--DECLARE @strAuditPriceMethod			NVARCHAR(MAX) = ''
	--DECLARE @strAuditPriceBasis				NVARCHAR(MAX) = ''
	--DECLARE @strAuditPriceProfileId			NVARCHAR(MAX) = ''
	--DECLARE @strAuditPriceIndexId			NVARCHAR(MAX) = ''

	--IF(ISNULL(@BatchRecalculate,0) = 1)
	--BEGIN
	--	SELECT TOP 1
	--	  @dblAuditOriginalTotalPrice	     =		ISNULL(dblOriginalTotalPrice,0)		
	--	, @dblAuditOriginalGrossPrice		 =		ISNULL(dblOriginalGrossPrice,0)
	--	, @dblAuditOriginalNetPrice			 =		ISNULL(dblOriginalNetPrice,0) 
	--	, @dblAuditCalculatedTotalPrice		 =		ISNULL(dblCalculatedTotalPrice,0) 
	--	, @dblAuditCalculatedGrossPrice		 =		ISNULL(dblCalculatedGrossPrice,0) 
	--	, @dblAuditCalculatedNetPrice		 =		ISNULL(dblCalculatedNetPrice,0)
	--	, @dblAuditCalculatedTotalTax		 =		ISNULL(dblCalculatedTotalTax,0)
	--	, @dblAuditOriginalTotalTax			 =		ISNULL(dblOriginalTotalTax,0)
	--	, @strAuditPriceMethod				 =		ISNULL(strPriceMethod,'')
	--	, @strAuditPriceBasis				 =		ISNULL(strPriceBasis,'')
	--	, @strAuditPriceProfileId			 =		ISNULL(strPriceProfileId,'')
	--	, @strAuditPriceIndexId				 =		ISNULL(strPriceIndexId,'')
	--	FROM tblCFTransaction
	--	WHERE intTransactionId = @TransactionId 
	--END



	
	-------------- GET ITEM PRICE PARAMETERS  ------------
	--DECLARE @intItemId						INT
	--DECLARE @intCustomerId					INT
	--DECLARE @intLocationId					INT		
	--DECLARE @intItemUOMId					INT			
	--DECLARE @dtmTransactionDate				DATETIME		
	--DECLARE @dblQuantity					NUMERIC(18,10)
	--DECLARE @strTransactionType				NVARCHAR(MAX)
	--DECLARE @intNetworkId					INT
	--DECLARE @intSiteId						INT
	--DECLARE @dblTransferCost				NUMERIC(18,10)
	--DECLARE @dblOriginalPrice				NUMERIC(18,10)
	--DECLARE @dblOriginalPriceZeroQty		NUMERIC(18,10)
	--DECLARE @dblOriginalPriceForCalculation NUMERIC(18,10)
	--DECLARE @intCardId						INT
	--DECLARE @intVehicleId					INT
	--DECLARE @intTaxGroupId					INT

	--DECLARE @dblPrice						NUMERIC(18,10)
	--DECLARE @dblPriceZeroQty				NUMERIC(18,10)
	--DECLARE @strPriceBasis					NVARCHAR(MAX)
	--DECLARE @strPriceMethod					NVARCHAR(MAX)
	--DECLARE @intContractHeaderId			INT	
	--DECLARE @intContractDetailId			INT
	--DECLARE @strContractNumber				NVARCHAR(MAX)
	--DECLARE @intContractSeq					INT
	--DECLARE @intItemContractHeaderId		INT	
	--DECLARE @intItemContractDetailId		INT
	--DECLARE @strItemContractNumber			NVARCHAR(MAX)
	--DECLARE @intItemContractSeq				INTfnARGetItemPricingDetails
	--DECLARE @dblAvailableQuantity			NUMERIC(18,10)

	--DECLARE @intTransactionId				INT
	--DECLARE @ysnCreditCardUsed				BIT
	--DECLARE @ysnPostedOrigin				BIT
	--DECLARE @ysnPostedCSV					BIT
	--DECLARE @guid							NVARCHAR(MAX)
	--DECLARE	@runDate						DATETIME

	--DECLARE @intPriceProfileId				INT
	--DECLARE @intPriceProfileDetailId		INT
	--DECLARE @intPriceIndexId 				INT
	--DECLARE @intSiteGroupId 				INT

	--DECLARE @ysnForceRounding				BIT
	--DECLARE @strPriceProfileId				NVARCHAR(MAX)
	--DECLARE @strPriceIndexId				NVARCHAR(MAX)
	--DECLARE @strSiteGroup					NVARCHAR(MAX)
	--DECLARE @dblPriceProfileRate			NUMERIC(18,10)
	--DECLARE @dblPriceIndexRate				NUMERIC(18,10)
	--DECLARE @dblAdjustmentRate				NUMERIC(18,10)
	
	--DECLARE	@dtmPriceIndexDate				DATETIME		
	
				
	--DECLARE @intProductId					INT
	--DECLARE @strProductNumber				NVARCHAR(MAX)
	--DECLARE @strItemId						NVARCHAR(MAX)

	--DECLARE @ysnBackoutDueToRouding			BIT	= 0

	--DECLARE @intPriceRuleGroup				INT
	
	--DECLARE @dblGrossTransferCost			NUMERIC(18,10)
	--DECLARE @dblNetTransferCost				NUMERIC(18,10)
	--DECLARE @dblNetTransferCostZeroQuantity	NUMERIC(18,10)
	--DECLARE @dblAdjustments					NUMERIC(18,10)
	--DECLARE @dblAdjustmentWithIndex			NUMERIC(18,10)

	
	--DECLARE @ysnCaptiveSite					BIT
	--DECLARE @ysnActive						BIT

	--DECLARE @intCardTypeId					INT				= 0
	--DECLARE @ysnDualCard					BIT				= 0
	
	--DECLARE @ysnInvalid	BIT = 0

	--DECLARE @companyConfigFreightTermId	INT = NULL
	*/

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 tblCFImportTransactionStagingTable.intCompanyConfigFreightTermId = (SELECT TOP 1 intFreightTermId FROM tblCFCompanyPreference)
		,dblZeroQuantity = 100000
		,isImporting = 1
	WHERE strGUID = @strGUID



	DECLARE @isQuote						BIT = 0
	
	UPDATE tblCFImportTransactionStagingTable 
	SET tblCFImportTransactionStagingTable.isQuote = 1
	WHERE tblCFImportTransactionStagingTable.strProcessType = 'quote'
	AND strGUID = @strGUID

	----------------------------------------
	--FOR REVIEW - IF THIS IS STILL NEEDED--
	------------------------------------------
	--DELETE FROM tblCFTransactionPricingType
	--WHERE intTransactionId IN (
	--	SELECT intTranscationId FROM tblCFImportTransactionStagingTable WHERE tblCFImportTransactionStagingTable.IsImporting = 1
	--)

	--DELETE FROM tblCFTransactionTaxType
	--WHERE intTransactionId IN (
	--	SELECT intTranscationId FROM tblCFImportTransactionStagingTable WHERE tblCFImportTransactionStagingTable.IsImporting = 1
	--)

	--DELETE FROM tblCFTransactionPriceType
	--WHERE intTransactionId IN (
	--	SELECT intTranscationId FROM tblCFImportTransactionStagingTable WHERE tblCFImportTransactionStagingTable.IsImporting = 1
	--)
	------------------------------------------

	



	
	--IF(@strGUID IS NULL OR @strGUID = '')
	--BEGIN
	--	SET @guid		= NEWID()
	--END
	--ELSE
	--BEGIN
	--	SET @guid		= @strGUID
	--END

	--IF(@strProcessDate IS NULL OR @strProcessDate = '')
	--BEGIN
	--	SET @runDate		= GETDATE()
	--END
	--ELSE
	--BEGIN
	--	SET @runDate		= @strProcessDate
	--END


	 
	--SET @ysnPostedOrigin			= @PostedOrigin
	--SET @ysnPostedCSV				= @PostedCSV	
	--SET @ysnCreditCardUsed		= @CreditCardUsed
	--SET @intVehicleId				= @VehicleId
	--SET @intCardId				= @CardId
	--SET @dblQuantity				= @Quantity
	--SET @dtmTransactionDate		= @TransactionDate
	--SET @strTransactionType		= @TransactionType
	--SET @intNetworkId				= @NetworkId
	--SET @intSiteId						= @SiteId
	--SET @dblTransferCost				=@TransferCost
	--SET @dblOriginalPrice			= @OriginalPrice
	--SET @dblOriginalPriceZeroQty			= @dblOriginalPrice
	--SET @intTransactionId				= @TransactionId


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 dblOriginalPrice			= dblOriginalGrossPrice			
	,dblOriginalPriceZeroQty	= dblOriginalGrossPrice			
	WHERE strGUID = @strGUID



	UPDATE tblCFTransactionNote 
	SET ysnCurrentError = 0 , strErrorTitle = 'Prior Error' 
	WHERE intTransactionId IN (
								SELECT intTransactionId 
								FROM tblCFImportTransactionStagingTable 
								WHERE tblCFImportTransactionStagingTable.intTransactionId > 0 
								and @IsImporting = 1
								AND strGUID = @strGUID
								) 
	


	UPDATE tblCFImportTransactionStagingTable 
	SET intTransactionId = NULL
	WHERE intTransactionId = 0
	AND strGUID = @strGUID


	--IF (@intTransactionId > 0 AND @IsImporting = 0)
	--BEGIN
	--	--DELETE tblCFTransactionNote WHERE intTransactionId = @intTransactionId AND intTransactionId = 0
	--	UPDATE tblCFTransactionNote SET ysnCurrentError = 0 , strErrorTitle = 'Prior Error' WHERE intTransactionId = @intTransactionId 
	--END
	--ELSE IF(@intTransactionId = 0)
	--BEGIN
	--	SET @intTransactionId = NULL
	--END


	--IF()

	UPDATE tblCFImportTransactionStagingTable
	SET 
	tblCFImportTransactionStagingTable.ysnCaptiveSite = tblCFSite.ysnCaptiveSite,
	tblCFImportTransactionStagingTable.intTaxGroupId = tblCFSite.intTaxGroupId
	FROM tblCFSite 
	WHERE tblCFSite.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID


	--SELECT TOP 1 
	--@ysnCaptiveSite = ysnCaptiveSite
	--FROM tblCFSite WHERE intSiteId = @intSiteId


	--GET CAPTIVE SITE--
	--SELECT TOP 1 
	--@ysnCaptiveSite = ysnCaptiveSite
	--FROM tblCFSite WHERE intSiteId = @intSiteId

	--GET TAX GROUP ID--
	--SELECT TOP 1 
	--@intTaxGroupId = intTaxGroupId
	--FROM tblCFSite WHERE intSiteId = @intSiteId

	UPDATE tblCFImportTransactionStagingTable
	SET intCustomerId = tblCFNetwork.intCustomerId
	FROM tblCFNetwork
	WHERE tblCFNetwork.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND strTransactionType = 'Foreign Sale'
	AND (tblCFImportTransactionStagingTable.intPrcCustomerId IS NULL OR tblCFImportTransactionStagingTable.intPrcCustomerId = 0)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intCustomerId = cfAccount.intCustomerId
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFCard as cfCard
	ON cfCard.intCardId = tblCFImportTransactionStagingTable.intCardId
	INNER JOIN tblCFAccount as cfAccount
	ON cfCard.intAccountId = cfAccount.intAccountId
	WHERE (tblCFImportTransactionStagingTable.intPrcCustomerId IS NULL OR tblCFImportTransactionStagingTable.intPrcCustomerId = 0)
	AND (tblCFImportTransactionStagingTable.intCardId IS NOT NULL OR tblCFImportTransactionStagingTable.intCardId != 0)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intPriceRuleGroup = tblCFAccount.intPriceRuleGroup
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFAccount
	ON tblCFAccount.intCustomerId = tblCFImportTransactionStagingTable.intPrcCustomerId
	WHERE strGUID = @strGUID


	----GET CUSTOMER ID--
	--IF (@TransactionType = 'Foreign Sale')
	--BEGIN
	--	SELECT TOP 1
	--	@intCustomerId = intCustomerId
	--	FROM tblCFNetwork 
	--	WHERE intNetworkId = @intNetworkId
	--END
	--ELSE IF(ISNULL(@intCardId,0) != 0)
	--BEGIN
	--	SELECT TOP 1
	--	 @intCustomerId = cfAccount.intCustomerId
	--	,@intPriceRuleGroup = cfAccount.intPriceRuleGroup
	--	FROM tblCFCard as cfCard
	--	INNER JOIN tblCFAccount as cfAccount
	--	ON cfCard.intAccountId = cfAccount.intAccountId
	--	WHERE cfCard.intCardId = @intCardId
	--END


--ELSE
--BEGIN
--		SET @intCustomerId = @CustomerId
--		SELECT TOP 1 @intPriceRuleGroup = intPriceRuleGroup FROM tblCFAccount WHERE intCustomerId = @CustomerId
--	END

	--GET @ysnActive CUSTOMER--

		--SELECT TOP 1
		--@ysnActive = ysnActive
		--FROM tblARCustomer
		--WHERE intEntityId = @intCustomerId

	UPDATE tblCFImportTransactionStagingTable
	SET ysnActive = tblARCustomer.ysnActive
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblARCustomer
	ON tblARCustomer.intEntityId = tblCFImportTransactionStagingTable.intPrcCustomerId
	WHERE strGUID = @strGUID
	--GET @ysnActive CUSTOMER--


	UPDATE tblCFImportTransactionStagingTable
	SET 
	intLocationId = intARLocationId,
	intSiteGroupId = intAdjustmentSiteGroupId
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFSite
	ON tblCFSite.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	WHERE strGUID = @strGUID
	
	----GET COMPANY LOCATION ID--
	--SELECT TOP 1
	--	@intLocationId = intARLocationId,
	--	@intSiteGroupId = intAdjustmentSiteGroupId
	--FROM tblCFSite as cfSite
	--WHERE cfSite.intSiteId = @intSiteId



	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemId = cfItem.intARItemId,
		 intProductId = cfItem.intItemId,
		 strProductNumber = cfItem.strProductNumber,
		 strItemId = icItem.strItemNo
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFItem as cfItem 
	ON cfItem.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND cfItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND cfItem.strProductNumber = tblCFImportTransactionStagingTable.strProductId
	INNER JOIN tblICItem as icItem
	ON cfItem.intARItemId = icItem.intItemId
	WHERE (tblCFImportTransactionStagingTable.intProductId IS NULL OR tblCFImportTransactionStagingTable.intProductId = 0)
	AND (tblCFImportTransactionStagingTable.intTransactionId IS NOT NULL OR tblCFImportTransactionStagingTable.intTransactionId != 0)
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemId = cfItem.intARItemId,
		 intProductId = cfItem.intItemId,
		 strProductNumber = cfItem.strProductNumber,
		 strItemId = icItem.strItemNo
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFItem as cfItem 
	ON  cfItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND cfItem.strProductNumber = tblCFImportTransactionStagingTable.strProductId
	INNER JOIN tblICItem as icItem
	ON cfItem.intARItemId = icItem.intItemId
	WHERE (tblCFImportTransactionStagingTable.intProductId IS NULL OR tblCFImportTransactionStagingTable.intProductId = 0)
	AND (tblCFImportTransactionStagingTable.intTransactionId IS NOT NULL OR tblCFImportTransactionStagingTable.intTransactionId != 0)
	AND  (tblCFImportTransactionStagingTable.intARItemId IS NULL OR tblCFImportTransactionStagingTable.intARItemId = 0)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemId = icItem.intItemId,
		 strItemId = icItem.strItemNo
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblICItem as icItem
	ON tblCFImportTransactionStagingTable.intARItemId = icItem.intItemId
	WHERE (tblCFImportTransactionStagingTable.intProductId IS NULL OR tblCFImportTransactionStagingTable.intProductId = 0)
	AND (tblCFImportTransactionStagingTable.intTransactionId IS NOT NULL OR tblCFImportTransactionStagingTable.intTransactionId != 0)
	AND  (tblCFImportTransactionStagingTable.intARItemId IS NULL OR tblCFImportTransactionStagingTable.intARItemId = 0)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemId = cfItem.intARItemId,
		 intProductId = cfItem.intItemId,
		 strProductNumber = cfItem.strProductNumber,
		 strItemId = icItem.strItemNo
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFItem as cfItem 
	ON cfItem.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND cfItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND cfItem.intItemId = tblCFImportTransactionStagingTable.intProductId
	INNER JOIN tblICItem as icItem
	ON cfItem.intARItemId = icItem.intItemId
	WHERE (tblCFImportTransactionStagingTable.intProductId IS NULL OR tblCFImportTransactionStagingTable.intProductId = 0)
	AND (tblCFImportTransactionStagingTable.intTransactionId IS NOT NULL OR tblCFImportTransactionStagingTable.intTransactionId != 0)
	AND strGUID = @strGUID
	
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemId = cfItem.intARItemId,
		 intProductId = cfItem.intItemId,
		 strProductNumber = cfItem.strProductNumber,
		 strItemId = icItem.strItemNo
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFItem as cfItem 
	ON  cfItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND cfItem.intItemId = tblCFImportTransactionStagingTable.intProductId
	INNER JOIN tblICItem as icItem
	ON cfItem.intARItemId = icItem.intItemId
	WHERE (tblCFImportTransactionStagingTable.intProductId IS NULL OR tblCFImportTransactionStagingTable.intProductId = 0)
	AND (tblCFImportTransactionStagingTable.intTransactionId IS NOT NULL OR tblCFImportTransactionStagingTable.intTransactionId != 0)
	AND  (tblCFImportTransactionStagingTable.intARItemId IS NULL OR tblCFImportTransactionStagingTable.intARItemId = 0)
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote 
	(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
	SELECT 
	'Calculation',strProcessDate,strGUID,intTransactionId,'Unable to find product number ' + strProductId + ' into i21 item list'
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intARItemId IS NULL OR tblCFImportTransactionStagingTable.intARItemId = 0)
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	intItemUOMId = icItemLocation.intIssueUOMId
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblICItemLocation as icItemLocation
	ON tblCFImportTransactionStagingTable.intARItemId = icItemLocation.intItemId
	AND tblCFImportTransactionStagingTable.intARItemLocationId = icItemLocation.intLocationId 
	AND (tblCFImportTransactionStagingTable.intItemUOMId IS NULL OR tblCFImportTransactionStagingTable.intItemUOMId = 0) 
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	strNetworkType = tblCFNetwork.strNetworkType
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFNetwork
	ON tblCFNetwork.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	WHERE (tblCFImportTransactionStagingTable.strNetworkType IS NULL OR  tblCFImportTransactionStagingTable.strNetworkType = '')
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	ysnItemPricingOnly = 0
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.strTransactionType = 'Local/Network'
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	ysnItemPricingOnly = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.strTransactionType != 'Local/Network'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	dblPrice = dblOriginalPrice,
	strPriceMethod = 'Credit Card'
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.ysnCreditCard = 1
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	dblPrice = dblOriginalPrice,
	strPriceMethod = 'Origin History'
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.ysnPostedOrigin = 1
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	dblPrice = dblOriginalPrice,
	strPriceMethod = 'Posted Trans from CSV'
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.ysnPostedCSV = 1
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	dblPrice = dblOriginalPrice,
	strPriceMethod = 'Network Cost'
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.strTransactionType = 'Foreign Sale'
	AND strGUID = @strGUID



	DECLARE @currency INT
	SET @currency = dbo.fnSMGetDefaultCurrency ('FUNCTIONAL')

	UPDATE tblCFImportTransactionStagingTable
	SET 
	intDefaultCurrencyId = @currency
	FROM tblCFImportTransactionStagingTable 
	WHERE strGUID = @strGUID


	

	SELECT 
	tblCFImportTransactionStagingTable.intARItemId					
	,tblCFImportTransactionStagingTable.intPrcCustomerId
	,tblCFImportTransactionStagingTable.intARItemLocationId
	,tblCFImportTransactionStagingTable.intItemUOMId
	,tblCFImportTransactionStagingTable.intDefaultCurrencyId
	,tblCFImportTransactionStagingTable.dtmTransactionDate
	,tblCFImportTransactionStagingTable.dblQuantity
	,tblCFImportTransactionStagingTable.intContractHeaderId
	,tblCFImportTransactionStagingTable.intContractDetailId
	,tblCFImportTransactionStagingTable.strContractNumber			
	,tblCFImportTransactionStagingTable.intContractSeq
	,tblCFImportTransactionStagingTable.intItemContractHeaderId
	,tblCFImportTransactionStagingTable.intItemContractDetailId
	,tblCFImportTransactionStagingTable.strItemContractNumber		
	,tblCFImportTransactionStagingTable.intItemContractSeq
	,tblCFImportTransactionStagingTable.dblAvailableQuantity
	,tblCFImportTransactionStagingTable.ysnItemPricingOnly
	,strTransactionType
	,strItemId
	,strCardId
	,strProductId
	FROM tblCFImportTransactionStagingTable
	WHERE strGUID = @strGUID




	UPDATE tblCFImportTransactionStagingTable 
	SET 
	 dblPricingPrice				  = tblARPricing.dblPrice
	,strPricingPricing				  = tblARPricing.strPricing
	,strPricingPriceMethod			  = tblARPricing.strPricing
	,intPricingContractHeaderId		  = tblARPricing.intContractHeaderId
	,intPricingContractDetailId 	  = tblARPricing.intContractDetailId
	,strPricingContractNumber		  = tblARPricing.strContractNumber
	,intPricingContractSeq			  = tblARPricing.intContractSeq
	,dblPricingAvailableQuantity	  = tblARPricing.dblAvailableQty
	FROM tblCFImportTransactionStagingTable 
	CROSS APPLY [dbo].[fnARGetItemPricingDetails] (

			 tblCFImportTransactionStagingTable.intARItemId						
			,tblCFImportTransactionStagingTable.intPrcCustomerId
			,tblCFImportTransactionStagingTable.intARItemLocationId
			,tblCFImportTransactionStagingTable.intPrcItemUOMId
			,tblCFImportTransactionStagingTable.intDefaultCurrencyId
			,tblCFImportTransactionStagingTable.dtmTransactionDate
			,tblCFImportTransactionStagingTable.dblQuantity
			,tblCFImportTransactionStagingTable.intContractHeaderId
			,tblCFImportTransactionStagingTable.intContractDetailId
			,tblCFImportTransactionStagingTable.strContractNumber								
			,tblCFImportTransactionStagingTable.intContractSeq
			,tblCFImportTransactionStagingTable.intItemContractHeaderId
			,tblCFImportTransactionStagingTable.intItemContractDetailId
			,tblCFImportTransactionStagingTable.strItemContractNumber								
			,tblCFImportTransactionStagingTable.intItemContractSeq
			,tblCFImportTransactionStagingTable.dblAvailableQuantity
			,NULL--@UnlimitedQuantity
			,NULL--@OriginalQuantity
			,NULL--@CustomerPricingOnly
			,tblCFImportTransactionStagingTable.ysnItemPricingOnly
			,NULL--@ExcludeContractPricing
			,NULL--@VendorId
			,NULL--@SupplyPointId
			,NULL--@LastCost
			,NULL--@ShipToLocationId
			,NULL--@VendorLocationId
			,NULL--@PricingLevelId
			,1 --@AllowQtyToExceedContract
			,'CF Tran' --@InvoiceType
			,NULL--@TermId
			,NULL--@GetAllAvailablePricing
			,NULL--@CurrencyExchangeRate
			,NULL--@CurrencyExchangeRateTypeId
			,NULL--@ysnFromItemSelection
		) AS tblARPricing
	WHERE strGUID = @strGUID
	
	SELECT 'PRICING',
	 dblPricingPrice				 
	,strPricingPricing				 
	,strPricingPriceMethod			 
	,intPricingContractHeaderId		 
	,intPricingContractDetailId 	 
	,strPricingContractNumber		 
	,intPricingContractSeq			 
	,dblPricingAvailableQuantity	 
	FROM tblCFImportTransactionStagingTable
	WHERE strGUID = @strGUID
	

	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblOriginalPrice,0), 
	strPriceMethod = 'Import File Price'
	WHERE (LOWER(strPricingPriceMethod) = 'inventory - standard pricing' OR LOWER(strPricingPriceMethod) = 'inventory - pricing level')
	AND (dblOriginalPrice IS NOT NULL AND dblOriginalPrice > 0)
	AND (ISNULL(dblPricingPrice,0) != 0)
	AND strGUID = @strGUID
	
	
	

	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblOriginalPrice,0), 
	strPriceMethod = 'Import File Price'
	WHERE (LOWER(strPricingPriceMethod) = 'inventory - standard pricing' OR LOWER(strPricingPriceMethod) = 'inventory - pricing level')
	AND (dblOriginalPrice IS NOT NULL AND dblOriginalPrice > 0)
	AND (ISNULL(dblPricingPrice,0) != 0)
	AND (ysnCreditCard = 1)
	AND strGUID = @strGUID
	

	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblPricingPrice,0)
	WHERE (LOWER(strPricingPriceMethod) = 'inventory - standard pricing' OR LOWER(strPricingPriceMethod) = 'inventory - pricing level')
	AND (dblOriginalPrice IS NULL OR dblOriginalPrice = 0)
	AND (ISNULL(dblPricingPrice,0) != 0)
	AND strGUID = @strGUID
	
	

	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblOriginalPrice,0), 
	strPriceMethod = 'Import File Price'
	WHERE (dblOriginalPrice IS NOT NULL OR dblOriginalPrice > 0)
	AND (ISNULL(dblPricingPrice,0) = 0)
	AND (ISNULL(strPricingPriceMethod,'') = '')
	AND strGUID = @strGUID
	


	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblOriginalPrice,0), 
	strPriceMethod = 'Import File Price'
	WHERE(dblOriginalPrice IS NOT NULL OR dblOriginalPrice > 0)
	AND (ISNULL(dblPricingPrice,0) = 0)
	AND (ysnCreditCard = 1)
	AND (ISNULL(strPricingPriceMethod,'') = '')
	AND strGUID = @strGUID
	
	
	--UPDATE tblCFImportTransactionStagingTable 
	--SET 
	--dblPrice = dblPricingPrice, 
	--strPriceMethod = 'Inventory - Standard Pricing'
	--WHERE(dblOriginalPrice IS NOT NULL AND dblOriginalPrice > 0)
	--AND (ISNULL(dblPricingPrice,0) = 0)
	--AND (ISNULL(strPricingPriceMethod,'') = '')

	
	UPDATE tblCFImportTransactionStagingTable 
	SET 
	dblPrice = ISNULL(dblOriginalPrice,0)
	WHERE(dblOriginalPrice IS NOT NULL OR dblOriginalPrice > 0)
	AND ISNULL(dblPrice,0) = 0
	AND ISNULL(strPriceMethod,'') = ''
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable 
	SET 
	ysnGlobalProfile = 0, 
	intLinkedProfileId = NULL
	WHERE(dblOriginalPrice IS NOT NULL AND dblOriginalPrice > 0)
	AND (ISNULL(dblPricingPrice,0) = 0)
	AND strGUID = @strGUID

	
	--	SELECT 
	-- dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
	--	,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
	--	,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
	--	,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
	--	,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
	--	,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
	--	,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
	--	,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
	--	,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
	--	,ysnPriceProfileMatch		= 1
	--	,intItemId
	--	,intNetworkId
	--	,intSiteId
	--	,intSiteGroupId
	--FROM tblCFImportTransactionPriceProfile 
	--WHERE ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	--AND ISNULL(tblCFImportTransactionPriceProfile.intNetworkId,0) = 0 -- ALL NETWORKS
	--AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	--AND ISNULL(tblCFImportTransactionPriceProfile.intSiteGroupId,0) = 0 -- ALL SITES GROUPS
	--AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	--AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId



	-->> LOCAL <<--
	INSERT INTO tblCFImportTransactionPriceProfile
	(
		 intTransactionId		
		,intAccountId			
		,intCustomerId			
		,intDiscountDays			
		,intDiscountScheduleId	
		,intSalesPersonId		
		,intPriceProfileDetailId	
		,intPriceProfileHeaderId	
		,intItemId				
		,intNetworkId			
		,intSiteGroupId			
		,intSiteId				
		,intLocalPricingIndex	
		,dblRate					
		,strBasis				
		,strType					
		,intLinkedProfile		
		,strIndexType		
		,strPriceProfileId	
		,strPriceIndexId		
		,ysnForceRounding
		,strGUID	
	)
	SELECT 
		tblCFImportTransactionStagingTable.intTransactionId,
		tblCFAccount.intAccountId,			
		tblCFAccount.intCustomerId,			
		tblCFAccount.intDiscountDays,			
		tblCFAccount.intDiscountScheduleId,	
		tblCFAccount.intSalesPersonId,		
		tblCFPriceProfileDetail.intPriceProfileDetailId,	
		tblCFPriceProfileHeader.intPriceProfileHeaderId,	
		tblCFPriceProfileDetail.intItemId,				
		tblCFPriceProfileDetail.intNetworkId,			
		tblCFPriceProfileDetail.intSiteGroupId,			
		tblCFPriceProfileDetail.intSiteId,				
		intLocalPricingIndex,	
		tblCFPriceProfileDetail.dblRate,					
		tblCFPriceProfileDetail.strBasis,				
		tblCFPriceProfileHeader.strType,
		tblCFPriceProfileHeader.intLinkedProfile,
		tblCFPriceIndex.strType,
		tblCFPriceProfileHeader.strPriceProfile,
		tblCFPriceIndex.strPriceIndex,
		tblCFPriceProfileDetail.ysnForceRounding,
		@strGUID
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFAccount
	ON tblCFImportTransactionStagingTable.intAccountId = tblCFAccount.intAccountId
	AND tblCFAccount.intCustomerId = tblCFImportTransactionStagingTable.intPrcCustomerId 
	INNER JOIN tblCFPriceProfileHeader
	ON tblCFAccount.intLocalPriceProfileId = tblCFPriceProfileHeader.intPriceProfileHeaderId
	INNER JOIN tblCFPriceProfileDetail
	ON tblCFPriceProfileHeader.intPriceProfileHeaderId = tblCFPriceProfileDetail.intPriceProfileHeaderId
	LEFT JOIN tblCFPriceIndex
	ON tblCFPriceIndex.intPriceIndexId = tblCFPriceProfileDetail.intLocalPricingIndex
	WHERE tblCFPriceProfileHeader.strType = tblCFImportTransactionStagingTable.strTransactionType
	AND tblCFImportTransactionStagingTable.ysnGlobalProfile = 0
	AND strGUID = @strGUID

	-->> REMOTE <<--
	INSERT INTO tblCFImportTransactionPriceProfile
	(
		 intTransactionId		
		,intAccountId			
		,intCustomerId			
		,intDiscountDays			
		,intDiscountScheduleId	
		,intSalesPersonId		
		,intPriceProfileDetailId	
		,intPriceProfileHeaderId	
		,intItemId				
		,intNetworkId			
		,intSiteGroupId			
		,intSiteId				
		,intLocalPricingIndex	
		,dblRate					
		,strBasis				
		,strType					
		,intLinkedProfile		
		,strIndexType		
		,strPriceProfileId	
		,strPriceIndexId		
		,ysnForceRounding	
		,strGUID
	)
	SELECT 
		tblCFImportTransactionStagingTable.intTransactionId,
		tblCFAccount.intAccountId,			
		tblCFAccount.intCustomerId,			
		tblCFAccount.intDiscountDays,			
		tblCFAccount.intDiscountScheduleId,	
		tblCFAccount.intSalesPersonId,		
		tblCFPriceProfileDetail.intPriceProfileDetailId,	
		tblCFPriceProfileHeader.intPriceProfileHeaderId,	
		tblCFPriceProfileDetail.intItemId,				
		tblCFPriceProfileDetail.intNetworkId,			
		tblCFPriceProfileDetail.intSiteGroupId,			
		tblCFPriceProfileDetail.intSiteId,				
		intLocalPricingIndex,	
		tblCFPriceProfileDetail.dblRate,					
		tblCFPriceProfileDetail.strBasis,				
		tblCFPriceProfileHeader.strType,
		tblCFPriceProfileHeader.intLinkedProfile,
		tblCFPriceIndex.strType,
		tblCFPriceProfileHeader.strPriceProfile,
		tblCFPriceIndex.strPriceIndex,
		tblCFPriceProfileDetail.ysnForceRounding,
		@strGUID
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFAccount
	ON tblCFImportTransactionStagingTable.intAccountId = tblCFAccount.intAccountId
	AND tblCFAccount.intCustomerId = tblCFImportTransactionStagingTable.intPrcCustomerId 
	INNER JOIN tblCFPriceProfileHeader
	ON tblCFAccount.intRemotePriceProfileId = tblCFPriceProfileHeader.intPriceProfileHeaderId
	INNER JOIN tblCFPriceProfileDetail
	ON tblCFPriceProfileHeader.intPriceProfileHeaderId = tblCFPriceProfileDetail.intPriceProfileHeaderId
	LEFT JOIN tblCFPriceIndex
	ON tblCFPriceIndex.intPriceIndexId = tblCFPriceProfileDetail.intLocalPricingIndex
	WHERE tblCFPriceProfileHeader.strType = tblCFImportTransactionStagingTable.strTransactionType
	AND tblCFImportTransactionStagingTable.ysnGlobalProfile = 0
	AND strGUID = @strGUID


	-->> EXT REMOTE <<--
	INSERT INTO tblCFImportTransactionPriceProfile
	(
		 intTransactionId		
		,intAccountId			
		,intCustomerId			
		,intDiscountDays			
		,intDiscountScheduleId	
		,intSalesPersonId		
		,intPriceProfileDetailId	
		,intPriceProfileHeaderId	
		,intItemId				
		,intNetworkId			
		,intSiteGroupId			
		,intSiteId				
		,intLocalPricingIndex	
		,dblRate					
		,strBasis				
		,strType					
		,intLinkedProfile		
		,strIndexType		
		,strPriceProfileId	
		,strPriceIndexId		
		,ysnForceRounding		
		,strGUID
	)
	SELECT 
		tblCFImportTransactionStagingTable.intTransactionId,
		tblCFAccount.intAccountId,			
		tblCFAccount.intCustomerId,			
		tblCFAccount.intDiscountDays,			
		tblCFAccount.intDiscountScheduleId,	
		tblCFAccount.intSalesPersonId,		
		tblCFPriceProfileDetail.intPriceProfileDetailId,	
		tblCFPriceProfileHeader.intPriceProfileHeaderId,	
		tblCFPriceProfileDetail.intItemId,				
		tblCFPriceProfileDetail.intNetworkId,			
		tblCFPriceProfileDetail.intSiteGroupId,			
		tblCFPriceProfileDetail.intSiteId,				
		intLocalPricingIndex,	
		tblCFPriceProfileDetail.dblRate,					
		tblCFPriceProfileDetail.strBasis,				
		tblCFPriceProfileHeader.strType,
		tblCFPriceProfileHeader.intLinkedProfile,
		tblCFPriceIndex.strType,
		tblCFPriceProfileHeader.strPriceProfile,
		tblCFPriceIndex.strPriceIndex,
		tblCFPriceProfileDetail.ysnForceRounding,
		@strGUID

	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFAccount
	ON tblCFImportTransactionStagingTable.intAccountId = tblCFAccount.intAccountId
	AND tblCFAccount.intCustomerId = tblCFImportTransactionStagingTable.intPrcCustomerId 
	INNER JOIN tblCFPriceProfileHeader
	ON tblCFAccount.intExtRemotePriceProfileId = tblCFPriceProfileHeader.intPriceProfileHeaderId
	INNER JOIN tblCFPriceProfileDetail
	ON tblCFPriceProfileHeader.intPriceProfileHeaderId = tblCFPriceProfileDetail.intPriceProfileHeaderId
	LEFT JOIN tblCFPriceIndex
	ON tblCFPriceIndex.intPriceIndexId = tblCFPriceProfileDetail.intLocalPricingIndex
	WHERE tblCFPriceProfileHeader.strType = tblCFImportTransactionStagingTable.strTransactionType
	AND tblCFImportTransactionStagingTable.ysnGlobalProfile = 0
	AND strGUID = @strGUID


	SELECT 'tblCFImportTransactionPriceProfile',* FROM tblCFImportTransactionPriceProfile
	

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND tblCFImportTransactionPriceProfile.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	SELECT '1'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable




	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '2'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable
	
	

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
	AND tblCFImportTransactionPriceProfile.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND tblCFImportTransactionPriceProfile.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	
	SELECT '3'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
	AND ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	AND tblCFImportTransactionPriceProfile.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	

	
	SELECT '4'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 	 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
	AND tblCFImportTransactionPriceProfile.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND ISNULL(tblCFImportTransactionPriceProfile.intNetworkId,0) = 0 -- ALL NETWORKS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '5'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE  tblCFImportTransactionPriceProfile.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
	AND ISNULL(tblCFImportTransactionPriceProfile.intNetworkId,0) = 0 -- ALL NETWORKS
	AND ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '6'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND tblCFImportTransactionPriceProfile.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteGroupId,0) = 0 -- ALL SITES GROUPS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '7'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

		
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteGroupId,0) = 0 -- ALL SITES GROUPS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '8'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE tblCFImportTransactionPriceProfile.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND ISNULL(tblCFImportTransactionPriceProfile.intNetworkId,0) = 0 -- ALL NETWORKS
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteGroupId,0) = 0 -- ALL SITES GROUPS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	SELECT '9'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPriceProfileRate		= tblCFImportTransactionPriceProfile.dblRate
		,intPriceProfileId			= tblCFImportTransactionPriceProfile.intPriceProfileHeaderId
		,intPriceProfileDetailId	= tblCFImportTransactionPriceProfile.intPriceProfileDetailId
		,intPriceIndexId			= tblCFImportTransactionPriceProfile.intLocalPricingIndex
		,strPriceBasis				= tblCFImportTransactionPriceProfile.strBasis
		,strIndexType				= tblCFImportTransactionPriceProfile.strIndexType
		,strPriceIndexId			= tblCFImportTransactionPriceProfile.strPriceIndexId
		,strPriceProfileId			= tblCFImportTransactionPriceProfile.strPriceProfileId
		,ysnForceRounding			= tblCFImportTransactionPriceProfile.ysnForceRounding
		,ysnPriceProfileMatch		= 1
		,strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionPriceProfile 
	WHERE ISNULL(tblCFImportTransactionPriceProfile.intItemId,0) = 0 -- ALL ITEMS
	AND ISNULL(tblCFImportTransactionPriceProfile.intNetworkId,0) = 0 -- ALL NETWORKS
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteId,0) = 0 -- ALL SITES
	AND ISNULL(tblCFImportTransactionPriceProfile.intSiteGroupId,0) = 0 -- ALL SITES GROUPS
	AND (tblCFImportTransactionStagingTable.ysnPriceProfileMatch IS NULL OR tblCFImportTransactionStagingTable.ysnPriceProfileMatch = 0)
	AND tblCFImportTransactionPriceProfile.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.strGUID = tblCFImportTransactionPriceProfile.strGUID
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID


	
	SELECT '10'
	 dblPriceProfileRate		
	,intPriceProfileId			
	,intPriceProfileDetailId	
	,intPriceIndexId			
	,strPriceBasis				
	,strIndexType				
	,strPriceIndexId			
	,strPriceProfileId			
	,ysnForceRounding			
	,ysnPriceProfileMatch		
	FROM tblCFImportTransactionStagingTable



	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblPrice,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblPrice,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Local/Network'
	AND strPriceBasis = 'Pump Price Adjustment'
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Local/Network'
	AND strPriceBasis = 'Transfer Cost'
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Local/Network'
	AND strPriceBasis = 'Transfer Cost'
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET dblIndexPrice  = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC),
		dtmPriceIndexDate = (SELECT TOP 1 dtmDate
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC)
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Local/Network'
	AND LOWER(strPriceBasis) LIKE '%index%'
	AND strGUID = @strGUID

	SELECT strTransactionType,strPriceBasis,dblPrice,dblIndexPrice,dtmPriceIndexDate,* FROM tblCFImportTransactionStagingTable


	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile',
		strPriceBasis = strPriceBasis + ' ' + strIndexType 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Local/Network'
	AND LOWER(strPriceBasis) LIKE '%index%'
	AND dblIndexPrice IS NOT NULL
	AND strGUID = @strGUID


	

	UPDATE tblCFImportTransactionStagingTable 
	SET dblIndexPrice  = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC),
		dtmPriceIndexDate = (SELECT TOP 1 dtmDate
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC)
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Remote'
	AND LOWER(strPriceBasis) LIKE '%index%'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile',
		strPriceBasis = strPriceBasis + ' ' + strIndexType 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Remote'
	AND LOWER(strPriceBasis) LIKE '%index%'
	AND dblIndexPrice IS NOT NULL
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Remote'
	AND (strPriceBasis = 'Transfer Cost' OR strPriceBasis = 'Transfer Price')
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Extended Remote'
	AND strPriceBasis = 'Transfer Cost' 
	AND strGUID = @strGUID

	--SELECT
	--dblTransferCost,
	--strGUID,
	--strPriceBasis,
	--dblPricingPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
	--	dblPrice = ISNULL(dblTransferCost,0) + ISNULL(dblPriceProfileRate,0),
	--	strPriceMethod = 'Price Profile' 
	--FROM tblCFImportTransactionStagingTable
	--WHERE strTransactionType = 'Extended Remote'
	----AND strPriceBasis = 'Transfer Cost' 
	--AND strGUID = '653f9f1c407d4a4785995f5e91bcaca4'

	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblPrice,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblPrice,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile' 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Extended Remote'
	AND strPriceBasis = 'Pump Price Adjustment' 
	AND strGUID = @strGUID



	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblIndexPrice  = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC),
		dtmPriceIndexDate = (SELECT TOP 1 dtmDate
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = tblCFImportTransactionStagingTable.intPriceIndexId 
										AND IPH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
										AND IPD.intARItemID = tblCFImportTransactionStagingTable.intARItemId
										AND IPH.dtmDate <= tblCFImportTransactionStagingTable.dtmTransactionDate 
										ORDER BY IPH.dtmDate DESC)
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Extended Remote'
	AND strPriceBasis IS NOT NULL 
	AND strPriceBasis NOT IN ('Transfer Cost', 'Pump Price Adjustment')
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET dblPricingPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		dblPrice = ISNULL(dblIndexPrice,0) + ISNULL(dblPriceProfileRate,0),
		strPriceMethod = 'Price Profile',
		strPriceBasis = strPriceBasis + ' ' + strIndexType 
	FROM tblCFImportTransactionStagingTable
	WHERE strTransactionType = 'Extended Remote'
	AND strPriceBasis IS NOT NULL 
	AND strPriceBasis NOT IN ('Transfer Cost', 'Pump Price Adjustment')
	AND dblIndexPrice IS NOT NULL
	AND strGUID = @strGUID


	--TODO: LINKED PROFILE 


	
	UPDATE tblCFImportTransactionStagingTable 
	SET dblAdjustmentRate = (SELECT TOP 1 ISNULL(dblRate,0) 
							FROM tblCFSiteGroupPriceAdjustment ADJ
							INNER JOIN tblCFSiteGroupPriceAdjustmentHeader ADJH
							ON ADJ.intSiteGroupPriceAdjustmentHeaderId = ADJH.intSiteGroupPriceAdjustmentHeaderId
							WHERE ADJH.intSiteGroupId = tblCFImportTransactionStagingTable.intSiteGroupId
							AND intARItemId = tblCFImportTransactionStagingTable.intARItemId
							AND ISNULL(intPriceGroupId,0) = ISNULL(tblCFImportTransactionStagingTable.intPriceRuleGroup,0)
							AND ADJH.dtmEffectiveDate <= tblCFImportTransactionStagingTable.dtmTransactionDate
							ORDER BY ADJH.dtmEffectiveDate DESC)
	FROM tblCFImportTransactionStagingTable
	WHERE strPriceMethod = 'Price Profile'
	AND strGUID = @strGUID



	UPDATE tblCFImportTransactionStagingTable
	SET dblPricingPrice = ISNULL(dblPricingPrice,0) + ISNULL(dblAdjustmentRate,0),
		dblPrice =  ISNULL(dblPricingPrice,0) + ISNULL(dblAdjustmentRate,0)
	FROM tblCFImportTransactionStagingTable
	WHERE strPriceMethod = 'Price Profile'
	AND strGUID = @strGUID


	SELECT dblAdjustmentRate,dblPricingPrice,
	dblPricingPrice = ISNULL(dblPricingPrice,0) + ISNULL(dblAdjustmentRate,0),
		dblPrice =  ISNULL(dblPricingPrice,0) + ISNULL(dblAdjustmentRate,0)
	FROM tblCFImportTransactionStagingTable
	WHERE strPriceMethod = 'Price Profile'



	
	
	UPDATE tblCFImportTransactionStagingTable
	SET dblOriginalPrice = ISNULL(dblTransferCost,0)
	FROM tblCFImportTransactionStagingTable
	WHERE LOWER(strPriceMethod) = 'network cost' OR LOWER(strPriceBasis) = 'transfer cost'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 strSiteGroup = tblCFSiteGroup.strSiteGroup
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFSiteGroup
	ON tblCFImportTransactionStagingTable.intSiteGroupId = tblCFSiteGroup.intSiteGroupId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblPrice = dbo.fnCFForceRounding(ISNULL(dblPrice,0))
	FROM tblCFImportTransactionStagingTable
	WHERE strPriceMethod = 'Price Profile'
	AND ISNULL(ysnForceRounding,0) = 1
	AND strGUID = @strGUID
	

	
SELECT tblCFImportTransactionStagingTable.dblPrice,dblOriginalPrice,dblOriginalPrice FROM tblCFImportTransactionStagingTable

	---------
	--TAXES--
	---------

	TAXCOMPUTATION:



	-------------------------------------------------------------------------------------------

	DELETE FROM tblCFImportTransactionRemoteOriginalTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionRemoteCalculatedTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionRemoteTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxExempt WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTax WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTaxZeroQuantity WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxZeroQuantity WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxExemptZeroQuantity WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTaxZeroQuantity WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTaxType WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionPricingType WHERE strGUID = @strGUID



	--SELECT 'i',* FROM tblCFImportTransactionRemoteOriginalTax					--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionRemoteCalculatedTax					--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionRemoteTax							--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionOriginalTax							--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionCalculatedTax						--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionCalculatedTaxExempt					--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionTax									--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionOriginalTaxZeroQuantity				--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionCalculatedTaxZeroQuantity			--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionCalculatedTaxExemptZeroQuantity		--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionTaxZeroQuantity						--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionTaxType								--WHERE strGUID = @strGUID
	--SELECT 'i',* FROM tblCFImportTransactionPricingType							--WHERE strGUID = @strGUID


	

	
	UPDATE tblCFImportTransactionStagingTable
	SET strTaxCodes = NULL
	,ysnDisregardTaxExemption = 1
	WHERE strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET strSiteApplyExemption =tblCFSite.strAllowExemptionsOnExtAndRetailTrans 
	FROM tblCFSite	  
	WHERE tblCFSite.intSiteId	 = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET strNetworkApplyExemption =tblCFNetwork.strAllowExemptionsOnExtAndRetailTrans 
	FROM tblCFNetwork 
	WHERE tblCFNetwork.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND strGUID = @strGUID

	-------------------------------------------------------
	------				TAX COMPUTATION					 --
	-------------------------------------------------------

	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 0
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType IS NULL OR strProcessType = 'invoice')
	AND LOWER(strTransactionType) = 'extended remote'
	AND ( 
		(LOWER(ISNULL(strNetworkApplyExemption,'no')) = 'yes' AND LOWER(ISNULL(strSiteApplyExemption,'no')) = 'yes')
		OR
		(LOWER(ISNULL(strNetworkApplyExemption,'no')) = 'no' AND LOWER(ISNULL(strSiteApplyExemption,'no')) = 'yes')
		)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType IS NULL OR strProcessType = 'invoice')
	AND LOWER(strTransactionType) = 'extended remote'
	AND ( 
		(LOWER(ISNULL(strNetworkApplyExemption,'no')) = 'no' AND LOWER(ISNULL(strSiteApplyExemption,'no')) = 'no')
		OR
		(LOWER(ISNULL(strNetworkApplyExemption,'no')) = 'yes' AND LOWER(ISNULL(strSiteApplyExemption,'no')) = 'no')
		)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 0
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType IS NULL OR strProcessType = 'invoice')
	AND LOWER(strTransactionType) != 'extended remote'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 0
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType IS NULL OR strProcessType = 'invoice')
	AND LOWER(strTransactionType) != 'extended remote'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 0
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType != 'invoice')
	AND ISNULL(ysnQuoteTaxExemption,0) = 1
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDisregardTaxExemption = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE (strProcessType != 'invoice')
	AND ISNULL(ysnQuoteTaxExemption,0) = 0
	AND strGUID = @strGUID
	
	

	
	UPDATE tblCFImportTransactionStagingTable
	SET strTaxCodes = (SELECT COALESCE(strTaxCodes + ', ', '') + CONVERT(varchar(10), intTaxCodeId)
						FROM tblCFTransactionTax
						WHERE tblCFTransactionTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId)
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFTransactionTax
	ON tblCFImportTransactionStagingTable.intTransactionId = tblCFTransactionTax.intTransactionId
	WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
	AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
	AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
	AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
	AND (tblCFImportTransactionStagingTable.intTransactionId is not null)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET strTaxState = (SELECT TOP 1 strTaxState from tblCFSite where intSiteId = tblCFImportTransactionStagingTable.intSiteId)
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFTransactionTax
	ON tblCFImportTransactionStagingTable.intTransactionId = tblCFTransactionTax.intTransactionId
	WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
	AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
	AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
	AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
	AND (tblCFImportTransactionStagingTable.intTransactionId is not null)
	AND (
			(tblCFImportTransactionStagingTable.isImporting = 0 OR tblCFImportTransactionStagingTable.isImporting IS NULL)
			OR
			(tblCFImportTransactionStagingTable.strTaxState = '' OR tblCFImportTransactionStagingTable.strTaxState IS NULL)  
		)
	AND strGUID = @strGUID

	
	INSERT INTO tblCFImportTransactionRemoteOriginalTax (
		 [intTransactionId]					
		,[intTransactionDetailTaxId]	
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
		,strGUID 			
	)
	SELECT
	 tblCFImportTransactionStagingTable.intTransactionId
	,tblCFRemoteTax.[intTransactionDetailTaxId]
	,tblCFRemoteTax.[intTransactionDetailId]  AS [intInvoiceDetailId]
	,NULL
	,tblCFRemoteTax.[intTaxGroupId]
	,tblCFRemoteTax.[intTaxCodeId]
	,tblCFRemoteTax.[intTaxClassId]
	,tblCFRemoteTax.[strTaxableByOtherTaxes]
	,tblCFRemoteTax.[strCalculationMethod]
	,tblCFRemoteTax.[dblRate]
	, --[dblTax]
		(CASE WHEN tblCFImportTransactionStagingTable.strNetworkType  = 'CFN'
		THEN
			tblCFRemoteTax.[dblRate]
		ELSE
			tblCFRemoteTax.[dblTax]
		END)
	,--[dblAdjustedTax]
		(CASE WHEN tblCFImportTransactionStagingTable.strNetworkType  = 'CFN'
		THEN
			tblCFRemoteTax.[dblRate]
		ELSE
			tblCFRemoteTax.[dblAdjustedTax]
		END)
	,tblCFRemoteTax.[intTaxAccountId]    AS [intSalesTaxAccountId]
	,tblCFRemoteTax.[ysnSeparateOnInvoice]
	,tblCFRemoteTax.[ysnCheckoffTax]
	,tblCFRemoteTax.[strTaxCode]
	,tblCFRemoteTax.[ysnTaxExempt]
	,tblCFRemoteTax.[ysnTaxOnly]
	,tblCFRemoteTax.[strTaxGroup]
	,tblCFRemoteTax.[ysnInvalidSetup]
	,tblCFRemoteTax.[strReason]
	,tblCFRemoteTax.[strNotes]
	,@strGUID	
FROM tblCFImportTransactionStagingTable
CROSS APPLY 
	[dbo].[fnCFRemoteTaxes](
	 tblCFImportTransactionStagingTable.strTaxState		
	,tblCFImportTransactionStagingTable.strTaxCodes
	,tblCFImportTransactionStagingTable.dblFederalExciseTaxRate        	
	,tblCFImportTransactionStagingTable.dblStateExciseTaxRate1         	
	,tblCFImportTransactionStagingTable.dblStateExciseTaxRate2         	
	,tblCFImportTransactionStagingTable.dblCountyExciseTaxRate         	
	,tblCFImportTransactionStagingTable.dblCityExciseTaxRate           	
	,tblCFImportTransactionStagingTable.dblStateSalesTaxPercentageRate 	
	,tblCFImportTransactionStagingTable.dblCountySalesTaxPercentageRate		
	,tblCFImportTransactionStagingTable.dblCitySalesTaxPercentageRate  		
	,tblCFImportTransactionStagingTable.dblOtherSalesTaxPercentageRate 
	,tblCFImportTransactionStagingTable.dblFederalExciseTax1	
	,tblCFImportTransactionStagingTable.dblFederalExciseTax2	
	,tblCFImportTransactionStagingTable.dblStateExciseTax1	
	,tblCFImportTransactionStagingTable.dblStateExciseTax2	
	,tblCFImportTransactionStagingTable.dblStateExciseTax3	
	,tblCFImportTransactionStagingTable.dblCountyTax1		
	,tblCFImportTransactionStagingTable.dblCityTax1			
	,tblCFImportTransactionStagingTable.dblStateSalesTax		
	,tblCFImportTransactionStagingTable.dblCountySalesTax	
	,tblCFImportTransactionStagingTable.dblCitySalesTax			
	,tblCFImportTransactionStagingTable.intNetworkId
	,tblCFImportTransactionStagingTable.intARItemId				
	,tblCFImportTransactionStagingTable.intARItemLocationId			
	,tblCFImportTransactionStagingTable.intPrcCustomerId				
	,tblCFImportTransactionStagingTable.intCustomerLocationId		
	,tblCFImportTransactionStagingTable.dtmTransactionDate
	,tblCFImportTransactionStagingTable.ysnDisregardExemptionSetup	
	,tblCFImportTransactionStagingTable.strTax1						
	,tblCFImportTransactionStagingTable.strTax2						
	,tblCFImportTransactionStagingTable.strTax3						
	,tblCFImportTransactionStagingTable.strTax4						
	,tblCFImportTransactionStagingTable.strTax5						
	,tblCFImportTransactionStagingTable.strTax6						
	,tblCFImportTransactionStagingTable.strTax7						
	,tblCFImportTransactionStagingTable.strTax8						
	,tblCFImportTransactionStagingTable.strTax9						
	,tblCFImportTransactionStagingTable.strTax10						
	,tblCFImportTransactionStagingTable.dblTaxValue1					
	,tblCFImportTransactionStagingTable.dblTaxValue2					
	,tblCFImportTransactionStagingTable.dblTaxValue3					
	,tblCFImportTransactionStagingTable.dblTaxValue4					
	,tblCFImportTransactionStagingTable.dblTaxValue5					
	,tblCFImportTransactionStagingTable.dblTaxValue6					
	,tblCFImportTransactionStagingTable.dblTaxValue7					
	,tblCFImportTransactionStagingTable.dblTaxValue8					
	,tblCFImportTransactionStagingTable.dblTaxValue9					
	,tblCFImportTransactionStagingTable.dblTaxValue10
	,tblCFImportTransactionStagingTable.intSiteId						
	,tblCFImportTransactionStagingTable.intCardId					
	,tblCFImportTransactionStagingTable.intVehicleId				
	,tblCFImportTransactionStagingTable.intFreightTermId			
	)
 AS tblCFRemoteTax
 WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND strGUID = @strGUID


UPDATE tblCFImportTransactionRemoteOriginalTax
SET 
dblRate = tblCFTransactionTax.dblTaxRate 
,dblTax = tblCFTransactionTax.dblTaxOriginalAmount  
FROM tblCFImportTransactionRemoteOriginalTax
INNER JOIN tblCFImportTransactionStagingTable
ON tblCFImportTransactionRemoteOriginalTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
INNER JOIN tblCFTransactionTax
ON	tblCFTransactionTax.intTransactionId = tblCFImportTransactionRemoteOriginalTax.intTransactionId
AND tblCFTransactionTax.intTaxCodeId = tblCFImportTransactionRemoteOriginalTax.intTaxCodeId
WHERE(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND (tblCFImportTransactionStagingTable.isImporting IS NULL OR tblCFImportTransactionStagingTable.isImporting = 0) 
AND (tblCFImportTransactionRemoteOriginalTax.strCalculationMethod != '' OR tblCFImportTransactionRemoteOriginalTax.strCalculationMethod IS NOT NULL)
AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

INSERT INTO tblCFTransactionNote (
	intTransactionId
	,strProcess
	,dtmProcessDate
	,strNote
	,strGuid
)

SELECT 
	tblCFImportTransactionStagingTable.intTransactionId
	,'Calculation'
	,tblCFImportTransactionStagingTable.strProcessDate
	,ISNULL(tblCFImportTransactionRemoteOriginalTax.strReason,'Invalid Setup -' + tblCFImportTransactionRemoteOriginalTax.strTaxCode)
	,tblCFImportTransactionStagingTable.strGUID
FROM tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionRemoteOriginalTax
ON tblCFImportTransactionStagingTable.intTransactionId = tblCFImportTransactionRemoteOriginalTax.intTransactionId
WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup =1 )
AND LOWER(tblCFImportTransactionRemoteOriginalTax.strReason) NOT LIKE '%item category%'
AND (tblCFImportTransactionRemoteOriginalTax.ysnTaxExempt IS NULL OR  tblCFImportTransactionRemoteOriginalTax.ysnTaxExempt = 0)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID
--AND (tblCFImportTransactionStagingTable.ysnReRunCalcTax IS NULL OR  tblCFImportTransactionStagingTable.ysnReRunCalcTax = 0)


INSERT INTO tblCFFailedImportedTransaction (
	intTransactionId
	,strFailedReason
)

SELECT 
	 tblCFImportTransactionStagingTable.intTransactionId
	,tblCFImportTransactionRemoteOriginalTax.strReason
FROM tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionRemoteOriginalTax
ON tblCFImportTransactionStagingTable.intTransactionId = tblCFImportTransactionRemoteOriginalTax.intTransactionId
WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup =1 )
AND LOWER(tblCFImportTransactionRemoteOriginalTax.strReason) like '%unable to find match for%'
AND tblCFImportTransactionStagingTable.strGUID = @strGUID


UPDATE tblCFImportTransactionStagingTable
SET tblCFImportTransactionStagingTable.ysnInvalid = 1
FROM tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionRemoteOriginalTax
ON tblCFImportTransactionStagingTable.intTransactionId = tblCFImportTransactionRemoteOriginalTax.intTransactionId
WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup =1 )
AND LOWER(tblCFImportTransactionRemoteOriginalTax.strReason) like '%unable to find match for%'
AND tblCFImportTransactionStagingTable.strGUID = @strGUID
-------------------------------------------------------------------------------------


SELECT 'dblPrice1',dblPrice FROm tblCFImportTransactionStagingTable

DECLARE @RemoteLineItemTaxEntries LineItemTaxDetailStagingTable

DECLARE @CalculatedTaxExemptParam ConstructLineItemTaxDetailParam
DECLARE @CalculatedTaxExemptParamZeroQty ConstructLineItemTaxDetailParam

DECLARE @OriginalTaxExemptParam ConstructLineItemTaxDetailParam
DECLARE @OriginalTaxExemptParamZeroQty ConstructLineItemTaxDetailParam


DECLARE @CalculatedTaxParam ConstructLineItemTaxDetailParam
DECLARE @CalculatedTaxParamZeroQty ConstructLineItemTaxDetailParam

DECLARE @OriginalTaxParam ConstructLineItemTaxDetailParam
DECLARE @OriginalTaxParamZeroQty ConstructLineItemTaxDetailParam

DELETE FROM @RemoteLineItemTaxEntries 
DELETE FROM @CalculatedTaxExemptParam 
DELETE FROM @CalculatedTaxExemptParamZeroQty 
DELETE FROM @OriginalTaxExemptParam 
DELETE FROM @OriginalTaxExemptParamZeroQty 
DELETE FROM @CalculatedTaxParam 
DELETE FROM @CalculatedTaxParamZeroQty 
DELETE FROM @OriginalTaxParam 
DELETE FROM @OriginalTaxParamZeroQty 
	

INSERT INTO @RemoteLineItemTaxEntries(
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
	,tblCFImportTransactionStagingTable.[intTransactionId]  		
	,tblCFImportTransactionStagingTable.[intTaxGroupId]			
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
	,CASE WHEN (ISNULL(ysnDisregardTaxExemption,0) = 1 ) THEN 0 ELSE ysnTaxExempt END
	,ISNULL([ysnTaxOnly],0)	
	,[strNotes]  				
FROM tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionRemoteOriginalTax
ON tblCFImportTransactionStagingTable.intTransactionId = tblCFImportTransactionRemoteOriginalTax.intTransactionId
WHERE (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0 )
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

---- CHECK IF THERE IS TAX RECORD TO COMPUTE > IF NONE GO TO PRICE CALCULATION 
---- THIS WILL AVOID AR SP TO COMPUTE TAX BASE ON COMPANY LOCATION OR CUSTOMER LOCATION DEFAULT TAX GROUP
--IF((SELECT COUNT(1) FROM @LineItemTaxDetailStagingTable) = 0)
--BEGIN 
--	GOTO PRICECALCULATION
--END
-----------------------------------------------------------------


UPDATE tblCFImportTransactionStagingTable 
SET 
ysnBackOutCalculationForCalculatedTax = CASE 
WHEN 
(CHARINDEX('retail',LOWER(tblCFImportTransactionStagingTable.strPriceBasis)) > 0 
OR CHARINDEX('pump price adjustment',LOWER(tblCFImportTransactionStagingTable.strPriceBasis)) > 0 
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Credit Card' 
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Posted Trans from CSV'
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Origin History'
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Network Cost')
THEN 1
ELSE 0
END,
ysnBackOutCalculationForOriginalTax = CASE 
WHEN 
(CHARINDEX('retail',LOWER(tblCFImportTransactionStagingTable.strPriceBasis)) > 0 
OR CHARINDEX('pump price adjustment',LOWER(tblCFImportTransactionStagingTable.strPriceBasis)) > 0 
OR CHARINDEX('transfer cost',LOWER(tblCFImportTransactionStagingTable.strPriceBasis)) > 0 
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Import File Price' 
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Credit Card' 
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Posted Trans from CSV'
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Origin History'
OR tblCFImportTransactionStagingTable.strPriceMethod = 'Network Cost')
THEN 1
ELSE 0
END
WHERE strGUID = @strGUID


SELECT 
tblCFImportTransactionStagingTable.intNetworkId
,tblCFImportTransactionStagingTable.strSiteId
,tblCFImportTransactionStagingTable.strSiteName
,dblPrice
,strPriceMethod
,dblPrice
FROM tblCFImportTransactionStagingTable
WHERE strGUID = @strGUID


INSERT INTO @CalculatedTaxExemptParam
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblQuantity
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE ISNULL(tblCFImportTransactionStagingTable.dblQuantity,0) * ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) END 
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
--AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0 )
AND ISNULL(tblCFImportTransactionStagingTable.ysnDisregardTaxExemption,0) = 0 
AND strGUID = @strGUID


SELECT '@CalculatedTaxExemptParam'
SELECT '@CalculatedTaxExemptParam', * FROM @CalculatedTaxExemptParam

INSERT INTO @CalculatedTaxExemptParamZeroQty
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblZeroQuantity
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE tblCFImportTransactionStagingTable.dblZeroQuantity * ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) END 
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND
 (tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
--AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0 )
AND ISNULL(tblCFImportTransactionStagingTable.ysnDisregardTaxExemption,0) = 0 
AND strGUID = @strGUID

--SELECT '@CalculatedTaxExemptParamZeroQty'
--SELECT '@CalculatedTaxExemptParamZeroQty', * FROM @CalculatedTaxExemptParamZeroQty

INSERT INTO @OriginalTaxExemptParam
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblQuantity
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE tblCFImportTransactionStagingTable.dblQuantity * tblCFImportTransactionStagingTable.dblOriginalPrice END 
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN tblCFImportTransactionStagingTable.dblOriginalPrice ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
--AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0 )
AND ISNULL(tblCFImportTransactionStagingTable.ysnDisregardTaxExemption,0) = 0 
AND strGUID = @strGUID


--SELECT '@OriginalTaxExemptParam'
--SELECT '@OriginalTaxExemptParam', * FROM @OriginalTaxExemptParam


INSERT INTO @OriginalTaxExemptParamZeroQty
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblZeroQuantity
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE tblCFImportTransactionStagingTable.dblZeroQuantity * tblCFImportTransactionStagingTable.dblOriginalPrice END 
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN tblCFImportTransactionStagingTable.dblOriginalPrice ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
--AND (tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup IS NULL OR tblCFImportTransactionRemoteOriginalTax.ysnInvalidSetup = 0 )
AND ISNULL(tblCFImportTransactionStagingTable.ysnDisregardTaxExemption,0) = 0 
AND strGUID = @strGUID


--SELECT '@OriginalTaxExemptParamZeroQty'
--SELECT '@OriginalTaxExemptParamZeroQty', * FROM @OriginalTaxExemptParamZeroQty

INSERT INTO @CalculatedTaxParam
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblQuantity
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE ISNULL(tblCFImportTransactionStagingTable.dblQuantity,0) * ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) END 
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,tblCFImportTransactionStagingTable.ysnDisregardTaxExemption
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
AND strGUID = @strGUID

SELECT '@CalculatedTaxParam'
SELECT '@CalculatedTaxParam', * FROM @CalculatedTaxParam

INSERT INTO @CalculatedTaxParamZeroQty
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblZeroQuantity
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE ISNULL(tblCFImportTransactionStagingTable.dblZeroQuantity,0) * ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) END 
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForCalculatedTax = 0) THEN ISNULL(tblCFImportTransactionStagingTable.dblPrice,0) ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,tblCFImportTransactionStagingTable.ysnDisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND strGUID = @strGUID

SELECT '@CalculatedTaxParamZeroQty'
SELECT '@CalculatedTaxParamZeroQty', * FROM @CalculatedTaxParamZeroQty

INSERT INTO @OriginalTaxParam
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblQuantity
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE tblCFImportTransactionStagingTable.dblQuantity * tblCFImportTransactionStagingTable.dblOriginalPrice END 
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN tblCFImportTransactionStagingTable.dblOriginalPrice ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE 
--(tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
AND strGUID = @strGUID

SELECT '@OriginalTaxParam'
SELECT '@OriginalTaxParam', * FROM @OriginalTaxParam

INSERT INTO @OriginalTaxParamZeroQty
(
  dblQuantity						
, dblGrossAmount					
, ysnReversal						
, intItemId							
, intEntityCustomerId				
, intCompanyLocationId				
, intTaxGroupId						
, dblPrice							
, dtmTransactionDate				
, intShipToLocationId				
, ysnIncludeExemptedCodes			
, ysnIncludeInvalidCodes			
, intSiteId							
, intFreightTermId					
, intCardId							
, intVehicleId						
, ysnDisregardExemptionSetup		
, ysnExcludeCheckOff				
, intItemUOMId						
, intCFSiteId						
, ysnDeliver						
, ysnCFQuote					    
, intCurrencyId						
, intCurrencyExchangeRateTypeId		
, dblCurrencyExchangeRate				
, intLineItemId						
)
SELECT 
 tblCFImportTransactionStagingTable.dblZeroQuantity
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE tblCFImportTransactionStagingTable.dblZeroQuantity * tblCFImportTransactionStagingTable.dblOriginalPrice END 
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN 0 ELSE 1 END
,tblCFImportTransactionStagingTable.intARItemId
,tblCFImportTransactionStagingTable.intPrcCustomerId
,tblCFImportTransactionStagingTable.intARItemLocationId
,tblCFImportTransactionStagingTable.intTaxGroupId
,CASE WHEN (ysnBackOutCalculationForOriginalTax = 0) THEN tblCFImportTransactionStagingTable.dblOriginalPrice ELSE 0 END 
,tblCFImportTransactionStagingTable.dtmTransactionDate
,NULL
,1
,0			--@IncludeInvalidCodes
,NULL
,tblCFImportTransactionStagingTable.intFreightTermId
,tblCFImportTransactionStagingTable.intCardId		
,tblCFImportTransactionStagingTable.intVehicleId
,1 --@DisregardExemptionSetup
,0
,tblCFImportTransactionStagingTable.intItemUOMId	--intItemUOMId			
,tblCFImportTransactionStagingTable.intSiteId
,0		--@IsDeliver	
,tblCFImportTransactionStagingTable.isQuote								 
,NULL	--@CurrencyId
,NULL	--@@CurrencyExchangeRateTypeId
,NULL	--@@CurrencyExchangeRate	
,tblCFImportTransactionStagingTable.intTransactionId
FROM tblCFImportTransactionStagingTable
WHERE
-- (tblCFImportTransactionStagingTable.ysnReRunForSpecialTax = 0 OR tblCFImportTransactionStagingTable.ysnReRunCalcTax = 1)
--AND 
(tblCFImportTransactionStagingTable.ysnPostedCSV IS NULL OR tblCFImportTransactionStagingTable.ysnPostedCSV = 0)
AND (tblCFImportTransactionStagingTable.ysnPostedOrigin = 0 OR tblCFImportTransactionStagingTable.ysnPostedOrigin IS NULL)
--AND (LOWER(tblCFImportTransactionStagingTable.strTransactionType) like '%remote%')
--AND (tblCFImportTransactionStagingTable.intTaxGroupId IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupId = 0 )
AND strGUID = @strGUID

SELECT '@OriginalTaxParamZeroQty'
SELECT '@OriginalTaxParamZeroQty', * FROM @OriginalTaxParamZeroQty



DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


SELECT '@RemoteLineItemTaxEntries', * FROM @RemoteLineItemTaxEntries


EXEC uspARConstructLineItemTaxDetail
@CalculatedTaxExemptParam,
@RemoteLineItemTaxEntries,
@strGUID

INSERT INTO tblCFImportTransactionCalculatedTaxExempt(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


EXEC uspARConstructLineItemTaxDetail
@CalculatedTaxExemptParamZeroQty,
@RemoteLineItemTaxEntries,	
@strGUID

INSERT INTO tblCFImportTransactionCalculatedTaxExemptZeroQuantity(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


--UPDATE tblCFImportTransactionCalculatedTaxExemptZeroQuantity
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionCalculatedTaxExemptZeroQuantity


EXEC uspARConstructLineItemTaxDetail
@OriginalTaxExemptParam,
@RemoteLineItemTaxEntries,
@strGUID


INSERT INTO tblCFImportTransactionOriginalTaxExempt(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

--UPDATE tblCFImportTransactionOriginalTaxExempt
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionOriginalTaxExempt

EXEC uspARConstructLineItemTaxDetail
@OriginalTaxExemptParamZeroQty,
@RemoteLineItemTaxEntries,	
@strGUID

INSERT INTO tblCFImportTransactionOriginalTaxExemptZeroQuantity(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


--UPDATE tblCFImportTransactionOriginalTaxExemptZeroQuantity
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionOriginalTaxExemptZeroQuantity


EXEC uspARConstructLineItemTaxDetail
@CalculatedTaxParam,
@RemoteLineItemTaxEntries,
@strGUID

INSERT INTO tblCFImportTransactionCalculatedTax(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID



DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


--UPDATE tblCFImportTransactionCalculatedTax
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionCalculatedTax

EXEC uspARConstructLineItemTaxDetail
@CalculatedTaxParamZeroQty,
@RemoteLineItemTaxEntries,
@strGUID


INSERT INTO tblCFImportTransactionCalculatedTaxZeroQuantity(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

--UPDATE tblCFImportTransactionCalculatedTaxZeroQuantity
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionCalculatedTaxZeroQuantity

EXEC uspARConstructLineItemTaxDetail
@OriginalTaxParam,
@RemoteLineItemTaxEntries,
@strGUID


INSERT INTO tblCFImportTransactionOriginalTax(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

SELECT * FROM tblCFImportTransactionOriginalTax

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID


--UPDATE tblCFImportTransactionOriginalTax
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionOriginalTax

EXEC uspARConstructLineItemTaxDetail
@OriginalTaxParamZeroQty,
@RemoteLineItemTaxEntries,
@strGUID


INSERT INTO tblCFImportTransactionOriginalTaxZeroQuantity(
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, [strGUID]
, [intTransactionId]
)
SELECT 
  [intTaxGroupId]
, [intTaxCodeId]
, [intTaxClassId]
, [strTaxableByOtherTaxes]
, [strCalculationMethod]
, [dblRate]
, [dblBaseRate]
, [dblExemptionPercent]
, [dblTax]
, [dblAdjustedTax]
, [intTaxAccountId]
, [ysnCheckoffTax]
, [ysnTaxExempt]
, [ysnTaxOnly]
, [ysnInvalidSetup]
, [strNotes]
, [dblExemptionAmount]
, [intLineItemId]
, @strGUID
, [intLineItemId]
FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

DELETE FROM tblARConstructLineItemTaxDetailResult
WHERE strRequestId = @strGUID

--UPDATE tblCFImportTransactionOriginalTaxZeroQuantity
--SET intTransactionId = intLineItemId
--SELECT * FROM tblCFImportTransactionOriginalTaxZeroQuantity



-- OVERRIDE TAX FOR CFN ONLY --	

UPDATE tblCFImportTransactionOriginalTax
SET dblTax = li.dblTax,
	dblAdjustedTax = li.dblAdjustedTax
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionOriginalTax AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

UPDATE tblCFImportTransactionOriginalTaxZeroQuantity 
SET dblTax = (li.dblTax / dblQuantity) * dblZeroQuantity,
	dblAdjustedTax = (li.dblAdjustedTax / dblQuantity) * dblZeroQuantity
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionOriginalTaxZeroQuantity AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

UPDATE tblCFImportTransactionCalculatedTax 
	SET dblTax = li.dblTax,
	dblAdjustedTax = li.dblAdjustedTax
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionCalculatedTax AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

UPDATE tblCFImportTransactionCalculatedTaxExempt 
	SET dblTax = li.dblTax,
	dblAdjustedTax = li.dblAdjustedTax
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionCalculatedTaxExempt AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID


UPDATE tblCFImportTransactionCalculatedTaxExemptZeroQuantity 
	SET dblTax = (li.dblTax / dblQuantity) * dblZeroQuantity,
	dblAdjustedTax = (li.dblAdjustedTax / dblQuantity) * dblZeroQuantity
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionCalculatedTaxExemptZeroQuantity AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID

UPDATE tblCFImportTransactionCalculatedTaxZeroQuantity 
	SET dblTax = (li.dblTax / dblQuantity) * dblZeroQuantity,
	dblAdjustedTax = (li.dblAdjustedTax / dblQuantity) * dblZeroQuantity
FROM  tblCFImportTransactionStagingTable
INNER JOIN tblCFImportTransactionCalculatedTaxZeroQuantity AS ot
ON tblCFImportTransactionStagingTable.intTransactionId = ot.intTransactionId
INNER JOIN @RemoteLineItemTaxEntries AS li
ON ot.intTaxGroupId		= li.intTaxGroupId
AND ot.intTaxCodeId		= li.intTaxCodeId
AND ot.intTaxClassId	= li.intTaxClassId
AND ot.dblRate			= li.dblRate
AND ot.intTransactionId = li.intDetailId
WHERE ISNULL(ot.ysnTaxExempt,0) = 0
AND ISNULL(ot.ysnInvalidSetup,0) = 0
AND (tblCFImportTransactionStagingTable.strNetworkType = 'CFN' AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0 AND ISNULL(tblCFImportTransactionStagingTable.isImporting,0) = 1)
AND tblCFImportTransactionStagingTable.strGUID = @strGUID
	
-- SET AS TAX AS INVALID SETUP > ONLY IF TAX HAVE ITEM CATEGORY EXEMPTION
UPDATE tblCFImportTransactionOriginalTax SET ysnInvalidSetup = 1, dblTax = 0.0, dblAdjustedTax = 0.0 
WHERE ysnTaxExempt = 1 AND strNotes LIKE '%has an exemption set for item category%'
AND tblCFImportTransactionOriginalTax.strGUID = @strGUID

-- MERGE ORIGINAL AND CALCULATED TAXES > 
INSERT INTO tblCFImportTransactionTax
(
	 intTransactionId
	,[intTransactionDetailTaxId]	
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
	,strGUID
)	
SELECT 
	 originalTax.intTransactionId
	,originalTax.intTransactionDetailTaxId
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
	,([dbo].fnRoundBanker(calculatedTax.dblTax,2))
	,([dbo].fnRoundBanker(originalTax.dblTax,2))
	,@strGUID
FROM tblCFImportTransactionOriginalTax as originalTax
CROSS APPLY (
		SELECT TOP 1 
			ysnTaxExempt
			,dblTax
		FROM tblCFImportTransactionCalculatedTax
		WHERE originalTax.intTaxGroupId		= tblCFImportTransactionCalculatedTax.intTaxGroupId
		AND originalTax.intTaxCodeId		= tblCFImportTransactionCalculatedTax.intTaxCodeId
		AND originalTax.intTaxClassId		= tblCFImportTransactionCalculatedTax.intTaxClassId
		AND originalTax.dblRate				= tblCFImportTransactionCalculatedTax.dblRate
		AND originalTax.intTransactionId	= tblCFImportTransactionCalculatedTax.intTransactionId
	) AS calculatedTax
WHERE strGUID = @strGUID

SELECT 'tblCFImportTransactionTax',* FROM tblCFImportTransactionTax

INSERT INTO tblCFImportTransactionTaxZeroQuantity
(
	 intTransactionId
	,[intTransactionDetailTaxId]	
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
	,[strGUID]
)	
SELECT 
	 originalTax.intTransactionId
	,originalTax.intTransactionDetailTaxId
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
	,@strGUID
FROM tblCFImportTransactionOriginalTaxZeroQuantity as originalTax
CROSS APPLY (
		SELECT TOP 1 
			ysnTaxExempt
			,dblTax
		FROM tblCFImportTransactionCalculatedTaxZeroQuantity
		WHERE originalTax.intTaxGroupId = intTaxGroupId
		AND originalTax.intTaxCodeId = intTaxCodeId
		AND originalTax.intTaxClassId = intTaxClassId
		AND originalTax.dblRate = dblRate
		AND originalTax.intTransactionId	= intTransactionId
	) AS calculatedTax
WHERE strGUID = @strGUID


	SELECT 'tblCFImportTransactionTaxZeroQuantity',* FROM tblCFImportTransactionTaxZeroQuantity
		
---SPECIAL TAX RULE--
				
DECLARE @tblCFImportTaxCodeList		TABLE
(
	 [strTaxCode]				NVARCHAR(MAX) NULL
	,[intTaxCodeId]				INT NULL
	,[strTaxRule]				NVARCHAR(MAX) NULL
	,[intTaxRuleId]				INT NULL
	,[ysnApplyTaxRule]			BIT NULL
	,[intTransactionId]			INT NULL
)


DELETE FROM @tblCFImportTaxCodeList

INSERT INTO @tblCFImportTaxCodeList 
(
 strTaxCode
,intTaxCodeId
,intTransactionId
)
SELECT 
strTaxCode
,intTaxCodeId
,intTransactionId
FROM tblCFImportTransactionCalculatedTax
WHERE strGUID = @strGUID

INSERT INTO @tblCFImportTaxCodeList 
(
 strTaxCode
,intTaxCodeId
,intTransactionId
)
SELECT 
 strTaxCode
,intTaxCodeId
,intTransactionId
FROM tblCFImportTransactionOriginalTax
WHERE strTaxCode NOT IN 
(SELECT strTaxCode COLLATE Latin1_General_CI_AS FROM @tblCFImportTaxCodeList)
AND strGUID = @strGUID


UPDATE @tblCFImportTaxCodeList 
SET 
	 ysnApplyTaxRule = 1
	,strTaxRule = tblCFTaxRules.strDescription
	,intTaxRuleId = tblCFTaxRules.intSpecialTaxingRuleId
FROM 
(
	SELECT 
	tblCFInnerTaxRules.strDescription, 
	tblCFInnerTaxRules.strType, 
	tblCFInnerTaxRules.intSpecialTaxingRuleId,
	tblCFInnerTaxRules.intSiteGroupId,
	tblCFInnerTaxRules.intSiteId,
	tblCFInnerTaxRules.intTaxCodeId,
	tblCFImportTransactionStagingTable.intTransactionId
	FROM tblCFImportTransactionStagingTable
	INNER JOIN (
		SELECT 
		strDescription, 
		strType, 
		sptrh.intSpecialTaxingRuleId,
		intSiteGroupId,
		intSiteId,
		intTaxCodeId 
		FROM 
		tblCFSpecialTaxingRuleHeader as sptrh
		INNER JOIN tblCFSpecialTaxingRuleSite as sptrs
		ON sptrh.intSpecialTaxingRuleId = sptrs.intSpecialTaxingRuleId
		INNER JOIN tblCFSpecialTaxingRuleTax as sptrt
		ON sptrh.intSpecialTaxingRuleId = sptrt.intSpecialTaxingRuleId
		) AS tblCFInnerTaxRules
	ON (tblCFImportTransactionStagingTable.intSiteGroupId = tblCFInnerTaxRules.intSiteGroupId 
	OR tblCFImportTransactionStagingTable.intSiteId = tblCFInnerTaxRules.intSiteId)
	WHERE strGUID = @strGUID
) AS tblCFTaxRules
WHERE [@tblCFImportTaxCodeList].intTaxCodeId = tblCFTaxRules.intTaxCodeId and tblCFTaxRules.intTransactionId = [@tblCFImportTaxCodeList].intTransactionId


UPDATE tblCFImportTransactionStagingTable
SET dblSpecialTaxZeroQty = tblCFSpecialTax.dblSpecialTaxZeroQty
FROM ( 
	SELECT 
	  dblSpecialTaxZeroQty= SUM(ISNULL([dblOriginalTax],0))
	 ,tblCFImportTransactionTaxZeroQuantity.intTransactionId
	FROM 
	tblCFImportTransactionTaxZeroQuantity
	INNER JOIN
	(
		SELECT 
		intTaxCodeId,
		intTransactionId
		FROM @tblCFImportTaxCodeList
		WHERE ISNULL(ysnApplyTaxRule,0) = 1
	)  AS tblCFInnerSpecialTax
	ON tblCFInnerSpecialTax.intTransactionId = tblCFImportTransactionTaxZeroQuantity.intTransactionId
	AND tblCFInnerSpecialTax .intTaxCodeId = tblCFImportTransactionTaxZeroQuantity.intTaxCodeId
	WHERE ISNULL(tblCFImportTransactionTaxZeroQuantity.ysnInvalidSetup,0) = 0
	GROUP BY tblCFImportTransactionTaxZeroQuantity.intTransactionId
)
AS tblCFSpecialTax
WHERE tblCFSpecialTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
AND strGUID = @strGUID
--AND tblCFImportTransactionStagingTable.ysnReRunCalcTax = 0


UPDATE tblCFImportTransactionStagingTable
SET dblSpecialTax = tblCFSpecialTax.dblSpecialTax
FROM ( 
	SELECT 
	  dblSpecialTax= SUM(ISNULL([dblOriginalTax],0))
	 ,tblCFImportTransactionTax.intTransactionId
	FROM 
	tblCFImportTransactionTax
	INNER JOIN
	(
		SELECT 
		intTaxCodeId,
		intTransactionId
		FROM @tblCFImportTaxCodeList
		WHERE ISNULL(ysnApplyTaxRule,0) = 1
	)  AS tblCFInnerSpecialTax
	ON tblCFInnerSpecialTax.intTransactionId = tblCFImportTransactionTax.intTransactionId
	AND tblCFInnerSpecialTax .intTaxCodeId = tblCFImportTransactionTax.intTaxCodeId
	WHERE ISNULL(tblCFImportTransactionTax.ysnInvalidSetup,0) = 0
	GROUP BY tblCFImportTransactionTax.intTransactionId
)
AS tblCFSpecialTax
WHERE tblCFSpecialTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
AND strGUID = @strGUID
--AND tblCFImportTransactionStagingTable.ysnReRunCalcTax = 0


UPDATE tblCFImportTransactionTax 
SET [dblOriginalTax] = 0
FROM tblCFImportTransactionTax
INNER JOIN
	(
		SELECT 
		intTaxCodeId,
		intTransactionId
		FROM @tblCFImportTaxCodeList
		WHERE ISNULL(ysnApplyTaxRule,0) = 1
	)  AS tblCFInnerSpecialTax
	ON tblCFInnerSpecialTax.intTransactionId = tblCFImportTransactionTax.intTransactionId
	AND tblCFInnerSpecialTax .intTaxCodeId = tblCFImportTransactionTax.intTaxCodeId
WHERE ISNULL(ysnInvalidSetup,0) = 0
AND strGUID = @strGUID



UPDATE tblCFImportTransactionTaxZeroQuantity 
SET [dblOriginalTax] = 0
FROM tblCFImportTransactionTaxZeroQuantity
INNER JOIN
	(
		SELECT 
		intTaxCodeId,
		intTransactionId
		FROM @tblCFImportTaxCodeList
		WHERE ISNULL(ysnApplyTaxRule,0) = 1
	)  AS tblCFInnerSpecialTax
	ON tblCFInnerSpecialTax.intTransactionId = tblCFImportTransactionTaxZeroQuantity.intTransactionId
	AND tblCFInnerSpecialTax .intTaxCodeId = tblCFImportTransactionTaxZeroQuantity.intTaxCodeId
WHERE ISNULL(ysnInvalidSetup,0) = 0
AND strGUID = @strGUID


	-------------------------------------------------------
	------				 PRICE CALCULATION				 --
	-------------------------------------------------------
	----PRICECALCULATION: 
	-----------------------NORMAL QTY TAX CALC------------------------
	


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblTotalCalculatedTax = ISNULL(tblCFImportTransactionTax.dblTotalCalculatedTax,0)
		,dblTotalOriginalTax = ISNULL(tblCFImportTransactionTax.dblTotalOriginalTax,0)
	FROM ( 
		 SELECT 
			 dblTotalCalculatedTax = ISNULL(SUM([dbo].fnRoundBanker(dblCalculatedTax,2)),0),
			 dblTotalOriginalTax = ISNULL(SUM([dbo].fnRoundBanker(dblOriginalTax,2)),0),
			 intTransactionId 
		 FROM tblCFImportTransactionTax
		 WHERE (ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL)
		 GROUP BY intTransactionId
		 ) AS tblCFImportTransactionTax
	WHERE tblCFImportTransactionTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND strGUID = @strGUID
	--AND (ysnReRunForSpecialTax = 0 OR ysnReRunCalcTax = 1)

	UPDATE tblCFImportTransactionStagingTable
	SET 
		dblTotalCalculatedTaxExempt = ISNULL(tblCFImportTransactionTax.dblTotalCalculatedTaxExempt,0)
	FROM ( 
		 SELECT 
			 dblTotalCalculatedTaxExempt = ISNULL(SUM([dbo].fnRoundBanker(cftx.dblTax,2)),0),
			 cft.intTransactionId 
		 FROM tblCFImportTransactionTax cft
		 INNER JOIN tblCFImportTransactionCalculatedTaxExempt as cftx
	 	 ON cft.intTaxClassId = cftx.intTaxClassId
		 AND cft.intTaxCodeId = cftx.intTaxCodeId
		 AND cft.intTransactionId = cftx.intTransactionId
		 WHERE cft.ysnTaxExempt = 1 AND (cft.ysnInvalidSetup = 0 OR cft.ysnInvalidSetup IS NULL)
		 GROUP BY cft.intTransactionId
		 ) AS tblCFImportTransactionTax
	WHERE tblCFImportTransactionTax.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND strGUID = @strGUID
	--AND (ysnReRunForSpecialTax = 0 OR ysnReRunCalcTax = 1)

	UPDATE tblCFImportTransactionStagingTable
	SET 
		dblTotalCalculatedTaxExemptZeroQuantity = ISNULL(tblCFImportTransactionTaxZeroQuantity.dblTotalCalculatedTaxExemptZeroQuantity,0)
	FROM ( 
		 SELECT 
			 dblTotalCalculatedTaxExemptZeroQuantity = ISNULL(SUM([dbo].fnRoundBanker(cftx.dblTax,2)),0),
			 cft.intTransactionId 
		 FROM tblCFImportTransactionTaxZeroQuantity cft
		 INNER JOIN tblCFImportTransactionCalculatedTaxExempt as cftx
	 	 ON cft.intTaxClassId = cftx.intTaxClassId
		 AND cft.intTaxCodeId = cftx.intTaxCodeId
		 AND cft.intTransactionId = cftx.intTransactionId
		 WHERE cft.ysnTaxExempt = 1 AND (cft.ysnInvalidSetup = 0 OR cft.ysnInvalidSetup IS NULL)
		 GROUP BY cft.intTransactionId
		 ) AS tblCFImportTransactionTaxZeroQuantity
	WHERE tblCFImportTransactionTaxZeroQuantity.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND strGUID = @strGUID
	--AND (ysnReRunForSpecialTax = 0 OR ysnReRunCalcTax = 1)


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblTotalCalculatedTaxZeroQuantity = ISNULL(tblCFImportTransactionTaxZeroQuantity.dblTotalCalculatedTaxZeroQuantity,0)
		,dblTotalOriginalTaxZeroQuantity = ISNULL(tblCFImportTransactionTaxZeroQuantity.dblTotalOriginalTaxZeroQuantity,0)
	FROM ( 
		 SELECT 
			 dblTotalCalculatedTaxZeroQuantity = ISNULL(SUM([dbo].fnRoundBanker(dblCalculatedTax,2)),0),
			 dblTotalOriginalTaxZeroQuantity = ISNULL(SUM([dbo].fnRoundBanker(dblOriginalTax,2)),0),
			 intTransactionId 
		 FROM tblCFImportTransactionTaxZeroQuantity
		 WHERE (ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL)
		 GROUP BY intTransactionId
		 ) AS tblCFImportTransactionTaxZeroQuantity
	WHERE tblCFImportTransactionTaxZeroQuantity.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	AND strGUID = @strGUID
	--AND (ysnReRunForSpecialTax = 0 OR ysnReRunCalcTax = 1)



	UPDATE tblCFImportTransactionTax 
	SET  tblCFImportTransactionTax.dblTaxCalculatedExemptAmount = [dbo].fnRoundBanker(cftx.dblTax,2)
	FROM tblCFImportTransactionCalculatedTaxExempt cftx
	WHERE tblCFImportTransactionTax.intTaxClassId = cftx.intTaxClassId
	AND  tblCFImportTransactionTax.intTaxCodeId = cftx.intTaxCodeId
	AND  tblCFImportTransactionTax.ysnTaxExempt = 1 
	AND (tblCFImportTransactionTax.ysnInvalidSetup = 0 OR  tblCFImportTransactionTax.ysnInvalidSetup IS NULL)
	AND tblCFImportTransactionTax.intTransactionId = cftx.intTransactionId
	AND tblCFImportTransactionTax.strGUID = cftx.strGUID


	SELECT 
		dblTotalCalculatedTax
		,dblTotalCalculatedTaxZeroQuantity
		,dblTotalOriginalTax 
		,dblTotalOriginalTaxZeroQuantity
	FROM tblCFImportTransactionStagingTable
	WHERE strGUID = @strGUID
	
	----END

	-----------------------ZERO QTY TAX CALC------------------------

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 dblGrossTransferCost = ISNULL(dblTransferCost,0)
	,dblNetTransferCost = ISNULL(dblTransferCost,0) - (ISNULL(dblTotalOriginalTax,0) / ISNULL(dblQuantity,0))
	,dblAdjustments = ISNULL(dblPriceProfileRate,0)+ ISNULL(ISNULL(dblAdjustmentRate,0)	,0)
	,dblAdjustmentWithIndex = ISNULL(dblPriceProfileRate,0) + ISNULL(dblIndexPrice,0)	+ ISNULL(dblAdjustmentRate	,0)
	,dblNetTransferCostZeroQuantity = ISNULL(dblTransferCost,0) - (ISNULL(dblTotalOriginalTaxZeroQuantity,0) / ISNULL(dblZeroQuantity,0))
	WHERE strGUID = @strGUID
	

	SELECT dblTransferCost,dblTotalOriginalTaxZeroQuantity,dblPriceProfileRate,dblIndexPrice,dblAdjustmentRate,* FROM tblCFImportTransactionStagingTable

	-->> Import File Price | Credit Card | Origin History <<--

	IF(@ysnReRunCalcTax = 0)
	BEGIN
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			dblPrice = Round((Round(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6) + ISNULL(dblAdjustments,0),
			dblPriceZeroQty = Round((Round(dblOriginalPriceZeroQty * dblZeroQuantity,2) - dblTotalOriginalTaxZeroQuantity) / dblZeroQuantity, 6) + ISNULL(dblAdjustments,0)
			,ysnReRunCalcTax = 1
		WHERE 
		(strPriceMethod = 'Import File Price' 
		OR strPriceMethod = 'Credit Card' 
		OR strPriceMethod = 'Origin History')
		AND strGUID = @strGUID
	END


	

	UPDATE tblCFImportTransactionStagingTable 
	SET dblImportFileGrossPriceZeroQty = ROUND(ISNULL(dblPrice,0) + ROUND((ISNULL(dblTotalCalculatedTaxZeroQuantity,0) / dblZeroQuantity),6), 6)
	WHERE 
	(strPriceMethod = 'Import File Price' 
	OR strPriceMethod = 'Credit Card' 
	OR strPriceMethod = 'Origin History')
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable 
	SET 
		dblImportFileGrossPriceZeroQty = dbo.fnCFForceRounding(dblImportFileGrossPriceZeroQty)
	WHERE 
	(strPriceMethod = 'Import File Price' 
	OR strPriceMethod = 'Credit Card' 
	OR strPriceMethod = 'Origin History')
	AND (ISNULL(ysnForceRounding,0) = 1) 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblCalculatedGrossPrice	 = dblImportFileGrossPriceZeroQty
		,dblOriginalGrossPrice		 = dblOriginalPrice
		,dblCalculatedNetPrice		 = ROUND(((ROUND((dblImportFileGrossPriceZeroQty * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0)) ) / dblQuantity),6)
		,dblOriginalNetPrice		 = ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
		,dblCalculatedTotalPrice	 = ROUND((dblImportFileGrossPriceZeroQty * dblQuantity),2)
		,dblOriginalTotalPrice		 = ROUND(dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 = dblCalculatedGrossPrice
		,dblQuoteNetPrice			 = ROUND(((ROUND((dblQuoteGrossPrice * dblZeroQuantity),2) - (ISNULL(dblTotalCalculatedTaxZeroQuantity,0)) ) / dblZeroQuantity),6)
	WHERE 
	(strPriceMethod = 'Import File Price' 
	OR strPriceMethod = 'Credit Card' 
	OR strPriceMethod = 'Origin History')
	AND strGUID = @strGUID


	--SELECT dblOriginalNetPrice		 = ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
	--FROM tblCFImportTransactionStagingTable
	--<< Import File Price | Credit Card | Origin History >>--


	-->> Posted Trans from CSV <<--

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblPostedTranGrossPrice = ROUND (ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6) + ISNULL(dblAdjustments,0) + ROUND((ISNULL(dblTotalCalculatedTax,0) / dblQuantity),6),6)
	WHERE strPriceMethod = 'Posted Trans from CSV'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblImportFileGrossPrice = dblPostedTranGrossPrice
	WHERE strPriceMethod = 'Posted Trans from CSV'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblImportFileGrossPrice = dbo.fnCFForceRounding(dblImportFileGrossPrice)
	WHERE strPriceMethod = 'Posted Trans from CSV'
	AND (ISNULL(ysnForceRounding,0) = 1) 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		  dblCalculatedGrossPrice	 = dblImportFileGrossPrice
		 ,dblOriginalGrossPrice		 = dblOriginalPrice
		 ,dblCalculatedNetPrice		 = ROUND(((ROUND((dblImportFileGrossPrice * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0)) ) / dblQuantity),6)
		 ,dblOriginalNetPrice		 = ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
		 ,dblCalculatedTotalPrice	 = ROUND((dblImportFileGrossPrice * dblQuantity),2)
		 ,dblOriginalTotalPrice		 = ROUND(dblOriginalPrice * dblQuantity,2)
		 ,dblQuoteGrossPrice			 = dblCalculatedGrossPrice
		 ,dblQuoteNetPrice			 = ROUND(((ROUND((dblQuoteGrossPrice * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0)) ) / dblQuantity),6)
	WHERE strPriceMethod = 'Posted Trans from CSV'
	AND (ISNULL(ysnForceRounding,0) = 1) 
	AND strGUID = @strGUID







	--<< Posted Trans from CSV >>--



	-->> Network Cost <<--

	UPDATE tblCFImportTransactionStagingTable 
	SET dblOriginalPrice = dblOriginalPriceForCalculation
	WHERE strPriceMethod = 'Network Cost'
	AND ysnReRunForSpecialTax = 1
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblOriginalPriceForCalculation		= dblOriginalPrice
		,dblOriginalPriceZeroQty			= Round((Round(dblOriginalPriceZeroQty * dblZeroQuantity,2) - dblTotalOriginalTaxZeroQuantity) / dblZeroQuantity, 6)
		,dblOriginalPrice					= Round((Round(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
		,ysnReRunForSpecialTax				= 1
	WHERE strPriceMethod = 'Network Cost'
	AND (ysnReRunForSpecialTax = 0 AND ISNULL(dblSpecialTax,0) > 0)
	AND strGUID = @strGUID
	--GOTO TAXCOMPUTATION


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblNCPriceQty = Round((ISNULL(dblTransferCost,0) + ROUND((ISNULL(dblSpecialTax,0) / dblQuantity),6) ),6)
		,dblNCPrice100kQty = Round((ISNULL(dblTransferCost,0) + ROUND((ISNULL(dblSpecialTaxZeroQty,0) / dblZeroQuantity),6) ),6)
		,dblPrice = dblNCPriceQty
		,dblPriceZeroQty = dblNCPrice100kQty
		--,ysnReRunCalcTax = 1
	WHERE strPriceMethod = 'Network Cost'
	AND strGUID = @strGUID
	--AND ISNULL(ysnReRunCalcTax,0) = 0


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblNetworkCostGrossPrice = Round((ISNULL(dblTransferCost,0) - ROUND((ISNULL(dblTotalCalculatedTaxExempt,0) / dblQuantity),6) + ROUND((ISNULL(dblSpecialTax,0) / dblQuantity),6) ),6)
		,dblNetworkCostGrossPriceZeroQty = Round((ISNULL(dblTransferCost,0) - ROUND((ISNULL(dblTotalCalculatedTaxExemptZeroQuantity,0)/ dblZeroQuantity),6) + ROUND((ISNULL(dblSpecialTaxZeroQty,0) / dblZeroQuantity),6) ),6)
	WHERE strPriceMethod = 'Network Cost'
	AND strGUID = @strGUID
	--AND ISNULL(ysnReRunCalcTax,0) = 1


	
	UPDATE tblCFImportTransactionStagingTable 
	SET 
		  dblNetworkCostGrossPrice = dbo.fnCFForceRounding(dblNetworkCostGrossPrice)
		 ,dblNetworkCostGrossPriceZeroQty = dbo.fnCFForceRounding(dblNetworkCostGrossPriceZeroQty)
	WHERE strPriceMethod = 'Network Cost'
	AND ISNULL(ysnForceRounding,0) = 1
	AND strGUID = @strGUID



	UPDATE tblCFImportTransactionStagingTable 
	SET 
		  dblCalculatedGrossPrice	 = 	 dblNetworkCostGrossPriceZeroQty
		 ,dblOriginalGrossPrice		 = 	 dblOriginalPrice
		 ,dblCalculatedNetPrice		 = 	 ROUND(((ROUND((dblNetworkCostGrossPrice * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0))) / dblQuantity),6)
		 ,dblOriginalNetPrice		 = 	 ROUND(((ROUND((dblOriginalPrice * dblQuantity),2) - (ISNULL(dblTotalOriginalTax,0))) / dblQuantity),6)
		 ,dblCalculatedTotalPrice	 = 	 ROUND((dblNetworkCostGrossPrice * dblQuantity),2)
		 ,dblOriginalTotalPrice		 = 	 ROUND(dblOriginalPrice * dblQuantity,2)
		 ,dblQuoteGrossPrice		 =	 dblCalculatedGrossPrice
		 ,dblQuoteNetPrice			 =	 ROUND(((ROUND((dblQuoteGrossPrice * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0))) / dblQuantity),6)
	WHERE strPriceMethod = 'Network Cost'
	AND strGUID = @strGUID


	--<< Network Cost >>--

	-->> Index Cost <<--


	UPDATE tblCFImportTransactionStagingTable 
	SET dblLocalIndexCostGrossPrice = ROUND((dblAdjustmentWithIndex + ROUND((dblTotalCalculatedTax / dblQuantity),6)),6)
	WHERE (LOWER(strPriceBasis) = 'index cost')
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET dblLocalIndexCostGrossPriceZeroQty = ROUND((dblAdjustmentWithIndex + ROUND((ISNULL(dblTotalCalculatedTaxZeroQuantity,0) / dblZeroQuantity),6)  ),6)
	WHERE (LOWER(strPriceBasis) = 'index cost')
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblLocalIndexCostGrossPrice = dbo.fnCFForceRounding(dblLocalIndexCostGrossPrice)
		,dblLocalIndexCostGrossPriceZeroQty = dbo.fnCFForceRounding(dblLocalIndexCostGrossPriceZeroQty)
	WHERE (LOWER(strPriceBasis) = 'index cost')
	AND (ISNULL(ysnForceRounding,0) = 1)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblCalculatedGrossPrice		 = 	 dblLocalIndexCostGrossPriceZeroQty
		,dblOriginalGrossPrice		 = 	 dblOriginalPrice
		,dblCalculatedNetPrice		 = 	 ROUND((ROUND((dblLocalIndexCostGrossPriceZeroQty * dblQuantity),2) -  (ISNULL(dblTotalCalculatedTax,0))) / dblQuantity,6)
		,dblOriginalNetPrice			 = 	 ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6) 
		,dblCalculatedTotalPrice		 = 	 ROUND((dblLocalIndexCostGrossPriceZeroQty * dblQuantity),2)
		,dblOriginalTotalPrice		 = 	 ROUND(dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 =	 dblCalculatedGrossPrice
		,dblQuoteNetPrice			 =   ROUND((ROUND((dblQuoteGrossPrice * dblZeroQuantity),2) -  (ISNULL(dblTotalCalculatedTaxZeroQuantity,0))) / dblZeroQuantity,6)
	WHERE (LOWER(strPriceBasis)	 =	'index cost')
	AND strGUID = @strGUID


	--<< Index Cost >>--


	
	-->> Index Retail <<--

	IF(@ysnReRunCalcTax = 0)
	BEGIN
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			 dblLocalIndexRetailGrossPrice = ROUND((dblAdjustmentWithIndex - ROUND((ISNULL(dblTotalCalculatedTaxExempt,0) / dblQuantity),6)),6)
			,dblLocalIndexRetailGrossPriceZeroQty = ROUND((dblAdjustmentWithIndex - ROUND((ISNULL(dblTotalCalculatedTaxExemptZeroQuantity,0)/ dblZeroQuantity),6)),6)
			,ysnReRunCalcTax = 1
		WHERE (LOWER(strPriceBasis)	 =	'index retail')
		AND strGUID = @strGUID

		SELECT ROUND((dblAdjustmentWithIndex - ROUND((ISNULL(dblTotalCalculatedTaxExempt,0) / dblQuantity),6)),6) FROM tblCFImportTransactionStagingTable
	
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			 dblPrice100kQty = dblLocalIndexRetailGrossPriceZeroQty
			,dblPriceQty	 = dblLocalIndexRetailGrossPrice
			,dblPrice		 = dblLocalIndexRetailGrossPrice
			,dblPriceZeroQty = dblLocalIndexRetailGrossPriceZeroQty
			,ysnReRunCalcTax = 1
		WHERE (LOWER(strPriceBasis)	 =	'index retail')
		AND strGUID = @strGUID

		SELECT 
		 dblPrice100kQty 
		,dblPriceQty	 
		,dblPrice		 
		,dblPriceZeroQty 
		,ysnReRunCalcTax 
		,strPriceBasis
		FROM tblCFImportTransactionStagingTable

	END
	--AND ysnReRunCalcTax = 0
	--GOTO TAXCOMPUTATION
	IF(@ysnReRunCalcTax = 1)
	BEGIN
		

		UPDATE tblCFImportTransactionStagingTable 
		SET 
			 dblLocalIndexRetailGrossPrice = dblPriceQty
			,dblLocalIndexRetailGrossPriceZeroQty  = dblPrice100kQty
		WHERE (LOWER(strPriceBasis)	 =	'index retail')
		AND strGUID = @strGUID
	
	--AND ysnReRunCalcTax = 1


		UPDATE tblCFImportTransactionStagingTable 
		SET 
			 dblLocalIndexRetailGrossPrice = dbo.fnCFForceRounding(dblLocalIndexRetailGrossPrice)
			,dblLocalIndexRetailGrossPriceZeroQty = dbo.fnCFForceRounding(dblLocalIndexRetailGrossPriceZeroQty)
		WHERE (LOWER(strPriceBasis)	 =	'index retail')
		AND (ISNULL(ysnForceRounding,0) = 1) 
		AND strGUID = @strGUID

	END


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblCalculatedGrossPrice	 =	  dblLocalIndexRetailGrossPriceZeroQty
		,dblOriginalGrossPrice		 =	  dblOriginalPrice
		,dblCalculatedNetPrice		 =	  ROUND((ROUND((dblLocalIndexRetailGrossPriceZeroQty * dblQuantity),2) -  (ISNULL(dblTotalCalculatedTax,0))) / dblQuantity,6)
		,dblOriginalNetPrice		 =	  ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6) 
		,dblCalculatedTotalPrice	 =	  ROUND((dblLocalIndexRetailGrossPriceZeroQty * dblQuantity),2)
		,dblOriginalTotalPrice		 =	  ROUND(dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 =	  dblCalculatedGrossPrice
		,dblQuoteNetPrice			 =    ROUND((ROUND((dblQuoteGrossPrice * dblZeroQuantity),2) -  (ISNULL(dblTotalCalculatedTaxZeroQuantity,0))) / dblZeroQuantity,6)
	WHERE (LOWER(strPriceBasis)	 =	'index retail')
	AND strGUID = @strGUID


	--<< Index Retail >>--

	
	-->> Index Fixed <<--
	
	UPDATE tblCFImportTransactionStagingTable 
	SET 
		dblLocalIndexFixedGrossPrice = ROUND(dblAdjustmentWithIndex,6)
	WHERE (LOWER(strPriceBasis)	 =	'index fixed')
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		dblLocalIndexFixedGrossPrice =  dbo.fnCFForceRounding(dblLocalIndexFixedGrossPrice)
	WHERE (LOWER(strPriceBasis)	 =	'index fixed')
	AND (ISNULL(ysnForceRounding,0) = 1) 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblCalculatedGrossPrice	 =	  dblLocalIndexFixedGrossPrice
		,dblOriginalGrossPrice		 =	  dblOriginalPrice
		,dblCalculatedNetPrice		 =	  ROUND((ROUND((dblLocalIndexFixedGrossPrice * dblQuantity),2) -  (ISNULL(dblTotalCalculatedTax,0))) / dblQuantity,6)
		,dblOriginalNetPrice		 =	  ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6) 
		,dblCalculatedTotalPrice	 =	  ROUND((dblLocalIndexFixedGrossPrice * dblQuantity),2)
		,dblOriginalTotalPrice		 =	  ROUND(dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 =	  dblCalculatedGrossPrice
		,dblQuoteNetPrice			 =    ROUND((ROUND((dblQuoteGrossPrice * dblZeroQuantity),2) -  (ISNULL(dblTotalCalculatedTaxZeroQuantity,0))) / dblZeroQuantity,6)
	WHERE (LOWER(strPriceBasis)	 =	'index fixed')
	AND strGUID = @strGUID


	--<< Index Fixed >>--

	-->> Pump Price Adjustment <<--



	--UPDATE tblCFImportTransactionStagingTable 
	--SET 
	--	 dblOriginalPrice	= dblOriginalPriceForCalculation
	--WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
	--AND strGUID = @strGUID
	--AND (ysnReRunForSpecialTax = 1)


	--UPDATE tblCFImportTransactionStagingTable 
	--SET 
	--	  dblOriginalPriceForCalculation	= dblOriginalPrice
	--	 ,dblOriginalPriceZeroQty			= Round((Round(dblOriginalPriceZeroQty * dblZeroQuantity,2) - dblTotalOriginalTaxZeroQuantity) / dblZeroQuantity, 6)
	--	 ,dblOriginalPrice					= Round((Round(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
	--	 ,ysnReRunForSpecialTax				= 1
	--WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
	--AND (ysnReRunForSpecialTax = 0 AND ISNULL(dblSpecialTax,0) > 0)
	--AND strGUID = @strGUID
	----GOTO TAXCOMPUTATION

	IF(@ysnReRunCalcTax = 0)
	BEGIN
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			   dblPPAPriceQty = Round(((ISNULL(dblAdjustments,0) +  ISNULL(dblOriginalPrice,0)) + ROUND((ISNULL(dblSpecialTax,0) / dblQuantity),6) ),6)
			  ,dblPPAPrice100kQty = Round(((dblAdjustments +  dblOriginalPrice) + ROUND((ISNULL(dblSpecialTaxZeroQty,0) / dblZeroQuantity),6) ),6)
			  ,dblPrice = Round(((ISNULL(dblAdjustments,0) +  ISNULL(dblOriginalPrice,0)) + ROUND((ISNULL(dblSpecialTax,0) / dblQuantity),6) ),6)
			  ,dblPriceZeroQty = Round(((dblAdjustments +  dblOriginalPrice) + ROUND((ISNULL(dblSpecialTaxZeroQty,0) / dblZeroQuantity),6) ),6)
			  --,ysnReRunCalcTax = 1
		WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
		AND strGUID = @strGUID
	END
	--AND (ysnReRunCalcTax = 0)
	--GOTO TAXCOMPUTATION



	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblPumpPriceAdjustmentGrossPrice = Round(((ISNULL(dblAdjustments,0) +  ISNULL(dblOriginalPrice,0))- ROUND((ISNULL(dblTotalCalculatedTaxExempt,0) / dblQuantity),6) + ROUND((ISNULL(dblSpecialTax,0) / dblQuantity),6) ),6)
		,dblPumpPriceAdjustmentGrossPriceZeroQty = Round(((dblAdjustments +  dblOriginalPrice)- ROUND((ISNULL(dblTotalCalculatedTaxExemptZeroQuantity,0)/ dblZeroQuantity),6) + ROUND((ISNULL(dblSpecialTaxZeroQty,0) / dblZeroQuantity),6) ),6)
	WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
	AND strGUID = @strGUID
	--AND (ysnReRunCalcTax = 1)


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblPumpPriceAdjustmentGrossPrice = dbo.fnCFForceRounding(dblPumpPriceAdjustmentGrossPrice)
		,dblPumpPriceAdjustmentGrossPriceZeroQty = dbo.fnCFForceRounding(dblPumpPriceAdjustmentGrossPriceZeroQty)
	WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
	AND strGUID = @strGUID
	AND ISNULL(ysnForceRounding,0) = 1


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblCalculatedGrossPrice	 =	   dblPumpPriceAdjustmentGrossPriceZeroQty
		,dblOriginalGrossPrice		 =	   dblOriginalPrice
		,dblCalculatedNetPrice		 =	   ROUND(((ROUND((dblPumpPriceAdjustmentGrossPriceZeroQty * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0)) ) / dblQuantity),6)
		,dblOriginalNetPrice		 =	   ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0)) / dblQuantity, 6)
		,dblCalculatedTotalPrice	 =	   ROUND((dblPumpPriceAdjustmentGrossPriceZeroQty * dblQuantity),2)
		,dblOriginalTotalPrice		 =	   ROUND(dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 =	   dblCalculatedGrossPrice
		,dblQuoteNetPrice			 =	   ROUND((ROUND((dblQuoteGrossPrice * dblZeroQuantity),2) -  (ISNULL(dblTotalCalculatedTaxZeroQuantity,0))) / dblZeroQuantity,6)
	WHERE (LOWER(strPriceBasis)	 =	'pump price adjustment')
	AND strGUID = @strGUID


	--<< Pump Price Adjustment >>--

	
	-->> Transfer Cost <<--

	IF(@ysnReRunCalcTax = 0)
	BEGIN
	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblPrice = ISNULL(dblNetTransferCostZeroQuantity,0) + ISNULL(dblAdjustments,0)
		,dblPriceZeroQty = ISNULL(dblPrice,0)
		,ysnReRunCalcTax = 1
	WHERE (LOWER(strPriceBasis)	 =	'transfer cost')
	AND strGUID = @strGUID
	END

	
	IF(@ysnReRunCalcTax = 1)
	BEGIN
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			dblTransferCostGrossPriceZeroQty = ROUND(ISNULL(dblPrice,0) + ROUND((ISNULL(dblTotalCalculatedTaxZeroQuantity,0) / dblZeroQuantity),6), 6)
		WHERE (LOWER(strPriceBasis)	 =	'transfer cost')
		AND strGUID = @strGUID


		UPDATE tblCFImportTransactionStagingTable 
		SET 
			dblTransferCostGrossPriceZeroQty = dbo.fnCFForceRounding(dblTransferCostGrossPriceZeroQty) 
		WHERE (LOWER(strPriceBasis)	 =	'transfer cost')
		AND ISNULL(ysnForceRounding,0) = 1
		AND strGUID = @strGUID


		
		UPDATE tblCFImportTransactionStagingTable 
		SET 
			 dblCalculatedGrossPrice	 =	   dblTransferCostGrossPriceZeroQty
			,dblOriginalGrossPrice		 =	   dblGrossTransferCost
			,dblCalculatedNetPrice		 =	   ROUND(((ROUND((dblTransferCostGrossPriceZeroQty * dblQuantity),2) - (ISNULL(dblTotalCalculatedTax,0)) ) / dblQuantity),6)
			,dblOriginalNetPrice		 =	   dblNetTransferCost
			,dblCalculatedTotalPrice	 =	   ROUND((dblTransferCostGrossPriceZeroQty * dblQuantity),2)
			,dblOriginalTotalPrice		 =	   ROUND(dblGrossTransferCost * dblQuantity,2)
			,dblQuoteGrossPrice			 =	   dblCalculatedGrossPrice
			,dblQuoteNetPrice			 =     dblCalculatedNetPrice
		WHERE (LOWER(strPriceBasis)	 =	'transfer cost')
		AND strGUID = @strGUID
	END


	--<< Transfer Cost >>--


	
	-->> Item Contracts <<--


	UPDATE tblCFImportTransactionStagingTable 
	SET 
		  dblNetTotalAmount = [dbo].[fnRoundBanker](((ISNULL(dblPrice,0) + dblAdjustments) * dblQuantity) ,2) 
		 ,dblCalculatedTotalPrice	 =	 dblNetTotalAmount + dblTotalCalculatedTax
		 ,dblCalculatedGrossPrice	 =	 ROUND((dblCalculatedTotalPrice / dblQuantity),6)
		 ,dblCalculatedNetPrice		 =	 ISNULL(dblPrice,0)
		 ,dblOriginalGrossPrice		 = 	 dblOriginalPrice
		 ,dblOriginalNetPrice		 = 	 ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6) 
		 ,dblOriginalTotalPrice		 = 	 [dbo].[fnRoundBanker](dblOriginalPrice * dblQuantity,2)
		 ,dblQuoteGrossPrice		 =	 dblCalculatedGrossPrice
		 ,dblQuoteNetPrice			 =   ISNULL(dblPrice,0)
	WHERE LOWER(strPriceMethod) = 'item contracts'
	AND strGUID = @strGUID


	--<< Item Contracts >>--

	
	
	-->> Contracts <<--

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblNetTotalAmount			 =   [dbo].[fnRoundBanker](((ISNULL(dblPrice,0) + dblAdjustments) * dblQuantity) ,2) 
		,dblCalculatedTotalPrice	 =	 dblNetTotalAmount + dblTotalCalculatedTax
		,dblCalculatedGrossPrice	 =	 ROUND((dblCalculatedTotalPrice / dblQuantity),6)
		,dblCalculatedNetPrice		 =	 ISNULL(dblPrice,0)
		,dblOriginalGrossPrice		 = 	 dblOriginalPrice
		,dblOriginalNetPrice		 = 	 ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6) 
		,dblOriginalTotalPrice		 = 	 [dbo].[fnRoundBanker](dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 =	 dblCalculatedGrossPrice
		,dblQuoteNetPrice			 =   ISNULL(dblPrice,0)
	WHERE LOWER(strPriceMethod) = 'contracts'
	AND strGUID = @strGUID


	--<< Contracts >>--




	-->> Remaining Pricing <<--

	UPDATE tblCFImportTransactionStagingTable 
	SET 
		 dblNetTotalAmount			 = [dbo].[fnRoundBanker]((ISNULL(dblPrice,0) * dblQuantity) ,2) 
		,dblCalculatedTotalPrice	 = dblNetTotalAmount + dblTotalCalculatedTax
		,dblCalculatedGrossPrice	 = ROUND((dblCalculatedTotalPrice / dblQuantity),6)
		,dblCalculatedNetPrice		 = ISNULL(dblPrice,0)
		,dblOriginalGrossPrice		 = dblOriginalPrice
		,dblOriginalNetPrice		 = ROUND((ROUND(dblOriginalPrice * dblQuantity,2) - ISNULL(dblTotalOriginalTax,0) ) / dblQuantity, 6)
		,dblOriginalTotalPrice		 = [dbo].[fnRoundBanker](dblOriginalPrice * dblQuantity,2)
		,dblQuoteGrossPrice			 = dblCalculatedGrossPrice
		,dblQuoteNetPrice			 = ISNULL(dblPrice,0)
	WHERE (
		strPriceMethod				 != 'Import File Price' 
		AND strPriceMethod			 != 'Credit Card' 
		AND strPriceMethod			 != 'Origin History' 
		AND strPriceMethod			 != 'Posted Trans from CSV' 
		AND strPriceMethod			 != 'Network Cost' 
		AND LOWER(strPriceBasis)	 !=	'index cost'
		AND LOWER(strPriceBasis)	 !=	'index retail'
		AND LOWER(strPriceBasis)	 !=	'index fixed'
		AND LOWER(strPriceBasis)	 !=	'pump price adjustment'
		AND LOWER(strPriceBasis)	 !=	'transfer cost'
		AND LOWER(strPriceMethod)	 != 'item contracts'
		AND LOWER(strPriceMethod)	 != 'contracts'
	)
	AND strGUID = @strGUID

	--<< Remaining Pricing >>--



	IF(@ysnReRunCalcTax = 0)
	BEGIN
		
		SET @ysnReRunCalcTax = 1

		UPDATE tblCFImportTransactionStagingTable 
		SET ysnReRunCalcTax = 1
		WHERE strGUID = @strGUID

		GOTO TAXCOMPUTATION
	END

	
	-------------------------------------------------------
	------				 PRICE CALCULATION				 --
	-------------------------------------------------------



	-------------------------------------------------------
	------				MARGIN COMPUTATION				 --
	-------------------------------------------------------

	UPDATE tblCFImportTransactionStagingTable
	SET dblMarginNetPrice = dblCalculatedNetPrice
	WHERE strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = ISNULL(dblMarginNetPrice,0) - ISNULL(dblNetTransferCost,0)
	WHERE ISNULL(dblCalculatedTotalPrice,0) != 0
	AND strTransactionType = 'Remote' OR strTransactionType = 'Extended Remote'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET dblInventoryCost = dblAverageCost
	FROM vyuICGetItemPricing
	WHERE vyuICGetItemPricing.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND vyuICGetItemPricing.intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId
	AND ISNULL(dblCalculatedTotalPrice,0) != 0
	AND strTransactionType = 'Foreign Sale'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = ISNULL(dblMarginNetPrice,0) - ISNULL(dblOriginalNetPrice,0)
	WHERE ISNULL(dblCalculatedTotalPrice,0) != 0
	AND strTransactionType = 'Foreign Sale'
	AND ISNULL(dblInventoryCost,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = ISNULL(dblNetTransferCost,0) - ISNULL(dblInventoryCost,0)
	WHERE ISNULL(dblCalculatedTotalPrice,0) != 0
	AND strTransactionType = 'Foreign Sale'
	AND ISNULL(dblInventoryCost,0) != 0
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET dblInventoryCost = dblAverageCost
	FROM vyuICGetItemPricing
	WHERE vyuICGetItemPricing.intItemId = tblCFImportTransactionStagingTable.intARItemId
	AND vyuICGetItemPricing.intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId
	AND ISNULL(dblCalculatedTotalPrice,0) != 0
	AND (strTransactionType != 'Foreign Sale' AND strTransactionType != 'Remote' AND strTransactionType != 'Extended Remote')
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = ISNULL(dblMarginNetPrice,0) - ISNULL(dblNetTransferCost,0)
	WHERE ISNULL(dblCalculatedTotalPrice,0) != 0
	AND (strTransactionType != 'Foreign Sale' AND strTransactionType != 'Remote' AND strTransactionType != 'Extended Remote')
	AND ISNULL(dblInventoryCost,0) = 0 
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = ISNULL(dblMarginNetPrice,0) - ISNULL(dblInventoryCost,0)
	WHERE ISNULL(dblCalculatedTotalPrice,0) != 0
	AND (strTransactionType != 'Foreign Sale' AND strTransactionType != 'Remote' AND strTransactionType != 'Extended Remote')
	AND ISNULL(dblInventoryCost,0) != 0 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET dblMargin = 0
	WHERE ISNULL(dblCalculatedTotalPrice,0) = 0
	AND strGUID = @strGUID

	-------------------------------------------------------
	------				MARGIN COMPUTATION				 --
	-------------------------------------------------------

	-------------------------------------------------------
	------				LOG DUPLICATE TRANS				 --
	-------------------------------------------------------


	UPDATE tblCFImportTransactionStagingTable
	SET intDupTransCount = 
	( 
		SELECT 
			 intDupTransCount = COUNT(1)
		FROM tblCFTransaction
		WHERE intNetworkId		= tblCFImportTransactionStagingTable.intNetworkId
		AND intSiteId			= tblCFImportTransactionStagingTable.intSiteId
		AND dtmTransactionDate	= tblCFImportTransactionStagingTable.dtmTransactionDate
		AND intCardId			= tblCFImportTransactionStagingTable.intCardId
		AND intProductId		= tblCFImportTransactionStagingTable.intProductId
		AND intPumpNumber		= tblCFImportTransactionStagingTable.intPumpNumber
		AND intTransactionId   != tblCFImportTransactionStagingTable.intTransactionId
		AND (intOverFilledTransactionId IS NULL OR intOverFilledTransactionId = 0)
	)
	WHERE strTransactionType != 'Foreign Sale'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET intDupTransCount = 
	( 
		SELECT 
			 intDupTransCount = COUNT(1)
		FROM tblCFTransaction
		WHERE intNetworkId		= tblCFImportTransactionStagingTable.intNetworkId
		AND intSiteId			= tblCFImportTransactionStagingTable.intSiteId
		AND dtmTransactionDate	= tblCFImportTransactionStagingTable.dtmTransactionDate
		AND strForeignCardId	= tblCFImportTransactionStagingTable.strForeignCardId
		AND intProductId		= tblCFImportTransactionStagingTable.intProductId
		AND intPumpNumber		= tblCFImportTransactionStagingTable.intPumpNumber
		AND intTransactionId   != tblCFImportTransactionStagingTable.intTransactionId
		AND (intOverFilledTransactionId IS NULL OR intOverFilledTransactionId = 0)
	)
	WHERE strTransactionType = 'Foreign Sale'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDuplicate = 1 
	WHERE intDupTransCount > 0 AND ISNULL(intOverFilledTransactionId,0) = 0
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Import'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Duplicate transaction history found.'
	FROM tblCFImportTransactionStagingTable
	WHERE intDupTransCount > 0 
	AND ISNULL(intOverFilledTransactionId,0) = 0
	AND ysnDuplicate = 1
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET strParentContractTransactionId = (
		SELECT TOP 1 strTransactionId
		FROM tblCFTransaction
		WHERE intTransactionId = tblCFImportTransactionStagingTable.intOverFilledTransactionId
		AND strGUID = @strGUID
	)
	WHERE strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Import'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Overfill transaction of ' + strParentContractTransactionId
	FROM tblCFImportTransactionStagingTable
	WHERE intDupTransCount > 0 
	AND ISNULL(intOverFilledTransactionId,0) > 0
	AND ysnDuplicate = 1
	AND strGUID = @strGUID



	-------------------------------------------------------
	------				LOG DUPLICATE TRANS				 --
	-------------------------------------------------------


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 intItemLocation = intItemLocationId
		,intIssuUOM = intIssueUOMId
	FROM tblICItemLocation
	WHERE tblICItemLocation.intItemId = tblCFImportTransactionStagingTable.intARItemId AND tblICItemLocation.intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Item does not have setup for specified site location.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(intItemLocation,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  ISNULL(intItemLocation,0) = 0
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Invalid Item Location UOM.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(intIssuUOM,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  ISNULL(intIssuUOM,0) = 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		intCardId = NULL
	WHERE intCardId = 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnVehicleRequire = (SELECT TOP 1 a.ysnVehicleRequire
			FROM tblCFCard as c
			INNER JOIN tblCFAccount as a
			ON c.intAccountId = a.intAccountId
			WHERE intCardId = intCardId)
	WHERE intCardId != 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  (intProductId = 0 OR intProductId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  (intCardId = 0 OR intCardId IS NULL)
	AND strTransactionType != 'Foreign Sale'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intNetworkId = NULL
	WHERE  (intNetworkId = 0 OR intNetworkId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  (intNetworkId = 0 OR intNetworkId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intSiteId = NULL
	WHERE  (intSiteId = 0 OR intSiteId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  (intSiteId = 0 OR intSiteId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE  (dblQuantity = 0 OR dblQuantity IS NULL)
	AND strGUID = @strGUID
	

	----------------------------------------------------------
	------------------ Start get card type/ dual card
	----------------------------------------------------------
	
	UPDATE tblCFImportTransactionStagingTable
	SET intCardTypeId =  tblCFCard.intCardTypeId
	FROM tblCFCard
	WHERE tblCFCard.intCardId = tblCFImportTransactionStagingTable.intCardId
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnDualCard = tblCFCardType.ysnDualCard
	FROM tblCFCardType
	WHERE tblCFCardType.intCardTypeId = tblCFImportTransactionStagingTable.intCardTypeId
	AND strGUID = @strGUID

	----------------------------------------------------------
	------------------ End get card type/ dual card
	----------------------------------------------------------

	
	---------------------------------------------------------
	------------------ Start Zero Dollar Transaction
	----------------------------------------------------------

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 ysnExpensed = tblCFVehicle.ysnCardForOwnUse 
		,intExpensedItemId = tblCFVehicle.intExpenseItemId
	FROM tblCFVehicle
	WHERE tblCFVehicle.intVehicleId = tblCFImportTransactionStagingTable.intVehicleId 
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 ysnExpensed = tblCFCard.ysnCardForOwnUse 
		,intExpensedItemId = tblCFCard.intExpenseItemId
	FROM tblCFCard 
	WHERE tblCFCard.intCardId = tblCFImportTransactionStagingTable.intCardId 
	AND ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intExpensedItemId = NULL
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
		ysnInvalid = 1
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) = 0
	AND strGUID = @strGUID

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'No setup for expensed item.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) = 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		isExpensedItemHaveSiteLocation = (SELECT CASE WHEN COUNT(1) > 0 
					THEN 1
					ELSE 0
				END
			FROM tblICItemLocation 
			WHERE intItemId = tblCFImportTransactionStagingTable.intExpensedItemId 
			AND intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId)
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) != 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET strExpensedItem = strItemNo
	FROM tblICItem 
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) != 0
	AND tblICItem.intItemId = tblCFImportTransactionStagingTable.intExpensedItemId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET strLocationId = strLocationNumber + ' ' + strLocationName
	FROM tblSMCompanyLocation 
	WHERE intCompanyLocationId = tblCFImportTransactionStagingTable.intARItemLocationId
	AND ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) != 0
	AND ISNULL(isExpensedItemHaveSiteLocation,0) = 0
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) != 0
	AND ISNULL(isExpensedItemHaveSiteLocation,0) = 0
	AND strGUID = @strGUID

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Expensed item ' + strExpensedItem + ' does''nt have setup for location ' + strLocationId
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(tblCFImportTransactionStagingTable.ysnExpensed,0) != 0
	AND ISNULL(tblCFImportTransactionStagingTable.intExpensedItemId,0) != 0
	AND ISNULL(isExpensedItemHaveSiteLocation,0) = 0
	AND strGUID = @strGUID



	----------------------------------------------------------
	------------------ End Zero Dollar Transaction
	----------------------------------------------------------

	
	UPDATE tblCFImportTransactionStagingTable
	SET intVehicleId = NULL
	WHERE (ISNULL(intVehicleId,0) = 0 AND ISNULL(isImporting,0) = 0)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE (ISNULL(intVehicleId,0) = 0 AND ISNULL(isImporting,0) = 0)
	AND ISNULL(ysnVehicleRequire,0) = 1
	AND ((ISNULL(ysnDualCard,0) = 1 OR ISNULL(intCardTypeId,0) = 0) AND strTransactionType != 'Foreign Sale')
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Vehicle is required'
	FROM tblCFImportTransactionStagingTable
	WHERE (ISNULL(intVehicleId,0) = 0 AND ISNULL(isImporting,0) = 0)
	AND ISNULL(ysnVehicleRequire,0) = 1
	AND ((ISNULL(ysnDualCard,0) = 1 OR ISNULL(intCardTypeId,0) = 0) AND strTransactionType != 'Foreign Sale')
	AND strGUID = @strGUID

	-------------------------------------------------------
	------					ZERO PRICING				 --
	-------------------------------------------------------
	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ISNULL(ysnCaptiveSite,0) = 0
	AND ISNULL(dblCalculatedNetPrice,0) <= 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Invalid calculated price.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(ysnCaptiveSite,0) = 0
	AND ISNULL(dblCalculatedNetPrice,0) <= 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ISNULL(ysnCaptiveSite,0) = 0
	AND ISNULL(dblOriginalNetPrice,0) <= 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Invalid original price.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(ysnCaptiveSite,0) = 0
	AND ISNULL(dblOriginalNetPrice,0) <= 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID



	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ISNULL(ysnCaptiveSite,0) != 0
	AND ISNULL(dblCalculatedNetPrice,0) < 0
	AND strGUID = @strGUID

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Invalid calculated price.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(ysnCaptiveSite,0) != 0
	AND ISNULL(dblCalculatedNetPrice,0) < 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ISNULL(ysnCaptiveSite,0) != 0
	AND ISNULL(dblOriginalNetPrice,0) < 0
	AND strGUID = @strGUID

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Invalid original price.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(ysnCaptiveSite,0) != 0
	AND ISNULL(dblOriginalNetPrice,0) < 0
	AND strGUID = @strGUID

	-------------------------------------------------------
	------					ZERO PRICING				 --
	-------------------------------------------------------

	UPDATE tblCFImportTransactionStagingTable 
	SET ysnInvalid = 1
	WHERE ISNULL(ysnActive,0) = 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Customer is invalid.'
	FROM tblCFImportTransactionStagingTable
	WHERE ISNULL(ysnActive,0) = 0
	AND ISNULL(ysnPostedCSV,0) = 0
	AND strGUID = @strGUID


	
	-------------------------------------------------------
	------					INDEX PRICING				 --
	-------------------------------------------------------

	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'No index price found.'
	FROM tblCFImportTransactionStagingTable
	WHERE ((intPriceIndexId > 0 AND intPriceIndexId IS NOT NULL) 
	AND (strPriceIndexId IS NOT NULL) 
	AND (dblIndexPrice <=0 OR dblIndexPrice IS NULL)
	AND (ISNULL(ysnCaptiveSite,0) = 0))
	AND strGUID = @strGUID

	-------------------------------------------------------
	------					INDEX PRICING				 --
	-------------------------------------------------------


	-------------------------------------------------------
	------					PRICE OUT					 --
	-------------------------------------------------------

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblCalculatedGrossPrice = dblQuoteGrossPrice
		,dblCalculatedNetPrice = dblQuoteNetPrice
	WHERE ISNULL(strProcessType,'invoice') != 'invoice'
	AND isImporting = 1
	AND strGUID = @strGUID

	

	UPDATE tblCFTransaction 
	SET 
		 dblCalculatedGrossPrice		=  tblCFImportTransactionStagingTable.dblCalculatedGrossPrice
		,dblOriginalGrossPrice			=  tblCFImportTransactionStagingTable.dblOriginalGrossPrice	
		,dblCalculatedNetPrice			=  tblCFImportTransactionStagingTable.dblCalculatedNetPrice	
		,dblOriginalNetPrice			=  tblCFImportTransactionStagingTable.dblOriginalNetPrice	
		,dblCalculatedTotalPrice		=  tblCFImportTransactionStagingTable.dblCalculatedTotalPrice
		,dblOriginalTotalPrice			=  tblCFImportTransactionStagingTable.dblOriginalTotalPrice	
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFTransaction.intTransactionId	= tblCFImportTransactionStagingTable.intTransactionId
	AND tblCFImportTransactionStagingTable.isImporting = 1
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblOutOriginalTotalPrice		= dblOriginalTotalPrice	
		,dblOutCalculatedTotalPrice		= dblCalculatedTotalPrice
		,dblOutOriginalGrossPrice		= dblOriginalGrossPrice	
		,dblOutCalculatedGrossPrice		= dblCalculatedGrossPrice
		,dblOutCalculatedNetPrice		= dblCalculatedNetPrice	
		,dblOutOriginalNetPrice			= dblOriginalNetPrice	
	WHERE strGUID = @strGUID



	
		INSERT INTO [tblCFImportTransactionPricingType]
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
			,intItemContractHeaderId	
			,intItemContractDetailId	
			,strItemContractNumber		
			,intItemContractSeq		
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
			,dblOriginalTotalPrice	
			,dblCalculatedTotalPrice
			,dblOriginalGrossPrice	
			,dblCalculatedGrossPrice
			,dblCalculatedNetPrice	
			,dblOriginalNetPrice	
			,dblCalculatedPumpPrice	
			,dblOriginalPumpPrice	
			,ysnExpensed			  
			,intExpensedItemId	
			,[intTransactionId]
			,strGUID	  
		)
		SELECT
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
			,intItemContractHeaderId	 
			,intItemContractDetailId	 
			,strItemContractNumber		 
			,intItemContractSeq		 
			,strPriceBasis				 
			,intPriceProfileId			 
			,intPriceIndexId 			 
			,intSiteGroupId 			 
			,strPriceProfileId			 
			,strPriceIndexId			 
			,strSiteGroup				 
			,dblPriceProfileRate		 
			,dblIndexPrice			 
			,dtmPriceIndexDate			 
			,dblMargin					 
			,dblAdjustmentRate			 
			,ysnDuplicate				 
			,ysnInvalid				 
			,dblGrossTransferCost		 
			,dblNetTransferCost		 
			,intFreightTermId 
			,dblOutOriginalTotalPrice	 
			,dblOutCalculatedTotalPrice 
			,dblOutOriginalGrossPrice	 
			,dblOutCalculatedGrossPrice 
			,dblOutCalculatedNetPrice	 
			,dblOutOriginalNetPrice	 
			,dblOutCalculatedPumpPrice	 
			,dblOutOriginalPumpPrice	 
			,ysnExpensed
			,intExpensedItemId
			,intTransactionId
			,strGUID
		FROM tblCFImportTransactionStagingTable
		WHERE strGUID = @strGUID
		AND isImporting = 1

	
	-------------------------------------------------------
	------					TAXES OUT					 --
	-------------------------------------------------------


	UPDATE tblCFImportTransactionStagingTable
	SET ysnDuplicateTaxCount = 1
	WHERE intTransactionId IN ( SELECT intTransactionId 
								FROM tblCFImportTransactionTax
								WHERE strGUID = @strGUID
								GROUP BY 
					 				[intTaxCodeId]
									,[strTaxCode]
									,[intTransactionId]
								HAVING COUNT(*) > 1  ) 
	AND strGUID = @strGUID


	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'Duplicate tax code detected.'
	FROM tblCFImportTransactionStagingTable
	WHERE ysnDuplicateTaxCount = 1 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET ysnInvalid = 1
	WHERE ysnDuplicateTaxCount = 1 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionTax
	SET dblRate = CASE WHEN LOWER(strCalculationMethod) = 'percentage' 
					THEN ISNULL(dblRate,0) / (dblQuantity * dblCalculatedNetPrice)
					ELSE ISNULL(dblRate,0) / ISNULL(dblQuantity,0)
				  END
	FROM tblCFImportTransactionTax
	INNER JOIN tblCFImportTransactionStagingTable
	ON tblCFImportTransactionTax.intTransactionId  = tblCFImportTransactionStagingTable.intTransactionId
	WHERE strNetworkType = 'CFN' AND ISNULL(isImporting,0) = 1 AND ISNULL(tblCFImportTransactionStagingTable.intTaxGroupId,0) = 0
	AND tblCFImportTransactionTax.strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		 dblCalculatedGrossPrice = dblQuoteGrossPrice
		,dblCalculatedNetPrice = dblQuoteNetPrice
	WHERE ISNULL(strProcessType,'invoice') != 'invoice'
	AND isImporting = 1
	AND strGUID = @strGUID




	INSERT INTO tblCFImportTransactionTaxType
	(
		dblTaxCalculatedAmount
		,dblTaxOriginalAmount
		,intTaxCodeId
		,dblTaxRate 
		,strTaxCode
		,intTaxGroupId
		,strTaxGroup
		,strCalculationMethod
		,ysnTaxExempt
		,dblTaxCalculatedExemptAmount
		,intTransactionId
		,strGUID
	)
	SELECT 
		ISNULL(dblCalculatedTax,0) AS 'dblTaxCalculatedAmount'
		,ISNULL(dblOriginalTax,0)	AS 'dblTaxOriginalAmount'
		,intTaxCodeId
		,dblRate AS 'dblTaxRate'
		,(SELECT TOP 1 strTaxCode FROM tblSMTaxCode WHERE intTaxCodeId = T.intTaxCodeId) AS 'strTaxCode'
		,T.intTaxGroupId
		,(SELECT TOP 1 strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = T.intTaxGroupId) as 'strTaxGroup'
		,strCalculationMethod
		,ysnTaxExempt
		,T.dblTaxCalculatedExemptAmount
		,T.intTransactionId
		,@strGUID
	FROM tblCFImportTransactionTax AS T
	INNER JOIN tblCFImportTransactionStagingTable
	ON T.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL
	AND ISNULL(strProcessType,'invoice') = 'invoice'
	AND isImporting = 1
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID


	SELECT * 
	FROM tblCFImportTransactionTax AS T
	INNER JOIN tblCFImportTransactionStagingTable
	ON T.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	WHERE ysnInvalidSetup = 0 OR ysnInvalidSetup IS NULL
	AND ISNULL(strProcessType,'invoice') = 'invoice'
	AND isImporting = 1
	AND tblCFImportTransactionStagingTable.strGUID = '0ff04d02fd1b4312b03300239e842be7'

	SELECT intTransactionId,* FROM tblCFImportTransactionStagingTable



	INSERT INTO tblCFImportTransactionTaxType
	(
		 dblTaxCalculatedAmount
		,dblTaxOriginalAmount
		,intTaxCodeId
		,dblTaxRate 
		,strTaxCode
		,intTaxGroupId
		,strTaxGroup
		,strCalculationMethod
		,ysnTaxExempt
		,intTransactionId
		,strGUID
		--,dblTaxCalculatedExemptAmount
	)
	SELECT 
		 ISNULL(dblCalculatedTax,0) / dblZeroQuantity AS 'dblTaxCalculatedAmount'
		,ISNULL(dblOriginalTax,0) / dblZeroQuantity	AS 'dblTaxOriginalAmount'
		,intTaxCodeId
		,dblRate AS 'dblTaxRate'
		,(SELECT TOP 1 strTaxCode FROM tblSMTaxCode WHERE intTaxCodeId = T.intTaxCodeId) AS 'strTaxCode'
		,T.intTaxGroupId
		,(SELECT TOP 1 strTaxGroup FROM tblSMTaxGroup WHERE intTaxGroupId = T.intTaxGroupId) as 'strTaxGroup'
		,strCalculationMethod
		,ysnTaxExempt
		,T.intTransactionId
		,@strGUID
	--,dblTaxCalculatedExemptAmount
	FROM tblCFImportTransactionTaxZeroQuantity AS T
	INNER JOIN tblCFImportTransactionStagingTable
	ON T.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
	WHERE ISNULL(ysnInvalidSetup,0) = 0 AND ISNULL(ysnTaxExempt,0) = 0
	AND ISNULL(strProcessType,'invoice') != 'invoice'
	AND isImporting = 1
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	SELECT 'tblCFImportTransactionTaxType',* FROM tblCFImportTransactionTaxType
	-------------------------------------------------------
	------					TAXES OUT					 --
	-------------------------------------------------------


	-------------------------------------------------------
	------					INDEX PRICING				 --
	-------------------------------------------------------
	
	--NOTE: DUPLICATE??
	INSERT INTO tblCFTransactionNote (
		 strProcess
		,dtmProcessDate
		,strGuid
		,intTransactionId
		,strNote
	)
	SELECT
		 'Calculation'
		,strRunDate
		,strGUID
		,intTransactionId
		,'No index price found.'
	FROM tblCFImportTransactionStagingTable
	WHERE ((intPriceIndexId > 0 AND intPriceIndexId IS NOT NULL) 
	AND (strPriceIndexId IS NOT NULL) 
	AND (dblIndexPrice <=0 OR dblIndexPrice IS NULL)
	AND (ISNULL(ysnCaptiveSite,0) = 0))
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	-------------------------------------------------------
	------					INDEX PRICING				 --
	-------------------------------------------------------

	END