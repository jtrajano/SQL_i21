CREATE VIEW vyuCTContractConditionView
AS
SELECT CC.intContractHeaderId
	,C.strConditionName
FROM tblCTContractCondition CC
JOIN tblCTCondition C ON CC.intConditionId = C.intConditionId
