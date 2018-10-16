CREATE TABLE [dbo].[tblARPaymentBudget]
(
	[intPaymentBudgetId]        INT IDENTITY(1,1) NOT NULL,
	[intCustomerBudgetId]       INT NOT NULL,
	[intPaymentId]              INT NOT NULL,
    [dblPayment]				NUMERIC(18, 6) NULL DEFAULT 0,
	[intConcurrencyId]		    INT CONSTRAINT [DF_tblARPaymentBudget_intConcurrencyId] DEFAULT ((0)) NOT NULL,    
	CONSTRAINT [PK_tblARPaymentBudget_intPaymentBudgetId] PRIMARY KEY CLUSTERED ([intPaymentBudgetId] ASC),
    CONSTRAINT [FK_tblARPaymentBudget_tblARCustomerBudget_intCustomerBudgetId] FOREIGN KEY ([intCustomerBudgetId]) REFERENCES [dbo].[tblARCustomerBudget] ([intCustomerBudgetId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblARPaymentBudget_tblARPayment_intPaymentId] FOREIGN KEY ([intPaymentId]) REFERENCES [dbo].[tblARPayment] ([intPaymentId]) ON DELETE CASCADE
)
