CREATE PROCEDURE [dbo].[uspARLogRiskPosition]
	  @tblInvoiceId			InvoiceId READONLY
	, @intUserId			INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @tblSummaryLog AS RKSummaryLog

	INSERT INTO @tblSummaryLog (
		  strBatchId 
		, strTransactionType
		, intTransactionRecordId
		, intTransactionRecordHeaderId
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
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
	)
	SELECT strBatchId					= II.strBatchId
		, strTransactionType			= I.strTransactionType
		, intTransactionRecordId		= I.intInvoiceId
		, intTransactionRecordHeaderId	= ID.intInvoiceDetailId --??
		, strTransactionNumber			= I.strInvoiceNumber
		, dtmTransactionDate			= GETDATE()
		, intContractDetailId			= ID.intContractDetailId
		, intContractHeaderId			= ID.intContractHeaderId
		, intTicketId					= ID.intTicketId
		, intCommodityId				= ITEM.intCommodityId
		, intCommodityUOMId				= ID.intItemUOMId
		, intItemId						= ID.intItemId
		, intBookId						= I.intBookId
		, intSubBookId					= I.intSubBookId
		, intLocationId					= I.intCompanyLocationId
		, intFutureMarketId				= CTD.intFutureMarketId
		, intFutureMonthId				= CTD.intFutureMonthId
		, dblNoOfLots					= CTD.dblNoOfLots
		, dblQty						= ID.dblQtyShipped
		, dblPrice						= ISNULL(ID.dblPrice, 0)
		, dblContractSize				= NULL
		, intEntityId					= I.intEntityId
		, ysnDelete						= ISNULL(II.ysnForDelete, 0)
		, intUserId						= @intUserId
		, strNotes						= NULL
		, strMiscFields					= NULL
	FROM tblARInvoice I
	INNER JOIN @tblInvoiceId II ON I.intInvoiceId = II.intHeaderId
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
	INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
	WHERE ID.intContractDetailId IS NOT NULL
	  AND ISNULL(ID.dblQtyShipped, 0) <> 0

	IF EXISTS (SELECT TOP 1 NULL FROM @tblSummaryLog)
		EXEC uspRKLogRiskPosition @tblSummaryLog
END
