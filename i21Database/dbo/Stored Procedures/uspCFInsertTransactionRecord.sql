CREATE PROCEDURE [dbo].[uspCFInsertTransactionRecord]
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
	
	DECLARE @intTaxGroupId			INT = 0
	DECLARE @intTaxMasterId			INT = 0
	DECLARE @strCountry				NVARCHAR(MAX)
	DECLARE @strCounty				NVARCHAR(MAX)
	DECLARE @strCity				NVARCHAR(MAX)
	DECLARE @strState				NVARCHAR(MAX)
	DECLARE @intCustomerId			INT = 0
	DECLARE @tblTaxTable			TABLE
	(
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[numRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
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
		,[numRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
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
		,[numRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
	)

	DECLARE @ysnInvalid					BIT	= 0
	DECLARE @ysnPosted					BIT = 0

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

	---------------------------------------
	-- SET intCard && intCustomerId value--
	SELECT TOP 1 
		 @intCardId = C.intCardId
		,@intCustomerId = A.intCustomerId
	FROM tblCFCard C
	INNER JOIN tblCFAccount A
	ON C.intAccountId = A.intAccountId
	WHERE C.strCardNumber = @strCardId
	---------------------------------------

	-------------------------------------------------------
	-- SET intItemId && intProductId && intARItemId value--
	 SELECT TOP 1 
		 @intProductId = intItemId
		,@intARItemId = intARItemId
		,@intTaxMasterId = intTaxGroupMaster
	FROM tblCFItem 
	WHERE strProductNumber = @strProductId
	-------------------------------------------------------

	SET @intARItemLocationId = (SELECT TOP 1 intARLocationId
								FROM tblCFSite 
								WHERE intSiteId = @intSiteId)
	SET @intVehicleId =(SELECT TOP 1 intVehicleId
						FROM tblCFVehicle
						WHERE strVehicleNumber	= @strVehicleId)
								
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

	
		--IF(@dtmTransactionDate = 0 OR @dtmTransactionDate IS NULL)
		--BEGIN
		--	SET @ysnInvalid = 1
		--END
		IF(@intARItemId = 0 OR @intARItemId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intPrcCustomerId = 0 OR @intPrcCustomerId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intARItemLocationId = 0 OR @intARItemLocationId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intPrcItemUOMId = 0 OR @intPrcItemUOMId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intNetworkId = 0 OR @intNetworkId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intSiteId = 0 OR @intSiteId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intCardId = 0 OR @intCardId IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		

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

		set @dblPrcOriginalPrice = @dblOriginalGrossPrice

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
					
					--print 's'
					--print @intPrcAvailableQuantity
					--print @dblQuantity
					--print @dblCalcOverfillQuantity

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


		---------------------------
		--	  GET TAX RECORDS    --
		---------------------------
	
		SELECT  
		@strCountry = strCountry 
		,@strCity = strCity
		,@strState = strStateProvince
		FROM tblSMCompanyLocation 
		WHERE intCompanyLocationId = @intARItemLocationId

		SELECT @intTaxGroupId = [dbo].[fnGetTaxGroupForLocation]
		(@intTaxMasterId, @strCountry, @strCounty, @strCity, @strState)

		INSERT INTO @tblTaxTable
		SELECT
		[intTransactionDetailTaxId]
		,[intTransactionDetailId]  AS [intInvoiceDetailId]
		,NULL
		,[intTaxGroupId]
		,[intTaxCodeId]
		,[intTaxClassId]
		,[strTaxableByOtherTaxes]
		,[strCalculationMethod]
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]    AS [intSalesTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
		FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer]
		(@intTaxGroupId, @intCustomerId, @dtmTransactionDate, @intARItemId, NULL, 0)
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
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]    AS [intSalesTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
		FROM @tblTaxTable
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
		,[numRate]
		,[dblTax]
		,[dblAdjustedTax]
		,[intTaxAccountId]    AS [intSalesTaxAccountId]
		,[ysnSeparateOnInvoice]
		,[ysnCheckoffTax]
		,[strTaxCode]
		,[ysnTaxExempt]
		,[strTaxGroup]
		FROM @tblTaxTable
		WHERE LOWER(strCalculationMethod) = 'unit'

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
			,[ysnPosted]
			,[ysnInvalid]			
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
			,@ysnPosted
			,@ysnInvalid		
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


		--------------------
		-- CALCULATE TAX  --
		--------------------

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

		
		SET @QxOP = @dblQuantity * @dblPrcOriginalPrice
		SET @QxCP = @dblQuantity * @dblPrcPriceOut
		

		SELECT @dblPrcOriginalPrice as 'dblPrcOriginalPrice'
		WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxUnitTable))
		BEGIN
			SELECT TOP 1 
			 @intLoopTaxGroupID = intTaxGroupId
			,@intLoopTaxCodeID = intTaxCodeId
			,@intLoopTaxClassID = intTaxClassId
			,@QxT = ROUND (@dblQuantity * numRate,6)
			,@QxOP = ROUND (@QxOP - (@dblQuantity * numRate),6)
			,@dblOPTotalTax = ROUND (@dblOPTotalTax + (@dblQuantity * numRate),6)
			,@dblCPTotalTax = ROUND (@dblCPTotalTax +  numRate,6)
			,@strLoopTaxCode = strTaxCode
			FROM @tblTaxUnitTable

			INSERT INTO tblCFTransactionTax(
				 [intTransactionId]
				,[strTransactionTaxId]
				,[dblTaxOriginalAmount]
				,[dblTaxCalculatedAmount]
			)
			VALUES(
				@Pk
				,@strLoopTaxCode
				,(CASE WHEN(@dblPrcOriginalPrice = 0 OR @dblPrcOriginalPrice IS NULL) 
					THEN 0 
					ELSE @QxT END)
				,(CASE WHEN(@dblPrcPriceOut = 0 OR @dblPrcPriceOut IS NULL) 
					THEN 0 
					ELSE @QxT END)
			)

			DELETE FROM @tblTaxUnitTable 
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID

		END


		WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxRateTable))
		BEGIN


			SELECT TOP 1 
			 @intLoopTaxGroupID = intTaxGroupId
			,@intLoopTaxCodeID = intTaxCodeId
			,@intLoopTaxClassID = intTaxClassId
			,@OPTax = ROUND (((@QxOP / (numRate/100 +1 )) * (numRate/100)),6)
			,@CPTax = ROUND (@QxCP * (numRate/100),6)
			,@dblOPTotalTax = ROUND (@dblOPTotalTax +  ((@QxOP / (numRate/100 +1 )) * (numRate/100)),6)
			,@dblCPTotalTax = ROUND (@dblCPTotalTax +  (@dblPrcPriceOut * (numRate/100)),6)
			,@strLoopTaxCode = strTaxCode
			FROM @tblTaxRateTable

			INSERT INTO tblCFTransactionTax(
				 [intTransactionId]
				,[strTransactionTaxId]
				,[dblTaxOriginalAmount]
				,[dblTaxCalculatedAmount]
			)
			VALUES(
				@Pk
				,@strLoopTaxCode
				,@OPTax
				,@CPTax
			)

			DELETE FROM @tblTaxRateTable 
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID

		END

		-------------------------------
		-- INSERT TRANSACTION PRICE  --
		-------------------------------
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
			,@dblPrcOriginalPrice	-- +TAX
			,@dblPrcPriceOut	  + @dblCPTotalTax-- +TAX
		),
		(
			@Pk
			,'Net Price'
			,(((@dblPrcOriginalPrice * @dblQuantity) - @dblOPTotalTax) / @dblQuantity)
			,@dblPrcPriceOut	 
		),
		(
			@Pk
			,'Total Amount'
			,@dblPrcOriginalPrice * @dblQuantity
			,(@dblPrcPriceOut + @dblCPTotalTax) * @dblQuantity
		)
		END

		--IF (@ysnInvalid = 0)
		--BEGIN
		--	DECLARE	@ErrorMessage NVARCHAR(250)
		--	EXEC [uspCFProcessTransactionToInvoice] 
		--	 @TransactionId = @Pk
		--	,@UserId = 1
		--	,@ErrorMessage = @ErrorMessage OUTPUT
		--	,@Post = 1

		--	--IF (@ErrorMessage IS NULL)
		--	--BEGIN
		--	--	UPDATE tblCFTransaction SET ysnPosted = 1 WHERE intTransactionId = @Pk
		--	--END
		--END
		

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