CREATE VIEW vyuQMSampleListUserRole
AS
SELECT S.*
	,SU.intUserRoleID
FROM vyuQMSampleList S
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
