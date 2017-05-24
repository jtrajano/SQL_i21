CREATE TYPE [dbo].[InvoiceId] AS TABLE
(
	 [intHeaderId]						INT	NULL	-- Invoice/Sales Order Id
	,[ysnUpdateAvailableDiscountOnly]	BIT	NULL	-- If [ysnUpdateAvailableDiscount] = 1 > Updates existing Posted/Unposted Invoice Available Discount Amount
	,[intDetailId]						INT	NULL	-- Invoice/Sales Order Detail Id
	,[ysnForDelete]						BIT
	,[ysnFromPosting]					BIT
	,[ysnPost]							BIT
)
