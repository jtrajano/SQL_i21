CREATE TYPE [dbo].[CommissionPostingTable] AS TABLE 
(	 
	 [intCommissionId]					INT				NOT NULL
	,[intCommissionExpenseAccountId]	INT				NULL
	,[intAPAccountId]					INT				NULL
	,[intCompanyLocationId]				INT				NULL
	,[strCommissionNumber]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	,[strBatchId]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	,[dblTotalAmount]					NUMERIC(18, 6)	NOT NULL DEFAULT 0
	,[ysnPosted]						BIT				NOT NULL DEFAULT ((0))
	,[ysnPaid]							BIT				NOT NULL DEFAULT ((0))
)
