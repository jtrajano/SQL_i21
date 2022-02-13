CREATE PROCEDURE [dbo].[uspARPopulateContractDetails]
	@Post BIT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF(OBJECT_ID('tempdb..#TBLTOPROCESS') IS NOT NULL) DROP TABLE #TBLTOPROCESS

CREATE TABLE #TBLTOPROCESS (
		intUniqueId					INT IDENTITY
	  , intInvoiceDetailId			INT 
	  , intInvoiceId				INT
	  , intOriginalInvoiceId		INT NULL
	  , intOriginalInvoiceDetailId	INT NULL
	  , intContractDetailId			INT 
	  , intContractHeaderId			INT NULL
	  , intItemUOMId				INT NULL
	  , intOrderUOMId				INT NULL
	  , intTicketId					INT NULL
	  , intLoadDetailId				INT NULL
	  , intPurchaseSale				INT NULL
	  , dblQty						NUMERIC(18,6) NULL DEFAULT 0
	  , dblQtyOrdered				NUMERIC(18,6) NULL DEFAULT 0
	  , ysnDestWtGrd				BIT	NULL DEFAULT 0
	  , dblShippedQty				NUMERIC(18,6) NULL DEFAULT 0
	  , dblRemainingSchedQty		NUMERIC(18,6) NULL DEFAULT 0
	  , dblConvertedQtyOrdered		NUMERIC(18,6) NULL DEFAULT 0
	  , dblConvertedQty				NUMERIC(18,6) NULL DEFAULT 0
	  , dblScheduledQty				NUMERIC(18,6) NULL DEFAULT 0
	  , intShippedQtyUOMId			INT
	  , ysnFromReturn				BIT NULL DEFAULT 0
	  , strPricing					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strBatchId					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strInvoiceNumber			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strTransactionType			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , strItemNo					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	  , dtmDate						DATETIME NULL
	  , intItemId					INT NULL
	  , intEntityId					INT NULL
	  , intContractItemUOMId		INT NULL
	  , intTicketTypeId				INT NULL
	  , intTicketType				INT NULL
	  , strInOutFlag				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	  , ysnLoad						BIT NULL DEFAULT 0
)

DELETE FROM ##ARItemsForContracts

