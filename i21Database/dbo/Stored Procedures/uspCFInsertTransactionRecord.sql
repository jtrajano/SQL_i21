CREATE PROCEDURE [dbo].[uspCFInsertTransactionRecord]
	
	 @strGUID						NVARCHAR(MAX)
	,@strProcessDate				NVARCHAR(MAX)
	,@strCardId						NVARCHAR(MAX)
	,@strVehicleId					NVARCHAR(MAX)
	,@strProductId					NVARCHAR(MAX)
	,@strNetworkId					NVARCHAR(MAX)	= NULL
	,@intNetworkId					INT				= 0
	,@intTransTime					INT				= 0
	,@intOdometer					INT				= 0
	,@intPumpNumber					INT				= 0
	,@intContractId					INT				= NULL
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
	,@FederalExciseTax1				NUMERIC(18,6)	= 0.000000
	,@FederalExciseTax2				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax1				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax2				NUMERIC(18,6)	= 0.000000
	,@StateExciseTax3				NUMERIC(18,6)	= 0.000000
	,@CountyTax1					NUMERIC(18,6)	= 0.000000
	,@CityTax1						NUMERIC(18,6)	= 0.000000
	,@StateSalesTax					NUMERIC(18,6)	= 0.000000
	,@CountySalesTax				NUMERIC(18,6)	= 0.000000
	,@CitySalesTax					NUMERIC(18,6)	= 0.000000

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
	,@strCreditCard					NVARCHAR(MAX)	= NULL
	--------------------------------------

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
	
	,@ysnOriginHistory					BIT				= 0
	,@ysnPostedCSV						BIT				= 0

	,@intSellingHost					INT				= 0
	,@intBuyingHost						INT				= 0
	,@intForeignCustomerId				INT				= 0

	
	
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
	DECLARE @ysnSiteCreated				BIT = 0
	DECLARE @ysnSiteAcceptCreditCard	BIT = 0
	--LOGS--

	DECLARE @ysnVehicleRequire			BIT = 0
	DECLARE @intOverFilledTransactionId INT = NULL
	DECLARE @intAccountId				INT = 0
	DECLARE @intCardId					INT = 0
	DECLARE @intVehicleId				INT	= 0
	DECLARE @intProductId				INT	= 0
	DECLARE @intARItemId				INT	= NULL
	DECLARE @intARItemLocationId		INT	= 0
	DECLARE @intCustomerLocationId		INT	= 0
	DECLARE @intTaxGroupId				INT = 0
	DECLARE @intTaxMasterId				INT = 0
	DECLARE @strCountry					NVARCHAR(MAX)
	DECLARE @strCounty					NVARCHAR(MAX)
	DECLARE @strCity					NVARCHAR(MAX)
	DECLARE @strState					NVARCHAR(MAX)
	DECLARE @intCustomerId				INT = 0
	DECLARE @ysnInvalid					BIT	= 0
	DECLARE @ysnPosted					BIT = 0
	DECLARE @ysnCreditCardUsed			BIT	= 0
	DECLARE @intParticipantNo			INT = 0
	DECLARE @strNetworkType				NVARCHAR(MAX)
	DECLARE @intNetworkLocation			INT = 0
	DECLARE @intDupTransCount			INT = 0
	DECLARE @ysnDuplicate				BIT = 0
	  
	------------------------------------------------------------

	IF (@ysnPosted != 1 OR @ysnPosted IS NULL)
	BEGIN
	SET @ysnPosted = @ysnOriginHistory
	END
	
	IF (@ysnPosted != 1 OR @ysnPosted IS NULL)
	BEGIN
	SET @ysnPosted = @ysnPostedCSV
	END

	------------------------------------------------------------
	--					SET VARIABLE VALUE					  --
	------------------------------------------------------------
	IF(@intContractId = 0)
	BEGIN
		SET @intContractId = NULL
	END

	IF(@intSalesPersonId = 0)
		BEGIN
			SET @intSalesPersonId = NULL
		END
	IF(@intSiteId = 0)
		BEGIN
			SELECT TOP 1 @intSiteId = intSiteId 
						,@intCustomerLocationId = intARLocationId
						,@intTaxMasterId = intTaxGroupId
						,@ysnSiteAcceptCreditCard = ysnSiteAcceptsMajorCreditCards
						FROM tblCFSite
						WHERE strSiteNumber = @strSiteId

			IF (@intSiteId = 0)
			BEGIN 
				SET @intSiteId = NULL
			END
		END
		ELSE
		BEGIN
			SELECT TOP 1 @intCustomerLocationId = intARLocationId
						,@intTaxMasterId = intTaxGroupId
						,@ysnSiteAcceptCreditCard = ysnSiteAcceptsMajorCreditCards
						FROM tblCFSite
						WHERE intSiteId = @intSiteId
		END

	IF(@intNetworkId = 0)
		BEGIN
			SELECT TOP 1
			 @intNetworkId			= intNetworkId 
			,@intParticipantNo		= strParticipant
			,@strNetworkType		= strNetworkType	
			,@intForeignCustomerId	= intCustomerId
			,@strNetworkType		= strNetworkType
			,@intNetworkLocation	= intLocationId
			FROM tblCFNetwork
			WHERE strNetwork = @strNetworkId
		END
	ELSE
		BEGIN
			SELECT TOP 1
			 @intNetworkId			= intNetworkId 
			,@intParticipantNo		= strParticipant
			,@strNetworkType		= strNetworkType	
			,@intForeignCustomerId	= intCustomerId
			,@strNetworkType		= strNetworkType
			,@intNetworkLocation	= intLocationId
			FROM tblCFNetwork
			WHERE intNetworkId = @intNetworkId
		END

	IF(@strNetworkType = 'PacPride')
	BEGIN
		-----------ORIGINAL GROSS PRICE-------
		IF(@dblOriginalGrossPrice IS NULL OR @dblOriginalGrossPrice = 0)
		BEGIN
		SET @dblOriginalGrossPrice = @dblTransferCost
		END
		
		-----------TRANSACTION TYPE-----------
		IF(@intSellingHost = @intParticipantNo AND @intBuyingHost = @intParticipantNo)
		BEGIN
			SET @strTransactionType = 'Local/Network'
		END
		ELSE IF (@intSellingHost = @intParticipantNo AND @intBuyingHost != @intParticipantNo)
		BEGIN
			SET @strTransactionType = 'Foreign Sale'
			SET @dblOriginalGrossPrice = @dblTransferCost
			--SET @intCustomerId = @intForeignCustomerId
		END
		ELSE IF (@intBuyingHost = @intParticipantNo AND @intSellingHost != @intParticipantNo)
		BEGIN
			SET @strTransactionType = (CASE @strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
		END
		ELSE IF (@intBuyingHost != @intParticipantNo AND @intSellingHost != @intParticipantNo)
		BEGIN
			SET @strTransactionType = (CASE @strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
		END 
	END
	ELSE IF (@strNetworkType = 'Voyager')
	BEGIN 
		SET @strTransactionType = 'Local/Network'
	END
	 

	DECLARE @ysnCreateSite BIT 
	------------------------------------------------------------
	--					AUTO CREATE SITE
	-- if transaction is remote or ext remote				  --
	------------------------------------------------------------
	IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND (@strPPSiteType = 'N' OR @strPPSiteType = 'R') AND @strNetworkType = 'PacPride')
		BEGIN 
			
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
	ELSE IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND @strNetworkType = 'Voyager')
	BEGIN
		DECLARE @intTaxGroupByState INT = NULL

		IF(@intTaxGroupByState IS NULL)
		BEGIN
			SELECT TOP 1 @intTaxGroupByState = intTaxGroupId FROM tblCFNetworkSiteTaxGroup WHERE intNetworkId = @intNetworkId AND strState = @strState
		END
		
		IF(@intTaxGroupByState IS NULL)
		BEGIN
			SELECT TOP 1 @intTaxGroupByState = intTaxGroupId FROM tblCFNetworkSiteTaxGroup WHERE intNetworkId = @intNetworkId AND (strState IS NULL OR strState = '')
		END

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
				,strSiteType
				,intTaxGroupId
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteId
				,strDeliveryPickup		= 'Pickup'
				,intARLocationId		= @intNetworkLocation
				,strControllerType		= 'Voyager'
				,strTaxState			= @strSiteState
				,strSiteAddress			= @strSiteAddress	
				,strSiteCity			= @strSiteCity	
				,strSiteType			= 'Extended Remote'
				,intTaxGroupId			= @intTaxGroupByState
				

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;
	END
	
	--FIND CARD--
	
	DECLARE @ysnLocalCard BIT
	DECLARE @ysnMatched INT = 0
	IF(@ysnSiteAcceptCreditCard = 1)
	BEGIN
		IF(@strCreditCard IS NOT NULL AND @strCreditCard != '' AND (@intSiteId IS NOT NULL OR @intSiteId > 0))
		BEGIN
			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--SEARCH FOR FULL MATCH-- 1234
				SET @strCreditCard = @strCreditCard
				SELECT TOP 1 
					@intCardId = intCardId
				   ,@ysnMatched = intCreditCardId
				   ,@ysnLocalCard= ysnLocalPrefix
				FROM tblCFCreditCard 
				WHERE strPrefix = @strCreditCard AND intSiteId = @intSiteId
			END

			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--SEARCH FOR 1 PARTIAL WILDCARD MATCH-- ex 123*
				SET @strCreditCard = STUFF(@strCreditCard, 4, 1, '*')
				SELECT TOP 1 
					@intCardId = intCardId
				   ,@ysnMatched = intCreditCardId
				   ,@ysnLocalCard= ysnLocalPrefix
				FROM tblCFCreditCard 
				WHERE strPrefix = @strCreditCard AND intSiteId = @intSiteId
			END
			
			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--SEARCH FOR 2 PARTIAL WILDCARD MATCH-- ex 12**
				SET @strCreditCard = STUFF(@strCreditCard, 3, 1, '*')
				SELECT TOP 1 
					@intCardId = intCardId
				   ,@ysnMatched = intCreditCardId
				   ,@ysnLocalCard= ysnLocalPrefix
				FROM tblCFCreditCard 
				WHERE strPrefix = @strCreditCard AND intSiteId = @intSiteId
			END

			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--SEARCH FOR 3 PARTIAL WILDCARD MATCH-- ex 1***
				SET @strCreditCard = STUFF(@strCreditCard, 2, 1, '*')
				SELECT TOP 1 
					@intCardId = intCardId
				   ,@ysnMatched = intCreditCardId
				   ,@ysnLocalCard= ysnLocalPrefix
				FROM tblCFCreditCard 
				WHERE strPrefix = @strCreditCard AND intSiteId = @intSiteId
			END

			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--SEARCH FOR FULL WILDCARD MATCH-- ex ****
				SET @strCreditCard = STUFF(@strCreditCard, 1, 1, '*')
				SELECT TOP 1 
					@intCardId = intCardId
				   ,@ysnMatched = intCreditCardId
				   ,@ysnLocalCard= ysnLocalPrefix
				FROM tblCFCreditCard 
				WHERE strPrefix = @strCreditCard AND intSiteId = @intSiteId
			END

			IF((@intCardId = 0 OR @intCardId IS NULL) AND @ysnMatched = 0)
			BEGIN
				--CARD MATCHING--
				SELECT TOP 1 
					 @intCardId = C.intCardId
					,@intCustomerId = A.intCustomerId
				FROM tblCFCard C
				INNER JOIN tblCFAccount A
				ON C.intAccountId = A.intAccountId
				WHERE C.strCardNumber = @strCardId
			END
			ELSE
			BEGIN
				IF(@ysnLocalCard = 1)
				BEGIN
					--CARD MATCHING--
					SELECT TOP 1 
						 @intCardId = C.intCardId
						,@intCustomerId = A.intCustomerId
					FROM tblCFCard C
					INNER JOIN tblCFAccount A
					ON C.intAccountId = A.intAccountId
					WHERE C.strCardNumber = @strCardId
				END
				ELSE
				BEGIN
					SELECT TOP 1 
						@intCustomerId = A.intCustomerId
					FROM tblCFCard C
					INNER JOIN tblCFAccount A
					ON C.intAccountId = A.intAccountId
					WHERE C.intCardId = @intCardId

					SET @ysnCreditCardUsed = 1

				END
			END
		END
		ELSE
		BEGIN
			BEGIN
				SELECT TOP 1 
					 @intCardId = C.intCardId
					,@intCustomerId = A.intCustomerId
				FROM tblCFCard C
				INNER JOIN tblCFAccount A
				ON C.intAccountId = A.intAccountId
				WHERE C.strCardNumber = @strCardId
			END
		END
	END
	ELSE
	BEGIN
		BEGIN
			SELECT TOP 1 
				 @intCardId = C.intCardId
				,@intCustomerId = A.intCustomerId
			FROM tblCFCard C
			INNER JOIN tblCFAccount A
			ON C.intAccountId = A.intAccountId
			WHERE C.strCardNumber = @strCardId
		END
	END

	IF (@intCardId = 0)
	BEGIN
		SET @intCardId = NULL
	END
	ELSE
	BEGIN
		SELECT TOP 1
			 @intAccountId = a.intAccountId
			,@ysnVehicleRequire = a.ysnVehicleRequire
		FROM tblCFCard as c
		INNER JOIN tblCFAccount as a
		ON c.intAccountId = a.intAccountId
		WHERE intCardId = @intCardId
	END

	IF(@intProductId = 0)
	BEGIN
		SELECT TOP 1 
			 @intProductId = intItemId
			,@intARItemId = intARItemId
		FROM tblCFItem 
		WHERE strProductNumber = @strProductId
		AND intNetworkId = @intNetworkId
		AND intSiteId = @intSiteId
	END

	IF(@intProductId = 0)
	BEGIN
		SELECT TOP 1 
			 @intProductId = intItemId
			,@intARItemId = intARItemId
		FROM tblCFItem 
		WHERE strProductNumber = @strProductId
		AND intNetworkId = @intNetworkId
		AND (intSiteId = 0 OR intSiteId IS NULL)
	END


	SET @intARItemLocationId = (SELECT TOP 1 intARLocationId
								FROM tblCFSite 
								WHERE intSiteId = @intSiteId)
	
	IF(@intAccountId IS NOT NULL AND @intAccountId != 0 AND @strVehicleId != 0)
	BEGIN
		SET @intVehicleId =
						(SELECT TOP 1 intVehicleId
						FROM tblCFVehicle
						WHERE strVehicleNumber	= @strVehicleId AND intAccountId = @intAccountId)
	END
	ELSE
	BEGIN
		SET @intVehicleId = NULL
	END
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
		DECLARE @intPriceProfileId			INT
		DECLARE @intPriceIndexId			INT
		DECLARE @intSiteGroupId				INT
		DECLARE @strPriceProfileId			NVARCHAR(MAX)
		DECLARE @strPriceIndexId			NVARCHAR(MAX)
		DECLARE @strSiteGroup				NVARCHAR(MAX)
		DECLARE @dblPriceProfileRate		NUMERIC(18,6)
		DECLARE @dblPriceIndexRate			NUMERIC(18,6)
		DECLARE @dtmPriceIndexDate			DATETIME
		DECLARE @dblMargin					NUMERIC(18,6)
	------------------------------------------------------------



		------------------------------------------------------------
		--						 VALIDATION						  --
		------------------------------------------------------------
		SET @intPrcCustomerId =(SELECT TOP 1 A.intCustomerId	
						FROM tblCFCard C
						INNER JOIN tblCFAccount A
						ON C.intAccountId = A.intAccountId
						WHERE C.intCardId= @intCardId)

		SET @intPrcItemUOMId = (SELECT TOP 1 intIssueUOMId
								FROM tblICItemLocation
								WHERE intLocationId = @intARItemLocationId 
								AND intItemId = @intARItemId)

	
		
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
			SET @ysnInvalid = 1
		END
		IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END
		IF(@intVehicleId = 0 OR @intVehicleId IS NULL)
		BEGIN
			SET @intVehicleId = NULL
			SET @ysnInvalid = 1
		END

		

		---- DUPLICATE CHECK -- 
		--SELECT @intDupTransCount = COUNT(*)
		--FROM tblCFTransaction
		--WHERE intNetworkId = @intNetworkId
		--AND intSiteId = @intSiteId
		--AND dtmTransactionDate = @dtmTransactionDate
		--AND intCardId = @intCardId
		--AND intProductId = @intProductId
		--AND intPumpNumber = @intPumpNumber

		--IF(@intDupTransCount > 0)
		--BEGIN
		--	SET @ysnInvalid = 1
		--	SET @ysnDuplicate = 1
		--END		

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
			,[ysnCreditCardUsed]			
			,[ysnOriginHistory]
			,[ysnPostedCSV]
			,[strForeignCardId]
			,[ysnDuplicate]
			,[strOriginalProductNumber]
			,[intOverFilledTransactionId]
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
			,@ysnCreditCardUsed		
			,@ysnOriginHistory
			,@ysnPostedCSV  
			,@strCardId
			,@ysnDuplicate
			,@strProductId
			,@intOverFilledTransactionId
		)			
	
		DECLARE @Pk	INT		
		DECLARE @test varchar(10)
		SELECT @Pk  = SCOPE_IDENTITY();


		------------------------------------------------------------
		--				INSERT IMPORT ERROR LOGS				  --
		------------------------------------------------------------
		IF(@intARItemId = 0 OR @intARItemId IS NULL)
		BEGIN
			--INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			--VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find product number ' + @strProductId + ' into i21 item list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find product number ' + @strProductId + ' into i21 item list')
		END
		IF((@intPrcCustomerId = 0 OR @intPrcCustomerId IS NULL) AND @strTransactionType != 'Foreign Sale')
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find customer number using card number ' + @strCardId + ' into i21 card account list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find customer number using card number ' + @strCardId + ' into i21 card account list')
		END
		IF(@intARItemLocationId = 0 OR @intARItemLocationId IS NULL)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid location for site ' + @strSiteId)
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid location for site ' + @strSiteId)
		END
		IF(@intPrcItemUOMId = 0 OR @intPrcItemUOMId IS NULL)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid UOM for product number ' + @strProductId)
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid UOM for product number ' + @strProductId)
		END
		IF(@intNetworkId = 0 OR @intNetworkId IS NULL)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find network ' + @strNetworkId + ' into i21 network list')
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find network ' + @strNetworkId + ' into i21 network list')
		END
		IF(@intSiteId = 0 OR @intSiteId IS NULL)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find site ' + @strSiteId + ' into i21 site list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find site ' + @strSiteId + ' into i21 site list')
		END
		IF(@ysnSiteCreated != 0)
		BEGIN
			--INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			--VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Site ' + @strSiteId + ' has been automatically created')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Site ' + @strSiteId + ' has been automatically created')
		END
		IF((@intCardId = 0 OR @intCardId IS NULL) AND @strTransactionType != 'Foreign Sale')
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find card number ' + @strCardId + ' into i21 card list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find card number ' + @strCardId + ' into i21 card list')
		END
		IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid quantity - ' + Str(@dblQuantity, 16, 8))

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid quantity - ' + Str(@dblQuantity, 16, 8))

			INSERT INTO tblCFTransactionPrice
			(
				 intTransactionId
				,strTransactionPriceId
				,dblOriginalAmount
				,dblCalculatedAmount
			)
			VALUES 
			 (@Pk,'Gross Price',@dblOriginalGrossPrice,0.0)
			,(@Pk,'Net Price',0.0,0.0)
			,(@Pk,'Total Amount',0.0,0.0)

			RETURN;
		END
		IF((@intVehicleId = 0 OR @intVehicleId IS NULL) AND @strTransactionType != 'Foreign Sale')
		BEGIN
			IF(@ysnVehicleRequire = 1)
			BEGIN
				INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
				VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')

				INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')
			END
		END

		
		

		------------------------------------------------------------

		EXEC dbo.uspCFRecalculateTransaciton 
		 @ProductId						=	@intProductId
		,@CardId						=	@intCardId
		,@VehicleId						=	@intVehicleId
		,@SiteId						=	@intSiteId
		,@TransactionDate				=	@dtmTransactionDate
		,@Quantity						=	@dblQuantity
		,@OriginalPrice					=	@dblOriginalGrossPrice
		,@TransactionType				=	@strTransactionType
		,@NetworkId						=	@intNetworkId
		,@TransferCost					=	@dblTransferCost
		,@TransactionId					=	@Pk
		,@CreditCardUsed				=	@ysnCreditCardUsed
		,@PostedOrigin					=	@ysnOriginHistory  
		,@PostedCSV						=	@ysnPostedCSV  
		,@PumpId						=	@intPumpNumber
		,@IsImporting					=	1
		,@TaxState						=	@TaxState						
		,@FederalExciseTaxRate        	=	@FederalExciseTaxRate        
		,@StateExciseTaxRate1         	=	@StateExciseTaxRate1         
		,@StateExciseTaxRate2         	=	@StateExciseTaxRate2         
		,@CountyExciseTaxRate         	=	@CountyExciseTaxRate         
		,@CityExciseTaxRate           	=	@CityExciseTaxRate           
		,@StateSalesTaxPercentageRate 	=	@StateSalesTaxPercentageRate 
		,@CountySalesTaxPercentageRate	=	@CountySalesTaxPercentageRate
		,@CitySalesTaxPercentageRate  	=	@CitySalesTaxPercentageRate  
		,@OtherSalesTaxPercentageRate	=	@OtherSalesTaxPercentageRate 
		,@FederalExciseTax1				=   @FederalExciseTax1	
		,@FederalExciseTax2				=   @FederalExciseTax2	
		,@StateExciseTax1				=   @StateExciseTax1	
		,@StateExciseTax2				=   @StateExciseTax2	
		,@StateExciseTax3				=   @StateExciseTax3	
		,@CountyTax1					=   @CountyTax1		
		,@CityTax1						=   @CityTax1			
		,@StateSalesTax					=   @StateSalesTax		
		,@CountySalesTax				=   @CountySalesTax	
		,@CitySalesTax					=   @CitySalesTax		
		,@strGUID						=   @strGUID		
		,@strProcessDate				=	@strProcessDate

		------------------------------------------------------------
		--			UPDATE TRANSACTION DEPENDS ON PRICING		  --
		------------------------------------------------------------
		SELECT
		 @dblPrcPriceOut				= dblPrice
		,@strPrcPricingOut				= strPriceMethod
		,@intPrcAvailableQuantity		= dblAvailableQuantity
		,@dblPrcOriginalPrice			= dblOriginalPrice
		,@intPrcContractHeaderId		= intContractHeaderId
		,@intPrcContractDetailId		= intContractDetailId
		,@intPrcContractNumber			= intContractNumber
		,@intPrcContractSeq				= intContractSeq
		,@strPrcPriceBasis				= strPriceBasis
		,@strPriceMethod   				= strPriceMethod
		,@strPriceBasis 				= strPriceBasis
		,@intContractId	 				= intContractDetailId
		,@dblCalcOverfillQuantity 		= 0
		,@dblCalcQuantity 				= 0
		,@intPriceProfileId 			= intPriceProfileId 	
		,@intPriceIndexId				= intPriceIndexId	
		,@intSiteGroupId				= intSiteGroupId		
		,@strPriceProfileId				= strPriceProfileId	
		,@strPriceIndexId				= strPriceIndexId	
		,@strSiteGroup					= strSiteGroup		
		,@dblPriceProfileRate			= dblPriceProfileRate
		,@dblPriceIndexRate				= dblPriceIndexRate	
		,@dtmPriceIndexDate				= dtmPriceIndexDate	
		,@ysnDuplicate					= ysnDuplicate
		FROM ##tblCFTransactionPricingType

		--IF(@ysnDuplicate = 1)
		--BEGIN
		--	SET @ysnInvalid = 1
		--	INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		--	VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Duplicate transaction history found.')
		--END

		IF (@strPriceMethod = 'Inventory - Standard Pricing')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblTransferCost = 0
				,strPriceMethod = 'Standard Pricing'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
		END
		IF (@strPriceMethod = 'Import File Price')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblTransferCost = 0
				,strPriceMethod = 'Import File Price'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
		END
		IF (@strPriceMethod = 'Network Cost')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblTransferCost = @dblTransferCost
				,strPriceMethod = @strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
		END
		ELSE IF (@strPriceMethod = 'Special Pricing')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblTransferCost = 0
				,strPriceMethod = 'Special Pricing'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
		END
		ELSE IF (@strPriceMethod = 'Price Profile')
		BEGIN
				IF(@strPrcPriceBasis = 'Transfer Cost' OR @strPrcPriceBasis = 'Transfer Price' OR @strPrcPriceBasis = 'Discounted Price' OR @strPrcPriceBasis = 'Full Retail')
				BEGIN
					SET @dblTransferCost = @dblTransferCost
				END
				ELSE
				BEGIN
					SET @dblTransferCost = 0
				END

				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis			= @strPrcPriceBasis
				,dblTransferCost		= @dblTransferCost
				,strPriceMethod			= 'Price Profile'
				,intPriceProfileId 		= @intPriceProfileId 	
				,intPriceIndexId		= @intPriceIndexId	
				,intSiteGroupId			= @intSiteGroupId		
				,strPriceProfileId		= @strPriceProfileId	
				,strPriceIndexId		= @strPriceIndexId	
				,strSiteGroup			= @strSiteGroup		
				,dblPriceProfileRate	= @dblPriceProfileRate
				,dblPriceIndexRate		= @dblPriceIndexRate	
				,dtmPriceIndexDate		= @dtmPriceIndexDate	
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
					
		END
		ELSE IF (@strPriceMethod = 'Contracts' OR @strPriceMethod = 'Contract Pricing')
		BEGIN

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

					
				UPDATE tblCFTransaction 
				SET strPriceBasis = null 
				,dblTransferCost = 0 
				,strPriceMethod = 'Contract Pricing'
				,intContractId = @intPrcContractHeaderId
				,intContractDetailId = @intPrcContractDetailId
				,dblQuantity = @dblQuantity
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk

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

		END
		ELSE
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblTransferCost = 0
				,strPriceMethod = @strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= null
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= ''
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				WHERE intTransactionId = @Pk
		END


		------------------------------------------------------------
		--						TRANSACTION TAX					  --
		------------------------------------------------------------
		INSERT INTO tblCFTransactionTax
		(
			 intTransactionId
			,dblTaxOriginalAmount
			,dblTaxCalculatedAmount
			,intTaxCodeId
			,dblTaxRate
		)
		SELECT 
			 @Pk
			,dblTaxOriginalAmount
			,dblTaxCalculatedAmount		
			,intTaxCodeId	
			,dblTaxRate	
		FROM ##tblCFTransactionTaxType
	

		------------------------------------------------------------
		--						TRANSACTION PRICE				  --
		------------------------------------------------------------
		INSERT INTO tblCFTransactionPrice
		(
			 intTransactionId
			,strTransactionPriceId
			,dblOriginalAmount
			,dblCalculatedAmount
		)
		SELECT 
			@Pk
			,strTransactionPriceId
			,dblTaxOriginalAmount
			,dblTaxCalculatedAmount
		FROM ##tblCFTransactionPriceType
		

		print @dblCalcOverfillQuantity
		IF(@dblCalcOverfillQuantity > 0)
		BEGIN

			IF(@intOverFilledTransactionId IS NULL)
			BEGIN
				SET @intOverFilledTransactionId = @Pk
			END
			
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
END