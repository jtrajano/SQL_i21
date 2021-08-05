CREATE PROCEDURE [dbo].[uspCFInsertSiteRecord]
	
	---------------------------------------------------------
	--				INTEGRATION TO OTHER TABLE			   --
	---------------------------------------------------------
	
	--master table--
	 @strNetworkId									NVARCHAR(MAX)	 =	 ''
	,@strARLocation									NVARCHAR(MAX)	 =	 ''
	,@strSiteGroup									NVARCHAR(MAX)	 =	 ''
	,@strTaxGroup									NVARCHAR(MAX)	 =	 ''
	,@strARCashCustomer								NVARCHAR(MAX)	 =	 ''
	,@strImportMapping								NVARCHAR(MAX)	 =	 ''

	--normal input--
	,@strSiteNumber									NVARCHAR(MAX)	 =	 ''
	,@strSiteName									NVARCHAR(MAX)	 =	 ''
	,@strAddress									NVARCHAR(MAX)	 =	 ''
	,@strCity										NVARCHAR(MAX)	 =	 ''
	,@strState										NVARCHAR(MAX)	 =	 ''
	,@strPacPrideHostId								NVARCHAR(MAX)	 =	 ''
	,@strImportFilePath								NVARCHAR(MAX)	 =	 ''
	,@strImportFileName								NVARCHAR(MAX)	 =	 ''
	,@strAllowExemptionsOnExtAndRetailTrans			NVARCHAR(MAX)	 =	 ''

	--predefined--
	,@strDeliveryPickup								NVARCHAR(MAX)	 =	 ''
	,@strSiteType									NVARCHAR(MAX)	 =	 ''
	,@strControllerType								NVARCHAR(MAX)	 =	 ''
	,@strPPSiteType									NVARCHAR(MAX)	 =	 ''


	--boolean--
	,@strSiteAcceptsCreditCards						NVARCHAR(MAX)	 =	 ''
	,@strProcessCashSales							NVARCHAR(MAX)	 =	 ''
	,@strImportTripleEStock							NVARCHAR(MAX)	 =	 ''
	,@strPumpCalculatesExemptPrice					NVARCHAR(MAX)	 =	 ''
	,@strRecalculateTaxesOnRemote					NVARCHAR(MAX)	 =	 ''
	,@strImportContainsMultipleSites				NVARCHAR(MAX)	 =	 ''
	,@strCaptiveSite								NVARCHAR(MAX)	 =	 ''
	
	,@ysnOverwriteRecords							BIT				 =	 0


AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @ysnAllowBlankValues					  BIT = 0
	DECLARE @intSiteId								  INT = 0

	DECLARE @intDuplicateSite					      INT = 0

	DECLARE @ysnSiteAcceptsCreditCards				  BIT = 0
	DECLARE @ysnProcessCashSales					  BIT = 0
	DECLARE @ysnImportTripleEStock					  BIT = 0
	DECLARE @ysnPumpCalculatesExemptPrice			  BIT = 0
	DECLARE @ysnRecalculateTaxesOnRemote			  BIT = 0
	DECLARE @ysnImportContainsMultipleSites			  BIT = 0
	DECLARE @ysnCaptiveSite							  BIT = 0
	---------------------------------------------------------
	DECLARE @intNetworkId							  INT = 0
	DECLARE @intARLocation							  INT = 0
	DECLARE @intSiteGroup							  INT = 0
	DECLARE @intTaxGroup							  INT = 0
	DECLARE @intARCashCustomer						  INT = 0
	DECLARE @intImportMapping						  INT = 0
	DECLARE @strNetworkType							  NVARCHAR(50)
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------

	---------------------------------------------------------
	----				    OPTIONS			   			 ----
	---------------------------------------------------------
	IF(ISNULL(@ysnOverwriteRecords,0) = 1)
	BEGIN
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
				IF(@strSiteNumber = NULL OR @strSiteNumber = '')
				BEGIN
					SET @strSiteNumber = NEWID()
					INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
					VALUES (@strSiteNumber,'Site number is required')
					SET @ysnHasError = 1
				END
				ELSE
				BEGIN
					SELECT @intDuplicateSite = COUNT(*) FROM tblCFSite WHERE strSiteNumber = @strSiteNumber AND intNetworkId = @intNetworkId
					IF (@intDuplicateSite > 0)
					BEGIN
						SET @ysnAllowBlankValues = 1
					END
				END
			END
		END
	
		IF(@ysnHasError = 1)
		BEGIN
			RETURN
		END
	
	END


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
	IF(ISNULL(@ysnAllowBlankValues,0) = 0)
	BEGIN
		IF(@ysnHasError = 1)
		BEGIN
			RETURN
		END
	END

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
					

					IF(ISNULL(@ysnAllowBlankValues,0) = 1)
					BEGIN
						INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
						VALUES (@strSiteNumber,'[Overwrite Records] Duplicate site for '+ @strSiteNumber)
					END
					ELSE
					BEGIN
						INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
						VALUES (@strSiteNumber,'[Skipped Records] Duplicate site for '+ @strSiteNumber)
					END

					SET @ysnHasError = 1
				END
	
				---------------------------------------------------------
			END
		END
	ELSE
		BEGIN
			SET @intNetworkId = NULL
		END

	IF(ISNULL(@ysnAllowBlankValues,0) = 0)
	BEGIN
		IF(@ysnHasError = 1)
		BEGIN
			RETURN
		END
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

			SET @strSiteAcceptsCreditCards = NULL
			SET @ysnSiteAcceptsCreditCards = NULL

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

			SET @strProcessCashSales = NULL
			SET @ysnProcessCashSales = NULL
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

			SET @strImportTripleEStock = NULL
			SET @ysnImportTripleEStock = NULL
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

			SET @strPumpCalculatesExemptPrice = NULL
			SET @ysnPumpCalculatesExemptPrice = NULL
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

			SET @strRecalculateTaxesOnRemote = NULL
			SET @ysnRecalculateTaxesOnRemote = NULL
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

			
			SET @strImportContainsMultipleSites = NULL
			SET @ysnImportContainsMultipleSites = NULL
		END

		--CaptiveSite
	IF (@strCaptiveSite = 'N')
		BEGIN 
			SET @ysnCaptiveSite = 0
		END
	ELSE IF (@strCaptiveSite = 'Y')
		BEGIN
			SET @ysnCaptiveSite = 1	
		END
	ELSE
		BEGIN 
			
			IF(ISNULL(@ysnAllowBlankValues,0) = 0)
			BEGIN
				SET @ysnCaptiveSite = 0
			END
			ELSE
			BEGIN
				SET @ysnCaptiveSite = NULL
			END
		END



	IF (@strAllowExemptionsOnExtAndRetailTrans = 'N')
		BEGIN 
			SET @strAllowExemptionsOnExtAndRetailTrans = 'No'
		END
	ELSE IF (@strAllowExemptionsOnExtAndRetailTrans = 'Y')
		BEGIN
			SET @strAllowExemptionsOnExtAndRetailTrans = 'Yes'
		END
	ELSE
	BEGIN 
			IF(ISNULL(@ysnAllowBlankValues,0) = 0)
			BEGIN
				SELECT TOP 1 
				@strAllowExemptionsOnExtAndRetailTrans = strAllowExemptionsOnExtAndRetailTrans
				FROM tblCFNetwork
				WHERE intNetworkId = @intNetworkId
			END
			ELSE
			BEGIN
				SET @strAllowExemptionsOnExtAndRetailTrans = NULL
			END

	END



	---------------------------------------------------------


	--Delivery Pickup
	IF (@strDeliveryPickup not in ('Delivery','Pickup'))
	BEGIN 
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Invalid Delivery Pickup '+ @strDeliveryPickup +'. Value should be Delivery or Pickup only')
		SET @ysnHasError = 1

		SET @strDeliveryPickup = NULL
	END
	
	---------------------------------------------------------


	--SiteType
	IF (@strSiteType not in ('Local/Network','Remote','Extended Remote'))
	BEGIN 
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strSiteNumber,'Invalid Site Type '+ @strSiteType +'. Value should be Local/Network or Remote or Extended Remote only')
		SET @ysnHasError = 1

		
		SET @strSiteType = NULL
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

		
		SET @strControllerType = NULL
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

			
		SET @strPPSiteType = NULL
		END
	END
	ELSE
	BEGIN
		SET @strPPSiteType = NULL
	END

	
	---------------------------------------------------------

	IF(ISNULL(@ysnAllowBlankValues,0) = 0)
	BEGIN
		IF(@ysnHasError = 1)
		BEGIN
			RETURN
		END
	END


	
	---------------------------------------------------------
	----				    DEFAULT			   			 ----
	---------------------------------------------------------

	--SELECT TOP 1 
	--@strAllowExemptionsOnExtAndRetailTrans = strAllowExemptionsOnExtAndRetailTrans
	--FROM tblCFNetwork
	--WHERE intNetworkId = @intNetworkId

	
	---------------------------------------------------------


	---------------------------------------------------------
	--				INSERT ACCOUNT RECORD			       --		
	---------------------------------------------------------
	BEGIN TRANSACTION
		BEGIN TRY
			IF(ISNULL(@ysnAllowBlankValues,0) = 0)
			BEGIN
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
					,ysnCaptiveSite
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
					,@ysnCaptiveSite
				)
			END
			ELSE
			BEGIN
				UPDATE tblCFSite 
				SET  intARLocationId						=  (CASE WHEN ISNULL(@intARLocation,0)					!= 0		THEN @intARLocation ELSE selector.intARLocationId END)
					,intAdjustmentSiteGroupId				=  (CASE WHEN ISNULL(@intSiteGroup,0)					!= 0		THEN @intSiteGroup ELSE selector.intAdjustmentSiteGroupId END)       							
					,intTaxGroupId							=  (CASE WHEN ISNULL(@intTaxGroup,0)					!= 0		THEN @intTaxGroup ELSE selector.intTaxGroupId END)       										
					,intCashCustomerID						=  (CASE WHEN ISNULL(@intARCashCustomer,0)				!= 0		THEN @intARCashCustomer ELSE selector.intCashCustomerID END)       									
					,intImportMapperId						=  (CASE WHEN ISNULL(@intImportMapping,0)				!= 0		THEN @intImportMapping ELSE selector.intImportMapperId END)       											
					,strSiteName							=  (CASE WHEN ISNULL(@strSiteName,'')					!= ''		THEN @strSiteName ELSE selector.strSiteName END)       										
					,strSiteAddress							=  (CASE WHEN ISNULL(@strAddress,'')					!= ''		THEN @strAddress ELSE selector.strSiteAddress END)       										
					,strSiteCity							=  (CASE WHEN ISNULL(@strCity,'')						!= '' 		THEN @strCity ELSE selector.strSiteCity END)       										
					,strTaxState							=  (CASE WHEN ISNULL(@strState,'')						!= '' 		THEN @strState ELSE selector.strTaxState END)       										
					,intPPHostId							=  (CASE WHEN ISNULL(@strPacPrideHostId,'')				!= '' 		THEN @strPacPrideHostId ELSE selector.intPPHostId END)       										
					,strImportPath							=  (CASE WHEN ISNULL(@strImportFilePath,'')				!= '' 		THEN @strImportFilePath ELSE selector.strImportPath END)       										
					,strImportFileName						=  (CASE WHEN ISNULL(@strImportFileName,'')				!= '' 		THEN @strImportFileName ELSE selector.strImportFileName END)       									
					,strDeliveryPickup						=  (CASE WHEN ISNULL(@strDeliveryPickup,'')				!= '' 		THEN @strDeliveryPickup ELSE selector.strDeliveryPickup END)       									
					,strSiteType							=  (CASE WHEN ISNULL(@strSiteType,'')					!= '' 		THEN @strSiteType ELSE selector.strSiteType END)       										
					,strControllerType						=  (CASE WHEN ISNULL(@strControllerType,'')				!= '' 		THEN @strControllerType ELSE selector.strControllerType END)       									
					,strPPSiteType							=  (CASE WHEN ISNULL(@strPPSiteType,'')					!= '' 		THEN @strPPSiteType ELSE selector.strPPSiteType END)       										
					,ysnSiteAcceptsMajorCreditCards			=  (CASE WHEN @ysnSiteAcceptsCreditCards				IS NOT NULL THEN @ysnSiteAcceptsCreditCards ELSE selector.ysnSiteAcceptsMajorCreditCards END)       						
					,ysnProcessCashSales					=  (CASE WHEN @ysnProcessCashSales						IS NOT NULL THEN @ysnProcessCashSales ELSE selector.ysnProcessCashSales END)       								
					,ysnEEEStockItemDetail					=  (CASE WHEN @ysnImportTripleEStock					IS NOT NULL THEN @ysnImportTripleEStock ELSE selector.ysnEEEStockItemDetail END)       								
					,ysnPumpCalculatesTaxes					=  (CASE WHEN @ysnPumpCalculatesExemptPrice				IS NOT NULL THEN @ysnPumpCalculatesExemptPrice ELSE selector.ysnPumpCalculatesTaxes END)       								
					,ysnRecalculateTaxesOnRemote			=  (CASE WHEN @ysnRecalculateTaxesOnRemote				IS NOT NULL THEN @ysnRecalculateTaxesOnRemote ELSE selector.ysnRecalculateTaxesOnRemote END)       						
					,ysnMultipleSiteImport					=  (CASE WHEN @ysnImportContainsMultipleSites			IS NOT NULL THEN @ysnImportContainsMultipleSites ELSE selector.ysnMultipleSiteImport END)       								
					,strAllowExemptionsOnExtAndRetailTrans	=  (CASE WHEN @strAllowExemptionsOnExtAndRetailTrans	IS NOT NULL THEN @strAllowExemptionsOnExtAndRetailTrans ELSE selector.strAllowExemptionsOnExtAndRetailTrans END)       				
					,ysnCaptiveSite							=  (CASE WHEN @ysnCaptiveSite							IS NOT NULL THEN @ysnCaptiveSite ELSE selector.ysnCaptiveSite END)       		
				FROM tblCFSite AS selector
				WHERE strSiteNumber = @strSiteNumber 
				AND intNetworkId = @intNetworkId
			END

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