INSERT INTO #TBLTOPROCESS (
	  intInvoiceDetailId
	, intInvoiceId
	, intOriginalInvoiceId
	, intOriginalInvoiceDetailId
	, intContractDetailId
	, intContractHeaderId
	, intItemUOMId
	, intOrderUOMId
	, intTicketId
	, intLoadDetailId
	, intPurchaseSale
	, dblQty
	, dblQtyOrdered
	, ysnDestWtGrd
	, dblShippedQty
	, intShippedQtyUOMId
	, ysnFromReturn
	, strPricing
	, strBatchId
	, strInvoiceNumber
	, strTransactionType
	, strItemNo
	, dtmDate
	, intItemId
	, intEntityId
	, intContractItemUOMId
	, intTicketTypeId
	, intTicketType
	, strInOutFlag
	, ysnLoad
	, dblScheduledQty
)
SELECT intInvoiceDetailId			= ID.intInvoiceDetailId
	, intInvoiceId					= ID.intInvoiceId
	, intOriginalInvoiceId			= RI.intInvoiceId
	, intOriginalInvoiceDetailId	= IDD.intOriginalInvoiceDetailId
	, intContractDetailId			= ID.intContractDetailId
	, intContractHeaderId			= ID.intContractHeaderId
	, intItemUOMId					= ID.intItemUOMId
	, intOrderUOMId					= IDD.intOrderUOMId
	, intTicketId					= NULL--ID.intTicketId
	, intLoadDetailId				= ID.intLoadDetailId
	, intPurchaseSale				= LG.intPurchaseSale		
	, dblQty						= CASE WHEN ID.[strTransactionType] = 'Credit Memo' AND ID.[intLoadDetailId] IS NOT NULL AND ISNULL(CH.[ysnLoad], 0) = 1 
											THEN 1 
											ELSE 
												CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL AND ISI.intDestinationGradeId IS NOT NULL AND ISI.intDestinationWeightId IS NOT NULL AND ID.dblQtyShipped > ISNULL(ISI.dblQuantity, 0) AND ISNULL(CD.dblBalance, 0) = 0
														THEN ID.dblQtyShipped - ISNULL(ISI.dblQuantity, 0)
														ELSE ID.dblQtyShipped 
												END
										END * (CASE WHEN ID.[ysnPost] = 0 THEN -1.000000 ELSE 1.000000 END) * (CASE WHEN ID.[ysnIsInvoicePositive] = 0 THEN -1.000000 ELSE 1.000000 END)
	, dblQtyOrdered					= CASE WHEN ID.intSalesOrderDetailId IS NOT NULL OR (ID.intTicketId IS NOT NULL AND ISNULL(T.intTicketType, 0) <> 6 AND ISNULL(T.strInOutFlag, '') <> 'O') THEN IDD.dblQtyOrdered ELSE 0 END
	, ysnDestWtGrd					= CASE WHEN (W.strWhereFinalized = 'Destination' OR G.strWhereFinalized= 'Destination') THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	, dblShippedQty					= 0
	, intShippedQtyUOMId			= NULL
	, ysnFromReturn					= CASE WHEN ISNULL(RI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	, strPricing					= IDD.strPricing
	, strBatchId					= ID.strBatchId
	, strInvoiceNumber				= ID.strInvoiceNumber
	, strTransactionType			= ID.strTransactionType
	, strItemNo						= ID.strItemNo
	, dtmDate						= ID.dtmDate
	, intItemId						= CD.intItemId
	, intEntityId					= CH.intEntityId
	, intContractItemUOMId			= CD.intItemUOMId
	, intTicketTypeId				= T.intTicketTypeId
	, intTicketType					= T.intTicketType
	, strInOutFlag					= T.strInOutFlag
	, ysnLoad						= CH.ysnLoad
	, dblScheduledQty				= CD.dblScheduleQty
FROM ##ARPostInvoiceDetail ID
INNER JOIN tblARInvoiceDetail IDD ON ID.intInvoiceDetailId = IDD.intInvoiceDetailId
INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblICInventoryShipmentItem ISI ON ID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId
LEFT JOIN tblARInvoice PI ON ID.intOriginalInvoiceId = PI.intInvoiceId AND ID.ysnFromProvisional = 1 AND PI.strType = 'Provisional'
LEFT JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
LEFT JOIN tblCTWeightGrade W ON W.intWeightGradeId = T.intWeightId
LEFT JOIN tblCTWeightGrade G ON G.intWeightGradeId = T.intGradeId
LEFT JOIN tblLGLoadDetail LGD ON ID.intLoadDetailId = LGD.intLoadDetailId
LEFT JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
OUTER APPLY (
	SELECT TOP 1 intInvoiceId 
	FROM tblARInvoice I
	WHERE I.strTransactionType = 'Invoice'
	  AND I.ysnReturned = 1
	  AND ID.strInvoiceOriginId = I.strInvoiceNumber
	  AND ID.intOriginalInvoiceId = I.intInvoiceId
) RI
WHERE ID.[intInventoryShipmentChargeId] IS NULL
	AND	(
		(ID.strTransactionType NOT IN ('Credit Memo', 'Debit Memo') AND ((ID.[intInventoryShipmentItemId] IS NULL AND (ID.[intLoadDetailId] IS NULL OR (ID.intLoadDetailId IS NOT NULL AND LG.intPurchaseSale = 3)))))
		OR
		(ID.strTransactionType = 'Credit Memo' AND (ID.[intInventoryShipmentItemId] IS NOT NULL OR ID.[intLoadDetailId] IS NOT NULL OR RI.[intInvoiceId] IS NOT NULL))
		)
    AND (ID.[strItemType] IS NOT NULL AND ID.[strItemType] <> 'Other Charge')
	AND (RI.[intInvoiceId] IS NULL OR (RI.[intInvoiceId] IS NOT NULL AND (ID.intLoadDetailId IS NULL OR ID.[intTicketId] IS NOT NULL)))
	AND ((ID.ysnFromProvisional = 1 AND PI.ysnPosted = 0) OR ID.ysnFromProvisional = 0)
	AND (ISNULL(W.strWhereFinalized, '') <> 'Destination' AND ISNULL(G.strWhereFinalized, '') <> 'Destination')
	AND ID.intContractDetailId IS NOT NULL

--DESTINATION WEIGHTS/GRADES
IF NOT EXISTS(SELECT TOP 1 NULL FROM #TBLTOPROCESS)
	BEGIN
		INSERT INTO #TBLTOPROCESS (
			  intInvoiceDetailId
			, intInvoiceId
			, intContractDetailId
			, intContractHeaderId
			, intItemUOMId
			, dblQty
			, intTicketId
			, ysnDestWtGrd
			, dblShippedQty
			, intShippedQtyUOMId
			, intOriginalInvoiceId
			, intOriginalInvoiceDetailId
			, ysnFromReturn
			, strPricing
			, strBatchId
			, strInvoiceNumber
			, strTransactionType
			, strItemNo
			, dtmDate
			, intItemId
			, intEntityId
			, intContractItemUOMId
			, intTicketTypeId
			, intTicketType
			, strInOutFlag
			, ysnLoad
			, dblScheduledQty
		)
		SELECT intInvoiceDetailId	= MIN(I.intInvoiceDetailId)
			, intInvoiceId			= I.intInvoiceId
			, intContractDetailId	= I.intContractDetailId
			, intContractHeaderId	= I.intContractHeaderId
			, intItemUOMId			= I.intItemUOMId
			, dblQty				= SUM(CASE WHEN I.strTransactionType = 'Credit Memo' AND I.intLoadDetailId IS NOT NULL AND ISNULL(CH.ysnLoad, 0) = 1 
											THEN 1 
											ELSE 
												CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL AND S.intDestinationGradeId IS NOT NULL AND S.intDestinationWeightId IS NOT NULL AND ID.dblQtyShipped > ISNULL(S.dblQuantity, 0) AND ISNULL(CD.dblBalance, 0) = 0
														THEN ID.dblQtyShipped - ISNULL(S.dblQuantity, 0)
														ELSE ID.dblQtyShipped 
												END
										END * (CASE WHEN I.ysnPost = 0 THEN -1.000000 ELSE 1.000000 END) * (CASE WHEN I.ysnIsInvoicePositive = 0 THEN -1.000000 ELSE 1.000000 END))
			, intTicketId			= I.intTicketId
			, ysnDestWtGrd			= CAST(1 AS BIT)
			, dblShippedQty			= AVG(ISNULL(S.dblQuantity, ID.dblQtyShipped))
			, intShippedQtyUOMId	= ISNULL(S.intItemUOMId, ID.intItemUOMId)
			, intOriginalInvoiceId			= RI.intInvoiceId
			, intOriginalInvoiceDetailId	= ID.intOriginalInvoiceDetailId
			, ysnFromReturn			= CASE WHEN ISNULL(RI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
			, strPricing			= ID.strPricing	
			, strBatchId			= I.strBatchId
			, strInvoiceNumber		= I.strInvoiceNumber
			, strTransactionType	= I.strTransactionType
			, strItemNo				= I.strItemNo
			, dtmDate				= I.dtmDate
			, intItemId				= CD.intItemId
			, intEntityId			= CH.intEntityId
			, intContractItemUOMId	= CD.intItemUOMId
			, intTicketTypeId		= T.intTicketTypeId
			, intTicketType			= T.intTicketType
			, strInOutFlag			= T.strInOutFlag
			, ysnLoad				= CH.ysnLoad
			, dblScheduledQty		= CD.dblScheduleQty
		FROM ##ARPostInvoiceDetail I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceDetailId = ID.intInvoiceDetailId
		INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
		INNER JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		INNER JOIN tblSCTicket T ON T.intTicketId = I.intTicketId
		INNER JOIN tblCTWeightGrade W ON W.intWeightGradeId = T.intWeightId
		INNER JOIN tblCTWeightGrade G ON G.intWeightGradeId = T.intGradeId
		LEFT JOIN tblICInventoryShipmentItem S ON S.intSourceId = I.intTicketId
										 AND S.intLineNo IS NOT NULL
										 AND I.intContractDetailId = S.intLineNo
		OUTER APPLY (
			SELECT TOP 1 intInvoiceId 
			FROM tblARInvoice INV
			WHERE INV.strTransactionType = 'Invoice'
			  AND INV.ysnReturned = 1
			  AND I.strInvoiceOriginId = INV.strInvoiceNumber
			  AND I.intOriginalInvoiceId = INV.intInvoiceId
		) RI
		WHERE I.intTicketId IS NOT NULL 
		  AND (W.strWhereFinalized = 'Destination' OR G.strWhereFinalized= 'Destination')
		  AND I.intContractDetailId IS NOT NULL
		  AND ID.intShipmentPurchaseSalesContractId IS NULL
		  AND I.intLoadDetailId IS NULL
		  AND (I.[strItemType] IS NOT NULL AND I.[strItemType] <> 'Other Charge')
		GROUP BY I.[intInvoiceId], I.[intContractDetailId], I.[intContractHeaderId], I.[intItemUOMId], I.[intTicketId], ISNULL(S.intItemUOMId, ID.intItemUOMId), ID.[strPricing], ID.intInventoryShipmentItemId, I.strBatchId, I.strInvoiceNumber, I.strTransactionType, I.strItemNo,  I.dtmDate, RI.intInvoiceId, ID.intOriginalInvoiceDetailId, CD.intItemId, CD.intItemUOMId, CH.intEntityId, T.intTicketTypeId, T.intTicketType, T.strInOutFlag, CH.ysnLoad, CD.dblScheduleQty
	END

IF NOT EXISTS(SELECT TOP 1 NULL FROM #TBLTOPROCESS)
	RETURN;

--CONTRACT BALANCE
INSERT INTO ##ARItemsForContracts (
	  intInvoiceId
	, intInvoiceDetailId
	, intOriginalInvoiceId
	, intOriginalInvoiceDetailId
	, intItemId
	, intContractDetailId
	, intContractHeaderId
	, intEntityId
	, intUserId
	, dtmDate
	, dblQuantity
	, dblBalanceQty
	, dblSheduledQty
	, dblRemainingQty
	, strType
	, strTransactionType
	, strInvoiceNumber
	, strItemNo
	, strBatchId
	, ysnFromReturn
)
SELECT intInvoiceId					= intInvoiceId
	, intInvoiceDetailId			= intInvoiceDetailId
	, intOriginalInvoiceId			= intOriginalInvoiceId
	, intOriginalInvoiceDetailId	= intOriginalInvoiceDetailId
	, intItemId						= intItemId
	, intContractDetailId			= intContractDetailId
	, intContractHeaderId			= intContractHeaderId
	, intEntityId					= intEntityId
	, intUserId						= intEntityId
	, dtmDate						= dtmDate
	, dblQuantity					= dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty)
	, dblBalanceQty					= dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty)
	, dblSheduledQty				= 0
	, dblRemainingQty				= 0
	, strType						= 'Contract Balance'
	, strTransactionType			= strTransactionType
	, strInvoiceNumber				= strInvoiceNumber
	, strItemNo						= strItemNo
	, strBatchId					= strBatchId
	, ysnFromReturn					= ysnFromReturn
