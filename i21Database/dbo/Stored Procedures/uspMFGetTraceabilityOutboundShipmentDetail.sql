CREATE PROCEDURE uspMFGetTraceabilityOutboundShipmentDetail @intLoadId INT
AS
DECLARE @dblShipQuantity NUMERIC(38, 20)
DECLARE @strUOM NVARCHAR(50)
	,@strItemNo NVARCHAR(MAX)
	,@strDescription NVARCHAR(MAX)

SELECT @dblShipQuantity = SUM(ISNULL(dblQuantity, 0))
FROM tblLGLoadDetail
WHERE intLoadId = @intLoadId

SELECT TOP 1 @strUOM = um.strUnitMeasure
FROM tblICItemUOM iu
JOIN tblLGLoadDetail ld ON iu.intItemUOMId = ld.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
WHERE ld.intLoadId = @intLoadId

SELECT @strItemNo = ''
	,@strDescription = ''

SELECT @strItemNo = @strItemNo + strItemNo + ', '
	,@strDescription = @strDescription + strDescription + ', '
FROM tblLGLoadDetail ld
JOIN tblICItem I ON I.intItemId = ld.intItemId
WHERE ld.intLoadId = @intLoadId

IF Len(@strItemNo) > 2
Begin
	SELECT @strItemNo = Left(@strItemNo, Len(@strItemNo) - 2)
	SELECT @strDescription = Left(@strDescription, Len(@strDescription) - 2)
End


SELECT 'Ship' AS strTransactionName
	,l.intLoadId
	,l.strLoadNumber
	,'' AS strLotAlias
	,0 intItemId
	,@strItemNo as strItemNo
	,@strDescription as strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,@dblShipQuantity AS dblQuantity
	,@strUOM AS strUOM
	,l.dtmScheduledDate AS dtmTransactionDate
	,c.strName
	,'OS' AS strType
FROM tblLGLoad l
LEFT JOIN vyuARCustomer c ON l.intEntityId = c.[intEntityId]
WHERE l.intLoadId = @intLoadId
