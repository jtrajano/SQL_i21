CREATE PROCEDURE [dbo].[uspICCreateUpdateLotNumber]
	@ItemsForLot ItemLotTableType READONLY 
	,@intEntityUserSecurityId AS INT 
	,@intLotStatusId AS INT = NULL -- (1: is Active, 2: is On Hold, 3: Quarantine) 
	,@ysnItemChange AS BIT = 0  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @LotStatus_Active AS INT = 1
		,@LotStatus_OnHold AS INT = 2
		,@LotStatus_Quarantine AS INT = 3

DECLARE @intInsertedLotId AS INT 
DECLARE @intLotTypeId AS INT
DECLARE @intLocationId AS INT 
DECLARE @errorFoundOnUpdate AS INT 
DECLARE @strUnitMeasureItemUOMFrom AS NVARCHAR(50)
DECLARE @strUnitMeasureItemUOMTo AS NVARCHAR(50)
DECLARE @strUnitMeasureWeightUOMFrom AS NVARCHAR(50)
DECLARE @strUnitMeasureWeightUOMTo AS NVARCHAR(50)
DECLARE @strSubLocatioNameFrom AS NVARCHAR(50)
DECLARE @strSubLocatioNameTo AS NVARCHAR(50)
DECLARE @strStorageLocatioNameFrom AS NVARCHAR(50)
DECLARE @strStorageLocatioNameTo AS NVARCHAR(50)
DECLARE @dtmCreatedDate AS DATETIME;
DECLARE @strOwnershipType AS NVARCHAR(50)
DECLARE @strOwnershipTypeNew AS NVARCHAR(50)

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2
		,@LotType_ManualSerial AS INT = 3

DECLARE @strItemNo AS NVARCHAR(50)
		,@strItemNo2 AS NVARCHAR(50) 

DECLARE @intParentLotId AS INT = NULL
DECLARE @intReturnCode AS INT = 0 

-- Lot Number batch number in the starting numbers table. 
DECLARE @STARTING_NUMBER_BATCH AS INT = 24 

-- If temp table does not exists, create a stub for it so that insert statement for the temp table will not fail. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
BEGIN 
	CREATE TABLE #GeneratedLotItems (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intDetailId INT 
		,intParentLotId INT
		,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	);
END

DECLARE 
	@intId						AS INT 
	,@intLotId					AS INT 
	,@strLotNumber				AS NVARCHAR(50) 
	,@strLotAlias				AS NVARCHAR(50) 
	,@intItemId					AS INT 
	,@intItemLocationId			AS INT 
	,@intSubLocationId			AS INT 
	,@intStorageLocationId		AS INT
	,@dblQty					AS NUMERIC(38,20) 
	,@intItemUOMId				AS INT 
	,@dblWeight					AS NUMERIC(38,20)
	,@intWeightUOMId			AS INT
	,@dtmExpiryDate				AS DATETIME
	,@dtmManufacturedDate		AS DATETIME
	,@intOriginId				AS INT
	,@intGradeId				AS INT
	,@strBOLNo					AS NVARCHAR(100)
	,@strVessel					AS NVARCHAR(100)
	,@strReceiptNumber			AS NVARCHAR(50)
	,@strMarkings				AS NVARCHAR(MAX)
	,@strNotes					AS NVARCHAR(MAX)
	,@intEntityVendorId			AS INT 
	,@strVendorLotNo			AS NVARCHAR(50)
	,@strGarden					AS NVARCHAR(100)
	,@strContractNo				AS NVARCHAR(50)
	,@ysnReleasedToWarehouse	AS BIT
	,@ysnProduced				AS BIT 
	,@intDetailId				AS INT 
	,@intOwnershipType			AS INT
	,@dblGrossWeight			AS NUMERIC(38,20)
	,@strParentLotNumber		AS NVARCHAR(50) 
	,@strParentLotAlias			AS NVARCHAR(50) 
	,@intLotStatusId_ItemLotTable AS INT 
	,@intSplitFromLotId			AS INT 
	,@dblWeightPerQty			AS NUMERIC(38,20)
	,@intNoPallet				AS INT
	,@intUnitPallet				AS INT
	,@strTransactionId			AS NVARCHAR(50) 
	,@strSourceTransactionId	AS NVARCHAR(50) 
	,@intSourceTransactionTypeId AS INT 
	,@intOwnerId				AS INT 	
	,@intShiftId				AS INT 
	,@strContainerNo			AS NVARCHAR(50) 
	,@strCondition				AS NVARCHAR(50) 
	,@strUnitMeasure			AS NVARCHAR(50)
	,@intUnitMeasureId			AS INT
	,@intInventoryReceiptId		AS INT 
	,@intInventoryReceiptItemId	AS INT 
	,@intInventoryReceiptItemLotId	AS INT
	,@intSeasonCropYear			AS INT
	,@intBookId					AS INT
	,@intSubBookId				AS INT 
	,@strCertificate			AS NVARCHAR(50)
	,@intProducerId				AS INT
	,@strCertificateId			AS NVARCHAR(50)
	,@strTrackingNumber			AS NVARCHAR(255) 
	,@strWarehouseRefNo			AS NVARCHAR(255)
DECLARE @strName AS NVARCHAR(200)
		,@intItemOwnerId AS INT 
		,@intEntityProducerId AS INT 

DECLARE @OwnerShipType_Own AS INT = 1

DECLARE @intCategoryId INT = NULL
DECLARE @intManufacturingId INT = NULL
DECLARE @intOrderTypeId INT = NULL
DECLARE @intBlendRequirementId INT = NULL
DECLARE @intPatternCode INT = 24
DECLARE @ysnProposed INT = 0

