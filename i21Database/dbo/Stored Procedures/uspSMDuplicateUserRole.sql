CREATE PROCEDURE [dbo].[uspSMDuplicateUserRole]
	@intUserRoleId INT,
	@newUserRoleId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMUserRole] WHERE [strName] LIKE 'DUP: ' + (SELECT [strName] FROM [dbo].[tblSMUserRole] WHERE [intUserRoleID] = @intUserRoleId) + '%' 
	
	INSERT INTO tblSMUserRole([strName], [strDescription], [strMenu], [strMenuPermission], [strForm], [ysnAdmin])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strName] 
		   ELSE 'DUP: ' + [strName] + ' (' + @intCount + ')' END,
		   [strDescription], 
		   [strMenu], 
		   [strMenuPermission], 
		   [strForm], 
		   [ysnAdmin]
	FROM [tblSMUserRole]
	WHERE [intUserRoleID] = @intUserRoleId

	SELECT @newUserRoleId = SCOPE_IDENTITY();

	EXEC uspSMUpdateUserRoleMenus @newUserRoleId, 1, 0

	UPDATE B SET B.ysnVisible = A.ysnVisible
	FROM tblSMUserRoleMenu A
	JOIN tblSMUserRoleMenu B
	ON A.intMenuId = B.intMenuId
	WHERE A.intUserRoleId = @intUserRoleId
	AND B.intUserRoleId = @newUserRoleId

	INSERT INTO [tblSMUserRoleDashboardPermission]([intUserRoleId], [intPanelId], [strPermission])
	SELECT @newUserRoleId, 
		   [intPanelId],
		   [strPermission]
	FROM [tblSMUserRoleDashboardPermission]
	WHERE [intUserRoleId] = @intUserRoleId

	INSERT INTO [tblSMUserRoleFRPermission]([intUserRoleId], [intReportId], [strPermission])
	SELECT @newUserRoleId, 
		   [intReportId], 
		   [strPermission]
	FROM [tblSMUserRoleFRPermission]
	WHERE [intUserRoleId] = @intUserRoleId

	INSERT INTO [tblSMUserRoleReportPermission]([intUserRoleId], [intReportId], [strPrinter], [ysnCollate], [intCopies], [ysnPreview], [ysnPermission])
	SELECT @newUserRoleId,
		   [intReportId],
		   [strPrinter],
		   [ysnCollate],
		   [intCopies],
		   [ysnPreview],
		   [ysnPermission]
	FROM [tblSMUserRoleReportPermission]
	WHERE [intUserRoleId] = @intUserRoleId

	INSERT INTO [tblSMUserRoleScreenPermission]([intUserRoleId],[intScreenId],[strPermission],[intConcurrencyId])
	SELECT @newUserRoleId,
		   [intScreenId],
		   [strPermission],
		   [intConcurrencyId]
	FROM [tblSMUserRoleScreenPermission]
	WHERE [intUserRoleId] = @intUserRoleId

	INSERT INTO [tblSMUserRoleControlPermission]([intUserRoleId], [intControlId], [strPermission], [strLabel], [strDefaultValue], [ysnRequired])
	SELECT @newUserRoleId,
		   [intControlId],
		   [strPermission],
		   [strLabel],
		   [strDefaultValue],
		   [ysnRequired]
	FROM [tblSMUserRoleControlPermission]
	WHERE [intUserRoleId] = @intUserRoleId

	INSERT INTO [tblSMUserRoleCompanyLocationPermission]([intUserRoleId], [intCompanyLocationId])
	SELECT @newUserRoleId, 
		   [intCompanyLocationId]
	FROM [tblSMUserRoleCompanyLocationPermission]
	WHERE [intUserRoleId] = @intUserRoleId

END
