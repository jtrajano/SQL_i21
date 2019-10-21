CREATE PROCEDURE uspMFUpdateLotTareWeight
AS
BEGIN
	DECLARE @tblMFInventoryReceipt TABLE (intInventoryReceiptId INT)
	DECLARE @tblMFLotTareWeight TABLE (
		strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblTareWeight NUMERIC(38, 20)
		)

	INSERT INTO @tblMFInventoryReceipt (intInventoryReceiptId)
	SELECT IR.intInventoryReceiptId
	FROM tblICInventoryReceipt IR
	WHERE ysnPosted = 1
		AND NOT EXISTS (
			SELECT *
			FROM tblMFLotTareWeight TW
			WHERE TW.intInventoryReceiptId = IR.intInventoryReceiptId
			)
	ORDER BY IR.intInventoryReceiptId

	INSERT INTO @tblMFLotTareWeight (
		strLotNumber
		,dblTareWeight
		)
	SELECT RL.strLotNumber
		,RL.dblTareWeight
	FROM tblICInventoryReceiptItemLot RL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RL.intInventoryReceiptItemId
	JOIN @tblMFInventoryReceipt IR ON IR.intInventoryReceiptId = RI.intInventoryReceiptId

	UPDATE LI
	SET dblTareWeight = TW.dblTareWeight
	FROM @tblMFLotTareWeight TW
	JOIN tblICLot L ON L.strLotNumber = TW.strLotNumber
	JOIN tblMFLotInventory LI ON LI.intLotId = L.intLotId

	INSERT INTO tblMFLotTareWeight (intInventoryReceiptId)
	SELECT intInventoryReceiptId
	FROM @tblMFInventoryReceipt
END

