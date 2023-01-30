CREATE VIEW [dbo].[vyuSMRapidDeployment]
AS
SELECT
	  A.*
	, M.strModule
FROM tblSMRapidDeployment A
JOIN tblSMModule M
	ON M.intModuleId = A.intModuleId
