CREATE PROCEDURE [dbo].[uspICCreateUpdateLotNumber]
	@ItemsForLot ItemLotTableType READONLY 
	,@intUserId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE @id AS INT

--DECLARE @intItemLocationId AS INT 
--DECLARE @intItemUOMId AS INT

DECLARE @intInsertedLotId AS INT 
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intLotTypeId AS INT

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

-- Lot Number batch number in the starting numbers table. 
DECLARE @STARTING_NUMBER_BATCH AS INT = 24 

DECLARE @LotNumber AS NVARCHAR(40) 
DECLARE @strUserSuppliedLotNumber AS NVARCHAR(50)

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
	,@dblWeightQty				AS NUMERIC(18,6)
	,@intWeightUOMId			AS INT
	,@dtmExpiryDate				AS DATETIME
	,@dtmManufacturedDate		AS DATETIME
	,@intOriginId				AS INT
	,@strBOLNo					AS NVARCHAR(100)
	,@strVessel					AS NVARCHAR(100)
	,@strReceiptNumber			AS NVARCHAR(50)
	,@strMarkings				AS NVARCHAR(100)
	,@strNotes					AS NVARCHAR(100)
	,@intVendorId				AS INT 
	,@strVendorLotNo			AS NVARCHAR(50)
	,@intVendorLocationId		AS INT
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
		,dblWeightQty
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
		,strContractNo
		,ysnReleasedToWarehouse
		,ysnProduced
		,intDetailId
FROM	@ItemsForLot

OPEN loopLotItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO 
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
		,@dblWeightQty
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

		-- Validate if the Manual lot item does not have a lot number. 
		IF ISNULL(@strLotNumber, '') = '' AND @intLotTypeId = @LotType_Manual
		BEGIN 
			SELECT	@strItemNo = strItemNo
			FROM	dbo.tblICItem Item
			WHERE	Item.intItemId = @intItemId

			--Please specify the lot numbers for %s.
			RAISERROR(51037, 11, 1, @strItemNo);
			RETURN;
		END 

		-- Generate the next lot number if non is found AND it is a serial lot item. 
		IF @intLotTypeId = @LotType_Serial
		BEGIN 		
			EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strLotNumber OUTPUT 
		END 
		
		IF ISNULL(@strLotNumber, '') <> ''
		BEGIN  
			SET @intInsertedLotId = NULL 

			-- Get the Lot id or insert a new record on the Lot master table. 
			MERGE	
			INTO	dbo.tblICLot 
			WITH	(HOLDLOCK) 
			AS		LotMaster
			USING (
					SELECT	intItemLocationId = @intItemLocationId
							,intItemUOMId = @intItemUOMId
							,strLotNumber = @LotNumber
							,intSubLocationId = @intSubLocationId
							,intStorageLocationId = @intStorageLocationId
			) AS LotToUpdate
				ON LotMaster.intItemLocationId = LotToUpdate.intItemLocationId 
				AND LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
				AND LotMaster.strLotNumber = LotToUpdate.strLotNumber 
				AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
				AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)

			-- If matched, get the Lot Id. 
			WHEN MATCHED THEN 
				UPDATE 
				SET		@intLotId = LotMaster.intLotId 

			-- If none found, insert a new lot record. 
			WHEN NOT MATCHED THEN 
				INSERT (
					strLotNumber
					,intItemLocationId
					,intItemUOMId
				) VALUES (
					@LotNumber
					,@intItemLocationId
					,@intItemUOMId
				)
			;
		
			-- Get the lot id of the newly inserted record
			IF @intInsertedLotId IS NULL 
				SELECT @intInsertedLotId = SCOPE_IDENTITY();
		END 

		-- Insert into a temp table 
		-- 1. the @intInsertedLotId
		-- 2. the intDetailItemId	

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO 
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
		,@dblWeightQty
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
		,@strContractNo
		,@ysnReleasedToWarehouse
		,@ysnProduced
		,@intDetailId;
END
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;
