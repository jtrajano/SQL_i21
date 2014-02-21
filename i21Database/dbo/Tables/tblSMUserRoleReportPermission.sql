CREATE TABLE [dbo].[tblSMUserRoleReportPermission]
(
	[intUserRoleReportPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPrinter] NVARCHAR(50) NULL, 
    [ysnCollate] BIT NOT NULL DEFAULT (0), 
    [intCopies] INT NOT NULL DEFAULT (1), 
    [ysnPreview] BIT NOT NULL DEFAULT (1), 
    [ysnPermission] BIT NOT NULL DEFAULT (0), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleReportPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]), 
    CONSTRAINT [FK_tblSMUserRoleReportPermission_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [tblRMReport]([intReportId])
)

GO

CREATE INDEX [IX_tblSMUserRoleReportPermission_intUserRoleId] ON [dbo].[tblSMUserRoleReportPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleReportPermission_intReportId] ON [dbo].[tblSMUserRoleReportPermission] ([intReportId])
