CREATE TABLE [dbo].[tblMFBudgetLog]
(
	[intBudgetLogId] INT NOT NULL IDENTITY(1,1), 
    [intYear] INT NULL, 
    [intLocationId] INT NULL,
	[strNote] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intItemId] INT NULL, 
    [intBudgetTypeId] INT NULL, 
    [strMonth] NVARCHAR(50)  COLLATE Latin1_General_CI_AS NULL, 
    [dblOldValue] NUMERIC(18, 6) NULL, 
    [dblNewValue] NUMERIC(18, 6) NULL,
	[intLastModifiedUserId] INT NULL,
	[dtmLastModified] [datetime] NULL ,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFBudgetLog_intConcurrencyId] DEFAULT 0,
	intCompanyId INT NULL,
	CONSTRAINT [PK_tblMFBudgetLog_intBudgetLogId] PRIMARY KEY ([intBudgetLogId])	 
)
