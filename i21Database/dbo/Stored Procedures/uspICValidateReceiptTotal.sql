CREATE PROCEDURE uspICValidateReceiptTotal  
	@intReceiptId AS INT = NULL,
    @ysnValid BIT OUTPUT
AS  

DECLARE @dblDifference AS NUMERIC(38, 15)

SELECT @dblDifference = (dblInvoiceAmount - dblGrandTotal) FROM tblICInventoryReceipt WHERE intInventoryReceiptId = @intReceiptId

SET @ysnValid = CASE WHEN @dblDifference <> 0 THEN 0 ELSE 1 END 