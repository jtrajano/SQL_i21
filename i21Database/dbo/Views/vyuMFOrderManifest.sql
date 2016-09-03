CREATE VIEW vyuMFOrderManifest
AS 
SELECT OH.intOrderHeaderId
	,M.intOrderManifestId
	,M.intConcurrencyId
	,L.intLotId
	,L.strLotNumber
	,L.strLotAlias
	,L.dblQty
	,I.strItemNo
	,I.strDescription
	,UM.strUnitMeasure
	,LS.strSecondaryStatus AS strLotStatus
FROM tblMFOrderHeader OH 
JOIN tblMFOrderManifest M ON OH.intOrderHeaderId = M.intOrderHeaderId
JOIN tblICLot L ON L.intLotId = M.intLotId
JOIN tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
JOIN tblICItem I ON I.intItemId = L.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId