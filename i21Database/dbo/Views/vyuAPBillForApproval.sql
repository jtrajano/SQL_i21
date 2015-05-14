CREATE VIEW [dbo].[vyuAPBillForApproval]
WITH SCHEMABINDING
AS
SELECT
ROW_NUMBER() OVER(ORDER BY intBillId, intEntityApproverId) AS intId
,intBillId
,strBillId
,strVendorOrderNumber
,dblTotal
,dtmDate
,dtmDueDate
,ysnApproved
,strApprovalNotes
,strVendorId
,strName
,intEntityApproverId
FROM (
	SELECT
		A.intBillId
		,A.strBillId
		,A.strVendorOrderNumber
		,A.dblTotal
		,A.dtmDate
		,A.dtmDueDate
		,A.ysnApproved
		,A.strApprovalNotes
		,CASE WHEN ISNULL(B.strVendorId,'') = '' THEN C.strEntityNo ELSE B.strVendorId END AS strVendorId
		,C.strName
		,intEntityApproverId = Approver.intEntityId
	FROM dbo.tblAPBill A
		INNER JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEntity C ON B.intEntityVendorId = C.intEntityId)
		ON A.intEntityVendorId = B.intEntityVendorId
		OUTER APPLY
		(
			SELECT
				F.intEntityId
			FROM dbo.tblSMApprovalList D
			INNER JOIN dbo.tblSMApprovalListUserSecurity E ON D.intApprovalListId = E.intApprovalListId
			LEFT JOIN dbo.tblSMUserSecurity F ON E.intUserSecurityId = F.intUserSecurityID
			WHERE D.intApprovalListId = B.intApprovalListId
		) Approver
		WHERE A.intTransactionType = 7 AND B.intApprovalListId IS NOT NULL AND A.dtmApprovalDate IS NULL
) tblBillApproval