DECLARE @intSourceType_Scale AS INT = 1

-- Check for redundant lot numbers 
BEGIN 
	SET @strReceiptNumber = NULL
	SET @strLotNumber = NULL 
	SET @strItemNo = NULL 
	SELECT	TOP 1
			@strLotNumber = LotFromTransaction.strLotNumber
			,@strReceiptNumber = LotFromTransaction.strReceiptNumber
			,@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
	FROM	@ItemsForLot LotFromTransaction INNER JOIN dbo.tblICItem Item
				ON LotFromTransaction.intItemId = Item.intItemId
	WHERE	ISNULL(LotFromTransaction.intSourceType, 0) <> @intSourceType_Scale 
	GROUP BY 
		LotFromTransaction.strLotNumber
		, LotFromTransaction.strReceiptNumber
		, Item.strItemNo
		, Item.intItemId
		, LotFromTransaction.intSubLocationId
		, LotFromTransaction.intStorageLocationId
	HAVING COUNT(1) > 1

	IF ISNULL(@strReceiptNumber, '') <> '' AND ISNULL(@strLotNumber, '') <> '' AND ISNULL(@strItemNo, '') <> ''
	BEGIN 
		-- 'Please check for duplicate lot numbers. The lot number {Lot Number} is used more than once in item {Item No} on {Transaction Id}.'
		EXEC uspICRaiseError 80019, @strLotNumber, @strItemNo, @strReceiptNumber;
		SET @intReturnCode = -80019;
		GOTO _Exit;
	END
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopLotItems CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,intLotId
		,strLotNumber
		,strLotAlias
		,intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dtmExpiryDate
		,dtmManufacturedDate
		,intOriginId
		,intGradeId
		,strBOLNo
		,strVessel
		,strReceiptNumber
		,strMarkings
		,strNotes
		,intEntityVendorId
		,strVendorLotNo
		,strGarden
		,strContractNo
		,ysnReleasedToWarehouse
		,ysnProduced
		,intDetailId
		,intOwnershipType
		,dblGrossWeight
		,strParentLotNumber
		,strParentLotAlias
		,intLotStatusId
		,intSplitFromLotId
		,dblWeightPerQty
		,intNoPallet
		,intUnitPallet
		,strTransactionId
		,strSourceTransactionId
		,intSourceTransactionTypeId
		,intOwnerId 
		,intShiftId 
		,strContainerNo
		,strCondition
		,intInventoryReceiptId
		,intInventoryReceiptItemId
		,intInventoryReceiptItemLotId
		,intSeasonCropYear
		,intBookId
		,intSubBookId 
		,strCertificate
		,intProducerId
		,strCertificateId
		,strTrackingNumber
		,strWarehouseRefNo
FROM	@ItemsForLot

OPEN loopLotItems;

-- Initial fetch attempt
FETCH NEXT FROM loopLotItems INTO 
		@intId
		,@intLotId
		,@strLotNumber
		,@strLotAlias
		,@intItemId
		,@intItemLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@dblQty
		,@intItemUOMId
		,@dblWeight
		,@intWeightUOMId
		,@dtmExpiryDate
		,@dtmManufacturedDate
		,@intOriginId
		,@intGradeId
		,@strBOLNo
		,@strVessel
		,@strReceiptNumber
		,@strMarkings
		,@strNotes
		,@intEntityVendorId
		,@strVendorLotNo
		,@strGarden
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId
		,@intOwnershipType
		,@dblGrossWeight
		,@strParentLotNumber
		,@strParentLotAlias
		,@intLotStatusId_ItemLotTable
		,@intSplitFromLotId
		,@dblWeightPerQty
		,@intNoPallet
		,@intUnitPallet
		,@strTransactionId
		,@strSourceTransactionId
		,@intSourceTransactionTypeId
		,@intOwnerId 
		,@intShiftId
		,@strContainerNo
		,@strCondition
		,@intInventoryReceiptId
		,@intInventoryReceiptItemId
		,@intInventoryReceiptItemLotId
		,@intSeasonCropYear
		,@intBookId
		,@intSubBookId 
		,@strCertificate
		,@intProducerId
		,@strCertificateId
		,@strTrackingNumber
		,@strWarehouseRefNo
