GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginAccountStatus')
	DROP VIEW vyuTMOriginAccountStatus
GO

CREATE VIEW [dbo].[vyuTMOriginAccountStatus]
AS
SELECT 
	 intAccountStatusID= A4GLIdentity
	,strDescription = ssasc_desc
	,strCode = ssasc_code
	,strUserID = ssasc_user_id
	,intUserDate = ssasc_user_rev_dt
	,intConcurrencyId = 0
FROM
ssascmst

GO