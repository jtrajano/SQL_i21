CREATE VIEW vyuMFOrderManifest
AS 
SELECT OH.intOrderHeaderId
	,M.intOrderManifestId
	,M.intConcurrencyId
	,L.intLotId
	,L.strLotNumber
	,PL.strParentLotNumber
	,L.strLotAlias
	,L.dblQty
	,I.strItemNo
	,I.strDescription
	,UM.strUnitMeasure
	,LS.strSecondaryStatus AS strLotStatus
	,ISNULL(T.dblQty, 0) AS dblTaskQty
	,ISNULL(T.dblPickQty, 0) AS dblPickQty
	,I.intCategoryId
	,I.intItemId
FROM tblMFOrderHeader OH 
JOIN tblMFOrderManifest M ON OH.intOrderHeaderId = M.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = M.intLotId
JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN tblICItem I ON I.intItemId = L.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblMFTask T ON T.intOrderHeaderId = OH.intOrderHeaderId
	AND T.intLotId = M.intLotId
