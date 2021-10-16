﻿CREATE TYPE QualityInspectionTable AS TABLE
(
	 intRecordId INT IDENTITY(1, 1)
	,intPropertyId INT
	,strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strPropertyValue NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
