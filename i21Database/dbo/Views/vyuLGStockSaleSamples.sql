CREATE VIEW vyuLGStockSaleSamples
AS
SELECT L.strLotNumber
	,L.intLotId
	,S.strSampleNumber
	,S.dtmCreated
	,ST.strSampleTypeName
	,CH.strContractNumber + '/' + CONVERT(NVARCHAR,CD.intContractSeq) AS strContractNumber
	,CD.intContractSeq
	,SS.strStatus
	,L.intEntityVendorId
	,E.strName AS strVendor
	,L.strMarkings AS strMarks
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
FROM tblICLot L
JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = L.intLotId
JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId --AND L.intItemId = IRI.intItemId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = IRI.intLineNo
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity E ON E.intEntityId = L.intEntityVendorId
LEFT JOIN tblQMSample S ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
LEFT JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId