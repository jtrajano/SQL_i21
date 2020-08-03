CREATE VIEW [dbo].[vyuTFGetReportingComponentConfiguration]
	AS
	
SELECT intReportingComponentConfigurationId
	, RC.intTaxAuthorityId
	, RC.intReportingComponentId
	, RC.strFormCode
	, RC.strScheduleCode strReportingScheduleCode
	, RC.strType
	, strTemplateItemId
	, strReportSection
	, intReportItemSequence
	, intTemplateItemNumber
	, strDescription = REPLACE(strDescription, '<value>', ISNULL(strConfiguration, ''))
	, RCC.strScheduleCode
	, strConfiguration
	, ysnConfiguration = (CASE WHEN ysnOutputDesigner = 1 THEN CAST(1 AS BIT) ELSE RCC.ysnConfiguration END)
	, ysnUserDefinedValue
	, strLastIndexOf
	, strSegment
	, intConfigurationSequence
	, strInputType
FROM tblTFReportingComponentConfiguration RCC
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId