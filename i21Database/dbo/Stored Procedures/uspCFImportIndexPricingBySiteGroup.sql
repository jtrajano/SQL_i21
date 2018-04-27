﻿CREATE PROCEDURE [dbo].[uspCFImportIndexPricingBySiteGroup]
	
	 @strPriceIndex					NVARCHAR(MAX)	 =	 ''
	,@strSiteGroup					NVARCHAR(MAX)	 =	 ''
	,@dtmDate						DATETIME	     =	 NULL
	,@strItemNumber					NVARCHAR(MAX)	 =	 ''
	,@dblIndexPrice					NUMERIC(18,6)	 =	 0
AS
BEGIN
	---------------------------------------------------------
	----				    VARIABLES		   			 ----
	---------------------------------------------------------
	DECLARE @ysnHasError							  BIT = 0
	DECLARE @intDuplicateCard					      INT = 0
	---------------------------------------------------------
	DECLARE @intSiteGroupId							  INT = 0
	DECLARE @intPriceIndexId						  INT = 0
	DECLARE @intItemId								  INT = 0
	DECLARE @intIndexPricingBySiteGroupHeaderId		  INT = 0
	DECLARE @intIndexPricingBySiteGroupId			  INT = 0
	
	
	
	---------------------------------------------------------


	---------------------------------------------------------
	----				    VALIDATION		   			 ----
	---------------------------------------------------------
	
	---------------------------------------------------------
	--					 REQUIRED FIELDS				   --
	---------------------------------------------------------
	IF(@strPriceIndex = NULL OR @strPriceIndex = '')
	BEGIN
		SET @strPriceIndex = NEWID()
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Price Index is required')
		SET @ysnHasError = 1
	END
	IF(@strSiteGroup = NULL OR @strSiteGroup = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Site Group is required')
		SET @ysnHasError = 1
	END
	IF(@dtmDate = NULL OR @dtmDate = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Date is required')
		SET @ysnHasError = 1
	END
	IF(@strItemNumber = NULL OR @strItemNumber = '')
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strItemNumber,'Item Number is required')
		SET @ysnHasError = 1
	END
	---------------------------------------------------------

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	
	---------------------------------------------------------
	--				VALID VALUE TO OTHER TABLE		       --
	---------------------------------------------------------
	---Price Index
	IF (@strPriceIndex != '')
	BEGIN 
		SELECT @intPriceIndexId = intPriceIndexId
		FROM tblCFPriceIndex 
		WHERE strPriceIndex = @strPriceIndex


		IF (ISNULL(@intPriceIndexId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceIndex,'Unable to find match for '+ @strPriceIndex +' on site price index list')
			SET @ysnHasError = 1
		END
	END

	--Site Group
	IF (@strSiteGroup != '')
	BEGIN 
		SELECT @intSiteGroupId = intSiteGroupId
		FROM tblCFSiteGroup 
		WHERE strSiteGroup = @strSiteGroup

		IF (ISNULL(@intSiteGroupId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceIndex,'Unable to find match for '+ @strSiteGroup +' on site group list')
			SET @ysnHasError = 1
		END
	END
	
	--Product
	IF (@strItemNumber != '')
	BEGIN 
		SELECT @intItemId = intItemId
		FROM tblICItem 
		WHERE strItemNo = @strItemNumber

		IF (ISNULL(@intItemId,0) = 0)
		BEGIN
			INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
			VALUES (@strPriceIndex,'Unable to find match for '+ @strItemNumber +' on Item list')
			SET @ysnHasError = 1
		END
	END

	IF(@ysnHasError = 1)
	BEGIN
		RETURN
	END

	
	----------------------Check IndexPricingBySiteGroup Header

	SELECT TOP 1 @intIndexPricingBySiteGroupHeaderId = intIndexPricingBySiteGroupHeaderId
	FROM tblCFIndexPricingBySiteGroupHeader
	WHERE intPriceIndexId = @intPriceIndexId
		AND intSiteGroupId = @intSiteGroupId
		AND dtmDate = @dtmDate
	
	----- CHECK for IndexPricingBySiteGroup Detail
	SELECT TOP 1 @intIndexPricingBySiteGroupId = intIndexPricingBySiteGroupId
	FROM tblCFIndexPricingBySiteGroup
	WHERE intIndexPricingBySiteGroupHeaderId = @intIndexPricingBySiteGroupHeaderId
		AND intARItemID = @intItemId


	IF(ISNULL(@intIndexPricingBySiteGroupId,0) <> 0)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Item price for - ' + @strItemNumber + ' is changed to ' + CAST(@dblIndexPrice AS NVARCHAR(30)))
	END

	BEGIN TRANSACTION
	BEGIN TRY
		IF(ISNULL(@intIndexPricingBySiteGroupHeaderId,0) = 0)
		BEGIN
			----INSERt Header
			INSERT INTO tblCFIndexPricingBySiteGroupHeader(
				intPriceIndexId
				,intSiteGroupId
				,dtmDate)
			SELECT 
				@intPriceIndexId
				,@intSiteGroupId
				,@dtmDate

			SET @intIndexPricingBySiteGroupHeaderId = @@IDENTITY
		END


		IF(ISNULL(@intIndexPricingBySiteGroupId,0) <> 0)
		BEGIN
			UPDATE tblCFIndexPricingBySiteGroup SET
				intARItemID = @dblIndexPrice
			WHERE intIndexPricingBySiteGroupHeaderId = @intIndexPricingBySiteGroupHeaderId
				AND intARItemID = @intItemId
				AND intIndexPricingBySiteGroupId = @intIndexPricingBySiteGroupId
		END
		ELSE
		BEGIN
			---Insert Detail
			INSERT INTO tblCFIndexPricingBySiteGroup(
				intIndexPricingBySiteGroupHeaderId
				,intARItemID
				,dblIndexPrice)
			SELECT 
				@intIndexPricingBySiteGroupHeaderId
				,@intItemId
				,@dblIndexPrice
		END
		
		COMMIT TRANSACTION
		RETURN 1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Internal Error - ' + ERROR_MESSAGE())
		SET @ysnHasError = 1
		RETURN 0
	END CATCH
END
