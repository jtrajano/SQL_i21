CREATE PROCEDURE [dbo].[uspARUpdateOverageContracts]
	  @intInvoiceId			INT
	, @intScaleUOMId		INT = NULL
	, @intUserId			INT 
	, @dblNetWeight			NUMERIC(18, 6) = 0
	, @ysnFromSalesOrder	BIT = 0
	, @intTicketId   		INT = NULL
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
	 , intTicketId     				= ISNULL(ID.intTicketId, @intTicketId)
	 , strDocumentNumber			= ID.strDocumentNumber			
INTO #INVOICEDETAILS 
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
LEFT JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId AND ID.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
WHERE I.intInvoiceId = @intInvoiceId
  AND (ISNULL(@intTicketId, 0) = 0 OR (ISNULL(@intTicketId, 0) <> 0 AND @intTicketId = ISNULL(ID.intTicketId, 0)))
  AND ISNULL(CH.ysnLoad, 0) = 0

-- IF (SELECT COUNT(*) FROM #INVOICEDETAILS WHERE intContractDetailId IS NOT NULL) > 1
-- 	BEGIN
-- 		DECLARE @intContractHeaderIdToCompute	INT

-- 		SELECT TOP 1 @intContractHeaderIdToCompute = intContractHeaderId 
-- 		FROM #INVOICEDETAILS
-- 		ORDER BY intContractDetailId ASC

-- 		DELETE FROM #INVOICEDETAILS
-- 		WHERE intContractHeaderId <> @intContractHeaderIdToCompute

-- 		DELETE FROM tblARInvoiceDetail
-- 		WHERE intContractHeaderId <> @intContractHeaderIdToCompute
-- 		AND intInvoiceId = @intInvoiceId

-- 		UPDATE #INVOICEDETAILS
-- 		SET dblQtyShipped = @dblNetWeight
-- 		WHERE intContractHeaderId = @intContractHeaderIdToCompute
-- 		  AND intInventoryShipmentItemId IS NOT NULL

-- 		EXEC dbo.uspARUpdateInvoiceIntegrations @intInvoiceId, 0, @intUserId
-- 	END

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
GROUP BY SC.intTicketId, QM.intTicketDiscountId, IC.intCostUOMId, IC.intChargeId

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

IF ISNULL(@strInvalidItem, '') <> '' AND ISNULL(@ysnFromSalesOrder, 0) = 0
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
			  , @intItemUOMId				INT = NULL
			  , @intContractSeq				INT = NULL
			  , @intInventoryShipmentItemId	INT = NULL
			  , @dblQtyOverAged				NUMERIC(18, 6) = 0
			  , @dtmDate					DATETIME = NULL
			  , @strDocumentNumber			NVARCHAR(100) = NULL

		SELECT TOP 1 @intInvoiceDetailId			= intInvoiceDetailId
				   , @intCompanyLocationId			= intCompanyLocationId
				   , @intEntityCustomerId			= intEntityCustomerId
				   , @intContractDetailId			= intContractDetailId
				   , @intContractHeaderId			= intContractHeaderId
				   , @intItemId						= intItemId
				   , @intItemUOMId					= intItemUOMId
				   , @intContractSeq				= intContractSeq
				   , @intInventoryShipmentItemId	= intInventoryShipmentItemId
				   , @intTicketId					= intTicketId
				   , @dtmDate						= dtmDate
				   , @strDocumentNumber				= strDocumentNumber
		FROM #INVOICEDETAILS

		--UPDATE INVOICE DETAIL QTY SHIPPED = AVAILABLE CONTRACT QTY
		IF ISNULL(@ysnFromSalesOrder, 0) = 0
			BEGIN		
				UPDATE ID
				SET dblQtyShipped	= ISNULL(CASE WHEN ISI.dblDestinationQuantity > CTD.dblOriginalQty 
												THEN CTD.dblOriginalQty 
												ELSE 
													CASE WHEN ISI.dblQuantity < ISI.dblDestinationQuantity AND ISI.dblDestinationQuantity > (CTD.dblBalance + ISI.dblQuantity)
														THEN ISI.dblQuantity + CTD.dblBalance
														ELSE ISI.dblDestinationQuantity
													END
											END
									, ISI.dblQuantity)
				  , dblUnitQuantity	= ISNULL(CASE WHEN ISI.dblDestinationQuantity > CTD.dblOriginalQty 
												THEN CTD.dblOriginalQty 
												ELSE 
													CASE WHEN ISI.dblQuantity < ISI.dblDestinationQuantity AND ISI.dblDestinationQuantity > (CTD.dblBalance + ISI.dblQuantity)
														THEN ISI.dblQuantity + CTD.dblBalance
														ELSE ISI.dblDestinationQuantity
													END
											END
									, ISI.dblQuantity)
				  , @dblQtyOverAged	= @dblNetWeight - ISNULL(CASE WHEN ISI.dblDestinationQuantity > CTD.dblOriginalQty 
												THEN CTD.dblOriginalQty 
												ELSE 
													CASE WHEN ISI.dblQuantity < ISI.dblDestinationQuantity AND ISI.dblDestinationQuantity > (CTD.dblBalance + ISI.dblQuantity)
														THEN ISI.dblQuantity + CTD.dblBalance
														ELSE ISI.dblDestinationQuantity
													END
											END
									, ISI.dblQuantity)
				  , intTicketId  	= ISNULL(ID.intTicketId, @intTicketId)
				FROM tblARInvoiceDetail ID
				INNER JOIN tblICInventoryShipmentItem ISI ON ID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId AND ID.intTicketId = ISI.intSourceId
				INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId AND ID.intContractHeaderId = CTD.intContractHeaderId
				WHERE ID.intInvoiceDetailId = @intInvoiceDetailId
				  --AND ID.intInvoiceDetailId NOT IN (SELECT DISTINCT intInvoiceDetailId FROM tblCTPriceFixationDetailAPAR)
			END
		ELSE IF ISNULL(@ysnFromSalesOrder, 0) = 1 AND @intContractDetailId IS NOT NULL
			BEGIN
				DECLARE @intContractCount	INT = 0

				SELECT @intContractCount = COUNT(*)
				FROM tblSOSalesOrderDetail SOD
				LEFT JOIN tblARInvoiceDetail ID ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
				LEFT JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				WHERE SOD.intContractDetailId = @intContractDetailId
				  AND SOD.intContractDetailId IS NOT NULL
				  AND ISNULL(I.ysnPosted, 0) = 0

				-- 1. ORDERED = CONTRACT BALANCE
				--	1.1 TICKET < ORDERED
				--	1.2 TICKET > ORDERED
				-- 2. ORDERED < CONTRACT BALANCE
				-- 3. ORDERED = UNUSED CONTRACT IN #2
				UPDATE ID
				SET dblQtyShipped	= CASE WHEN ISNULL(@dblNetWeight, 0) > CTD.dblBalance --SCENARIO 
										   THEN 
												CASE WHEN CTD.dblBalance = CTD.dblQuantity AND CTD.dblScheduleQty = CTD.dblQuantity
													 THEN ID.dblQtyOrdered 
													 ELSE CTD.dblBalance 
												END
										   ELSE 
												CASE WHEN @dblNetWeight > ID.dblQtyOrdered AND ISNULL(@intContractCount, 0) > 1 --CONTRACT USED ON OTHER S.O. (INVOICE NOT POSTED YET)
										  	     	 THEN CTD.dblBalance - (CTD.dblScheduleQty - ID.dblQtyOrdered)
												 	 ELSE ISNULL(@dblNetWeight, 0) 
												END
									  END
				  , dblUnitQuantity	= CASE WHEN ISNULL(@dblNetWeight, 0) > CTD.dblBalance 
										   THEN 
												CASE WHEN CTD.dblBalance = CTD.dblQuantity AND CTD.dblScheduleQty = CTD.dblQuantity
													 THEN ID.dblQtyOrdered 
													 ELSE CTD.dblBalance 
												END
										   ELSE 
												CASE WHEN @dblNetWeight > ID.dblQtyOrdered AND ISNULL(@intContractCount, 0) > 1
										  	     	 THEN CTD.dblBalance - (CTD.dblScheduleQty - ID.dblQtyOrdered)
												 	 ELSE ISNULL(@dblNetWeight, 0) 
												END
									  END
				  , dblQtyOrdered	= CASE WHEN @dblNetWeight = 0 THEN CTD.dblBalance ELSE ID.dblQtyOrdered END
				  , intTicketId     = ISNULL(ID.intTicketId, @intTicketId)
				  , @dblQtyOverAged	= CASE WHEN @dblNetWeight > 0 
										   THEN ISNULL(@dblNetWeight, 0) - 
												CASE WHEN CTD.dblBalance = CTD.dblQuantity AND CTD.dblScheduleQty = CTD.dblQuantity
													 THEN ID.dblQtyOrdered 
													 ELSE CTD.dblBalance 
												END
											ELSE ID.dblQtyOrdered - CTD.dblBalance 
									  END					
				FROM tblARInvoiceDetail ID
				INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId AND ID.intContractHeaderId = CTD.intContractHeaderId				
				WHERE ID.intInvoiceDetailId = @intInvoiceDetailId
			END
		ELSE IF ISNULL(@ysnFromSalesOrder, 0) = 1 AND @intContractDetailId IS NULL
			BEGIN
				UPDATE ID
				SET dblQtyShipped	= ISNULL(dbo.fnCalculateQtyBetweenUOM(@intScaleUOMId, ID.intItemUOMId, @dblNetWeight), 0)
				  , dblUnitQuantity	= ISNULL(dbo.fnCalculateQtyBetweenUOM(@intScaleUOMId, ID.intItemUOMId, @dblNetWeight), 0)
				  , intTicketId  	= ISNULL(ID.intTicketId, @intTicketId)
				  , @dblQtyOverAged	= 0
				FROM tblARInvoiceDetail ID
				WHERE ID.intInvoiceDetailId = @intInvoiceDetailId
			END

		IF ISNULL(@ysnFromSalesOrder, 0) = 1
			BEGIN
				--UPDATE ADD ON ITEMS QTY.
				UPDATE ID
				SET dblQtyShipped	= PARENT.dblQtyShipped * dblAddOnQuantity
				  , dblUnitQuantity	= PARENT.dblQtyShipped * dblAddOnQuantity
				  , intTicketId  	= ISNULL(ID.intTicketId, @intTicketId)
				FROM tblARInvoiceDetail ID
				CROSS APPLY (
					SELECT TOP 1 intItemId
							   , intCompanyLocationId
							   , dblQtyOrdered
							   , dblQtyShipped 
					FROM tblARInvoiceDetail ADDON
					INNER JOIN tblARInvoice I ON ADDON.intInvoiceId = I.intInvoiceId
					WHERE ADDON.strAddonDetailKey = ID.strAddonDetailKey
					  AND ISNULL(ADDON.ysnAddonParent, 0) = 1
					  AND I.intInvoiceId = @intInvoiceId
				) PARENT
				INNER JOIN vyuARGetAddOnItems ADDONITEMS ON ID.intItemId = ADDONITEMS.intComponentItemId
														AND PARENT.intItemId = ADDONITEMS.intItemId
														AND PARENT.intCompanyLocationId = ADDONITEMS.intCompanyLocationId
				WHERE ID.intContractDetailId IS NULL 
				  AND ID.intContractHeaderId IS NULL
				  AND ISNULL(ID.ysnAddonParent, 0) = 0
				  AND ID.intInvoiceId = @intInvoiceId
			END
				
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
				SELECT intContractDetailId	= CD.intContractDetailId
					 , intContractSeq		= CD.intContractSeq
					 , dblBalance			= CD.dblBalance - ISNULL(CD.dblScheduleQty, 0)
					 , dblCashPrice			= CD.dblCashPrice
				INTO #AVAILABLECONTRACTS
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader C ON CD.intContractHeaderId = C.intContractHeaderId
				WHERE CD.intContractHeaderId = @intContractHeaderId
				  AND CD.intContractSeq > @intContractSeq
				  AND CD.intItemId = @intItemId
				  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDate))) BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmStartDate))) AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmEndDate))) 
				  AND C.intEntityId = @intEntityCustomerId
				  AND CD.intCompanyLocationId = @intCompanyLocationId
				  AND CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) > 0
				  AND C.intPricingTypeId <> 2
				ORDER BY CD.intContractSeq

				WHILE EXISTS (SELECT TOP 1 NULL FROM #AVAILABLECONTRACTS)
					BEGIN
						DECLARE @intContractDetailIdAC	INT = NULL
							  , @dblQtyToApplyAC		NUMERIC(18, 6) = 0
							  , @dblCashPriceAC			NUMERIC(18, 6) = 0

						SELECT TOP 1 @intContractDetailIdAC		= intContractDetailId								    
								   , @dblQtyToApplyAC			= CASE WHEN dblBalance > @dblQtyOverAged THEN @dblQtyOverAged ELSE dblBalance END
								   , @dblCashPriceAC			= dblCashPrice
						FROM #AVAILABLECONTRACTS ORDER BY intContractSeq

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= @intContractDetailIdAC
							 , intContractHeaderId	= @intContractHeaderId
							 , intTicketId			= @intTicketId
							 , intItemId			= NULL
							 , intItemUOMId			= NULL
							 , dblQtyShipped		= @dblQtyToApplyAC
							 , dblPrice				= @dblCashPriceAC
							 , ysnCharge			= CAST(0 AS BIT)

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= @intContractDetailIdAC
							 , intContractHeaderId	= @intContractHeaderId
							 , intTicketId			= @intTicketId
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
						SELECT intContractDetailId	= CD.intContractDetailId
							 , intContractHeaderId	= CD.intContractHeaderId
							 , dblBalance			= CD.dblBalance - ISNULL(CD.dblScheduleQty, 0)
							 , dblCashPrice			= CD.dblCashPrice
						INTO #AVAILABLECONTRACTSBYCUSTOMER
						FROM tblCTContractDetail CD
						INNER JOIN tblCTContractHeader C ON CD.intContractHeaderId = C.intContractHeaderId
						WHERE CD.intItemId = @intItemId
						  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDate))) BETWEEN CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmStartDate))) AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), CD.dtmEndDate)))
						  AND C.intEntityId = @intEntityCustomerId
						  AND CD.intCompanyLocationId = @intCompanyLocationId
						  AND CD.dblBalance - ISNULL(CD.dblScheduleQty, 0) > 0
						  AND C.intContractHeaderId > @intContractHeaderId
						  AND C.intPricingTypeId <> 2
						ORDER BY C.intContractHeaderId

						WHILE EXISTS (SELECT TOP 1 NULL FROM #AVAILABLECONTRACTSBYCUSTOMER)
							BEGIN
								DECLARE @intContractDetailIdACBC	INT = NULL
									  , @intContractHeaderIdACBC	INT = NULL
								      , @dblQtyToApplyACBC			NUMERIC(18, 6) = 0
									  , @dblCashPriceACBC			NUMERIC(18, 6) = 0

								SELECT TOP 1 @intContractDetailIdACBC = intContractDetailId
										   , @intContractHeaderIdACBC = intContractHeaderId
										   , @dblQtyToApplyACBC		  = CASE WHEN dblBalance > @dblQtyOverAged THEN @dblQtyOverAged ELSE dblBalance END
										   , @dblCashPriceACBC		  = dblCashPrice
								FROM #AVAILABLECONTRACTSBYCUSTOMER ORDER BY intContractHeaderId

								INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
								SELECT intInvoiceDetailId	= @intInvoiceDetailId
									 , intContractDetailId	= @intContractDetailIdACBC
									 , intContractHeaderId	= @intContractHeaderIdACBC
									 , intTicketId			= @intTicketId
									 , intItemId			= NULL
									 , intItemUOMId			= NULL
									 , dblQtyShipped		= @dblQtyToApplyACBC
									 , dblPrice				= @dblCashPriceACBC
									 , ysnCharge			= CAST(0 AS BIT)

								INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
								SELECT intInvoiceDetailId	= @intInvoiceDetailId
									 , intContractDetailId	= @intContractDetailIdACBC
									 , intContractHeaderId	= @intContractHeaderIdACBC
									 , intTicketId			= @intTicketId
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
							 , intTicketId			= @intTicketId
							 , intItemId			= @intItemId
							 , intItemUOMId			= @intItemUOMId
							 , dblQtyShipped		= @dblQtyOverAged
							 , dblPrice				= 0
							 , ysnCharge			= CAST(0 AS BIT)

						INSERT INTO #INVOICEDETAILSTOADD (intInvoiceDetailId, intContractDetailId, intContractHeaderId, intTicketId, intItemId, intItemUOMId, dblQtyShipped, dblPrice, ysnCharge)
						SELECT intInvoiceDetailId	= @intInvoiceDetailId
						     , intContractDetailId	= NULL
							 , intContractHeaderId	= NULL
							 , intTicketId			= @intTicketId
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
		DECLARE @strAddOnKey				NVARCHAR(100) = NEWID()

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
			, strAddonDetailKey
			, ysnAddonParent
			, intInventoryShipmentItemId
			, intStorageLocationId
			, intSubLocationId
			, intCompanyLocationSubLocationId
			, strDocumentNumber
		)
		SELECT intInvoiceDetailId				= NULL
		    , strSourceTransaction				= 'Direct'
			, strSourceId						= ''
			, intEntityCustomerId				= ID.intEntityCustomerId
			, intCompanyLocationId				= ID.intCompanyLocationId
			, dtmDate							= ID.dtmDate
			, intEntityId						= ID.intEntityId
			, intInvoiceId						= @intInvoiceId
			, intItemId							= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemId ELSE IDTOADD.intItemId END
			, strItemDescription				= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.strItemDescription ELSE ITEM.strDescription END
			, intOrderUOMId						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intOrderUOMId ELSE NULL END
			, dblQtyOrdered						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 1 THEN 0 ELSE CASE WHEN IDTOADD.dblPrice <> 0 THEN CTD.dblQuantity ELSE IDTOADD.dblQtyShipped END END
			, intItemUOMId						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemUOMId ELSE IDTOADD.intItemUOMId END
			, intPriceUOMId						= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intPriceUOMId ELSE IDTOADD.intItemUOMId END
			, dblQtyShipped						= IDTOADD.dblQtyShipped
			, dblPrice							= IDTOADD.dblPrice
			, dblUnitPrice						= IDTOADD.dblPrice
			, dblContractPriceUOMQty			= IDTOADD.dblQtyShipped
			, intItemWeightUOMId				= CASE WHEN ISNULL(IDTOADD.ysnCharge, 0) = 0 THEN ID.intItemWeightUOMId ELSE NULL END
			, intContractDetailId				= IDTOADD.intContractDetailId
			, intContractHeaderId				= IDTOADD.intContractHeaderId
			, intTicketId						= @intTicketId-- CASE WHEN IDTOADD.intContractDetailId IS NOT NULL AND ISNULL(@ysnFromSalesOrder, 0) = 0 THEN NULL ELSE IDTOADD.intTicketId END
			, intTaxGroupId						= ID.intTaxGroupId
			, dblCurrencyExchangeRate			= ID.dblCurrencyExchangeRate
			, strAddonDetailKey					= CASE WHEN ISNULL(ID.ysnAddonParent, 0) = 1 THEN @strAddOnKey ELSE NULL END
			, ysnAddonParent					= ISNULL(ID.ysnAddonParent, 0)
			, intInventoryShipmentItemId		= @intInventoryShipmentItemId-- CASE WHEN IDTOADD.intContractDetailId IS NOT NULL AND ISNULL(@ysnFromSalesOrder, 0) = 0 THEN NULL ELSE @intInventoryShipmentItemId END
			, intStorageLocationId				= ID.intStorageLocationId
			, intSubLocationId					= ID.intSubLocationId
			, intCompanyLocationSubLocationId	= ID.intCompanyLocationSubLocationId
			, strDocumentNumber					= ID.strDocumentNumber
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
		LEFT JOIN tblCTContractDetail CTD ON IDTOADD.intContractDetailId = CTD.intContractDetailId
		
		UNION ALL

		--GET AUTO-ADD, ADD-ON ITEMS
		SELECT intInvoiceDetailId				= NULL
		    , strSourceTransaction				= 'Direct'
			, strSourceId						= ''
			, intEntityCustomerId				= ID.intEntityCustomerId
			, intCompanyLocationId				= ID.intCompanyLocationId
			, dtmDate							= ID.dtmDate
			, intEntityId						= ID.intEntityId
			, intInvoiceId						= @intInvoiceId
			, intItemId							= ADDON.intComponentItemId
			, strItemDescription				= ADDON.strDescription
			, intOrderUOMId						= ADDON.intItemUnitMeasureId
			, dblQtyOrdered						= 0
			, intItemUOMId						= ADDON.intItemUnitMeasureId
			, intPriceUOMId						= ADDON.intItemUnitMeasureId
			, dblQtyShipped						= IDTOADD.dblQtyShipped * ADDON.dblQuantity
			, dblPrice							= ADDON.dblPrice
			, dblUnitPrice						= ADDON.dblPrice
			, dblContractPriceUOMQty			= 0
			, intItemWeightUOMId				= NULL
			, intContractDetailId				= NULL
			, intContractHeaderId				= NULL
			, intTicketId						= IDTOADD.intTicketId
			, intTaxGroupId						= ID.intTaxGroupId
			, dblCurrencyExchangeRate			= ID.dblCurrencyExchangeRate
			, strAddonDetailKey					= @strAddOnKey
			, ysnAddonParent					= CAST(0 AS BIT)
			, intInventoryShipmentItemId		= NULL
			, intStorageLocationId				= NULL
			, intSubLocationId					= NULL
			, intCompanyLocationSubLocationId	= NULL
			, strDocumentNumber					= ID.strDocumentNumber
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
		INNER JOIN vyuARGetAddOnItems ADDON ON IDTOADD.intItemId = ADDON.intItemId
										   AND ID.intCompanyLocationId = ADDON.intCompanyLocationId
		WHERE ADDON.ysnAutoAdd = 1		  
		  AND ISNULL(@ysnFromSalesOrder, 0) = 1

		--UPDATE ADD-ON QTY FOR NOT AUTO-ADD
		UPDATE ID 
		SET dblQtyShipped 	= ID.dblQtyShipped + dbo.fnRoundBanker((IDTOADD.dblQtyShipped * ADDON.dblQuantity), 6)
		  , dblUnitQuantity = ID.dblUnitQuantity + dbo.fnRoundBanker((IDTOADD.dblQtyShipped * ADDON.dblQuantity), 6)
		FROM tblARInvoiceDetail ID 
		INNER JOIN #INVOICEIDS INV ON ID.intInvoiceId = INV.intInvoiceId
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN vyuARGetAddOnItems ADDON ON ID.intItemId = ADDON.intComponentItemId
										   AND I.intCompanyLocationId = ADDON.intCompanyLocationId
		INNER JOIN #INVOICEDETAILSTOADD IDTOADD ON IDTOADD.intItemId = ADDON.intItemId
		WHERE ID.strAddonDetailKey IS NOT NULL
		  AND ISNULL(ID.ysnAddonParent, 0) = 0		  
		  AND ISNULL(@ysnFromSalesOrder, 0) = 1
		  AND ADDON.ysnAutoAdd = 0
		  		
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