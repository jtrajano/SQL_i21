CREATE PROCEDURE [AP].[Fake tblSMUserSecurity records]
AS

EXEC [AP].DropConstraints 'tblSMUserSecurity'
EXEC [tSQLt].FakeTable 'dbo.tblSMUserSecurity', @Identity = 1

INSERT [dbo].[tblSMUserSecurity] (
	[intEntityUserSecurityId]
	,[intUserRoleID]
	,[intCompanyLocationId]
	,[strUserName]
	,[strJIRAUserName]
	,[strFullName]
	,[strPassword]
	,[strOverridePassword]
	,[strDashboardRole]
	,[strFirstName]
	,[strMiddleName]
	,[strLastName]
	,[strPhone]
	,[strDepartment]
	,[strLocation]
	,[strEmail]
	,[strMenuPermission]
	,[strMenu]
	,[strForm]
	,[strFavorite]
	,[ysnDisabled]
	,[ysnAdmin]
	,[ysnRequirePurchasingApproval]
	,[intConcurrencyId]
	,[intEntityIdOld]
	,[intUserSecurityIdOld]
	)
VALUES (
	1
	,1
	,2
	,N'irelyadmin'
	,N''
	,N'IRELY ADMIN'
	,N'i21by2015'
	,N''
	,N'Administrator'
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,N''
	,0
	,0
	,0
	,9
	,1
	,1
	)
