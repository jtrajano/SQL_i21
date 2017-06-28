CREATE PROCEDURE [dbo].[uspARPostInvoicesIntegrationsNew]
	 @InvoiceIds		InvoiceId	READONLY
	,@UserId			INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @IIDs AS InvoiceId
DECLARE @InvoiceLog AuditLogStagingTable	

IF EXISTS(SELECT NULL FROM @InvoiceIds WHERE [strSourceTransaction] IN ('Card Fueling Transaction','CF Tran','CF Invoice'))
BEGIN
	DELETE FROM @IIDs
	INSERT INTO @IIDs SELECT * FROM @InvoiceIds WHERE [strSourceTransaction] IN ('Card Fueling Transaction','CF Tran','CF Invoice')

	EXEC dbo.[uspARUpdatePrepaymentsAndCreditMemos] @InvoiceIds = @IIDs

	DELETE FROM @InvoiceLog

	INSERT INTO @InvoiceLog(
		 [strScreenName]
		,[intKeyValueId]
		,[intEntityId]
		,[strActionType]
		,[strDescription]
		,[strActionIcon]
		,[strChangeDescription]
		,[strFromValue]
		,[strToValue]
		,[strDetails]
	)
	SELECT DISTINCT
		 [strScreenName]			= 'AccountsReceivable.view.Invoice'
		,[intKeyValueId]			= ARI.[intInvoiceId]
		,[intEntityId]				= @UserId
		,[strActionType]			= CASE WHEN IL.[ysnPost] = 1 THEN 'Posted'  ELSE 'Unposted' END 
		,[strDescription]			= ''
		,[strActionIcon]			= NULL
		,[strChangeDescription]		= ''
		,[strFromValue]				= ''
		,[strToValue]				= ARI.[strInvoiceNumber]
		,[strDetails]				= NULL
		FROM @IIDs IL
	INNER JOIN
		(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice) ARI
			ON IL.[intHeaderId] = ARI.[intInvoiceId]

		EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog
END

DELETE FROM @IIDs
INSERT INTO @IIDs SELECT * FROM @InvoiceIds WHERE [strSourceTransaction] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')

IF NOT EXISTS(SELECT TOP 1 NULL FROM @IIDs)
	RETURN 1

--Contracts
	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
	INSERT INTO @ItemsFromInvoice
	SELECT
		-- Header
		 [intInvoiceId]								= I.[intInvoiceId]
		,[strInvoiceNumber]							= I.[strInvoiceNumber]
		,[intEntityCustomerId]						= I.[intEntityCustomerId]
		,[dtmDate]									= I.[dtmDate]
		,[intCurrencyId]							= I.[intCurrencyId]
		,[intCompanyLocationId]						= I.[intCompanyLocationId]
		,[intDistributionHeaderId]					= I.[intDistributionHeaderId]
		,[intTransactionId]							= I.[intTransactionId]

		-- Detail 
		,[intInvoiceDetailId]						= ID.[intInvoiceDetailId]			
		,[intItemId]								= ID.[intItemId]		
		,[strItemNo]								= II.[strItemNo]
		,[strItemDescription]						= ID.[strItemDescription]			
		,[intSCInvoiceId]							= ID.[intSCInvoiceId]				
		,[strSCInvoiceNumber]						= ID.[strSCInvoiceNumber]			
		,[intItemUOMId]								= ID.[intItemUOMId]					
		,[dblQtyOrdered]							= ID.[dblQtyOrdered]				
		,[dblQtyShipped]							= ID.[dblQtyShipped] * (CASE WHEN ISNULL(IIDs.[ysnPost], 0) = 1 THEN -1 ELSE 1 END) 				
		,[dblDiscount]								= ID.[dblDiscount]					
		,[dblPrice]									= ID.[dblPrice]						
		,[dblTotalTax]								= ID.[dblTotalTax]					
		,[dblTotal]									= ID.[dblTotal]						
		,[intServiceChargeAccountId]				= ID.[intServiceChargeAccountId]	
		,[intInventoryShipmentItemId]				= ID.[intInventoryShipmentItemId]	
		,[intSalesOrderDetailId]					= ID.[intSalesOrderDetailId]
		,[intShipmentPurchaseSalesContractId]		= ID.[intShipmentPurchaseSalesContractId]		
		,[intSiteId]								= ID.[intSiteId]					
		,[strBillingBy]								= ID.[strBillingBy]                 
		,[dblPercentFull]							= ID.[dblPercentFull]				
		,[dblNewMeterReading]						= ID.[dblNewMeterReading]			
		,[dblPreviousMeterReading]					= ID.[dblPreviousMeterReading]		
		,[dblConversionFactor]						= ID.[dblConversionFactor]			
		,[intPerformerId]							= ID.[intPerformerId]				
		,[intContractHeaderId]						= ID.[intContractHeaderId]
		,[strContractNumber]						= CH.[strContractNumber]
		,[strMaintenanceType]						= ID.[strMaintenanceType]           
		,[strFrequency]								= ID.[strFrequency]                 
		,[dtmMaintenanceDate]						= ID.[dtmMaintenanceDate]           
		,[dblMaintenanceAmount]						= ID.[dblMaintenanceAmount]         
		,[dblLicenseAmount]							= ID.[dblLicenseAmount]             
		,[intContractDetailId]						= ID.[intContractDetailId]			
		,[intTicketId]								= ID.[intTicketId]
		,[intTicketHoursWorkedId]					= ID.[intTicketHoursWorkedId]
		,[intCustomerStorageId]						= ID.[intCustomerStorageId]
		,[intSiteDetailId]							= ID.[intSiteDetailId]
		,[intLoadDetailId]							= ID.[intLoadDetailId]
		,[intOriginalInvoiceDetailId]				= ID.[intOriginalInvoiceDetailId]
		,[ysnLeaseBilling]							= ID.[ysnLeaseBilling]				
	FROM
		(SELECT [intInvoiceId] ,[strInvoiceNumber] ,[intEntityCustomerId] ,[dtmDate] ,[intCurrencyId] ,[intCompanyLocationId] ,[intDistributionHeaderId] ,[intTransactionId] FROM tblARInvoice WITH (NOLOCK)) I
	INNER JOIN
		@IIDs IIDs
			ON I.[intInvoiceId] = IIDs.[intHeaderId]
	INNER JOIN
		(SELECT intInvoiceId, [intInvoiceDetailId], [intItemId], [strItemDescription], [intSCInvoiceId], [strSCInvoiceNumber], [intItemUOMId], [dblQtyOrdered], [dblQtyShipped], [dblDiscount], 
			[dblPrice], [dblTotalTax], [dblTotal], [intServiceChargeAccountId], [intInventoryShipmentItemId], [intSalesOrderDetailId], [intShipmentPurchaseSalesContractId], [intSiteId], [strBillingBy],
			[dblPercentFull], [dblNewMeterReading], [dblPreviousMeterReading], [dblConversionFactor], [intPerformerId], [intContractHeaderId], [strMaintenanceType], [strFrequency], [dtmMaintenanceDate],
			[dblMaintenanceAmount], [dblLicenseAmount], [intContractDetailId], [intTicketId], [intTicketHoursWorkedId], [intCustomerStorageId], [intSiteDetailId], [intLoadDetailId], 
			[intOriginalInvoiceDetailId], [ysnLeaseBilling]
		 FROM tblARInvoiceDetail WITH (NOLOCK) ) ID 	
			ON I.[intInvoiceId] = ID.[intInvoiceId]
	LEFT JOIN
		(SELECT intItemId, [strItemNo] FROM tblICItem WITH (NOLOCK) ) II 
			ON ID.intItemId = II.intItemId
	LEFT JOIN
		(SELECT intContractHeaderId, strContractNumber FROM tblCTContractHeader WITH (NOLOCK) ) CH
			ON ID.intContractHeaderId = CH.intContractHeaderId

EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @UserId


UPDATE ARID
SET
	ARID.dblContractBalance = CTCD.dblBalance
FROM
	(SELECT intInvoiceId, dblContractBalance, intContractDetailId FROM dbo.tblARInvoiceDetail WITH (NOLOCK) ) ARID
INNER JOIN
	(SELECT intContractDetailId, dblBalance FROM dbo.tblCTContractDetail WITH (NOLOCK))  CTCD
	ON ARID.intContractDetailId = CTCD.intContractDetailId
INNER JOIN
	@IIDs IIDs
		ON ARID.[intInvoiceId] = IIDs.[intHeaderId]
WHERE 
	ARID.dblContractBalance <> CTCD.dblBalance


--Prepaids
EXEC dbo.[uspARUpdatePrepaymentsAndCreditMemos] @InvoiceIds = @IIDs


--Sales Order Status
EXEC dbo.[uspARPostSOStatusFromInvoices] @InvoiceIds = @IIDs

--Committed
--EXEC dbo.[uspARUpdateCommitted] @intTransactionId, @ysnPost, @intUserId, 1

--Stock Reservation
EXEC dbo.[uspARUpdateLineItemsReservedStock] @InvoiceIds = @IIDs

----In Transit Outbound Quantities 
--EXEC dbo.[uspARUpdateInTransit] @intTransactionId, @ysnPost, 0


------Update LG - Load Shipment
--EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
--	@InvoiceId	= @intTransactionId
--	,@Post		= @ysnPost
--	,@LoadId	= @LoadId
--	,@UserId	= @intUserId

------Patronage
--DECLARE	@successfulCount INT
--		,@invalidCount INT
--		,@success BIT
		

--EXEC [dbo].[uspPATInvoiceToCustomerVolume]
--	 @intEntityCustomerId	= @EntityCustomerId
--	,@intInvoiceId			= @intTransactionId
--	,@ysnPosted				= @ysnPost
--	,@successfulCount		= @successfulCount OUTPUT
--	,@invalidCount			= @invalidCount OUTPUT
--	,@success				= @success OUTPUT


DELETE FROM @InvoiceLog
INSERT INTO @InvoiceLog(
	 [strScreenName]
	,[intKeyValueId]
	,[intEntityId]
	,[strActionType]
	,[strDescription]
	,[strActionIcon]
	,[strChangeDescription]
	,[strFromValue]
	,[strToValue]
	,[strDetails]
)
SELECT DISTINCT
	 [strScreenName]			= 'AccountsReceivable.view.Invoice'
	,[intKeyValueId]			= ARI.[intInvoiceId]
	,[intEntityId]				= @UserId
	,[strActionType]			= CASE WHEN IL.[ysnPost] = 1 THEN 'Posted'  ELSE 'Unposted' END 
	,[strDescription]			= ''
	,[strActionIcon]			= NULL
	,[strChangeDescription]		= ''
	,[strFromValue]				= ''
	,[strToValue]				= ARI.[strInvoiceNumber]
	,[strDetails]				= NULL
	FROM @InvoiceIds IL
INNER JOIN
	(SELECT [intInvoiceId], [strInvoiceNumber] FROM tblARInvoice) ARI
		ON IL.[intHeaderId] = ARI.[intInvoiceId]

	EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog



GO