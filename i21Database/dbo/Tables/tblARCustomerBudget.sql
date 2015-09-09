CREATE TABLE [dbo].[tblARCustomerBudget]
(	
	[intCustomerBudgetId]		INT				IDENTITY (1, 1) NOT NULL,
    [intEntityCustomerId]		INT				NOT NULL,
	[dblBudgetAmount]			NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
	[dtmBudgetDate]				DATETIME		NULL,    
    [intConcurrencyId]			INT				NOT NULL,
    CONSTRAINT [PK_tblARCustomerBudget] PRIMARY KEY CLUSTERED ([intCustomerBudgetId] ASC),
	CONSTRAINT [FK_tblARCustomerBudget_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityCustomerId]) ON DELETE CASCADE
)
