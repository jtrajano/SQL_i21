CREATE VIEW vyuQMLotQuality
AS
SELECT intProductValueId
	,intSampleId
	,Moisture
	,Density
	,Color
FROM (
	SELECT P.strPropertyName
		,TR.intProductTypeId
		,TR.intProductValueId
		,TR.intSampleId
		,TR.strPropertyValue
	FROM dbo.tblQMTestResult TR
	JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		AND P.strPropertyName IN (
			'Moisture'
			,'Density'
			,'Color'
			)
	WHERE TR.intProductTypeId = 6
		AND TR.intSampleId = (
			SELECT MAX(intSampleId)
			FROM dbo.tblQMTestResult
			WHERE intProductValueId = TR.intProductValueId
				AND intProductTypeId = 6
			)
	GROUP BY P.strPropertyName
		,TR.intProductTypeId
		,TR.intProductValueId
		,TR.intSampleId
		,TR.strPropertyValue
	) SrcQry
PIVOT(MIN(strPropertyValue) FOR [strPropertyName] IN (
			Moisture
			,Density
			,Color
			)) Pvt
