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
		B.strTransactionNo, CAST(B.strRecordNo AS INT) intTransactionId
	FROM tblSMTransaction B
	WHERE A.intScreenId = B.intScreenId
	AND (B.strApprovalStatus IS NOT NULL AND B.strApprovalStatus NOT IN ('No Need for Approval','Approved'))
) APTransaction
WHERE A.strScreenName IN ('Purchase Order','Voucher')

