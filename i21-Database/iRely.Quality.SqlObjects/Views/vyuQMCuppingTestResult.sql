CREATE VIEW vyuQMCuppingTestResult
AS
SELECT TR.intSampleId
	,TR.intPropertyId
	,MAX(TR.strPropertyValue) strPropertyValue
FROM tblQMTestResult TR
JOIN tblQMReportCuppingPropertyMapping AS Property_cup_map ON UPPER(Property_cup_map.strPropertyName) IN (
		'OVERALL CUP ANALYSIS'
		,'HUMIDITY'
		,'Bulk Density'
		)
JOIN tblQMProperty AS Property_cup ON UPPER(Property_cup.strPropertyName) = UPPER(Property_cup_map.strActualPropertyName)
	AND Property_cup.intPropertyId = TR.intPropertyId
GROUP BY TR.intSampleId
	,TR.intPropertyId
