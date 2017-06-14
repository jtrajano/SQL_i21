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
	,[strSourceTransaction]				NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values 
																									-- 0. "Direct"
																									-- 1. "Sales Order"
																									-- 2. "Invoice", "Provisional", 
																									-- 3. "Transport Load"
																									-- 4. "Inbound Shipment"
																									-- 5. "Inventory Shipment"
																									-- 6. "Card Fueling Transaction" / "CF Tran"
																									-- 7. "Transfer Storage"
																									-- 8. "Sale OffSite"
																									-- 9. "Settle Storage"
																									-- 10. "Process Grain Storage"
																									-- 11. "Consumption Site"
																									-- 12. "Meter Billing"
																									-- 13. "Load/Shipment Schedules"
																									-- 14. "Credit Card Reconciliation"
																									-- 15. "Sales Contract"
																									-- 16. "Load Schedule"
																									-- 17. "CF Invoice"
	,[ysnProcessed]						BIT	NULL
)
