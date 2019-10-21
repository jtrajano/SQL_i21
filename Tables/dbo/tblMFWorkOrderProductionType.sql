CREATE TABLE [dbo].[tblMFWorkOrderProductionType]
(
	[intProductionTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFProductionType_intProductionTypeId] PRIMARY KEY ([intProductionTypeId]), 
    CONSTRAINT [UQ_tblMFProductionType_strName] UNIQUE ([strName]) 
)
