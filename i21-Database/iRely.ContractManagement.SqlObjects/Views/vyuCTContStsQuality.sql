CREATE VIEW vyuCTContStsQuality
AS
SELECT S.intSampleId
	,S.intContractDetailId
	,S.strSampleNumber
	,ST.strSampleTypeName
	,dbo.fnCTConvertQuantityToTargetItemUOM(S.intItemId, S.intSampleUOMId, LP.intWeightUOMId, S.dblSampleQty) dblSampleQty
	,SS.strStatus
FROM tblQMSample S
JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
CROSS APPLY tblLGCompanyPreference LP
