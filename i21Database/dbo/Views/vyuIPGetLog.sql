﻿CREATE VIEW [dbo].[vyuIPGetLog]
AS 
SELECT l.intLogId,p.intProcessId,p.strProcessName,s.strStepName,l.strSessionId,l.strMessage,l.dtmDate,l.strUserName,
l.strInfo1,l.strInfo2,(CASE WHEN LEN(l.strData)>0 THEN 'z' Else '' End COLLATE Latin1_General_CI_AS)  AS strData,l.strFileType,s.intStepTypeId 
FROM tblIPLog l Join tblIPProcess p on l.intProcessId=p.intProcessId
Join tblIPStep s on l.intStepId=s.intStepId
