CREATE TYPE [dbo].[InvoiceId] AS TABLE
(
	 [intHeaderId]						INT	NULL	-- Invoice/Sales Order Id
	,[ysnUpdateAvailableDiscountOnly]	BIT	NULL	-- If [ysnUpdateAvailableDiscount] = 1 > Updates existing Posted/Unposted Invoice Available Discount Amount
	,[intDetailId]						INT	NULL	-- Invoice/Sales Order Detail Id
	,[ysnForDelete]						BIT	NULL
	,[ysnFromPosting]					BIT	NULL
	,[ysnPost]							BIT	NULL
	,[ysnAccrueLicense]					BIT	NULL
	,[strTransactionType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
)
