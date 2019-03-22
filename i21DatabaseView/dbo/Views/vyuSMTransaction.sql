CREATE VIEW vyuSMTransaction
AS
SELECT 
	A.intRowId,
	A.strRecordNo, 
	C.intTransactionId,
	A.intEntityId
FROM vyuSMTransactionRaw A LEFT OUTER JOIN tblSMTransaction C ON A.intId = C.intRecordId AND C.intScreenId = A.intScreenId
 