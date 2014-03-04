CREATE TABLE [dbo].[tblSMUserRoleControlPermission]
(
	[intUserRoleControlPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intControlId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleControlPermission_tblSMControl] FOREIGN KEY ([intControlId]) REFERENCES [tblSMControl]([intControlId]), 
    CONSTRAINT [FK_tblSMUserRoleControlPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID])
)

GO

CREATE INDEX [IX_tblSMUserRoleControlPermission_intUserRoleId] ON [dbo].[tblSMUserRoleControlPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleControlPermission_intControlId] ON [dbo].[tblSMUserRoleControlPermission] ([intControlId])
