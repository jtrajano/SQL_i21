CREATE TABLE [dbo].[tblMFItemSubstitutionType]
(
	[intItemSubstitutionTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFItemSubstitutionType_intItemSubstitutionTypeId] PRIMARY KEY ([intItemSubstitutionTypeId]), 
    CONSTRAINT [UQ_tblMFItemSubstitutionType_strName] UNIQUE ([strName]) 
)
