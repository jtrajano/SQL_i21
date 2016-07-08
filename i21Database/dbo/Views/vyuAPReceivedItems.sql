CREATE VIEW [dbo].[vyuAPReceivedItems]
AS

SELECT
CAST(ROW_NUMBER() OVER(ORDER BY intInventoryReceiptItemId, intPurchaseDetailId) AS INT) AS intReceivedItemId
,Items.*
FROM
(
	SELECT * FROM vyuAPPurchaseOrderPayables
	UNION ALL
	SELECT * FROM [vyuAPReceiptPayables]
	UNION ALL
	SELECT * FROM [vyuAPLogisticsPayables]
	UNION ALL
	SELECT * FROM [vyuAPLogisticsPayables]
) Items
GO