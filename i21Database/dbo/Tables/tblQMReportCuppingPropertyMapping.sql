﻿CREATE TABLE dbo.tblQMReportCuppingPropertyMapping (
	intReportCuppingPropertyMappingId INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_tblQMReportCuppingPropertyMapping_intReportCuppingPropertyMapping PRIMARY KEY,
	strPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	,strActualPropertyName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
	)
