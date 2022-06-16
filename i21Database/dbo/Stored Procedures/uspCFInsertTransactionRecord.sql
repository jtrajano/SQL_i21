
CREATE PROCEDURE [dbo].[uspCFInsertTransactionRecord]
	
	 @strGUID						    NVARCHAR(MAX)
	,@intUserId							INT				= NULL



AS
BEGIN

	DECLARE @tblCFSiteToCreate TABLE 
	(
		strSiteId			 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
		,intNetworkId		 INT NULL
		,intRowId			 INT NULL
	)

	---- clear the buffers before time monitoring
	--dbcc dropcleanbuffers;
	--checkpoint;
 
	---- perform any additional operations for enabling a test query design
	---- such as creating keys and indexes

	---- flush query cache on server
	--dbcc freeproccache with no_infomsgs;

	--set statistics time on

	BEGIN TRY 
	BEGIN TRANSACTION 
	

	PROCESSOVERFILL:
	DECLARE @ysnAssignSite INT
	SET @ysnAssignSite = 0 
	/**********************************
		IF(LOWER(@strTransactionType) LIKE '%foreign%')
		BEGIN
			SET @strTransactionType = 'Foreign Sale'
		END
	***********************************/

	UPDATE tblCFImportTransactionStagingTable 
	SET strProcessType = 'invoice'
	WHERE strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET strTransactionType = 'Foreign Sale' 
	WHERE strTransactionType = '%Foreign%'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
		strTrimedVehicleNumber = LTRIM(RTRIM(strVehicleNumber))
	WHERE strGUID = @strGUID
	

	UPDATE tblCFImportTransactionStagingTable
	SET 
		 ysnNumericVehicle = 1 
		,strNumericVehicleNumber = CAST(strTrimedVehicleNumber AS BIGINT)
	WHERE ISNUMERIC(strTrimedVehicleNumber) = 1
	AND strGUID = @strGUID
	


	/*****************************
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
	*/

	UPDATE tblCFImportTransactionStagingTable 
	SET ysnPosted = tblCFImportTransactionStagingTable.ysnOriginHistory 
	WHERE tblCFImportTransactionStagingTable.ysnPosted != 1 OR tblCFImportTransactionStagingTable.ysnPosted IS NULL
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable 
	SET ysnPosted = tblCFImportTransactionStagingTable.ysnPostedCSV 
	WHERE tblCFImportTransactionStagingTable.ysnPosted != 1 OR tblCFImportTransactionStagingTable.ysnPosted IS NULL
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable 
	SET ysnInvoiced = 1
	WHERE tblCFImportTransactionStagingTable.ysnPosted = 1
	AND strGUID = @strGUID




	/********************
	IF(@intContractId = 0)
	BEGIN
		SET @intContractId = NULL
	END
	**********************/
	UPDATE tblCFImportTransactionStagingTable 
	SET intContractId = NULL 
	WHERE intContractId = 0
	AND strGUID = @strGUID

	


	/*************************
	IF(@intSalesPersonId = 0)
		BEGIN
			SET @intSalesPersonId = NULL
		END
	*************************/
	UPDATE tblCFImportTransactionStagingTable 
	SET intSalesPersonId = NULL 
	WHERE intSalesPersonId = 0
	AND strGUID = @strGUID





	/*******************
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
	**********************/
	UPDATE tblCFImportTransactionStagingTable
	SET intNetworkId		 = tblCFNetwork.intNetworkId 
	,strParticipantNo		 = tblCFNetwork.strParticipant
	,strNetworkType			 = tblCFNetwork.strNetworkType
	,intForeignCustomerId	 = tblCFNetwork.intCustomerId
	,intNetworkLocation		 = tblCFNetwork.intLocationId
	FROM tblCFNetwork
	WHERE tblCFNetwork.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND tblCFImportTransactionStagingTable.intNetworkId != 0 
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET intNetworkId		 = tblCFNetwork.intNetworkId 
	,strParticipantNo		 = tblCFNetwork.strParticipant
	,strNetworkType			 = tblCFNetwork.strNetworkType
	,intForeignCustomerId	 = tblCFNetwork.intCustomerId
	,intNetworkLocation		 = tblCFNetwork.intLocationId
	FROM tblCFNetwork
	WHERE tblCFNetwork.strNetwork COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strNetworkId COLLATE Latin1_General_CI_AS
	AND tblCFImportTransactionStagingTable.intNetworkId = 0 OR tblCFImportTransactionStagingTable.intNetworkId IS NULL
	AND tblCFImportTransactionStagingTable.strGUID = @strGUID



	/***************************************
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
	***************************************/

	REASSIGNSITE:

	

	UPDATE tblCFImportTransactionStagingTable
	SET
	 intSiteId					= tblCFSite.intSiteId 
	,intCustomerLocationId		= tblCFSite.intARLocationId
	,intTaxMasterId				= tblCFSite.intTaxGroupId
	,ysnSiteAcceptCreditCard	= tblCFSite.ysnSiteAcceptsMajorCreditCards
	,strSiteType				= tblCFSite.strSiteType
	FROM tblCFSite
	WHERE tblCFSite.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND tblCFSite.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND (tblCFImportTransactionStagingTable.intSiteId != 0 OR tblCFImportTransactionStagingTable.intSiteId IS NOT NULL)
	AND strGUID = @strGUID

	
	--TEST--
	SELECT intSiteId FROM tblCFImportTransactionStagingTable

	UPDATE tblCFImportTransactionStagingTable
	SET
	 intSiteId					= tblCFSite.intSiteId 
	,intCustomerLocationId		= tblCFSite.intARLocationId
	,intTaxMasterId				= tblCFSite.intTaxGroupId
	,ysnSiteAcceptCreditCard	= tblCFSite.ysnSiteAcceptsMajorCreditCards
	,strSiteType				= tblCFSite.strSiteType
	FROM tblCFSite
	WHERE tblCFSite.strSiteNumber COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strSiteId COLLATE Latin1_General_CI_AS
	AND tblCFSite.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND (tblCFImportTransactionStagingTable.intSiteId = 0 OR tblCFImportTransactionStagingTable.intSiteId IS NULL)
	AND strGUID = @strGUID

	
	--TEST--
	SELECT intSiteId FROM tblCFImportTransactionStagingTable

	UPDATE tblCFImportTransactionStagingTable
	SET
	 intSiteId					= NULL
	WHERE tblCFImportTransactionStagingTable.intSiteId = 0
	AND strGUID = @strGUID


	--TEST--
	SELECT intSiteId FROM tblCFImportTransactionStagingTable


	/******************************
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
	******************************/
	
	UPDATE tblCFImportTransactionStagingTable
	SET
	 intMatchSellingHost = (select Count(*) from fnCFSplitString(tblCFImportTransactionStagingTable.strParticipantNo,',') where Record = tblCFImportTransactionStagingTable.intSellingHost)
	,intMatchBuyingHost  = (select Count(*) from fnCFSplitString(tblCFImportTransactionStagingTable.strParticipantNo,',') where Record = tblCFImportTransactionStagingTable.intBuyingHost)
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET
		tblCFImportTransactionStagingTable.strTransactionType = 'Local/Network'
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND intMatchSellingHost > 0 AND intMatchBuyingHost > 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType = 'Foreign Sale'
		,tblCFImportTransactionStagingTable.dblOriginalGrossPrice = tblCFImportTransactionStagingTable.dblTransferCost
		,tblCFImportTransactionStagingTable.intCustomerId = tblCFImportTransactionStagingTable.intForeignCustomerId
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND intMatchSellingHost > 0 AND intMatchBuyingHost > 0
	AND strGUID = @strGUID

	


	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType = 'Foreign Sale'
		,tblCFImportTransactionStagingTable.dblOriginalGrossPrice = tblCFImportTransactionStagingTable.dblTransferCost
		,tblCFImportTransactionStagingTable.intCustomerId = tblCFImportTransactionStagingTable.intForeignCustomerId
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND intMatchSellingHost > 0 AND intMatchBuyingHost = 0
	AND strGUID = @strGUID

	


	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType = (CASE tblCFImportTransactionStagingTable.strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND intMatchBuyingHost > 0 AND intMatchSellingHost = 0
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType = (CASE tblCFImportTransactionStagingTable.strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
									  END)
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND intMatchBuyingHost = 0 AND intMatchSellingHost = 0
	AND strGUID = @strGUID



	UPDATE tblCFImportTransactionStagingTable
	SET
		tblCFImportTransactionStagingTable.dblOriginalGrossPrice = tblCFImportTransactionStagingTable.dblTransferCost
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND dblOriginalGrossPrice IS NULL OR dblOriginalGrossPrice = 0
	AND strGUID = @strGUID

	


	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.dblStateSalesTaxPercentageRate   = tblCFImportTransactionStagingTable.dblStateSalesTaxPercentageRate  * 100
		,tblCFImportTransactionStagingTable.dblCountySalesTaxPercentageRate  = tblCFImportTransactionStagingTable.dblCountySalesTaxPercentageRate * 100
		,tblCFImportTransactionStagingTable.dblCitySalesTaxPercentageRate    = tblCFImportTransactionStagingTable.dblCitySalesTaxPercentageRate   * 100
		,tblCFImportTransactionStagingTable.dblOtherSalesTaxPercentageRate   = tblCFImportTransactionStagingTable.dblOtherSalesTaxPercentageRate  * 100
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' AND (tblCFImportTransactionStagingTable.ysnPosted IS NULL OR tblCFImportTransactionStagingTable.ysnPosted = 0)
	AND strGUID = @strGUID

	/*
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
	*/

	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.dblFederalExciseTaxRate  			  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strFederalExciseTaxRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strFederalExciseTaxRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strFederalExciseTaxRateReference = 'R'
																						THEN 0.000000
																						ELSE dblFederalExciseTaxRate
																					END
		,tblCFImportTransactionStagingTable.dblStateExciseTaxRate1  			  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strStateExciseTaxRate1Reference IS NULL 
																							OR tblCFImportTransactionStagingTable.strStateExciseTaxRate1Reference = '' 
																							OR tblCFImportTransactionStagingTable.strStateExciseTaxRate1Reference = 'R'
																						THEN 0.000000
																						ELSE dblStateExciseTaxRate1
																					END
		,tblCFImportTransactionStagingTable.dblStateExciseTaxRate2   			  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strStateExciseTaxRate2Reference IS NULL 
																							OR tblCFImportTransactionStagingTable.strStateExciseTaxRate2Reference = '' 
																							OR tblCFImportTransactionStagingTable.strStateExciseTaxRate2Reference = 'R'
																						THEN 0.000000
																						ELSE dblStateExciseTaxRate2
																					END
		,tblCFImportTransactionStagingTable.dblCountyExciseTaxRate   			  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strCountyExciseTaxRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strCountyExciseTaxRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strCountyExciseTaxRateReference = 'R'
																						THEN 0.000000
																						ELSE dblCountyExciseTaxRate
																					END
		,tblCFImportTransactionStagingTable.dblCityExciseTaxRate				  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strCityExciseTaxRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strCityExciseTaxRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strCityExciseTaxRateReference = 'R'
																						THEN 0.000000
																						ELSE dblCityExciseTaxRate
																					END
		,tblCFImportTransactionStagingTable.dblStateSalesTaxPercentageRate		  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strStateSalesTaxPercentageRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strStateSalesTaxPercentageRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strStateSalesTaxPercentageRateReference = 'R'
																						THEN 0.000000
																						ELSE dblStateSalesTaxPercentageRate
																					END
		,tblCFImportTransactionStagingTable.dblCountySalesTaxPercentageRate		  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strCountySalesTaxPercentageRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strCountySalesTaxPercentageRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strCountySalesTaxPercentageRateReference = 'R'
																						THEN 0.000000
																						ELSE dblCountySalesTaxPercentageRate
																					END
		,tblCFImportTransactionStagingTable.dblCitySalesTaxPercentageRate		  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strCitySalesTaxPercentageRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strCitySalesTaxPercentageRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strCitySalesTaxPercentageRateReference = 'R'
																						THEN 0.000000
																						ELSE dblCitySalesTaxPercentageRate
																					END
		,tblCFImportTransactionStagingTable.dblOtherSalesTaxPercentageRate		  = CASE 
																						WHEN tblCFImportTransactionStagingTable.strOtherSalesTaxPercentageRateReference IS NULL 
																							OR tblCFImportTransactionStagingTable.strOtherSalesTaxPercentageRateReference = '' 
																							OR tblCFImportTransactionStagingTable.strOtherSalesTaxPercentageRateReference = 'R'
																						THEN 0.000000
																						ELSE dblOtherSalesTaxPercentageRate
																					END
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride' 
	AND strGUID = @strGUID


	/********************
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
	********************/
	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType   = CASE WHEN (tblCFImportTransactionStagingTable.intSiteId = 0 OR  tblCFImportTransactionStagingTable.intSiteId IS NULL) THEN 'Extended Remote' ELSE tblCFImportTransactionStagingTable.strSiteType END
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Voyager'
	AND strGUID = @strGUID



	/*********************
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
	*******************/
	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType   = CASE WHEN (tblCFImportTransactionStagingTable.intSiteId = 0 OR  tblCFImportTransactionStagingTable.intSiteId IS NULL) THEN 'Extended Remote' ELSE tblCFImportTransactionStagingTable.strSiteType END
		 ,tblCFImportTransactionStagingTable.dblQuantity = CASE 
															WHEN (tblCFImportTransactionStagingTable.dblQuantity = 0 OR  tblCFImportTransactionStagingTable.dblQuantity IS NULL) AND (ISNULL(tblCFImportTransactionStagingTable.dblOriginalTotalPrice,0) > 0) THEN 1 
														    WHEN (tblCFImportTransactionStagingTable.dblQuantity = 0 OR  tblCFImportTransactionStagingTable.dblQuantity IS NULL) AND (ISNULL(tblCFImportTransactionStagingTable.dblOriginalTotalPrice,0) < 0) THEN -1 
														   END
		,tblCFImportTransactionStagingTable.dblOriginalGrossPrice = CASE 
															WHEN (tblCFImportTransactionStagingTable.dblQuantity = 0 OR  tblCFImportTransactionStagingTable.dblQuantity IS NULL) AND (ISNULL(tblCFImportTransactionStagingTable.dblOriginalTotalPrice,0) > 0) THEN ISNULL(dblOriginalTotalPrice ,0)
														    WHEN (tblCFImportTransactionStagingTable.dblQuantity = 0 OR  tblCFImportTransactionStagingTable.dblQuantity IS NULL) AND (ISNULL(tblCFImportTransactionStagingTable.dblOriginalTotalPrice,0) < 0) THEN ISNULL(dblOriginalTotalPrice ,0) * 1
														   END
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Wright Express'
	AND strGUID = @strGUID


	


	
	/*********************
	ELSE IF (@strNetworkType = 'CFN')
	BEGIN

		IF(@dblOriginalTotalPrice < 0)
		BEGIN
			IF(ISNULL(@dblQuantity,0) > 0)
			BEGIN
				SET @dblOriginalGrossPrice = ABS(@dblOriginalGrossPrice)
				SET @dblQuantity = (@dblQuantity * -1)
			END
		END

		IF(@strTransactionType = 'R')
		BEGIN
			SET @strTransactionType = 'Remote'
		END
		ELSE IF (@strTransactionType = 'D' OR @strTransactionType = 'C' OR @strTransactionType = 'N')
		BEGIN
			SET @strTransactionType = 'Local/Network'
			IF(ISNULL(@dblTransferCost,0) = 0)-- AND @strTransactionType = 'Local/Network'
			BEGIN
				SET @dblTransferCost = @dblOriginalGrossPrice
			END
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
	*********************/

	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.dblQuantity = (tblCFImportTransactionStagingTable.dblQuantity * -1)
		,tblCFImportTransactionStagingTable.dblOriginalGrossPrice = ABS(tblCFImportTransactionStagingTable.dblOriginalGrossPrice)
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND tblCFImportTransactionStagingTable.dblOriginalTotalPrice < 0
	AND tblCFImportTransactionStagingTable.dblQuantity > 0
	AND strGUID = @strGUID

	


	
	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strTransactionType = 'Remote'
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND tblCFImportTransactionStagingTable.strTransactionType = 'R'
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET
		  tblCFImportTransactionStagingTable.strTransactionType = 'Local/Network'
		 ,tblCFImportTransactionStagingTable.dblTransferCost = CASE 
																WHEN 
																	tblCFImportTransactionStagingTable.dblTransferCost IS NULL OR tblCFImportTransactionStagingTable.dblTransferCost = 0
																	THEN tblCFImportTransactionStagingTable.dblOriginalGrossPrice
																	ELSE tblCFImportTransactionStagingTable.dblTransferCost
																END

	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND tblCFImportTransactionStagingTable.strTransactionType = 'D' OR tblCFImportTransactionStagingTable.strTransactionType = 'C' OR tblCFImportTransactionStagingTable.strTransactionType = 'N'
	AND strGUID = @strGUID
	

	UPDATE tblCFImportTransactionStagingTable
	SET
		  tblCFImportTransactionStagingTable.strTransactionType = 'Foreign Sale'
		 ,tblCFImportTransactionStagingTable.intCustomerId = tblCFImportTransactionStagingTable.intForeignCustomerId
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND tblCFImportTransactionStagingTable.strTransactionType = 'F'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET
		  tblCFImportTransactionStagingTable.strTransactionType = 'Extended Remote'
	FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND tblCFImportTransactionStagingTable.strTransactionType = 'E'
	AND strGUID = @strGUID

	

	--INSERT INTO [tblCFDebugImportTransaction]
	--(
	--	 strTransactionType
	--	,strNetworkType
	--	,strPriceMethod
	--	,strGUID
	--)
	--SELECT 
	-- strTransactionType
	--,strNetworkType
	--,@strGUID
	--,strGUID
	--FROM tblCFImportTransactionStagingTable



	DELETE FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE strGUID = @strGUID
	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		 tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax1
		,tblCFImportTransactionStagingTable.dblTaxValue1
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		 tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax2
		,tblCFImportTransactionStagingTable.dblTaxValue2
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		 tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax3
		,tblCFImportTransactionStagingTable.dblTaxValue3
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		 tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax4
		,tblCFImportTransactionStagingTable.dblTaxValue4
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		 tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax5
		,tblCFImportTransactionStagingTable.dblTaxValue5
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax6
		,tblCFImportTransactionStagingTable.dblTaxValue6
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax7
		,tblCFImportTransactionStagingTable.dblTaxValue7
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax8
		,tblCFImportTransactionStagingTable.dblTaxValue8
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax9
		,tblCFImportTransactionStagingTable.dblTaxValue9
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	INSERT INTO tblCFImportTransactionCFNTaxDetailStagingTable
	(
		 intRecordId
		,strTaxCode
		,dblTaxValue
		,strGUID
	)
	SELECT
		tblCFImportTransactionStagingTable.intRowId
		,tblCFImportTransactionStagingTable.strTax10
		,tblCFImportTransactionStagingTable.dblTaxValue10
		,strGUID
	FROM tblCFImportTransactionStagingTable
	WHERE tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	AND strGUID = @strGUID 

	--TEMPORARY--
	--UPDATE tblCFImportTransactionStagingTable
	--SET
	--	 tblCFImportTransactionStagingTable.dblTaxValue1	 = (SELECT TOP 1 dblTaxValue1  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax1  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue2	 = (SELECT TOP 1 dblTaxValue2  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax2  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue3	 = (SELECT TOP 1 dblTaxValue3  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax3  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue4	 = (SELECT TOP 1 dblTaxValue4  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax4  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue5	 = (SELECT TOP 1 dblTaxValue5  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax5  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue6	 = (SELECT TOP 1 dblTaxValue6  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax6  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue7	 = (SELECT TOP 1 dblTaxValue7  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax7  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue8	 = (SELECT TOP 1 dblTaxValue8  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax8  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue9	 = (SELECT TOP 1 dblTaxValue9  = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax9  COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--	,tblCFImportTransactionStagingTable.dblTaxValue10	 = (SELECT TOP 1 dblTaxValue10 = (SUM(ISNULL(dblTaxValue,0))) FROM tblCFImportTransactionCFNTaxDetailStagingTable WHERE tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId AND strTaxCode COLLATE Latin1_General_CI_AS = strTax10 COLLATE Latin1_General_CI_AS GROUP BY strTaxCode)
	--FROM tblCFImportTransactionStagingTable
	--WHERE intRowId = intRowId
	--AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN' 
	--AND tblCFImportTransactionStagingTable.dblQuantity != 0
	


	
	/*
	IF (@strNetworkType != 'CFN' AND @strNetworkType != 'Wright Express')
	BEGIN
		IF(@dblOriginalGrossPrice < 0)
		BEGIN
			SET @dblOriginalGrossPrice = ABS(@dblOriginalGrossPrice)
			IF(ISNULL(@dblQuantity,0) > 0)
			BEGIN
				SET @dblQuantity = (@dblQuantity * -1)
			END
		END
	END
	*/




	
	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.dblOriginalGrossPrice	 = ABS(tblCFImportTransactionStagingTable.dblOriginalGrossPrice)
		,tblCFImportTransactionStagingTable.dblQuantity	 = CASE 
															WHEN tblCFImportTransactionStagingTable.dblQuantity > 0 
															THEN (tblCFImportTransactionStagingTable.dblQuantity * -1)
															ELSE tblCFImportTransactionStagingTable.dblQuantity
														   END
		FROM tblCFImportTransactionStagingTable
	WHERE intRowId = intRowId
	AND tblCFImportTransactionStagingTable.strNetworkType != 'CFN' AND tblCFImportTransactionStagingTable.strNetworkType != 'Wright Express'
	AND tblCFImportTransactionStagingTable.dblOriginalGrossPrice < 0
	AND strGUID = @strGUID





	
	/*
	DECLARE @ysnCreateSite BIT 
	DECLARE @strAllowExemptionsOnExtAndRetailTrans NVARCHAR(MAX)


	---------------------------------------------------------
	----				    DEFAULT			   			 ----
	---------------------------------------------------------

	SELECT TOP 1 
	@strAllowExemptionsOnExtAndRetailTrans = strAllowExemptionsOnExtAndRetailTrans
	FROM tblCFNetwork
	WHERE intNetworkId = @intNetworkId
	*/

	UPDATE tblCFImportTransactionStagingTable
	SET
		 tblCFImportTransactionStagingTable.strAllowExemptionsOnExtAndRetailTrans = tblCFNetwork.strAllowExemptionsOnExtAndRetailTrans
	FROM tblCFNetwork
	WHERE tblCFNetwork.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND strGUID = @strGUID


	/**********************************
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
	***********************************/


	
			
	DELETE FROM @tblCFSiteToCreate 
	INSERT INTO @tblCFSiteToCreate
	(
		 strSiteId			
		,intNetworkId		
	)
	SELECT 
		 strSiteId			
		,intNetworkId	
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND (tblCFImportTransactionStagingTable.strPPSiteType = 'N' OR tblCFImportTransactionStagingTable.strPPSiteType = 'R')
	AND tblCFImportTransactionStagingTable.strNetworkType = 'PacPride'
	AND strGUID = @strGUID
	GROUP BY 
		 strSiteId			
		,intNetworkId		

	UPDATE @tblCFSiteToCreate
	SET intRowId = (SELECT TOP 1 intRowId 
					FROM tblCFImportTransactionStagingTable 
					WHERE strSiteId			=  [@tblCFSiteToCreate].strSiteId		
					AND intNetworkId		=  [@tblCFSiteToCreate].intNetworkId
					)


	IF(SELECT COUNT(1) FROM @tblCFSiteToCreate) > 0 
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
			intNetworkId			= tblCFImportTransactionStagingTable.intNetworkId
			,strSiteNumber			= tblCFImportTransactionStagingTable.strSiteId
			,strSiteName			= tblCFImportTransactionStagingTable.strSiteId -- default site name to site number
			,strDeliveryPickup		= 'Pickup'
			,intARLocationId		= tblCFImportTransactionStagingTable.intNetworkLocation
			,strControllerType		= (CASE strNetworkType 
										WHEN 'PacPride' 
											THEN 'PacPride'
										ELSE 'CFN'
										END)
			,strTaxState			= tblCFImportTransactionStagingTable.strSiteState
			,strSiteAddress			= tblCFImportTransactionStagingTable.strSiteAddress	
			,strSiteCity			= tblCFImportTransactionStagingTable.strSiteCity	
			,intPPHostId			= tblCFImportTransactionStagingTable.intSellingHost	
			,strPPSiteType			= (CASE tblCFImportTransactionStagingTable.strPPSiteType 
										WHEN 'N' 
											THEN 'Network'
										WHEN 'X' 
											THEN 'Exclusive'
										WHEN 'R' 
											THEN 'Retail'
										END)	
			,strSiteType			= (CASE tblCFImportTransactionStagingTable.strPPSiteType 
										WHEN 'N' 
											THEN 'Remote'
										WHEN 'R' 
											THEN 'Extended Remote'
										END)
			,strAllowExemptionsOnExtAndRetailTrans = tblCFImportTransactionStagingTable.strAllowExemptionsOnExtAndRetailTrans
		FROM tblCFImportTransactionStagingTable
		INNER JOIN @tblCFSiteToCreate
		ON [@tblCFSiteToCreate].intRowId = tblCFImportTransactionStagingTable.intRowId
	END

	/*********************************
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
	*********************************/



	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.intTaxGroupByState = tblCFNetworkSiteTaxGroup.intTaxGroupId
	FROM tblCFNetworkSiteTaxGroup
	WHERE tblCFNetworkSiteTaxGroup.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId AND tblCFNetworkSiteTaxGroup.strState COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strSiteState COLLATE Latin1_General_CI_AS
	AND tblCFImportTransactionStagingTable.intTaxGroupByState IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupByState = 0
	AND (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Voyager'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.intTaxGroupByState = tblCFNetworkSiteTaxGroup.intTaxGroupId
	FROM tblCFNetworkSiteTaxGroup
	WHERE tblCFNetworkSiteTaxGroup.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId AND (tblCFNetworkSiteTaxGroup.strState IS NULL OR tblCFNetworkSiteTaxGroup.strState = '')
	AND (tblCFImportTransactionStagingTable.intTaxGroupByState IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupByState = 0)
	AND (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Voyager'
	AND strGUID = @strGUID



	DELETE FROM @tblCFSiteToCreate 
	INSERT INTO @tblCFSiteToCreate
	(
		 strSiteId			
		,intNetworkId		
	)
	SELECT 
		 strSiteId			
		,intNetworkId	
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Voyager'
	AND strGUID = @strGUID
	GROUP BY 
		 strSiteId			
		,intNetworkId		

	UPDATE @tblCFSiteToCreate
	SET intRowId = (SELECT TOP 1 intRowId 
					FROM tblCFImportTransactionStagingTable 
					WHERE strSiteId			=  [@tblCFSiteToCreate].strSiteId		
					AND intNetworkId		=  [@tblCFSiteToCreate].intNetworkId
					)


	IF(SELECT COUNT(1) FROM @tblCFSiteToCreate) > 0 
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
			,strSiteType
			,intTaxGroupId
			,strAllowExemptionsOnExtAndRetailTrans

		)
		SELECT
			intNetworkId							= tblCFImportTransactionStagingTable.intNetworkId
			,strSiteNumber							= tblCFImportTransactionStagingTable.strSiteId
			,strSiteName							= tblCFImportTransactionStagingTable.strSiteName
			,strDeliveryPickup						= 'Pickup'
			,intARLocationId						= tblCFImportTransactionStagingTable.intNetworkLocation
			,strControllerType						= 'Voyager'
			,strTaxState							= tblCFImportTransactionStagingTable.strSiteState
			,strSiteAddress							= tblCFImportTransactionStagingTable.strSiteAddress	
			,strSiteCity							= tblCFImportTransactionStagingTable.strSiteCity	
			,strSiteType							= 'Extended Remote'
			,intTaxGroupId							= tblCFImportTransactionStagingTable.intTaxGroupByState
			,strAllowExemptionsOnExtAndRetailTrans	= tblCFImportTransactionStagingTable.strAllowExemptionsOnExtAndRetailTrans
		FROM tblCFImportTransactionStagingTable
		INNER JOIN @tblCFSiteToCreate
		ON [@tblCFSiteToCreate].intRowId = tblCFImportTransactionStagingTable.intRowId

	END



	/***********************
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
	************************/

	
	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.strSiteState = strPostalCode
	FROM tblCFStateCode
	WHERE strStateName COLLATE Latin1_General_CI_AS= tblCFImportTransactionStagingTable.strSiteTaxLocation COLLATE Latin1_General_CI_AS
	AND (tblCFImportTransactionStagingTable.intTaxGroupByState IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupByState = 0)
	AND (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND strGUID = @strGUID

	DELETE FROM @tblCFSiteToCreate 
	INSERT INTO @tblCFSiteToCreate
	(
		 strSiteId			
		,intNetworkId		
	)
	SELECT 
		 strSiteId			
		,intNetworkId	
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'CFN'
	AND strGUID = @strGUID
	GROUP BY 
		 strSiteId			
		,intNetworkId		

	UPDATE @tblCFSiteToCreate
	SET intRowId = (SELECT TOP 1 intRowId 
					FROM tblCFImportTransactionStagingTable 
					WHERE strSiteId			=  [@tblCFSiteToCreate].strSiteId		
					AND intNetworkId		=  [@tblCFSiteToCreate].intNetworkId
					)


	IF(SELECT COUNT(1) FROM @tblCFSiteToCreate) > 0 
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
			,strSiteType
			,intTaxGroupId
			,strAllowExemptionsOnExtAndRetailTrans
		)
		SELECT
			intNetworkId							= tblCFImportTransactionStagingTable.intNetworkId
			,strSiteNumber							= tblCFImportTransactionStagingTable.strSiteId
			,strSiteName							= tblCFImportTransactionStagingTable.strSiteName
			,strDeliveryPickup						= 'Pickup'
			,intARLocationId						= tblCFImportTransactionStagingTable.intNetworkLocation
			,strControllerType						= 'CFN'
			,strTaxState							= tblCFImportTransactionStagingTable.strSiteState
			,strSiteAddress							= tblCFImportTransactionStagingTable.strSiteAddress	
			,strSiteCity							= tblCFImportTransactionStagingTable.strSiteCity	
			,strSiteType							= CASE tblCFImportTransactionStagingTable.strTransactionType 
														WHEN 'Foreign Sale' 
															THEN 'Local/Network'
														ELSE tblCFImportTransactionStagingTable.strTransactionType
													   END
			,intTaxGroupId							= tblCFImportTransactionStagingTable.intTaxGroupByState
			,strAllowExemptionsOnExtAndRetailTrans	= tblCFImportTransactionStagingTable.strAllowExemptionsOnExtAndRetailTrans
		FROM tblCFImportTransactionStagingTable
		INNER JOIN @tblCFSiteToCreate
		ON [@tblCFSiteToCreate].intRowId = tblCFImportTransactionStagingTable.intRowId

	END


	/*****************************************
	
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



	********************************/


	

	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.intTaxGroupByState = tblCFNetworkSiteTaxGroup.intTaxGroupId
	FROM tblCFNetworkSiteTaxGroup
	WHERE tblCFNetworkSiteTaxGroup.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId AND tblCFNetworkSiteTaxGroup.strState COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strSiteState COLLATE Latin1_General_CI_AS
	AND tblCFImportTransactionStagingTable.intTaxGroupByState IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupByState = 0
	AND (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Wright Express'
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.intTaxGroupByState = tblCFNetworkSiteTaxGroup.intTaxGroupId
	FROM tblCFNetworkSiteTaxGroup
	WHERE tblCFNetworkSiteTaxGroup.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId AND (tblCFNetworkSiteTaxGroup.strState IS NULL OR tblCFNetworkSiteTaxGroup.strState = '')
	AND (tblCFImportTransactionStagingTable.intTaxGroupByState IS NULL OR tblCFImportTransactionStagingTable.intTaxGroupByState = 0)
	AND (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Wright Express'
	AND strGUID = @strGUID


	DELETE FROM @tblCFSiteToCreate 
	INSERT INTO @tblCFSiteToCreate
	(
		 strSiteId			
		,intNetworkId		
	)
	SELECT 
		 strSiteId			
		,intNetworkId	
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NULL OR tblCFImportTransactionStagingTable.intSiteId = 0)
	AND (tblCFImportTransactionStagingTable.intNetworkId IS NOT NULL OR tblCFImportTransactionStagingTable.intNetworkId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Wright Express'
	AND strGUID = @strGUID
	GROUP BY 
		 strSiteId			
		,intNetworkId		

	UPDATE @tblCFSiteToCreate
	SET intRowId = (SELECT TOP 1 intRowId 
					FROM tblCFImportTransactionStagingTable 
					WHERE strSiteId			=  [@tblCFSiteToCreate].strSiteId		
					AND intNetworkId		=  [@tblCFSiteToCreate].intNetworkId
					)


	IF(SELECT COUNT(1) FROM @tblCFSiteToCreate) > 0 
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
			,strSiteType
			,intTaxGroupId
			,strAllowExemptionsOnExtAndRetailTrans
		)
		SELECT
			intNetworkId							= tblCFImportTransactionStagingTable.intNetworkId
			,strSiteNumber							= tblCFImportTransactionStagingTable.strSiteId
			,strSiteName							= tblCFImportTransactionStagingTable.strSiteName
			,strDeliveryPickup						= 'Pickup'
			,intARLocationId						= tblCFImportTransactionStagingTable.intNetworkLocation
			,strControllerType						= 'AutoGas'
			,strTaxState							= tblCFImportTransactionStagingTable.strSiteState
			,strSiteAddress							= tblCFImportTransactionStagingTable.strSiteAddress	
			,strSiteCity							= tblCFImportTransactionStagingTable.strSiteCity	
			,strSiteType							= 'Extended Remote'
			,intTaxGroupId							= tblCFImportTransactionStagingTable.intTaxGroupByState
			,strAllowExemptionsOnExtAndRetailTrans	= tblCFImportTransactionStagingTable.strAllowExemptionsOnExtAndRetailTrans
		FROM tblCFImportTransactionStagingTable
		INNER JOIN @tblCFSiteToCreate
		ON [@tblCFSiteToCreate].intRowId = tblCFImportTransactionStagingTable.intRowId

	END

	/************************
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

				-- IF(ISNULL(@strCardId,'') = '')
				-- BEGIN


					IF(ISNULL(@CardNumberForDualCard,'') != '')
					BEGIN
						SET @strCardId = @CardNumberForDualCard
					END
					ELSE
					BEGIN
						SET @strCardId = @VehicleNumberForDualCard
						SET @strVehicleId = null
					END

				-- END

				-- IF (ISNUMERIC(@strCardId) = 1)
				-- BEGIN
				-- 	IF (CONVERT(BIGINT, @strCardId) = 0)
				-- 	BEGIN
					--	IF(ISNULL(@CardNumberForDualCard,'') != '')
					--	BEGIN
					--		SET @strCardId = @CardNumberForDualCard
					--		-- SET @strVehicleId = null
					--	END
					--	ELSE
					--	BEGIN
					--		SET @strCardId = @strVehicleId
					--		SET @strVehicleId = null
					--	END
					---- END
				-- END
			END
		END
	END
	**********************************/

	IF(@ysnAssignSite = 0)
	BEGIN
		SET @ysnAssignSite =1 
		GOTO REASSIGNSITE
	END


	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.ysnPetrovendDualCard = tblCFSite.ysnPetrovendDualCard
	FROM tblCFSite
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NOT NULL OR tblCFImportTransactionStagingTable.intSiteId != 0)
	AND tblCFSite.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Non Network'
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.strCardId = CASE 
														WHEN (tblCFImportTransactionStagingTable.strCardNumberForDualCard IS NOT NULL OR tblCFImportTransactionStagingTable.strCardNumberForDualCard != '' )
														THEN strCardNumberForDualCard
														ELSE strVehicleNumberForDualCard
														END 
	,tblCFImportTransactionStagingTable.strVehicleId = CASE 
														WHEN (tblCFImportTransactionStagingTable.strCardNumberForDualCard IS NOT NULL OR tblCFImportTransactionStagingTable.strCardNumberForDualCard != '' )
														THEN strVehicleId
														ELSE NULL
														END 
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intSiteId IS NOT NULL OR tblCFImportTransactionStagingTable.intSiteId != 0)
	AND tblCFImportTransactionStagingTable.strNetworkType = 'Non Network'
	AND (tblCFImportTransactionStagingTable.ysnPetrovendDualCard IS NOT NULL OR tblCFImportTransactionStagingTable.ysnPetrovendDualCard != 0 )
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET intSiteId = tblCFSite.intSiteId
	FROM tblCFSite
	WHERE 
	tblCFImportTransactionStagingTable.intNetworkId		= tblCFSite.intNetworkId
	AND tblCFImportTransactionStagingTable.strSiteId		= tblCFSite.strSiteNumber
	AND tblCFImportTransactionStagingTable.strSiteId 		= tblCFSite.strSiteName
	AND strGUID = @strGUID

	


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCreditCard.intCardId
	,tblCFImportTransactionStagingTable.ysnMatched = tblCFCreditCard.intCreditCardId
	,tblCFImportTransactionStagingTable.ysnLocalCard= tblCFCreditCard.ysnLocalPrefix
	FROM tblCFCreditCard
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.intSiteId = tblCFCreditCard.intSiteId)
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFCreditCard.strPrefix = strCreditCard AND tblCFCreditCard.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strCreditCard = STUFF(tblCFImportTransactionStagingTable.strCreditCard, 4, 1, '*')
	FROM tblCFImportTransactionStagingTable
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCreditCard.intCardId
	,tblCFImportTransactionStagingTable.ysnMatched = tblCFCreditCard.intCreditCardId
	,tblCFImportTransactionStagingTable.ysnLocalCard= tblCFCreditCard.ysnLocalPrefix
	FROM tblCFCreditCard
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.intSiteId = tblCFCreditCard.intSiteId)
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFCreditCard.strPrefix = strCreditCard AND tblCFCreditCard.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strCreditCard = STUFF(tblCFImportTransactionStagingTable.strCreditCard, 3, 1, '*')
	FROM tblCFImportTransactionStagingTable
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCreditCard.intCardId
	,tblCFImportTransactionStagingTable.ysnMatched = tblCFCreditCard.intCreditCardId
	,tblCFImportTransactionStagingTable.ysnLocalCard= tblCFCreditCard.ysnLocalPrefix
	FROM tblCFCreditCard
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.intSiteId = tblCFCreditCard.intSiteId)
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFCreditCard.strPrefix = strCreditCard AND tblCFCreditCard.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strCreditCard = STUFF(tblCFImportTransactionStagingTable.strCreditCard, 2, 1, '*')
	FROM tblCFImportTransactionStagingTable
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCreditCard.intCardId
	,tblCFImportTransactionStagingTable.ysnMatched = tblCFCreditCard.intCreditCardId
	,tblCFImportTransactionStagingTable.ysnLocalCard= tblCFCreditCard.ysnLocalPrefix
	FROM tblCFCreditCard
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.intSiteId = tblCFCreditCard.intSiteId)
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFCreditCard.strPrefix = strCreditCard AND tblCFCreditCard.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strCreditCard = STUFF(tblCFImportTransactionStagingTable.strCreditCard, 1, 1, '*')
	FROM tblCFImportTransactionStagingTable
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFImportTransactionStagingTable.intRowId = tblCFImportTransactionStagingTable.intRowId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCreditCard.intCardId
	,tblCFImportTransactionStagingTable.ysnMatched = tblCFCreditCard.intCreditCardId
	,tblCFImportTransactionStagingTable.ysnLocalCard= tblCFCreditCard.ysnLocalPrefix
	FROM tblCFCreditCard
	WHERE ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.strCreditCard IS NOT NULL AND tblCFImportTransactionStagingTable.strCreditCard != '' )
	AND (tblCFImportTransactionStagingTable.intSiteId = tblCFCreditCard.intSiteId)
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND tblCFCreditCard.strPrefix = strCreditCard AND tblCFCreditCard.intSiteId = tblCFImportTransactionStagingTable.intSiteId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCard.intCardId
	,tblCFImportTransactionStagingTable.intCustomerId = tblCFAccount.intCustomerId
	FROM tblCFCard 
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE tblCFCard.strCardNumber = tblCFImportTransactionStagingTable.strCardId 
	AND ( ISNULL(tblCFCard.ysnActive,0) = 1  OR tblCFImportTransactionStagingTable.ysnPostedCSV = 1)
	AND ysnSiteAcceptCreditCard =  1
	AND (tblCFImportTransactionStagingTable.ysnMatched = 0 OR tblCFImportTransactionStagingTable.ysnMatched IS NULL)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND strGUID = @strGUID


	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCard.intCardId
	,tblCFImportTransactionStagingTable.intCustomerId = tblCFAccount.intCustomerId
	FROM tblCFCard 
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE tblCFCard.strCardNumber = tblCFImportTransactionStagingTable.strCardId 
	AND ( ISNULL(tblCFCard.ysnActive,0) = 1  OR tblCFImportTransactionStagingTable.ysnPostedCSV = 1)
	AND ysnSiteAcceptCreditCard =  1
	AND ysnLocalCard = 1
	AND strGUID = @strGUID


	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.ysnCreditCardUsed = 1
	,tblCFImportTransactionStagingTable.intCustomerId = tblCFAccount.intCustomerId
	FROM tblCFCard 
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE tblCFCard.strCardNumber = tblCFImportTransactionStagingTable.strCardId 
	AND ( ISNULL(tblCFCard.ysnActive,0) = 1  OR tblCFImportTransactionStagingTable.ysnPostedCSV = 1)
	AND ysnSiteAcceptCreditCard =  1
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = tblCFCard.intCardId
	,tblCFImportTransactionStagingTable.intCustomerId = tblCFAccount.intCustomerId
	FROM tblCFCard 
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE tblCFCard.strCardNumber = tblCFImportTransactionStagingTable.strCardId 
	AND ( ISNULL(tblCFCard.ysnActive,0) = 1  OR tblCFImportTransactionStagingTable.ysnPostedCSV = 1)
	AND (tblCFImportTransactionStagingTable.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL)
	AND strGUID = @strGUID



	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intCardId = NULL
	FROM tblCFImportTransactionStagingTable 
	WHERE strTransactionType = 'Foreign Sale' OR intCardId = 0 
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intAccountId = tblCFAccount.intAccountId
	,tblCFImportTransactionStagingTable.ysnVehicleRequire = tblCFAccount.ysnVehicleRequire
	FROM tblCFCard 
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE tblCFImportTransactionStagingTable.intCardId = tblCFCard.intCardId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intProductId = tblCFItem.intItemId
	,tblCFImportTransactionStagingTable.intARItemId = tblCFItem.intARItemId
	FROM tblCFItem 
	WHERE (tblCFImportTransactionStagingTable.intProductId = 0 OR tblCFImportTransactionStagingTable.intProductId IS NULL)
	AND tblCFItem.strProductNumber = tblCFImportTransactionStagingTable.strProductId
	AND tblCFItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND ( tblCFItem.intSiteId = tblCFImportTransactionStagingTable.intSiteId OR (tblCFItem.intSiteId = 0 OR tblCFItem.intSiteId IS NULL))
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intProductId = tblCFItem.intItemId
	,tblCFImportTransactionStagingTable.intARItemId = tblCFItem.intARItemId
	FROM tblCFItem 
	WHERE (tblCFImportTransactionStagingTable.intProductId = 0 OR tblCFImportTransactionStagingTable.intProductId IS NULL)
	AND tblCFItem.strProductNumber = RTRIM(LTRIM(tblCFImportTransactionStagingTable.strProductId))
	AND tblCFItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND ( tblCFItem.intSiteId = tblCFImportTransactionStagingTable.intSiteId OR (tblCFItem.intSiteId = 0 OR tblCFItem.intSiteId IS NULL))
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intProductId = tblCFItem.intItemId
	,tblCFImportTransactionStagingTable.intARItemId = tblCFItem.intARItemId
	FROM tblCFItem 
	WHERE (tblCFImportTransactionStagingTable.intProductId = 0 OR tblCFImportTransactionStagingTable.intProductId IS NULL)
	AND tblCFItem.strProductNumber = RTRIM(LTRIM(tblCFImportTransactionStagingTable.strProductId))
	AND tblCFItem.intNetworkId = tblCFImportTransactionStagingTable.intNetworkId
	AND ( tblCFItem.intSiteId = tblCFImportTransactionStagingTable.intSiteId OR (tblCFItem.intSiteId = 0 OR tblCFItem.intSiteId IS NULL))
	AND strGUID = @strGUID

	


	--IF(@intProductId = 0)
	--BEGIN

	--	IF(ISNUMERIC(RTRIM(LTRIM(@strProductId))) = 1)
	--	BEGIN

	--		SELECT * INTO #tempProduct FROM tblCFItem 
	--		WHERE intNetworkId = @intNetworkId
	--		AND (intSiteId = @intSiteId OR (intSiteId = 0 OR intSiteId IS NULL))
	--		AND ISNUMERIC(strProductNumber) = 1 

	--		SELECT TOP 1 
	--			@intProductId = intItemId
	--			,@intARItemId = intARItemId
	--		FROM #tempProduct 
	--		WHERE CAST( RTRIM(LTRIM(strProductNumber)) as INT) = CAST( RTRIM(LTRIM(@strProductId)) as INT)
	--		AND intNetworkId = @intNetworkId
	--		AND (intSiteId = @intSiteId OR (intSiteId = 0 OR intSiteId IS NULL))

	--		DROP TABLE #tempProduct

	--	END
	--END

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intARItemLocationId = tblCFSite.intARLocationId
	FROM tblCFSite 
	WHERE tblCFImportTransactionStagingTable.intSiteId = tblCFSite.intSiteId
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intDriverPinId = tblCFDriverPin.intDriverPinId
	FROM tblCFDriverPin 
	WHERE tblCFDriverPin.intAccountId = tblCFImportTransactionStagingTable.intAccountId
	AND tblCFImportTransactionStagingTable.strDriverPin != ''  
	AND tblCFImportTransactionStagingTable.strDriverPin != 0
	AND strGUID = @strGUID

	

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.ysnWriteDriverPinError = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE( intDriverPinId = 0 OR intDriverPinId IS NULL)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intDriverPinId = intDefaultDriverPin
	FROM tblCFCard 
	WHERE tblCFCard.intCardId = 0 OR tblCFImportTransactionStagingTable.intCardId IS NULL
	AND  (intDriverPinId = 0 OR intDriverPinId IS NULL)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.ysnConvertMiscToVehicle = tblCFAccount.ysnConvertMiscToVehicle
	FROM tblCFAccount 
	WHERE tblCFAccount.intAccountId = tblCFImportTransactionStagingTable.intAccountId 
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strPONumber = tblCFPurchaseOrder.strPurchaseOrderNo
	FROM tblCFPurchaseOrder 
	WHERE tblCFPurchaseOrder.intAccountId = tblCFImportTransactionStagingTable.intAccountId 
	AND (tblCFImportTransactionStagingTable.intAccountId != 0 OR tblCFImportTransactionStagingTable.intAccountId IS NOT NULL)
	AND strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strVehicleId = tblCFImportTransactionStagingTable.strMiscellaneous
	FROM tblCFImportTransactionStagingTable 
	WHERE (tblCFImportTransactionStagingTable.intAccountId != 0 OR tblCFImportTransactionStagingTable.intAccountId IS NOT NULL)
	AND ((tblCFImportTransactionStagingTable.strVehicleId = '0' OR  tblCFImportTransactionStagingTable.strVehicleId IS NULL OR ISNULL(tblCFImportTransactionStagingTable.intVehicleId,0) = 0) AND tblCFImportTransactionStagingTable.ysnConvertMiscToVehicle = 1)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.strVehicleId = tblCFImportTransactionStagingTable.strMiscellaneous
	FROM tblCFImportTransactionStagingTable 
	WHERE tblCFImportTransactionStagingTable.strVehicleId IS NOT NULL
	AND strGUID = @strGUID

	

	INSERT INTO tblCFImportTransactionNumericVehicleStagingTable(
		 intVehicleId			
		,strVehicleNumber
		,intAccountId
		,strGUID
	)	
	SELECT 
		 tblCFVehicle.intVehicleId			
		,tblCFVehicle.strVehicleNumber	
		,tblCFVehicle.intAccountId		
		,@strGUID
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFVehicle 
	ON tblCFImportTransactionStagingTable.intAccountId = tblCFVehicle.intAccountId
	WHERE RTRIM(LTRIM(tblCFVehicle.strVehicleNumber)) not like '%[^0-9]%' and LTRIM(RTRIM(tblCFVehicle.strVehicleNumber)) != ''
	AND strGUID = @strGUID

	
	INSERT INTO tblCFImportTransactionStringVehicleStagingTable(
		 intVehicleId			
		,strVehicleNumber
		,intAccountId
		,strGUID
	)	
	SELECT 
		 tblCFVehicle.intVehicleId			
		,tblCFVehicle.strVehicleNumber	
		,tblCFVehicle.intAccountId		
		,@strGUID
	FROM tblCFImportTransactionStagingTable
	INNER JOIN tblCFVehicle 
	ON tblCFImportTransactionStagingTable.intAccountId = tblCFVehicle.intAccountId
	WHERE RTRIM(LTRIM(tblCFVehicle.strVehicleNumber)) like '%[^0-9]%' and RTRIM(LTRIM(tblCFVehicle.strVehicleNumber)) != ''
	AND strGUID = @strGUID
	

	--UPDATE tblCFImportTransactionStagingTable
	--SET tblCFImportTransactionStagingTable.intVehicleId = CASE 
	--														WHEN ISNUMERIC(tblCFImportTransactionStagingTable.strVehicleId) = 1
	--														THEN (SELECT TOP 1 intVehicleId FROM tblCFImportTransactionNumericVehicleStagingTable WHERE strGUID = @strGUID AND LTRIM(RTRIM(strVehicleNumber)) = tblCFImportTransactionStagingTable.strNumericVehicleNumber) 
	--														WHEN ISNUMERIC(tblCFImportTransactionStagingTable.strVehicleId) = 0
	--														THEN (SELECT TOP 1 intVehicleId FROM tblCFImportTransactionStringVehicleStagingTable WHERE strGUID = @strGUID AND strVehicleNumber COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strTrimedVehicleNumber) 
	--														ELSE NULL
	--													  END
	--FROM tblCFImportTransactionStagingTable
	--WHERE (tblCFImportTransactionStagingTable.intAccountId != 0 OR tblCFImportTransactionStagingTable.intAccountId IS NOT NULL)
	--AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.intVehicleId = CASE 
															WHEN  ISNULL(ysnNumericVehicle,0) = 1
															THEN (SELECT TOP 1 intVehicleId FROM tblCFImportTransactionNumericVehicleStagingTable WHERE strGUID = @strGUID AND LTRIM(RTRIM(strVehicleNumber)) = tblCFImportTransactionStagingTable.strNumericVehicleNumber) 
															WHEN  ISNULL(ysnNumericVehicle,0) = 0
															THEN (SELECT TOP 1 intVehicleId FROM tblCFImportTransactionStringVehicleStagingTable WHERE strGUID = @strGUID AND strVehicleNumber COLLATE Latin1_General_CI_AS = tblCFImportTransactionStagingTable.strTrimedVehicleNumber) 
															ELSE NULL
														  END
	FROM tblCFImportTransactionStagingTable
	WHERE (tblCFImportTransactionStagingTable.intAccountId != 0 OR tblCFImportTransactionStagingTable.intAccountId IS NOT NULL)
	AND strGUID = @strGUID




	--UPDATE tblCFImportTransactionStagingTable
	--SET 
	-- tblCFImportTransactionStagingTable.ysnIgnoreVehicleError = (CASE 
	--																 WHEN ISNUMERIC(tblCFImportTransactionStagingTable.strVehicleId) = 1
	--																 THEN (CASE WHEN CAST(LTRIM(RTRIM(strVehicleNumber)) AS BIGINT) = 0 THEN 1 END)
	--																 WHEN LTRIM(RTRIM(ISNULL(strVehicleNumber,''))) = '' THEN 1
	--																 ELSE 0
	--															END)
	--FROM tblCFImportTransactionStagingTable 
	--WHERE strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.ysnIgnoreVehicleError = (CASE 
																	 WHEN ISNULL(ysnNumericVehicle,0) = 1
																		THEN (CASE WHEN strNumericVehicleNumber = 0 THEN 1 END)
																	 WHEN ISNULL(strTrimedVehicleNumber,'') = '' THEN 1
																		ELSE 0
																END)
	FROM tblCFImportTransactionStagingTable 
	WHERE strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	 tblCFImportTransactionStagingTable.intVehicleId = intDefaultFixVehicleNumber
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFCard
	ON tblCFCard.intCardId = tblCFImportTransactionStagingTable.intCardId
	WHERE (intVehicleId = 0 OR intVehicleId IS NULL)
	AND (ysnVehicleRequire = 0 OR ysnVehicleRequire IS NULL)
	AND strGUID = @strGUID

	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.ysnOnHold = ISNULL(ysnIgnoreCardTransaction,0) 
	 ,tblCFImportTransactionStagingTable.intCardTypeId = tblCFCard.intCardTypeId
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFCard
	ON tblCFCard.intCardId = tblCFImportTransactionStagingTable.intCardId
	WHERE strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.ysnDualCard = ISNULL(tblCFCardType.ysnDualCard,0) 
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFCardType
	ON tblCFCardType.intCardTypeId = tblCFImportTransactionStagingTable.intCardTypeId
	WHERE strGUID = @strGUID

	--------------
	--VALIDATION--
	--------------
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intPrcCustomerId = ISNULL(tblCFAccount.intCustomerId,0) 
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFCard 
	ON tblCFCard.intCardId = tblCFImportTransactionStagingTable.intCardId
	INNER JOIN tblCFAccount 
	ON tblCFCard.intAccountId = tblCFAccount.intAccountId
	WHERE strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intPrcItemUOMId = ISNULL(tblICItemLocation.intIssueUOMId,0) 
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblICItemLocation 
	ON tblICItemLocation.intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId 
	AND tblICItemLocation.intItemId = tblCFImportTransactionStagingTable.intARItemId
	WHERE strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intPrcItemUOMId = ISNULL(tblICItemLocation.intIssueUOMId,0) 
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblICItemLocation 
	ON tblICItemLocation.intLocationId = tblCFImportTransactionStagingTable.intARItemLocationId 
	AND tblICItemLocation.intItemId = tblCFImportTransactionStagingTable.intARItemId
	WHERE strGUID = @strGUID


	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.ysnInvalid = 1 
	FROM tblCFImportTransactionStagingTable 
	WHERE (intARItemId = 0 OR intARItemId IS NULL)
	OR ((intPrcCustomerId = 0 OR intPrcCustomerId IS NULL) AND strTransactionType != 'Foreign Sale')
	OR (intARItemLocationId = 0 OR intARItemLocationId IS NULL)
	OR (intPrcItemUOMId = 0 OR intPrcItemUOMId IS NULL)
	OR (intNetworkId = 0 OR intNetworkId IS NULL)
	OR (intSiteId = 0 OR intSiteId IS NULL)
	OR ((intCardId = 0 OR intCardId IS NULL) AND strTransactionType != 'Foreign Sale')
	OR (dblQuantity = 0 OR dblQuantity IS NULL)
	AND strGUID = @strGUID
	

	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intNetworkId = NULL
	FROM tblCFImportTransactionStagingTable 
	WHERE (intNetworkId = 0 OR intNetworkId IS NULL)
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intSiteId = NULL
	FROM tblCFImportTransactionStagingTable 
	WHERE (intSiteId = 0 OR intSiteId IS NULL)
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intCardId = NULL
	FROM tblCFImportTransactionStagingTable 
	WHERE (intCardId = 0 OR intCardId IS NULL)
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.ysnInvalid = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE  ((intVehicleId = 0 OR intVehicleId IS NULL) AND strTransactionType != 'Foreign Sale')
	AND (ISNULL(ysnVehicleRequire,0) = 1 AND (ISNULL(ysnDualCard,0) = 1 OR ISNULL(intCardTypeId,0) = 0))
	AND strGUID = @strGUID

	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.ysnInvalid = 1
	FROM tblCFImportTransactionStagingTable 
	WHERE  ((intVehicleId = 0 OR intVehicleId IS NULL) AND strTransactionType != 'Foreign Sale')
	AND ISNULL(ysnIgnoreVehicleError,0) = 0
	AND strGUID = @strGUID
	
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.intVehicleId = NULL
	FROM tblCFImportTransactionStagingTable 
	WHERE (intVehicleId = 0 OR intVehicleId IS NULL)
	AND strGUID = @strGUID

		
	UPDATE tblCFImportTransactionStagingTable
	SET 
	  tblCFImportTransactionStagingTable.strPostedDate = (CASE WHEN (DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, strLaggingDate), 0))
															   THEN strPostedDate
															   ELSE dtmTransactionDate
														  END)
	FROM tblCFImportTransactionStagingTable 
	WHERE strGUID = @strGUID

	-------------------
	--CHECK DUPLICATE--
	-------------------
	UPDATE tblCFImportTransactionStagingTable
	SET tblCFImportTransactionStagingTable.ysnDuplicate = 1
	FROM tblCFImportTransactionStagingTable 
	INNER JOIN tblCFTransaction
	ON  tblCFTransaction.intNetworkId =			tblCFImportTransactionStagingTable.intNetworkId
	AND tblCFTransaction.intSiteId =			tblCFImportTransactionStagingTable.intSiteId
	AND tblCFTransaction.dtmTransactionDate =	tblCFImportTransactionStagingTable.dtmTransactionDate
	AND tblCFTransaction.intCardId =			tblCFImportTransactionStagingTable.intCardId
	AND tblCFTransaction.intProductId =			tblCFImportTransactionStagingTable.intProductId
	AND tblCFTransaction.intPumpNumber =		tblCFImportTransactionStagingTable.intPumpNumber
	WHERE strGUID = @strGUID

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
			,[strTransactionId]
			,[strImportInstanceId]
			,[intImportInstanceId]
			,intUserId
		)
		--OUTPUT INSERTED.intTransactionId INTO tblCFImportTransactionInsertedRecorsStagingTable
		SELECT 
			 intSiteId				
			,intCardId			
			,intVehicleId			
			,intProductId 	
			,intNetworkId
			,intARItemId --intARItemId
			,intARItemLocationId --intARItemLocationId			
			--,@intContractId			
			,dblQuantity				
			,dtmBillingDate		
			,strPostedDate	
			,strCreatedDate
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
			,dblOriginalTotalPrice	
			,dblCalculatedTotalPrice	
			,dblOriginalGrossPrice	
			,dblCalculatedGrossPrice	
			,dblCalculatedNetPrice	
			,dblOriginalNetPrice	
			,dblCalculatedPumpPrice	
			,dblOriginalPumpPrice	
			,intSalesPersonId
			,ysnPosted
			,ysnInvalid--ysnInvalid
			,ysnCreditCardUsed --ysnCreditCardUsed		
			,ysnOriginHistory
			,ysnPostedCSV  
			,strCardId
			,ysnDuplicate --ysnDuplicate
			,strProductId
			,NULL --intOverFilledTransactionId
			,dtmInvoiceDate
			,strInvoiceReportNumber
			,ysnOnHold
			,intCustomerId
			,intCardId
			,intDriverPinId
			,ysnInvoiced
			,intRowId
			,strGUID
			,intRowId
			,intUserId
		FROM tblCFImportTransactionStagingTable	
		WHERE strGUID = @strGUID


		UPDATE tblCFImportTransactionStagingTable
		SET tblCFImportTransactionStagingTable.intTransactionId  =  tblCFTransaction.intTransactionId
		FROM tblCFTransaction 
		WHERE tblCFTransaction.[strImportInstanceId] = tblCFImportTransactionStagingTable.strGUID
		AND tblCFTransaction.[intImportInstanceId] = tblCFImportTransactionStagingTable.intRowId
		AND strGUID = @strGUID

		--------
		--LOGS--
		--------

		DECLARE @dtmProcessDate DATETIME = GETDATE()

		UPDATE tblCFImportTransactionStagingTable
		SET dtmProcessDate = @dtmProcessDate
		WHERE tblCFImportTransactionStagingTable.strGUID = @strGUID
		AND strGUID = @strGUID
		
		
		--*

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId,'Unable to find driver pin number ' + strDriverPin + ' into i21 driver pin list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(ysnWriteDriverPinError,0) = 1
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,'Unable to find driver pin number ' + strDriverPin + ' into i21 driver pin list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(ysnWriteDriverPinError,0) = 1
		AND strGUID = @strGUID
		

		--*

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Unable to find product number ' + strProductId + ' into i21 item list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intARItemId,0) = 0
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,'Unable to find product number ' + strProductId + ' into i21 item list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intARItemId,0) = 0
		AND strGUID = @strGUID

		--*

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Unable to find customer number using card number ' + strCardId + ' into i21 card account list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intPrcCustomerId,0) = 0 AND strTransactionType != 'Foreign Sale'
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,'Unable to find customer number using card number ' + strCardId + ' into i21 card account list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intPrcCustomerId,0) = 0 AND strTransactionType != 'Foreign Sale'
		AND strGUID = @strGUID

		--*
		
		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Invalid location for site ' + strSiteId
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intARItemLocationId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,'Invalid location for site ' + strSiteId
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intARItemLocationId,0) = 0)
		AND strGUID = @strGUID

		--*

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Invalid UOM for product number ' + strProductId
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intPrcItemUOMId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,'Invalid UOM for product number ' + strProductId
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intPrcItemUOMId,0) = 0)
		AND strGUID = @strGUID

		--*
		
		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId,  'Unable to find network ' + strNetworkId + ' into i21 network list'
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intNetworkId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId, 'Unable to find network ' + strNetworkId + ' into i21 network list'
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intNetworkId,0) = 0)
		AND strGUID = @strGUID

		--*
		
		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId,   'Unable to find site ' + strSiteId + ' into i21 site list'
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intSiteId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,  'Unable to find site ' + strSiteId + ' into i21 site list'
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intSiteId,0) = 0)
		AND strGUID = @strGUID

		--*
		
		--INSERT INTO tblCFTransactionNote 
		--(strProcess,dtmProcessDate,strGUID,intTransactionId,strNote)
		--SELECT 
		--'Import',@dtmProcessDate,@strGUID,intTransactionId,  'Site ' + strSiteId + ' has been automatically created'
		--FROM tblCFImportTransactionStagingTable
		--WHERE (ISNULL(intSiteId,0) = 0)

		--INSERT INTO tblCFFailedImportedTransaction 
		--(intTransactionId,strFailedReason)
		--SELECT 
		--intTransactionId,  'Site ' + strSiteId + ' has been automatically created'
		--FROM tblCFImportTransactionStagingTable
		--WHERE (ISNULL(ysnSiteCreated,0) != 0)

		--*

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId,  'Unable to find card number ' + strCardId + ' into i21 card list'
		FROM tblCFImportTransactionStagingTable
		WHERE(ISNULL(intCardId,0) = 0) AND strTransactionType != 'Foreign Sale'
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,  'Unable to find card number ' + strCardId + ' into i21 card list'
		FROM tblCFImportTransactionStagingTable
		WHERE (ISNULL(intCardId,0) = 0) AND strTransactionType != 'Foreign Sale'
		AND strGUID = @strGUID

		--*
		
		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId,  'Invalid quantity - ' + Str(dblQuantity, 16, 8)
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(dblQuantity,0) = 0
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId,  'Invalid quantity - ' + Str(dblQuantity, 16, 8)
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(dblQuantity,0) = 0
		AND strGUID = @strGUID

		--*

		INSERT INTO tblCFTransactionPrice
		(
			 intTransactionId
			,strTransactionPriceId
			,dblOriginalAmount
			,dblCalculatedAmount
		)
		SELECT 
			 intTransactionId
			,'Gross Price'
			,dblOriginalGrossPrice
			,0.0
		FROM
		tblCFImportTransactionStagingTable
		WHERE strGUID = @strGUID

		INSERT INTO tblCFTransactionPrice
		(
			 intTransactionId
			,strTransactionPriceId
			,dblOriginalAmount
			,dblCalculatedAmount
		)
		SELECT 
			 intTransactionId
			,'Net Price'
			,0.0
			,0.0
		FROM
		tblCFImportTransactionStagingTable
		WHERE strGUID = @strGUID

		INSERT INTO tblCFTransactionPrice
		(
			 intTransactionId
			,strTransactionPriceId
			,dblOriginalAmount
			,dblCalculatedAmount
		)
		SELECT 
			 intTransactionId
			,'Total Amount'
			,0.0
			,0.0
		FROM
		tblCFImportTransactionStagingTable
		WHERE strGUID = @strGUID


		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Vehicle is required.'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intVehicleId,0) = 0 AND strTransactionType != 'Foreign Sale'
		AND ISNULL(ysnVehicleRequire,0) = 1 AND (ISNULL(ysnDualCard,0) = 1 OR ISNULL(intCardTypeId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId, 'Vehicle is required.'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intVehicleId,0) = 0 AND strTransactionType != 'Foreign Sale'
		AND ISNULL(ysnVehicleRequire,0) = 1 AND (ISNULL(ysnDualCard,0) = 1 OR ISNULL(intCardTypeId,0) = 0)
		AND strGUID = @strGUID

		INSERT INTO tblCFTransactionNote 
		(strProcess,dtmProcessDate,strGuid,intTransactionId,strNote)
		SELECT 
		'Import',@dtmProcessDate,@strGUID,intTransactionId, 'Unable to find vehicle number '+ strVehicleId +' into i21 vehicle list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intVehicleId,0) = 0 
		AND strTransactionType != 'Foreign Sale'
		AND ISNULL(ysnIgnoreVehicleError,0) = 0
		AND strGUID = @strGUID

		INSERT INTO tblCFFailedImportedTransaction 
		(intTransactionId,strFailedReason)
		SELECT 
		intTransactionId, 'Unable to find vehicle number '+ strVehicleId +' into i21 vehicle list'
		FROM tblCFImportTransactionStagingTable
		WHERE ISNULL(intVehicleId,0) = 0 
		AND strTransactionType != 'Foreign Sale'
		AND ISNULL(ysnIgnoreVehicleError,0) = 0
		AND strGUID = @strGUID


		UPDATE tblCFImportTransactionStagingTable SET ysnInvalid = 1
		WHERE ISNULL(intVehicleId,0) = 0 
		AND strTransactionType != 'Foreign Sale'
		AND ISNULL(ysnIgnoreVehicleError,0) = 0  
		AND strGUID = @strGUID


		EXEC [uspCFCalculateTransaction]
		 @strGUID						=@strGUID
		,@intUserId						=@intUserId				
		,@dtmProcessDate				=@dtmProcessDate
		,@IsImporting					=1


		--select  *from tblCFImportTransactionTaxType

		--DECLARE @dblGrossTransferCost		NUMERIC(18,6)	
		--DECLARE @dblNetTransferCost		NUMERIC(18,6)	

		------------------------------------------------------------
		--			UPDATE TRANSACTION DEPENDS ON PRICING		  --
		------------------------------------------------------------
		--SELECT
		-- @dblPrcPriceOut				= dblPrice
		--,@strPrcPricingOut				= strPriceMethod
		--,@intPrcAvailableQuantity		= dblAvailableQuantity
		--,@dblPrcOriginalPrice			= dblOriginalPrice
		--,@intPrcContractHeaderId		= intContractHeaderId
		--,@intPrcContractDetailId		= intContractDetailId
		--,@intPrcContractNumber			= strContractNumber
		--,@intPrcContractSeq				= intContractSeq
		--,@intPrcItemContractHeaderId	= intItemContractHeaderId
		--,@intPrcItemContractDetailId	= intItemContractDetailId
		--,@intPrcItemContractNumber		= strItemContractNumber
		--,@intPrcItemContractSeq			= intItemContractSeq
		--,@strPrcPriceBasis				= strPriceBasis
		--,@strPriceMethod   				= strPriceMethod
		--,@strPriceBasis 				= strPriceBasis
		--,@intContractId	 				= intContractDetailId
		--,@dblCalcOverfillQuantity 		= 0
		--,@dblCalcQuantity 				= 0
		--,@intPriceProfileId 			= intPriceProfileId 	
		--,@intPriceIndexId				= intPriceIndexId	
		--,@intSiteGroupId				= intSiteGroupId		
		--,@strPriceProfileId				= strPriceProfileId	
		--,@strPriceIndexId				= strPriceIndexId	
		--,@strSiteGroup					= strSiteGroup		
		--,@dblPriceProfileRate			= dblPriceProfileRate
		--,@dblPriceIndexRate				= dblPriceIndexRate	
		--,@dtmPriceIndexDate				= dtmPriceIndexDate	
		--,@ysnDuplicate					= ysnDuplicate
		--,@ysnRecalculateInvalid			= ysnInvalid
		--,@dblInventoryCost				= dblInventoryCost
		--,@dblMargin						= dblMargin
		--,@dblGrossTransferCost			= dblGrossTransferCost
		--,@dblNetTransferCost			= dblNetTransferCost
		--,@dblAdjustmentRate				= dblAdjustmentRate
		--,@ysnExpensed					= ysnExpensed
		--,@intExpensedItemId				= intExpensedItemId
		--FROM tblCFTransactionPricingType

		
		UPDATE tblCFTransaction 
		SET 
			ysnExpensed = tblCFImportTransactionStagingTable.ysnExpensed
			,intExpensedItemId = tblCFImportTransactionStagingTable.intExpensedItemId
		FROM tblCFImportTransactionStagingTable
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
		AND strGUID = @strGUID


		UPDATE tblCFTransaction 
		SET 
			ysnInvalid = 1
		FROM tblCFImportTransactionStagingTable
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionStagingTable.intTransactionId
		AND strGUID = @strGUID
		AND tblCFImportTransactionStagingTable.ysnInvalid = 1


		UPDATE tblCFTransaction
		SET intContractId			= null 
			,strPriceBasis			= null
			,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
			,dblMargin				= tblCFImportTransactionPricingType.dblMargin
			,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
			,intPriceProfileId 		= null
			,intPriceIndexId		= null
			,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId
			,strPriceProfileId		= ''
			,strPriceIndexId		= ''
			,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup
			,dblPriceProfileRate	= null
			,dblPriceIndexRate		= null
			,dtmPriceIndexDate		= null
			,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
			,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
			,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
			,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
			,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Inventory - Standard Pricing'
		AND strGUID = @strGUID
		


		UPDATE tblCFTransaction
				SET 
				 intContractId = null 
				,strPriceBasis = null
				,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
				,dblMargin				= tblCFImportTransactionPricingType.dblMargin
				,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
				,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
				,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
				,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
				,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Import File Price'
		AND strGUID = @strGUID


		UPDATE tblCFTransaction
		SET intContractId			= null 
			,strPriceBasis			= null
			,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
			,dblMargin				= tblCFImportTransactionPricingType.dblMargin
			,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
			,intPriceProfileId 		= null
			,intPriceIndexId		= null
			,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId
			,strPriceProfileId		= ''
			,strPriceIndexId		= ''
			,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup
			,dblPriceProfileRate	= null
			,dblPriceIndexRate		= null
			,dtmPriceIndexDate		= null
			,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
			,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
			,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
			,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
			,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Network Cost'
		AND strGUID = @strGUID

		UPDATE tblCFTransaction
			SET  intContractId = null 
				,strPriceBasis = null
				,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
				,dblMargin				= tblCFImportTransactionPricingType.dblMargin
				,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
				,intPriceProfileId 		= null
				,intPriceIndexId		= null
				,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId
				,strPriceProfileId		= ''
				,strPriceIndexId		= ''
				,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup
				,dblPriceProfileRate	= null
				,dblPriceIndexRate		= null
				,dtmPriceIndexDate		= null
				,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
				,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
				,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
				,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
				,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Special Pricing'
		AND strGUID = @strGUID


		UPDATE tblCFTransaction
			SET intContractId = null 
				,strPriceBasis			= tblCFImportTransactionPricingType.strPriceBasis
				,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
				,dblMargin				= tblCFImportTransactionPricingType.dblMargin
				,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
				,intPriceProfileId 		= tblCFImportTransactionPricingType.intPriceProfileId 	
				,intPriceIndexId		= tblCFImportTransactionPricingType.intPriceIndexId	
				,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId		
				,strPriceProfileId		= tblCFImportTransactionPricingType.strPriceProfileId	
				,strPriceIndexId		= tblCFImportTransactionPricingType.strPriceIndexId	
				,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup		
				,dblPriceProfileRate	= tblCFImportTransactionPricingType.dblPriceProfileRate
				,dblPriceIndexRate		= tblCFImportTransactionPricingType.dblPriceIndexRate	
				,dtmPriceIndexDate		= tblCFImportTransactionPricingType.dtmPriceIndexDate	
				,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
				,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
				,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
				,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
				,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Price Profile'
		AND strGUID = @strGUID


		UPDATE tblCFTransaction 
				SET strPriceBasis			= null 
				,dblInventoryCost			= tblCFImportTransactionPricingType.dblInventoryCost	
				,dblMargin					= tblCFImportTransactionPricingType.dblMargin
				,strPriceMethod 			= tblCFImportTransactionPricingType.strPriceMethod
				,intItemContractId 			= tblCFImportTransactionPricingType.intItemContractHeaderId
				,intItemContractDetailId 	= tblCFImportTransactionPricingType.intItemContractDetailId
				,dblQuantity 				= tblCFImportTransactionPricingType.dblQuantity
				,intPriceProfileId 			= null
				,intPriceIndexId			= null
				,intSiteGroupId				= tblCFImportTransactionPricingType.intSiteGroupId
				,strPriceProfileId			= ''
				,strPriceIndexId			= ''
				,strSiteGroup				= tblCFImportTransactionPricingType.strSiteGroup
				,dblPriceProfileRate		= null
				,dblPriceIndexRate			= null
				,dtmPriceIndexDate			= null
				,ysnDuplicate				= tblCFImportTransactionPricingType.ysnDuplicate
				,ysnInvalid					= tblCFImportTransactionPricingType.ysnInvalid
				,dblGrossTransferCost		= tblCFImportTransactionPricingType.dblGrossTransferCost
				,dblNetTransferCost			= tblCFImportTransactionPricingType.dblNetTransferCost
				,dblAdjustmentRate			= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND tblCFImportTransactionPricingType.strPriceMethod = 'Item Contract Pricing'
		AND strGUID = @strGUID


		UPDATE tblCFTransaction 
				SET strPriceBasis			= null 
				,dblInventoryCost			= tblCFImportTransactionPricingType.dblInventoryCost	
				,dblMargin					= tblCFImportTransactionPricingType.dblMargin
				,strPriceMethod 			= tblCFImportTransactionPricingType.strPriceMethod
				,intContractId 				= tblCFImportTransactionPricingType.intContractHeaderId
				,intContractDetailId 		= tblCFImportTransactionPricingType.intContractDetailId
				,dblQuantity 				= tblCFImportTransactionPricingType.dblQuantity
				,intPriceProfileId 			= null
				,intPriceIndexId			= null
				,intSiteGroupId				= tblCFImportTransactionPricingType.intSiteGroupId
				,strPriceProfileId			= ''
				,strPriceIndexId			= ''
				,strSiteGroup				= tblCFImportTransactionPricingType.strSiteGroup
				,dblPriceProfileRate		= null
				,dblPriceIndexRate			= null
				,dtmPriceIndexDate			= null
				,ysnDuplicate				= tblCFImportTransactionPricingType.ysnDuplicate
				,ysnInvalid					= tblCFImportTransactionPricingType.ysnInvalid
				,dblGrossTransferCost		= tblCFImportTransactionPricingType.dblGrossTransferCost
				,dblNetTransferCost			= tblCFImportTransactionPricingType.dblNetTransferCost
				,dblAdjustmentRate			= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND (tblCFImportTransactionPricingType.strPriceMethod = 'Contracts' OR tblCFImportTransactionPricingType.strPriceMethod = 'Contract Pricing')
		AND strGUID = @strGUID


		UPDATE tblCFTransaction 
			SET intContractId = null 
			,strPriceBasis = null
			,dblInventoryCost		= tblCFImportTransactionPricingType.dblInventoryCost	
			,dblMargin				= tblCFImportTransactionPricingType.dblMargin
			,strPriceMethod			= tblCFImportTransactionPricingType.strPriceMethod
			,intPriceProfileId 		= null
			,intPriceIndexId		= null
			,intSiteGroupId			= tblCFImportTransactionPricingType.intSiteGroupId
			,strPriceProfileId		= ''
			,strPriceIndexId		= ''
			,strSiteGroup			= tblCFImportTransactionPricingType.strSiteGroup
			,dblPriceProfileRate	= null
			,dblPriceIndexRate		= null
			,dtmPriceIndexDate		= null
			,ysnDuplicate			= tblCFImportTransactionPricingType.ysnDuplicate
			,ysnInvalid				= tblCFImportTransactionPricingType.ysnInvalid
			,dblGrossTransferCost	= tblCFImportTransactionPricingType.dblGrossTransferCost
			,dblNetTransferCost		= tblCFImportTransactionPricingType.dblNetTransferCost
			,dblAdjustmentRate		= tblCFImportTransactionPricingType.dblAdjustmentRate
		FROM tblCFImportTransactionPricingType
		WHERE tblCFTransaction.intTransactionId = tblCFImportTransactionPricingType.intTransactionId
		AND tblCFImportTransactionPricingType.strGUID = @strGUID
		AND (tblCFImportTransactionPricingType.strPriceMethod != 'Contracts' AND tblCFImportTransactionPricingType.strPriceMethod != 'Contract Pricing')
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Item Contract Pricing'
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Price Profile'	
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Special Pricing'
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Network Cost'
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Import File Price'
		AND tblCFImportTransactionPricingType.strPriceMethod != 'Inventory - Standard Pricing'
		AND strGUID = @strGUID


	
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
			 tblCFImportTransactionTaxType.intTransactionId
			,tblCFImportTransactionTaxType.dblTaxOriginalAmount
			,tblCFImportTransactionTaxType.dblTaxCalculatedAmount		
			,tblCFImportTransactionTaxType.intTaxCodeId	
			,tblCFImportTransactionTaxType.dblTaxRate	
			,tblCFImportTransactionTaxType.ysnTaxExempt
		FROM tblCFImportTransactionTaxType
		WHERE tblCFImportTransactionTaxType.strGUID = @strGUID



		
	UPDATE tblCFTransaction
	SET 
		 dblCalculatedTotalTax = tblCFTransactionTaxTotal.dblCalculatedTotalTax
		,dblOriginalTotalTax = tblCFTransactionTaxTotal.dblOriginalTotalTax
	FROM ( 
		 SELECT 
			  dblCalculatedTotalTax = SUM(ISNULL(dblTaxCalculatedAmount,0))
			 ,dblOriginalTotalTax = SUM(ISNULL(dblTaxOriginalAmount,0))
			 ,intTransactionId
			 ,strGUID
		 FROM tblCFImportTransactionTaxType
		 GROUP BY 
			 intTransactionId
			,strGUID
		 ) AS tblCFTransactionTaxTotal
	WHERE tblCFTransactionTaxTotal.intTransactionId = tblCFTransaction.intTransactionId
	AND tblCFTransactionTaxTotal.strGUID = @strGUID


	DELETE FROM tblCFImportTransactionCalculatedTax						WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxExempt				WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxExemptZeroQuantity	WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCalculatedTaxZeroQuantity			WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionCFNTaxDetailStagingTable			WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionNumericVehicleStagingTable		WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTax						WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTaxExempt					WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTaxExemptZeroQuantity		WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionOriginalTaxZeroQuantity			WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionPriceProfile						WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionPriceType							WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionPricingType						WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionRemoteCalculatedTax				WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionRemoteOriginalTax					WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionRemoteTax							WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionStagingTable						WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionStringVehicleStagingTable			WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTax								WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTaxType							WHERE strGUID = @strGUID
	DELETE FROM tblCFImportTransactionTaxZeroQuantity					WHERE strGUID = @strGUID

	

	--SELECT 'tblCFImportTransactionContractOverfillStagingTable',* FROM tblCFImportTransactionContractOverfillStagingTable

	IF EXISTS(SELECT(1) FROM tblCFImportTransactionContractOverfillStagingTable WHERE strGUID = @strGUID)
	BEGIN
		SELECT 'overfill'
		INSERT INTO tblCFImportTransactionStagingTable (
		 strGUID                     
		,strProcessDate              
		,strPostedDate               
		,strLaggingDate              
		,strCreatedDate              
		,strCardId                   
		,strVehicleId                
		,strProductId                
		,strNetworkId                
		,intTransTime                
		,intOdometer                 
		,intPumpNumber               
		,intContractId               
		,intSalesPersonId            
		,dtmBillingDate              
		,dtmTransactionDate          
		,strSequenceNumber           
		,strPONumber                 
		,strMiscellaneous            
		,strPriceMethod              
		,strPriceBasis               
		,dblQuantity                 
		,dblTransferCost             
		,dblOriginalTotalPrice       
		,dblCalculatedTotalPrice     
		,dblOriginalGrossPrice
		,dblCalculatedGrossPrice
		,dblCalculatedNetPrice
		,dblOriginalNetPrice			
		,dblCalculatedPumpPrice		
		,dblOriginalPumpPrice		
		,intNetworkId				
		,strCreditCard				
		,intSiteId					
		,strSiteId					
		,strSiteName					
		,strTransactionType			
		,strDeliveryPickupInd
		,strTaxState							                   
		,dblFederalExciseTaxRate				                   
		,dblStateExciseTaxRate1                                 
		,dblStateExciseTaxRate2                                 
		,dblCountyExciseTaxRate                                 
		,dblCityExciseTaxRate                                   
		,dblStateSalesTaxPercentageRate                         
		,dblCountySalesTaxPercentageRate                        
		,dblCitySalesTaxPercentageRate                          
		,dblOtherSalesTaxPercentageRate                         
		,strFederalExciseTaxRateReference                       
		,strStateExciseTaxRate1Reference                        
		,strStateExciseTaxRate2Reference                        
		,strCountyExciseTaxRateReference                        
		,strCityExciseTaxRateReference                          
		,strStateSalesTaxPercentageRateReference                
		,strCountySalesTaxPercentageRateReference               
		,strCitySalesTaxPercentageRateReference                 
		,strOtherSalesTaxPercentageRateReference                
		,strSiteTaxLocation                                     
		,strTax1                                     
		,strTax2                                     
		,strTax3                                     
		,strTax4                                     
		,strTax5                                     
		,strTax6                                     
		,strTax7                                     
		,strTax8                                     
		,strTax9                                     
		,strTax10                                    
		,dblTaxValue1                                
		,dblTaxValue2                                
		,dblTaxValue3                                
		,dblTaxValue4                                
		,dblTaxValue5                                
		,dblTaxValue6                                
		,dblTaxValue7                                
		,dblTaxValue8                                
		,dblTaxValue9                                
		,dblTaxValue10                               
		,strSiteState                                
		,strSiteAddress                              
		,strSiteCity                                 
		,intPPHostId                                 
		,strPPSiteType                               
		,strSiteType                                 
		,intSellingHost                              
		,intBuyingHost                               
		,strCardNumberForDualCard                    
		,strVehicleNumberForDualCard                 
		,strDriverPin                                
		,intUserId
		)
		SELECT 
		strGUID                     
		,strProcessDate              
		,strPostedDate               
		,strLaggingDate              
		,strCreatedDate              
		,strCardId                   
		,strVehicleId                
		,strProductId                
		,strNetworkId                
		,intTransTime                
		,intOdometer                 
		,intPumpNumber               
		,intContractId               
		,intSalesPersonId            
		,dtmBillingDate              
		,dtmTransactionDate          
		,strSequenceNumber           
		,strPONumber                 
		,strMiscellaneous            
		,strPriceMethod              
		,strPriceBasis               
		,dblQuantity                 
		,dblTransferCost             
		,dblOriginalTotalPrice       
		,dblCalculatedTotalPrice     
		,dblOriginalGrossPrice
		,dblCalculatedGrossPrice
		,dblCalculatedNetPrice
		,dblOriginalNetPrice			
		,dblCalculatedPumpPrice		
		,dblOriginalPumpPrice		
		,intNetworkId				
		,strCreditCard				
		,intSiteId					
		,strSiteId					
		,strSiteName					
		,strTransactionType			
		,strDeliveryPickupInd
		,strTaxState							                   
		,dblFederalExciseTaxRate				                   
		,dblStateExciseTaxRate1                                 
		,dblStateExciseTaxRate2                                 
		,dblCountyExciseTaxRate                                 
		,dblCityExciseTaxRate                                   
		,dblStateSalesTaxPercentageRate                         
		,dblCountySalesTaxPercentageRate                        
		,dblCitySalesTaxPercentageRate                          
		,dblOtherSalesTaxPercentageRate                         
		,strFederalExciseTaxRateReference                       
		,strStateExciseTaxRate1Reference                        
		,strStateExciseTaxRate2Reference                        
		,strCountyExciseTaxRateReference                        
		,strCityExciseTaxRateReference                          
		,strStateSalesTaxPercentageRateReference                
		,strCountySalesTaxPercentageRateReference               
		,strCitySalesTaxPercentageRateReference                 
		,strOtherSalesTaxPercentageRateReference                
		,strSiteTaxLocation                                     
		,strTax1                                     
		,strTax2                                     
		,strTax3                                     
		,strTax4                                     
		,strTax5                                     
		,strTax6                                     
		,strTax7                                     
		,strTax8                                     
		,strTax9                                     
		,strTax10                                    
		,dblTaxValue1                                
		,dblTaxValue2                                
		,dblTaxValue3                                
		,dblTaxValue4                                
		,dblTaxValue5                                
		,dblTaxValue6                                
		,dblTaxValue7                                
		,dblTaxValue8                                
		,dblTaxValue9                                
		,dblTaxValue10                               
		,strSiteState                                
		,strSiteAddress                              
		,strSiteCity                                 
		,intPPHostId                                 
		,strPPSiteType                               
		,strSiteType                                 
		,intSellingHost                              
		,intBuyingHost                               
		,strCardNumberForDualCard                    
		,strVehicleNumberForDualCard                 
		,strDriverPin                                
		,intUserId
		FROM tblCFImportTransactionContractOverfillStagingTable
		WHERE strGUID = @strGUID


		DELETE FROM tblCFImportTransactionContractOverfillStagingTable
		WHERE strGUID = @strGUID

		GOTO PROCESSOVERFILL
	END

	COMMIT TRANSACTION


	END TRY 
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK TRANSACTION

	END CATCH
	END


		-->> LOOP THROUGH CALCULATE <<--
		/*
		--DECLARE @intTransactionId INT = 0 
		--DECLARE 
		--	 @intProductId						INT				= 0
		--	,@intCardId							INT				= 0
		--	,@intVehicleId						INT				= 0
		--	,@intSiteId							INT				= 0
		--	,@dtmTransactionDate				DATETIME		= NULL
		--	,@strTransactionType				NVARCHAR(MAX)	= NULL
		--	,@dblQuantity						NUMERIC(18,6)	= 0.000000
		--	,@dblOriginalGrossPrice				NUMERIC(18,6)	= 0.000000
		--	,@intNetworkId						INT				= 0
		--	,@dblTransferCost					NUMERIC(18,6)	= 0.000000
		--	,@Pk								INT				= 0
		--	,@ysnCreditCardUsed					BIT				= 0
		--	,@ysnOriginHistory					BIT				= 0
		--	,@ysnPostedCSV  					BIT				= 0
		--	,@intPumpNumber						INT				= 0
		--	,@TaxState							NVARCHAR(MAX)	= ''
		--	,@FederalExciseTaxRate        		NUMERIC(18,6)	= 0.000000
		--	,@StateExciseTaxRate1         		NUMERIC(18,6)	= 0.000000
		--	,@StateExciseTaxRate2         		NUMERIC(18,6)	= 0.000000
		--	,@CountyExciseTaxRate         		NUMERIC(18,6)	= 0.000000
		--	,@CityExciseTaxRate           		NUMERIC(18,6)	= 0.000000
		--	,@StateSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000
		--	,@CountySalesTaxPercentageRate		NUMERIC(18,6)	= 0.000000
		--	,@CitySalesTaxPercentageRate  		NUMERIC(18,6)	= 0.000000
		--	,@OtherSalesTaxPercentageRate 		NUMERIC(18,6)	= 0.000000
		--	,@FederalExciseTax1					NUMERIC(18,6)	= 0.000000
		--	,@FederalExciseTax2					NUMERIC(18,6)	= 0.000000
		--	,@StateExciseTax1					NUMERIC(18,6)	= 0.000000
		--	,@StateExciseTax2					NUMERIC(18,6)	= 0.000000
		--	,@StateExciseTax3					NUMERIC(18,6)	= 0.000000
		--	,@CountyTax1						NUMERIC(18,6)	= 0.000000
		--	,@CityTax1							NUMERIC(18,6)	= 0.000000
		--	,@StateSalesTax						NUMERIC(18,6)	= 0.000000
		--	,@CountySalesTax					NUMERIC(18,6)	= 0.000000
		--	,@CitySalesTax						NUMERIC(18,6)	= 0.000000
		--	,@strProcessDate					NVARCHAR(MAX)
		--	,@Tax1								NVARCHAR(MAX)	= NULL
		--	,@Tax2								NVARCHAR(MAX)	= NULL
		--	,@Tax3								NVARCHAR(MAX)	= NULL
		--	,@Tax4								NVARCHAR(MAX)	= NULL
		--	,@Tax5								NVARCHAR(MAX)	= NULL
		--	,@Tax6								NVARCHAR(MAX)	= NULL
		--	,@Tax7								NVARCHAR(MAX)	= NULL
		--	,@Tax8								NVARCHAR(MAX)	= NULL
		--	,@Tax9								NVARCHAR(MAX)	= NULL
		--	,@Tax10								NVARCHAR(MAX)	= NULL
		--	,@TaxValue1							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue2							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue3							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue4							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue5							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue6							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue7							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue8							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue9							NUMERIC(18,6)	= 0.000000
		--	,@TaxValue10						NUMERIC(18,6)	= 0.000000
		--	,@strCardId							NVARCHAR(MAX)
		--	,@dblGrossTransferCost				NUMERIC(18,6)	
		--	,@dblNetTransferCost				NUMERIC(18,6)	



		
		--DECLARE @intPrcCustomerId				INT				
		--		,@intPrcItemUOMId				INT
		--		,@dblPrcPriceOut				NUMERIC(18,6)	
		--		,@strPrcPricingOut				NVARCHAR(MAX)		
		--		,@intPrcAvailableQuantity		INT				
		--		,@dblPrcOriginalPrice			NUMERIC(18,6)	
		--		,@intPrcContractHeaderId		INT				
		--		,@intPrcContractDetailId		INT				
		--		,@intPrcContractNumber			NVARCHAR(MAX)				
		--		,@intPrcContractSeq				INT				
		--		,@intPrcItemContractHeaderId	INT				
		--		,@intPrcItemContractDetailId	INT				
		--		,@intPrcItemContractNumber		NVARCHAR(MAX)				
		--		,@intPrcItemContractSeq			INT				
		--		,@strPrcPriceBasis				NVARCHAR(MAX)	
		--		,@dblCalcQuantity				NUMERIC(18,6)
		--		,@dblCalcOverfillQuantity		NUMERIC(18,6)
		--		,@intPriceProfileId				INT
		--		,@intPriceIndexId				INT
		--		,@intSiteGroupId				INT
		--		,@strPriceProfileId				NVARCHAR(MAX)
		--		,@strPriceIndexId				NVARCHAR(MAX)
		--		,@strSiteGroup					NVARCHAR(MAX)
		--		,@dblPriceProfileRate			NUMERIC(18,6)
		--		,@dblPriceIndexRate				NUMERIC(18,6)
		--		,@dtmPriceIndexDate				DATETIME
		--		,@dblMargin						NUMERIC(18,6)
		--		,@dblInventoryCost				NUMERIC(18,6)
		--		,@dblAdjustmentRate				NUMERIC(18,6)


		--DECLARE @ysnRecalculateInvalid BIT	= 0
		--DECLARE @strPriceMethod		NVARCHAR(MAX)
		--		,@strPriceBasis		NVARCHAR(MAX)
		--		,@intContractId		INT
		--		,@ysnDuplicate		BIT
		--		,@ysnExpensed		BIT
		--		,@intExpensedItemId	INT
		--		,@ysnInvalid		BIT

		
		--select 'Start Loop'
		----set statistics time on
		----DECLARE @count INT = 0
		----WHILE EXISTS (SELECT TOP 1 * FROM tblCFImportTransactionStagingTable)
		----BEGIN


		---- declare cursor
		--DECLARE cursor_recalculate CURSOR FOR
		--  SELECT 
		--	 intTransactionId
		--	,intProductId						
		--	,intCardId							
		--	,intVehicleId						
		--	,intSiteId							
		--	,dtmTransactionDate				
		--	,strTransactionType				
		--	,dblQuantity						
		--	,dblOriginalGrossPrice				
		--	,intNetworkId						
		--	,dblTransferCost					
		--	,intTransactionId								
		--	,ysnCreditCardUsed					
		--	,ysnOriginHistory					
		--	,ysnPostedCSV  					
		--	,intPumpNumber						
		--	,strTaxState							
		--	,dblFederalExciseTaxRate        		
		--	,dblStateExciseTaxRate1         		
		--	,dblStateExciseTaxRate2         		
		--	,dblCountyExciseTaxRate         		
		--	,dblCityExciseTaxRate           		
		--	,dblStateSalesTaxPercentageRate 		
		--	,dblCountySalesTaxPercentageRate		
		--	,dblCitySalesTaxPercentageRate  		
		--	,dblOtherSalesTaxPercentageRate 		
		--	,dblFederalExciseTax1					
		--	,dblFederalExciseTax2					
		--	,dblStateExciseTax1					
		--	,dblStateExciseTax2					
		--	,dblStateExciseTax3					
		--	,dblCountyTax1						
		--	,dblCityTax1							
		--	,dblStateSalesTax						
		--	,dblCountySalesTax					
		--	,dblCitySalesTax						
		--	,strProcessDate					
		--	,strTax1								
		--	,strTax2								
		--	,strTax3								
		--	,strTax4								
		--	,strTax5								
		--	,strTax6								
		--	,strTax7								
		--	,strTax8								
		--	,strTax9								
		--	,strTax10								
		--	,dblTaxValue1							
		--	,dblTaxValue2							
		--	,dblTaxValue3							
		--	,dblTaxValue4							
		--	,dblTaxValue5							
		--	,dblTaxValue6							
		--	,dblTaxValue7							
		--	,dblTaxValue8							
		--	,dblTaxValue9							
		--	,dblTaxValue10						
		--	,strCardId							
		--	FROM tblCFImportTransactionStagingTable
 
		--OPEN cursor_recalculate;
 
		---- loop through a cursor
		--FETCH NEXT FROM cursor_recalculate 
		--INTO 
		-- @intTransactionId				
		--,@intProductId					
		--,@intCardId						
		--,@intVehicleId					
		--,@intSiteId						
		--,@dtmTransactionDate			
		--,@strTransactionType			
		--,@dblQuantity					
		--,@dblOriginalGrossPrice			
		--,@intNetworkId					
		--,@dblTransferCost				
		--,@Pk							
		--,@ysnCreditCardUsed				
		--,@ysnOriginHistory				
		--,@ysnPostedCSV  				
		--,@intPumpNumber					
		--,@TaxState						
		--,@FederalExciseTaxRate        	
		--,@StateExciseTaxRate1         	
		--,@StateExciseTaxRate2         	
		--,@CountyExciseTaxRate         	
		--,@CityExciseTaxRate           	
		--,@StateSalesTaxPercentageRate 	
		--,@CountySalesTaxPercentageRate	
		--,@CitySalesTaxPercentageRate  	
		--,@OtherSalesTaxPercentageRate 	
		--,@FederalExciseTax1				
		--,@FederalExciseTax2				
		--,@StateExciseTax1				
		--,@StateExciseTax2				
		--,@StateExciseTax3				
		--,@CountyTax1					
		--,@CityTax1						
		--,@StateSalesTax					
		--,@CountySalesTax				
		--,@CitySalesTax					
		--,@strProcessDate				
		--,@Tax1							
		--,@Tax2							
		--,@Tax3							
		--,@Tax4							
		--,@Tax5							
		--,@Tax6							
		--,@Tax7							
		--,@Tax8							
		--,@Tax9							
		--,@Tax10							
		--,@TaxValue1						
		--,@TaxValue2						
		--,@TaxValue3						
		--,@TaxValue4						
		--,@TaxValue5						
		--,@TaxValue6						
		--,@TaxValue7						
		--,@TaxValue8						
		--,@TaxValue9						
		--,@TaxValue10					
		--,@strCardId			
					
		--WHILE @@FETCH_STATUS = 0
		--	BEGIN
			

		--	--SELECT 
		--	-- @intTransactionId				
		--	--,@intProductId					
		--	--,@intCardId						
		--	--,@intVehicleId					
		--	--,@intSiteId						
		--	--,@dtmTransactionDate			
		--	--,@strTransactionType			
		--	--,@dblQuantity					
		--	--,@dblOriginalGrossPrice			
		--	--,@intNetworkId					
		--	--,@dblTransferCost				
		--	--,@Pk							
		--	--,@ysnCreditCardUsed				
		--	--,@ysnOriginHistory				
		--	--,@ysnPostedCSV  				
		--	--,@intPumpNumber					
		--	--,@TaxState						
		--	--,@FederalExciseTaxRate        	
		--	--,@StateExciseTaxRate1         	
		--	--,@StateExciseTaxRate2         	
		--	--,@CountyExciseTaxRate         	
		--	--,@CityExciseTaxRate           	
		--	--,@StateSalesTaxPercentageRate 	
		--	--,@CountySalesTaxPercentageRate	
		--	--,@CitySalesTaxPercentageRate  	
		--	--,@OtherSalesTaxPercentageRate 	
		--	--,@FederalExciseTax1				
		--	--,@FederalExciseTax2				
		--	--,@StateExciseTax1				
		--	--,@StateExciseTax2				
		--	--,@StateExciseTax3				
		--	--,@CountyTax1					
		--	--,@CityTax1						
		--	--,@StateSalesTax					
		--	--,@CountySalesTax				
		--	--,@CitySalesTax					
		--	--,@strProcessDate				
		--	--,@Tax1							
		--	--,@Tax2							
		--	--,@Tax3							
		--	--,@Tax4							
		--	--,@Tax5							
		--	--,@Tax6							
		--	--,@Tax7							
		--	--,@Tax8							
		--	--,@Tax9							
		--	--,@Tax10							
		--	--,@TaxValue1						
		--	--,@TaxValue2						
		--	--,@TaxValue3						
		--	--,@TaxValue4						
		--	--,@TaxValue5						
		--	--,@TaxValue6						
		--	--,@TaxValue7						
		--	--,@TaxValue8						
		--	--,@TaxValue9						
		--	--,@TaxValue10					
		--	--,@strCardId						

		--	FETCH NEXT FROM cursor_recalculate 
		--	INTO 
		--	@intTransactionId				
		--	,@intProductId					
		--	,@intCardId						
		--	,@intVehicleId					
		--	,@intSiteId						
		--	,@dtmTransactionDate			
		--	,@strTransactionType			
		--	,@dblQuantity					
		--	,@dblOriginalGrossPrice			
		--	,@intNetworkId					
		--	,@dblTransferCost				
		--	,@Pk							
		--	,@ysnCreditCardUsed				
		--	,@ysnOriginHistory				
		--	,@ysnPostedCSV  				
		--	,@intPumpNumber					
		--	,@TaxState						
		--	,@FederalExciseTaxRate        	
		--	,@StateExciseTaxRate1         	
		--	,@StateExciseTaxRate2         	
		--	,@CountyExciseTaxRate         	
		--	,@CityExciseTaxRate           	
		--	,@StateSalesTaxPercentageRate 	
		--	,@CountySalesTaxPercentageRate	
		--	,@CitySalesTaxPercentageRate  	
		--	,@OtherSalesTaxPercentageRate 	
		--	,@FederalExciseTax1				
		--	,@FederalExciseTax2				
		--	,@StateExciseTax1				
		--	,@StateExciseTax2				
		--	,@StateExciseTax3				
		--	,@CountyTax1					
		--	,@CityTax1						
		--	,@StateSalesTax					
		--	,@CountySalesTax				
		--	,@CitySalesTax					
		--	,@strProcessDate				
		--	,@Tax1							
		--	,@Tax2							
		--	,@Tax3							
		--	,@Tax4							
		--	,@Tax5							
		--	,@Tax6							
		--	,@Tax7							
		--	,@Tax8							
		--	,@Tax9							
		--	,@Tax10							
		--	,@TaxValue1						
		--	,@TaxValue2						
		--	,@TaxValue3						
		--	,@TaxValue4						
		--	,@TaxValue5						
		--	,@TaxValue6						
		--	,@TaxValue7						
		--	,@TaxValue8						
		--	,@TaxValue9						
		--	,@TaxValue10					
		--	,@strCardId		

		--	END;
 
		---- close and deallocate cursor
		--CLOSE cursor_recalculate;
		--DEALLOCATE cursor_recalculate;





		 --SET @count = @count+1
			--SELECT TOP 1 
			-- @intTransactionId					= intTransactionId
			--,@intProductId						= intProductId						
			--,@intCardId							= intCardId							
			--,@intVehicleId						= intVehicleId						
			--,@intSiteId							= intSiteId							
			--,@dtmTransactionDate				= dtmTransactionDate				
			--,@strTransactionType				= strTransactionType				
			--,@dblQuantity						= dblQuantity						
			--,@dblOriginalGrossPrice				= dblOriginalGrossPrice				
			--,@intNetworkId						= intNetworkId						
			--,@dblTransferCost					= dblTransferCost					
			--,@Pk								= intTransactionId								
			--,@ysnCreditCardUsed					= ysnCreditCardUsed					
			--,@ysnOriginHistory					= ysnOriginHistory					
			--,@ysnPostedCSV  					= ysnPostedCSV  					
			--,@intPumpNumber						= intPumpNumber						
			--,@TaxState							= strTaxState							
			--,@FederalExciseTaxRate        		= dblFederalExciseTaxRate        		
			--,@StateExciseTaxRate1         		= dblStateExciseTaxRate1         		
			--,@StateExciseTaxRate2         		= dblStateExciseTaxRate2         		
			--,@CountyExciseTaxRate         		= dblCountyExciseTaxRate         		
			--,@CityExciseTaxRate           		= dblCityExciseTaxRate           		
			--,@StateSalesTaxPercentageRate 		= dblStateSalesTaxPercentageRate 		
			--,@CountySalesTaxPercentageRate		= dblCountySalesTaxPercentageRate		
			--,@CitySalesTaxPercentageRate  		= dblCitySalesTaxPercentageRate  		
			--,@OtherSalesTaxPercentageRate 		= dblOtherSalesTaxPercentageRate 		
			--,@FederalExciseTax1					= dblFederalExciseTax1					
			--,@FederalExciseTax2					= dblFederalExciseTax2					
			--,@StateExciseTax1					= dblStateExciseTax1					
			--,@StateExciseTax2					= dblStateExciseTax2					
			--,@StateExciseTax3					= dblStateExciseTax3					
			--,@CountyTax1						= dblCountyTax1						
			--,@CityTax1							= dblCityTax1							
			--,@StateSalesTax						= dblStateSalesTax						
			--,@CountySalesTax					= dblCountySalesTax					
			--,@CitySalesTax						= dblCitySalesTax						
			--,@strProcessDate					= strProcessDate					
			--,@Tax1								= strTax1								
			--,@Tax2								= strTax2								
			--,@Tax3								= strTax3								
			--,@Tax4								= strTax4								
			--,@Tax5								= strTax5								
			--,@Tax6								= strTax6								
			--,@Tax7								= strTax7								
			--,@Tax8								= strTax8								
			--,@Tax9								= strTax9								
			--,@Tax10								= strTax10								
			--,@TaxValue1							= dblTaxValue1							
			--,@TaxValue2							= dblTaxValue2							
			--,@TaxValue3							= dblTaxValue3							
			--,@TaxValue4							= dblTaxValue4							
			--,@TaxValue5							= dblTaxValue5							
			--,@TaxValue6							= dblTaxValue6							
			--,@TaxValue7							= dblTaxValue7							
			--,@TaxValue8							= dblTaxValue8							
			--,@TaxValue9							= dblTaxValue9							
			--,@TaxValue10						= dblTaxValue10						
			--,@strCardId							= strCardId							
			--FROM tblCFImportTransactionStagingTable

			--select @intTransactionId,@count
			
			/*
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
				,@intPrcAvailableQuantity		= dblAvailableQuantity
				,@dblPrcOriginalPrice			= dblOriginalPrice
				,@intPrcContractHeaderId		= intContractHeaderId
				,@intPrcContractDetailId		= intContractDetailId
				,@intPrcContractNumber			= strContractNumber
				,@intPrcContractSeq				= intContractSeq
				,@intPrcItemContractHeaderId	= intItemContractHeaderId
				,@intPrcItemContractDetailId	= intItemContractDetailId
				,@intPrcItemContractNumber		= strItemContractNumber
				,@intPrcItemContractSeq			= intItemContractSeq
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
				,@ysnExpensed					= ysnExpensed
				,@intExpensedItemId				= intExpensedItemId
				FROM tblCFTransactionPricingType

		
			UPDATE tblCFTransaction 
			SET ysnExpensed = @ysnExpensed , intExpensedItemId = @intExpensedItemId
			WHERE intTransactionId = @Pk

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
			ELSE IF (LOWER(@strPriceMethod) = 'item contract pricing' OR LOWER(@strPriceMethod) = 'item contracts')
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
				,strPriceMethod 		= 'Item Contract Pricing'
				,intItemContractId 			= @intPrcItemContractHeaderId
				,intItemContractDetailId 	= @intPrcItemContractDetailId
				,dblQuantity 			= @dblQuantity
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
				IF (LOWER(@strPriceMethod) = 'item contract pricing' OR LOWER(@strPriceMethod) = 'item contracts')
				BEGIN
					--EXEC uspCTUpdateScheduleQuantity 
					-- @intContractDetailId = @intContractId
					--,@dblQuantityToUpdate = @dblCalcQuantity
					--,@intUserId = 0
					--,@intExternalId = @Pk
					--,@strScreenName = 'Card Fueling Transaction Screen'

					EXEC uspCTItemContractUpdateScheduleQuantity
					@intItemContractDetailId = @intPrcItemContractDetailId,
					@dblQuantityToUpdate = @dblCalcQuantity,
					@intUserId = 0,
					@intTransactionDetailId = @Pk,
					@strScreenName = 'Card Fueling Transaction Screen'
				END


				SELECT @dblCalcOverfillQuantity,@intPrcItemContractDetailId,@dblCalcQuantity'itc', * FROM tblCFTransaction Where intTransactionId = @Pk
				
				------------------------------------------------------------

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
					,strPriceMethod 		= 'Contract Pricing'
					,intContractId 			= @intPrcContractHeaderId
					,intContractDetailId 	= @intPrcContractDetailId
					,dblQuantity 			= @dblQuantity
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


				-------
				--Tax--
				-------
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
	

	
				-------------
				--Audit Log--
				-------------
				EXEC [uspCFTransactionAuditLog] 
					@processName					= 'Import Transaction'
					,@keyValue						= @Pk
					,@entityId						= @intUserId
					,@action						= ''
					
					*/
			

			--DELETE FROM tblCFImportTransactionStagingTable WHERE intTransactionId = @intTransactionId

			--IF(SELECT COUNT(1) FROM tblCFImportTransactionStagingTable) > 0
			--BEGIN
			--	GOTO CalculatePrice
			--END
		--END

		--set statistics time off

		


	




		--COMMIT TRANSACTION
		*/
		--<< >>--


	
	--set statistics time off


	---------
	--To Do--
	---------
	--Contracts overfill transaction--


	--	print @dblCalcOverfillQuantity
	--	IF(@dblCalcOverfillQuantity > 0)
	--	BEGIN

	--		SELECT 'ovf' ,@dblCalcOverfillQuantity,@intOverFilledTransactionId

	--		IF(@intOverFilledTransactionId IS NULL)
	--		BEGIN
	--			SET @intOverFilledTransactionId = @Pk
	--		END
			
	--		SET @dblQuantity = @dblCalcOverfillQuantity
	--		SET @dblPrcPriceOut				  = NULL
	--		SET @strPrcPricingOut			  = NULL
	--		SET @intPrcAvailableQuantity	  = NULL
	--		SET @dblPrcOriginalPrice		  = NULL
	--		SET @intPrcContractHeaderId		  = NULL
	--		SET @intPrcContractDetailId		  = NULL
	--		SET @intPrcContractNumber		  = NULL
	--		SET @intPrcContractSeq			  = NULL
	--		SET @intPrcItemContractHeaderId   = NULL
	--		SET @intPrcItemContractDetailId	  = NULL
	--		SET @intPrcItemContractNumber	  = NULL
	--		SET @intPrcItemContractSeq		  = NULL
	--		SET @strPrcPriceBasis			  = NULL
	--		print 'goto calculate price'
	--		GOTO CALCULATEPRICE
	--	END
	--	------------------------------------------------------------
	
