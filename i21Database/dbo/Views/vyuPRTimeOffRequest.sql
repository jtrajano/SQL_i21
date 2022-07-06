CREATE VIEW [dbo].[vyuPRTimeOffRequest]  
AS  
SELECT   
 REQ.intTimeOffRequestId  
 ,REQ.strRequestId  
 ,REQ.intEntityEmployeeId  
 ,ENT.strEntityNo  
 ,ENT.strName  
 ,EMP.strFirstName  
 ,EMP.strLastName  
 ,EMP.strMiddleName  
 ,REQ.dtmRequestDate  
 ,DEP.strDepartment  
 ,strRankDescription = EMPRank.strDescription  
 ,REQ.dtmDateFrom  
 ,REQ.dtmDateTo  
 ,TOFF.strTimeOff  
 ,REQ.dblRequest  
 ,strApprovalStatus = ISNULL(TRN.strApprovalStatus, CASE WHEN EntityAPP.intEntityId IS NOT NULL AND EScreen.strNamespace = 'Payroll.view.TimeOffRequest' THEN 'Waiting for Submit' 
 													WHEN APP.intEntityUserSecurityId IS NOT NULL AND APPScreen.strNamespace = 'Payroll.view.TimeOffRequest' THEN 'Waiting for Submit' ELSE 'No Need for Approval' END)  
 ,REQ.ysnPostedToCalendar  
 ,strCalendarInfo = ENT.strName + ' : ' + CAST(CAST(dblRequest AS FLOAT) AS VARCHAR(20))   
      + ' Hour' + CASE WHEN (dblRequest > 0) THEN 's ' ELSE ' ' END + TOFF.strTimeOff  
 ,REQ.strReason  
 ,REQ.strAddress  
 ,PC.strPaycheckId  
 ,PC.dtmPayDate  
 ,REQ.intConcurrencyId  
FROM   
 tblPRTimeOffRequest REQ  
 LEFT JOIN tblEMEntity ENT ON REQ.intEntityEmployeeId = ENT.intEntityId  
 LEFT JOIN tblPREmployee EMP ON REQ.intEntityEmployeeId = EMP.intEntityId  
 LEFT JOIN tblPREmployeeRank EMPRank ON EMP.intRank = EMPRank.intRank  
 LEFT JOIN tblPRTypeTimeOff TOFF ON REQ.intTypeTimeOffId = TOFF.intTypeTimeOffId  
 LEFT JOIN tblPRDepartment DEP ON REQ.intDepartmentId = DEP.intDepartmentId   
 
 LEFT JOIN tblEMEntityRequireApprovalFor EntityAPP
  ON EMP.intEntityId = EntityAPP.intEntityId 
 LEFT JOIN tblSMScreen EScreen
  ON EScreen.intScreenId = EntityAPP.intScreenId 

 LEFT JOIN tblSMUserSecurityRequireApprovalFor APP  
     ON EMP.intEntityId = APP.intEntityUserSecurityId  
 LEFT JOIN tblSMScreen APPScreen  
     ON APP.intScreenId = APPScreen.intScreenId  
 
 LEFT JOIN tblSMTransaction TRN  
    ON TRN.intRecordId = REQ.intTimeOffRequestId  
 LEFT JOIN tblPRPaycheck PC ON REQ.intPaycheckId = PC.intPaycheckId

 WHERE TRN.intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = 'Payroll.view.TimeOffRequest')