CREATE VIEW vyuQMCuppingFormResultReport
AS
SELECT 
	 strPropertyName
	,strPropertyValue
	,strResult
FROM tblQMTestResult QMTR
INNER JOIN tblQMProperty QMP ON QMP.intPropertyId = QMTR.intPropertyId AND QMP.ysnPrintInCuppingForm = 1
