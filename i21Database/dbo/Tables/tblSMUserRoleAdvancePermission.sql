CREATE TABLE [dbo].[tblSMUserRoleAdvancePermission]
(
	[intUserRoleAdvancePermissionId]			INT NOT NULL PRIMARY KEY IDENTITY, 
	[intAdvancePermissionId]					INT NOT NULL, 
	[intUserRoleId]								INT NOT NULL, 
    [strPermission]								NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId]							INT NOT NULL DEFAULT (1), 


    CONSTRAINT [FK_tblSMUserRoleAdvancePermission_tblSMAdvancePermission] FOREIGN KEY ([intAdvancePermissionId]) REFERENCES [tblSMAdvancePermission]([intAdvancePermissionId]), 
    CONSTRAINT [FK_tblSMUserRoleAdvancePermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE
)
