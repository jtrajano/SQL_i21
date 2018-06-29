CREATE VIEW [dbo].[vyuTFGetReportingComponentOriginState]
	AS 

SELECT RCOS.intReportingComponentOriginStateId
	, RCOS.intReportingComponentId
	, RC.strFormCode
	, RC.strScheduleCode
	, strItemType = RC.strType
	, RCOS.intOriginDestinationStateId
	, strOriginDestinationState = ODS.strOriginDestinationState
	, RCOS.strType
FROM tblTFReportingComponentOriginState RCOS
LEFT JOIN tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId = RCOS.intOriginDestinationStateId
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCOS.intReportingComponentId