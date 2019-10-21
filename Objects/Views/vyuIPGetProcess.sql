CREATE VIEW [dbo].[vyuIPGetProcess]
AS 
SELECT intProcessId,strProcessName,strDescription,ysnAutoExecution,dtmLastExecution FROM tblIPProcess
