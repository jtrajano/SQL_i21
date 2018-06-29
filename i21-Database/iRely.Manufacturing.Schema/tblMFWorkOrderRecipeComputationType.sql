CREATE TABLE [dbo].[tblMFWorkOrderRecipeComputationType]
(
	[intTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFWorkOrderRecipeComputationType_intTypeId] PRIMARY KEY ([intTypeId]), 
    CONSTRAINT [UQ_tblMFWorkOrderRecipeComputationType_strName] UNIQUE ([strName]) 
)
