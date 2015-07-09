GO
	PRINT 'START OF CREATING [uspTMRecreateAccountStatusView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateAccountStatusView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateAccountStatusView
GO


CREATE PROCEDURE uspTMRecreateAccountStatusView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginAccountStatus')
	BEGIN
		DROP VIEW vyuTMOriginAccountStatus
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOriginAccountStatus]
			AS
			SELECT 
				 intAccountStatusID= CAST(A4GLIdentity AS INT)
				,strDescription = ssasc_desc
				,strCode = ssasc_code
				,strUserID = ssasc_user_id
				,intUserDate = ssasc_user_rev_dt
				,intConcurrencyId = 0
			FROM
			ssascmst
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMOriginAccountStatus]
			AS
			SELECT 
				 intAccountStatusID= intAccountStatusId
				,strDescription = strDescription
				,strCode = strAccountStatusCode
				,strUserID = ''''
				,intUserDate = 0
				,intConcurrencyId = 0
			FROM
			tblARAccountStatus
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateAccountStatusView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateAccountStatusView] SP'
GO
	EXEC ('uspTMRecreateAccountStatusView')
GO
	PRINT 'END OF Execute [uspTMRecreateAccountStatusView] SP'
GO