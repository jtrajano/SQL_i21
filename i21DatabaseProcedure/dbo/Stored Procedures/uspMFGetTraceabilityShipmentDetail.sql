CREATE PROCEDURE [dbo].[uspMFGetTraceabilityShipmentDetail] @intInventoryShipmentId INT
AS
DECLARE @dblShipQuantity NUMERIC(38, 20)
DECLARE @strUOM NVARCHAR(50)

SELECT @dblShipQuantity = SUM(ISNULL(dblQuantity, 0))
FROM tblICInventoryShipmentItem
WHERE intInventoryShipmentId = @intInventoryShipmentId

SELECT TOP 1 @strUOM = um.strUnitMeasure
FROM tblICItemUOM iu
JOIN tblICInventoryShipmentItem sd ON iu.intItemUOMId = sd.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId

SELECT 'Ship' AS strTransactionName
	,sh.intInventoryShipmentId
	,sh.strShipmentNumber
	,'' AS strLotAlias
	,0 intItemId
	,'' strItemNo
	,'' strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,@dblShipQuantity AS dblQuantity
	,@strUOM AS strUOM
	,sh.dtmShipDate AS dtmTransactionDate
	,c.strName
	,'S' AS strType
FROM tblICInventoryShipment sh
LEFT JOIN vyuARCustomer c ON sh.intEntityCustomerId = c.[intEntityId]
WHERE sh.intInventoryShipmentId = @intInventoryShipmentId
