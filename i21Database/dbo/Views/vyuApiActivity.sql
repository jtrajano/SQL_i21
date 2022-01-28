CREATE VIEW [dbo].[vyuApiActivity]
AS

SELECT
	  a.strType
    , a.intActivityId
	, a.dtmCreated
	, a.strSubject
	, a.dtmStartDate
	, a.dblNumberOfHours
	, a.intCreatedBy
	, a.strStatus
	, e.strName strCreatedBy
	, ea.strName strAssignedTo
	, a.strPriority
    , t.intRecordId
    , s.strNamespace
FROM tblSMActivity a
LEFT JOIN tblEMEntity e ON e.intEntityId = a.intCreatedBy
LEFT JOIN tblEMEntity ea ON ea.intEntityId = a.intAssignedTo
LEFT JOIN tblSMTransaction t ON t.intTransactionId = a.intTransactionId
LEFT JOIN tblSMScreen s ON s.intScreenId = t.intScreenId