CREATE PROCEDURE [dbo].[uspMFGetTraceabilityContainerDetail] @intContainerId INT
	,@intDirectionId INT
AS
SET NOCOUNT ON;

SELECT DISTINCT 'Container' AS strTransactionName
	,s.intLoadContainerId
	,s.strContainerNumber
	,'' AS strLotAlias
	,i.intItemId
	,i.strItemNo
	,i.strDescription
	,0 intCategoryId
	,'' strCategoryCode
	,s.dblQuantity
	,um.strUnitMeasure strUOM
	,NULL AS dtmTransactionDate
	,s.intLoadId AS intParentLotId
	,'' strVendor
	,'CN' AS strType
FROM tblLGLoadContainer s
JOIN tblLGLoadDetailContainerLink l on l.intLoadContainerId=s.intLoadContainerId
JOIN tblLGLoadDetail ld on ld.intLoadDetailId =l.intLoadDetailId
JOIN tblICItem i on i.intItemId=ld.intItemId  
JOIN tblICItemUOM iu on iu.intItemUOMId =ld.intItemUOMId
JOIN tblICUnitMeasure um on um.intUnitMeasureId =iu.intUnitMeasureId 
WHERE s.intLoadContainerId = @intContainerId