FROM #TBLTOPROCESS
WHERE (
	   ysnDestWtGrd = 0 AND ((intTicketTypeId <> 9 AND (intTicketType <> 6 AND strInOutFlag <> 'O')) OR (intTicketTypeId = 2 AND (intTicketType = 1 AND strInOutFlag = 'O'))) 
   OR (ysnDestWtGrd = 1 AND strPricing = 'Subsystem - Direct')
)

--CONTRACT SCHEDULED
INSERT INTO ##ARItemsForContracts (
	  intInvoiceId
	, intInvoiceDetailId
	, intItemId
	, intContractDetailId
	, intContractHeaderId
	, intEntityId
	, intUserId
	, dtmDate
	, dblQuantity
	, dblBalanceQty
	, dblSheduledQty
	, dblRemainingQty
	, strType
	, strTransactionType
	, strInvoiceNumber
	, strItemNo
	, strBatchId
)
SELECT intInvoiceId					= intInvoiceId
	, intInvoiceDetailId			= intInvoiceDetailId
	, intItemId						= intItemId
	, intContractDetailId			= intContractDetailId
	, intContractHeaderId			= intContractHeaderId
	, intEntityId					= intEntityId
	, intUserId						= intEntityId
	, dtmDate						= dtmDate
	, dblQuantity					= CASE WHEN ABS(dblQtyOrdered) > 0 AND ABS(dblQty) > ABS(dblQtyOrdered) THEN -dbo.fnCalculateQtyBetweenUOM(intOrderUOMId, intContractItemUOMId, dblQtyOrdered) ELSE -dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty) END-- @dblSchQuantityToUpdate
	, dblBalanceQty					= 0
	, dblSheduledQty				= CASE WHEN ABS(dblQtyOrdered) > 0 AND ABS(dblQty) > ABS(dblQtyOrdered) THEN -dbo.fnCalculateQtyBetweenUOM(intOrderUOMId, intContractItemUOMId, dblQtyOrdered) ELSE -dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty) END-- @dblSchQuantityToUpdate
	, dblRemainingQty				= 0
	, strType						= 'Contract Scheduled'
	, strTransactionType			= strTransactionType
	, strInvoiceNumber				= strInvoiceNumber
	, strItemNo						= strItemNo
	, strBatchId					= strBatchId
