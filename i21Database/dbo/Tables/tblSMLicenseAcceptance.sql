CREATE TABLE [dbo].[tblSMLicenseAcceptance]
(
	[intLicenseAcceptanceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [strEULAVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmDateAccepted] DATE NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMLicenseAcceptance_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID])
)

GO

CREATE INDEX [IX_tblSMLicenseAcceptance_strEULAVersion] ON [dbo].[tblSMLicenseAcceptance] ([strEULAVersion])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLicenseAcceptance',
    @level2type = N'COLUMN',
    @level2name = N'intLicenseAcceptanceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLicenseAcceptance',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'EULA Version',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLicenseAcceptance',
    @level2type = N'COLUMN',
    @level2name = N'strEULAVersion'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Date Accepted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLicenseAcceptance',
    @level2type = N'COLUMN',
    @level2name = N'dtmDateAccepted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMLicenseAcceptance',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'