CREATE TABLE [dbo].[tblMFWorkOrderRecipeComputationMethod]
(
	[intMethodId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFWorkOrderRecipeComputationMethod_intMethodId] PRIMARY KEY ([intMethodId]), 
    CONSTRAINT [UQ_tblMFWorkOrderRecipeComputationMethod_strName] UNIQUE ([strName]) 
)
