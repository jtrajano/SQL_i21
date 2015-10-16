CREATE PROCEDURE uspCFInsertTransactionRecord
	 @strSiteId						NVARCHAR(MAX)
	,@strCardId						NVARCHAR(MAX)
	,@strVehicleId					NVARCHAR(MAX)
	,@strProductId					NVARCHAR(MAX)
	,@strNetworkId					NVARCHAR(MAX)	= NULL
	,@intSiteId						INT				= 0
	,@intNetworkId					INT				= 0
	,@intTransTime					INT				= 0
	,@intOdometer					INT				= 0
	,@intPumpNumber					INT				= 0
	,@intContractId					INT				= 0
	,@intSalesPersonId				INT				= 0
	,@dtmBillingDate				DATETIME		= NULL
	,@dtmTransactionDate			DATETIME		= NULL
	,@strSequenceNumber				NVARCHAR(MAX)	= NULL
	,@strPONumber					NVARCHAR(MAX)	= NULL
	,@strMiscellaneous				NVARCHAR(MAX)	= NULL
	,@strPriceMethod				NVARCHAR(MAX)	= NULL
	,@strPriceBasis					NVARCHAR(MAX)	= NULL
	,@strTransactionType			NVARCHAR(MAX)	= NULL
	,@strDeliveryPickupInd			NVARCHAR(MAX)	= NULL
	,@dblQuantity					NUMERIC(18,6)	= 0.000000
	,@dblTransferCost				NUMERIC(18,6)	= 0.000000
	,@dblOriginalTotalPrice			NUMERIC(18,6)	= 0.000000
	,@dblCalculatedTotalPrice		NUMERIC(18,6)	= 0.000000
	,@dblOriginalGrossPrice			NUMERIC(18,6)	= 0.000000
	,@dblCalculatedGrossPrice		NUMERIC(18,6)	= 0.000000
	,@dblCalculatedNetPrice			NUMERIC(18,6)	= 0.000000
	,@dblOriginalNetPrice			NUMERIC(18,6)	= 0.000000
	,@dblCalculatedPumpPrice		NUMERIC(18,6)	= 0.000000
	,@dblOriginalPumpPrice			NUMERIC(18,6)	= 0.000000
