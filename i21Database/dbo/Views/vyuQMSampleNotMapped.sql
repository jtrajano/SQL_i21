CREATE VIEW vyuQMSampleNotMapped
AS
SELECT S.intSampleId
	,ST.intControlPointId
	,I.strDescription
	,IR.strReceiptNumber
	,CH.intContractTypeId
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
