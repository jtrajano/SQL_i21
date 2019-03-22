CREATE VIEW vyuQMSampleTypeCategoryControlPointUserRole
AS
SELECT S.*
	,SU.intUserRoleID
FROM vyuQMSampleTypeCategoryControlPoint S
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
