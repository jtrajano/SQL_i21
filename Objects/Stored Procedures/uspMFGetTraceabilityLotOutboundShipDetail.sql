CREATE PROCEDURE uspMFGetTraceabilityLotOutboundShipDetail @intLotId INT
	,@ysnParentLot BIT = 0
AS
DECLARE @strLotNumber NVARCHAR(50)

SELECT @strLotNumber = strLotNumber
FROM tblICLot
WHERE intLotId = @intLotId

IF @ysnParentLot = 0
	SELECT 'Ship' AS strTransactionName
		,l.intLoadId
		,l.strLoadNumber
		,'' AS strLotAlias
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,ldl.dblLotQuantity AS dblQuantity
		,um.strUnitMeasure AS strUOM
		,l.dtmScheduledDate AS dtmTransactionDate
		,c.strName
		,'OS' AS strType
	FROM tblLGLoadDetailLot ldl
	JOIN tblLGLoadDetail ld ON ldl.intLoadDetailId = ld.intLoadDetailId
	JOIN tblLGLoad l ON l.intLoadId = ld.intLoadId
	JOIN tblICLot l1 ON l1.intLotId = ldl.intLotId
	JOIN tblICItem i ON l1.intItemId = i.intItemId
	JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iu ON ldl.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN vyuARCustomer c ON l.intEntityId = c.[intEntityId]
	WHERE ldl.intLotId IN (
			SELECT intLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
			)
	ORDER BY l.intLoadId

IF @ysnParentLot = 1
	SELECT DISTINCT 'Ship' AS strTransactionName
		,l.intLoadId
		,l.strLoadNumber
		,'' AS strLotAlias
		,i.intItemId
		,i.strItemNo
		,i.strDescription
		,mt.intCategoryId
		,mt.strCategoryCode
		,ldl.dblLotQuantity AS dblQuantity
		,um.strUnitMeasure AS strUOM
		,l.dtmScheduledDate AS dtmTransactionDate
		,c.strName
		,'OS' AS strType
	FROM tblLGLoadDetailLot ldl
	JOIN tblLGLoadDetail ld ON ldl.intLoadDetailId = ld.intLoadDetailId
	JOIN tblLGLoad l ON l.intLoadId = ld.intLoadId
	JOIN tblICLot l1 ON l1.intLotId = ldl.intLotId
	JOIN tblICItem i ON l.intItemId = i.intItemId
	JOIN tblICCategory mt ON mt.intCategoryId = i.intCategoryId
	JOIN tblICItemUOM iu ON ldl.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	LEFT JOIN vyuARCustomer c ON l.intEntityId = c.[intEntityId]
	WHERE l1.intParentLotId = @intLotId
	ORDER BY l.intLoadId