;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 		
	-- Clean-up blanks from the lot number field
	SET @strLotNumber = RTRIM(LTRIM(ISNULL(@strLotNumber, ''))) 

	-- Get the type of lot (if manual or serialized)
	SELECT @intLotTypeId = dbo.fnGetItemLotType(@intItemId);

	-- Get the company location id
	SELECT	@intLocationId = intLocationId
	FROM	dbo.tblICItemLocation 
	WHERE	intItemLocationId = @intItemLocationId

	-- Validate if the Manual lot item does not have a lot number. 
	IF @strLotNumber = '' AND @intLotTypeId = @LotType_Manual
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Please specify the lot numbers for {Item}.
		EXEC uspICRaiseError 80005, @strItemNo;
		SET @intReturnCode = -80005;
		GOTO _Exit_Loop;
	END 	

	-- Generate the parent lot number 
	IF ISNULL(@strParentLotNumber, '') = '' 
	BEGIN 
		EXEC dbo.uspMFGeneratePatternId 
				@intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = NULL
				,@intSubLocationId = @intSubLocationId
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 78
				,@ysnProposed = 0
				,@strPatternString = @strParentLotNumber OUTPUT
				,@intEntityId = @intEntityUserSecurityId
				,@intShiftId = @intShiftId
				,@dtmDate = @dtmManufacturedDate
				,@strParentLotNumber = NULL
				,@intInventoryReceiptId = @intInventoryReceiptId
				,@intInventoryReceiptItemId = @intInventoryReceiptItemId
				,@intInventoryReceiptItemLotId = @intInventoryReceiptItemLotId
				,@intTransactionTypeId = @intSourceTransactionTypeId
	END 
	
	-- Generate the next lot number - if lot id is NULL AND it is a serial lot item. 
	IF @intLotTypeId = @LotType_Serial AND @intLotId IS NULL 
	BEGIN 		 
		-- Generate a new lot id if: 
		-- 1. Lot id is NULL. 
		-- 2. Lot Number is blank. 
		-- 3. and Lot Number was never used before for that item. If it was used, then user must be doing a lot move or merge for that serial number
		-- 4. if changing the item id of an existing lot. 
		IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICLot WHERE strLotNumber = @strLotNumber AND intItemId = @intItemId ) AND @ysnItemChange = 0
		BEGIN 
			--EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strLotNumber OUTPUT
			EXEC dbo.uspMFGeneratePatternId 
				@intCategoryId
				, @intItemId
				, @intManufacturingId
				, @intSubLocationId
				, @intLocationId
				, @intOrderTypeId
				, @intBlendRequirementId
				, @intPatternCode
				, @ysnProposed
				, @strLotNumber OUTPUT
				, @intEntityUserSecurityId
				, @intShiftId
				, @dtmManufacturedDate
				, @strParentLotNumber
				, @intInventoryReceiptId
				, @intInventoryReceiptItemId
				, @intInventoryReceiptItemLotId
				, @intSourceTransactionTypeId 

		END 
	END 

	-- Generate the next lot number - if lot number is blank and lot type is manual/serial. 
	IF @intLotTypeId = @LotType_ManualSerial AND @strLotNumber = '' AND @intLotId IS NULL 
	BEGIN 		 
		-- Generate a new lot id if: 
		-- 1. Lot id is NULL. 
		-- 2. Lot Number is blank. 
		-- 3. and Lot Number was never used before for that item. If it was used, then user must be doing a lot move or merge for that serial number
		-- 4. if changing the item id of an existing lot. 
		IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblICLot WHERE strLotNumber = @strLotNumber AND intItemId = @intItemId ) AND @ysnItemChange = 0
		BEGIN 
			--EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strLotNumber OUTPUT
			EXEC dbo.uspMFGeneratePatternId 
				@intCategoryId
				, @intItemId
				, @intManufacturingId
				, @intSubLocationId
				, @intLocationId
				, @intOrderTypeId
				, @intBlendRequirementId
				, @intPatternCode
				, @ysnProposed
				, @strLotNumber OUTPUT
				, @intEntityUserSecurityId
				, @intShiftId
				, @dtmManufacturedDate
				, @strParentLotNumber
				, @intInventoryReceiptId
				, @intInventoryReceiptItemId
				, @intInventoryReceiptItemLotId
				, @intSourceTransactionTypeId 
		END 
	END 

	-- Validate if the Serial lot item does not have a lot number. 
	IF ISNULL(@strLotNumber, '') = '' AND @intLotTypeId IN (@LotType_Serial, @LotType_ManualSerial)
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Unable to generate the serial lot number for {Item}.
		EXEC uspICRaiseError 80009, @strItemNo; 
		SET @intReturnCode = -80009;
		GOTO _Exit_Loop;
	END 	

	-- If weight UOM is specified, make sure weight is not zero. 
	IF ISNULL(@intWeightUOMId, 0) <> 0 AND ISNULL(@dblWeight, 0) = 0
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		IF @intLotTypeId = @LotType_Serial
		BEGIN 
			SET @strLotNumber = '(To be generated)'
		END 

		-- '{Item} with lot number {Lot Number} needs to have a weight.'
		EXEC uspICRaiseError 80015, @strItemNo, @strLotNumber;
		SET @intReturnCode = -80015;
		GOTO _Exit_Loop;
	END 

	-- Validate if intItemUOM id is valid
	BEGIN 
		
		SELECT	TOP 1 
				@intUnitMeasureId = u.intUnitMeasureId
				,@strItemNo = i.strItemNo
				,@strUnitMeasure = u.strUnitMeasure
		FROM	tblICItemUOM iu LEFT JOIN tblICItem i
					ON iu.intItemId = i.intItemId 
				LEFT JOIN tblICUnitMeasure u
					ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE	intItemUOMId = @intItemUOMId
				AND iu.intItemId <> @intItemId

		SET @strUnitMeasure = ISNULL(@strUnitMeasure, '(Unspecified UOM)')
		IF @intUnitMeasureId IS NOT NULL 
		BEGIN 
			SELECT	TOP 1 
					@strItemNo2 = i.strItemNo
			FROM	tblICItem i
			WHERE	intItemId = @intItemId

			-- 'The UOM {Unit Measure Name} is used for {Item No} and not for {Current Item No}. Please assign the correct UOM id.'
			EXEC uspICRaiseError 80186, @strUnitMeasure, @strItemNo, @strItemNo2;
			SET @intReturnCode = -80186;
			GOTO _Exit_Loop;
		END 
	END 

	-- Validate if intWeightUOM id is valid
	IF @intWeightUOMId IS NOT NULL 
	BEGIN 		
		SELECT	TOP 1 
				@intUnitMeasureId = u.intUnitMeasureId
				,@strItemNo = i.strItemNo
				,@strUnitMeasure = u.strUnitMeasure
		FROM	tblICItemUOM iu LEFT JOIN tblICItem i
					ON iu.intItemId = i.intItemId 
				LEFT JOIN tblICUnitMeasure u
					ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE	intItemUOMId = @intWeightUOMId
				AND iu.intItemId <> @intItemId

		SET @strUnitMeasure = ISNULL(@strUnitMeasure, '(Unspecified UOM)')
		IF @intUnitMeasureId IS NOT NULL 
		BEGIN 
			SELECT	TOP 1 
					@strItemNo2 = i.strItemNo
			FROM	tblICItem i
			WHERE	intItemId = @intItemId

			-- 'The UOM {Unit Measure Name} is used for {Item No} and not for {Current Item No}. Please assign the correct UOM id.'
			EXEC uspICRaiseError 80186, @strUnitMeasure, @strItemNo, @strItemNo2;
			SET @intReturnCode = -80186;
			GOTO _Exit_Loop;
		END 
	END 

	-- Setup the Lot Status
	-- 1: Get lot status from @intLotStatusId
	-- 2: If NULL, get lot status from source lot (@intLotStatusId_ItemLotTable)
	-- 3: If NULL, get lot status from item setup
	-- 4: If NULL, default to Active. 
	DECLARE @lotStatusFromItemSetup AS INT
	SELECT	TOP 1
			@lotStatusFromItemSetup = i.intLotStatusId
	FROM	tblICItem i
	WHERE	intItemId = @intItemId
	SET @intLotStatusId_ItemLotTable = COALESCE(@intLotStatusId, @intLotStatusId_ItemLotTable, @lotStatusFromItemSetup, @LotStatus_Active)

	-- Validate the Item Owner Id. 
	BEGIN
		SET @intItemOwnerId = NULL  

		-- Get the Item-Owner id. 
		SELECT	@intItemOwnerId = o.intItemOwnerId
		FROM	tblICItemOwner o
		WHERE	o.intItemId = @intItemId
				AND o.intOwnerId = @intOwnerId 

		-- If Item-Owner is null and @intOwnerId is null, then use the default item-owner id. 
		SELECT	@intItemOwnerId = defaultOwner.intItemOwnerId
		FROM	tblICItemOwner defaultOwner
		WHERE	defaultOwner.intItemId = @intItemId
				AND defaultOwner.ysnDefault = 1
				AND @intItemOwnerId IS NULL 
				AND @intOwnerId IS NULL 

		-- Validate Owner Id 
		IF (@intOwnerId IS NOT NULL) AND (@intItemOwnerId IS NULL)
		BEGIN 
			SET @strItemNo = NULL 
			SELECT	@strItemNo = strItemNo
			FROM	dbo.tblICItem Item
			WHERE	Item.intItemId = @intItemId
		
			SET @strName = NULL 
			SELECT	@strName = e.strName
			FROM	tblEMEntity e
			WHERE	e.intEntityId = @intOwnerId

			--'Invalid Owner. {Owner Name} is not configured as an Owner for {Item Name}. Please check the Item setup.'
			EXEC uspICRaiseError 80105, @strName, @strItemNo;
			SET @intReturnCode = -80105;
			GOTO _Exit_Loop;
		END 
	END 

	-- Validate If Lot already exist for Ownership Type 
	IF (@intOwnershipType IS NOT NULL)
	BEGIN 
		SET @strItemNo = NULL;

		SELECT TOP 1 @strOwnershipType = dbo.fnICGetOwnershipType(intOwnershipType)
		FROM tblICLot
		WHERE intItemId = @intItemId
			AND strLotNumber = @strLotNumber
			AND intLocationId = @intLocationId
			AND intSubLocationId = @intSubLocationId
			AND intStorageLocationId = @intStorageLocationId
			AND intOwnershipType <> @intOwnershipType

		IF(@strOwnershipType IS NOT NULL)
		BEGIN
			SET @strOwnershipTypeNew = dbo.fnICGetOwnershipType(@intOwnershipType);
			--'Ownership of {Lot Number} is {Ownership}. Cannot add  inventory to it'
			EXEC uspICRaiseError 80209, @strLotNumber, @strOwnershipType, @strOwnershipTypeNew;
			SET @intReturnCode = -80209;
		END
	END

	-- Validate the Producer Id. 
	BEGIN
		SET @intEntityProducerId = NULL  
		SET	@strName = NULL 

		SELECT	@intEntityProducerId = et.intEntityId
				,@strName  = e.strName
		FROM	tblEMEntity e LEFT JOIN tblEMEntityType et
					ON e.intEntityId = et.intEntityId
					AND et.strType = 'Producer'
		WHERE	e.intEntityId = @intProducerId

		IF (@intProducerId IS NOT NULL) AND (@intEntityProducerId IS NULL)
		BEGIN 
			--'Invalid Producer. {Entity Name} is not configured as a Producer type. Please check the Entity setup.'
			EXEC uspICRaiseError 80210, @strName, @strItemNo;
			SET @intReturnCode = -80210;
			GOTO _Exit_Loop;
		END 
	END 

	----------------------------------------------
	-- Special process on the Item Qty and Weight
	-- If there is weight and item qty is fractional, convert item uom into weight uom. 
	IF	@intWeightUOMId IS NOT NULL 
		AND ISNULL(@dblWeight, 0) <> 0 
		AND ISNULL(@dblQty, 0) <> 0 
		AND @intItemUOMId <> @intWeightUOMId
		AND @dblQty % 1 <> 0 
	BEGIN 
		SET @intItemUOMId = @intWeightUOMId
		SET	@dblQty = @dblWeight
	END 

	-- Upsert (update or insert) the record to the lot master table. 
	BEGIN  
		SET @intInsertedLotId = NULL 
		SET @errorFoundOnUpdate = NULL 

		-- Get the Item UOM String (old value)
		SELECT	@strUnitMeasureItemUOMFrom = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICLot Lot 
					ON ItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE	ItemUOM.intItemId = @intItemId
				AND Lot.strLotNumber = @strLotNumber
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		-- Get the Weight UOM String (old value)
		SELECT	@strUnitMeasureWeightUOMFrom = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICLot Lot 
					ON ItemUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ItemUOM.intItemId = @intItemId
				AND Lot.strLotNumber = @strLotNumber
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		-- Get the Sub Location String (old value)
		SELECT @strSubLocatioNameFrom = SubLocation.strSubLocationName
		FROM	 dbo.tblSMCompanyLocationSubLocation SubLocation INNER JOIN dbo.tblICLot Lot
					ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
		WHERE	Lot.intItemId = @intItemId
				AND Lot.strLotNumber = @strLotNumber
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		-- Get the Storage Location String (old value)
		SELECT @strSubLocatioNameFrom = StorageLocation.strName
		FROM	 dbo.tblICStorageLocation StorageLocation INNER JOIN dbo.tblICLot Lot
					ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
		WHERE	Lot.intItemId = @intItemId
				AND Lot.strLotNumber = @strLotNumber
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		-- Get Date Created from Source Lot
		SELECT @dtmCreatedDate = Lot.dtmDateCreated
		FROM	dbo.tblICLot Lot
		WHERE	Lot.intLotId = @intSplitFromLotId


		-- Get the Lot id or insert a new record on the Lot master table. 
		MERGE	
		INTO	dbo.tblICLot 
		WITH	(HOLDLOCK) 
		AS		LotMaster
		USING (
				SELECT	intItemId = @intItemId
						,intLotId = @intLotId
						,intLocationId = @intLocationId
						,intItemUOMId = @intItemUOMId
						,intWeightUOMId = @intWeightUOMId
						,strLotNumber = @strLotNumber
						,intSubLocationId = @intSubLocationId
						,intStorageLocationId = @intStorageLocationId
						,dblQty = @dblQty
						,dblWeight = @dblWeight
						,dblWeightPerQty = @dblWeightPerQty
						,intSplitFromLotId = @intSplitFromLotId
						,intItemOwnerId = @intItemOwnerId
						,strContainerNo = @strContainerNo
						,strCondition = @strCondition 
						,intSeasonCropYear = @intSeasonCropYear
						,intUnitPallet = @intUnitPallet
						,intBookId = @intBookId
						,intSubBookId = @intSubBookId 
						,strWarehouseRefNo = @strWarehouseRefNo
		) AS LotToUpdate
			ON LotMaster.intItemId = LotToUpdate.intItemId
			AND LotMaster.intLocationId = LotToUpdate.intLocationId			
			AND LotMaster.strLotNumber = LotToUpdate.strLotNumber 
			AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
			AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)

		-- If matched, update the lot record 
		WHEN MATCHED THEN 
			UPDATE 
			SET		
				-- The following fields are updated if it is changed from the source transaction. 
				dtmExpiryDate			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @dtmExpiryDate ELSE LotMaster.dtmExpiryDate END 
				,strLotAlias			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strLotAlias ELSE ISNULL(@strLotAlias, LotMaster.strLotAlias) END 				
				,intOriginId			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intOriginId ELSE LotMaster.intOriginId END  
				,intGradeId				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intGradeId ELSE LotMaster.intGradeId END  
				,strBOLNo				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strBOLNo ELSE LotMaster.strBOLNo END 
				,strVessel				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strVessel ELSE LotMaster.strVessel END 
				,strReceiptNumber		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strReceiptNumber ELSE LotMaster.strReceiptNumber END 
				,strTransactionId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strTransactionId ELSE LotMaster.strTransactionId END 
				,strMarkings			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strMarkings ELSE LotMaster.strMarkings END 
				,strNotes				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strNotes ELSE LotMaster.strNotes END 
				,intEntityVendorId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intEntityVendorId ELSE LotMaster.intEntityVendorId END 
				,strVendorLotNo			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strVendorLotNo ELSE LotMaster.strVendorLotNo END 
				,strGarden				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strGarden ELSE LotMaster.strGarden END
				,strContractNo			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strContractNo ELSE LotMaster.strContractNo END 
				,dtmManufacturedDate	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @dtmManufacturedDate ELSE LotMaster.dtmManufacturedDate END 
				,intSplitFromLotId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intSplitFromLotId ELSE LotMaster.intSplitFromLotId END 
				,intNoPallet			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intNoPallet ELSE LotMaster.intNoPallet END 
				,intUnitPallet			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intUnitPallet ELSE LotMaster.intUnitPallet END 
				,strContainerNo			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strContainerNo ELSE LotMaster.strContainerNo END 
				,strCondition			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strCondition ELSE LotMaster.strCondition END 
				,intSeasonCropYear		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intSeasonCropYear ELSE LotMaster.intSeasonCropYear END 				
				-- Find out if there any possible errors when updating an existing lot record. 
				,@errorFoundOnUpdate	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) <> 0 THEN 
													CASE	WHEN ISNULL(LotMaster.intWeightUOMId, 0) = LotToUpdate.intItemUOMId AND ISNULL(LotMaster.intWeightUOMId, 0) = LotToUpdate.intWeightUOMId THEN 0 -- Incoming lot is already in wgt. If incoming and target lot shares the same wgt uom, then this is valid. 
															WHEN ISNULL(LotMaster.intItemUOMId, 0) = ISNULL(LotMaster.intWeightUOMId, 0) AND ISNULL(LotMaster.intWeightUOMId, 0) = LotToUpdate.intWeightUOMId THEN 0 -- Lot is purely in wgt. Any bag wgt passed on it is converted to wgt. If incoming and target lot shares the same wgt uom, then this is valid. 
															WHEN ISNULL(LotMaster.intItemUOMId, LotToUpdate.intItemUOMId) <> LotToUpdate.intItemUOMId THEN 1 
															WHEN ISNULL(LotMaster.intWeightUOMId, LotToUpdate.intWeightUOMId) <> LotToUpdate.intWeightUOMId THEN 2
															WHEN ISNULL(LotMaster.intSubLocationId, 0) <> ISNULL(LotToUpdate.intSubLocationId, 0) THEN 3
															WHEN ISNULL(LotMaster.intStorageLocationId, 0) <> ISNULL(LotToUpdate.intStorageLocationId, 0) THEN 4
															ELSE 0 
													END 
												ELSE 0
										  END

				-- Allow update on the following fields if dblQty is zero.  
				,dblWeightPerQty		=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN 														
														CASE	WHEN ISNULL(LotToUpdate.intWeightUOMId, 0) <> 0 THEN
																	CASE WHEN LotToUpdate.intWeightUOMId = LotToUpdate.intItemUOMId THEN 1 ELSE
																	dbo.fnCalculateWeightUnitQty(LotToUpdate.dblQty, LotToUpdate.dblWeight) END
																ELSE 0 
														END 
													ELSE 
														
														CASE	-- Retain the same Wgt Per Qty if the incoming stock is in wgt. 
																WHEN LotToUpdate.dblQty > 0 AND ISNULL(LotMaster.intWeightUOMId, 0) = LotToUpdate.intItemUOMId AND ISNULL(LotMaster.intWeightUOMId, 0) = LotToUpdate.intWeightUOMId THEN 
																	LotMaster.dblWeightPerQty

																-- If lot master does not have weight uom, calculate a new one based on the incoming lot. 
																WHEN LotToUpdate.dblQty > 0 AND LotMaster.intWeightUOMId IS NULL AND LotToUpdate.intWeightUOMId IS NOT NULL THEN 
																	dbo.fnCalculateWeightUnitQty(
																		(
																			LotMaster.dblQty 
																			+ dbo.fnCalculateQtyBetweenUOM(LotToUpdate.intItemUOMId, LotMaster.intItemUOMId, LotToUpdate.dblQty) 
																		)
																		,(
																			-- convert the pack qty from the lot master into weight. 
																			dbo.fnCalculateQtyBetweenUOM(LotMaster.intItemUOMId, LotToUpdate.intWeightUOMId, LotMaster.dblQty)
																			+ LotToUpdate.dblWeight
																		)
																	)

																-- Increase the weight per Qty if there is an incoming stock for the lot. 
																WHEN LotToUpdate.dblQty > 0 AND LotMaster.intWeightUOMId IS NOT NULL AND LotToUpdate.dblWeightPerQty <> LotMaster.dblWeightPerQty THEN 
																	dbo.fnCalculateWeightUnitQty(
																		(
																			LotMaster.dblQty 
																			+ dbo.fnCalculateQtyBetweenUOM(LotToUpdate.intItemUOMId, LotMaster.intItemUOMId, LotToUpdate.dblQty) 
																		)
																		,(
																			dbo.fnMultiply(LotMaster.dblQty, LotMaster.dblWeightPerQty)	
																			+ LotToUpdate.dblWeight
																		)
																	) 
																ELSE 
																	LotMaster.dblWeightPerQty 
														END 

											END
				,intItemUOMId			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intItemUOMId ELSE LotMaster.intItemUOMId END
				,intWeightUOMId			=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN 
														LotToUpdate.intWeightUOMId 
													WHEN ISNULL(LotMaster.dblQty, 0) < 0 AND LotMaster.intWeightUOMId IS NULL THEN 
														LotToUpdate.intWeightUOMId 
													ELSE 
														LotMaster.intWeightUOMId 
											END
				,intSubLocationId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intSubLocationId ELSE LotMaster.intSubLocationId END
				,intStorageLocationId	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intStorageLocationId ELSE LotMaster.intStorageLocationId END
				,intItemOwnerId			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intItemOwnerId ELSE LotMaster.intItemOwnerId END
				,strWarehouseRefNo		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.strWarehouseRefNo ELSE LotMaster.strWarehouseRefNo END

				-- The following fields are always updated if it has the same: 
				-- 1. Quantity UOM
				-- 2. Weight UOM
				-- 3. sub location 
				-- 4. storage location
				,intLotStatusId			=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @intLotStatusId_ItemLotTable ELSE LotMaster.intLotStatusId
											END 
				,ysnReleasedToWarehouse =	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @ysnReleasedToWarehouse ELSE LotMaster.ysnReleasedToWarehouse
											END 
				,ysnProduced			=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @ysnProduced ELSE LotMaster.ysnProduced
											END 
				,intConcurrencyId		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN ISNULL(LotMaster.intConcurrencyId, 0) + 1 ELSE ISNULL(LotMaster.intConcurrencyId, 0)
											END 
				,intOwnershipType		=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN ISNULL(@intOwnershipType, @OwnerShipType_Own) ELSE LotMaster.intOwnershipType END
				,dblGrossWeight			=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN
														@dblGrossWeight
													-- Increase the gross weight on top of the existing gross weight. 													
													WHEN (
														LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
														AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
														AND LotToUpdate.intSplitFromLotId IS NULL 
													) THEN 
														ISNULL(LotMaster.dblGrossWeight, 0) + @dblGrossWeight 
													ELSE 
														LotMaster.dblGrossWeight 
											END 
				,intBookId			=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@intBookId  
											ELSE 
												LotMaster.intBookId 
										END
				,intSubBookId		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@intSubBookId  
											ELSE 
												LotMaster.intSubBookId 
										END
				,strCertificate		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@strCertificate  
											ELSE 
												LotMaster.strCertificate 
										END
				,intProducerId		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@intProducerId  
											ELSE 
												LotMaster.intProducerId 
										END
				,strCertificateId		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@strCertificateId  
											ELSE 
												LotMaster.strCertificateId 
										END
				,strTrackingNumber		=	CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN 
												@strTrackingNumber  
											ELSE 
												LotMaster.strTrackingNumber 
										END

				-- The following field are returned from the lot master if:
				-- 1. It is editing from the source transaction id
				-- 2. The item UOM, Weight UOM, Sub Location, and Storage Location matches exactly. 
				-- Otherwise, it returns zero. 
				,@intInsertedLotId		=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN 
														LotMaster.intLotId
													WHEN (
														LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
														AND COALESCE(LotMaster.intWeightUOMId, LotToUpdate.intWeightUOMId, 0) = COALESCE(LotToUpdate.intWeightUOMId, 0)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN 
														LotMaster.intLotId 
													WHEN (
														(LotMaster.intWeightUOMId = LotToUpdate.intItemUOMId OR LotMaster.intWeightUOMId = LotToUpdate.intWeightUOMId)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN 
														LotMaster.intLotId 
													ELSE 0 
											END
				,@intLotId				=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN 
														LotMaster.intLotId
													WHEN (
														LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
														AND COALESCE(LotMaster.intWeightUOMId, LotToUpdate.intWeightUOMId, 0) = COALESCE(LotToUpdate.intWeightUOMId, 0)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN 
														LotMaster.intLotId 
													WHEN (
														(LotMaster.intWeightUOMId = LotToUpdate.intItemUOMId OR LotMaster.intWeightUOMId = LotToUpdate.intWeightUOMId)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN 
														LotMaster.intLotId 
													ELSE 0 
											END	



		-- If none found, insert a new lot record. 
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intLocationId
				,intItemLocationId
				,intItemUOMId
				,strLotNumber
				,intSubLocationId
				,intStorageLocationId
				,dblQty
				,dtmExpiryDate
				,strLotAlias
				,intLotStatusId
				,dblWeight
				,intWeightUOMId
				,dblWeightPerQty
				,intOriginId
				,intGradeId
				,strBOLNo
				,strVessel
				,strReceiptNumber
				,strMarkings
				,strNotes
				,intEntityVendorId
				,strVendorLotNo
				,strGarden
				,strContractNo
				,dtmManufacturedDate
				,ysnReleasedToWarehouse
				,ysnProduced
				,dtmDateCreated
				,intCreatedEntityId
				,intConcurrencyId
				,intOwnershipType
				,dblGrossWeight
				,intSplitFromLotId
				,intNoPallet
				,intUnitPallet
				,strTransactionId
				,strSourceTransactionId
				,intSourceTransactionTypeId
				,intItemOwnerId
				,strContainerNo
				,strCondition
				,intSeasonCropYear
				,intBookId
				,intSubBookId 
				,strCertificate
				,intProducerId
				,strCertificateId
				,strTrackingNumber
				,strWarehouseRefNo
			) VALUES (
				@intItemId
				,@intLocationId
				,@intItemLocationId
				,@intItemUOMId
				,@strLotNumber
				,@intSubLocationId
				,@intStorageLocationId
				,0 -- (keep at zero. We only need to create the lot record)
				,@dtmExpiryDate
				,@strLotAlias
				,@intLotStatusId_ItemLotTable
				,0 -- (keep at zero. We only need to create the lot record)
				,@intWeightUOMId
				,CASE WHEN ISNULL(@intWeightUOMId, 0) <> 0 THEN
						CASE WHEN @intWeightUOMId = @intItemUOMId THEN 1 ELSE
						dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight) END -- (though, we need to know immediately the weight per qty). 
					  ELSE
						0.00
				END 
				,@intOriginId
				,@intGradeId
				,@strBOLNo
				,@strVessel
				,@strReceiptNumber
				,@strMarkings
				,@strNotes
				,@intEntityVendorId
				,@strVendorLotNo
				,@strGarden
				,@strContractNo
				,@dtmManufacturedDate
				,@ysnReleasedToWarehouse
				,@ysnProduced
				,ISNULL(@dtmCreatedDate, GETDATE())
				,@intEntityUserSecurityId
				,1
				,@intOwnershipType
				,@dblGrossWeight
				,@intSplitFromLotId
				,@intNoPallet
				,@intUnitPallet
				,@strTransactionId
				,@strSourceTransactionId
				,@intSourceTransactionTypeId
				,@intItemOwnerId 
				,@strContainerNo
				,@strCondition
				,@intSeasonCropYear
				,@intBookId
				,@intSubBookId 
				,@strCertificate
				,@intProducerId
				,@strCertificateId
				,@strTrackingNumber
				,@strWarehouseRefNo
			)
		;
	
		-- Get the lot id of the newly inserted record
		IF @intInsertedLotId IS NULL 
		BEGIN 
			SELECT @intLotId = SCOPE_IDENTITY();
			SELECT @intInsertedLotId = @intLotId;
		END 

		-- Insert the parent lot 
		IF ISNULL(@intInsertedLotId, 0) <> 0 
		BEGIN 
			SET @intParentLotId = NULL
			SET @intReturnCode = 0

			EXEC @intReturnCode = dbo.uspMFCreateUpdateParentLotNumber 
				@strParentLotNumber
				,@strParentLotAlias
				,@intItemId
				,@dtmExpiryDate
				,@intLotStatusId_ItemLotTable
				,@intEntityUserSecurityId
				,@intLotId
				,@intParentLotId OUTPUT 
				,@intSubLocationId
				,@intLocationId
				,@dtmManufacturedDate
				,@intShiftId

			IF @intReturnCode <> 0
			BEGIN 
				GOTO _Exit_Loop;
			END
		END 

		-- Insert into a temp table 
		BEGIN 
			-- Get the generated parent lot id. 
			SELECT @strParentLotNumber = strParentLotNumber
			FROM	dbo.tblICParentLot
			WHERE	intParentLotId = @intParentLotId

			INSERT INTO #GeneratedLotItems (
				intLotId
				,strLotNumber
				,intDetailId
				,intParentLotId
				,strParentLotNumber
			)
			SELECT	@intLotId
					,@strLotNumber
					,@intDetailId
					,@intParentLotId
					,@strParentLotNumber
			WHERE ISNULL(@intLotId, 0) <> 0 
		END 
	END 

	-- Validation check point 1 of 5
	IF @errorFoundOnUpdate = 1 
	BEGIN 
		-- Get the item id string value
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item 
		WHERE	Item.intItemId = @intItemId

		-- Get the Item UOM String (proposed value)
		SELECT	@strUnitMeasureItemUOMTo = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ItemUOM.intItemId = @intItemId
				AND ItemUOM.intItemUOMId = @intItemUOMId

		-- Lot {Lot number} exists in {Quantity UOM used}. Cannot receive in {Quantity UOM proposed value}. Change the receiveing UOM to {Quantity UOM used} or create a new lot.
		EXEC uspICRaiseError 80011, @strLotNumber, @strUnitMeasureItemUOMFrom, @strUnitMeasureItemUOMTo, @strUnitMeasureItemUOMFrom; 
		SET @intReturnCode = -80011;
		GOTO _Exit_Loop;
	END 

	-- Validation check point 2 of 5
	IF @errorFoundOnUpdate = 2
	BEGIN 
		-- Get the Weight UOM String (proposed value)
		SELECT	@strUnitMeasureWeightUOMTo = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ItemUOM.intItemId = @intItemId
				AND ItemUOM.intItemUOMId = @intWeightUOMId

		--'The Weight UOM for {Lot number} cannot be changed from {Weight UOM} to {Weight UOM} because a stock from it has been used from a different transaction.'
		EXEC uspICRaiseError 80012, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo; 
		SET @intReturnCode = -80012;
		GOTO _Exit_Loop;
	END 

	-- Validation check point 3 of 5
	IF @errorFoundOnUpdate = 3
	BEGIN 
		-- Get the Sub Location String (proposed value)
		SELECT	@strSubLocatioNameTo = SubLocation.strSubLocationName
		FROM	dbo.tblSMCompanyLocationSubLocation SubLocation 
		WHERE	ISNULL(SubLocation.intCompanyLocationSubLocationId, 0) = ISNULL(@intSubLocationId, 0)

		--'The Sub-Location for {Lot number} cannot be changed from {Sub Location} to {Sub Location} because a stock from it has been used from a different transaction.'
		EXEC uspICRaiseError 80013, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo;
		SET @intReturnCode = -80013;
		GOTO _Exit_Loop;
	END 

	-- Validation check point 4 of 5
	IF @errorFoundOnUpdate = 4
	BEGIN 
		-- Get the Storage Location String (proposed value)
		SELECT	@strSubLocatioNameTo = StorageLocation.strName
		FROM	 dbo.tblICStorageLocation StorageLocation 
		WHERE	ISNULL(StorageLocation.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		--'The Storage Location for {Lot number} cannot be changed from {Storage Location} to {StorageLocation} because a stock from it has been used from a different transaction.'
		EXEC uspICRaiseError 80014, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo;
		SET @intReturnCode = -80014;
		GOTO _Exit_Loop;
	END

	-- Validation check point 5 of 5
	-- Validate if lot id is generated correctly. 
	IF ISNULL(@intLotId, 0) = 0 AND ISNULL(@intInsertedLotId, 0) = 0 
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Failed to process the lot number for {Item}. It may have been used on a different sub-location or storage location.'
		EXEC uspICRaiseError 80010, @strItemNo
		SET @intReturnCode = -80010;
		GOTO _Exit_Loop;
	END
	
	-- Fetch the next row from cursor. 
	FETCH NEXT FROM loopLotItems INTO 
		@intId
		,@intLotId
		,@strLotNumber
		,@strLotAlias
		,@intItemId
		,@intItemLocationId
		,@intSubLocationId
		,@intStorageLocationId
		,@dblQty
		,@intItemUOMId
		,@dblWeight
		,@intWeightUOMId
		,@dtmExpiryDate
		,@dtmManufacturedDate
		,@intOriginId
		,@intGradeId
		,@strBOLNo
		,@strVessel
		,@strReceiptNumber
		,@strMarkings
		,@strNotes
		,@intEntityVendorId
		,@strVendorLotNo
		,@strGarden
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId
		,@intOwnershipType
		,@dblGrossWeight
		,@strParentLotNumber
		,@strParentLotAlias
		,@intLotStatusId_ItemLotTable
		,@intSplitFromLotId
		,@dblWeightPerQty
		,@intNoPallet
		,@intUnitPallet
		,@strTransactionId
		,@strSourceTransactionId
		,@intSourceTransactionTypeId
		,@intOwnerId 
		,@intShiftId
		,@strContainerNo
		,@strCondition
		,@intInventoryReceiptId
		,@intInventoryReceiptItemId
		,@intInventoryReceiptItemLotId
		,@intSeasonCropYear
		,@intBookId
		,@intSubBookId
		,@strCertificate
		,@intProducerId
		,@strCertificateId
		,@strTrackingNumber
		,@strWarehouseRefNo
	;
END

_Exit_Loop:

CLOSE loopLotItems;
DEALLOCATE loopLotItems;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
----------------------------------------------------------------------------------------------------------------------------

_Exit:

RETURN @intReturnCode;