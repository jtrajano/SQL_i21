CREATE VIEW vyuQMQualityExceptionListUserRole
AS
SELECT S.*
	,SU.intUserRoleID
FROM vyuQMQualityExceptionList S
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
