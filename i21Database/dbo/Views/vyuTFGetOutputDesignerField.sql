﻿CREATE VIEW [dbo].[vyuTFGetOutputDesignerField]
	AS

SELECT intOutputDesignerFieldId
	, strColumnName
	, strColumnType
	, intReportingComponentId = NULL
	, ysnFromConfiguration = CAST(0 AS BIT)
	, strConfigurationValue = NULL
FROM tblTFOutputDesignerField

UNION ALL

SELECT ROW_NUMBER() OVER(ORDER BY intReportingComponentConfigurationId DESC) AS intOutputDesignerFieldId
	, strDescription
	, NULL
	, intReportingComponentId
	, ysnFromConfiguration = CAST(1 AS BIT)
	, strConfigurationValue = strConfiguration
FROM tblTFReportingComponentConfiguration
WHERE ysnOutputDesigner = 1