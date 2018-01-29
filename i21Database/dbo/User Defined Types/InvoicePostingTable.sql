CREATE TYPE [dbo].[InvoicePostingTable] AS TABLE
(
	 [intInvoiceId]					INT				NOT NULL
	,[strInvoiceNumber]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL
	,[dtmDate]						DATETIME										NOT NULL
	,[dtmPostDate]					DATETIME										NULL
	,[dtmShipDate]					DATETIME										NULL
	,[intEntityCustomerId]			INT				NULL
	,[intCompanyLocationId]			INT				NULL
	,[intAccountId]					INT				NULL
	,[intDeferredRevenueAccountId]	INT				NULL
	,[intCurrencyId]				INT				NULL
	,[intTermId]					INT				NULL
	,[dblInvoiceTotal]				NUMERIC(18, 6)	NULL
	,[dblShipping]					NUMERIC(18, 6)	NULL
	,[dblTax]						NUMERIC(18, 6)	NULL
	,[strImportFormat]				NVARCHAR(50)	NULL
	,[intOriginalInvoiceId]			INT				NULL
	,[intDistributionHeaderId]		INT				NULL
	,[intLoadDistributionHeaderId]	INT				NULL
	,[intLoadId]					INT				NULL
	,[intFreightTermId]				INT				NULL
	,[strActualCostId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL	
	,[intPeriodsToAccrue]			INT				NULL
	,[ysnAccrueLicense]				BIT				NULL	
	,[intSplitId]					INT				NULL
	,[dblSplitPercent]				NUMERIC(18, 6)	NULL	
	,[ysnSplitted]					BIT				NULL
	,[ysnImpactInventory]			BIT				NULL	
	,[intEntityId]					INT				NULL
	,[ysnPost]						BIT				NULL	
	,[intInvoiceDetailId]			INT				NULL	
	,[intItemId]					INT				NULL
	,[intItemUOMId]					INT				NULL
	,[intDiscountAccountId]			INT				NULL	
	,[intCustomerStorageId]			INT				NULL
	,[intStorageScheduleTypeId]		INT				NULL
	,[intSubLocationId]				INT				NULL
	,[intStorageLocationId]			INT				NULL
	,[dblQuantity]					NUMERIC(18, 6)	NULL
	,[dblMaxQuantity]				NUMERIC(18, 6)	NULL	
	,[strOptionType]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceType]				NVARCHAR(30)	COLLATE Latin1_General_CI_AS	NULL
	,[strBatchId]					NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingMessage]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[intUserId]					INT				NULL
	,[ysnAllowOtherUserToPost]		BIT				NULL
	,[ysnImpactForProvisional]		BIT				NULL
)