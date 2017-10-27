CREATE FUNCTION [dbo].[fnAPGetVoucherApprovalStatus]
(
	@voucherId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 
	TOP 1
	I.strApprovalStatus
	,K.strName
	,CASE WHEN I.strApprovalStatus = 'Approved' THEN J.dtmDate ELSE NULL END AS dtmApprovalDate
FROM dbo.tblSMScreen H
INNER JOIN dbo.tblSMTransaction I ON H.intScreenId = I.intScreenId
INNER JOIN dbo.tblSMApproval J ON I.intTransactionId = J.intTransactionId
LEFT JOIN dbo.tblEMEntity K ON J.intApproverId = K.intEntityId
WHERE H.strScreenName = 'Voucher' AND H.strModule = 'Accounts Payable' AND J.ysnCurrent = 1
AND I.intRecordId = @voucherId