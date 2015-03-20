CREATE PROCEDURE [dbo].[uspICCreateUpdateLotNumber]
	@ItemsForLot ItemLotTableType READONLY 
	,@intUserId AS INT 
	,@intLotStatusId AS INT = 1 -- (1: is Active, 2: is On Hold, 3: Quarantine) 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @Active AS INT = 1
		,@OnHold AS INT = 2
		,@Quarantine AS INT = 3

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

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

DECLARE @strItemNo AS NVARCHAR(50)

-- Lot Number batch number in the starting numbers table. 
DECLARE @STARTING_NUMBER_BATCH AS INT = 24 

-- If temp table does not exists, create a stub for it so that insert statement for the temp table will not fail. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#GeneratedLotItems')) 
BEGIN 
	CREATE TABLE #GeneratedLotItems (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intDetailId INT 
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
	,@dblQty					AS NUMERIC(18,6) 
	,@intItemUOMId				AS INT 
	,@dblWeight					AS NUMERIC(18,6)
	,@intWeightUOMId			AS INT
	,@dtmExpiryDate				AS DATETIME
	,@dtmManufacturedDate		AS DATETIME
	,@intOriginId				AS INT
	,@strBOLNo					AS NVARCHAR(100)
	,@strVessel					AS NVARCHAR(100)
	,@strReceiptNumber			AS NVARCHAR(50)
	,@strMarkings				AS NVARCHAR(MAX)
	,@strNotes					AS NVARCHAR(MAX)
	,@intVendorId				AS INT 
	,@strVendorLotNo			AS NVARCHAR(50)
	,@intVendorLocationId		AS INT
	,@strVendorLocation			AS NVARCHAR(100)
	,@strContractNo				AS NVARCHAR(50)
	,@ysnReleasedToWarehouse	AS BIT
	,@ysnProduced				AS BIT 
	,@intDetailId				AS INT 

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
		,strBOLNo
		,strVessel
		,strReceiptNumber
		,strMarkings
		,strNotes
		,intVendorId
		,strVendorLotNo
		,intVendorLocationId
		,strVendorLocation 
		,strContractNo
		,ysnReleasedToWarehouse
		,ysnProduced
		,intDetailId
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
		,@strBOLNo
		,@strVessel
		,@strReceiptNumber
		,@strMarkings
		,@strNotes
		,@intVendorId
		,@strVendorLotNo
		,@intVendorLocationId
		,@strVendorLocation
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 		
	-- Get the type of lot (if manual or serialized)
	SELECT @intLotTypeId = dbo.fnGetItemLotType(@intItemId);

	-- Get the company location id
	SELECT	@intLocationId = intLocationId
	FROM	dbo.tblICItemLocation 
	WHERE	intItemLocationId = @intItemLocationId

	-- Validate if the Manual lot item does not have a lot number. 
	IF ISNULL(@strLotNumber, '') = '' AND @intLotTypeId = @LotType_Manual
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Please specify the lot numbers for {Item}.
		RAISERROR(51037, 11, 1, @strItemNo);
		RETURN;
	END 	
	
	-- Generate the next lot number - if it is blank AND it is a serial lot item. 
	IF @intLotTypeId = @LotType_Serial
	BEGIN 		
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strLotNumber OUTPUT 
	END 

	-- Validate if the Serial lot item does not have a lot number. 
	IF ISNULL(@strLotNumber, '') = '' AND @intLotTypeId = @LotType_Serial
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Unable to generate the serial lot number for {Item}.
		RAISERROR(51042, 11, 1, @strItemNo);
		RETURN;
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
		RAISERROR(51048, 11, 1, @strItemNo, @strLotNumber)  
		RETURN; 
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
				AND Lot.intLotId = @intLotId
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(intStorageLocationId, 0)

		-- Get the Weight UOM String (old value)
		SELECT	@strUnitMeasureWeightUOMFrom = UOM.strUnitMeasure
		FROM	dbo.tblICItemUOM ItemUOM INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
				INNER JOIN dbo.tblICLot Lot 
					ON ItemUOM.intItemUOMId = Lot.intWeightUOMId
		WHERE	ItemUOM.intItemId = @intItemId
				AND Lot.intLotId = @intLotId
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(intStorageLocationId, 0)

		-- Get the Sub Location String (old value)
		SELECT @strSubLocatioNameFrom = SubLocation.strSubLocationName
		FROM	 dbo.tblSMCompanyLocationSubLocation SubLocation INNER JOIN dbo.tblICLot Lot
					ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
		WHERE	Lot.intItemId = @intItemId
				AND Lot.intLotId = @intLotId
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		-- Get the Storage Location String (old value)
		SELECT @strSubLocatioNameFrom = StorageLocation.strName
		FROM	 dbo.tblICStorageLocation StorageLocation INNER JOIN dbo.tblICLot Lot
					ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
		WHERE	Lot.intItemId = @intItemId
				AND Lot.intLotId = @intLotId
				AND Lot.intLocationId = @intLocationId
				AND ISNULL(Lot.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
				AND ISNULL(Lot.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
				
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
		) AS LotToUpdate
			ON LotMaster.intItemId = LotToUpdate.intItemId
			AND LotMaster.intLocationId = LotToUpdate.intLocationId			
			AND LotMaster.strLotNumber = LotToUpdate.strLotNumber 

		-- If matched, update the lot record 
		WHEN MATCHED THEN 
			UPDATE 
			SET		
				-- The following fields are updated if it is changed from the source transaction. 
				dtmExpiryDate			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @dtmExpiryDate ELSE LotMaster.dtmExpiryDate END 
				,strLotAlias			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strLotAlias ELSE LotMaster.strLotAlias END 				
				,intOriginId			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @intOriginId ELSE LotMaster.intOriginId END  
				,strBOLNo				= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strBOLNo ELSE LotMaster.strBOLNo END 
				,strVessel				= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strVessel ELSE LotMaster.strVessel END 
				,strReceiptNumber		= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strReceiptNumber ELSE LotMaster.strReceiptNumber END 
				,strMarkings			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strMarkings ELSE LotMaster.strMarkings END 
				,strNotes				= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strNotes ELSE LotMaster.strNotes END 
				,intVendorId			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @intVendorId ELSE LotMaster.intVendorId END 
				,strVendorLotNo			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strVendorLotNo ELSE LotMaster.strVendorLotNo END 
				,intVendorLocationId	= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @intVendorLocationId ELSE LotMaster.intVendorLocationId END
				,strVendorLocation		= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strVendorLocation ELSE LotMaster.strVendorLocation END 
				,strContractNo			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @strContractNo ELSE LotMaster.strContractNo END 
				,dtmManufacturedDate	= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber THEN @dtmManufacturedDate ELSE LotMaster.dtmManufacturedDate END 
								
				-- Find out if there any possible errors when updating an existing lot record. 
				,@errorFoundOnUpdate	= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) <> 0 THEN 
													CASE	WHEN ISNULL(LotMaster.intItemUOMId, 0) <> LotToUpdate.intItemUOMId THEN 1 
															WHEN ISNULL(LotMaster.intWeightUOMId, 0) <> LotToUpdate.intWeightUOMId THEN 2
															WHEN ISNULL(LotMaster.intSubLocationId, 0) <> ISNULL(LotToUpdate.intSubLocationId, 0) THEN 3
															WHEN ISNULL(LotMaster.intStorageLocationId, 0) <> ISNULL(LotToUpdate.intStorageLocationId, 0) THEN 4
															ELSE 0 
													END 
												ELSE 0
										  END
				-- Allow update on the following fields if it is changed from the source transaction. 
				,dblWeightPerQty		= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) = 0 THEN dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight) ELSE LotMaster.dblWeightPerQty END
				,intItemUOMId			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intItemUOMId ELSE LotMaster.intItemUOMId END
				,intWeightUOMId			= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intWeightUOMId ELSE LotMaster.intWeightUOMId END
				,intSubLocationId		= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intSubLocationId ELSE LotMaster.intSubLocationId END
				,intStorageLocationId	= CASE	WHEN LotMaster.strReceiptNumber = @strReceiptNumber AND ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intStorageLocationId ELSE LotMaster.intStorageLocationId END

				-- The following fields are always updated if it has the same: 
				-- 1. Quantity UOM
				-- 2. Weight UOM
				-- 3. sub location 
				-- 4. storage location
				,intLotStatusId			= CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @intLotStatusId ELSE LotMaster.intLotStatusId
											END 
				,ysnReleasedToWarehouse = CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @ysnReleasedToWarehouse ELSE LotMaster.ysnReleasedToWarehouse
											END 
				,ysnProduced			= CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN @ysnProduced ELSE LotMaster.ysnProduced
											END 
				,intConcurrencyId		= CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN ISNULL(LotMaster.intConcurrencyId, 0) + 1 ELSE ISNULL(LotMaster.intConcurrencyId, 0)
											END 
				,@intInsertedLotId		= CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN LotMaster.intLotId ELSE 0 
											END 
				,@intLotId				= CASE WHEN (
												LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
												AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
												AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
												AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
											) THEN LotMaster.intLotId ELSE 0 
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
				,strBOLNo
				,strVessel
				,strReceiptNumber
				,strMarkings
				,strNotes
				,intVendorId
				,strVendorLotNo
				,intVendorLocationId
				,strVendorLocation
				,strContractNo
				,dtmManufacturedDate
				,ysnReleasedToWarehouse
				,ysnProduced
				,dtmDateCreated
				,intCreatedUserId
				,intConcurrencyId
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
				,@intLotStatusId
				,0 -- (keep at zero. We only need to create the lot record)
				,@intWeightUOMId
				,dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight) -- (though, we need to know immediately the weight per qty). 
				,@intOriginId
				,@strBOLNo
				,@strVessel
				,@strReceiptNumber
				,@strMarkings
				,@strNotes
				,@intVendorId
				,@strVendorLotNo
				,@intVendorLocationId
				,@strVendorLocation
				,@strContractNo
				,@dtmManufacturedDate
				,@ysnReleasedToWarehouse
				,@ysnProduced
				,GETDATE()
				,@intUserId
				,1
			)
		;
	
		-- Get the lot id of the newly inserted record
		IF @intInsertedLotId IS NULL 
		BEGIN 
			SELECT @intLotId = SCOPE_IDENTITY();
			SELECT @intInsertedLotId = @intLotId;
		END 

		-- Insert into a temp table 
		BEGIN 
			INSERT INTO #GeneratedLotItems (
				intLotId
				,strLotNumber
				,intDetailId
			)
			SELECT	@intLotId
					,@strLotNumber
					,@intDetailId
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

		--'The Quantity UOM for {Item} cannot be changed from {Item UOM} to {Item UOM} because a stock from it has been used from a different transaction.'
		RAISERROR(51044, 11, 1, @strItemNo, @strUnitMeasureItemUOMFrom, @strUnitMeasureItemUOMTo);
		RETURN;
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
		RAISERROR(51045, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN;
	END 

	-- Validation check point 3 of 5
	IF @errorFoundOnUpdate = 3
	BEGIN 
		-- Get the Sub Location String (proposed value)
		SELECT	@strSubLocatioNameTo = SubLocation.strSubLocationName
		FROM	dbo.tblSMCompanyLocationSubLocation SubLocation 
		WHERE	ISNULL(SubLocation.intCompanyLocationSubLocationId, 0) = ISNULL(@intSubLocationId, 0)

		--'The Sub-Location for {Lot number} cannot be changed from {Sub Location} to {Sub Location} because a stock from it has been used from a different transaction.'
		RAISERROR(51046, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN;
	END 

	-- Validation check point 4 of 5
	IF @errorFoundOnUpdate = 4
	BEGIN 
		-- Get the Storage Location String (proposed value)
		SELECT	@strSubLocatioNameTo = StorageLocation.strName
		FROM	 dbo.tblICStorageLocation StorageLocation 
		WHERE	ISNULL(StorageLocation.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		--'The Storage Location for {Lot number} cannot be changed from {Storage Location} to {StorageLocation} because a stock from it has been used from a different transaction.'
		RAISERROR(51047, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN;
	END

	-- Validation check point 5 of 5
	-- Validate if lot id is generated correctly. 
	IF ISNULL(@intLotId, 0) = 0 AND ISNULL(@intInsertedLotId, 0) = 0 
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Failed to process the lot number for {Item}. It may have been used on a different sub-location or storage location.'
		RAISERROR(51043, 11, 1, @strItemNo);
		RETURN;
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
		,@strBOLNo
		,@strVessel
		,@strReceiptNumber
		,@strMarkings
		,@strNotes
		,@intVendorId
		,@strVendorLotNo
		,@intVendorLocationId
		,@strVendorLocation
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId;
END

CLOSE loopLotItems;
DEALLOCATE loopLotItems;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
----------------------------------------------------------------------------------------------------------------------------