FROM #TBLTOPROCESS
WHERE (
	   ysnDestWtGrd = 0 AND ((intTicketTypeId <> 9 AND (intTicketType <> 6 AND strInOutFlag <> 'O')) OR (intTicketTypeId = 2 AND (intTicketType = 1 AND strInOutFlag = 'O'))) 
   OR (ysnDestWtGrd = 1 AND strPricing = 'Subsystem - Direct')
)
AND ysnFromReturn = 0
AND (intLoadDetailId IS NULL OR (intLoadDetailId IS NOT NULL AND intPurchaseSale = 3))

--FIX CONTRACT SCHEDULED
UPDATE P
SET dblConvertedQtyOrdered	= dbo.fnCalculateQtyBetweenUOM(intOrderUOMId, intContractItemUOMId, dblQtyOrdered)
  , dblConvertedQty			= dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty)
FROM ##ARItemsForContracts C
INNER JOIN #TBLTOPROCESS P ON C.intInvoiceDetailId = P.intInvoiceDetailId AND C.intContractDetailId = P.intContractDetailId
WHERE C.strType = 'Contract Scheduled'

--FIX REMAINING CONTRACT SCHEDULED
UPDATE P
SET dblRemainingSchedQty	= CASE WHEN dblConvertedQtyOrdered - dblConvertedQty > dblScheduledQty THEN dblScheduledQty ELSE dblConvertedQtyOrdered - dblConvertedQty END
FROM ##ARItemsForContracts C
INNER JOIN #TBLTOPROCESS P ON C.intInvoiceDetailId = P.intInvoiceDetailId AND C.intContractDetailId = P.intContractDetailId
WHERE C.strType = 'Contract Scheduled'

