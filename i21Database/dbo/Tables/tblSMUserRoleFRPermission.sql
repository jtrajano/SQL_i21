CREATE TABLE [dbo].[tblSMUserRoleFRPermission]
(
	[intUserRoleFRPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleFRPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]),
	CONSTRAINT [FK_tblSMUserRoleFRPermission_tblFRReport] FOREIGN KEY ([intReportId]) REFERENCES [tblFRReport]([intReportID])
)

GO


CREATE INDEX [IX_tblSMUserRoleFRPermission_intUserRoleId] ON [dbo].[tblSMUserRoleFRPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleFRPermission_intReportId] ON [dbo].[tblSMUserRoleFRPermission] ([intReportId])
