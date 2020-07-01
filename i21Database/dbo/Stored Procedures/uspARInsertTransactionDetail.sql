CREATE PROCEDURE [dbo].[uspARInsertTransactionDetail]
	  @InvoiceId	INT
	, @UserId		INT = NULL
AS
BEGIN
	DECLARE @strTransactionType		NVARCHAR(25) = NULL
		  , @dblAmountDue			NUMERIC(18, 6) = 0
		  , @intCurrencyId			INT = NULL
		  , @intCompanyLocationId	INT
	
	SELECT TOP 1 @strTransactionType	= strTransactionType 
			   , @dblAmountDue			= dblAmountDue
			   , @intCurrencyId			= intCurrencyId
			   , @intCompanyLocationId	= intCompanyLocationId
	FROM tblARInvoice 
	WHERE intInvoiceId = @InvoiceId

	DELETE FROM [tblARTransactionDetail] WHERE [intTransactionId] = @InvoiceId AND [strTransactionType] = @strTransactionType	
	
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
		,[intItemContractHeaderId]
		,[intItemContractDetailId]
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
		,[intCompanyLocationId]
		,[intEntityUserId])
	SELECT
		 [intTransactionDetailId]				= [intInvoiceDetailId]
		,[intTransactionId]						= [intInvoiceId] 
		,[strTransactionType]					= @strTransactionType
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
		,[intItemContractHeaderId]				= [intItemContractHeaderId]
		,[intItemContractDetailId]				= [intItemContractDetailId]
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
		,[intCurrencyId]						= @intCurrencyId
		,[intSubCurrencyId] 					= [intSubCurrencyId]
		,[dblAmountDue]							= @dblAmountDue
		,[intCompanyLocationId]					= @intCompanyLocationId
		,[intEntityUserId]						= @UserId
	FROM [tblARInvoiceDetail]
	WHERE [intInvoiceId] = @InvoiceId	
END