CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportCount]
	@HandheldScannerId INT,
	@UserId INT,
	@NewInventoryCountId INT OUTPUT
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

	SELECT *
	INTO #ImportCounts
	FROM vyuSTGetHandheldScannerImportCount
	WHERE intHandheldScannerId = @HandheldScannerId

	DECLARE @NewId INT,
		@CountDate DATETIME = GETDATE(),
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


	EXEC uspICAddInventoryCount
	-- Header fields 
		@intLocationId = @CompanyLocationId
		,@dtmCountDate = @CountDate
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

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH