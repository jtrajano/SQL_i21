CREATE VIEW vyuQMSampleTypeControlPointUserRole
AS
SELECT S.*
	,SU.intUserRoleID
FROM vyuQMSampleTypeControlPoint S
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
