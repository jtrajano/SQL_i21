CREATE PROCEDURE [dbo].[uspICAddInventoryCount]
	-- Header fields 
	@intLocationId AS INT
	,@dtmCountDate AS DATETIME = NULL 
	,@intCategoryId	AS INT = NULL 
	,@intCommodityId AS INT = NULL 
	,@intCountGroupId AS INT = NULL  	
	,@intSubLocationId AS INT = NULL  	
	,@intStorageLocationId AS INT = NULL  	
	,@strDescription AS NVARCHAR(200) = NULL  	
	,@ysnIncludeZeroOnHand AS BIT = NULL  	
	,@ysnIncludeOnHand AS BIT = NULL  	
	,@ysnScannedCountEntry AS BIT = NULL  	
	,@ysnCountByLots AS BIT = NULL  	
	,@strCountBy AS NVARCHAR(50) = 'Item' -- Possible values: (1) Item or (2) Pack. 
	,@ysnCountByPallets	AS BIT = NULL  	
	,@ysnRecountMismatch AS BIT = NULL  	
	,@ysnExternal AS BIT = NULL  	
	,@ysnRecount AS BIT = NULL  	
	,@intRecountReferenceId	AS INT = NULL  	
	,@strShiftNo AS NVARCHAR(50) = NULL 
	,@intImportFlagInternal	AS INT = NULL 
	,@intEntityUserSecurityId AS INT	
	,@strSourceId AS NVARCHAR(50) 
	,@strSourceScreenName AS NVARCHAR(50)
	,@CountDetails InventoryCountStagingTable READONLY 
	,@intInventoryCountId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Exit immediately if location is null 
IF @intLocationId IS NULL
	GOTO _Exit; 
	
-- Exit immediately if Security Entity Id is null 
IF @intEntityUserSecurityId IS NULL
	GOTO _Exit; 

DECLARE @StartingNumberId_InventoryCount AS INT = 76
		,@InventoryCountNumber AS NVARCHAR(50)		

DECLARE @Status_Open AS INT = 1
		,@Status_CountSheetPrinted AS INT = 2
		,@Status_InventoryLocked AS INT = 3
		,@Status_Closed AS INT = 4

-- Generate the transfer starting number
BEGIN 
	-- If @InventoryCountNumber IS NULL, uspSMGetStartingNumber will throw an error. 
	-- Error is 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryCount, @InventoryCountNumber OUTPUT, @intLocationId
	IF @@ERROR <> 0 OR @InventoryCountNumber IS NULL GOTO _Exit;
END 

-- Generate the header record
IF @InventoryCountNumber IS NOT NULL 
BEGIN 
	-- Validate Location Id	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intLocationId)
	BEGIN
		-- Location Id is invalid or missing.
		EXEC uspICRaiseError 80137;
		RETURN -80137
	END

	INSERT INTO tblICInventoryCount (
		strCountNo
		,intLocationId
		,intCategoryId
		,intCommodityId
		,intCountGroupId
		,dtmCountDate		
		,intSubLocationId
		,intStorageLocationId
		,strDescription
		,ysnIncludeZeroOnHand
		,ysnIncludeOnHand
		,ysnScannedCountEntry
		,ysnCountByLots
		,strCountBy
		,ysnCountByPallets
		,ysnRecountMismatch
		,ysnExternal
		,ysnRecount
		,intRecountReferenceId
		,intStatus
		,ysnPosted
		,intEntityId
		,strShiftNo
		,intImportFlagInternal
		,intSort
		,intConcurrencyId
	)
	SELECT 
		strCountNo = @InventoryCountNumber
		,intLocationId = @intLocationId
		,intCategoryId = @intCategoryId
		,intCommodityId = @intCommodityId
		,intCountGroupId = @intCountGroupId
		,dtmCountDate = dbo.fnRemoveTimeOnDate(ISNULL(@dtmCountDate, GETDATE()))		
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,strDescription = @strDescription
		,ysnIncludeZeroOnHand = ISNULL(@ysnIncludeZeroOnHand, 0)
		,ysnIncludeOnHand = ISNULL(@ysnIncludeOnHand, 0)
		,ysnScannedCountEntry = ISNULL(@ysnScannedCountEntry, 0)
		,ysnCountByLots = ISNULL(@ysnCountByLots, 0)
		,strCountBy = @strCountBy
		,ysnCountByPallets = ISNULL(@ysnCountByPallets, 0)
		,ysnRecountMismatch = ISNULL(@ysnRecountMismatch, 0)
		,ysnExternal = ISNULL(@ysnExternal, 0)
		,ysnRecount = ISNULL(@ysnRecount, 0)
		,intRecountReferenceId = @intRecountReferenceId
		,intStatus = @Status_Open 
		,ysnPosted = 0 
		,intEntityId = @intEntityUserSecurityId
		,strShiftNo = @strShiftNo
		,intImportFlagInternal = @intImportFlagInternal
		,intSort = 1
		,intConcurrencyId = 1
	FROM tblEMEntity e
	WHERE	e.intEntityId = @intEntityUserSecurityId
	
	SET @intInventoryCountId = SCOPE_IDENTITY()
