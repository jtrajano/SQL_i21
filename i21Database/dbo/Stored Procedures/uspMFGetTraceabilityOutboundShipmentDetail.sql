CREATE PROCEDURE uspMFGetTraceabilityOutboundShipmentDetail @intLoadId INT
AS
DECLARE @dblShipQuantity NUMERIC(38, 20)
DECLARE @strUOM NVARCHAR(50)

SELECT @dblShipQuantity = SUM(ISNULL(dblQuantity, 0))
FROM tblLGLoadDetail 
WHERE intLoadId = @intLoadId

SELECT TOP 1 @strUOM = um.strUnitMeasure
FROM tblICItemUOM iu
JOIN tblLGLoadDetail ld ON iu.intItemUOMId = ld.intItemUOMId
JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId

SELECT 'Ship' AS strTransactionName
	,l.intLoadId
	,l.strLoadNumber
	,'' AS strLotAlias
	,0 intItemId
	,'' strItemNo
	,'' strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,@dblShipQuantity AS dblQuantity
	,@strUOM AS strUOM
	,l.dtmScheduledDate  AS dtmTransactionDate
	,c.strName
	,'S' AS strType
FROM tblLGLoad l
LEFT JOIN vyuARCustomer c ON l.intEntityId = c.[intEntityId]
WHERE l.intLoadId = @intLoadId
