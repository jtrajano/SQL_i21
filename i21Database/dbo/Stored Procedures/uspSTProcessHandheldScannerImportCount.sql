CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportCount]
	@HandheldScannerId INT,
	@UserId INT,
	@dtmCountDate DATETIME,
	@intProcessType INT,
	@strCountNo NVARCHAR(100),
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
	
	BEGIN TRANSACTION

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
	FROM vyuSTGetHandheldScannerImportCount ImportCount
	WHERE ImportCount.intHandheldScannerId = @HandheldScannerId

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

	-- Process Type
	-- 1 = 'Create'
	-- 2 = 'Update'

	IF(@intProcessType = 1)
		BEGIN
			-- ======================================================================================================================
			-- START CREATE COUNT----------------------------------------------------------------------------------------------------
			-- ======================================================================================================================

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

			-- ======================================================================================================================
			-- END CREATE COUNT----------------------------------------------------------------------------------------------------
			-- ======================================================================================================================
		END

	ELSE IF(@intProcessType = 2)
		BEGIN
			-- ======================================================================================================================
			-- START UPDATE COUNT----------------------------------------------------------------------------------------------------
			-- ======================================================================================================================

			SET @NewId = 0 -- No new id if 'Update'
			DECLARE @intPrimaryCountId INT
					, @dblCountQty DECIMAL(18, 6)
					, @intItemId INT
					, @intItemLocationId INT
					, @intItemUOMId INT

			-- Loop here
			WHILE (SELECT COUNT(*) FROM #ImportCounts) > 0
				BEGIN
					-- Get Primary Id
					SELECT TOP 1 
						@intPrimaryCountId = intHandheldScannerImportCountId
						, @dblCountQty = dblCountQty
						, @intItemId = intItemId
						, @intItemLocationId = intItemLocationId
						, @intItemUOMId = intItemUOMId
					FROM #ImportCounts

					-- Update
					BEGIN TRY
						EXEC uspICUpdateInventoryPhysicalCount
							-- Count No and Physical Count are required
							@strCountNo = @strCountNo,
							@dblPhysicalCount = @dblCountQty,

							-- ========================================
							--    Required for a lotted item
							-- ========================================
							-- Set this to NULL for a non-lotted item
							@intLotId = NULL,

							-- This is also required
							@intUserSecurityId = @UserId,

							-- ========================================
							--    Parameters for a non-lotted item
							-- ========================================
							-- Required for a non-lotted item
							@intItemId = @intItemId,
							@intItemLocationId = @intItemLocationId,

							-- Set this to change the Count UOM 
							@intItemUOMId = @intItemUOMId,
							-- Set these to change the storage unit/loc
							@intStorageLocationId = NULL,
							@intStorageUnitId = NULL
					END TRY
					BEGIN CATCH
						-- Flag Success
						SET @ysnSuccess = CAST(0 AS BIT)
						SET @strStatusMsg = ERROR_MESSAGE()

						-- ROLLBACK
						GOTO ExitWithRollback
					END CATCH

					-- Remove record after use
					DELETE FROM #ImportCounts
					WHERE intHandheldScannerImportCountId = @intPrimaryCountId
				END

			-- ======================================================================================================================
			-- END UPDATE COUNT----------------------------------------------------------------------------------------------------
			-- ======================================================================================================================
		END
	

	DROP TABLE #ImportCounts

	SET @NewInventoryCountId = @NewId

	-- Clear record from table
	DELETE FROM tblSTHandheldScannerImportCount 
	WHERE intHandheldScannerId = @HandheldScannerId

	-- Flag Success
	SET @ysnSuccess = CAST(1 AS BIT)
	SET @strStatusMsg = ''

	-- COMMIT
	GOTO ExitWithCommit
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

	-- ROLLBACK
	GOTO ExitWithRollback
END CATCH


ExitWithCommit:
	-- Commit Transaction
	COMMIT TRANSACTION --@TransactionName
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION --@TransactionName
		END
	
ExitPost: