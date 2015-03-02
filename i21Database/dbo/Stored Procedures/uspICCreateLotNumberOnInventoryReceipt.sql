CREATE PROCEDURE [dbo].[uspICCreateLotNumberOnInventoryReceipt]
	@strTransactionId NVARCHAR(40) = NULL   
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @STARTING_NUMBER_BATCH AS INT = 24 -- Lot Number batch number in the starting numbers table. 
DECLARE @SerializedLotNumber AS NVARCHAR(40) 
DECLARE @intLotId AS INT 
DECLARE @strUserSuppliedLotNumber AS NVARCHAR(50)
DECLARE @id AS INT
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemLocationId AS INT 
DECLARE @intItemUOMId AS INT
DECLARE @GeneratedLotNumbers AS dbo.ItemLotTableType
DECLARE @intLotTypeId AS INT

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

INSERT INTO @GeneratedLotNumbers (
		intItemId
		,strItemNo
		,intItemLocationId
		,intItemUOMId 
		,intDetailId
		,strLotNumber		,intLotTypeId
)
SELECT	ReceiptItems.intItemId
		,Item.strItemNo
		,ItemLocation.intItemLocationId
		,ReceiptItems.intUnitMeasureId
		,ItemLot.intInventoryReceiptItemLotId
		,ItemLot.strLotId
		,dbo.fnGetItemLotType(ReceiptItems.intItemId)
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItems 
			ON Receipt.intInventoryReceiptId = ReceiptItems.intInventoryReceiptId
		INNER JOIN dbo.tblICItem Item
			ON ReceiptItems.intItemId = Item.intItemId		
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ReceiptItems.intItemId = ItemLocation.intItemId
			AND Receipt.intLocationId = ItemLocation.intLocationId
		INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot 			
			ON ReceiptItems.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId
WHERE	Receipt.strReceiptNumber = @strTransactionId
		AND ISNULL(intLotId, 0) = 0

-- Update the table variable and get all the items in the Item Lot table that does not have a lot number
SELECT	TOP 1 
		@id = intId 
		,@strItemNo = strItemNo
		,@intItemLocationId = intItemLocationId
		,@intItemUOMId = intItemUOMId
		,@strUserSuppliedLotNumber = strLotNumber
		,@intLotTypeId = intLotTypeId
FROM	@GeneratedLotNumbers 
WHERE	ISNULL(intLotId, 0) = 0

WHILE @id IS NOT NULL 
BEGIN 
	-- Initialize the serial lot number field. 
	SET @SerializedLotNumber = @strUserSuppliedLotNumber

	-- Validate if the Manual lot item does not have a lot number. 
	IF ISNULL(@SerializedLotNumber, '') = '' AND @intLotTypeId = @LotType_Manual
	BEGIN 
		PRINT 'ERROR'
		--Please specify a lot number for %s
		RAISERROR(51041, 11, 1, @strItemNo);
		RETURN;
	END 

	-- Generate the next lot number if non is found AND it is a serial lot item. 
	IF ISNULL(@SerializedLotNumber, '') = '' 
	BEGIN 		
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @SerializedLotNumber OUTPUT 
	END 

		
	IF	ISNULL(@SerializedLotNumber, '') <> ''
	BEGIN  
		SET @intLotId = NULL 

		-- Get the Lot id or insert a new record on the Lot master table. 
		MERGE	
		INTO	dbo.tblICLot 
		WITH	(HOLDLOCK) 
		AS		LotMaster
		USING (
				SELECT	intItemLocationId = @intItemLocationId
						,intItemUOMId = @intItemUOMId
						,strLotNumber = @SerializedLotNumber
		) AS LotToUpdate
			ON LotMaster.intItemLocationId = LotToUpdate.intItemLocationId 
			AND LotMaster.intItemUOMId = LotToUpdate.intItemUOMId
			AND LotMaster.strLotNumber = LotToUpdate.strLotNumber 

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
				@SerializedLotNumber
				,@intItemLocationId
				,@intItemUOMId
			)
		;
		
		-- Get the lot id of the newly inserted record
		IF @intLotId IS NULL 
			SELECT @intLotId = SCOPE_IDENTITY();
	END 

	-- Update the table variable 
	UPDATE	TOP (1) @GeneratedLotNumbers 
	SET		intLotId = @intLotId
			,strLotNumber = @SerializedLotNumber
	WHERE	@intLotId IS NOT NULL 
			AND intId = @id

	-- Clean the values of the counter variables.
	SET @id = NULL 
	SET @strUserSuppliedLotNumber = NULL 

	SELECT	TOP 1 
			@id = intId 
			,@strItemNo = strItemNo
			,@intItemLocationId = intItemLocationId
			,@intItemUOMId = intItemUOMId
			,@strUserSuppliedLotNumber = strLotNumber
			,@intLotTypeId = intLotTypeId
	FROM	@GeneratedLotNumbers 
	WHERE	ISNULL(intLotId, 0) = 0
END

-- Give the generated lot numbers back to the inventory receipt. 
UPDATE	dbo.tblICInventoryReceiptItemLot
SET		intLotId = LotNumbers.intLotId
		,strLotId = LotNumbers.strLotNumber		
FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN @GeneratedLotNumbers LotNumbers
			ON ItemLot.intInventoryReceiptItemLotId = LotNumbers.intDetailId
			