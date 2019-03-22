CREATE PROCEDURE [dbo].[uspMFGetTraceabilityShipmentLots] @intInventoryShipmentId INT
	,@ysnParentLot BIT = 0
AS
IF @ysnParentLot = 0
	SELECT 'Ship' AS strTransactionName
		,t.intLotId
		,t.strLotNumber
		,t.strLotAlias
		,t.intItemId
		,t.strItemNo
		,t.strDescription
		,t.intCategoryId
		,t.strCategoryCode
		,SUM(t.dblQuantity) AS dblQuantity
		,MAX(t.strUOM) AS strUOM
		,MAX(t.dtmTransactionDate) AS dtmTransactionDate
		,t.intParentLotId
		,'L' AS strType
		,t.intImageTypeId
	FROM (
		SELECT DISTINCT 'Ship' AS strTransactionName
			,l.intLotId
			,l.strLotNumber
			,l.strLotAlias
			,i.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,shl.dblQuantityShipped AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,sh.dtmShipDate AS dtmTransactionDate
			,l.intParentLotId
			,4 AS intImageTypeId
		FROM tblICInventoryShipmentItemLot shl
		JOIN tblICInventoryShipmentItem shi ON shl.intInventoryShipmentItemId = shi.intInventoryShipmentItemId
		JOIN tblICInventoryShipment sh ON sh.intInventoryShipmentId = shi.intInventoryShipmentId
		JOIN tblICLot l ON shl.intLotId = l.intLotId
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICItemUOM iu ON shi.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE sh.intInventoryShipmentId = @intInventoryShipmentId
		) t
	GROUP BY t.strTransactionName
		,t.intItemId
		,t.strItemNo
		,t.strDescription
		,intCategoryId
		,t.strCategoryCode
		,t.intLotId
		,t.strLotNumber
		,t.strLotAlias
		,t.intParentLotId
		,t.intImageTypeId

IF @ysnParentLot = 1
	SELECT 'Ship' AS strTransactionName
		,t.intLotId
		,t.strLotNumber
		,t.strLotAlias
		,t.intItemId
		,t.strItemNo
		,t.strDescription
		,t.intCategoryId
		,t.strCategoryCode
		,SUM(t.dblQuantity) AS dblQuantity
		,MAX(t.strUOM) AS strUOM
		,MAX(t.dtmTransactionDate) AS dtmTransactionDate
		,t.intParentLotId
		,'L' AS strType
		,t.intImageTypeId
	FROM (
		SELECT DISTINCT 'Ship' AS strTransactionName
			,pl.intParentLotId AS intLotId
			,pl.strParentLotNumber AS strLotNumber
			,pl.strParentLotAlias AS strLotAlias
			,i.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,shl.dblQuantityShipped AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,sh.dtmShipDate AS dtmTransactionDate
			,l.intParentLotId
			,4 AS intImageTypeId
		FROM tblICInventoryShipmentItemLot shl
		JOIN tblICInventoryShipmentItem shi ON shl.intInventoryShipmentItemId = shi.intInventoryShipmentItemId
		JOIN tblICInventoryShipment sh ON sh.intInventoryShipmentId = shi.intInventoryShipmentId
		JOIN tblICLot l ON shl.intLotId = l.intLotId
		JOIN tblICParentLot pl ON l.intParentLotId = pl.intParentLotId
		JOIN tblICItem i ON l.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICItemUOM iu ON shi.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE sh.intInventoryShipmentId = @intInventoryShipmentId
		) t
	GROUP BY t.strTransactionName
		,t.intItemId
		,t.strItemNo
		,t.strDescription
		,intCategoryId
		,t.strCategoryCode
		,t.intLotId
		,t.strLotNumber
		,t.strLotAlias
		,t.intParentLotId
		,t.intImageTypeId
