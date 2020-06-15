CREATE PROCEDURE [dbo].[uspCFInsertTransactionRecord]
	
	 @strGUID						NVARCHAR(MAX)
	,@strProcessDate				NVARCHAR(MAX)
	,@strPostedDate					NVARCHAR(MAX)
	,@strCreatedDate				NVARCHAR(MAX)
	,@strLaggingDate				NVARCHAR(MAX)
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
	,@Tax1							NVARCHAR(MAX)	= NULL
	,@Tax2							NVARCHAR(MAX)	= NULL
	,@Tax3							NVARCHAR(MAX)	= NULL
	,@Tax4							NVARCHAR(MAX)	= NULL
	,@Tax5							NVARCHAR(MAX)	= NULL
	,@Tax6							NVARCHAR(MAX)	= NULL
	,@Tax7							NVARCHAR(MAX)	= NULL
	,@Tax8							NVARCHAR(MAX)	= NULL
	,@Tax9							NVARCHAR(MAX)	= NULL
	,@Tax10							NVARCHAR(MAX)	= NULL
	,@TaxValue1						NUMERIC(18,6)	= 0.000000
	,@TaxValue2						NUMERIC(18,6)	= 0.000000
	,@TaxValue3						NUMERIC(18,6)	= 0.000000
	,@TaxValue4						NUMERIC(18,6)	= 0.000000
	,@TaxValue5						NUMERIC(18,6)	= 0.000000
	,@TaxValue6						NUMERIC(18,6)	= 0.000000
	,@TaxValue7						NUMERIC(18,6)	= 0.000000
	,@TaxValue8						NUMERIC(18,6)	= 0.000000
	,@TaxValue9						NUMERIC(18,6)	= 0.000000
	,@TaxValue10					NUMERIC(18,6)	= 0.000000

	-------------SITE RELATED-------------
	,@strSiteId						NVARCHAR(MAX)
	,@strSiteName					NVARCHAR(MAX)	= NULL
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

	,@FederalExciseTaxRateReference        	  NVARCHAR(MAX)	= NULL
	,@StateExciseTaxRate1Reference         	  NVARCHAR(MAX)	= NULL
	,@StateExciseTaxRate2Reference         	  NVARCHAR(MAX)	= NULL
	,@CountyExciseTaxRateReference         	  NVARCHAR(MAX)	= NULL
	,@CityExciseTaxRateReference           	  NVARCHAR(MAX)	= NULL
	,@StateSalesTaxPercentageRateReference 	  NVARCHAR(MAX)	= NULL
	,@CountySalesTaxPercentageRateReference	  NVARCHAR(MAX)	= NULL
	,@CitySalesTaxPercentageRateReference  	  NVARCHAR(MAX)	= NULL
	,@OtherSalesTaxPercentageRateReference 	  NVARCHAR(MAX)	= NULL
	
	,@ysnOriginHistory					BIT				= 0
	,@ysnPostedCSV						BIT				= 0

	,@intSellingHost					INT				= 0
	,@intBuyingHost						INT				= 0
	,@intForeignCustomerId				INT				= 0


	,@strInvoiceReportNumber			NVARCHAR(MAX)	= NULL
	,@dtmInvoiceDate					DATETIME		= NULL		
	
	,@strSiteTaxLocation				NVARCHAR(MAX)	= NULL
	,@CardNumberForDualCard				NVARCHAR(MAX)	= NULL
	,@strDriverPin						NVARCHAR(MAX)	= NULL


	
	
	
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
	DECLARE @strParticipantNo			NVARCHAR(MAX)
	DECLARE @strNetworkType				NVARCHAR(MAX)
	DECLARE @intNetworkLocation			INT = 0
	DECLARE @intDupTransCount			INT = 0
	DECLARE @ysnDuplicate				BIT = 0

	DECLARE @ysnOnHold					BIT = 0

	DECLARE @intCardTypeId				INT				= 0
	DECLARE @ysnDualCard				BIT				= 0
	DECLARE @ysnConvertMiscToVehicle	BIT				= 0
	DECLARE @ysnInvoiced				BIT				= 0

	--DECLARE @strSiteType				NVARCHAR(MAX)

	
	--DECLARE @strTransactionType AS nvarchar(max)

	IF(LOWER(@strTransactionType) LIKE '%foreign%')
	BEGIN
		SET @strTransactionType = 'Foreign Sale'
	END
	  
	------------------------------------------------------------

	IF (@ysnPosted != 1 OR @ysnPosted IS NULL)
	BEGIN
	SET @ysnPosted = @ysnOriginHistory
	END
	
	IF (@ysnPosted != 1 OR @ysnPosted IS NULL)
	BEGIN
	SET @ysnPosted = @ysnPostedCSV
	END

	IF(ISNULL(@ysnPosted,0) = 1)
	BEGIN
		SET @ysnInvoiced = 1
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

	

	IF(@intNetworkId = 0)
		BEGIN
			SELECT TOP 1
			 @intNetworkId			= intNetworkId 
			,@strParticipantNo		= strParticipant
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
			,@strParticipantNo		= strParticipant
			,@strNetworkType		= strNetworkType	
			,@intForeignCustomerId	= intCustomerId
			,@strNetworkType		= strNetworkType
			,@intNetworkLocation	= intLocationId
			FROM tblCFNetwork
			WHERE intNetworkId = @intNetworkId
		END

	IF(@intSiteId = 0)
		BEGIN
			SELECT TOP 1 @intSiteId = intSiteId 
						,@intCustomerLocationId = intARLocationId
						,@intTaxMasterId = intTaxGroupId
						,@ysnSiteAcceptCreditCard = ysnSiteAcceptsMajorCreditCards
						,@strSiteType = strSiteType
						FROM tblCFSite
						WHERE strSiteNumber = @strSiteId
						AND intNetworkId = @intNetworkId

			IF (@intSiteId = 0)
			BEGIN 
				SET @intSiteId = NULL
			END
		END
		ELSE
		BEGIN
			DECLARE @tempSiteId AS INT = 0
			SELECT TOP 1 @tempSiteId = intSiteId 
						,@intCustomerLocationId = intARLocationId
						,@intTaxMasterId = intTaxGroupId
						,@ysnSiteAcceptCreditCard = ysnSiteAcceptsMajorCreditCards
						,@strSiteType = strSiteType
						FROM tblCFSite
						WHERE intSiteId = @intSiteId
						AND intNetworkId = @intNetworkId

			IF (ISNULL(@tempSiteId,0) = 0)
			BEGIN 
				SET @intSiteId = NULL
			END
		END

	

	IF(@strNetworkType = 'PacPride' AND ISNULL(@ysnPosted,0) = 0)
	BEGIN

		DECLARE @intMatchSellingHost INT = 0
		DECLARE @intMatchBuyingHost  INT = 0


		SET @strParticipantNo = REPLACE(@strParticipantNo,' ', '')
		SET @strParticipantNo = RTRIM(LTRIM(@strParticipantNo))


		select @intMatchSellingHost = Count(*) from fnCFSplitString(@strParticipantNo,',') where Record = @intSellingHost
		select @intMatchBuyingHost = Count(*) from fnCFSplitString(@strParticipantNo,',') where Record = @intBuyingHost
		


		-----------TRANSACTION TYPE-----------
		--IF(@intSellingHost = @strParticipantNo AND @intBuyingHost = @strParticipantNo)
		IF(@intMatchSellingHost > 0 AND @intMatchBuyingHost > 0)
		BEGIN
			SET @strTransactionType = 'Local/Network'
		END
		--ELSE IF (@intSellingHost = @strParticipantNo AND @intBuyingHost != @strParticipantNo)
		ELSE IF (@intMatchSellingHost > 0 AND @intMatchBuyingHost = 0)
		BEGIN
			SET @strTransactionType = 'Foreign Sale'
			SET @dblOriginalGrossPrice = @dblTransferCost
			SET @intCustomerId = @intForeignCustomerId
		END
		--ELSE IF (@intBuyingHost = @strParticipantNo AND @intSellingHost != @strParticipantNo)
		ELSE IF (@intMatchBuyingHost > 0 AND @intMatchSellingHost = 0)
		BEGIN
			SET @strTransactionType = (CASE @strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
		END
		--ELSE IF (@intBuyingHost != @strParticipantNo AND @intSellingHost != @strParticipantNo)
		ELSE IF (@intMatchBuyingHost = 0 AND @intMatchSellingHost = 0)
		BEGIN
			SET @strTransactionType = (CASE @strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
		END 
		-----------TRANSACTION TYPE-----------


		-----------ORIGINAL GROSS PRICE-------
		IF(@dblOriginalGrossPrice IS NULL OR @dblOriginalGrossPrice = 0)-- AND @strTransactionType = 'Local/Network'
		BEGIN
			SET @dblOriginalGrossPrice = @dblTransferCost
			--SET @dblTransferCost = 0
		END
		--ELSE IF @strTransactionType != 'Local/Network'
		--BEGIN
		--	SET @dblOriginalGrossPrice = @dblTransferCost
		--END
		-----------ORIGINAL GROSS PRICE-------


		--TAX PERCENTAGE CONVERSION--
		SET @StateSalesTaxPercentageRate   = @StateSalesTaxPercentageRate  * 100
		SET @CountySalesTaxPercentageRate  = @CountySalesTaxPercentageRate * 100
		SET @CitySalesTaxPercentageRate    = @CitySalesTaxPercentageRate   * 100
		SET @OtherSalesTaxPercentageRate   = @OtherSalesTaxPercentageRate  * 100
		--TAX PERCENTAGE CONVERSION--


	END
	ELSE IF (@strNetworkType = 'Voyager')
	BEGIN 
		IF(ISNULL(@intSiteId,0) = 0)
		BEGIN
			SET @strTransactionType = 'Extended Remote'
		END
		ELSE
		BEGIN
			SET @strTransactionType = @strSiteType
		END
	END
	ELSE IF (@strNetworkType = 'Wright Express')
	BEGIN 
		IF(ISNULL(@intSiteId,0) = 0)
		BEGIN
			SET @strTransactionType = 'Extended Remote'
		END
		ELSE
		BEGIN
			SET @strTransactionType = @strSiteType
		END

			--===========ZERO QTY============---
		IF(ISNULL(@dblQuantity,0) = 0 AND ISNULL(@dblOriginalTotalPrice,0) > 0)
		BEGIN
			SET @dblQuantity = 1
			SET @dblOriginalGrossPrice = ISNULL(@dblOriginalTotalPrice,0)
		END

		IF(ISNULL(@dblQuantity,0) = 0 AND ISNULL(@dblOriginalTotalPrice,0) < 0)
		BEGIN
			SET @dblQuantity = -1
			SET @dblOriginalGrossPrice = ISNULL(@dblOriginalTotalPrice,0) * 1
		END

		--===========ZERO QTY============---

	END
	ELSE IF (@strNetworkType = 'CFN')
	BEGIN
		IF(@strTransactionType = 'R')
		BEGIN
			SET @strTransactionType = 'Remote'
		END
		ELSE IF (@strTransactionType = 'D' OR @strTransactionType = 'C' OR @strTransactionType = 'N')
		BEGIN
			SET @strTransactionType = 'Local/Network'
		END
		ELSE IF (@strTransactionType = 'F')
		BEGIN
			SET @strTransactionType = 'Foreign Sale'
			SET @intCustomerId = @intForeignCustomerId
		END
		ELSE IF (@strTransactionType = 'E')
		BEGIN
			SET @strTransactionType = 'Extended Remote'
		END

		DECLARE @tblTaxTempTable TABLE
		(
			 strTaxCode		NVARCHAR(MAX)
			,dblTaxValue	NUMERIC(18,6)
		)

		INSERT INTO @tblTaxTempTable 
			(strTaxCode,dblTaxValue) 
		VALUES 
			 (@Tax1, @TaxValue1)
			,(@Tax2, @TaxValue2)
			,(@Tax3, @TaxValue3)
			,(@Tax4, @TaxValue4)
			,(@Tax5, @TaxValue5)
			,(@Tax6, @TaxValue6)
			,(@Tax7, @TaxValue7)
			,(@Tax8, @TaxValue8)
			,(@Tax9, @TaxValue9)
			,(@Tax10, @TaxValue10)
			
		SET @TaxValue1	   = 0
		SET @TaxValue2	   = 0
		SET @TaxValue3	   = 0
		SET @TaxValue4	   = 0
		SET @TaxValue5	   = 0
		SET @TaxValue6	   = 0
		SET @TaxValue7	   = 0
		SET @TaxValue8	   = 0
		SET @TaxValue9	   = 0
		SET @TaxValue10	   = 0

		--SELECT '@tblTaxTempTable',* FROM @tblTaxTempTable--HERE

		--TAXES--
		IF(ISNULL(@dblQuantity,0) != 0)
		BEGIN

			--GET RAW VALUE FROM CSV--
			--TO BE CONVERT/COMPUTE IN RECALC SP--
			SELECT TOP 1 @TaxValue1 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax1 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue1 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax1 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax1
			IF(ISNULL(@TaxValue1,0) = 0) BEGIN SET @Tax1 = NULL END

			SELECT TOP 1 @TaxValue2 = (SUM(ISNULL(dblTaxValue,0)) ) FROM @tblTaxTempTable WHERE strTaxCode = @Tax2 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue2 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax2 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax2
			IF(ISNULL(@TaxValue2,0) = 0) BEGIN SET @Tax2 = NULL END

			SELECT TOP 1 @TaxValue3 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax3 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue3 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax3 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax3
			IF(ISNULL(@TaxValue3,0) = 0) BEGIN SET @Tax3 = NULL END
			 
			SELECT TOP 1 @TaxValue4 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax4 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue4 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax4 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax4
			IF(ISNULL(@TaxValue4,0) = 0) BEGIN SET @Tax4 = NULL END
			 
			SELECT TOP 1 @TaxValue5 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax5 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue5 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax5 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax5
			IF(ISNULL(@TaxValue5,0) = 0) BEGIN SET @Tax5 = NULL END
			 
			SELECT TOP 1 @TaxValue6 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax6 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue6 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax6 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax6
			IF(ISNULL(@TaxValue6,0) = 0) BEGIN SET @Tax6 = NULL END
			 
			SELECT TOP 1 @TaxValue7 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax7 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue7 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax7 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax7
			IF(ISNULL(@TaxValue7,0) = 0) BEGIN SET @Tax7 = NULL END
			 
			SELECT TOP 1 @TaxValue8 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax8 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue8 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax8 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax8
			IF(ISNULL(@TaxValue8,0) = 0) BEGIN SET @Tax8 = NULL END
			 
			SELECT TOP 1 @TaxValue9 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax9 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue9 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax9 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax9
			IF(ISNULL(@TaxValue9,0) = 0) BEGIN SET @Tax9 = NULL END
			 
			SELECT TOP 1 @TaxValue10 = (SUM(ISNULL(dblTaxValue,0))) FROM @tblTaxTempTable WHERE strTaxCode = @Tax10 GROUP BY strTaxCode
			--SELECT TOP 1 @TaxValue10 = (SUM(ISNULL(dblTaxValue,0)) / ISNULL(@dblQuantity,0)) FROM @tblTaxTempTable WHERE strTaxCode = @Tax10 GROUP BY strTaxCode
			DELETE FROM @tblTaxTempTable WHERE strTaxCode = @Tax10
			IF(ISNULL(@TaxValue10,0) = 0) BEGIN SET @Tax10 = NULL END
		
		END					


	END


	--TAX REFERENCE--
	IF(@strNetworkType = 'PacPride')
	BEGIN
		IF(@strTransactionType = 'Remote' OR @strTransactionType = 'Extended Remote')
		BEGIN

			IF(ISNULL(@FederalExciseTaxRateReference,'') = '' OR @FederalExciseTaxRateReference = 'R')
			BEGIN
				SET @FederalExciseTaxRate = 0.000000
			END

			IF(ISNULL(@StateExciseTaxRate1Reference,'') = '' OR @StateExciseTaxRate1Reference = 'R')
			BEGIN
				SET @StateExciseTaxRate1 = 0.000000
			END

			IF(ISNULL(@StateExciseTaxRate2Reference,'') = '' OR @StateExciseTaxRate2Reference = 'R')
			BEGIN
				SET @StateExciseTaxRate2 = 0.000000
			END

			IF(ISNULL(@CountyExciseTaxRateReference,'') = '' OR @CountyExciseTaxRateReference = 'R')
			BEGIN
				SET @CountyExciseTaxRate = 0.000000
			END
			
			IF(ISNULL(@CityExciseTaxRateReference,'') = '' OR @CityExciseTaxRateReference = 'R')
			BEGIN
				SET @CityExciseTaxRate = 0.000000
			END
			
			IF(ISNULL(@StateSalesTaxPercentageRateReference,'') = '' OR @StateSalesTaxPercentageRateReference = 'R')
			BEGIN
				SET @StateSalesTaxPercentageRate = 0.000000
			END

			IF(ISNULL(@CountySalesTaxPercentageRateReference,'') = '' OR @CountySalesTaxPercentageRateReference = 'R')
			BEGIN
				SET @CountySalesTaxPercentageRate = 0.000000
			END

			IF(ISNULL(@CitySalesTaxPercentageRateReference,'') = '' OR @CitySalesTaxPercentageRateReference = 'R')
			BEGIN
				SET @CitySalesTaxPercentageRate = 0.000000
			END

			IF(ISNULL(@OtherSalesTaxPercentageRateReference,'') = '' OR @OtherSalesTaxPercentageRateReference = 'R')
			BEGIN
				SET @OtherSalesTaxPercentageRate = 0.000000
			END
			

		END
	END

	
	--TAX REFERENCE--


	IF(@dblOriginalGrossPrice < 0)
	BEGIN
		SET @dblOriginalGrossPrice = ABS(@dblOriginalGrossPrice)
		IF(ISNULL(@dblQuantity,0) > 0)
		BEGIN
			SET @dblQuantity = (@dblQuantity * -1)
		END
	END

	DECLARE @ysnCreateSite BIT 
	DECLARE @strAllowExemptionsOnExtAndRetailTrans NVARCHAR(MAX)


	---------------------------------------------------------
	----				    DEFAULT			   			 ----
	---------------------------------------------------------

	SELECT TOP 1 
	@strAllowExemptionsOnExtAndRetailTrans = strAllowExemptionsOnExtAndRetailTrans
	FROM tblCFNetwork
	WHERE intNetworkId = @intNetworkId

	
	---------------------------------------------------------


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
				,strAllowExemptionsOnExtAndRetailTrans
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteId -- default site name to site number
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
				,intPPHostId			= @intSellingHost	
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
				,@strAllowExemptionsOnExtAndRetailTrans

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;

	END
	ELSE IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND @strNetworkType = 'Voyager')
	BEGIN
		DECLARE @intTaxGroupByState INT = NULL

		IF(@intTaxGroupByState IS NULL)
		BEGIN
			SELECT TOP 1 @intTaxGroupByState = intTaxGroupId FROM tblCFNetworkSiteTaxGroup WHERE intNetworkId = @intNetworkId AND strState = @strSiteState
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
				,strAllowExemptionsOnExtAndRetailTrans
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteName
				,strDeliveryPickup		= 'Pickup'
				,intARLocationId		= @intNetworkLocation
				,strControllerType		= 'Voyager'
				,strTaxState			= @strSiteState
				,strSiteAddress			= @strSiteAddress	
				,strSiteCity			= @strSiteCity	
				,strSiteType			= 'Extended Remote'
				,intTaxGroupId			= @intTaxGroupByState
				,@strAllowExemptionsOnExtAndRetailTrans
				

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;
	END
	ELSE IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND @strNetworkType = 'CFN')
	BEGIN

		DECLARE @CFNState	NVARCHAR(MAX) = NULL
		SELECT TOP 1 @CFNState = strPostalCode FROM tblCFStateCode where strStateName = @strSiteTaxLocation

		INSERT INTO tblCFSite
			(
				 intNetworkId		
				,strSiteNumber	
				,strSiteName
				,strDeliveryPickup	
				,intARLocationId	
				,strControllerType	
				,strTaxState			
				,strSiteType
				,strAllowExemptionsOnExtAndRetailTrans
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteId
				,strDeliveryPickup		= 'Pickup'
				,intARLocationId		= @intNetworkLocation
				,strControllerType		= 'CFN'
				,strTaxState			= @CFNState
				,strSiteType			= (CASE @strTransactionType 
											WHEN 'Foreign Sale' 
												THEN 'Local/Network'
											ELSE @strTransactionType
											END)
				,@strAllowExemptionsOnExtAndRetailTrans
				

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;
	END
	ELSE IF ((@intSiteId IS NULL OR @intSiteId = 0) AND @intNetworkId != 0 AND @strNetworkType = 'Wright Express')
	BEGIN
		DECLARE @intWEXTaxGroupByState INT = NULL

		IF(@intTaxGroupByState IS NULL)
		BEGIN
			SELECT TOP 1 @intWEXTaxGroupByState = intTaxGroupId FROM tblCFNetworkSiteTaxGroup WHERE intNetworkId = @intNetworkId AND strState = @strSiteState
		END
		
		IF(@intTaxGroupByState IS NULL)
		BEGIN
			SELECT TOP 1 @intWEXTaxGroupByState = intTaxGroupId FROM tblCFNetworkSiteTaxGroup WHERE intNetworkId = @intNetworkId AND (strState IS NULL OR strState = '')
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
				,strAllowExemptionsOnExtAndRetailTrans
			)
			SELECT
				intNetworkId			= @intNetworkId
				,strSiteNumber			= @strSiteId
				,strSiteName			= @strSiteName
				,strDeliveryPickup		= 'Pickup'
				,intARLocationId		= @intNetworkLocation
				,strControllerType		= 'AutoGas'
				,strTaxState			= @strSiteState
				,strSiteAddress			= @strSiteAddress	
				,strSiteCity			= @strSiteCity	
				,strSiteType			= 'Extended Remote'
				,intTaxGroupId			= @intWEXTaxGroupByState
				,@strAllowExemptionsOnExtAndRetailTrans
				

			SET @intSiteId = SCOPE_IDENTITY();
			SET @ysnSiteCreated = 1;
	END
	ELSE IF (@strNetworkType = 'Non Network')
	BEGIN 
		IF(ISNULL(@intSiteId,0) != 0)
		BEGIN
			DECLARE @ysnPetrovendDualCard INT
			SELECT TOP 1 @ysnPetrovendDualCard = ysnPetrovendDualCard
			FROM tblCFSite where intSiteId = @intSiteId

			IF(ISNULL(@ysnPetrovendDualCard,0) = 1)
			BEGIN
				--DECLARE @i NVARCHAR(MAX)
				--SET @i = '0000000'
				--SELECT CONVERT(BIGINT, @i)

				IF(ISNULL(@strCardId,'') = '')
				BEGIN
					IF(ISNULL(@CardNumberForDualCard,'') != '')
					BEGIN
						SET @strCardId = @CardNumberForDualCard
						SET @strVehicleId = null
					END
					ELSE
					BEGIN
						SET @strCardId = @strVehicleId
						SET @strVehicleId = null
					END
				END

				IF (ISNUMERIC(@strCardId) = 1)
				BEGIN
					IF (CONVERT(BIGINT, @strCardId) = 0)
					BEGIN
						IF(ISNULL(@CardNumberForDualCard,'') != '')
						BEGIN
							SET @strCardId = @CardNumberForDualCard
							SET @strVehicleId = null
						END
						ELSE
						BEGIN
							SET @strCardId = @strVehicleId
							SET @strVehicleId = null
						END
					END
				END
			END
		END
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
				AND ( ISNULL(C.ysnActive,0) = 1  OR @ysnPostedCSV = 1)
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
					AND ( ISNULL(C.ysnActive,0) = 1  OR @ysnPostedCSV = 1)
				END
				ELSE
				BEGIN
					SELECT TOP 1 
						@intCustomerId = A.intCustomerId
					FROM tblCFCard C
					INNER JOIN tblCFAccount A
					ON C.intAccountId = A.intAccountId
					WHERE C.intCardId = @intCardId
					AND ( ISNULL(C.ysnActive,0) = 1  OR @ysnPostedCSV = 1)

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
				AND ( ISNULL(C.ysnActive,0) = 1  OR @ysnPostedCSV = 1)
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
			AND ( ISNULL(C.ysnActive,0) = 1  OR @ysnPostedCSV = 1)
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

	IF(@intProductId = 0)
	BEGIN
		SELECT TOP 1 
			 @intProductId = intItemId
			,@intARItemId = intARItemId
		FROM tblCFItem 
		WHERE strProductNumber = RTRIM(LTRIM(@strProductId))
		AND intNetworkId = @intNetworkId
		AND (intSiteId = 0 OR intSiteId IS NULL)
	END




	SET @intARItemLocationId = (SELECT TOP 1 intARLocationId
								FROM tblCFSite 
								WHERE intSiteId = @intSiteId)
	

	DECLARE @intDriverPinId INT = NULL
	DECLARE @ysnWriteDriverPinError BIT = 0
	IF(ISNULL(@strDriverPin,'') != '' AND ISNULL(@strDriverPin,'') != 0)
	BEGIN
		SELECT TOP 1 @intDriverPinId = intDriverPinId FROM tblCFDriverPin
		WHERE intAccountId = @intAccountId
		AND strDriverPinNumber = @strDriverPin

		IF(ISNULL(@intDriverPinId,0) = 0)
		BEGIN
			SET @ysnWriteDriverPinError = 1
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intDriverPinId = intDefaultDriverPin FROM tblCFCard 
		WHERE intCardId = @intCardId
	END


	--------------------------VEHICLE---------------------------
	
	DECLARE @tblCFNumericVehicle TABLE(
		 intVehicleId				int
		,strVehicleNumber			nvarchar(MAX)
		,intAccountId				int
	)

	DECLARE @tblCFCharVehicle TABLE(
		 intVehicleId				int
		,strVehicleNumber			nvarchar(MAX)
		,intAccountId				int
	)

	SELECT TOP 1 @ysnConvertMiscToVehicle = ysnConvertMiscToVehicle 
	FROM tblCFAccount 
	WHERE intAccountId = @intAccountId

	IF(@intAccountId IS NOT NULL AND @intAccountId != 0)
	BEGIN
		SET @strPONumber = ''
		SELECT TOP 1 @strPONumber = strPurchaseOrderNo FROM tblCFPurchaseOrder WHERE intAccountId = @intAccountId AND  DATEADD(dd, DATEDIFF(dd, 0, dtmExpirationDate), 0) >= DATEADD(dd, DATEDIFF(dd, 0, @dtmTransactionDate), 0) ORDER BY dtmExpirationDate ASC
	END


	IF(@intAccountId IS NOT NULL AND @intAccountId != 0)
	BEGIN
		IF((@strVehicleId = '0' OR  @strVehicleId IS NULL OR ISNULL(@intVehicleId,0) = 0) AND @ysnConvertMiscToVehicle = 1)
		BEGIN
			SET @strVehicleId = @strMiscellaneous
		END

		IF(@strVehicleId IS NOT NULL)
		BEGIN

			IF(ISNUMERIC(@strVehicleId) = 1)
			BEGIN

				--INT VEHICLE NUMBER--
				INSERT INTO @tblCFNumericVehicle(
					 intVehicleId			
					,strVehicleNumber
					,intAccountId
				)	
				SELECT 
					 intVehicleId			
					,strVehicleNumber	
					,intAccountId		
				FROM tblCFVehicle 
				WHERE RTRIM(LTRIM(strVehicleNumber)) not like '%[^0-9]%' and LTRIM(RTRIM(strVehicleNumber)) != ''
				AND intAccountId = @intAccountId

				SET @intVehicleId =
				(SELECT TOP 1 intVehicleId
				FROM @tblCFNumericVehicle
				WHERE CAST(LTRIM(RTRIM(strVehicleNumber)) AS BIGINT) = CAST(LTRIM(RTRIM(@strVehicleId)) AS BIGINT))


			END
			ELSE
			BEGIN
				--CHAR VEHICLE NUMBER--
				INSERT INTO @tblCFCharVehicle(
					 intVehicleId			
					,strVehicleNumber
					,intAccountId
				)	
				SELECT 
					 intVehicleId			
					,strVehicleNumber	
					,intAccountId		
				FROM tblCFVehicle WHERE RTRIM(LTRIM(strVehicleNumber)) like '%[^0-9]%' and RTRIM(LTRIM(strVehicleNumber)) != ''
				AND intAccountId = @intAccountId

				SET @intVehicleId =
				(SELECT TOP 1 intVehicleId
				FROM @tblCFCharVehicle
				WHERE LTRIM(RTRIM(strVehicleNumber)) = RTRIM(LTRIM(@strVehicleId)))

			END
		
		END
	END
	ELSE
	BEGIN
		SET @intVehicleId = NULL
	END


	DECLARE @ysnIgnoreVehicleError BIT
	SET @ysnIgnoreVehicleError = 0

	IF(ISNUMERIC(@strVehicleId) = 1)
	BEGIN
		SET @strVehicleId = CAST(@strVehicleId AS BIGINT)
		DECLARE @bgIntVehicleId BIGINT
		SET @bgIntVehicleId = CAST(@strVehicleId AS BIGINT)

		IF(@bgIntVehicleId = 0)
		BEGIN
			SET @ysnIgnoreVehicleError = 1
		END
	END
	ELSE
	BEGIN
		SET @strVehicleId =  LTRIM(RTRIM(ISNULL(@strVehicleId,'')))
		IF(@strVehicleId = '')
		BEGIN
			SET @ysnIgnoreVehicleError = 1
		END
	END


	IF(ISNULL(@intVehicleId,0) = 0)
	BEGIN
		SELECT TOP 1 @intVehicleId = intDefaultFixVehicleNumber FROM tblCFCard 
		WHERE intCardId = @intCardId
	END

	------------------------------------------------------------


	SELECT TOP 1 @ysnOnHold  = ISNULL(ysnIgnoreCardTransaction,0) 
	FROM tblCFCard WHERE intCardId = @intCardId


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
		DECLARE @intPrcContractNumber		NVARCHAR(MAX)				
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
		DECLARE @dblInventoryCost			NUMERIC(18,6)
		DECLARE @dblAdjustmentRate			NUMERIC(18,6)
		
	------------------------------------------------------------

		------------------------------------------------------
		-------------- Start get card type/ dual card
		------------------------------------------------------
	
		SELECT TOP 1 
			@intCardTypeId =  intCardTypeId
		FROM tblCFCard
		WHERE intCardId = @intCardId


		SELECT TOP 1
			@ysnDualCard = ysnDualCard
		FROM tblCFCardType
		WHERE intCardTypeId = @intCardTypeId
		------------------------------------------------------
		-------------- End get card type/ dual card
		------------------------------------------------------



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
			IF (@strTransactionType != 'Foreign Sale')
			BEGIN
				SET @ysnInvalid = 1
			END
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
			IF (@strTransactionType != 'Foreign Sale')
			BEGIN
				SET @ysnInvalid = 1
			END
		END

		IF(@dblQuantity = 0 OR @dblQuantity IS NULL)
		BEGIN
			SET @ysnInvalid = 1
		END

		
		IF(ISNULL(@intVehicleId,0) = 0 AND @strTransactionType != 'Foreign Sale' )
		BEGIN
			SET @intVehicleId = NULL
			IF(ISNULL(@ysnVehicleRequire,0) = 1 AND (ISNULL(@ysnDualCard,0) = 1 OR ISNULL(@intCardTypeId,0) = 0))
			BEGIN
				SET @ysnInvalid = 1
			END
			ELSE
			BEGIN
				IF(@ysnIgnoreVehicleError = 0)
				BEGIN
					SET @ysnInvalid = 1
				END
			END
		END
		ELSE
		BEGIN
			IF(@intVehicleId = 0)
			BEGIN
				SET @intVehicleId = NULL
			END
		END
		
		
		----------POSTED DATE----------
		--SELECT @strLaggingDate

		

		IF (DATEADD(dd, DATEDIFF(dd, 0, @dtmTransactionDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, @strLaggingDate), 0))
		BEGIN
			SET @strPostedDate = @strPostedDate
		END
		ELSE
		BEGIN
			SET @strPostedDate = @dtmTransactionDate
		END
		----------POSTED DATE----------

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
			--,[intContractId]				
			,[dblQuantity]				
			,[dtmBillingDate]			
			,[dtmPostedDate]		
			,[dtmCreatedDate]
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
			,[dtmInvoiceDate]
			,[strInvoiceReportNumber]
			,[ysnOnHold]
			,[intCustomerId]
			,[intImportCardId]
			,[intDriverPinId]
			,[ysnInvoiced]
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
			--,@intContractId			
			,@dblQuantity				
			,@dtmBillingDate		
			,@strPostedDate	
			,@strCreatedDate
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
			,@dtmInvoiceDate
			,@strInvoiceReportNumber
			,@ysnOnHold
			,@intCustomerId
			,@intCardId
			,@intDriverPinId
			,@ysnInvoiced
		)			
	
		DECLARE @Pk	INT		
		DECLARE @test varchar(10)
		SELECT @Pk  = SCOPE_IDENTITY();


		------------------------------------------------------------
		--				INSERT IMPORT ERROR LOGS				  --
		------------------------------------------------------------
		
		
		IF(ISNULL(@ysnWriteDriverPinError,0) = 1)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find driver pin number ' + @strDriverPin + ' into i21 driver pin list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find driver pin number ' + @strDriverPin + ' into i21 driver pin list')
		END

		IF(ISNULL(@intARItemId,0) = 0)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find product number ' + @strProductId + ' into i21 item list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find product number ' + @strProductId + ' into i21 item list')
		END
		IF(ISNULL(@intPrcCustomerId,0) = 0 AND @strTransactionType != 'Foreign Sale')
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find customer number using card number ' + @strCardId + ' into i21 card account list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find customer number using card number ' + @strCardId + ' into i21 card account list')
		END
		IF(ISNULL(@intARItemLocationId,0) = 0)
		BEGIN
			--INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			--VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid location for site ' + @strSiteId)
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid location for site ' + @strSiteId)
		END
		IF(ISNULL(@intPrcItemUOMId,0) = 0)
		BEGIN
			--INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			--VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid Item Location UOM')
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid UOM for product number ' + @strProductId)
		END
		IF(ISNULL(@intNetworkId,0) = 0)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find network ' + @strNetworkId + ' into i21 network list')
			
			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find network ' + @strNetworkId + ' into i21 network list')
		END
		IF(ISNULL(@intSiteId,0) = 0)
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
		IF((ISNULL(@intCardId,0) = 0) AND @strTransactionType != 'Foreign Sale')
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Unable to find card number ' + @strCardId + ' into i21 card list')

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find card number ' + @strCardId + ' into i21 card list')
		END
		IF(ISNULL(@dblQuantity,0) = 0)
		BEGIN
			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
			VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Invalid quantity - ' + Str(@dblQuantity, 16, 8))

			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid quantity - ' + Str(@dblQuantity, 16, 8))

			UPDATE tblCFTransaction SET dblOriginalGrossPrice = @dblOriginalGrossPrice WHERE intTransactionId = @Pk


			--INSERT INTO tblCFTransactionPrice
			--(
			--	 intTransactionId
			--	,strTransactionPriceId
			--	,dblOriginalAmount
			--	,dblCalculatedAmount
			--)
			--VALUES 
			-- (@Pk,'Gross Price',@dblOriginalGrossPrice,0.0)
			--,(@Pk,'Net Price',0.0,0.0)
			--,(@Pk,'Total Amount',0.0,0.0)

			RETURN;
		END

		--------------------------------------------------------
		---------------- Start get card type/ dual card
		--------------------------------------------------------
	
		--SELECT TOP 1 
		--	@intCardTypeId =  intCardTypeId
		--FROM tblCFCard
		--WHERE intCardId = @intCardId


		--SELECT TOP 1
		--	@ysnDualCard = ysnDualCard
		--FROM tblCFCardType
		--WHERE intCardTypeId = @intCardTypeId
		--------------------------------------------------------
		---------------- End get card type/ dual card
		--------------------------------------------------------

		
		IF(ISNULL(@intVehicleId,0) = 0 AND @strTransactionType != 'Foreign Sale' )
		BEGIN
			SET @intVehicleId = NULL
			IF(ISNULL(@ysnVehicleRequire,0) = 1 AND (ISNULL(@ysnDualCard,0) = 1 OR ISNULL(@intCardTypeId,0) = 0))
			BEGIN
				INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
				VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Vehicle is required.')

				INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Vehicle is required.')

				IF(@ysnIgnoreVehicleError = 0)
				BEGIN
					INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
					VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')

					INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')
				END

				SET @ysnInvalid = 1

			END
			ELSE
			BEGIN
				IF(@ysnIgnoreVehicleError = 0)
				BEGIN
					INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
					VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Invalid Vehicle # '+ @strVehicleId +' , setup vehicle in Card Accounts to correct, or recalculate to remove this error and leave the vehicle as blank.')

					INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid Vehicle # '+ @strVehicleId +' , setup vehicle in Card Accounts to correct, or recalculate to remove this error and leave the vehicle as blank.')

					SET @ysnInvalid = 1
				END
			END
		END


		--IF(ISNULL(@ysnVehicleRequire,0) = 1)
		--BEGIN
		--	IF(ISNULL(@ysnVehicleRequire,0) = 1 AND (ISNULL(@ysnDualCard,0) = 1 OR ISNULL(@intCardTypeId,0) = 0) AND @strTransactionType != 'Foreign Sale')
		--	BEGIN
		--		IF(@strVehicleId <> '0')
		--		BEGIN
		--			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		--			VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')

		--			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Unable to find vehicle number '+ @strVehicleId +' into i21 vehicle list')
		--		END
		--	END
		--END
		--ELSE
		--BEGIN
		--	IF(ISNULL(LTRIM(RTRIM(@strVehicleId)),'') != '')
		--	BEGIN
		--		IF(ISNULL(@intVehicleId,0) = 0 AND @strVehicleId <> '0' AND @strTransactionType != 'Foreign Sale')
		--		BEGIN

		--			INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		--			VALUES ('Import',@strProcessDate,@strGUID, @Pk,'Invalid Vehicle # '+ @strVehicleId +' , setup vehicle in Card Accounts to correct, or recaclulate to remove this error and leave the vehicle as blank.')

		--			INSERT INTO tblCFFailedImportedTransaction (intTransactionId,strFailedReason) VALUES (@Pk, 'Invalid Vehicle # '+ @strVehicleId +' , setup vehicle in Card Accounts to correct, or recaclulate to remove this error and leave the vehicle as blank.')
		--		END
		--	END
		--END
		

		
		DECLARE @ysnRecalculateInvalid BIT	= 0

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
		,@Tax1							=	@Tax1		
		,@Tax2							=	@Tax2		
		,@Tax3							=	@Tax3		
		,@Tax4							=	@Tax4		
		,@Tax5							=	@Tax5		
		,@Tax6							=	@Tax6		
		,@Tax7							=	@Tax7		
		,@Tax8							=	@Tax8		
		,@Tax9							=	@Tax9		
		,@Tax10							=	@Tax10		
		,@TaxValue1						=	@TaxValue1	
		,@TaxValue2						=	@TaxValue2	
		,@TaxValue3						=	@TaxValue3	
		,@TaxValue4						=	@TaxValue4	
		,@TaxValue5						=	@TaxValue5	
		,@TaxValue6						=	@TaxValue6	
		,@TaxValue7						=	@TaxValue7	
		,@TaxValue8						=	@TaxValue8	
		,@TaxValue9						=	@TaxValue9	
		,@TaxValue10					=	@TaxValue10
		,@ForeignCardId					=   @strCardId


		DECLARE @dblGrossTransferCost	NUMERIC(18,6)	
		DECLARE @dblNetTransferCost		NUMERIC(18,6)	

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
		,@intPrcContractNumber			= strContractNumber
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
		,@ysnRecalculateInvalid			= ysnInvalid
		,@dblInventoryCost				= dblInventoryCost
		,@dblMargin						= dblMargin
		,@dblGrossTransferCost			= dblGrossTransferCost
		,@dblNetTransferCost			= dblNetTransferCost
		,@dblAdjustmentRate				= dblAdjustmentRate
		FROM tblCFTransactionPricingType

		--IF(@ysnDuplicate = 1)
		--BEGIN
		--	SET @ysnInvalid = 1
		--	INSERT INTO tblCFTransactionNote (strProcess,dtmProcessDate,strGuid,intTransactionId ,strNote)
		--	VALUES ('Import',@strProcessDate,@strGUID, @Pk, 'Duplicate transaction history found.')
		--END

		IF(@ysnRecalculateInvalid = 1)
		BEGIN 
			SET @ysnInvalid = @ysnRecalculateInvalid
		END

		IF (@strPriceMethod = 'Inventory - Standard Pricing')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId		= null 
				,strPriceBasis			= null
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod			= 'Standard Pricing'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk
		END
		IF (@strPriceMethod = 'Import File Price')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod = 'Import File Price'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk
		END
		IF (@strPriceMethod = 'Network Cost')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod = @strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk
		END
		ELSE IF (@strPriceMethod = 'Special Pricing')
		BEGIN
				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis = null
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod = 'Special Pricing'
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk
		END
		ELSE IF (@strPriceMethod = 'Price Profile')
		BEGIN
				--IF(@strPrcPriceBasis = 'Transfer Cost' OR @strPrcPriceBasis = 'Transfer Price' OR @strPrcPriceBasis = 'Discounted Price' OR @strPrcPriceBasis = 'Full Retail')
				--BEGIN
				--	SET @dblTransferCost = @dblTransferCost
				--END
				--ELSE
				--BEGIN
				--	SET @dblTransferCost = 0
				--END

				UPDATE tblCFTransaction 
				SET intContractId = null 
				,strPriceBasis			= @strPrcPriceBasis
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
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
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
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
				SET dblQuantity = @dblQuantity
				WHERE intTransactionId = @Pk


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
				,@Tax1							=	@Tax1		
				,@Tax2							=	@Tax2		
				,@Tax3							=	@Tax3		
				,@Tax4							=	@Tax4		
				,@Tax5							=	@Tax5		
				,@Tax6							=	@Tax6		
				,@Tax7							=	@Tax7		
				,@Tax8							=	@Tax8		
				,@Tax9							=	@Tax9		
				,@Tax10							=	@Tax10		
				,@TaxValue1						=	@TaxValue1	
				,@TaxValue2						=	@TaxValue2	
				,@TaxValue3						=	@TaxValue3	
				,@TaxValue4						=	@TaxValue4	
				,@TaxValue5						=	@TaxValue5	
				,@TaxValue6						=	@TaxValue6	
				,@TaxValue7						=	@TaxValue7	
				,@TaxValue8						=	@TaxValue8	
				,@TaxValue9						=	@TaxValue9	
				,@TaxValue10					=	@TaxValue10
				,@ForeignCardId					=   @strCardId


				SELECT
				 @dblPrcPriceOut				= dblPrice
				,@strPrcPricingOut				= strPriceMethod
				,@dblPrcOriginalPrice			= dblOriginalPrice
				,@strPrcPriceBasis				= strPriceBasis
				,@strPriceMethod   				= strPriceMethod
				,@strPriceBasis 				= strPriceBasis
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
				,@ysnRecalculateInvalid			= ysnInvalid
				,@dblInventoryCost				= dblInventoryCost
				,@dblMargin						= dblMargin
				,@dblGrossTransferCost			= dblGrossTransferCost
				,@dblNetTransferCost			= dblNetTransferCost
				,@dblAdjustmentRate				= dblAdjustmentRate
				FROM tblCFTransactionPricingType

					
				UPDATE tblCFTransaction 
				SET strPriceBasis = null 
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod = 'Contract Pricing'
				,intContractId = @intPrcContractHeaderId
				,intContractDetailId = @intPrcContractDetailId
				,dblQuantity = @dblQuantity
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk

				------------------------------------------------------------
				--				UPDATE CONTRACTS QUANTITY				  --
				------------------------------------------------------------
				IF (@strPriceMethod = 'Contracts' OR @strPriceMethod = 'Contract Pricing')
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
				,dblInventoryCost		= @dblInventoryCost	
				,dblMargin				= @dblMargin
				,strPriceMethod = @strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= @intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= @strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= @ysnDuplicate
				,ysnInvalid				= @ysnInvalid
				,dblGrossTransferCost	= @dblGrossTransferCost
				,dblNetTransferCost		= @dblNetTransferCost
				,dblAdjustmentRate		= @dblAdjustmentRate
				WHERE intTransactionId = @Pk
		END


		--DEBUGGER HERE-- SELECT * FROM tblCFTransactionTaxType --HERE--
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
			,ysnTaxExempt
		)
		SELECT 
			 @Pk
			,dblTaxOriginalAmount
			,dblTaxCalculatedAmount		
			,intTaxCodeId	
			,dblTaxRate	
			,ysnTaxExempt
		FROM tblCFTransactionTaxType


		UPDATE tblCFTransaction
		SET
		dblCalculatedTotalTax		= (SELECT 
		SUM(ISNULL(dblTaxCalculatedAmount,0))
		FROM tblCFTransactionTaxType as tax)
		,dblOriginalTotalTax		= (SELECT 
		SUM(ISNULL(dblTaxOriginalAmount,0))
		FROM tblCFTransactionTaxType as tax)
		WHERE intTransactionId = @Pk
	

		------------------------------------------------------------
		--						TRANSACTION PRICE				  --
		------------------------------------------------------------

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