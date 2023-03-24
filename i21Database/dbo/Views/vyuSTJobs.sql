CREATE VIEW [dbo].[vyuSTJobs]
AS
SELECT		Job.intJobId,
			Job.intStoreId,
			JobType.strJobType,
			Job.strParameter1,
			Job.strParameter2,
			register.strRegisterClass,
			register.strSAPPHIREUserName,
			dbo.fnAESDecryptASym(register.strSAPPHIREPassword) as strSAPPHIREPassword
FROM		tblSTJobs Job
INNER JOIN	tblSTJobTypes JobType
ON			Job.intJobTypeId = JobType.intJobTypeId
INNER JOIN	tblSTStore store
ON			Job.intStoreId = store.intStoreId
LEFT JOIN	tblSTRegister register
ON			store.intRegisterId = register.intRegisterId
WHERE		Job.ysnJobReceived = 0