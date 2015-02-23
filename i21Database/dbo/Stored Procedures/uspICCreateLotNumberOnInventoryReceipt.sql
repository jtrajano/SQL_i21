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
DECLARE @id AS INT
DECLARE @intItemLocationId AS INT 
DECLARE @GeneratedLotNumbers AS dbo.ItemLotTableType

DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

INSERT INTO @GeneratedLotNumbers (
	intItemId
	,intItemLocationId
	,intDetailId
)
SELECT	ReceiptItems.intItemId
		,ItemLocation.intItemLocationId
		,ItemLot.intInventoryReceiptItemLotId
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItems 
			ON Receipt.intInventoryReceiptId = ReceiptItems.intInventoryReceiptId
		INNER JOIN dbo.tblICItemLocation ItemLocation
			ON ReceiptItems.intItemId = ItemLocation.intItemId
			AND Receipt.intLocationId = ItemLocation.intLocationId
		INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot 			
			ON ReceiptItems.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId
WHERE	Receipt.strReceiptNumber = @strTransactionId
		AND ISNULL(intLotId, 0) = 0
		AND dbo.fnGetItemLotType(ReceiptItems.intItemId) = @LotType_Serial

-- Update the table variable and get all the items in the Item Lot table that does not have a lot number
SELECT	TOP 1 
		@id = intId 
		,@intItemLocationId = intItemLocationId
FROM	@GeneratedLotNumbers 
WHERE	ISNULL(intLotId, 0) = 0

WHILE @id IS NOT NULL 
BEGIN 
	-- Generate the next lot number 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @SerializedLotNumber OUTPUT   

	SET @intLotId = NULL 
	IF	ISNULL(@SerializedLotNumber, '') <> '' 
		AND NOT EXISTS (SELECT TOP 1 1 FROM tblICLot WHERE strLotNumber = @SerializedLotNumber)
	BEGIN
		INSERT INTO tblICLot (
			strLotNumber
			,intItemLocationId
		) VALUES (
			@SerializedLotNumber
			,@intItemLocationId
		)
		SET @intLotId = SCOPE_IDENTITY();
	END 

	-- Update the table variable 
	UPDATE	TOP (1) @GeneratedLotNumbers 
	SET		intLotId = @intLotId
			,strLotNumber = @SerializedLotNumber
	WHERE	@intLotId IS NOT NULL 
			AND intId = @id

	SET @id = NULL 
	SELECT	TOP 1 
			@id = intId
			,@intItemLocationId = intItemLocationId
	FROM	@GeneratedLotNumbers 
	WHERE	ISNULL(intLotId, 0) = 0
END

-- Give the generated lot numbers back to the inventory receipt. 
UPDATE	dbo.tblICInventoryReceiptItemLot
SET		intLotId = LotNumbers.intLotId
		,strLotId = LotNumbers.strLotNumber
FROM	dbo.tblICInventoryReceiptItemLot ItemLot INNER JOIN @GeneratedLotNumbers LotNumbers
			ON ItemLot.intInventoryReceiptItemLotId = LotNumbers.intDetailId
