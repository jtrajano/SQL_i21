CREATE VIEW [dbo].[vyuTFGetReportingComponentConfiguration]
	AS
	
SELECT intReportingComponentConfigurationId
	, intReportingComponentId
	, strTemplateItemId
	, strReportSection
	, intReportItemSequence
	, intTemplateItemNumber
	, strDescription = REPLACE(strDescription, '<value>', strConfiguration)
	, strScheduleCode
	, strConfiguration
	, ysnConfiguration
	, ysnDynamicConfiguration
	, strLastIndexOf
	, strSegment
	, intConfigurationSequence
FROM tblTFReportingComponentConfiguration