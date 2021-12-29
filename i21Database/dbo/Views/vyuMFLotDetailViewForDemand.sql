CREATE VIEW vyuMFLotDetailViewForDemand
AS
SELECT L.intLotId
	,L.intItemId
	,L.intLocationId
	,L.strLotNumber
	,PL.strParentLotNumber
	,I.strItemNo
	,CASE 
		WHEN L.intWeightUOMId IS NULL
			THEN L.dblQty
		ELSE L.dblWeight
		END AS dblQty
	,UOM.strUnitMeasure
	,CL.strLocationName
	,CLSL.strSubLocationName
	,SL.strName AS strStorageLocationName
	,L.dtmDateCreated
FROM dbo.tblICLot L
JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
	AND L.dblQty <> 0
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = ISNULL(L.intWeightUOMId, L.intItemUOMId)
JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = L.intSubLocationId
LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
