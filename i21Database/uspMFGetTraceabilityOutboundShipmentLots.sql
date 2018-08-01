CREATE PROCEDURE uspMFGetTraceabilityOutboundShipmentLots @intLoadId INT
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
			,l1.intLotId
			,l1.strLotNumber
			,l1.strLotAlias
			,i.intItemId
			,i.strItemNo
			,i.strDescription
			,mt.intCategoryId
			,mt.strCategoryCode
			,ldl.dblLotQuantity AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmScheduledDate  AS dtmTransactionDate
			,l1.intParentLotId
			,4 AS intImageTypeId
		FROM tblLGLoadDetailLot ldl
		JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = ldl.intLoadDetailId
		JOIN tblLGLoad l ON l.intLoadId = ld.intLoadId
		JOIN tblICLot l1 ON ldl.intLotId = l1.intLotId
		JOIN tblICItem i ON l1.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICItemUOM iu ON ldl.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE l.intLoadId  = @intLoadId
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
			,ldl.dblLotQuantity AS dblQuantity
			,um.strUnitMeasure AS strUOM
			,l.dtmScheduledDate  AS dtmTransactionDate
			,l1.intParentLotId
			,4 AS intImageTypeId
		FROM tblLGLoadDetailLot  ldl
		JOIN tblLGLoadDetail ld ON ld.intLoadDetailId  = ldl.intLoadDetailId
		JOIN tblLGLoad l ON l.intLoadId = ld.intLoadId 
		JOIN tblICLot l1 ON ldl.intLotId = l1.intLotId
		JOIN tblICParentLot pl ON l1.intParentLotId = pl.intParentLotId
		JOIN tblICItem i ON l1.intItemId = i.intItemId
		JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
		JOIN tblICItemUOM iu ON ldl.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		WHERE l.intLoadId = @intLoadId
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
