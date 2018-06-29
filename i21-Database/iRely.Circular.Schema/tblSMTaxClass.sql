CREATE TABLE [dbo].[tblSMTaxClass]
(
	[intTaxClassId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxClass] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strOriginTaxType] NVARCHAR(5) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)