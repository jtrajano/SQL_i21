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
FROM tblSMActivityAttendee a
JOIN vyuEMEntityCredentialContact ve ON ve.intEntityId = a.intEntityId
JOIN tblEMEntity e ON e.intEntityId = a.intEntityId
JOIN tblSMActivity ac ON ac.intActivityId = a.intActivityId
WHERE ac.strType != 'Comment'