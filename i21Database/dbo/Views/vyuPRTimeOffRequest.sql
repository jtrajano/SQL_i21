﻿CREATE VIEW [dbo].[vyuPRTimeOffRequest]
AS
SELECT 
	REQ.intTimeOffRequestId
	,REQ.strRequestId
	,REQ.intEntityEmployeeId
	,ENT.strEntityNo
	,ENT.strName
	,REQ.dtmRequestDate
	,DEP.strDepartment
	,REQ.dtmDateFrom
	,REQ.dtmDateTo
	,TOFF.strTimeOff
	,REQ.dblRequest
	,strApprovalStatus = ISNULL(TRANS.strApprovalStatus, 'No Need for Approval')
	,REQ.ysnPostedToCalendar
	,strCalendarInfo = ENT.strName + ' : ' + CAST(CAST(dblRequest AS FLOAT) AS VARCHAR(20)) 
						+ ' Hour' + CASE WHEN (dblRequest > 0) THEN 's ' ELSE ' ' END + TOFF.strTimeOff
	,REQ.strReason
	,REQ.strAddress
	,REQ.intConcurrencyId
FROM 
	tblPRTimeOffRequest REQ
	LEFT JOIN tblEMEntity ENT ON REQ.intEntityEmployeeId = ENT.intEntityId
	LEFT JOIN tblPRTypeTimeOff TOFF ON REQ.intTypeTimeOffId = TOFF.intTypeTimeOffId
	LEFT JOIN tblPRDepartment DEP ON REQ.intDepartmentId = DEP.intDepartmentId 
	LEFT JOIN 
		(SELECT intRecordId, strApprovalStatus FROM tblSMTransaction TRN
			INNER JOIN tblSMScreen SCR 
			ON TRN.intScreenId = SCR.intScreenId 
			AND SCR.strNamespace = 'Payroll.view.TimeOffRequest') TRANS 
		ON REQ.intTimeOffRequestId = TRANS.intRecordId