﻿CREATE VIEW [dbo].[vyuTFReportingComponentProductCode]
	AS

SELECT 
	RCPC.intReportingComponentProductCodeId,
	RCPC.intProductCodeId, 
	PC.strProductCode, 
	RC.intReportingComponentId, 
	RC.strFormCode, 
	RC.strScheduleCode,
	RC.intTaxAuthorityId FROM tblTFReportingComponentProductCode RCPC
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = RCPC.intProductCodeId
LEFT JOIN tblTFReportingComponent RC ON RC.intReportingComponentId = RCPC.intReportingComponentId
