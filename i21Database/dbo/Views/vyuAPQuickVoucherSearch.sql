CREATE VIEW [dbo].[vyuAPQuickVoucherSearch]
AS
SELECT
	A.strBillId,
	A.intBillId,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblTotal,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblAmountDue,
	CASE WHEN (A.intTransactionType IN (3,8)) OR (A.intTransactionType = 2 AND A.ysnPosted = 1) THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblPayment,
	A.dtmDate,
	A.dtmBillDate,
	A.dtmDueDate,
	A.strVendorOrderNumber,
	A.intTransactionType,
	A.intEntityVendorId,
	A.dblWithheld,
	A.strReference,
	A.strComment,
	CASE WHEN A.dtmDateCreated IS NULL THEN A.dtmDate ELSE A.dtmDateCreated END AS dtmDateCreated,
	A.dblTax,
	B1.strName,
	F.strUserName AS strUserId,
	G.strLocationName AS strUserLocation,
	A.ysnPosted
FROM
	dbo.tblAPBill A
	INNER JOIN 
		(dbo.tblAPVendor B INNER JOIN dbo.tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId)
		ON A.[intEntityVendorId] = B.[intEntityId]
	LEFT JOIN dbo.[tblEMEntityCredential] F ON A.intEntityId = F.intEntityId
	LEFT JOIN dbo.tblSMCompanyLocation G
		ON A.intStoreLocationId = G.intCompanyLocationId
