CREATE TABLE [dbo].[tblCTCleanCostExpenseType]
(
	[intExpenseTypeId] INT IDENTITY(1,1) NOT NULL, 
	[intConcurrencyId] INT NOT NULL,
	[strExpenseName] NVARCHAR(256) COLLATE Latin1_General_CI_AS NOT NULL,
	[strExpenseDescription] NVARCHAR(256) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnQuantityEnable] BIT,
	
	CONSTRAINT [PK_tblCTCleanCostExpenseType_intExpenseTypeId] PRIMARY KEY CLUSTERED ([intExpenseTypeId] ASC),
	CONSTRAINT [UK_tblCTCleanCostExpenseType_strExpenseName] UNIQUE ([strExpenseName]),
	CONSTRAINT [UK_tblCTCleanCostExpenseType_strExpenseDescription] UNIQUE ([strExpenseDescription])
)
