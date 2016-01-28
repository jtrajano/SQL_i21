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
,D.strLocationName
,strApprovalStatus = CASE WHEN (A.ysnForApproval = 1 OR A.dtmApprovalDate IS NOT NULL) AND A.ysnForApprovalSubmitted = 1
						THEN (
							CASE WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 1 THEN 'Approved'
								WHEN A.dtmApprovalDate IS NOT NULL AND A.ysnApproved = 0 THEN 'Rejected'
								ELSE 'Awaiting approval' END
						)
						WHEN A.ysnForApproval = 1 AND A.ysnForApprovalSubmitted = 0
							THEN 'Ready for submit'
						ELSE NULL END
,CASE WHEN A.ysnForApproval = 1 THEN G.strApprovalList ELSE NULL END AS strApprover
FROM dbo.tblPOPurchase A
	INNER JOIN dbo.tblAPVendor B ON A.[intEntityVendorId] = B.[intEntityVendorId]
	INNER JOIN dbo.tblEntity B1 ON B.intEntityVendorId = B1.intEntityId
	INNER JOIN dbo.tblPOOrderStatus C ON A.intOrderStatusId = C.intOrderStatusId
	INNER JOIN dbo.tblSMCompanyLocation D ON A.intShipToId = D.intCompanyLocationId
	LEFT JOIN dbo.tblSMApprovalList G ON G.intApprovalListId = ISNULL(B.intApprovalListId , (SELECT intApprovalListId FROM dbo.tblAPCompanyPreference))
	
