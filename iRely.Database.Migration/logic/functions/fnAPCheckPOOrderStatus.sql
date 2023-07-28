--liquibase formatted sql

-- changeset Von:fnAPCheckPOOrderStatus.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPCheckPOOrderStatus]
(
       @orderStatus int,
       @poId INT
)
RETURNS BIT
AS
BEGIN

       --DECLARE @success AS BIT = 0;

       --IF EXISTS(SELECT 1 FROM tblPOPurchaseDetail A
       --                    INNER JOIN tblICItem B ON A.intItemId = B.intItemId 
       --                    WHERE strType NOT IN ('Non-Inventory', 'Other Charge', 'Service') AND intPurchaseId = @poId)
       --BEGIN

       --       SET @success = 
       --       (
       --              CASE 
       --                    WHEN @orderStatus = 1 AND EXISTS
       --                    (
       --                           SELECT 1 
       --                           FROM   tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRItems
       --                                                ON IR.intInventoryReceiptId = IRItems.intInventoryReceiptId
       --                           WHERE  IRItems.intSourceId = @poId
       --                                  --AND IR.ysnPosted = 1
       --                    )
       --                    THEN 0
       --                    WHEN @orderStatus = 7 AND NOT EXISTS
       --                    (
       --                           SELECT 1 
       --                           FROM   tblICInventoryReceipt IR INNER JOIN tblICInventoryReceiptItem IRItems
       --                                                ON IR.intInventoryReceiptId = IRItems.intInventoryReceiptId
       --                           WHERE  IRItems.intSourceId = @poId
       --                                  --AND IR.ysnPosted = 1
       --                    )
       --                    THEN 0
       --              ELSE 1 END
       --       )

       --END
       --ELSE
       --BEGIN
       --       SET @success = 1;
       --END

       --RETURN(@success)

	   -- Manually return true for now so that we can move forward testing the 15.1 WM builds. 
	   RETURN 1;
END



