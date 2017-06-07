CREATE VIEW [dbo].[vyuAPPurchase]
WITH SCHEMABINDING
AS 
SELECT 
A.intPurchaseId
,A.dtmDate
,A.[intEntityVendorId]
,A.intOrderStatusId
,A.strVendorOrderNumber
,A.strPurchaseOrderNumber
,B.strVendorId 
,B1.strName
,C.strStatus
,D.strLocationName,
--,strApprovalStatus = CASE WHEN (A.ysnForApproval = 1 OR A.dtmApprovalDate IS NOT NULL) AND A.ysnForApprovalSubmitted = 1
--						THEN (
--							CASE WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 1 THEN 'Approved'
--								WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 0 THEN 'Rejected'
--								ELSE 'Awaiting approval' END
--						)
--						WHEN A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
--							THEN 'Ready for submit'
--						ELSE NULL END
--,CASE WHEN A.ysnForApproval = 1 THEN G.strApprovalList ELSE NULL END AS strApprover
Approvals.strApprovalStatus,
Approvals.strName as strApprover
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.[intEntityVendorId] = B.[intEntityId]
	INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId
	INNER JOIN dbo.tblPOOrderStatus C ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN dbo.tblSMCompanyLocation D ON A.intShipToId = D.intCompanyLocationId
	--LEFT JOIN dbo.tblSMApprovalList G ON G.intApprovalListId = ISNULL(B.intApprovalListId , (SELECT intApprovalListId FROM dbo.tblAPCompanyPreference))
	OUTER APPLY (
		SELECT TOP 1
			I.strApprovalStatus
			,K.strName
			,CASE WHEN I.strApprovalStatus = 'Approved' THEN J.dtmDate ELSE NULL END AS dtmApprovalDate
		FROM dbo.tblSMScreen H
		INNER JOIN dbo.tblSMTransaction I ON H.intScreenId = I.intScreenId
		INNER JOIN dbo.tblSMApproval J ON I.intTransactionId = J.intTransactionId
		INNER JOIN dbo.tblEMEntity K ON J.intApproverId = K.intEntityId
		WHERE H.strScreenName = 'Purchase Order' AND H.strModule = 'Accounts Payable' AND J.ysnCurrent = 1
		AND A.intPurchaseId = I.intRecordId
	) Approvals
	
