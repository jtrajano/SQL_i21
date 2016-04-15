CREATE VIEW dbo.vyuQMCuppingTestResult
	--WITH SCHEMABINDING
AS
SELECT intSampleId
	,intPropertyId
	,MAX(strPropertyValue) strPropertyValue
FROM dbo.tblQMTestResult
GROUP BY intSampleId
	,intPropertyId
