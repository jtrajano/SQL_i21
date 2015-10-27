﻿CREATE PROCEDURE [dbo].[uspICCreateUpdateLotNumber]
	@ItemsForLot ItemLotTableType READONLY 
	,@intEntityUserSecurityId AS INT 
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
	,@intGradeId				AS INT
	,@strBOLNo					AS NVARCHAR(100)
	,@strVessel					AS NVARCHAR(100)
	,@strReceiptNumber			AS NVARCHAR(50)
	,@strMarkings				AS NVARCHAR(MAX)
	,@strNotes					AS NVARCHAR(MAX)
	,@intEntityVendorId				AS INT 
	,@strVendorLotNo			AS NVARCHAR(50)
	,@intVendorLocationId		AS INT
	,@strContractNo				AS NVARCHAR(50)
	,@ysnReleasedToWarehouse	AS BIT
	,@ysnProduced				AS BIT 
	,@intDetailId				AS INT 
	,@intOwnershipType			AS INT
	,@dblGrossWeight			AS NUMERIC(18,6)


DECLARE @OwnerShipType_Own AS INT = 1

---- Check for UNIQUE errors. 
--BEGIN
--	SELECT	TOP 1 
--			@strReceiptNumber = LotMaster.strReceiptNumber
--			,@strLotNumber = LotMaster.strLotNumber
--	FROM	tblICLot LotMaster INNER JOIN @ItemsForLot LotFromTransaction
--				ON LotMaster.intItemId = LotFromTransaction.intItemId
--				AND LotMaster.strLotNumber = LotFromTransaction.strLotNumber
--			INNER JOIN dbo.tblICItemLocation ItemLocation
--				ON ItemLocation.intItemLocationId = LotFromTransaction.intItemLocationId
--				AND LotMaster.intLocationId = ItemLocation.intLocationId
--	WHERE	ISNULL(LotMaster.dblQty, 0) > 0

