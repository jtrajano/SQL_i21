CREATE PROCEDURE [dbo].[uspCFInsertSiteRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	
	--master table--
	 @strNetworkId						NVARCHAR(MAX)	 =	 ''
	,@strARLocation						NVARCHAR(MAX)	 =	 ''
	,@strSiteGroup						NVARCHAR(MAX)	 =	 ''
	,@strTaxGroup						NVARCHAR(MAX)	 =	 ''
	,@strARCashCustomer					NVARCHAR(MAX)	 =	 ''
	,@strImportMapping					NVARCHAR(MAX)	 =	 ''

	--normal input--
	,@strSiteNumber						NVARCHAR(MAX)	 =	 ''
	,@strSiteName						NVARCHAR(MAX)	 =	 ''
	,@strAddress						NVARCHAR(MAX)	 =	 ''
	,@strCity							NVARCHAR(MAX)	 =	 ''
	,@strState							NVARCHAR(MAX)	 =	 ''
	,@strPacPrideHostId					NVARCHAR(MAX)	 =	 ''
	,@strImportFilePath					NVARCHAR(MAX)	 =	 ''
	,@strImportFileName					NVARCHAR(MAX)	 =	 ''

	--predefined--
	,@strDeliveryPickup					NVARCHAR(MAX)	 =	 ''
	,@strSiteType						NVARCHAR(MAX)	 =	 ''
	,@strControllerType					NVARCHAR(MAX)	 =	 ''
	,@strPPSiteType						NVARCHAR(MAX)	 =	 ''


	--boolean--
	,@strSiteAcceptsCreditCards			NVARCHAR(MAX)	 =	 ''
	,@strProcessCashSales				NVARCHAR(MAX)	 =	 ''
	,@strImportTripleEStock				NVARCHAR(MAX)	 =	 ''
	,@strPumpCalculatesExemptPrice		NVARCHAR(MAX)	 =	 ''
	,@strRecalculateTaxesOnRemote		NVARCHAR(MAX)	 =	 ''
	,@strImportContainsMultipleSites	NVARCHAR(MAX)	 =	 ''


AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0

	DECLARE @intDuplicateSite					      INT = 0

	DECLARE @ysnSiteAcceptsCreditCards				  BIT = 0
	DECLARE @ysnProcessCashSales					  BIT = 0
	DECLARE @ysnImportTripleEStock					  BIT = 0
	DECLARE @ysnPumpCalculatesExemptPrice			  BIT = 0
	DECLARE @ysnRecalculateTaxesOnRemote			  BIT = 0
	DECLARE @ysnImportContainsMultipleSites			  BIT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intARLocation							  INT = 0
	DECLARE @intSiteGroup							  INT = 0
	DECLARE @intTaxGroup							  INT = 0
	DECLARE @intARCashCustomer						  INT = 0
	DECLARE @intImportMapping						  INT = 0
	DECLARE @strNetworkType							  NVARCHAR(50)
	---------------------------------------------------------
	DECLARE @strAllowExemptionsOnExtAndRetailTrans	  NVARCHAR(50)
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strNetworkId = NULL OR @strNetworkId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strNetworkId,'Network is required')
		SET @ysnHasError = 1
	END

	IF(@strARLocation = NULL OR @strARLocation = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strARLocation,'Location is required')
		SET @ysnHasError = 1
	END

	IF(@strSiteNumber = NULL OR @strSiteNumber = '')
	BEGIN
		SET @strSiteNumber = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Site number is required')
		SET @ysnHasError = 1
	END

	IF(@strSiteName = NULL OR @strSiteName = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteName,'Site name is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	

	--IF(@ysnHasError = 1)
	--BEGIN
	--	RETURN
	--END

	---------------------------------------------------------
	--				VALID VALUE TO OTHER TABLE		       --
	---------------------------------------------------------

	--Account
	IF (@strNetworkId != '')
		BEGIN 
			SELECT 
			 @intNetworkId = n.intNetworkId
			,@strNetworkType = strNetworkType
			FROM tblCFNetwork as n
			WHERE strNetwork = @strNetworkId

			IF (ISNULL(@intNetworkId,0) = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strNetworkId +' on network list')
				SET @ysnHasError = 1
			END
			ELSE
			BEGIN
				---------------------------------------------------------
				--			      DUPLICATE VEHICLE NUMBER				   --
				---------------------------------------------------------
				SELECT @intDuplicateSite = COUNT(*) FROM tblCFSite WHERE strSiteNumber = @strSiteNumber AND intNetworkId = @intNetworkId 
				IF (@intDuplicateSite > 0)
				BEGIN
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strSiteNumber,'Duplicate site for '+ @strSiteNumber)
					SET @ysnHasError = 1
				END
	
				---------------------------------------------------------
			END
		END
	ELSE
		BEGIN
			SET @intNetworkId = NULL
		END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	--Location
	IF (@strARLocation != '')
		BEGIN 
			SELECT @intARLocation = intCompanyLocationId  
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strARLocation
			IF (@intARLocation = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strARLocation +' on location list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intARLocation = NULL
		END

	---------------------------------------------------------

	--Site Group
	IF (@strSiteGroup != '')
		BEGIN 
			SELECT @intSiteGroup = intSiteGroupId  
			FROM tblCFSiteGroup
			WHERE strSiteGroup = @strSiteGroup
			IF (@intSiteGroup = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strSiteGroup +' on site group list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intSiteGroup = NULL
		END

	---------------------------------------------------------

	--Tax Group
	IF (@strTaxGroup != '')
		BEGIN 
			SELECT @intTaxGroup = intTaxGroupId  
			FROM tblSMTaxGroup
			WHERE strTaxGroup = @strTaxGroup
			IF (@intTaxGroup = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strTaxGroup +' on tax group list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intTaxGroup = NULL
		END

	---------------------------------------------------------

	--Cash Customer
	IF (@strARCashCustomer != '')
		BEGIN 
			SELECT @intARCashCustomer = e.intEntityId  
			FROM tblEMEntity e
			INNER JOIN tblARCustomer c
			ON e.intEntityId = c.intEntityId
			WHERE e.strName = @strARCashCustomer
			IF (@intARCashCustomer = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strARCashCustomer +' on customer list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intARCashCustomer = NULL
		END

	---------------------------------------------------------

	--Cash Customer
	IF (@strImportMapping != '')
		BEGIN 
			SELECT @intImportMapping = intImportFileHeaderId  
			FROM tblSMImportFileHeader
			WHERE strLayoutTitle = @strImportMapping
			IF (@intImportMapping = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strImportMapping +' on file field mapping list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intImportMapping = NULL
		END

	---------------------------------------------------------

	
	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------

	--SiteAcceptsCreditCards
	IF (@strSiteAcceptsCreditCards = 'N')
		BEGIN 
			SET @ysnSiteAcceptsCreditCards = 0
		END
	ELSE IF (@strSiteAcceptsCreditCards = 'Y')
		BEGIN
			SET @ysnSiteAcceptsCreditCards = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Site Accepts Credit Card '+ @strSiteAcceptsCreditCards +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--ProcessCashSales
	IF (@strProcessCashSales = 'N')
		BEGIN 
			SET @ysnProcessCashSales = 0
		END
	ELSE IF (@strProcessCashSales = 'Y')
		BEGIN
			SET @ysnProcessCashSales = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Process Cash Sales '+ @strProcessCashSales +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Import Triple E Stock
	IF (@strImportTripleEStock = 'N')
		BEGIN 
			SET @ysnImportTripleEStock = 0
		END
	ELSE IF (@strImportTripleEStock = 'Y')
		BEGIN
			SET @ysnImportTripleEStock = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Import Triple E Stock '+ @strImportTripleEStock +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--PumpCalculatesExemptPrice
	IF (@strPumpCalculatesExemptPrice = 'N')
		BEGIN 
			SET @ysnPumpCalculatesExemptPrice = 0
		END
	ELSE IF (@strPumpCalculatesExemptPrice = 'Y')
		BEGIN
			SET @ysnPumpCalculatesExemptPrice = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Pump Calculates Exempt Price '+ @strPumpCalculatesExemptPrice +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Recalculate Taxes On Remote
	IF (@strRecalculateTaxesOnRemote = 'N')
		BEGIN 
			SET @ysnRecalculateTaxesOnRemote = 0
		END
	ELSE IF (@strRecalculateTaxesOnRemote = 'Y')
		BEGIN
			SET @ysnRecalculateTaxesOnRemote = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Recalculate Taxes On Remote '+ @strRecalculateTaxesOnRemote +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

		
	--Import Contains Multiple Sites
	IF (@strImportContainsMultipleSites = 'N')
		BEGIN 
			SET @ysnImportContainsMultipleSites = 0
		END
	ELSE IF (@strImportContainsMultipleSites = 'Y')
		BEGIN
			SET @ysnImportContainsMultipleSites = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid Import Contains Multiple Sites '+ @strImportContainsMultipleSites +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END


	---------------------------------------------------------


	--Delivery Pickup
	IF (@strDeliveryPickup not in ('Delivery','Pickup'))
	BEGIN 
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Invalid Delivery Pickup '+ @strDeliveryPickup +'. Value should be Delivery or Pickup only')
		SET @ysnHasError = 1
	END
	
	---------------------------------------------------------


	--SiteType
	IF (@strSiteType not in ('Local/Network','Remote','Extended Remote'))
	BEGIN 
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Invalid Site Type '+ @strSiteType +'. Value should be Local/Network or Remote or Extended Remote only')
		SET @ysnHasError = 1
	END
	
	---------------------------------------------------------

	--Controller Type
	IF (@strControllerType not in   (
										 'AutoGas'
										,'Gasboy'
										,'Tech-21'
										,'Mannatec'
										,'WetHosing'
										,'CCIS'
										,'EEE'
										,'PetroVend'
										,'CFN'
										,'PacPride'
										,'Voyager'
									))

	BEGIN 
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Invalid Controller Type '+ @strControllerType +'. Value should be AutoGas,Gasboy,Tech-21,Mannatec,WetHosing,CCIS,EEE,PetroVend,CFN,PacPride,Voyager only')
		SET @ysnHasError = 1
	END
	
	---------------------------------------------------------

	IF (@strNetworkType = 'PacPride')
	BEGIN
		--PP SiteType
		IF (@strPPSiteType not in ('Network','Exclusive','Retail'))
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Invalid PP SiteType '+ @strPPSiteType +'. Value should be Network or Exclusive or Retail only')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @strPPSiteType = NULL
	END

	
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END


	
	---------------------------------------------------------
	----				    DEFAULT			   			 ----
	---------------------------------------------------------

	SELECT TOP 1 
	@strAllowExemptionsOnExtAndRetailTrans = strAllowExemptionsOnExtAndRetailTrans
	FROM tblCFNetwork
	WHERE intNetworkId = @intNetworkId

	
	---------------------------------------------------------


	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFSite
			(
				 intNetworkId					
				,intARLocationId					
				,intAdjustmentSiteGroupId					
				,intTaxGroupId					
				,intCashCustomerID				
				,intImportMapperId				
				,strSiteNumber					
				,strSiteName					
				,strSiteAddress					
				,strSiteCity						
				,strTaxState						
				,intPPHostId				
				,strImportPath				
				,strImportFileName				
				,strDeliveryPickup				
				,strSiteType					
				,strControllerType				
				,strPPSiteType					
				,ysnSiteAcceptsMajorCreditCards		
				,ysnProcessCashSales			
				,ysnEEEStockItemDetail			
				,ysnPumpCalculatesTaxes	
				,ysnRecalculateTaxesOnRemote	
				,ysnMultipleSiteImport
				,strAllowExemptionsOnExtAndRetailTrans
	        )
			VALUES
			(
				 @intNetworkId					
				,@intARLocation					
				,@intSiteGroup					
				,@intTaxGroup					
				,@intARCashCustomer				
				,@intImportMapping				
				,@strSiteNumber					
				,@strSiteName					
				,@strAddress					
				,@strCity						
				,@strState						
				,@strPacPrideHostId				
				,@strImportFilePath				
				,@strImportFileName				
				,@strDeliveryPickup				
				,@strSiteType					
				,@strControllerType				
				,@strPPSiteType					
				,@ysnSiteAcceptsCreditCards		
				,@ysnProcessCashSales			
				,@ysnImportTripleEStock			
				,@ysnPumpCalculatesExemptPrice	
				,@ysnRecalculateTaxesOnRemote	
				,@ysnImportContainsMultipleSites
				,@strAllowExemptionsOnExtAndRetailTrans
			)

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
		
			ROLLBACK TRANSACTION

			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'SQL Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			RETURN 0
		END CATCH
		
END