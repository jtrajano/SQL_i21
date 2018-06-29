CREATE TABLE [dbo].[tblSMLogoPreference]
(
	[intLogoPreferenceId] INT NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [strLogoName] NVARCHAR(50) NULL, 
    [imgLogo] VARBINARY(MAX) NULL, 
    [ysnDefault] BIT NULL, 
    [ysnARInvoice] BIT NULL, 
    [ysnARStatement] BIT NULL, 
    [ysnContract] BIT NULL, 
    [ysnAllOtherReports] BIT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
