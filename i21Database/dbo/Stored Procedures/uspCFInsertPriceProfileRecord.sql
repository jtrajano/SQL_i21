﻿CREATE PROCEDURE [dbo].[uspCFInsertPriceProfileRecord]
	
	-----------------------------------------
	--				PARAMETERS			   --
	-----------------------------------------
	 @strPriceProfile				NVARCHAR(MAX)	 =	 ''
	,@strDescription				NVARCHAR(MAX)	 =	 ''
	,@strType						NVARCHAR(MAX)	 =	 ''
	,@strItemId						NVARCHAR(MAX)	 =	 ''
	,@strBasis						NVARCHAR(MAX)	 =	 ''
	,@strNetworkId					NVARCHAR(MAX)	 =	 ''
	,@strSiteGroupId				NVARCHAR(MAX)	 =	 ''
	,@strSiteId						NVARCHAR(MAX)	 =	 ''
	,@strLocalPricingIndex			NVARCHAR(MAX)	 =	 ''
	,@dblRate						NUMERIC(18,6)	 =    0
	,@ysnForceRounding				NVARCHAR(MAX)	 =	 ''
	,@ysnGlobalProfile				NVARCHAR(MAX)	 =	 ''
	,@strLinkedProfile				NVARCHAR(MAX)	 =	 ''

	---------------------------------------------------------
	 
AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @ysnCheckIndex							  BIT = 0
	DECLARE @intDuplicate						      INT = 0
	DECLARE @intId								      INT
	---------------------------------------------------------
	DECLARE @intItemId								  INT = NULL
	DECLARE @intNetworkId							  INT = NULL
	DECLARE @intSiteGroup							  INT = NULL
	DECLARE @intSiteId								  INT = NULL
	DECLARE @intLinkedProfileId						  INT = NULL
	DECLARE @intLocalPricingIndex					  INT = NULL
	---------------------------------------------------------

	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	IF (@ysnGlobalProfile = 'N')
		BEGIN 
			SET @ysnGlobalProfile = 0
		END
	ELSE IF (@ysnGlobalProfile = 'Y' OR @ysnGlobalProfile IS NULL OR @ysnGlobalProfile = '')
		BEGIN
			SET @ysnGlobalProfile = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@ysnGlobalProfile,'Invalid Global Profile value'+ @ysnGlobalProfile +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	IF (@ysnForceRounding = 'N')
		BEGIN 
			SET @ysnForceRounding = 0
		END
	ELSE IF (@ysnForceRounding = 'Y' OR @ysnForceRounding IS NULL OR @ysnForceRounding = '')
		BEGIN
			SET @ysnForceRounding = 1	
		END
	ELSE
		BEGIN 
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Invalid Force Rounding value'+ @ysnForceRounding +'. Value should be Y or N only')
			SET @ysnHasError = 1
		END

	IF(@strPriceProfile IS NULL OR @strPriceProfile = '')
	BEGIN
		SET @strPriceProfile = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceProfile,'Price Profile Code is required')
		SET @ysnHasError = 1
	END




	IF(@strType = 'Remote')
	BEGIN
		IF(@strBasis = 'Transfer Cost')
			BEGIN
				SET @ysnCheckIndex = 0
			END
		ELSE IF(LOWER(@strBasis) LIKE '%index%')
			BEGIN
				SET @strBasis = 'Index'
				SET @ysnCheckIndex = 1
			END
		ELSE
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strPriceProfile,'Invalid Price Basis')
				SET @ysnHasError = 1
			END
	END
	ELSE IF(@strType = 'Extended Remote')
	BEGIN
		IF(@strBasis = 'Pump Price Adjustment' OR @strBasis = 'Transfer Cost')
			BEGIN
				SET @ysnCheckIndex = 0
			END
		ELSE
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strPriceProfile,'Invalid Price Basis')
				SET @ysnHasError = 1
			END
	END
	ELSE IF(@strType = 'Local/Network')
	BEGIN
		IF(LOWER(@strBasis) LIKE '%index%')
			BEGIN
				SET @strBasis = 'Index'
				SET @ysnCheckIndex = 1
			END
		ELSE IF(@strBasis = 'Pump Price Adjustment' OR @strBasis = 'Transfer Cost')
			BEGIN
				SET @ysnCheckIndex = 0
			END
		ELSE
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strPriceProfile,'Invalid Price Basis')
				SET @ysnHasError = 1
			END
	END
	ELSE
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceProfile,'Invalid Price Profile Type')
		SET @ysnHasError = 1
	END


	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	---------------------------------------------------------
	--				VALID PREDEFINED VALUES			       --		
	---------------------------------------------------------
	
	--strLinkedProfile
	IF(@strLinkedProfile != '' AND @ysnGlobalProfile != 1)
	BEGIN
		SELECT @intLinkedProfileId = intPriceProfileHeaderId 
		FROM tblCFPriceProfileHeader 
		WHERE strPriceProfile = @strLinkedProfile
		AND strType = @strType
		AND ysnGlobalProfile = 1

		IF (@intLinkedProfileId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Unable to find match for '+ @strLinkedProfile +' on price profile list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intLinkedProfileId = NULL;
	END


	--LocalPricingIndex
	IF(@ysnCheckIndex = 1)
	BEGIN
		IF(@strLocalPricingIndex != '')
		BEGIN
			SELECT @intLocalPricingIndex = intPriceIndexId 
			FROM tblCFPriceIndex 
			WHERE strPriceIndex = @strLocalPricingIndex

			IF (@intLocalPricingIndex = 0)
			BEGIN
				INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
				VALUES (@strPriceProfile,'Unable to find match for '+ @strLocalPricingIndex +' on price index list')
				SET @ysnHasError = 1
			END
		END
		ELSE
		BEGIN
			SET @intLocalPricingIndex = NULL;
		END
	END

	--strSiteId
	IF(@strSiteId != '' )
	BEGIN
		SELECT @intSiteId = intSiteId 
		FROM tblCFSite 
		WHERE strSiteNumber = @strSiteId

		IF (@intSiteId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Unable to find match for '+ @strSiteId +' on site list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intSiteId = NULL;
	END

	--SiteGroup
	IF(@strSiteGroupId != '' )
	BEGIN
		SELECT @intSiteGroup = intSiteGroupId 
		FROM tblCFSiteGroup 
		WHERE strSiteGroup = @strSiteGroupId

		IF (@intSiteGroup = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Unable to find match for '+ @strSiteGroupId +' on site group list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intSiteGroup = NULL;
	END

	--Item
	IF(@strItemId != '')
	BEGIN
		SELECT @intItemId = intItemId 
		FROM tblICItem 
		WHERE strItemNo = @strItemId

		IF (@intItemId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Unable to find match for '+ @strItemId +' on item list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intItemId = NULL;
	END

	--Network
	IF(@strNetworkId != '' )
	BEGIN
		SELECT @intNetworkId = intNetworkId 
		FROM tblCFNetwork 
		WHERE strNetwork = @strNetworkId

		IF (@intNetworkId = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Unable to find match for '+ @strNetworkId +' on network list')
			SET @ysnHasError = 1
		END
	END
	ELSE
	BEGIN
		SET @intNetworkId = NULL;
	END

	
	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END


	SELECT TOP 1 @intId = intPriceProfileHeaderId 
	FROM tblCFPriceProfileHeader 
	WHERE strPriceProfile = @strPriceProfile

	IF(@intId IS NOT NULL AND @intId > 0)
	BEGIN

		--IF (@intFromQty = 0 AND @intThruQty = 0 AND (@dblRate = 0 OR @dblRate = 0.0))
		--BEGIN
		--	RETURN 1
		--END

		----------------------------------------------------------
		--				INSERT PRICE PROFILE RECORD			--		
		----------------------------------------------------------
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO tblCFPriceProfileDetail(
				 intPriceProfileHeaderId 
				,intItemId				
				,intNetworkId			
				,intSiteGroupId			
				,intSiteId				
				,intLocalPricingIndex	
				,dblRate					
				,strBasis	
				,ysnForceRounding				
				)
			VALUES(
				 @intId
				,@intItemId				
				,@intNetworkId			
				,@intSiteGroup			
				,@intSiteId				
				,@intLocalPricingIndex	
				,@dblRate					
				,@strBasis	
				,@ysnForceRounding	
				)
			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			ROLLBACK TRANSACTION
			RETURN 0
		END CATCH
	END
	ELSE
	BEGIN
		----------------------------------------------------------
		--				INSERT PRICE PROFILE RECORD			--		
		----------------------------------------------------------
		BEGIN TRANSACTION
		BEGIN TRY

			INSERT INTO tblCFPriceProfileHeader(
				 strPriceProfile
				,strDescription
				,strType	
				,intLinkedProfile
				,ysnGlobalProfile
			 )
			VALUES(
				 @strPriceProfile
				,@strDescription
				,@strType
				,@intLinkedProfileId
				,@ysnGlobalProfile
			 )

			SET @intId = SCOPE_IDENTITY()

			INSERT INTO tblCFPriceProfileDetail(
				 intPriceProfileHeaderId 
				,intItemId				
				,intNetworkId			
				,intSiteGroupId			
				,intSiteId				
				,intLocalPricingIndex	
				,dblRate					
				,strBasis
				,ysnForceRounding				
				)
			VALUES(
				 @intId
				,@intItemId				
				,@intNetworkId			
				,@intSiteGroup			
				,@intSiteId				
				,@intLocalPricingIndex	
				,@dblRate					
				,@strBasis		
				,@ysnForceRounding
				)
			COMMIT TRANSACTION
			RETURN 1
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceProfile,'Internal Error - ' + ERROR_MESSAGE())
			SET @ysnHasError = 1
			RETURN 0
		END CATCH
	END
END