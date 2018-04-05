CREATE VIEW dbo.vyuMFGetPalletSSCCNo
	WITH schemabinding
AS
SELECT OH.strReferenceNo
	,L.strLotNumber
	,OML.strSSCCNo
FROM dbo.tblMFOrderHeader OH
JOIN dbo.tblMFOrderManifest OM ON OM.intOrderHeaderId = OH.intOrderHeaderId
JOIN dbo.tblICLot L ON L.intLotId = OM.intLotId
JOIN dbo.tblMFOrderManifestLabel OML ON OML.intOrderManifestId = OM.intOrderManifestId and OML.ysnDeleted =0

