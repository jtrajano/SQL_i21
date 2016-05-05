CREATE PROCEDURE [dbo].[uspCFInsertTransactionRecord]
	
	 @strCardId						NVARCHAR(MAX)
	,@strVehicleId					NVARCHAR(MAX)
	,@strProductId					NVARCHAR(MAX)
	,@strNetworkId					NVARCHAR(MAX)	= NULL
	,@intNetworkId					INT				= 0
	,@intTransTime					INT				= 0
	,@intOdometer					INT				= 0
	,@intPumpNumber					INT				= 0
	,@intContractId					INT				= 0
	,@intSalesPersonId				INT				= NULL
	,@dtmBillingDate				DATETIME		= NULL
	,@dtmTransactionDate			DATETIME		= NULL
	,@strSequenceNumber				NVARCHAR(MAX)	= NULL
	,@strPONumber					NVARCHAR(MAX)	= NULL
	,@strMiscellaneous				NVARCHAR(MAX)	= NULL
	,@strPriceMethod				NVARCHAR(MAX)	= NULL
	,@strPriceBasis					NVARCHAR(MAX)	= NULL
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

	-------------SITE RELATED-------------
	,@strSiteId						NVARCHAR(MAX)
	,@strTransactionType			NVARCHAR(MAX)	= NULL
	,@strDeliveryPickupInd			NVARCHAR(MAX)	= NULL
	,@intSiteId						INT				= 0
	,@strSiteState					NVARCHAR(MAX)	= NULL
	,@strSiteAddress				NVARCHAR(MAX)	= NULL
	,@strSiteCity					NVARCHAR(MAX)	= NULL
	,@intPPHostId					INT				= 0
	,@strPPSiteType					NVARCHAR(MAX)	= NULL
	,@strSiteType					NVARCHAR(MAX)	= NULL
	--------------------------------------

	-------------REMOTE TAXES-------------
	--  1. REMOTE TRANSACTION			--
	--  2. EXT. REMOTE TRANSACTION 		--
	--------------------------------------
	,@TaxState							NVARCHAR(MAX)
	,@FederalExciseTaxRate        		NUMERIC(18,6)	= 0.000000
	,@StateExciseTaxRate1         		NUMERIC(18,6)	= 0.000000
	,@StateExciseTaxRate2         		NUMERIC(18,6)	= 0.000000
	,@CountyExciseTaxRate         		NUMERIC(18,6)	= 0.000000
	,@CityExciseTaxRate           		NUMERIC(18,6)	= 0.000000
	,@StateSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000
	,@CountySalesTaxPercentageRate		NUMERIC(18,6)	= 0.000000
	,@CitySalesTaxPercentageRate  		NUMERIC(18,6)	= 0.000000
	,@OtherSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000
	--,@LC7							NUMERIC(18,6)	= 0.000000
	--,@LC8							NUMERIC(18,6)	= 0.000000
	--,@LC9							NUMERIC(18,6)	= 0.000000
	--,@LC10							NUMERIC(18,6)	= 0.000000
	--,@LC11							NUMERIC(18,6)	= 0.000000
	--,@LC12							NUMERIC(18,6)	= 0.000000

--'Federal Excise Tax Rate'
--'State Excise Tax Rate 1'
--'State Excise Tax Rate 2'
--'County Excise Tax Rate'
--'City Excise Tax Rate'
--'State Sales Tax Percentage Rate'
--'County Sales TaxPercentage Rate'
--'City Sales Tax Percentage Rate'
--'Other Sales Tax Percentage Rate'



