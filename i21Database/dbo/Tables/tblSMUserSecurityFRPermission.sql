CREATE TABLE [dbo].[tblSMUserSecurityFRPermission]
(
	[intUserSecurityFRPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityFRPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityFRPermission_tblFRReport] FOREIGN KEY ([intReportId]) REFERENCES [tblFRReport]([intReportId]) ON DELETE CASCADE
)

GO


CREATE INDEX [IX_tblSMUserSecurityFRPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityFRPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityFRPermission_intReportId] ON [dbo].[tblSMUserSecurityFRPermission] ([intReportId])
