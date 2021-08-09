CREATE VIEW vyuQMSampleContractSequenceNotMapped
AS
SELECT SCS.intSampleContractSequenceId
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber
	,UOM.strUnitMeasure
FROM tblQMSampleContractSequence SCS
JOIN tblCTContractDetail CD ON CD.intContractDetailId = SCS.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SCS.intUnitMeasureId
