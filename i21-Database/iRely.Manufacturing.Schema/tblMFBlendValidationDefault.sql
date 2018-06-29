CREATE TABLE [dbo].[tblMFBlendValidationDefault]
(
	[intBlendValidationDefaultId] INT NOT NULL, 
    [strBlendValidationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFBlendValidationDefault_intBlendValidationDefaultId] PRIMARY KEY ([intBlendValidationDefaultId]), 
    CONSTRAINT [UQ_tblMFBlendValidationDefault_strBlendValidationName] UNIQUE ([strBlendValidationName])  
)
