GO
	PRINT N'BEGIN INSERT DEFAULT USER ROLE'
GO
	ALTER TABLE tblSMUserSecurity NOCHECK CONSTRAINT FK_UserSecurity_UserRole
	ALTER TABLE tblSMUserSecurityCompanyLocationRolePermission NOCHECK CONSTRAINT FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMUserRole
GO
	DELETE FROM tblSMUserRole WHERE intUserRoleID IN (1, 2)
GO
	SET IDENTITY_INSERT [dbo].[tblSMUserRole] ON
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'ADMIN') INSERT [dbo].[tblSMUserRole] ([intUserRoleID], [strName], [strDescription], [ysnAdmin], [strRoleType]) VALUES (1, N'ADMIN', N'Do not use in Production. For Demo Purposes Only.', 1, 'Administrator')
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'USER') INSERT [dbo].[tblSMUserRole] ([intUserRoleID], [strName], [strDescription], [ysnAdmin], [strRoleType]) VALUES (2, N'USER', N'Do not use in Production. For Demo Purposes Only.', 0, 'User')	
	SET IDENTITY_INSERT [dbo].[tblSMUserRole] OFF
GO
	ALTER TABLE tblSMUserSecurity CHECK CONSTRAINT FK_UserSecurity_UserRole
	ALTER TABLE tblSMUserSecurityCompanyLocationRolePermission CHECK CONSTRAINT FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMUserRole
GO
	PRINT N'INSERT DEFAULT CONTACT ROLE'
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'Help Desk') 
		INSERT [dbo].[tblSMUserRole] ([strName], [strDescription], [strRoleType], [ysnAdmin]) VALUES (N'Help Desk', N'Default contact role.', 'Contact', 0)
	ELSE
		UPDATE [dbo].[tblSMUserRole] SET [strDescription] = N'Default contact role.' WHERE [strName] = 'Help Desk'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE intUserRoleID = 999)
	BEGIN
		SET IDENTITY_INSERT [dbo].[tblSMUserRole] ON
		INSERT [dbo].[tblSMUserRole] ([intUserRoleID], [strName], [strDescription], [strRoleType], [ysnAdmin]) VALUES (999, N'PORTAL DEFAULT', N'Do not alter this is record.', 'Portal Default', 1)
		SET IDENTITY_INSERT [dbo].[tblSMUserRole] OFF
	END
GO
	PRINT N'END INSERT DEFAULT USER ROLE'
GO