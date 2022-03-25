CREATE VIEW [dbo].[vyuApiActivityAttendee]
AS
SELECT
	  a.intActivityAttendeeId
	, a.intActivityId
	, ve.intEntityId
	, ve.strName
	, ve.strEmail
	, ve.strPhone
	, ve.strMobile
	, a.ysnAddCalendarEvent
	, ve.ysnDefaultContact
FROM tblSMActivityAttendee a
JOIN vyuEMEntityCredentialContact ve ON ve.intEntityId = a.intEntityId
JOIN tblEMEntity e ON e.intEntityId = a.intEntityId
JOIN tblSMActivity ac ON ac.intActivityId = a.intActivityId
WHERE ac.strType != 'Comment' 
	AND (([ve].[ysnDisabled] = CAST(0 AS bit)) AND ([ve].[User] = 1)) AND ([ve].[strName] IS NOT NULL AND NOT ([ve].[strName] LIKE N''))