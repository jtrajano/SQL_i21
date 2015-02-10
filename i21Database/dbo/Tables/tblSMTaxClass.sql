CREATE TABLE [dbo].[tblSMTaxClass]
(
	[intTaxClassId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxClass] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
    [ysnTaxable] BIT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)