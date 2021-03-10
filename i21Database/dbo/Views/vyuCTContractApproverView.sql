CREATE VIEW [dbo].[vyuCTContractApproverView]
AS
SELECT intContractHeaderId
	,strName
	,strUserName
	,strScreenName
	,strContractNumber
FROM (
	SELECT A.intTransactionId AS intContractHeaderId
		,E.strName
		,US.strUserName AS strUserName
		,S.strScreenName
		,B.strTransactionNo AS strContractNumber
		,Rank() OVER (
			PARTITION BY A.intTransactionId ORDER BY intApprovalId DESC
			) intRowId
	FROM tblSMApproval A
	JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
	JOIN tblEMEntity E ON E.intEntityId = A.intApproverId
	JOIN tblSMUserSecurity US ON US.intEntityId = E.intEntityId
	WHERE A.strStatus = 'Approved'
		AND S.strNamespace IN (
			'ContractManagement.view.Contract'
			,'ContractManagement.view.Amendments'
			)
	) AS DT
WHERE DT.intRowId = 1