--IF UNPOST WITH OVERAGE CONTRACT
UPDATE P
SET dblRemainingSchedQty	= ID.dblQtyShipped - ID.dblQtyOrdered
FROM ##ARItemsForContracts C
INNER JOIN #TBLTOPROCESS P ON C.intInvoiceDetailId = P.intInvoiceDetailId AND C.intContractDetailId = P.intContractDetailId
INNER JOIN tblARInvoiceDetail ID ON C.intInvoiceDetailId = ID.intInvoiceDetailId AND C.intContractDetailId = ID.intContractDetailId
WHERE C.strType = 'Contract Scheduled'
  AND P.dblConvertedQty > P.dblConvertedQtyOrdered
  AND P.dblRemainingSchedQty <> 0
  AND P.dblConvertedQtyOrdered <> 0
  AND P.dblQty < 0
  AND P.ysnLoad = 0
  AND ID.intSalesOrderDetailId IS NOT NULL
  AND ID.dblQtyOrdered <> ID.dblQtyShipped
	
UPDATE C
SET dblQuantity		= dblQuantity - CASE WHEN @Post = 1 AND dblQty > 0 THEN -dblRemainingSchedQty ELSE 0 END
  , dblSheduledQty	= dblSheduledQty - CASE WHEN @Post = 1 AND dblQty > 0 THEN -dblRemainingSchedQty ELSE 0 END
