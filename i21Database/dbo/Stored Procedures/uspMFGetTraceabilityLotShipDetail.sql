﻿CREATE PROCEDURE [dbo].[uspMFGetTraceabilityLotShipDetail] @intLotId INT
	,@ysnParentLot BIT = 0
	,@intLocationId int=NULL
AS
DECLARE @strLotNumber NVARCHAR(50)

SELECT @strLotNumber = strLotNumber
FROM tblICLot
WHERE intLotId = @intLotId

IF @ysnParentLot = 0
	SELECT 'Ship' AS strTransactionName
		,sh.intInventoryShipmentId
		,sh.strShipmentNumber
		,'' AS strLotAlias
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,SUM(shl.dblQuantityShipped) AS dblQuantity
		,um.strUnitMeasure AS strUOM
		,sh.dtmShipDate AS dtmTransactionDate
		,c.strName
		,'S' AS strType
	FROM tblICInventoryShipmentItemLot shl
	JOIN tblICInventoryShipmentItem shi ON shl.intInventoryShipmentItemId = shi.intInventoryShipmentItemId
	JOIN tblICInventoryShipment sh ON sh.intInventoryShipmentId = shi.intInventoryShipmentId
	JOIN tblICLot l ON shl.intLotId = l.intLotId
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iu ON shi.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN vyuARCustomer c ON sh.intEntityCustomerId = c.[intEntityId]
	WHERE sh.intShipFromLocationId= @intLocationId and shl.intLotId IN (
			SELECT intLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
			)
	group by 
		sh.intInventoryShipmentId
		,sh.strShipmentNumber
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,um.strUnitMeasure 
		,sh.dtmShipDate 
		,c.strName
	ORDER BY sh.intInventoryShipmentId

IF @ysnParentLot = 1
	SELECT DISTINCT 'Ship' AS strTransactionName
		,sh.intInventoryShipmentId
		,sh.strShipmentNumber
		,'' AS strLotAlias
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,SUM(shl.dblQuantityShipped) AS dblQuantity
		,um.strUnitMeasure AS strUOM
		,sh.dtmShipDate AS dtmTransactionDate
		,c.strName
		,'S' AS strType
	FROM tblICInventoryShipmentItemLot shl
	JOIN tblICInventoryShipmentItem shi ON shl.intInventoryShipmentItemId = shi.intInventoryShipmentItemId
	JOIN tblICInventoryShipment sh ON sh.intInventoryShipmentId = shi.intInventoryShipmentId
	JOIN tblICLot l ON shl.intLotId = l.intLotId
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iu ON shi.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN vyuARCustomer c ON sh.intEntityCustomerId = c.[intEntityId]
	WHERE sh.intShipFromLocationId=@intLocationId and l.intParentLotId = @intLotId
	group by 
		sh.intInventoryShipmentId
		,sh.strShipmentNumber
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,um.strUnitMeasure 
		,sh.dtmShipDate 
		,c.strName
	ORDER BY sh.intInventoryShipmentId
