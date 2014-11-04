CREATE TABLE [dbo].[tblSTSubcategoryFamily]
(
	[intFamilyId] INT NOT NULL IDENTITY,
    [strFamilyId] NCHAR(8) NOT NULL, 
    [strFamilyDesc] NCHAR(30) NULL, 
    [strFamilyComment] NCHAR(90) NULL, 
    [intConcurrencyID] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategoryFamily] PRIMARY KEY CLUSTERED ([intFamilyId] ASC),
    CONSTRAINT [AK_tblSTSubcategoryFamily_strFamilyId] UNIQUE NONCLUSTERED ([strFamilyId] ASC),
);
