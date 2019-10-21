CREATE TABLE [dbo].[tblMFCostSource]
(
	[intCostSourceId] INT NOT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblMFCostSource_intCostSourceId] PRIMARY KEY ([intCostSourceId]), 
    CONSTRAINT [UQ_tblMFCostSource_strName] UNIQUE ([strName]) 
)
