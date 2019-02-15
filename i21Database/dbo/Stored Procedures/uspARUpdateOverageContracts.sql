CREATE PROCEDURE [dbo].[uspARUpdateOverageContracts]
	  @intInvoiceId		INT
	, @intScaleUOMId	INT
	, @intUserId		INT
	, @dblNetWeight		NUMERIC(18, 6) = 0
AS

DECLARE @tblInvoiceIds				InvoiceId
DECLARE @intUnitMeasureId			INT
	  , @intTicketForDiscountId		INT
	  , @strUnitMeasure				NVARCHAR(100)
	  , @strInvalidItem				NVARCHAR(500)

--DROP TEMP TABLES
IF(OBJECT_ID('tempdb..#INVOICEDETAILS') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICEDETAILS
END

IF(OBJECT_ID('tempdb..#INVOICEIDS') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICEIDS
END

IF(OBJECT_ID('tempdb..#INVOICEDETAILSTOADD') IS NOT NULL)
BEGIN
    DROP TABLE #INVOICEDETAILSTOADD
END

IF(OBJECT_ID('tempdb..#SHIPMENTCHARGES') IS NOT NULL)
BEGIN
    DROP TABLE #SHIPMENTCHARGES
END

CREATE TABLE #INVOICEDETAILSTOADD (
	  intInvoiceDetailId			INT	NOT NULL
	, intContractDetailId			INT NULL
	, intContractHeaderId			INT	NULL
	, intTicketId					INT NULL
	, intItemId						INT NULL	
	, intItemUOMId					INT NULL	
	, dblQtyShipped					NUMERIC(18, 6) NOT NULL
	, dblPrice						NUMERIC(18, 6) NOT NULL
	, ysnCharge						BIT NULL
)

--GET INVOICES WITH CONTRACTS AND OVERAGED CONVERT ITEM QTY WITH CONTRACTS TO SCALE UOM (BUSHELS USUALLY)
SELECT intInvoiceId					= ID.intInvoiceId
	 , intCompanyLocationId			= I.intCompanyLocationId
	 , intEntityCustomerId			= I.intEntityCustomerId
	 , dtmDate						= I.dtmDate
	 , intInvoiceDetailId			= ID.intInvoiceDetailId
	 , intContractDetailId			= ID.intContractDetailId
	 , intContractHeaderId			= ID.intContractHeaderId
	 , intItemUOMId					= ID.intItemUOMId
	 , intItemId					= ID.intItemId
	 , intContractSeq				= CD.intContractSeq
	 , dblQtyShipped				= ID.dblQtyShipped
	 , dblQtyOrdered				= ID.dblQtyOrdered
	 , dblPrice						= ID.dblPrice
	 , dblUnitPrice					= ID.dblUnitPrice
	 , dblUnitQuantity				= ID.dblUnitQuantity
	 , intEntityId					= I.intEntityId
	 , intInventoryShipmentItemId	= ID.intInventoryShipmentItemId
	 , intTicketId					= ID.intTicketId
	 , strDocumentNumber			= ID.strDocumentNumber			
INTO #INVOICEDETAILS 
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId AND ID.intContractHeaderId = CD.intContractHeaderId
WHERE I.intInvoiceId = @intInvoiceId
  AND dblQtyShipped > dblQtyOrdered

INSERT INTO @tblInvoiceIds (intHeaderId)
SELECT DISTINCT intInvoiceId FROM #INVOICEDETAILS

SELECT DISTINCT intInvoiceId
			  , intEntityId
INTO #INVOICEIDS
FROM #INVOICEDETAILS

SELECT TOP 1 @intTicketForDiscountId = intTicketId
FROM #INVOICEDETAILS

SELECT intTicketId			= SC.intTicketId
     , intTicketDiscountId	= QM.intTicketDiscountId
	 , intItemUOMId			= IC.intCostUOMId
	 , intItemId			= IC.intChargeId
INTO #SHIPMENTCHARGES
FROM tblSCTicket SC
INNER JOIN tblGRDiscountCrossReference GCR ON GCR.intDiscountId = SC.intDiscountId
INNER JOIN tblGRDiscountSchedule GRDS ON GRDS.intDiscountScheduleId = GCR.intDiscountScheduleId AND GRDS.intCommodityId = SC.intCommodityId
INNER JOIN tblGRDiscountScheduleCode GRDSC ON GRDSC.intDiscountScheduleId = GCR.intDiscountScheduleId 
INNER JOIN tblQMTicketDiscount QM ON QM.intDiscountScheduleCodeId = GRDSC.intDiscountScheduleCodeId AND QM.strSourceType = 'Scale' AND QM.intTicketId = SC.intTicketId
INNER JOIN tblICInventoryShipmentItem ICS ON ICS.intSourceId = SC.intTicketId
INNER JOIN tblICInventoryShipmentCharge IC ON IC.intChargeId = GRDSC.intItemId AND IC.intInventoryShipmentId = ICS.intInventoryShipmentId
WHERE SC.intTicketId = @intTicketForDiscountId

--VALIDATE ITEMS IF HAS SCALE UOM
SELECT @intUnitMeasureId 	= IUOM.intUnitMeasureId
	 , @strUnitMeasure		= UOM.strUnitMeasure
FROM dbo.tblICItemUOM IUOM WITH (NOLOCK)
INNER JOIN tblICUnitMeasure UOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
WHERE IUOM.intItemUOMId = @intScaleUOMId

SELECT TOP 1 @strInvalidItem = I.strItemNo + ' - ' + I.strDescription
FROM #INVOICEDETAILS ID WITH (NOLOCK)
INNER JOIN (
	SELECT I.intItemId
		 , I.strItemNo
	     , I.strDescription
	FROM dbo.tblICItem I WITH (NOLOCK)
	LEFT JOIN dbo.tblICItemUOM IUOM ON I.intItemId = IUOM.intItemId AND IUOM.intUnitMeasureId = @intUnitMeasureId
	WHERE I.ysnUseWeighScales = 1
	  AND IUOM.intItemUOMId IS NULL
) I ON ID.intItemId = I.intItemId 
WHERE intInvoiceId = @intInvoiceId

IF ISNULL(@strInvalidItem, '') <> ''
	BEGIN
		DECLARE @strErrorMsg NVARCHAR(MAX) = 'Item ' + @strInvalidItem + ' doesn''t have UOM setup for ' + @strUnitMeasure + '.'

		RAISERROR(@strErrorMsg, 16, 1)
		RETURN;
	END

WHILE EXISTS (SELECT TOP 1 NULL FROM #INVOICEDETAILS)
	BEGIN
		DECLARE @intInvoiceDetailId			INT	= NULL
			  , @intCompanyLocationId		INT = NULL
			  , @intEntityCustomerId		INT = NULL
			  , @intContractDetailId		INT = NULL
			  , @intContractHeaderId		INT = NULL
			  , @intItemId					INT = NULL
			  , @intContractSeq				INT = NULL
			  , @intInventoryShipmentItemId	INT = NULL
			  , @intTicketId				INT = NULL
			  , @dblQtyOverAged				NUMERIC(18, 6) = 0
			  , @dtmDate					DATETIME = NULL
			  , @strDocumentNumber			NVARCHAR(100) = NULL

		SELECT TOP 1 @intInvoiceDetailId			= intInvoiceDetailId
				   , @intCompanyLocationId			= intCompanyLocationId
				   , @intEntityCustomerId			= intEntityCustomerId
				   , @intContractDetailId			= intContractDetailId
				   , @intContractHeaderId			= intContractHeaderId
				   , @intItemId						= intItemId
				   , @intContractSeq				= intContractSeq
				   , @intInventoryShipmentItemId	= intInventoryShipmentItemId
				   , @intTicketId					= intTicketId
				   , @dtmDate						= dtmDate
				   , @strDocumentNumber				= strDocumentNumber
		FROM #INVOICEDETAILS

		--UPDATE INVOICE DETAIL QTY SHIPPED = AVAILABLE CONTRACT QTY
		UPDATE ID
		SET dblQtyShipped	= ISI.dblQuantity
		  , dblUnitQuantity	= ISI.dblQuantity
		  , @dblQtyOverAged	= @dblNetWeight - ISI.dblQuantity
		FROM tblARInvoiceDetail ID
		INNER JOIN tblICInventoryShipmentItem ISI ON ID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId AND ID.intTicketId = ISI.intSourceId
		WHERE ID.intInvoiceDetailId = @intInvoiceDetailId
				
		IF @dblQtyOverAged > 0
			BEGIN
				IF(OBJECT_ID('tempdb..#AVAILABLECONTRACTS') IS NOT NULL)
				BEGIN
					DROP TABLE #AVAILABLECONTRACTS
				END

				IF(OBJECT_ID('tempdb..#AVAILABLECONTRACTSBYCUSTOMER') IS NOT NULL)
				BEGIN
					DROP TABLE #AVAILABLECONTRACTSBYCUSTOMER
				END

				--GET NEXT AVAILABLE CONTRACT WITHIN CONTRACT
				SELECT intContractDetailId
					 , intContractSeq
					 , dblBalance
				INTO #AVAILABLECONTRACTS
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader C ON CD.intContractHeaderId = C.intContractHeaderId
				WHERE CD.intContractHeaderId = @intContractHeaderId
				  AND CD.intContractSeq > @intContractSeq
				  AND CD.intItemId = @intItemId
				  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDate))) BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmStartDate))) AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmEndDate))) 
				  AND C.intEntityId = @intEntityCustomerId
				  AND CD.intCompanyLocationId = @intCompanyLocationId
				  AND CD.dblBalance > 0
				ORDER BY CD.intContractSeq

				WHILE EXISTS (SELECT TOP 1 NULL FROM #AVAILABLECONTRACTS)
					BEGIN
						DECLARE @intContractDetailIdAC	INT = NULL
							  , @dblQtyToApplyAC		NUMERIC(18, 6) = 0

						SELECT TOP 1 @intContractDetailIdAC		= intContractDetailId								    
								   , @dblQtyToApplyAC			= CASE WHEN dblBalance > @dblQtyOverAged THEN @dblQtyOverAged ELSE dblBalance END
						FROM #AVAILABLECONTRACTS ORDER BY intContractSeq

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= @intContractDetailIdAC
							 , intContractHeaderId	= @intContractHeaderId
							 , intTicketId			= NULL
							 , intItemId			= NULL
							 , intItemUOMId			= NULL
							 , dblQtyShipped		= @dblQtyToApplyAC
							 , dblPrice				= 0
							 , ysnCharge			= CAST(0 AS BIT)

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= @intContractDetailIdAC
							 , intContractHeaderId	= @intContractHeaderId
							 , intTicketId			= NULL
							 , intItemId			= intItemId
							 , intItemUOMId			= intItemUOMId
							 , dblQtyShipped		= 1
							 , dblPrice				= dbo.fnSCCalculateDiscount(@intTicketForDiscountId, intTicketDiscountId, @dblQtyToApplyAC, intItemUOMId, 0) * -1
							 , ysnCharge			= CAST(1 AS BIT)
						FROM #SHIPMENTCHARGES

						SET @dblQtyOverAged = @dblQtyOverAged - @dblQtyToApplyAC

						IF @dblQtyOverAged = 0
							DELETE FROM #AVAILABLECONTRACTS
						ELSE
							DELETE FROM #AVAILABLECONTRACTS WHERE intContractDetailId = @intContractDetailIdAC
					END

				--GET NEXT AVAILABLE CONTRACT BY CUSTOMER
				IF @dblQtyOverAged > 0
					BEGIN
						SELECT CD.intContractDetailId
							 , CD.intContractHeaderId
							 , CD.dblBalance
						INTO #AVAILABLECONTRACTSBYCUSTOMER
						FROM tblCTContractDetail CD
						INNER JOIN tblCTContractHeader C ON CD.intContractHeaderId = C.intContractHeaderId
						WHERE CD.intItemId = @intItemId
						  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDate))) BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmStartDate))) AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmEndDate)))
						  AND C.intEntityId = @intEntityCustomerId
						  AND CD.intCompanyLocationId = @intCompanyLocationId
						  AND CD.dblBalance > 0
						  AND C.intContractHeaderId > @intContractHeaderId
						ORDER BY C.intContractHeaderId

						WHILE EXISTS (SELECT TOP 1 NULL FROM #AVAILABLECONTRACTSBYCUSTOMER)
							BEGIN
								DECLARE @intContractDetailIdACBC	INT = NULL
									  , @intContractHeaderIdACBC	INT = NULL
								      , @dblQtyToApplyACBC			NUMERIC(18, 6) = 0

								SELECT TOP 1 @intContractDetailIdACBC = intContractDetailId
										   , @intContractHeaderIdACBC = intContractHeaderId
										   , @dblQtyToApplyACBC		  = CASE WHEN dblBalance > @dblQtyOverAged THEN @dblQtyOverAged ELSE dblBalance END
								FROM #AVAILABLECONTRACTSBYCUSTOMER ORDER BY intContractHeaderId

								INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
								SELECT intInvoiceDetailId	= @intInvoiceDetailId
									 , intContractDetailId	= @intContractDetailIdACBC
									 , intContractHeaderId	= @intContractHeaderIdACBC
									 , intTicketId			= NULL
									 , intItemId			= NULL
									 , intItemUOMId			= NULL
									 , dblQtyShipped		= @dblQtyToApplyACBC
									 , dblPrice				= 0
									 , ysnCharge			= CAST(0 AS BIT)

								INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
								SELECT intInvoiceDetailId	= @intInvoiceDetailId
									 , intContractDetailId	= @intContractDetailIdACBC
									 , intContractHeaderId	= @intContractHeaderIdACBC
									 , intTicketId			= NULL
									 , intItemId			= intItemId
									 , intItemUOMId			= intItemUOMId
									 , dblQtyShipped		= 1
									 , dblPrice				= dbo.fnSCCalculateDiscount(@intTicketForDiscountId, intTicketDiscountId, @dblQtyOverAged, intItemUOMId, 0) * -1
									 , ysnCharge			= CAST(1 AS BIT)
								FROM #SHIPMENTCHARGES

								SET @dblQtyOverAged = @dblQtyOverAged - @dblQtyToApplyACBC

								IF @dblQtyOverAged = 0
									DELETE FROM #AVAILABLECONTRACTSBYCUSTOMER
								ELSE
									DELETE FROM #AVAILABLECONTRACTSBYCUSTOMER WHERE intContractDetailId = @intContractDetailIdACBC
							END
					END				

				--ADD INVOICE DETAIL LINE WITHOUT CONTRACT AND INVENTORY SHIPMENT LINK
				IF @dblQtyOverAged > 0
					BEGIN
						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= NULL
							 , intContractHeaderId	= NULL
							 , intTicketId			= NULL
							 , intItemId			= NULL
							 , intItemUOMId			= NULL
							 , dblQtyShipped		= @dblQtyOverAged
							 , dblPrice				= 0
							 , ysnCharge			= CAST(0 AS BIT)

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= NULL
							 , intContractHeaderId	= NULL
							 , intTicketId			= NULL
							 , intItemId			= intItemId
							 , intItemUOMId			= intItemUOMId
							 , dblQtyShipped		= 1
							 , dblPrice				= dbo.fnSCCalculateDiscount(@intTicketForDiscountId, intTicketDiscountId, @dblQtyOverAged, intItemUOMId, 0) * -1
							 , ysnCharge			= CAST(1 AS BIT)
						FROM #SHIPMENTCHARGES

						SET @dblQtyOverAged = 0
					END
			END
		
		DELETE FROM #INVOICEDETAILS WHERE intInvoiceDetailId = @intInvoiceDetailId
	END

--ADD OVERRAGED ITEMS TO INVOICE DETAILS
IF EXISTS (SELECT TOP 1 NULL FROM #INVOICEDETAILSTOADD)
	BEGIN
		DECLARE @tblInvoiceDetailEntries	InvoiceStagingTable
		
		INSERT INTO @tblInvoiceDetailEntries (
			  intInvoiceDetailId
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
			, dblContractPriceUOMQty
			, intItemWeightUOMId
			, intContractDetailId
			, intContractHeaderId
			, intTicketId
			, intTaxGroupId
			, dblCurrencyExchangeRate
		)
		SELECT intInvoiceDetailId			= NULL
		    , strSourceTransaction			= 'Direct'
			, strSourceId					= ''
			, intEntityCustomerId			= ID.intEntityCustomerId
			, intCompanyLocationId			= ID.intCompanyLocationId
			, dtmDate						= ID.dtmDate
			, intEntityId					= ID.intEntityId
			, intInvoiceId					= @intInvoiceId
			, intItemId						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemId ELSE IDTOADD.intItemId END
			, strItemDescription			= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.strItemDescription ELSE ITEM.strDescription END
			, intOrderUOMId					= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intOrderUOMId ELSE NULL END
			, dblQtyOrdered					= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.dblQtyOrdered ELSE 1 END
			, intItemUOMId					= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemUOMId ELSE IDTOADD.intItemUOMId END
			, intPriceUOMId					= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intPriceUOMId ELSE IDTOADD.intItemUOMId END
			, dblQtyShipped					= IDTOADD.dblQtyShipped
			, dblPrice						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.dblPrice ELSE IDTOADD.dblPrice END
			, dblUnitPrice					= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.dblUnitPrice ELSE IDTOADD.dblPrice END
			, dblContractPriceUOMQty		= IDTOADD.dblQtyShipped
			, intItemWeightUOMId			= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemWeightUOMId ELSE NULL END
			, intContractDetailId			= IDTOADD.intContractDetailId
			, intContractHeaderId			= IDTOADD.intContractHeaderId
			, intTicketId					= IDTOADD.intTicketId
			, intTaxGroupId					= ID.intTaxGroupId
			, dblCurrencyExchangeRate		= ID.dblCurrencyExchangeRate
		FROM #INVOICEDETAILSTOADD IDTOADD
		CROSS APPLY (
			SELECT TOP 1 ID.*
					   , I.intCompanyLocationId
					   , I.intEntityCustomerId
					   , I.dtmDate 
					   , I.intEntityId
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			WHERE intInvoiceDetailId = IDTOADD.intInvoiceDetailId
		) ID
		LEFT JOIN tblICItem ITEM ON ITEM.intItemId = CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemId ELSE IDTOADD.intItemId END
				
		EXEC dbo.uspARAddItemToInvoices @InvoiceEntries		= @tblInvoiceDetailEntries
									  , @IntegrationLogId	= NULL
									  , @UserId				= @intUserId
	END

--UPDATE INVOICE INTEGRATION
WHILE EXISTS (SELECT TOP 1 NULL FROM #INVOICEIDS)
	BEGIN
		DECLARE @intInvoiceToUpdate INT = NULL
			  , @intEntityUserId	INT = NULL
	
		SELECT TOP 1 @intInvoiceToUpdate = intInvoiceId
				   , @intEntityUserId	 = intEntityId
		FROM #INVOICEIDS

		EXEC dbo.uspARUpdateInvoiceIntegrations @intInvoiceToUpdate, 0, @intEntityUserId

		DELETE FROM #INVOICEIDS WHERE intInvoiceId = @intInvoiceId
	END

--RECOMPUTE INVOICE AMOUNTS
EXEC dbo.uspARReComputeInvoicesTaxes @tblInvoiceIds