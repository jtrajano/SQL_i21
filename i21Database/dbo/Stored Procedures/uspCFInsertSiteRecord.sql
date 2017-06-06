

CREATE  PROCEDURE [dbo].[uspCFInsertSiteRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	
	---------------------------------------------------------
	--primary--
	  @strSiteNumber				NVARCHAR(MAX)	 =	 ''						-- *
	 ,@strSiteName					NVARCHAR(MAX)	 =	 ''						-- *

	---------------------------------------------------------
	--navigation prop--
	,@strNetworkId					NVARCHAR(MAX)	 =	 ''						-- *
	,@strARLocation					NVARCHAR(MAX)	 =	 ''						-- *
	,@strSiteGroup					NVARCHAR(MAX)	 =	 ''
	,@strTaxGroup					NVARCHAR(MAX)	 =	 ''
	,@strARCashCustomer				NVARCHAR(MAX)	 =	 ''
	,@strImportMapping				NVARCHAR(MAX)	 =	 ''
	
	---------------------------------------------------------
	--predefined--
	,@strDeliveryPickup				NVARCHAR(MAX)	 =	 'Pickup'				-- *
	,@strSiteType					NVARCHAR(MAX)	 =	 'Local/Network'		-- *
	,@strControllerType				NVARCHAR(MAX)	 =	 'AutoGas'				-- *
	,@strPPSiteType					NVARCHAR(MAX)	 =	 ''
	
	---------------------------------------------------------
	--boolean--
	,@strSiteAcceptsCreditCards		 NVARCHAR(MAX)	 =	 'N'
	,@strProcessCashSales			 NVARCHAR(MAX)	 =	 'N'
	,@strImportTripleEStock			 NVARCHAR(MAX)	 =	 'N'
	,@strPumpCalculatesExemptPrice	 NVARCHAR(MAX)	 =	 'N'
	,@strRecalculateTaxesOnRemote	 NVARCHAR(MAX)	 =	 'N'
	,@strImportContainsMultipleSites NVARCHAR(MAX)	 =	 'N'
	
	---------------------------------------------------------
	--string--
	,@strAddress					NVARCHAR(MAX)	 =	 ''
	,@strCity						NVARCHAR(MAX)	 =	 ''
	,@strState						NVARCHAR(MAX)	 =	 ''
	,@strPacPrideHostId				NVARCHAR(MAX)	 =	 ''
	,@strImportFilePath				NVARCHAR(MAX)	 =	 ''
	,@strImportFileName				NVARCHAR(MAX)	 =	 ''
	
	---------------------------------------------------------


AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateSite					      INT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intARLocation							  INT = 0
	DECLARE @intSiteGroup							  INT = 0
	DECLARE @intTaxGroup							  INT = 0
	DECLARE @intARCashCustomer						  INT = 0
	DECLARE @intImportMapping						  INT = 0
	---------------------------------------------------------
	DECLARE @ysnSiteAcceptsCreditCards		 		  BIT = 0
	DECLARE @ysnProcessCashSales			 		  BIT = 0
	DECLARE @ysnImportTripleEStock			 		  BIT = 0
	DECLARE @ysnPumpCalculatesExemptPrice	 		  BIT = 0
	DECLARE @ysnRecalculateTaxesOnRemote	 		  BIT = 0
	DECLARE @ysnImportContainsMultipleSites 		  BIT = 0
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strSiteNumber = NULL OR @strSiteNumber = '')
	BEGIN
		SET @strSiteNumber = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Site Number is required')
		SET @ysnHasError = 1
	END
	IF(@strSiteName = NULL OR @strSiteName = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Site Name is required')
		SET @ysnHasError = 1
	END
	IF(@strNetworkId = NULL OR @strNetworkId = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Network is required')
		SET @ysnHasError = 1
	END
	IF(@strARLocation = NULL OR @strARLocation = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'AR Location is required')
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


	--Network
	IF (@strNetworkId != '')
		BEGIN 
			
			SELECT TOP 1 @intNetworkId = intNetworkId
			FROM tblCFNetwork 
			WHERE strNetwork = @strNetworkId
			
			IF (@intNetworkId = 0)
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


	--Company Location
	IF (@strARLocation != '')
		BEGIN 
			SELECT @intARLocation = intCompanyLocationId  
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strARLocation
			IF (@intARLocation = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strSiteNumber,'Unable to find match for '+ @strARLocation +' on company location list')
				SET @ysnHasError = 1
			END
		END
	ELSE
		BEGIN
			SET @intARLocation = NULL
		END

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

	--@AR Cash Customer
	IF (@strARCashCustomer != '')
		BEGIN 
			SELECT @intARCashCustomer = intEntityId  
			FROM tblARCustomer
			WHERE strCustomerNumber = @strARCashCustomer
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

	--@Import Mapping
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
	
	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------


	--Site accepts credit cards
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
			VALUES (@strSiteNumber,'Invalid site accepts credit cards '+ @strSiteAcceptsCreditCards +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--Process Cash Sales
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
			VALUES (@strSiteNumber,'Invalid process cash sales '+ @strProcessCashSales +'. Value should be Y or N only')
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
			VALUES (@strSiteNumber,'Invalid import triple E stock '+ @strImportTripleEStock +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	--@Pump Calculates Exempt Price
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
			VALUES (@strSiteNumber,'Invalid pump calculates exempt price '+ @strPumpCalculatesExemptPrice +'. Value should be Y or N only')
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
			VALUES (@strSiteNumber,'Invalid recalculate taxes on remote '+ @strRecalculateTaxesOnRemote +'. Value should be Y or N only')
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
			VALUES (@strSiteNumber,'Invalid import contains multiple sites '+ @strImportContainsMultipleSites +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFSite(
				 intNetworkId
				,strSiteNumber
				,strSiteName
				,intARLocationId
				,strDeliveryPickup
				,strSiteType
				,strControllerType
				,intAdjustmentSiteGroupId
				,ysnSiteAcceptsMajorCreditCards
				,strSiteAddress
				,strSiteCity
				,strTaxState
				,intTaxGroupId
				,intPPHostId
				,strPPSiteType
				,ysnProcessCashSales
				,intCashCustomerID
				,ysnEEEStockItemDetail
				,ysnPumpCalculatesTaxes
				,ysnRecalculateTaxesOnRemote
				,ysnMultipleSiteImport
				,intImportMapperId
				,strImportPath
				,strImportFileName
				)
			VALUES(
				 @intNetworkId
				,@strSiteNumber
				,@strSiteName
				,@intARLocation
				,@strDeliveryPickup
				,@strSiteType
				,@strControllerType
				,@intSiteGroup
				,@ysnSiteAcceptsCreditCards
				,@strAddress
				,@strCity
				,@strState
				,@intTaxGroup
				,@strPacPrideHostId
				,@strPPSiteType
				,@ysnProcessCashSales
				,@intARCashCustomer
				,@ysnImportTripleEStock
				,@ysnPumpCalculatesExemptPrice
				,@ysnRecalculateTaxesOnRemote
				,@ysnImportContainsMultipleSites
				,@intImportMapping
				,@strImportFilePath
				,@strImportFileName
				 )

			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strSiteNumber,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
		
END