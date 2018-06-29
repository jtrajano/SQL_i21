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
		,intEntityApproverId = Approver.intApproverId
	FROM dbo.tblAPBill A
		INNER JOIN (dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity C ON B.[intEntityId] = C.intEntityId)
		ON A.intEntityVendorId = B.[intEntityId]
		OUTER APPLY (
			SELECT intApproverId FROM [dbo].[fnAPGetNextVoucherApprover](A.intBillId)
		) Approver
		WHERE A.ysnForApproval = 1 AND B.intApprovalListId IS NOT NULL AND A.dtmApprovalDate IS NULL
) tblBillApproval
