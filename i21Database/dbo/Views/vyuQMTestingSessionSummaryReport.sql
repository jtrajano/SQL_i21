CREATE VIEW vyuQMTestingSessionSummaryReport
AS
SELECT 
	 strPropertyName
	,strPropertyValue
	,strResult
FROM tblQMTestResult QMTR
JOIN tblQMProperty QMP ON QMP.intPropertyId = QMTR.intPropertyId
