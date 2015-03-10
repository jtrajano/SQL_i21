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
		,intDetailItemId INT 
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

	-- Upsert (update or insert) the record to the lot master table. 
	BEGIN  
		SET @intInsertedLotId = NULL 

		-- Get the Lot id or insert a new record on the Lot master table. 
		MERGE	
		INTO	dbo.tblICLot 
		WITH	(HOLDLOCK) 
		AS		LotMaster
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intItemUOMId = @intItemUOMId
						,intWeightUOMId = @intWeightUOMId
						,strLotNumber = @strLotNumber
						,intSubLocationId = @intSubLocationId
						,intStorageLocationId = @intStorageLocationId
		) AS LotToUpdate
			ON LotMaster.intItemLocationId = LotToUpdate.intItemLocationId 
			AND LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
			AND LotMaster.strLotNumber = LotToUpdate.strLotNumber 
			AND ISNULL(LotMaster.intWeightUOMId, 0) = ISNULL(LotToUpdate.intWeightUOMId, 0)
			AND ISNULL(LotMaster.intSubLocationId, 0) = ISNULL(LotToUpdate.intSubLocationId, 0)
			AND ISNULL(LotMaster.intStorageLocationId, 0) = ISNULL(LotToUpdate.intStorageLocationId, 0)

		-- If matched, get the Lot Id. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		
				dblQty					= @dblQty
				,dtmExpiryDate			= @dtmExpiryDate
				,strLotAlias			= @strLotAlias
				,intLotStatusId			= @intLotStatusId
				,dblWeight				= @dblWeight
				,dblWeightPerQty		= dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight)
				,intOriginId			= @intOriginId
				,strBOLNo				= @strBOLNo
				,strVessel				= @strVessel
				,strReceiptNumber		= @strReceiptNumber
				,strMarkings			= @strMarkings
				,strNotes				= @strNotes
				,intVendorId			= @intVendorId
				,strVendorLotNo			= @strVendorLotNo
				,intVendorLocationId	= @intVendorLocationId
				,strVendorLocation		= @strVendorLocation
				,strContractNo			= @strContractNo
				,dtmManufacturedDate	= @dtmManufacturedDate
				,ysnReleasedToWarehouse = @ysnReleasedToWarehouse
				,ysnProduced			= @ysnProduced
				,intConcurrencyId		= ISNULL(intConcurrencyId, 0) + 1
				,@intInsertedLotId		= intLotId

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
				,@dblQty
				,@dtmExpiryDate
				,@strLotAlias
				,@intLotStatusId
				,@dblWeight
				,@intWeightUOMId
				,dbo.fnCalculateWeightUnitQty(@dblQty, @dblWeight)
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
			SELECT @intInsertedLotId = SCOPE_IDENTITY();	 

		-- Insert into a temp table 
		BEGIN 
			INSERT INTO #GeneratedLotItems (
				intLotId
				,strLotNumber
				,intDetailItemId
			)
			SELECT	@intInsertedLotId
					,@strLotNumber
					,@intDetailId
		END 
	END 

	-- Validate if lot id is generated correctly. 
	IF ISNULL(@intLotId, 0) = 0 AND ISNULL(@intInsertedLotId, 0) = 0 
	BEGIN 
		SELECT	@strItemNo = strItemNo
		FROM	dbo.tblICItem Item
		WHERE	Item.intItemId = @intItemId

		--Failed to process the lot number for {Item}.
		RAISERROR(51043, 11, 1, @strItemNo);
		RETURN;
	END 	
	
	-- Fetch the next row from cursor. 
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

CLOSE loopItems;
DEALLOCATE loopItems;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

