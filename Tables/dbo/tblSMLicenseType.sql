CREATE TABLE [dbo].[tblSMLicenseType]
(
	[intLicenseTypeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnRequiredForApplication] BIT NOT NULL DEFAULT 1, 
    [ysnRequiredForPurchase] BIT NOT NULL DEFAULT 1, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
