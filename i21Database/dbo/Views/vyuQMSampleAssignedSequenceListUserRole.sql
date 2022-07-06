CREATE VIEW vyuQMSampleAssignedSequenceListUserRole
AS
SELECT S.*
	,SU.intUserRoleID
FROM vyuQMSampleAssignedSequenceList S
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
