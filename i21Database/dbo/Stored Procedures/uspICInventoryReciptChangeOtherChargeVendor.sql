CREATE PROCEDURE [dbo].[uspICInventoryReciptChangeOtherChargeVendor]
	@ReceiptId INT,
	@UserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  
	

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceipt r WHERE r.intInventoryReceiptId = @ReceiptId AND r.ysnNewOtherChargeVendor = 1)
BEGIN 
	RETURN; 
END 


SELECT * 
FROM
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
WHERE
	rc.intNewEntityVendorId IS NOT NULL