CREATE TABLE [dbo].[tblSMLicenseAcceptance]
(
	[intLicenseAcceptanceId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [strEULAVersion] NVARCHAR(50) NOT NULL, 
    [dtmDateAccepted] DATE NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMLicenseAcceptance_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID])
)

GO

CREATE INDEX [IX_tblSMLicenseAcceptance_strEULAVersion] ON [dbo].[tblSMLicenseAcceptance] ([strEULAVersion])
