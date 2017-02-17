CREATE VIEW [dbo].[vyuTFGetReportingComponentDestinationState]
AS

SELECT RCDS.intReportingComponentDestinationStateId
	, RCDS.intReportingComponentId
	, RC.strFormCode
	, RC.strScheduleCode
	, strItemType = RC.strType
	, RCDS.intOriginDestinationStateId
	, strOriginDestinationState = ODS.strOriginDestinationState
	, RCDS.strType
FROM tblTFReportingComponentDestinationState RCDS
LEFT JOIN tblTFOriginDestinationState ODS ON ODS.intOriginDestinationStateId = RCDS.intOriginDestinationStateId
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCDS.intReportingComponentId