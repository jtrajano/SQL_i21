CREATE TYPE [dbo].[PaymentId] AS TABLE
(
	 [intHeaderId]						INT	NULL	-- Payment Id
	,[intDetailId]						INT	NULL	-- Payment Detail Id
	,[strTransactionId]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL	
	,[intARAccountId]					INT	NULL
	,[intBankAccountId]					INT	NULL
	,[intDiscountAccountId]				INT	NULL
	,[intInterestAccountId]				INT	NULL
	,[intWriteOffAccountId]				INT	NULL
	,[intGainLossAccountId]				INT	NULL
	,[intCFAccountId]					INT	NULL
	,[ysnForDelete]						BIT	NULL
	,[ysnFromPosting]					BIT	NULL
	,[ysnPost]							BIT	NULL
	,[strTransactionType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
																									-- 0. "Direct"
																									-- 1. "Invoice"
	,[ysnProcessed]						BIT	NULL
)