FROM ##ARItemsForContracts C
INNER JOIN #TBLTOPROCESS P ON C.intInvoiceDetailId = P.intInvoiceDetailId AND C.intContractDetailId = P.intContractDetailId
WHERE C.strType = 'Contract Scheduled'
  AND P.dblConvertedQty > P.dblConvertedQtyOrdered
  AND P.dblRemainingSchedQty <> 0
  AND P.dblConvertedQtyOrdered <> 0
  AND P.dblQty <> 0
  AND P.ysnLoad = 0 

--RETURN AND DWG
INSERT INTO ##ARItemsForContracts (
	  intInvoiceId
	, intInvoiceDetailId
	, intOriginalInvoiceId
	, intOriginalInvoiceDetailId
	, intItemId
	, intContractDetailId
	, intContractHeaderId
	, intEntityId
	, intUserId
	, dtmDate
	, dblQuantity
	, dblBalanceQty
	, dblSheduledQty
	, dblRemainingQty
	, strType
	, strTransactionType
	, strInvoiceNumber
	, strItemNo
	, strBatchId
	, ysnFromReturn
)
SELECT intInvoiceId					= intInvoiceId
	, intInvoiceDetailId			= intInvoiceDetailId
	, intOriginalInvoiceId			= intOriginalInvoiceId
	, intOriginalInvoiceDetailId	= intOriginalInvoiceDetailId
	, intItemId						= intItemId
	, intContractDetailId			= intContractDetailId
	, intContractHeaderId			= intContractHeaderId
	, intEntityId					= intEntityId
	, intUserId						= intEntityId
	, dtmDate						= dtmDate
	, dblQuantity					= dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty)
	, dblBalanceQty					= dbo.fnCalculateQtyBetweenUOM(intItemUOMId, intContractItemUOMId, dblQty)
	, dblSheduledQty				= 0
	, dblRemainingQty				= 0
	, strType						= 'Contract Balance'
	, strTransactionType			= strTransactionType
	, strInvoiceNumber				= strInvoiceNumber
	, strItemNo						= strItemNo
	, strBatchId					= strBatchId
	, ysnFromReturn					= ysnFromReturn
FROM #TBLTOPROCESS
WHERE ysnFromReturn = 1 
  AND ysnDestWtGrd = 1