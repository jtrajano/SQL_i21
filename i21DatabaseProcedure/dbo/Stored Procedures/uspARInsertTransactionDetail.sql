CREATE PROCEDURE [dbo].[uspARInsertTransactionDetail]
	@InvoiceId	INT
AS
BEGIN
	DECLARE @TransactionType AS NVARCHAR(25)
	SELECT @TransactionType = [strTransactionType] FROM tblARInvoice WHERE [intInvoiceId] = @InvoiceId
	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = @TransactionType

	DECLARE @AmountDue NUMERIC(18, 6)
	DECLARE @CurrencyId INT
	DECLARE @CompanyLocationId INT

	SELECT TOP 1 @AmountDue = [dblAmountDue], 
				@CurrencyId = intCurrencyId,
				@CompanyLocationId = intCompanyLocationId
	FROM tblARInvoice WHERE intInvoiceId = @InvoiceId
	INSERT INTO [tblARTransactionDetail](
		 [intTransactionDetailId]
		,[intTransactionId]
		,[strTransactionType]
		,[intItemId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblPrice]
		,[strPricing]
		,[intInventoryShipmentItemId]
		,[intSalesOrderDetailId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intShipmentId]
		,[intLoadDetailId]
		,[intTicketId]
		,[intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]
		,[intSiteId]
		,[intCompanyLocationSubLocationId]
		,[intStorageLocationId]
		,[intOwnershipTypeId]
		,[intStorageScheduleTypeId]
		,[intCurrencyId]
		,[intSubCurrencyId]
		,[dblAmountDue]
		,[intCompanyLocationId])
	SELECT
		 [intTransactionDetailId]				= [intInvoiceDetailId]
		,[intTransactionId]						= [intInvoiceId] 
		,[strTransactionType]					= @TransactionType
		,[intItemId]							= [intItemId] 
		,[intItemUOMId]							= [intItemUOMId] 
		,[dblQtyOrdered]						= [dblQtyOrdered] 
		,[dblQtyShipped]						= [dblQtyShipped] 
		,[dblPrice]								= [dblPrice]
		,[strPricing]							= [strPricing]
		,[intInventoryShipmentItemId]			= [intInventoryShipmentItemId]
		,[intSalesOrderDetailId]				= [intSalesOrderDetailId]
		,[intContractHeaderId]					= [intContractHeaderId]
		,[intContractDetailId]					= [intContractDetailId]
		,[intShipmentId]						= [intShipmentId]
        ,[intLoadDetailId]						= [intLoadDetailId]
        ,[intTicketId]							= [intTicketId]
        ,[intTicketHoursWorkedId]				= [intTicketHoursWorkedId]
		,[intOriginalInvoiceDetailId]			= [intOriginalInvoiceDetailId]
        ,[intSiteId]							= [intSiteId]
		,[intCompanyLocationSubLocationId]		= [intCompanyLocationSubLocationId]
		,[intStorageLocationId]					= [intStorageLocationId]
		,[intOwnershipTypeId]					= NULL
		,[intStorageScheduleTypeId]				= [intStorageScheduleTypeId]
		,[intCurrencyId]						= @CurrencyId
		,[intSubCurrencyId] 					= [intSubCurrencyId]
		,[dblAmountDue]							= @AmountDue
		,[intCompanyLocationId]					= @CompanyLocationId
	FROM
		[tblARInvoiceDetail]
	WHERE
		[intInvoiceId] = @InvoiceId
	
END
