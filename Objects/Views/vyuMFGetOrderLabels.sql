CREATE VIEW vyuMFGetOrderLabels
AS
SELECT OML.intOrderManifestLabelId
	,OM.intOrderManifestId
	,L.strLotNumber
	,PL.strParentLotNumber
	,I.strItemNo
	,I.strDescription
	,LT.strLabelType
	,OML.intCustomerLabelTypeId
	,OML.strSSCCNo
	,OML.strBarcodeLabel1
	,OML.strBarcodeLabel2
	,OML.strBarcodeLabel3
	,OH.intOrderHeaderId
FROM tblMFOrderHeader OH
JOIN tblMFOrderManifest OM ON OM.intOrderHeaderId = OH.intOrderHeaderId
JOIN tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId
	AND OML.ysnDeleted <> 1
JOIN tblICLot L ON L.intLotId = OM.intLotId
JOIN tblICItem I ON I.intItemId = L.intItemId
JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN tblMFCustomerLabelType LT ON LT.intCustomerLabelTypeId = OML.intCustomerLabelTypeId
