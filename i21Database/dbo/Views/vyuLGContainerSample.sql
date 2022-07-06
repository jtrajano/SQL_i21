CREATE VIEW [dbo].[vyuLGContainerSample]
AS
	SELECT 
		S.intSampleId,
		strContainerNumber, 
		strMarks, 
		strSampleNumber,
		strSampleType = strSampleTypeName,
		strSampleStatus = SS.strStatus, 
		intContractDetailId = CD.intContractDetailId,
		strContractNumber = CH.strContractNumber,
		intContractSeq = CD.intContractSeq,
		S.intConcurrencyId
	FROM tblQMSample S
		INNER JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
		INNER JOIN tblQMSampleType SA ON SA.intSampleTypeId = S.intSampleTypeId
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE S.strContainerNumber <> ''
		AND S.intContractDetailId IS NOT NULL
		AND S.intTypeId = 1
GO