END 

-- Insert the details. 
IF @intInventoryCountId IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM @CountDetails) 
BEGIN 
	DECLARE @validate_intItemId INT = NULL
			,@validate_strItemNo AS NVARCHAR(50) 
			,@validate_intSubLocationId AS INT
			,@validate_intStorageLocationId AS INT 

	-- Validate Item Id
	BEGIN 
		SELECT TOP 1 
				@validate_intItemId = RawData.intItemId
		FROM	@CountDetails RawData LEFT JOIN tblICItem i
					ON i.intItemId = RawData.intItemId
		WHERE	i.intItemId IS NULL 

		IF @validate_intItemId IS NOT NULL 
		BEGIN
			SET @validate_strItemNo = CAST(@validate_intItemId AS NVARCHAR(50))

			-- Item Id {Item Id} invalid.
			EXEC uspICRaiseError 80117, @validate_strItemNo;
			RETURN -80117;
		END
	END

	-- Validate Item UOM Id
	BEGIN 
		SELECT	TOP 1  
				@validate_intItemId = RawData.intItemId
				,@validate_strItemNo = i.strItemNo 
		FROM	@CountDetails RawData LEFT JOIN tblICItem i
					ON RawData.intItemId = i.intItemId 
				LEFT JOIN tblICItemUOM iu 
					ON iu.intItemUOMId = RawData.intItemUOMId
		WHERE	iu.intItemUOMId IS NULL 

		IF @validate_intItemId IS NOT NULL 
		BEGIN
			-- Item UOM Id is invalid or missing for {Item}.
			EXEC uspICRaiseError 80120, @validate_strItemNo;
			RETURN -80120;
		END
	END

	-- Validate Sub Location Id
	BEGIN 
		SELECT TOP 1 
				@validate_intSubLocationId = @intSubLocationId
				,@validate_strItemNo = i.strItemNo 
		FROM	@CountDetails RawData LEFT JOIN tblICItem i
					ON RawData.intItemId = i.intItemId 	
				OUTER APPLY (
					SELECT	TOP 1 
							intCompanyLocationSubLocationId 
					FROM	tblSMCompanyLocationSubLocation sub 
					WHERE	sub.intCompanyLocationSubLocationId = @intSubLocationId
							AND sub.intCompanyLocationId = @intLocationId 
				) subLocation
		WHERE	subLocation.intCompanyLocationSubLocationId IS NULL 		
				AND @intSubLocationId IS NOT NULL 		

		IF @validate_intSubLocationId IS NOT NULL 
		BEGIN
			-- 'Sub Location is invalid or missing for item {Item}.'
			EXEC uspICRaiseError 80097, @validate_strItemNo
			RETURN -80097;
		END
	END

	-- Validate Storage Location Id
	BEGIN 
		SELECT TOP 1 
				@validate_intStorageLocationId = @intStorageLocationId
				,@validate_strItemNo = i.strItemNo 
		FROM	@CountDetails RawData LEFT JOIN tblICItem i
					ON RawData.intItemId = i.intItemId 	
				OUTER APPLY (
					SELECT	TOP 1 
							intStorageLocationId 
					FROM	tblICStorageLocation storage 
					WHERE	storage.intStorageLocationId = @intStorageLocationId
							AND storage.intSubLocationId = @intSubLocationId
				) storage
		WHERE	storage.intStorageLocationId IS NULL 		
				AND @intStorageLocationId IS NOT NULL 

		IF @validate_intStorageLocationId IS NOT NULL 
		BEGIN
			-- Storage Unit is invalid or missing for item {Item}.
			EXEC uspICRaiseError 80098, @validate_strItemNo
			RETURN -80098;
		END
	END

	INSERT INTO tblICInventoryCountDetail (
		intInventoryCountId
		,intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,intCountGroupId
		,intLotId
		,strLotNo
		,strLotAlias
		,intParentLotId
		,strParentLotNo
		,strParentLotAlias
		,intStockUOMId
		,dblSystemCount
		,dblLastCost
		,strAutoCreatedLotNumber
		,strCountLine
		,dblPallets
		,dblQtyPerPallet
		,dblPhysicalCount
		,intItemUOMId
		,intWeightUOMId
		,dblWeightQty
		,dblNetQty
		,ysnRecount
		,dblQtyReceived
		,dblQtySold
		,intEntityUserSecurityId
		,ysnFetched
		,intSort
		,intConcurrencyId
	)
	SELECT
		intInventoryCountId			= @intInventoryCountId
		,intItemId					= i.intItemId  
		,intItemLocationId			= il.intItemLocationId
		,intSubLocationId			= @intSubLocationId
		,intStorageLocationId		= @intStorageLocationId
		,intCountGroupId			= @intCountGroupId
		,intLotId					= NULL 
		,strLotNo					= NULL 
		,strLotAlias				= NULL 
		,intParentLotId				= NULL 
		,strParentLotNo				= NULL 
		,strParentLotAlias			= NULL 
		,intStockUOMId				= NULL 
		,dblSystemCount				= ISNULL(itemStockAndPricing.dblOnHand, 0) 
		,dblLastCost				= ISNULL(itemStockAndPricing.dblLastCost, 0) 
		,strAutoCreatedLotNumber	= NULL 
		,strCountLine				= @InventoryCountNumber + '-' + CAST(items.intId AS NVARCHAR(20))
		,dblPallets					= 0.00
		,dblQtyPerPallet			= 0.00
		,dblPhysicalCount			= items.dblPhysicalCount
		,intItemUOMId				= items.intItemUOMId
		,intWeightUOMId				= NULL 
		,dblWeightQty				= NULL 
		,dblNetQty					= NULL 
		,ysnRecount					= 0 
		,dblQtyReceived				= NULL 
		,dblQtySold					= NULL 
		,intEntityUserSecurityId	= @intEntityUserSecurityId
		,ysnFetched					= 0
		,intSort					= items.intId
		,intConcurrencyId			= 1
	FROM 
		@CountDetails items INNER JOIN tblICItem i
			ON items.intItemId = i.intItemId 
		INNER JOIN tblICItemLocation il 
			ON items.intItemId = il.intItemId
			AND il.intLocationId = @intLocationId 
		INNER JOIN tblICInventoryCount inventoryCount
			ON inventoryCount.intInventoryCountId = @intInventoryCountId
		OUTER APPLY (
			SELECT	dblOnHand =  SUM(COALESCE(dblOnHand, 0.00)),
					dblLastCost = MAX(dblLastCost)
			FROM	vyuICGetItemStockSummary
			WHERE 
				dbo.fnDateLessThanEquals(dtmDate, inventoryCount.dtmCountDate) = 1
				AND intItemId = i.intItemId
				AND intItemUOMId = items.intItemUOMId
				AND intItemLocationId = il.intItemLocationId
				AND ISNULL(intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)			 
		) itemStockAndPricing
END 

-- Create an Audit Log
BEGIN 
	DECLARE @strAuditLogDescription AS NVARCHAR(100) = @strSourceScreenName + ' to Inventory Count'			
		
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intInventoryCountId						-- Primary Key Value of the Inventory Count
			,@screenName = 'Inventory.view.InventoryCount'			-- Screen Namespace
			,@entityId = @intEntityUserSecurityId                   -- Entity Id.
			,@actionType = 'Processed'                              -- Action Type
			,@changeDescription = @strAuditLogDescription			-- Description
			,@fromValue = @strSourceId                              -- Previous Value
			,@toValue = @InventoryCountNumber						-- New Value
END

_Exit: