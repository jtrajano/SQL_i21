CREATE PROCEDURE [dbo].[uspARLogRiskPosition]
	  @tblInvoiceId		InvoiceId READONLY
	, @intUserId		INT
AS
 
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
 
BEGIN
    DECLARE @tblSummaryLog          AS RKSummaryLog
    
    INSERT INTO @tblSummaryLog (
          strBatchId 
        , strBucketType
        , strTransactionType
        , intTransactionRecordId
        , intTransactionRecordHeaderId
        , strDistributionType
        , strTransactionNumber
        , dtmTransactionDate
        , intContractDetailId
        , intContractHeaderId
        , intFutOptTransactionId
        , intTicketId
        , intCommodityId
        , intCommodityUOMId
        , intItemId
        , intBookId
        , intSubBookId
        , intLocationId
        , intFutureMarketId
        , intFutureMonthId
        , dblNoOfLots
        , dblQty
        , dblPrice
        , dblContractSize
        , intEntityId
        , ysnDelete
        , intUserId
        , strNotes
        , strMiscFields
        , intActionId
        , intCurrencyId
    )
    --INVOICE HEADER ADD/DELETE 
    SELECT strBatchId				            = II.strBatchId
        , strBucketType					        = 'Accounts Receivable'
        , strTransactionType            = I.strTransactionType
        , intTransactionRecordId		    = ID.intInvoiceDetailId
        , intTransactionRecordHeaderId	= I.intInvoiceId
        , strDistributionType			      = NULL
        , strTransactionNumber			    = I.strInvoiceNumber
        , dtmTransactionDate			      = I.dtmDate
        , intContractDetailId			      = ID.intContractDetailId
        , intContractHeaderId			      = ID.intContractHeaderId
        , intFutOptTransactionId		    = NULL
        , intTicketId					          = ID.intTicketId
        , intCommodityId				        = ITEM.intCommodityId
        , intCommodityUOMId				      = ICUM.intCommodityUnitMeasureId
        , intItemId						          = ID.intItemId
        , intBookId						          = I.intBookId
        , intSubBookId					        = I.intSubBookId
        , intLocationId					        = I.intCompanyLocationId
        , intFutureMarketId				      = CTD.intFutureMarketId
        , intFutureMonthId				      = CTD.intFutureMonthId
        , dblNoOfLots					          = CTD.dblNoOfLots
        , dblQty						            = -((ID.dblQtyShipped * CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END) * CASE WHEN ISNULL(II.ysnForDelete, 0) = 1 THEN -1 ELSE 1 END)
        , dblPrice						          = ISNULL(ID.dblPrice, 0)
        , dblContractSize				        = NULL
        , intEntityId					          = I.intEntityCustomerId
        , ysnDelete						          = ISNULL(II.ysnForDelete, 0)
        , intUserId						          = @intUserId
        , strNotes						          = NULL
        , strMiscFields					        = NULL
        , intActionId					          = 16--CREATE INVOICE
        , intCurrencyId                 = I.intCurrencyId    
    FROM tblARInvoice I
    INNER JOIN @tblInvoiceId II ON I.intInvoiceId = II.intHeaderId
    INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
    INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ID.intItemUOMId
    INNER JOIN tblICCommodityUnitMeasure ICUM ON ICUM.intCommodityId = ITEM.intCommodityId AND ICUM.intUnitMeasureId = IUOM.intUnitMeasureId 
    LEFT JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
    LEFT JOIN tblARTransactionDetail TD ON I.intInvoiceId = TD.intTransactionId AND I.strTransactionType = TD.strTransactionType
    WHERE ID.intItemId IS NOT NULL
      AND I.strTransactionType IN ('Credit Memo', 'Debit Memo', 'Invoice')
      AND TD.intTransactionId IS NULL
      AND ITEM.strType != 'Other Charge'

    UNION ALL

    --ADD LINE ITEM 
    SELECT strBatchId				            = II.strBatchId
        , strBucketType					        = 'Accounts Receivable'
        , strTransactionType            = I.strTransactionType
        , intTransactionRecordId		    = ID.intInvoiceDetailId
        , intTransactionRecordHeaderId	= I.intInvoiceId
        , strDistributionType			      = NULL
        , strTransactionNumber			    = I.strInvoiceNumber
        , dtmTransactionDate			      = I.dtmDate
        , intContractDetailId			      = ID.intContractDetailId
        , intContractHeaderId			      = ID.intContractHeaderId
        , intFutOptTransactionId		    = NULL
        , intTicketId					          = ID.intTicketId
        , intCommodityId				        = ITEM.intCommodityId
        , intCommodityUOMId				      = ICUM.intCommodityUnitMeasureId
        , intItemId						          = ID.intItemId
        , intBookId						          = I.intBookId
        , intSubBookId					        = I.intSubBookId
        , intLocationId					        = I.intCompanyLocationId
        , intFutureMarketId				      = CTD.intFutureMarketId
        , intFutureMonthId				      = CTD.intFutureMonthId
        , dblNoOfLots					          = CTD.dblNoOfLots
        , dblQty						            = -(ID.dblQtyShipped * CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END)
        , dblPrice						          = ISNULL(ID.dblPrice, 0)
        , dblContractSize				        = NULL
        , intEntityId					          = I.intEntityCustomerId
        , ysnDelete						          = ISNULL(II.ysnForDelete, 0)
        , intUserId						          = @intUserId
        , strNotes						          = NULL
        , strMiscFields					        = NULL
        , intActionId					          = 16--CREATE INVOICE
        , intCurrencyId                 = I.intCurrencyId       
    FROM tblARInvoice I
    INNER JOIN @tblInvoiceId II ON I.intInvoiceId = II.intHeaderId
    INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
    INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ID.intItemUOMId
    INNER JOIN tblICCommodityUnitMeasure ICUM ON ICUM.intCommodityId = ITEM.intCommodityId AND ICUM.intUnitMeasureId = IUOM.intUnitMeasureId 
    LEFT JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
    INNER JOIN tblARTransactionDetail TD ON I.intInvoiceId = TD.intTransactionId AND I.strTransactionType = TD.strTransactionType
    INNER JOIN tblICItem ITEM2 ON TD.intItemId = ITEM2.intItemId
    WHERE ID.intItemId IS NOT NULL
      AND I.strTransactionType IN ('Credit Memo', 'Debit Memo', 'Invoice')
      AND ISNULL(II.ysnForDelete, 0) = 0
      AND ID.intInvoiceDetailId NOT IN (SELECT intTransactionDetailId FROM tblARTransactionDetail TDD WHERE I.intInvoiceId = TDD.intTransactionId AND ID.intInvoiceDetailId = TDD.intTransactionDetailId AND I.strTransactionType = TDD.strTransactionType) 
      AND ITEM.strType != 'Other Charge'
      AND ITEM2.strType != 'Other Charge'

    UNION ALL

    --DELETE LINE ITEM
    SELECT strBatchId				            = II.strBatchId
        , strBucketType					        = 'Accounts Receivable'
        , strTransactionType            = I.strTransactionType
        , intTransactionRecordId		    = TD.intTransactionDetailId
        , intTransactionRecordHeaderId	= I.intInvoiceId
        , strDistributionType			      = NULL
        , strTransactionNumber			    = I.strInvoiceNumber
        , dtmTransactionDate			      = I.dtmDate
        , intContractDetailId			      = TD.intContractDetailId
        , intContractHeaderId			      = TD.intContractHeaderId
        , intFutOptTransactionId		    = NULL
        , intTicketId					          = TD.intTicketId
        , intCommodityId				        = ITEM.intCommodityId
        , intCommodityUOMId				      = ICUM.intCommodityUnitMeasureId
        , intItemId						          = TD.intItemId
        , intBookId						          = I.intBookId
        , intSubBookId					        = I.intSubBookId
        , intLocationId					        = I.intCompanyLocationId
        , intFutureMarketId				      = CTD.intFutureMarketId
        , intFutureMonthId				      = CTD.intFutureMonthId
        , dblNoOfLots					          = CTD.dblNoOfLots
        , dblQty						            = TD.dblQtyShipped * CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END
        , dblPrice						          = ISNULL(TD.dblPrice, 0)
        , dblContractSize			        	= NULL
        , intEntityId				          	= I.intEntityCustomerId
        , ysnDelete				          		= ISNULL(II.ysnForDelete, 0)
        , intUserId					          	= @intUserId
        , strNotes					            = NULL
        , strMiscFields					        = NULL
        , intActionId					          = 63--DELETE INVOICE
        , intCurrencyId                 = I.intCurrencyId
    FROM tblARTransactionDetail TD
    INNER JOIN tblARInvoice I ON I.intInvoiceId = TD.intTransactionId
    INNER JOIN @tblInvoiceId II ON TD.intTransactionId = II.intHeaderId
    LEFT JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId AND TD.intTransactionDetailId = ID.intInvoiceDetailId
    INNER JOIN tblICItem ITEM ON TD.intItemId = ITEM.intItemId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = TD.intItemUOMId
    INNER JOIN tblICCommodityUnitMeasure ICUM ON ICUM.intCommodityId = ITEM.intCommodityId AND ICUM.intUnitMeasureId = IUOM.intUnitMeasureId 
    LEFT JOIN tblCTContractDetail CTD ON TD.intContractDetailId = CTD.intContractDetailId
    INNER JOIN tblICItem ITEM2 ON TD.intItemId = ITEM2.intItemId
    WHERE TD.intItemId IS NOT NULL
      AND TD.strTransactionType IN ('Credit Memo', 'Debit Memo', 'Invoice')
      --AND ISNULL(II.ysnForDelete, 0) = 0
      AND ID.intInvoiceDetailId IS NULL
      AND ITEM.strType != 'Other Charge'
      AND ITEM2.strType != 'Other Charge'

    UNION ALL

    --UPDATE LINE ITEM (RETURN ORGINAL QTY)
    SELECT strBatchId				            = II.strBatchId
        , strBucketType					        = 'Accounts Receivable'
        , strTransactionType            = I.strTransactionType
        , intTransactionRecordId		    = ID.intInvoiceDetailId
        , intTransactionRecordHeaderId	= I.intInvoiceId
        , strDistributionType			      = NULL
        , strTransactionNumber			    = I.strInvoiceNumber
        , dtmTransactionDate			      = I.dtmDate
        , intContractDetailId			      = ID.intContractDetailId
        , intContractHeaderId			      = ID.intContractHeaderId
        , intFutOptTransactionId		    = NULL
        , intTicketId				          	= ID.intTicketId
        , intCommodityId				        = ITEM.intCommodityId
        , intCommodityUOMId				      = ICUM.intCommodityUnitMeasureId
        , intItemId						          = ID.intItemId
        , intBookId					          	= I.intBookId
        , intSubBookId			        		= I.intSubBookId
        , intLocationId			        		= I.intCompanyLocationId
        , intFutureMarketId		      		= CTD.intFutureMarketId
        , intFutureMonthId		      		= CTD.intFutureMonthId
        , dblNoOfLots				          	= CTD.dblNoOfLots
        , dblQty					            	= TD.dblQtyShipped * CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END
        , dblPrice				          		= ISNULL(ID.dblPrice, 0)
        , dblContractSize		        		= NULL
        , intEntityId				          	= I.intEntityCustomerId
        , ysnDelete				          		= ISNULL(II.ysnForDelete, 0)
        , intUserId				          		= @intUserId
        , strNotes					          	= NULL
        , strMiscFields			        		= NULL
        , intActionId				           	= 16--CREATE INVOICE
        , intCurrencyId                 = I.intCurrencyId       
    FROM tblARInvoice I
    INNER JOIN @tblInvoiceId II ON I.intInvoiceId = II.intHeaderId
    INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
    INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ID.intItemUOMId
    INNER JOIN tblICCommodityUnitMeasure ICUM ON ICUM.intCommodityId = ITEM.intCommodityId AND ICUM.intUnitMeasureId = IUOM.intUnitMeasureId 
    LEFT JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
    INNER JOIN tblARTransactionDetail TD ON I.intInvoiceId = TD.intTransactionId AND ID.intInvoiceDetailId = TD.intTransactionDetailId AND I.strTransactionType = TD.strTransactionType
    WHERE ID.intItemId IS NOT NULL
      AND I.strTransactionType IN ('Credit Memo', 'Debit Memo', 'Invoice')
      AND ISNULL(II.ysnForDelete, 0) = 0
      AND ID.dblQtyShipped <> TD.dblQtyShipped
      AND ITEM.strType != 'Other Charge'

    UNION ALL

    --UPDATE LINE ITEM (DEDUCT ACTUAL QTY)
    SELECT strBatchId				            = II.strBatchId
        , strBucketType					        = 'Accounts Receivable'
        , strTransactionType            = I.strTransactionType
        , intTransactionRecordId		    = ID.intInvoiceDetailId
        , intTransactionRecordHeaderId	= I.intInvoiceId
        , strDistributionType			      = NULL
        , strTransactionNumber			    = I.strInvoiceNumber
        , dtmTransactionDate			      = I.dtmDate
        , intContractDetailId			      = ID.intContractDetailId
        , intContractHeaderId			      = ID.intContractHeaderId
        , intFutOptTransactionId		    = NULL
        , intTicketId					          = ID.intTicketId
        , intCommodityId				        = ITEM.intCommodityId
        , intCommodityUOMId				      = ICUM.intCommodityUnitMeasureId
        , intItemId						          = ID.intItemId
        , intBookId						          = I.intBookId
        , intSubBookId					        = I.intSubBookId
        , intLocationId				        	= I.intCompanyLocationId
        , intFutureMarketId		      		= CTD.intFutureMarketId
        , intFutureMonthId			      	= CTD.intFutureMonthId
        , dblNoOfLots				          	= CTD.dblNoOfLots
        , dblQty					             	= -(ID.dblQtyShipped * CASE WHEN I.strTransactionType = 'Credit Memo' THEN -1 ELSE 1 END)
        , dblPrice			        	  		= ISNULL(ID.dblPrice, 0)
        , dblContractSize		        		= NULL
        , intEntityId			          		= I.intEntityCustomerId
        , ysnDelete				          		= ISNULL(II.ysnForDelete, 0)
        , intUserId			           			= @intUserId
        , strNotes			          			= NULL
        , strMiscFields			        		= NULL
        , intActionId				          	= 16--CREATE INVOICE
        , intCurrencyId                 = I.intCurrencyId       
    FROM tblARInvoice I
    INNER JOIN @tblInvoiceId II ON I.intInvoiceId = II.intHeaderId
    INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
    INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = ID.intItemUOMId
    INNER JOIN tblICCommodityUnitMeasure ICUM ON ICUM.intCommodityId = ITEM.intCommodityId AND ICUM.intUnitMeasureId = IUOM.intUnitMeasureId 
    LEFT JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
    INNER JOIN tblARTransactionDetail TD ON I.intInvoiceId = TD.intTransactionId AND ID.intInvoiceDetailId = TD.intTransactionDetailId AND I.strTransactionType = TD.strTransactionType
    WHERE ID.intItemId IS NOT NULL
      AND I.strTransactionType IN ('Credit Memo', 'Debit Memo', 'Invoice')
      AND ISNULL(II.ysnForDelete, 0) = 0
      AND ID.dblQtyShipped <> TD.dblQtyShipped
      AND ITEM.strType != 'Other Charge'

    --POST/UNPOST DWG
    DELETE FROM SL
    FROM @tblSummaryLog SL
    INNER JOIN tblARInvoiceDetail ID ON SL.intTransactionRecordId = ID.intInvoiceDetailId
    INNER JOIN tblICInventoryShipmentItem ISI ON ID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId
    WHERE ISNULL(ISI.ysnDestinationWeightsAndGrades, 0) = 1   

    IF EXISTS (SELECT TOP 1 NULL FROM @tblSummaryLog)
    BEGIN
        EXEC dbo.uspRKLogRiskPosition @tblSummaryLog, 0, 0
    END

    --CONTRACT BALANCE LOG  
    WHILE EXISTS (SELECT TOP 1 NULL FROM @tblSummaryLog)  
    BEGIN  
        DECLARE @intId                INT = NULL  
              , @intContractHeaderId  INT = NULL  
              , @intContractDetailId  INT = NULL       
              , @intTransactionId     INT = NULL  
              , @dblTransactionQty    NUMERIC(24, 10) = 0  
              , @strSource            NVARCHAR(20) = NULL  
              , @strProcess           NVARCHAR(50) = NULL  
  
        SELECT TOP 1 @intId    = intId  
                , @intContractHeaderId = intContractHeaderId  
                , @intContractDetailId = intContractDetailId  
                , @intTransactionId  = intTransactionRecordId  
                , @dblTransactionQty = dblQty  
                , @strSource   = 'Inventory'  
                , @strProcess   = CASE WHEN dblQty > 0 THEN 'Delete Invoice' ELSE 'Create Invoice' END  
        FROM @tblSummaryLog  
  
        DECLARE @contractDetailList AS ContractDetailTable  
        EXEC uspCTLogSummary @intContractHeaderId = @intContractHeaderId  
                                , @intContractDetailId = @intContractDetailId  
                                , @strSource   = @strSource  
                                , @strProcess   = @strProcess  
                                , @contractDetail  = @contractDetailList  
                                , @intUserId   = @intUserId  
                                , @intTransactionId  = @intTransactionId  
                                , @dblTransactionQty = @dblTransactionQty  
  
        DELETE FROM @tblSummaryLog WHERE intId = @intId  
    END  
END