--	IF ISNULL(@strReceiptNumber, '') <> ''
--	BEGIN 
--		-- 'The lot number {Lot Number} is already used in {Transaction Id}.'
--		RAISERROR(80018, 11, 1, @strLotNumber, @strReceiptNumber);
--		RETURN -9
--	END 
--END			

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
	GROUP BY LotFromTransaction.strLotNumber, LotFromTransaction.strReceiptNumber, Item.strItemNo, Item.intItemId, LotFromTransaction.intSubLocationId, LotFromTransaction.intStorageLocationId
	HAVING COUNT(1) > 1

	IF ISNULL(@strReceiptNumber, '') <> '' AND ISNULL(@strLotNumber, '') <> '' AND ISNULL(@strItemNo, '') <> ''
	BEGIN 
		-- 'Please check for duplicate lot numbers. The lot number {Lot Number} is used more than once in item {Item No} on {Transaction Id}.'
		RAISERROR(80019, 11, 1, @strLotNumber, @strItemNo, @strReceiptNumber);
		RETURN -1
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
		,intVendorLocationId
		,strContractNo
		,ysnReleasedToWarehouse
		,ysnProduced
		,intDetailId
		,intOwnershipType
		,dblGrossWeight
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
		,@intVendorLocationId
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId
		,@intOwnershipType
		,@dblGrossWeight

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
		RAISERROR(80005, 11, 1, @strItemNo);
		RETURN -2;
	END 	
	
	-- Generate the next lot number - if it is blank AND it is a serial lot item. 
	IF @intLotTypeId = @LotType_Serial AND @intLotId IS NULL 
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
		RAISERROR(80009, 11, 1, @strItemNo);
		RETURN -3;
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
		RAISERROR(80015, 11, 1, @strItemNo, @strLotNumber)  
		RETURN -4; 
	END 

	-- Check if Item and Weight UOM are the same value. 
	--IF @intItemUOMId = @intWeightUOMId
	--BEGIN 
	--	SELECT	@strItemNo = strItemNo
	--	FROM	dbo.tblICItem Item
	--	WHERE	Item.intItemId = @intItemId

	--	IF @intLotTypeId = @LotType_Serial
	--	BEGIN 
	--		SET @strLotNumber = '(To be generated)'
	--	END 

	--	-- Cannot have the same item and weight UOM. Please remove the weight UOM for {Item} with lot number {Lot Number}.
	--	RAISERROR(80042, 11, 1, @strItemNo, @strLotNumber)  
	--	RETURN -5; 
	--END 

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
				,strMarkings			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strMarkings ELSE LotMaster.strMarkings END 
				,strNotes				= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strNotes ELSE LotMaster.strNotes END 
				,intEntityVendorId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intEntityVendorId ELSE LotMaster.intEntityVendorId END 
				,strVendorLotNo			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strVendorLotNo ELSE LotMaster.strVendorLotNo END 
				,intVendorLocationId	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @intVendorLocationId ELSE LotMaster.intVendorLocationId END
				,strContractNo			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @strContractNo ELSE LotMaster.strContractNo END 
				,dtmManufacturedDate	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @dtmManufacturedDate ELSE LotMaster.dtmManufacturedDate END 
								
				-- Find out if there any possible errors when updating an existing lot record. 
				,@errorFoundOnUpdate	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) <> 0 THEN 
													CASE	WHEN ISNULL(LotMaster.intItemUOMId, 0) <> LotToUpdate.intItemUOMId THEN 1 
															WHEN ISNULL(LotMaster.intWeightUOMId, 0) <> LotToUpdate.intWeightUOMId THEN 2
															WHEN ISNULL(LotMaster.intSubLocationId, 0) <> ISNULL(LotToUpdate.intSubLocationId, 0) THEN 3
															WHEN ISNULL(LotMaster.intStorageLocationId, 0) <> ISNULL(LotToUpdate.intStorageLocationId, 0) THEN 4
															ELSE 0 
													END 
												ELSE 0
										  END
				-- Allow update on the following fields if dblQty is zero.  
				,dblWeightPerQty		=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN 														
														CASE	WHEN ISNULL(LotToUpdate.intWeightUOMId, 0) <> 0 THEN 
																	dbo.fnCalculateWeightUnitQty(LotToUpdate.dblQty, LotToUpdate.dblWeight) 
																ELSE 0 
														END 
													ELSE 
														-- Increase the weight per Qty if there is an incoming stock for the lot. 
														CASE	WHEN LotToUpdate.dblQty > 0  THEN 
																	dbo.fnCalculateWeightUnitQty(
																		(
																			LotMaster.dblQty 
																			+ LotToUpdate.dblQty
																		)
																		,(
																			(CAST(LotMaster.dblQty AS FLOAT) * CAST(LotMaster.dblWeightPerQty AS FLOAT))
																			+ CAST(LotToUpdate.dblWeight AS FLOAT) 
																		)
																	) 
																ELSE 
																	LotMaster.dblWeightPerQty 
														END 

											END
				,intItemUOMId			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intItemUOMId ELSE LotMaster.intItemUOMId END
				,intWeightUOMId			= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intWeightUOMId ELSE LotMaster.intWeightUOMId END
				,intSubLocationId		= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intSubLocationId ELSE LotMaster.intSubLocationId END
				,intStorageLocationId	= CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotToUpdate.intStorageLocationId ELSE LotMaster.intStorageLocationId END

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
											) THEN @intLotStatusId ELSE LotMaster.intLotStatusId
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
													) THEN 
														ISNULL(LotMaster.dblGrossWeight, 0) + @dblGrossWeight 
													ELSE 
														LotMaster.dblGrossWeight 
											END 
															
				
				-- CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN @dblGrossWeight ELSE LotMaster.dblGrossWeight END

				-- The following field are returned from the lot master if:
				-- 1. It is editing from the source transaction id
				-- 2. The item UOM, Weight UOM, Sub Location, and Storage Location matches exactly. 
				-- Otherwise, it returns zero. 
				,@intInsertedLotId		=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotMaster.intLotId
													WHEN (
														LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
														AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN LotMaster.intLotId 
													ELSE 0 
											END
				,@intLotId				=	CASE	WHEN ISNULL(LotMaster.dblQty, 0) = 0 THEN LotMaster.intLotId
													WHEN (
														LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
														AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
														AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
														AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)
													) THEN LotMaster.intLotId 
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
				,intVendorLocationId
				,strContractNo
				,dtmManufacturedDate
				,ysnReleasedToWarehouse
				,ysnProduced
				,dtmDateCreated
				,intCreatedEntityId
				,intConcurrencyId
				,intOwnershipType
				,dblGrossWeight
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
				,CASE WHEN ISNULL(@intWeightUOMId, 0) <> 0 THEN 
						dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight) -- (though, we need to know immediately the weight per qty). 
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
				,@intVendorLocationId
				,@strContractNo
				,@dtmManufacturedDate
				,@ysnReleasedToWarehouse
				,@ysnProduced
				,GETDATE()
				,@intEntityUserSecurityId
				,1
				,@intOwnershipType
				,@dblGrossWeight
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
		RAISERROR(80011, 11, 1, @strItemNo, @strUnitMeasureItemUOMFrom, @strUnitMeasureItemUOMTo);
		RETURN -6;
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
		RAISERROR(80012, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN -7;
	END 

	-- Validation check point 3 of 5
	IF @errorFoundOnUpdate = 3
	BEGIN 
		-- Get the Sub Location String (proposed value)
		SELECT	@strSubLocatioNameTo = SubLocation.strSubLocationName
		FROM	dbo.tblSMCompanyLocationSubLocation SubLocation 
		WHERE	ISNULL(SubLocation.intCompanyLocationSubLocationId, 0) = ISNULL(@intSubLocationId, 0)

		--'The Sub-Location for {Lot number} cannot be changed from {Sub Location} to {Sub Location} because a stock from it has been used from a different transaction.'
		RAISERROR(80013, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN -8;
	END 

	-- Validation check point 4 of 5
	IF @errorFoundOnUpdate = 4
	BEGIN 
		-- Get the Storage Location String (proposed value)
		SELECT	@strSubLocatioNameTo = StorageLocation.strName
		FROM	 dbo.tblICStorageLocation StorageLocation 
		WHERE	ISNULL(StorageLocation.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)

		--'The Storage Location for {Lot number} cannot be changed from {Storage Location} to {StorageLocation} because a stock from it has been used from a different transaction.'
		RAISERROR(80014, 11, 1, @strLotNumber, @strUnitMeasureWeightUOMFrom, @strUnitMeasureWeightUOMTo);
		RETURN -9;
	END

	-- Validation check point 5 of 5
	-- Validate if lot id is generated correctly. 
	IF ISNULL(@intLotId, 0) = 0 AND ISNULL(@intInsertedLotId, 0) = 0 
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Failed to process the lot number for {Item}. It may have been used on a different sub-location or storage location.'
		RAISERROR(80010, 11, 1, @strItemNo);
		RETURN -10;
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
		,@intVendorLocationId
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId
		,@intOwnershipType
		,@dblGrossWeight;
END

CLOSE loopLotItems;
DEALLOCATE loopLotItems;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
----------------------------------------------------------------------------------------------------------------------------

RETURN 0;
