CREATE VIEW vyuCRMActivityAttendee
AS
SELECT AA.intActivityAttendeeId, 
	AA.intActivityId, 
	ECC.intEntityId, 
	ECC.strName, 
	ECC.strEmail
FROM tblSMActivityAttendee AS AA LEFT JOIN
    vyuEMEntityCredentialContact AS ECC ON ECC.intEntityId = AA.intEntityId