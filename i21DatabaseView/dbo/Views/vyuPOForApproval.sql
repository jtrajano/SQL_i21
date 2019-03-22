CREATE VIEW [dbo].[vyuPOForApproval]
AS
SELECT
ROW_NUMBER() OVER(ORDER BY intPurchaseId, intEntityApproverId) AS intId
,intPurchaseId
,strPurchaseOrderNumber
,dblTotal
,dtmDate
,ysnApproved
,strApprovalNotes
,strVendorId
,strName
,intEntityApproverId
FROM (
	SELECT
		A.intPurchaseId
		,A.strPurchaseOrderNumber
		,A.dblTotal
		,A.dtmDate
		,A.ysnApproved
		,A.strApprovalNotes
		,CASE WHEN ISNULL(B.strVendorId,'') = '' THEN C.strEntityNo ELSE B.strVendorId END AS strVendorId
		,C.strName
		,intEntityApproverId = Approver.intApproverId
	FROM dbo.tblPOPurchase A
		INNER JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON A.intEntityVendorId = B.[intEntityId]
		OUTER APPLY (
			SELECT intApproverId FROM [dbo].[fnPOGetNextApprover](A.intPurchaseId)
		) Approver
		WHERE A.ysnForApproval = 1 AND B.intApprovalListId IS NOT NULL AND A.dtmApprovalDate IS NULL
) tblPOApproval
