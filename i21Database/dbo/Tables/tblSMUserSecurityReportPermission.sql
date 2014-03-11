CREATE TABLE [dbo].[tblSMUserSecurityReportPermission]
(
	[intUserSecurityReportPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPrinter] NVARCHAR(50) NULL, 
    [ysnCollate] BIT NOT NULL DEFAULT (0), 
    [intCopies] INT NOT NULL DEFAULT (1), 
    [ysnPreview] BIT NOT NULL DEFAULT (1), 
    [ysnPermission] BIT NOT NULL DEFAULT (0), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityReportPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityReportPermission_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [tblRMReport]([intReportId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityReportPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityReportPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityReportPermission_intReportId] ON [dbo].[tblSMUserSecurityReportPermission] ([intReportId])
