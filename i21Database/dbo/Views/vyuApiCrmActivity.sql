CREATE VIEW [dbo].[vyuApiCrmActivity]
AS
SELECT
      ac.intActivityId
	, ac.strType
	, ac.strActivityNo
	, ac.dtmCreated
	, a.ysnBillable
	, ac.ysnPrivate
	, ac.strSubject
	, NULL strEventAddress
	, a.dblNumberOfHours
	, ac.dtmStartDate
	, a.dtmStartTime
	, a.dtmEndDate
	, a.dtmEndTime
	, a.ysnAllDayEvent
	, a.ysnRemind
	, a.strReminder
	, ac.strContactName
	, a.strShowTimeAs
	, a.strRelatedTo
	, a.strRecordNo
	, a.strCreatedBy
	, a.strAssignedTo
	, a.strStatus
	, a.strPriority
	, a.strCategory
	, a.strDetails
	, sa.intTransactionId
	, a.intRecordId
	, sa.intAssignedTo intAssignedToId
	, cl.strLocationName strCompanyLocation
	, C.strTimezone
	, C.strEmail
	, C.strPhone
	, C.strMobile
	, cl.strLocationName
	, C.strLocationName strEntityLocation
	, CASE WHEN C.intEntityId IS NULL THEN 0 ELSE 1 END ysnIsContact
	, ac.intEntityId
	, a.dtmDateCreated
	, a.dtmDateLastUpdated
FROM vyuCRMActivitySearch2 ac
JOIN vyuApiActivity a ON a.intActivityId = ac.intActivityId
JOIN tblSMActivity sa ON sa.intActivityId = a.intActivityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = sa.intCompanyLocationId
OUTER APPLY (
	SELECT TOP 1 EntityContact.intEntityId, Contact.strTimezone, Contact.strEmail, Contact.strPhone, Contact.strMobile, EntityLocation.strLocationName
	FROM tblEMEntityToContact EntityContact
	LEFT JOIN tblEMEntity Contact ON EntityContact.intEntityContactId = Contact.intEntityId
	LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = EntityContact.intEntityId
		AND EntityLocation.intEntityLocationId = EntityContact.intEntityLocationId
	LEFT JOIN tblEMEntityType EntityType ON EntityType.intEntityId = EntityContact.intEntityId
	WHERE EntityContact.intEntityId = sa.intEntityId
) C