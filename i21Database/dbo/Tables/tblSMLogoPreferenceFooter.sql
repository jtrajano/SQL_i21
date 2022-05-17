CREATE TABLE [dbo].[tblSMLogoPreferenceFooter]
(
	[intLogoPreferenceFooterId] INT NOT NULL PRIMARY KEY IDENTITY(1,1), 
    [strLogoName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [imgLogo] VARBINARY(MAX) NULL, 
    [ysnDefault] BIT NULL, 
    [ysnARInvoice] BIT NULL, 
    [ysnARStatement] BIT NULL, 
    [ysnContract] BIT NULL, 
	[ysnVendorStatement] BIT NULL, 
    [ysnAllOtherReports] BIT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
