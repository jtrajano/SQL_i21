CREATE VIEW [dbo].[vyuICGetWarrantLotAuditLog]
AS

SELECT 
	A.intAuditId
	,dtmDateUTC = B.dtmDate
	,E.strAction
	,A.strChange
	,A.strFrom
	,A.strTo
	,F.strLotNumber
FROM tblSMAudit A
INNER JOIN tblSMLog B
	ON A.intLogId = B.intLogId
INNER JOIN tblSMTransaction C
	ON B.intTransactionId = C.intTransactionId
INNER JOIN tblSMScreen D
	ON C.intScreenId = D.intScreenId
INNER JOIN tblSMAudit E
	ON A.intParentAuditId = E.intAuditId
INNER JOIN tblICLot F
	ON C.intRecordId = F.intLotId
WHERE B.strType = 'Audit'
	AND D.strNamespace = 'Inventory.view.Warrant'
	AND D.strModule = 'Inventory'
	AND A.intParentAuditId IS NOT NULL





