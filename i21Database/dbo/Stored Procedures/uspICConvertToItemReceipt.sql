
CREATE PROCEDURE [dbo].[uspICConvertToItemReceipt]
	@ItemsToReceive AS ItemCostingTableType READONLY 
	,@SourceTransactionId AS INT
	,@SourceType AS INT 
	,@intUserId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Constant variables the source type
DECLARE @SourceType_PurchaseOrder AS INT = 1;

----------------------------------
-- Run the validation 
----------------------------------

--------------------------------------------------
-- Run the actual creation for the Item Receipt
--------------------------------------------------

-------------------------------------------------
-- Increase the On-Order Qty for the items
-------------------------------------------------
UPDATE	Stock 
SET		Stock.dblOnOrder = ISNULL(Stock.dblOnOrder, 0) + (ISNULL(Items.dblUnitQty, 0) * ISNULL(Items.dblUOMQty, 0))
FROM	dbo.tblICItemStock Stock INNER JOIN @ItemsToReceive Items
			ON Stock.intItemId = Items.intItemId
			AND Stock.intLocationId = Items.intLocationId


