CREATE TABLE [dbo].[tblMFBudgetType]
(
	[intBudgetTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblMFBudgetType_intBudgetTypeId] PRIMARY KEY ([intBudgetTypeId]), 
    CONSTRAINT [UQ_tblMFBudgetType_strName] UNIQUE ([strName])
)
