CREATE VIEW [dbo].[vyuAPForApprovalTransaction]
AS

SELECT
	A.intScreenId
	,A.strScreenName
	,APTransaction.intTransactionId
	,APTransaction.strTransactionNo
FROM tblSMScreen A
CROSS APPLY (
	SELECT
		B.strTransactionNo, B.intRecordId intTransactionId, B.intEntityId
	FROM tblSMTransaction B
	WHERE A.intScreenId = B.intScreenId
	AND (B.strApprovalStatus IS NOT NULL AND B.strApprovalStatus NOT IN ('No Need for Approval','Approved'))
) APTransaction
WHERE A.strScreenName IN ('Purchase Order','Voucher')
AND EXISTS (
	--MAKE SURE THERE STILL HAS APPROVAL SETUP
	SELECT TOP 1 1 FROM tblEMEntityRequireApprovalFor em WHERE em.intScreenId = A.intScreenId AND em.intEntityId = APTransaction.intEntityId
	UNION ALL
	SELECT TOP 1 1 FROM tblSMCompanyLocationRequireApprovalFor sm WHERE sm.intScreenId = A.intScreenId
	UNION ALL
	SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor usr WHERE usr.intScreenId = A.intScreenId AND usr.intEntityUserSecurityId = APTransaction.intEntityId
)

