﻿CREATE PROCEDURE [dbo].[uspSTProcessHandheldScannerImportCount]
	@HandheldScannerId				INT,
	@UserId							INT,
	@dtmCountDate					DATETIME,
	@intProcessType					INT,
	@strCountNo						NVARCHAR(100),
	@NewInventoryCountId			INT OUTPUT,
	@ysnSuccess						BIT OUTPUT,
	@strStatusMsg					NVARCHAR(1000) OUTPUT,
	@strItemNosWithInvalidLocation	NVARCHAR(MAX) OUTPUT
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


	DECLARE @intCompanyLocationId INT = (
											SELECT 
												st.intCompanyLocationId 
											FROM tblSTStore st
											INNER JOIN tblSTHandheldScanner hs
												ON st.intStoreId = hs.intStoreId
											WHERE hs.intHandheldScannerId = @HandheldScannerId
										)
	
	SET @strItemNosWithInvalidLocation = NULL

	--------------------------------------------------------------------------------------
	-------------------- Start Validate if has record to Process -------------------------
	--------------------------------------------------------------------------------------
	IF NOT EXISTS(SELECT TOP 1 1 FROM vyuSTGetHandheldScannerImportCount WHERE intHandheldScannerId = @HandheldScannerId)
		BEGIN
			-- Flag Failed
			SET @NewInventoryCountId = 0
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'There are no records to process.'
			SET @strItemNosWithInvalidLocation	=  NULL
			
			GOTO ExitWithRollback
		END
	--------------------------------------------------------------------------------------
	-------------------- End Validate if has record to Process ---------------------------
	--------------------------------------------------------------------------------------


	--------------------------------------------------------------------------------------
	------------ Start Validate if All Items have the same Store Location ----------------
	--------------------------------------------------------------------------------------
	IF EXISTS(
				SELECT TOP 1 1 
				FROM tblSTHandheldScannerImportCount importCount
				INNER JOIN tblSTHandheldScanner HS
					ON importCount.intHandheldScannerId = HS.intHandheldScannerId
				INNER JOIN tblSTStore ST
					ON HS.intStoreId = ST.intStoreId
				INNER JOIN tblICItem Item
					ON importCount.intItemId = Item.intItemId
				LEFT JOIN tblICItemLocation ItemLoc
					ON Item.intItemId = ItemLoc.intItemId
						AND ST.intCompanyLocationId = ItemLoc.intLocationId
				WHERE importCount.intHandheldScannerId = @HandheldScannerId
					AND (ST.intCompanyLocationId != @intCompanyLocationId OR ItemLoc.intItemLocationId IS NULL)
			 )
		BEGIN
			DECLARE @strItemNoLocationSameAsStore AS NVARCHAR(MAX)


			SELECT 
				@strItemNoLocationSameAsStore = COALESCE(@strItemNoLocationSameAsStore + ', ', '') + Item.strItemNo
			FROM tblSTHandheldScannerImportCount importCount
			INNER JOIN tblSTHandheldScanner HS
				ON importCount.intHandheldScannerId = HS.intHandheldScannerId
			INNER JOIN tblSTStore ST
				ON HS.intStoreId = ST.intStoreId
			INNER JOIN tblICItem Item
				ON importCount.intItemId = Item.intItemId
			LEFT JOIN tblICItemLocation ItemLoc
				ON Item.intItemId = ItemLoc.intItemId
					AND ST.intCompanyLocationId = ItemLoc.intLocationId
			WHERE importCount.intHandheldScannerId = @HandheldScannerId
				AND (ST.intCompanyLocationId != @intCompanyLocationId OR ItemLoc.intItemLocationId IS NULL)


			-- Flag Failed
			SET @NewInventoryCountId = 0
			SET @ysnSuccess = CAST(0 AS BIT)
			SET @strStatusMsg = 'Selected Item/s  ' + @strItemNoLocationSameAsStore + '  has no location setup same as location of selected Store.'
			SET @strItemNosWithInvalidLocation	=  @strItemNoLocationSameAsStore

			GOTO ExitWithRollback
		END
	--------------------------------------------------------------------------------------
	------------- End Validate if All Items have the same Store Location -----------------
	--------------------------------------------------------------------------------------

	--SELECT *
	--INTO #ImportCounts
	--FROM vyuSTGetHandheldScannerImportCount ImportCount
	--WHERE ImportCount.intHandheldScannerId = @HandheldScannerId

	SELECT intHandheldScannerId
		   , intStoreId
		   , intStoreNo
		   , intCompanyLocationId 
		   , intUnitMeasureId
		   , strUPCNo
		   , intItemId
		   , strItemNo
		   , strDescription
		   , intItemUOMId
		   , strUnitMeasure
		   , intItemLocationId
		   , SUM(dblComputedCount) AS dblComputedCount
	INTO #ImportCounts
	FROM vyuSTGetHandheldScannerImportCountWithRecipe
	WHERE intHandheldScannerId = @HandheldScannerId
	GROUP BY intHandheldScannerId, intStoreId, intStoreNo, intCompanyLocationId, intUnitMeasureId, strUPCNo, intItemId, strItemNo, strDescription, intItemUOMId, strUnitMeasure, intItemLocationId


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
		, dblComputedCount
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
			SET @strItemNosWithInvalidLocation	=  NULL

			GOTO ExitWithRollback
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
					--, @intCompanyLocationId INT
					, @intItemUOMId INT
					, @ysnUpdatedOutdatedStock BIT

			-- Loop here
			WHILE (SELECT COUNT(*) FROM #ImportCounts) > 0
				BEGIN
					
					DECLARE @intRemainingRecord INT = (SELECT COUNT(intItemId) FROM #ImportCounts)
					IF(@intRemainingRecord = 1)
						BEGIN
							SET @ysnUpdatedOutdatedStock = CAST(1 AS BIT)
						END
					ELSE 
						BEGIN
							SET @ysnUpdatedOutdatedStock = CAST(0 AS BIT)
						END
					
					
					-- Get values
					SELECT TOP 1 
						@intItemId = Imports.intItemId
						, @intItemUOMId = Imports.intItemUOMId
						, @intItemLocationId = IL.intItemLocationId
						--, @intCompanyLocationId = Store.intCompanyLocationId
						, @dblCountQty = Imports.dblComputedCount
					FROM #ImportCounts Imports
					INNER JOIN tblSTStore Store
						ON Imports.intStoreId = Store.intStoreId
					INNER JOIN tblICItemLocation IL
						ON Imports.intItemId = IL.intItemId
						AND Store.intCompanyLocationId = IL.intLocationId


					-- UPDATE Item
					BEGIN TRY
						EXEC uspICUpdateInventoryPhysicalCount
							-- Count No and Physical Count are required
							@strCountNo			= @strCountNo,
							@dblPhysicalCount	= @dblCountQty,

							-- ========================================
							--    Required for a lotted item
							-- ========================================
							-- Set this to NULL for a non-lotted item
							@intLotId = NULL,

							-- This is also required
							@intUserSecurityId	= @UserId,

							-- ========================================
							--    Parameters for a non-lotted item
							-- ========================================
							-- Required for a non-lotted item
							@intItemId			= @intItemId,
							@intItemLocationId	= @intItemLocationId,

							-- Set this to change the Count UOM 
							@intItemUOMId		= @intItemUOMId,
							-- Set these to change the storage unit/loc
							@intStorageLocationId = NULL,
							@intStorageUnitId	= NULL,

							-- Will be responsible to Update Outdated Stocks
							-- Logic here is to Update Outdated Stocks on the last record of the while loop
							@ysnUpdatedOutdatedStock = @ysnUpdatedOutdatedStock 
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
					WHERE intItemId				= @intItemId
						AND intItemUOMId		= @intItemUOMId
						AND intItemLocationId	= @intItemLocationId
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
	SET @ysnSuccess						= CAST(1 AS BIT)
	SET @strStatusMsg					= ''
	SET @strItemNosWithInvalidLocation	= NULL

	-- COMMIT
	GOTO ExitWithCommit
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Flag Failed
	SET @ysnSuccess						= CAST(0 AS BIT)
	SET @strStatusMsg					= 'Catch error'
	SET @NewInventoryCountId			= 0
	SET @strItemNosWithInvalidLocation	= NULL

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