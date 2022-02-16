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
	, e.strEmail
	, e.strPhone
	, e.strMobile
	, a.strDetails
	, a.strCategory
	, a.dtmEndDate
	, a.dtmStartTime
	, a.dtmEndTime
	, a.ysnAllDayEvent
	, a.ysnRemind
	, a.strReminder
	, e.strTimezone
	, a.strShowTimeAs
	, a.strRelatedTo
	, a.strRecordNo
	, a.ysnBillable
	, created.dtmDate dtmDateCreated
	, COALESCE(updated.dtmDate, created.dtmDate, a.dtmCreated) dtmDateLastUpdated
FROM tblSMActivity a
LEFT JOIN tblEMEntity e ON e.intEntityId = a.intCreatedBy
LEFT JOIN tblEMEntity ea ON ea.intEntityId = a.intAssignedTo
LEFT JOIN tblSMTransaction t ON t.intTransactionId = a.intTransactionId
LEFT JOIN tblSMScreen s ON s.intScreenId = t.intScreenId
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = a.intActivityId
		AND au.strAction = 'Created'
		AND au.strNamespace = 'GlobalComponentEngine.view.Activity'
) created
OUTER APPLY (
	SELECT TOP 1 au.dtmDate
	FROM vyuApiRecordAudit au
	WHERE au.intRecordId = a.intActivityId
		AND au.strAction = 'Updated'
		AND au.strNamespace = 'GlobalComponentEngine.view.Activity'
) updated