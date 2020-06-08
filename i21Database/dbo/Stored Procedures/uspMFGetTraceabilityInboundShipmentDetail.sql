CREATE PROCEDURE [dbo].[uspMFGetTraceabilityInboundShipmentDetail] @intShipmentId INT
	,@intDirectionId INT
	,@intLocationId int=NULL
AS
SET NOCOUNT ON;

SELECT DISTINCT 'In Shipment' AS strTransactionName
	,l.intLoadId
	,l.strLoadNumber
	,'' AS strLotAlias
	,0 intItemId
	,'' strItemNo
	,'' strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,ld.dblQuantity
	,um.strUnitMeasure strUOM
	,NULL AS dtmTransactionDate
	,'' strVendor
	,'IS' AS strType
FROM tblLGLoad l 
JOIN tblLGLoadDetail ld on ld.intLoadId =l.intLoadId
JOIN tblICItemUOM iu on iu.intItemUOMId =ld.intItemUOMId
JOIN tblICUnitMeasure um on um.intUnitMeasureId =iu.intUnitMeasureId 
WHERE IsNULL(ld.intPCompanyLocationId,@intLocationId)=@intLocationId and l.intLoadId = @intShipmentId
	AND l.intShipmentType = 1
