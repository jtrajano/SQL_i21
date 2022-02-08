CREATE VIEW [dbo].[vyuApiCrmActivity]
AS
SELECT
      ac.intActivityId
	, ac.strType
	, ac.strActivityNo
	, cl.strLocationName
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
	, Contact.strTimezone
	, ac.strContactName
	, Contact.strEmail
	, Contact.strPhone
	, Contact.strMobile
	, EntityLocation.strLocationName strEntityLocation
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
	, cl.strLocationName strCompanyLocation
FROM vyuCRMActivitySearch2 ac
JOIN vyuApiActivity a ON a.intActivityId = ac.intActivityId
JOIN tblSMActivity sa ON sa.intActivityId = a.intActivityId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = sa.intCompanyLocationId
LEFT JOIN tblEMEntityToContact EntityContact ON EntityContact.intEntityId = sa.intEntityId
LEFT JOIN tblEMEntity Contact ON EntityContact.intEntityContactId = Contact.intEntityId
LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityId = EntityContact.intEntityId
	AND EntityLocation.intEntityLocationId = EntityContact.intEntityLocationId
LEFT JOIN tblEMEntityType EntityType ON EntityType.intEntityId = EntityContact.intEntityId
WHERE EntityContact.ysnDefaultContact = 1