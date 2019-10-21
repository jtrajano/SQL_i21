CREATE TABLE [dbo].[tblSMTaxType]
(
    [intTaxTypeId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
