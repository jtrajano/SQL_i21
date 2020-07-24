CREATE PROCEDURE [dbo].[uspICSaveReceiptCleanChargesPerItem]
	@guiUniqueId UNIQUEIDENTIFIER
AS

DELETE c
FROM tblICInventoryReceiptChargePerItem c 
INNER JOIN tblICStagingReceiptChargePerItem s ON s.intReceiptItemId = c.intInventoryReceiptItemId
	AND s.intReceiptId = c.intInventoryReceiptId
WHERE s.guiUniqueId = @guiUniqueId

DELETE FROM tblICStagingReceiptChargePerItem WHERE @guiUniqueId = @guiUniqueId