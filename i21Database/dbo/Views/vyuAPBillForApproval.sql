CREATE VIEW vyuAPBillForApproval
AS

SELECT
	A.*
FROM tblAPBill A
CROSS APPLY
(
	SELECT
		B.intEntityId
	FROM tblEntityCredential B
		INNER JOIN tblEntityToContact C
			ON B.intEntityId = C.intEntityContactId
	WHERE A.intEntityId = B.intEntityId
) Contact
WHERE A.intTransactionType = 7