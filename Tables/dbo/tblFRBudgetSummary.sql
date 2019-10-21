CREATE TABLE [dbo].[tblFRBudgetSummary] (
    [intBudgetSummaryId]			INT				IDENTITY (1, 1) NOT NULL,
	[intBudgetCode]					INT				NULL,    
	[intBudgetId]					INT				NULL,    
	[intAccountId]					INT				NULL,    
    [dblBalance]					NUMERIC (18, 6) DEFAULT 0 NULL,
	[dtmStartDate]                  DATETIME		NULL, 
	[dtmEndDate]					DATETIME		NULL,
    [intConcurrencyId]				INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRBudgetSummary] PRIMARY KEY CLUSTERED ([intBudgetSummaryId] ASC)
);