AS
BEGIN
	
	------------------------------------------------------------
	--			    TRUNCATE IMPORT LOG TABLE 				  --
	------------------------------------------------------------
	--truncate table tblCFFailedImportedTransaction
	------------------------------------------------------------




	------------------------------------------------------------
	--					  DECLARE VARIABLE 					  --
	------------------------------------------------------------

	--LOGS--
	DECLARE @ysnSiteCreated			BIT = 0
	DECLARE @ysnSiteItemUsed		BIT = 0
	DECLARE @ysnNetworkItemUsed		BIT = 0
	--LOGS--


	DECLARE @intCardId				INT = 0
	DECLARE @intVehicleId			INT	= 0
	DECLARE @intProductId			INT	= 0
	DECLARE @intARItemId			INT	= NULL
	DECLARE @intARItemLocationId	INT	= 0
	DECLARE @intCustomerLocationId  INT	= 0
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
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[ysnInvalid]					BIT
		,[strReason]					NVARCHAR(MAX)
		,[strNotes]						NVARCHAR(MAX)
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
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
	)
	DECLARE @ysnInvalid				BIT	= 0
	DECLARE @ysnPosted				BIT = 0
	------------------------------------------------------------





	------------------------------------------------------------
	--					SET VARIABLE VALUE					  --
	------------------------------------------------------------
	IF(@intSalesPersonId = 0)
		BEGIN
			SET @intSalesPersonId = NULL
		END
	IF(@intSiteId = 0)
		BEGIN
			SELECT TOP 1 @intSiteId = intSiteId 
						,@intCustomerLocationId = intARLocationId
						,@intTaxMasterId = intTaxGroupId
						FROM tblCFSite
						WHERE strSiteNumber = @strSiteId

	IF(@intNetworkId = 0)
		BEGIN
			SELECT TOP 1 @intNetworkId = intNetworkId 
			FROM tblCFNetwork
			WHERE strNetwork = @strNetworkId
	END
	
	------------------------------------------------------------
	--					AUTO CREATE SITE
	-- if transaction is remote or ext remote				  --
	------------------------------------------------------------
	IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND (@strPPSiteType = 'N' OR @strPPSiteType = 'R'))
		BEGIN 
			DECLARE @strNetworkType						NVARCHAR(MAX)
			DECLARE @intNetworkLocation					INT

			SELECT 
				 @strNetworkType = strNetworkType
				,@intNetworkLocation = intLocationId
			FROM tblCFNetwork
			WHERE intNetworkId = @intNetworkId

			INSERT INTO tblCFSite
			(
				intNetworkId		
				,strSiteNumber	
				,strSiteName
				,strDeliveryPickup	
				,intARLocationId	
				,strControllerType	
				,strTaxState		
				,strSiteAddress		
				,strSiteCity		
				,intPPHostId		
				,strPPSiteType		
				,strSiteType
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteId
				,strDeliveryPickup		= 'Pickup'
				,intARLocationId		= @intNetworkLocation
				,strControllerType		= (CASE @strNetworkType 
											WHEN 'PacPride' 
												THEN 'PacPride'
											ELSE 'CFN'
											END)
				,strTaxState			= @strSiteState
				,strSiteAddress			= @strSiteAddress	
				,strSiteCity			= @strSiteCity	
				,intPPHostId			= @intPPHostId	
				,strPPSiteType			= (CASE @strPPSiteType 
											WHEN 'N' 
												THEN 'Network'
											WHEN 'X' 
												THEN 'Exclusive'
											WHEN 'R' 
												THEN 'Retail'
											END)	
				,strSiteType			= (CASE @strPPSiteType 
											WHEN 'N' 
												THEN 'Remote'
											WHEN 'R' 
												THEN 'Extended Remote'
											END)

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;

			END
			
	END
	SELECT TOP 1 
		 @intCardId = C.intCardId
		,@intCustomerId = A.intCustomerId
	FROM tblCFCard C
	INNER JOIN tblCFAccount A
	ON C.intAccountId = A.intAccountId
	WHERE C.strCardNumber = @strCardId

	--FIND IN SITE ITEM--
	IF(@intProductId = 0)
	BEGIN
		SELECT TOP 1 
			 @intProductId = intItemId
			,@intARItemId = intARItemId
		FROM tblCFItem 
		WHERE strProductNumber = @strProductId
		AND intNetworkId IS NULL

		IF(@intProductId != 0)
		BEGIN
			SET @ysnSiteItemUsed = 1
			SET @ysnNetworkItemUsed = 0
		END
	END

	--FIND IN NETWORK ITEM--
	IF(@intProductId = 0)
	BEGIN
		SELECT TOP 1 
			 @intProductId = intItemId
			,@intARItemId = intARItemId
		FROM tblCFItem 
		WHERE strProductNumber = @strProductId
		AND intSiteId IS NULL

		IF(@intProductId != 0)
		BEGIN
			SET @ysnSiteItemUsed = 0
			SET @ysnNetworkItemUsed = 1
		END

	END

	SET @intARItemLocationId = (SELECT TOP 1 intARLocationId
								FROM tblCFSite 
								WHERE intSiteId = @intSiteId)

	SET @intVehicleId =(SELECT TOP 1 intVehicleId
						FROM tblCFVehicle
						WHERE strVehicleNumber	= @strVehicleId)
	------------------------------------------------------------





	------------------------------------------------------------
	--					FOR OVERFILL TRANSACTION			  --
	------------------------------------------------------------
	CALCULATEPRICE:
	--print 'OVER FILL TRANSACTION'
	
	
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
	------------------------------------------------------------





		------------------------------------------------------------
		--						 VALIDATION						  --
		------------------------------------------------------------
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
		------------------------------------------------------------





		------------------------------------------------------------
		--				       GET ITEM PRICE					  --
		------------------------------------------------------------

		SELECT @intARItemId			AS intARItemId,
		 @intPrcCustomerId			AS intPrcCustomerId,
		 @intARItemLocationId		AS intARItemLocationId,
		 @dblQuantity				AS dblQuantity,
		 @intPrcItemUOMId			AS intPrcItemUOMId,
		 @dtmTransactionDate		AS dtmTransactionDate,
		 @strTransactionType		AS strTransactionType,
		 @intNetworkId				AS intNetworkId,
		 @intSiteId					AS intSiteId,
		 @dblTransferCost			AS dblTransferCost,
		 @dblPrcPriceOut			AS dblPrcPriceOut,		
		 @strPrcPricingOut			AS strPrcPricingOut,	
		 @intPrcAvailableQuantity	AS intPrcAvailableQuantity,
		 @dblPrcOriginalPrice		AS dblPrcOriginalPrice,
		 @intPrcContractHeaderId	AS intPrcContractHeaderId,
		 @intPrcContractDetailId	AS intPrcContractDetailId,
		 @intPrcContractNumber		AS intPrcContractNumber,
		 @intPrcContractSeq			AS intPrcContractSeq,
		 @strPrcPriceBasis			AS strPrcPriceBasis		
		SET @dblPrcOriginalPrice = @dblOriginalGrossPrice
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
		--SELECT  
		--	 @dblPrcPriceOut			AS price
		--	,@strPrcPricingOut			AS pricing
		--	,@intPrcAvailableQuantity	AS availableQuantity
		--	,@dblPrcOriginalPrice		AS originalPrice
		--	,@intPrcContractHeaderId	AS contractHeader
		--	,@intPrcContractDetailId	AS contractDetail
		--	,@intPrcContractNumber		AS contractNumber
		--	,@intPrcContractSeq			AS contractSequence
		--	,@strPrcPriceBasis			AS priceBasis
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
		IF (@strPriceMethod = 'Import File Price')
		BEGIN
					SET @intContractId = null
					SET @strPrcPriceBasis = null
					SET @dblTransferCost = 0
					SET @strPriceMethod = 'Import File Price'
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
		------------------------------------------------------------




		------------------------------------------------------------
		--				INSERT TRANSACTION RECORD				  --
		------------------------------------------------------------
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


		------------------------------------------------------------
		--				INSERT IMPORT ERROR LOGS				  --
		------------------------------------------------------------
		IF(@intARItemId = 0 OR @intARItemId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find product number ' + @strProductId + ' into i21 site item list')
		END
		IF(@intPrcCustomerId = 0 OR @intPrcCustomerId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find customer number using card number ' + @strCardId + ' into i21 card account list')
		END
		IF(@intARItemLocationId = 0 OR @intARItemLocationId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid location for site ' + @strSiteId)
		END
		IF(@intPrcItemUOMId = 0 OR @intPrcItemUOMId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid UOM for product number ' + @strProductId)
		END
		IF(@intNetworkId = 0 OR @intNetworkId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find network ' + @strNetworkId + ' into i21 network list')
		END
		IF(@intSiteId = 0 OR @intSiteId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find site ' + @strSiteId + ' into i21 site list')
		END
		IF(@ysnSiteCreated != 0)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Site ' + @strSiteId + ' has been automatically created')
		END
		IF(@intCardId = 0 OR @intCardId IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find card number ' + @strCardId + ' into i21 card list')
		END
		IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid quantity - ' + @dblQuantity)
		END
		IF(@ysnSiteItemUsed = 0 AND @ysnNetworkItemUsed = 1)
		BEGIN
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Network item ' + @strProductId + ' has been used')
		END
		ELSE IF(@ysnSiteItemUsed = 1 AND @ysnNetworkItemUsed = 0)
		BEGIN 
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Site item ' + @strProductId + ' has been used')
		END

		


		------------------------------------------------------------







		------------------------------------------------------------
		--				UPDATE CONTRACTS QUANTITY				  --
		------------------------------------------------------------
		IF (@strPriceMethod = 'Contract Pricing')
		BEGIN
			EXEC uspCTUpdateScheduleQuantity 
			 @intContractDetailId = @intContractId
			,@dblQuantityToUpdate = @dblCalcQuantity
			,@intUserId = 0
			,@intExternalId = @Pk
			,@strScreenName = 'Card Fueling Transaction Screen'
		END
		------------------------------------------------------------





		

		------------------------------------------------------------
		--				       GET TAX RECORDS					  --
		------------------------------------------------------------
		IF (@strTransactionType = 'Local/Network')
		BEGIN
			SELECT  
			@strCountry = strCountry 
			,@strCity = strCity
			,@strState = strStateProvince
			FROM tblSMCompanyLocation 
			WHERE intCompanyLocationId = @intARItemLocationId

			SELECT @intTaxGroupId = @intTaxMasterId ----------HERE-------------

		INSERT INTO @tblTaxTable
		(
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
		)
		SELECT
			 [intTransactionDetailTaxId]
			,[intTransactionDetailId]  AS [intInvoiceDetailId]
			,NULL
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
			,[strTaxGroup]
		FROM
		[dbo].[fnGetTaxGroupTaxCodesForCustomer]
		(@intTaxGroupId, @intCustomerId, @dtmTransactionDate, @intARItemId, NULL, 0,NULL)
			
		END 
		ELSE IF (@strTransactionType = 'Remote'  OR @strTransactionType = 'Extended Remote')
		BEGIN

		INSERT INTO @tblTaxTable 
		(
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
			,[ysnInvalid]				
			,[strReason]
			,[strNotes]
			)		
		SELECT
			 [intTransactionDetailTaxId]
			,[intTransactionDetailId]  AS [intInvoiceDetailId]
			,NULL
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
			,[strTaxGroup]
			,[ysnInvalidSetup]
			,[strReason]
			,[strNotes]
		 FROM
		 [dbo].[fnCFRemoteTaxes](
			 @TaxState		
			,''
			,@FederalExciseTaxRate        	
			,@StateExciseTaxRate1         	
			,@StateExciseTaxRate2         	
			,@CountyExciseTaxRate         	
			,@CityExciseTaxRate           	
			,@StateSalesTaxPercentageRate 	
			,@CountySalesTaxPercentageRate		
			,@CitySalesTaxPercentageRate  		
			,@OtherSalesTaxPercentageRate 		
			--,@LC7		
			--,@LC8		
			--,@LC9		
			--,@LC10			
			--,@LC11			
			--,@LC12			
			,@intNetworkId
			,@intARItemId				
			,@intARItemLocationId			
			,@intCustomerId				
			,@intCustomerLocationId		
			,@dtmTransactionDate	)
							
		END

		------------------------------------------------------------
		--					NOTE FOR EXEMPTED TAX				  --
		------------------------------------------------------------
		INSERT INTO tblCFFailedImportedTransaction
		(
			intTransactionId
			,strFailedReason
		)
		SELECT
			@Pk 					 	
			,'Tax code ' + strTaxCode + ' is checked off' 
		FROM @tblTaxTable
		WHERE ysnCheckoffTax = 1


		INSERT INTO tblCFFailedImportedTransaction
		(
			intTransactionId
			,strFailedReason
		)
		SELECT
			@Pk 					 	
			,strNotes
		FROM @tblTaxTable
		WHERE ysnTaxExempt = 1
		
		------------------------------------------------------------
		--			VALIDATION FOR UNMAPPED NETWORK TAX			  --
		------------------------------------------------------------
		INSERT INTO tblCFFailedImportedTransaction
		(
			intTransactionId
			,strFailedReason
		)
		SELECT
			@Pk 					 	
			,strReason
		FROM @tblTaxTable
		WHERE ysnInvalid = 1

		IF((SELECT COUNT(*) FROM @tblTaxTable WHERE ysnInvalid = 1) > 0)
		BEGIN
			UPDATE tblCFTransaction SET ysnInvalid = 1 WHERE intTransactionId = @Pk
		END
		------------------------------------------------------------


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
		,[dblRate]
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
		------------------------------------------------------------


		------------------------------------------------------------
		--					   TRANSACTION TAX					  --
		------------------------------------------------------------

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

		SET @QxOP = @dblQuantity * @dblPrcOriginalPrice
		SET @QxCP = @dblQuantity * @dblPrcPriceOut
		--SELECT @dblPrcOriginalPrice as 'dblPrcOriginalPrice'
		WHILE (EXISTS(SELECT TOP 1 * FROM @tblTaxUnitTable))
		BEGIN
			SELECT TOP 1 
			 @intLoopTaxGroupID = intTaxGroupId
			,@intLoopTaxCodeID = intTaxCodeId
			,@intLoopTaxClassID = intTaxClassId
			,@QxT = ROUND (@dblQuantity * dblRate,2)
			,@QxOP = ROUND (@QxOP - (@dblQuantity * dblRate),2)
			,@dblOPTotalTax = ROUND (@dblOPTotalTax + (@dblQuantity * dblRate),2)
			,@dblCPTotalTax = ROUND (@dblCPTotalTax +  dblRate,2)
			,@strLoopTaxCode = strTaxCode
			,@Rate = dblRate
			,@CalculationMethod = strCalculationMethod
			,@ysnLoopTaxExempt = ysnCheckoffTax
			,@ysnLoopTaxExempt = ysnTaxExempt
			FROM @tblTaxUnitTable

			INSERT INTO tblCFTransactionTax(
				 [intTransactionId]
				,[dblTaxOriginalAmount]
				,[dblTaxCalculatedAmount]
				,[dblTaxRate]
				,[intTaxCodeId]
			)
			VALUES(
				@Pk
				,(CASE WHEN(@dblPrcOriginalPrice = 0 OR @dblPrcOriginalPrice IS NULL) 
					THEN 0 
					ELSE @QxT END)
				,(CASE 
					WHEN((@dblPrcPriceOut = 0 OR @dblPrcPriceOut IS NULL) OR (@ysnLoopTaxCheckOff = 1 OR @ysnLoopTaxExempt = 1)) 
				  THEN 0 
					ELSE @QxT END)
				,@Rate
				,@intLoopTaxCodeID
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
			,@OPTax = ROUND (((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
			,@CPTax = ROUND (@QxCP * (dblRate/100),2)
			,@dblOPTotalTax = ROUND (@dblOPTotalTax +  ((@QxOP / (dblRate/100 +1 )) * (dblRate/100)),2)
			,@dblCPTotalTax = ROUND (@dblCPTotalTax +  (@dblPrcPriceOut * (dblRate/100)),2)
			,@strLoopTaxCode = strTaxCode
			,@Rate = dblRate
			,@CalculationMethod = strCalculationMethod
			FROM @tblTaxRateTable

			INSERT INTO tblCFTransactionTax(
				 [intTransactionId]
				,[dblTaxOriginalAmount]
				,[dblTaxCalculatedAmount]
				,[dblTaxRate]
				,[intTaxCodeId]
			)
			VALUES(
				 @Pk
				,@OPTax
				,(CASE 
					WHEN(@ysnLoopTaxCheckOff = 1 OR @ysnLoopTaxExempt = 1) 
				  THEN 0 
					ELSE @CPTax END)
				,@Rate
				,@intLoopTaxCodeID
			)

			DELETE FROM @tblTaxRateTable 
			WHERE intTaxGroupId = @intLoopTaxGroupID
			AND intTaxClassId = @intLoopTaxClassID
			AND intTaxCodeId = @intLoopTaxCodeID

		END
		
		------------------------------------------------------------





		------------------------------------------------------------
		--						TRANSACTION PRICE				  --
		------------------------------------------------------------
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
			--@dblPrcPriceOut + @dblCPTotalTax-- +TAX
			,(case
				when @strPriceMethod = 'Import File Price' 
				then @dblPrcOriginalPrice
				else @dblPrcPriceOut + @dblCPTotalTax
			end)
		),
		(
			@Pk
			,'Net Price'
			,Round(@dblPrcOriginalPrice - Round((@dblOPTotalTax/@dblQuantity),6),5)
			,(case
				when @strPriceMethod = 'Import File Price' 
				then Round(@dblPrcOriginalPrice - Round((@dblOPTotalTax/@dblQuantity),6),5)
				else @dblPrcPriceOut
			end)
		),
		(
			@Pk
			,'Total Amount'
			,Round(@dblPrcOriginalPrice * @dblQuantity,2)
			,(case
				when @strPriceMethod = 'Import File Price' 
				then Round(@dblPrcOriginalPrice * @dblQuantity,2)
				else Round((@dblPrcPriceOut + @dblCPTotalTax) * @dblQuantity,2)
			end)
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
		------------------------------------------------------------

	END