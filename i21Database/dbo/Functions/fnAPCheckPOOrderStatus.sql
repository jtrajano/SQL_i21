CREATE FUNCTION [dbo].[fnAPCheckPOOrderStatus]
(
       @orderStatus int,
       @poId INT
)
RETURNS BIT
AS
BEGIN

       DECLARE @success AS BIT = 0;

       IF EXISTS(SELECT 1 FROM tblPOPurchaseDetail A
                           INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
                           WHERE strType NOT IN ('Non-Inventory', 'Other Charge', 'Service', 'Software') AND intPurchaseId = @poId)
       BEGIN

              SET @success = 
              (
                     CASE 
                           WHEN @orderStatus = 1 AND EXISTS
                           (
                                  SELECT 1 
                                  FROM   tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRItems
                                                       ON IR.intInventoryReceiptId = IRItems.intInventoryReceiptId
                                  WHERE  IRItems.intSourceId = @poId
                                                --AND IR.ysnPosted = 1
                           )
                           THEN 0
                           WHEN @orderStatus = 7 AND NOT EXISTS
                           (
                                  SELECT 1 
                                  FROM   tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRItems
                                                       ON IR.intInventoryReceiptId = IRItems.intInventoryReceiptId
                                  WHERE  IRItems.intSourceId = @poId
                                                --AND IR.ysnPosted = 1
                           )
                           THEN 0
                     ELSE 1 END
              )

       END
       ELSE
       BEGIN
              SET @success = 1;
       END

       RETURN(@success)
END
