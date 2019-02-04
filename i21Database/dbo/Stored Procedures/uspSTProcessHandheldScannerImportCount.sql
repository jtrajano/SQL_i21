CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportCount]
	@HandheldScannerId INT,
	@UserId INT,
	@dtmCountDate DATETIME,
	@NewInventoryCountId INT OUTPUT,
	@ysnSuccess BIT OUTPUT,
	@strStatusMsg NVARCHAR(1000) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @intEntityId int;

BEGIN TRY
	
	--------------------------------------------------------------------------------------
	-------------------- Start Validate if has record to Process -------------------------
	--------------------------------------------------------------------------------------
	IF NOT EXISTS(SELECT TOP 1 1 FROM vyuSTGetHandheldScannerImportCount WHERE intHandheldScannerId = @HandheldScannerId)
		BEGIN
			-- Flag Failed
			SET @NewInventoryCountId = 0
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'There are no records to process.'
			RETURN
		END
	--------------------------------------------------------------------------------------
	-------------------- End Validate if has record to Process ---------------------------
	--------------------------------------------------------------------------------------

	SELECT *
	INTO #ImportCounts
	FROM vyuSTGetHandheldScannerImportCount
	WHERE intHandheldScannerId = @HandheldScannerId

	DECLARE @NewId INT,
		--@CountDate DATETIME = @dtmCountDate,
		@CompanyLocationId INT,
		@CountRecords InventoryCountStagingTable

	SELECT TOP 1 @CompanyLocationId = intCompanyLocationId FROM #ImportCounts

	INSERT INTO @CountRecords(intItemId
		,intItemUOMId
		,dblPhysicalCount)
	SELECT intItemId
		, intItemUOMId
		, dblCountQty
	FROM #ImportCounts

	SET @strStatusMsg = ''

	--------------------------------------------------------------------------------------
	--------- Start Validate if items does not have intItemUOMId -------------------------
	--------------------------------------------------------------------------------------
	IF EXISTS (SELECT TOP 1 1 FROM vyuSTGetHandheldScannerImportCount WHERE intHandheldScannerId = @HandheldScannerId AND intItemUOMId IS NULL)
		BEGIN
			DECLARE @strItemNoHasNoUOM AS NVARCHAR(MAX)

			SELECT @strItemNoHasNoUOM = COALESCE(@strItemNoHasNoUOM + ', ', '') + strItemNo
			FROM vyuSTGetHandheldScannerImportCount
			WHERE intHandheldScannerId = @HandheldScannerId
			AND intItemUOMId IS NULL

			-- Flag Failed
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'Selected Item/s ' + @strItemNoHasNoUOM + ' has no default UOM'
			SET @NewInventoryCountId = 0
			RETURN
		END
	--------------------------------------------------------------------------------------
	--------- End Validate if items does not have intItemUOMId ---------------------------
	--------------------------------------------------------------------------------------

	EXEC uspICAddInventoryCount
	-- Header fields 
		@intLocationId = @CompanyLocationId
		,@dtmCountDate = @dtmCountDate
		,@intCategoryId	= NULL 
		,@intCommodityId = NULL 
		,@intCountGroupId = NULL  	
		,@intSubLocationId = NULL  	
		,@intStorageLocationId = NULL  	
		,@strDescription = 'Imported from Handheld Scanner'  	
		,@ysnIncludeZeroOnHand = 0  	
		,@ysnIncludeOnHand = NULL  	
		,@ysnScannedCountEntry = NULL  	
		,@ysnCountByLots = 0  	
		,@strCountBy = 'Item' -- Possible values: (1) Item or (2) Pack. 
		,@ysnCountByPallets	= 0
		,@ysnRecountMismatch = 0
		,@ysnExternal = 0
		,@ysnRecount = 0
		,@intRecountReferenceId	= NULL  	
		,@strShiftNo = NULL 
		,@intImportFlagInternal	= NULL 
		,@intEntityUserSecurityId = @UserId
		,@strSourceId = NULL
		,@strSourceScreenName = NULL
		,@CountDetails = @CountRecords
		,@intInventoryCountId = @NewId OUTPUT  

	DROP TABLE #ImportCounts


	SET @NewInventoryCountId = @NewId

	-- Clear record from table
	DELETE FROM tblSTHandheldScannerImportCount 
	WHERE intHandheldScannerId = @HandheldScannerId

	-- Flag Success
	SET @ysnSuccess = CAST(1 AS BIT)
	SET @strStatusMsg = ''
END TRY

BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Flag Failed
	SET @ysnSuccess = CAST(0 AS BIT)
	SET @strStatusMsg = 'Catch error'
	SET @NewInventoryCountId = 0

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH