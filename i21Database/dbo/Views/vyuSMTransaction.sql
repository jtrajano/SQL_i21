CREATE VIEW vyuSMTransaction
AS
SELECT 
	A.intRowId,
	A.strRecordNo, 
	C.intTransactionId,
	intEntityId
FROM vyuSMTransactionRaw A LEFT OUTER JOIN tblSMTransaction C ON A.intId = CAST(C.strRecordNo AS INT) AND C.intScreenId = A.intScreenId
 