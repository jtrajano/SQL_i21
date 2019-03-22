CREATE TABLE [dbo].[tblMFCostDistributionMethod]
(
	[intCostDistributionMethodId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFCostDistributionMethod_intCostDistributionMethodId] PRIMARY KEY ([intCostDistributionMethodId]), 
    CONSTRAINT [UQ_tblMFCostDistributionMethod_strName] UNIQUE ([strName]) 
)
