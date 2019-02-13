﻿GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginAccountStatus') 
	
	DROP VIEW vyuTMOriginAccountStatus
GO
IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ssascmst') = 1
	EXEC('
		CREATE VIEW [dbo].[vyuTMOriginAccountStatus]
		AS
		SELECT 
			 intAccountStatusID= A4GLIdentity
			,strDescription = ssasc_desc COLLATE Latin1_General_CI_AS 
			,strCode = ssasc_code COLLATE Latin1_General_CI_AS 
			,strUserID = ssasc_user_id COLLATE Latin1_General_CI_AS 
			,intUserDate = ssasc_user_rev_dt
			,intConcurrencyId = 0
		FROM
		ssascmst')
GO