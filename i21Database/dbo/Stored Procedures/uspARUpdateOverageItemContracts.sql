CREATE PROCEDURE [dbo].[uspARUpdateOverageItemContracts]
	  @intInvoiceId			INT
	, @intUserId			INT 
AS

IF(OBJECT_ID('tempdb..#OVERAGEINVOICEDETAILS') IS NOT NULL)
BEGIN
    DROP TABLE #OVERAGEINVOICEDETAILS
END

--GET LINE ITEMS WITH OVERAGE CONTRACTS
SELECT intInvoiceDetailId   = ID.intInvoiceDetailId
     , dblBalance           = ICD.dblBalance
     , dblQtyShipped        = ID.dblQtyShipped
     , dblOverageQty        = ISNULL(ID.dblQtyShipped, 0) - ISNULL(ICD.dblBalance, 0)
INTO #OVERAGEINVOICEDETAILS
FROM tblARInvoiceDetail ID
INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
WHERE ID.intInvoiceId = @intInvoiceId
  AND ID.intItemContractDetailId IS NOT NULL
  AND ISNULL(ID.dblQtyShipped, 0) > ISNULL(ICD.dblBalance, 0)

IF NOT EXISTS (SELECT TOP 1 NULL FROM #OVERAGEINVOICEDETAILS)
    RETURN;

--UPDATE SHIPPED QTY. LINE ITEMS
UPDATE ID
SET dblQtyShipped = ISNULL(CID.dblBalance, 0)
  , dblQtyOrdered = ISNULL(CID.dblBalance, 0)
FROM tblARInvoiceDetail ID
INNER JOIN #OVERAGEINVOICEDETAILS CID ON ID.intInvoiceDetailId = CID.intInvoiceDetailId

--INSERT OVERAGE LINE ITEMS
DECLARE @tblInvoiceDetailEntries	InvoiceStagingTable

INSERT INTO @tblInvoiceDetailEntries (
      intInvoiceDetailId
    , intSalesOrderDetailId
    , strSourceTransaction
    , strSourceId
    , intEntityCustomerId
    , intCompanyLocationId
    , dtmDate			
    , intEntityId
    , intInvoiceId
    , intItemId
    , strItemDescription
    , intOrderUOMId
    , dblQtyOrdered
    , intItemUOMId
    , intPriceUOMId
    , dblQtyShipped
    , dblPrice
    , dblUnitPrice
    , intItemWeightUOMId
    , intItemContractDetailId
    , intItemContractHeaderId
    , intTicketId
    , intTaxGroupId
    , dblCurrencyExchangeRate
    , intStorageLocationId
    , intSubLocationId
    , intCompanyLocationSubLocationId
)
SELECT intInvoiceDetailId				= NULL
    , intSalesOrderDetailId     = ID.intSalesOrderDetailId
    , strSourceTransaction			= 'Direct'
    , strSourceId						    = ''
    , intEntityCustomerId				= I.intEntityCustomerId
    , intCompanyLocationId			= I.intCompanyLocationId
    , dtmDate							      = I.dtmDate
    , intEntityId						    = I.intEntityId
    , intInvoiceId					  	= @intInvoiceId
    , intItemId							    = ID.intItemId
    , strItemDescription				= ID.strItemDescription
    , intOrderUOMId						  = ID.intOrderUOMId
    , dblQtyOrdered						  = OVERAGE.dblOverageQty
    , intItemUOMId						  = ID.intItemUOMId
    , intPriceUOMId						  = ID.intPriceUOMId
    , dblQtyShipped						  = OVERAGE.dblOverageQty
    , dblPrice							    = 0
    , dblUnitPrice						  = 0
    , intItemWeightUOMId				= ID.intItemWeightUOMId
    , intItemContractDetailId		= ID.intItemContractDetailId
    , intItemContractHeaderId		= ID.intItemContractHeaderId
    , intTicketId						    = ID.intTicketId
    , intTaxGroupId						  = ID.intTaxGroupId
    , dblCurrencyExchangeRate		= ID.dblCurrencyExchangeRate
    , intStorageLocationId			= ID.intStorageLocationId
    , intSubLocationId					= ID.intSubLocationId
    , intCompanyLocationSubLocationId	= ID.intCompanyLocationSubLocationId
FROM #OVERAGEINVOICEDETAILS OVERAGE
INNER JOIN tblARInvoiceDetail ID ON OVERAGE.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId

EXEC dbo.uspARAddItemToInvoices @InvoiceEntries		= @tblInvoiceDetailEntries
                              , @IntegrationLogId	= NULL
							                , @UserId				    = @intUserId

--RECOMPUTE INVOICE AMOUNTS
EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId