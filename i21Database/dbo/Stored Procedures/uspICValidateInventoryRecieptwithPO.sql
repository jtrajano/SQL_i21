/*
	This stored procedure will validate the Unit of Measure used in the Inventory Receipt.
	It should match to the UOM used in the PO. 	
*/
CREATE PROCEDURE [dbo].[uspICValidateInventoryRecieptwithPO]
	@strTransactionId AS NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intPO_UOMId AS INT
		,@strPOUOMName AS NVARCHAR(50)
		
DECLARE @intIR_UOMId AS INT
		,@strIRUOMName AS NVARCHAR(50)

DECLARE @intItemId AS INT
		,@strItemNo AS NVARCHAR(50)

-- Get the invalid records. 
SELECT	TOP 1 
		@intPO_UOMId = PODetail.intUnitOfMeasureId
		,@intIR_UOMId = ReceiptItem.intUnitMeasureId
		,@intItemId = ReceiptItem.intItemId		
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN dbo.tblPOPurchaseDetail PODetail
			ON ReceiptItem.intLineNo = PODetail.intPurchaseDetailId
			AND ReceiptItem.intSourceId = PODetail.intPurchaseId
WHERE	Receipt.strReceiptNumber = @strTransactionId
		AND ReceiptItem.intUnitMeasureId <> PODetail.intUnitOfMeasureId

-- If there is an invalid record, raise the error. 
IF @intItemId IS NOT NULL 
BEGIN 
	SELECT	@strItemNo = strItemNo
	FROM	dbo.tblICItem
	WHERE	intItemId = @intItemId
	
	SELECT	@strPOUOMName = tblICUnitMeasure.strUnitMeasure
	FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
				ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
	WHERE	intItemUOMId = @intPO_UOMId 

	SELECT	@strIRUOMName = tblICUnitMeasure.strUnitMeasure
	FROM	dbo.tblICItemUOM INNER JOIN dbo.tblICUnitMeasure
				ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
	WHERE	intItemUOMId = @intIR_UOMId 

	-- 'Please correct the UOM. The UOM for {Item} in PO is {PO UOM}. It is now using {IR UOM} in the Inventory Receipt'
	RAISERROR(51049, 11, 1, @strItemNo, @strPOUOMName, @strIRUOMName)  

	RETURN -1;
END 

RETURN 0