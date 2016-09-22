CREATE TYPE QualityInspectionTable AS TABLE
(
	 intRecordId INT IDENTITY(1, 1)
	,intPropertyId INT
	,strPropertyName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strPropertyValue NVARCHAR(10) COLLATE Latin1_General_CI_AS
)
