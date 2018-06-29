CREATE TABLE [dbo].[tblMFCostDriver]
(
	[intCostDriverId] INT NOT NULL , 
    [strName] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFCostDriver_CostDriver] PRIMARY KEY ([intCostDriverId]), 
    CONSTRAINT [UQ_tblMFCostDriver_strName] UNIQUE ([strName]) 
)
