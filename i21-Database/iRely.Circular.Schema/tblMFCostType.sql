CREATE TABLE [dbo].[tblMFCostType]
(
	[intCostTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFCostType_intCostTypeId] PRIMARY KEY ([intCostTypeId]), 
    CONSTRAINT [UQ_tblMFCostType_strName] UNIQUE ([strName]) 
)
