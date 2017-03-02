CREATE VIEW vyuQMSampleStaticPropertiesResult
AS
SELECT TR.intTestResultId
	,TR.intSampleId
	,S.strSampleNumber
	,P.strPropertyName
	,TR.strPropertyValue
	,TR.strResult
	,TR.dtmLastModified
FROM tblQMTestResult TR
JOIN tblQMSample S ON S.intSampleId = TR.intSampleId
	AND TR.strResult = 'Failed'
JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	AND (P.strPropertyName IN (
		'Are the weights below the MAV?'
		,'Is there any positive results?'
		) OR P.ysnNotify =1)
	AND TR.dtmLastModified > (GETDATE() - 1)
