CREATE VIEW vyuQMGetSampleType
AS
SELECT ST.intSampleTypeId AS SampleTypeId
	,ST.strSampleTypeName AS SampleType
FROM dbo.tblQMSampleType ST
WHERE ST.intSampleTypeId NOT IN (
		SELECT intSampleTypeId
		FROM dbo.tblIPSampleType
		)
