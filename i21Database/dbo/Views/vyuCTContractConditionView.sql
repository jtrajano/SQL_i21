CREATE VIEW vyuCTContractConditionView
AS
SELECT CC.intContractHeaderId
	,C.strConditionName
	,CC.strConditionDescription AS strConditionDesc
FROM tblCTContractCondition CC
JOIN tblCTCondition C ON CC.intConditionId = C.intConditionId
