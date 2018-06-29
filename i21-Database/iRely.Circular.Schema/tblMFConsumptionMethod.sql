CREATE TABLE [dbo].[tblMFConsumptionMethod]
(
	[intConsumptionMethodId] INT NOT NULL , 
    [strName] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFConsumptionMethod_intConsumptionMethodId] PRIMARY KEY ([intConsumptionMethodId]), 
    CONSTRAINT [UQ_tblMFConsumptionMethod_strName] UNIQUE ([strName]) 
)
