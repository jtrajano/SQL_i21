CREATE PROCEDURE [dbo].[uspICInventoryReceiptUpdateInternalComments]
	@ReceiptId INT,
	@UserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON

UPDATE lot
SET lot.strCargoNo = rlot.strCargoNo,
	lot.strWarrantNo = rlot.strWarrantNo,
	lot.dtmDateModified = GETUTCDATE(),
	lot.intModifiedByUserId = @UserId
FROM tblICLot lot
	INNER JOIN tblICInventoryReceiptItemLot rlot ON rlot.intLotId = lot.intLotId
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = rlot.intInventoryReceiptItemId
WHERE ri.intInventoryReceiptId = @ReceiptId