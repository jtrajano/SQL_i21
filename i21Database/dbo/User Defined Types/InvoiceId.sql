CREATE TYPE [dbo].[InvoiceId] AS TABLE
(
	 [intHeaderId]						INT	NULL	-- Invoice Id
	,[ysnUpdateAvailableDiscountOnly]	BIT	NULL	-- If [ysnUpdateAvailableDiscount] = 1 > Updates existing Posted/Unposted Invoice Available Discount Amount
	,[intDetailId]						INT	NULL	-- Invoice Detail Id
)
