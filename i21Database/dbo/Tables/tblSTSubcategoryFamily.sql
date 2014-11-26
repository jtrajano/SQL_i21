CREATE TABLE [dbo].[tblSTSubcategoryFamily]
(
	[intFamilyId] INT NOT NULL IDENTITY,
    [strFamilyId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strFamilyDesc] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strFamilyComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategoryFamily] PRIMARY KEY CLUSTERED ([intFamilyId] ASC),
    CONSTRAINT [AK_tblSTSubcategoryFamily_strFamilyId] UNIQUE NONCLUSTERED ([strFamilyId] ASC),
);
