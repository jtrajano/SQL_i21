CREATE VIEW [dbo].[vyuTFGetReportingComponentConfiguration]
	AS
	
SELECT intReportingComponentConfigurationId
	, RC.intTaxAuthorityId
	, RC.intReportingComponentId
	, RC.strFormCode
	, RC.strType
	, strTemplateItemId
	, strReportSection
	, intReportItemSequence
	, intTemplateItemNumber
	, strDescription = REPLACE(strDescription, '<value>', ISNULL(strConfiguration, ''))
	, RCC.strScheduleCode
	, strConfiguration
	, ysnConfiguration
	, ysnDynamicConfiguration
	, strLastIndexOf
	, strSegment
	, intConfigurationSequence
FROM tblTFReportingComponentConfiguration RCC
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCC.intReportingComponentId