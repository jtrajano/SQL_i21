CREATE VIEW vyuLGGetContractSubLocation
AS
SELECT CD.intContractDetailId
	,CD.intContractHeaderId
	,CD.intSubLocationId
	,CD.intStorageLocationId
	,SL.strName AS strStorageLocationName
	,CLSL.strSubLocationName
FROM tblCTContractDetail CD
JOIN tblICStorageLocation SL ON CD.intStorageLocationId = SL.intStorageLocationId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId