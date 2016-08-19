CREATE TABLE [dbo].[tblSMTypeValue]
(
    [intTypeValueId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
