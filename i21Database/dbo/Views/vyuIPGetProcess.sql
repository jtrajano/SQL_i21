CREATE VIEW [dbo].[vyuIPGetProcess]
AS 
SELECT intProcessId,strProcessName,strDescription,ysnAutoExecution,dtmLastExecution,intInterval FROM tblIPProcess