AS
BEGIN
	DECLARE @intCardId				INT = 0
	DECLARE @intVehicleId			INT	= 0
	DECLARE @intProductId			INT	= 0
	DECLARE @intARItemId			INT	= 0
	DECLARE @intARItemLocationId	INT	= 0

	IF(@intSiteId = 0)
		BEGIN
			SET @intSiteId =(SELECT TOP 1 intSiteId
							FROM tblCFSite
							WHERE strSiteNumber = @strSiteId)
		END

	IF(@intNetworkId = 0)
		BEGIN
			SET @intNetworkId = (SELECT TOP 1 intNetworkId 
								FROM tblCFNetwork
								WHERE strNetwork = @strNetworkId)
		END

	SET @intCardId =(SELECT TOP 1 intCardId	
					FROM tblCFCard
					WHERE strCardNumber	= @strCardId)

	SET @intVehicleId =(SELECT TOP 1 intVehicleId
						FROM tblCFVehicle
						WHERE strVehicleNumber	= @strVehicleId)

	SET @intProductId = (SELECT TOP 1 intItemId 
						FROM tblCFItem 
						WHERE strProductNumber = @strProductId)

	SET @intARItemId = (SELECT TOP 1 intARItemId 
						FROM tblCFItem 
						WHERE strProductNumber = @strProductId)

	SET @intARItemLocationId = (SELECT TOP 1 intARLocationId
								FROM tblCFSite 
								WHERE strSiteNumber = @strSiteId)

	---------------------------
	--   PRICE COMPUTATION   --
	---------------------------
	CALCULATEPRICE:
	print 'calculatePrice'
	
	BEGIN
		DECLARE @intPrcCustomerId			INT				
		DECLARE @intPrcItemUOMId			INT
		DECLARE @dblPrcPriceOut				NUMERIC(18,6)	
		DECLARE @strPrcPricingOut			NVARCHAR(MAX)		
		DECLARE @intPrcAvailableQuantity	INT				
		DECLARE @dblPrcOriginalPrice		NUMERIC(18,6)	
		DECLARE @intPrcContractHeaderId		INT				
		DECLARE @intPrcContractDetailId		INT				
		DECLARE @intPrcContractNumber		INT				
		DECLARE @intPrcContractSeq			INT				
		DECLARE @strPrcPriceBasis			NVARCHAR(MAX)	
		DECLARE @dblCalcQuantity			NUMERIC(18,6)
		DECLARE @dblCalcOverfillQuantity	NUMERIC(18,6)
		

		SET @intPrcCustomerId =(SELECT TOP 1 A.intCustomerId	
						FROM tblCFCard C
						INNER JOIN tblCFAccount A
						ON C.intAccountId = A.intAccountId
						WHERE strCardNumber	= @strCardId)

		SET @intCardId =(SELECT TOP 1 intCardId	
						FROM tblCFCard
						WHERE strCardNumber	= @strCardId)

		SET @intPrcItemUOMId = (SELECT TOP 1 intIssueUOMId
								FROM tblICItemLocation
								WHERE intLocationId = @intARItemLocationId 
								AND intItemId = @intARItemId)

		SELECT @intARItemId	 AS intARItemId,
		 @intPrcCustomerId		 AS intPrcCustomerId,
		 @intARItemLocationId		 AS intARItemLocationId,
		 @dblQuantity			 AS dblQuantity,
		 @intPrcItemUOMId			 AS intPrcItemUOMId,
		 @dtmTransactionDate	 AS dtmTransactionDate,
		 @strTransactionType	 AS strTransactionType,
		 @intNetworkId	 AS intNetworkId,
		 @intSiteId		 AS intSiteId,
		 @dblTransferCost		 AS dblTransferCost,
		 @dblPrcPriceOut			as dblPrcPriceOut	,		
		 @strPrcPricingOut			as strPrcPricingOut	,	
		 @intPrcAvailableQuantity	as intPrcAvailableQuantity,
		 @dblPrcOriginalPrice		as dblPrcOriginalPrice	,
		 @intPrcContractHeaderId	as intPrcContractHeaderId	,
		 @intPrcContractDetailId	as intPrcContractDetailId	,
		 @intPrcContractNumber		as intPrcContractNumber	,
		 @intPrcContractSeq			as intPrcContractSeq		,
		 @strPrcPriceBasis			as strPrcPriceBasis		

		 
		select dblQuantity,dblScheduleQty,dblBalance from tblCTContractDetail where intContractDetailId = 43

	
		EXEC dbo.uspCFGetItemPrice 
			@CFItemId					=	@intARItemId,
			@CFCustomerId				=	@intPrcCustomerId,
			@CFLocationId				=	@intARItemLocationId,
			@CFQuantity					=	@dblQuantity,
			@CFItemUOMId				=	@intPrcItemUOMId,
			@CFTransactionDate			=	@dtmTransactionDate,
			@CFTransactionType			=	@strTransactionType,
			@CFNetworkId				=	@intNetworkId,
			@CFSiteId					=	@intSiteId,
			@CFTransferCost				=	@dblTransferCost,
			@CFPriceOut					=	@dblPrcPriceOut				output,
			@CFPricingOut				=	@strPrcPricingOut			output,
			@CFAvailableQuantity		=	@intPrcAvailableQuantity	output,
			@CFOriginalPrice			=	@dblPrcOriginalPrice		output,
			@CFContractHeaderId			=	@intPrcContractHeaderId		output,
			@CFContractDetailId			=	@intPrcContractDetailId		output,
			@CFContractNumber			=	@intPrcContractNumber		output,
			@CFContractSeq				=	@intPrcContractSeq			output,
			@CFPriceBasis				=	@strPrcPriceBasis			output

		select  
			 @dblPrcPriceOut			AS price
			,@strPrcPricingOut			AS pricing
			,@intPrcAvailableQuantity	AS availableQuantity
			,@dblPrcOriginalPrice		AS originalPrice
			,@intPrcContractHeaderId	AS contractHeader
			,@intPrcContractDetailId	AS contractDetail
			,@intPrcContractNumber		AS contractNumber
			,@intPrcContractSeq			AS contractSequence
			,@strPrcPriceBasis			AS priceBasis

		SET @strPriceMethod   = @strPrcPricingOut
		SET @strPriceBasis = @strPrcPriceBasis
		SET @intContractId	  = @intPrcContractDetailId
		SET @dblCalcOverfillQuantity = 0;
		SET @dblCalcQuantity = 0;

		IF (@strPriceMethod = 'Inventory - Standard Pricing')
		BEGIN
					SET @intContractId = null
					SET @strPrcPriceBasis = null
					SET @dblTransferCost = 0
					SET @strPriceMethod = 'Standard Pricing'
		END
		ELSE IF (@strPriceMethod = 'Special Pricing')
		BEGIN
					SET @intContractId = null
					SET @strPrcPriceBasis = null
					SET @dblTransferCost = 0
					SET @strPriceMethod = 'Special Pricing'
		END
		ELSE IF (@strPriceMethod = 'Price Profile')
		BEGIN
					SET @intContractId = null
					SET @strPrcPriceBasis = @strPrcPriceBasis
					SET @strPriceMethod = 'Price Profile'

					IF(@strPrcPriceBasis = 'Transfer Cost' OR @strPrcPriceBasis = 'Transfer Price' OR @strPrcPriceBasis = 'Discounted Price')
						BEGIN
							SET @dblTransferCost = @dblTransferCost
						END
					ELSE
						BEGIN
							SET @dblTransferCost = 0
						END
		END
		ELSE IF (@strPriceMethod = 'Contracts - Customer Pricing')
		BEGIN
					SET @strPrcPriceBasis = null
					SET @dblTransferCost = 0
					SET @strPriceMethod = 'Contract Pricing'
					
					print 's'
					print @intPrcAvailableQuantity
					print @dblQuantity
					print @dblCalcOverfillQuantity

					IF(@intPrcAvailableQuantity < @dblQuantity)
						BEGIN
							SET @dblCalcQuantity = @intPrcAvailableQuantity
							SET @dblCalcOverfillQuantity = @dblQuantity - @intPrcAvailableQuantity
							SET @dblQuantity = @intPrcAvailableQuantity
							print 'calc'
							print @dblCalcOverfillQuantity
						END
					ELSE
						BEGIN
							SET @dblCalcQuantity = @dblQuantity
						END

					print 'e'
					print @intPrcAvailableQuantity
					print @dblQuantity
					print @dblCalcOverfillQuantity
		END
	
		INSERT INTO tblCFTransaction(
			 [intSiteId]					
			,[intCardId]					
			,[intVehicleId]				
			,[intProductId]			
			,[intNetworkId]
			,[intARItemId]
			,[intARLocationId]				
			,[intContractId]				
			,[dblQuantity]				
			,[dtmBillingDate]			
			,[dtmTransactionDate]		
			,[intTransTime]				
			,[strSequenceNumber]		
			,[strPONumber]				
			,[strMiscellaneous]			
			,[intOdometer]				
			,[intPumpNumber]				
			,[dblTransferCost]			
			,[strPriceMethod]			
			,[strPriceBasis]				
			,[strTransactionType]		
			,[strDeliveryPickupInd]		
			,[dblOriginalTotalPrice]		
			,[dblCalculatedTotalPrice]	
			,[dblOriginalGrossPrice]		
			,[dblCalculatedGrossPrice]	
			,[dblCalculatedNetPrice]		
			,[dblOriginalNetPrice]		
			,[dblCalculatedPumpPrice]	
			,[dblOriginalPumpPrice]		
			,[intSalesPersonId]			
		)
		VALUES
		(
			 @intSiteId				
			,@intCardId			
			,@intVehicleId			
			,@intProductId	
			,@intNetworkId
			,@intARItemId
			,@intARItemLocationId			
			,@intContractId			
			,@dblQuantity				
			,@dtmBillingDate			
			,@dtmTransactionDate		
			,@intTransTime				
			,@strSequenceNumber	
			,@strPONumber			
			,@strMiscellaneous			
			,@intOdometer			
			,@intPumpNumber			
			,@dblTransferCost			
			,@strPriceMethod			
			,@strPriceBasis			
			,@strTransactionType		
			,@strDeliveryPickupInd
			,@dblOriginalTotalPrice	
			,@dblCalculatedTotalPrice	
			,@dblOriginalGrossPrice	
			,@dblCalculatedGrossPrice	
			,@dblCalculatedNetPrice	
			,@dblOriginalNetPrice	
			,@dblCalculatedPumpPrice	
			,@dblOriginalPumpPrice	
			,@intSalesPersonId		
		)			
	
		DECLARE @Pk	INT		
		SELECT @Pk  = SCOPE_IDENTITY();

		-------------------------------
		-- UPDATE CONTRACTS QUANTITY --
		-------------------------------

		IF (@strPriceMethod = 'Contract Pricing')
		BEGIN
			EXEC uspCTUpdateScheduleQuantity 
			 @intContractDetailId = @intContractId
			,@dblQuantityToUpdate = @dblCalcQuantity
			,@intUserId = 0
			,@intExternalId = @Pk
			,@strScreenName = 'Card Fueling Transaction Screen'
		END

		INSERT INTO tblCFTransactionPrice(
			 [intTransactionId]
			,[strTransactionPriceId]
			,[dblOriginalAmount]
			,[dblCalculatedAmount]
		)
		VALUES
		(
			@Pk
			,'Gross Price'
			,@dblPrcOriginalPrice -- +TAX
			,@dblPrcPriceOut	  -- +TAX
		),
		(
			@Pk
			,'Net Price'
			,@dblPrcOriginalPrice 
			,@dblPrcPriceOut	 
		),
		(
			@Pk
			,'Total Amount'
			,@dblPrcOriginalPrice * @dblQuantity
			,@dblPrcPriceOut      * @dblQuantity
		)
		END

		print @dblCalcOverfillQuantity
		IF(@dblCalcOverfillQuantity > 0)
		BEGIN
			SET @dblQuantity = @dblCalcOverfillQuantity
			SET @dblPrcPriceOut				  = NULL
			SET @strPrcPricingOut			  = NULL
			SET @intPrcAvailableQuantity	  = NULL
			SET @dblPrcOriginalPrice		  = NULL
			SET @intPrcContractHeaderId		  = NULL
			SET @intPrcContractDetailId		  = NULL
			SET @intPrcContractNumber		  = NULL
			SET @intPrcContractSeq			  = NULL
			SET @strPrcPriceBasis			  = NULL
			print 'goto calculate price'
			GOTO CALCULATEPRICE
		END
	END
GO


