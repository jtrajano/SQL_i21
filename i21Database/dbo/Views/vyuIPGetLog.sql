CREATE VIEW [dbo].[vyuIPGetLog]
AS 
SELECT l.intLogId,p.intProcessId,p.strProcessName,s.strStepName,l.strSessionId,l.strMessage,l.dtmDate,l.strUserName,l.strInfo1,l.strInfo2,l.strData,l.strFileType 
FROM tblIPLog l Join tblIPProcess p on l.intProcessId=p.intProcessId
Join tblIPStep s on l.intStepId=s.intStepId
