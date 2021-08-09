CREATE VIEW vyuIPContractDetailERPInfoView
AS
SELECT CD.intContractHeaderId 
		,CD.intContractDetailRefId
		,CD.strERPPONumber
		,CD.strERPItemNumber
FROM tblCTContractDetail CD