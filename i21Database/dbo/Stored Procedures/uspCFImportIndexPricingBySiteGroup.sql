CREATE PROCEDURE [dbo].[uspCFImportIndexPricingBySiteGroup]
	
	@intResult						INT				 OUT --- 0 = haserror, 1 = inserted, 2 = skipped, 3= updated
	,@strPriceIndex					NVARCHAR(MAX)	 =	 ''
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
	DECLARE @intVehicleId							  INT = 0
	DECLARE @intAccountId							  INT = 0
	DECLARE @intExpenseItemId						  INT = 0
	DECLARE @intDepartmentId						  INT = 0
	DECLARE @strAccountId		NVARCHAR(30)
	DECLARE @strVehicleNumber	NVARCHAR(30)
	DECLARE @strDepartment		NVARCHAR(30)
	DECLARE @strExpenseItemId		NVARCHAR(30)
	DECLARE @ysnCardForOwnUse BIT
     
	DECLARE @strCustomerUnitNumber NVARCHAR(30)
	DECLARE @strVehicleDescription NVARCHAR(30)
	DECLARE @strLicencePlateNumber NVARCHAR(30)

	DECLARE @intDaysBetweenService INT = 0
	DECLARE @intMilesBetweenService INT = 0
	DECLARE @intLastReminderOdometer INT = 0
	DECLARE @dtmLastReminderDate DATETIME
	DECLARE @dtmLastServiceDate DATETIME
	DECLARE @intLastServiceOdometer INT = 0
	DECLARE @strNoticeMessageLine1 NVARCHAR(30)
	DECLARE @ysnActive BIT 
	DECLARE @intSiteGroupId							  INT = 0
	DECLARE @intPriceIndexId						  INT = 0
	DECLARE @intItemId								  INT = 0
	DECLARE @intIndexPricingBySiteGroupHeaderId		  INT = 0
	DECLARE @intIndexPricingBySiteGroupId			  INT = 0
	DECLARE @intIndexPricingBySiteGroupIdPriceCheck   INT = 0
	DECLARE @dblOldIndexPrice						  NUMERIC(18,6) = 0
	
	
	
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
		SET @intResult = 0
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
		SET @intResult = 0
		RETURN 0
	END

	
	----------------------Check IndexPricingBySiteGroup Header

	SELECT TOP 1 @intIndexPricingBySiteGroupHeaderId = intIndexPricingBySiteGroupHeaderId
	FROM tblCFIndexPricingBySiteGroupHeader
	WHERE intPriceIndexId = @intPriceIndexId
		AND intSiteGroupId = @intSiteGroupId
		AND dtmDate = @dtmDate

	

	----- CHECK for IndexPricingBySiteGroup For same price
	SELECT TOP 1 @intIndexPricingBySiteGroupIdPriceCheck = intIndexPricingBySiteGroupId
	FROM tblCFIndexPricingBySiteGroup
	WHERE intIndexPricingBySiteGroupHeaderId = @intIndexPricingBySiteGroupHeaderId
		AND intARItemID = @intItemId
		AND dblIndexPrice = @dblIndexPrice
	
	IF(ISNULL(@intIndexPricingBySiteGroupIdPriceCheck,0) <> 0)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Duplicate record/Same price - Skipped')
		SET @intResult = 3
		RETURN 
	END
	
	----- CHECK for IndexPricingBySiteGroup Detail
	SELECT TOP 1 
		@intIndexPricingBySiteGroupId = intIndexPricingBySiteGroupId
		,@dblOldIndexPrice = dblIndexPrice
	FROM tblCFIndexPricingBySiteGroup
	WHERE intIndexPricingBySiteGroupHeaderId = @intIndexPricingBySiteGroupHeaderId
		AND intARItemID = @intItemId

	IF(ISNULL(@intIndexPricingBySiteGroupId,0) <> 0)
	BEGIN
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Item price for - ' + @strItemNumber + ' is changed from ' + CAST(@dblOldIndexPrice AS NVARCHAR(30)) + ' to ' + CAST(@dblIndexPrice AS NVARCHAR(30)))
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
				dblIndexPrice = @dblIndexPrice
			WHERE intIndexPricingBySiteGroupHeaderId = @intIndexPricingBySiteGroupHeaderId
				AND intARItemID = @intItemId
				AND intIndexPricingBySiteGroupId = @intIndexPricingBySiteGroupId
			SET @intResult = 3
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
			SET @intResult = 1
		END
		
		COMMIT TRANSACTION
		RETURN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		INSERT tblCFImportFromCSVLog (strImportFromCSVId,strNote)
		VALUES (@strPriceIndex,'Internal Error - ' + ERROR_MESSAGE())
		SET @ysnHasError = 1
		SET @intResult = 0
		RETURN 0
	END CATCH
END
