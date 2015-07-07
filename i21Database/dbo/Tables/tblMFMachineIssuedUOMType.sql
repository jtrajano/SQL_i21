CREATE TABLE [dbo].[tblMFMachineIssuedUOMType]
(
	[intIssuedUOMTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFMachineIssuedUOMType_intIssuedUOMTypeId] PRIMARY KEY ([intIssuedUOMTypeId]), 
    CONSTRAINT [UQ_tblMFMachineIssuedUOMType_strName] UNIQUE ([strName]) 
)
