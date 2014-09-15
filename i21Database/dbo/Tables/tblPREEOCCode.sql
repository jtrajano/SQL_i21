CREATE TABLE [dbo].[tblPREEOCCode]
(
	[intEEOCCodeId] INT NOT NULL IDENTITY , 
    [strEEOCCode] NVARCHAR(50) NOT NULL, 
    [strJobTitle] NVARCHAR(50) NULL, 
	[strJobDescription] NVARCHAR(255) NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblPREEOCCode] PRIMARY KEY ([intEEOCCodeId]), 
    CONSTRAINT [UK_tblPREEOCCode_strDivision] UNIQUE ([strEEOCCode]) 
)

GO
