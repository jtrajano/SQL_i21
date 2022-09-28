CREATE PROCEDURE [dbo].[uspGRPurchaseSalesSummaryReport]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY

	-- Start extracting parameters from XML
	DECLARE @xmlDocumentId INT
	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT, @xmlParam

	DECLARE @temp_xml_table TABLE 
	(  
		[fieldname]		NVARCHAR(50),
		condition		NVARCHAR(20),
		[from]			NVARCHAR(50),
		[to]			NVARCHAR(50),
		[join]			NVARCHAR(10),
		[begingroup]	NVARCHAR(50),
		[endgroup]		NVARCHAR(50),
		[datatype]		NVARCHAR(50)
	)

	INSERT INTO @temp_xml_table
	SELECT *  
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
	WITH (  
		[fieldname]		NVARCHAR(50),
		[condition]		NVARCHAR(20),
		[from]			NVARCHAR(50),
		[to]			NVARCHAR(50),
		[join]			NVARCHAR(10),
		[begingroup]	NVARCHAR(50),
		[endgroup]		NVARCHAR(50),
		[datatype]		NVARCHAR(50)
	)

	DECLARE
		@dtmDeliveryDateFromParam DATETIME
		,@dtmDeliveryDateToParam DATETIME
		,@ysnIncludeInterLocationTransfers BIT
		,@ysnPrintConsolidatedTotals BIT
	
	DECLARE @tblLocationId Id
	DECLARE @tblEntityId Id
	DECLARE @tblCommodityId Id
	DECLARE @tblMarketZoneId Id

	SELECT @dtmDeliveryDateFromParam = ISNULL([from], DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDeliveryDate'

	SELECT @dtmDeliveryDateToParam = ISNULL([to], GETDATE())
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDeliveryDate'

	SELECT TOP 1 @ysnIncludeInterLocationTransfers = CONVERT(BIT, [from])
	FROM @temp_xml_table WHERE [fieldname] = 'ysnIncludeInterLocationTransfers'

	SELECT TOP 1 @ysnPrintConsolidatedTotals = CONVERT(BIT, [from])
	FROM @temp_xml_table WHERE [fieldname] = 'ysnPrintConsolidatedTotals'


	IF EXISTS (SELECT 1 FROM @temp_xml_table X WHERE [fieldname] = 'strLocationName')
		INSERT INTO @tblLocationId
		SELECT Z.intCompanyLocationId FROM @temp_xml_table X
		INNER JOIN tblSMCompanyLocation Z ON Z.strLocationName = [from] COLLATE Latin1_General_CI_AS
		WHERE [fieldname] = 'strLocationName'
	ELSE
		INSERT INTO @tblLocationId
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation

	INSERT INTO @tblEntityId
	SELECT Z.intEntityId FROM @temp_xml_table X
	INNER JOIN tblEMEntity Z ON Z.strName = [from] COLLATE Latin1_General_CI_AS
	WHERE [fieldname] = 'strEntityName'

	IF EXISTS (SELECT 1 FROM @temp_xml_table X WHERE [fieldname] = 'strCommodityCode')
		INSERT INTO @tblCommodityId
		SELECT Z.intCommodityId FROM @temp_xml_table X
		INNER JOIN tblICCommodity Z ON Z.strCommodityCode = X.[from] COLLATE Latin1_General_CI_AS
		WHERE [fieldname] = 'strCommodityCode'
	ELSE
		INSERT INTO @tblCommodityId
		SELECT intCommodityId
		FROM tblICCommodity

	INSERT INTO @tblMarketZoneId
	SELECT Z.intMarketZoneId FROM @temp_xml_table X
	INNER JOIN tblARMarketZone Z ON Z.strMarketZoneCode = [from] COLLATE Latin1_General_CI_AS
	WHERE [fieldname] = 'strMarketZoneCode'

	-- End extraction of parameters from XML

	-- PURCHASE CTE
	;WITH MainCTE AS (
		SELECT
			[intCompanyLocationId]				= CL.intCompanyLocationId
			,[intCommodityId]					= CM.intCommodityId
			,[strUnitMeasure]					= UM.strSymbol
		FROM tblSMCompanyLocation CL
		OUTER APPLY tblICCommodity CM
		LEFT JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityId = CM.intCommodityId AND CUOM.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUOM.intUnitMeasureId
		WHERE CL.intCompanyLocationId IN (SELECT intId FROM @tblLocationId)
		AND CM.intCommodityId IN (SELECT intId FROM @tblCommodityId)
	),	
	PurchaseCTE AS (
		SELECT
			[intCommodityId]					= MC.intCommodityId
			,[intCompanyLocationId]				= MC.intCompanyLocationId
			,[strUnitMeasure]					= MC.strUnitMeasure
			-- Inbound Units
			,[dblPurchaseGrainDP]				= ISNULL(INBOUND.dblPurchaseGrainDP, 0)
			,[dblPurchaseGrainOS]				= ISNULL(INBOUND.dblPurchaseGrainOS, 0)
			,[dblPurchaseGrainTransfer]			= ISNULL(TRANS.dblPurchaseGrainTransfer, 0)
			,[dblPurchaseGrainContract]			= ISNULL(INBOUND.dblPurchaseGrainContract, 0)
			,[dblPurchaseGrainSpot]				= ISNULL(INBOUND.dblPurchaseGrainSpot, 0)

			-- Paid Units
			,[dblPurchasePaidUnitsDP]			= ISNULL(PAID_TICKET.dblPurchasePaidUnitsDP, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsDP, 0)
			,[dblPurchasePaidUnitsContract]		= ISNULL(PAID_TICKET.dblPurchasePaidUnitsContract, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsContract, 0)
			,[dblPurchasePaidUnitsSpot]			= ISNULL(PAID_TICKET.dblPurchasePaidUnitsSpot, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsSpot, 0)

			-- Paid Amounts
			,[dblPurchasePaidAmountDP]			= ISNULL(PAID_TICKET.dblPurchasePaidAmountDP, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidAmountDP, 0)
			,[dblPurchasePaidAmountContract]	= ISNULL(PAID_TICKET.dblPurchasePaidAmountContract, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidAmountContract, 0)
			,[dblPurchasePaidAmountSpot]		= ISNULL(PAID_TICKET.dblPurchasePaidAmountSpot, 0) + ISNULL(PAID_STORAGE.dblPurchasePaidAmountSpot, 0)

			-- Adjustments
			,[dblPurchaseAdjustment]			= 0

			,[dblPurchaseStorageEarnedDP]		= 0
			,[dblPurchaseStorageEarnedOS]		= 0
		FROM MainCTE MC
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IR.intLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblPurchaseGrainDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN ISNULL(IRI.dblNet, 0) ELSE 0 END)
				,[dblPurchaseGrainOS]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 0 THEN IRI.dblNet ELSE 0 END)
				,[dblPurchaseGrainContract]		=	SUM(CASE WHEN IRI.intContractDetailId IS NOT NULL THEN IRI.dblNet ELSE 0 END)
				,[dblPurchaseGrainSpot]			=	SUM(CASE WHEN IRI.intContractDetailId IS NULL AND IRI.intOwnershipType = 1 THEN IRI.dblNet ELSE 0 END)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblICInventoryReceiptItem IRI
				ON IRI.intSourceId = T.intTicketId
				AND T.intItemId = IRI.intItemId
			INNER JOIN tblICInventoryReceipt IR
				ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
				AND IR.intSourceType = 1
			LEFT JOIN tblGRCustomerStorage CS
				ON CS.intTicketId = T.intTicketId
				AND CS.ysnTransferStorage = 0
			LEFT JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
			GROUP BY IR.intLocationId, I.intCommodityId
		) INBOUND
			ON MC.intCommodityId = INBOUND.intCommodityId
			AND MC.intCompanyLocationId = INBOUND.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IT.intToLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblPurchaseGrainTransfer]		=	SUM(T.dblNetUnits)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblSCTicketType TT
				ON TT.intTicketTypeId = T.intTicketTypeId
			INNER JOIN tblSCTicket MT
				ON MT.intTicketId = T.intMatchTicketId
			INNER JOIN tblICInventoryTransferDetail TD
				ON TD.intInventoryTransferId = MT.intInventoryTransferId
			INNER JOIN tblICInventoryTransfer IT
				ON IT.intInventoryTransferId = TD.intInventoryTransferId
			WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND TT.intListTicketTypeId = 3 -- Transfer In
				AND IT.ysnPosted = 1
			GROUP BY IT.intToLocationId, I.intCommodityId		
		) TRANS
			ON MC.intCommodityId = TRANS.intCommodityId
			AND MC.intCompanyLocationId = TRANS.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]				=	IR.intLocationId
				,[intCommodityId]					=	I.intCommodityId
				-- Paid Units
				,[dblPurchasePaidUnitsDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				,[dblPurchasePaidUnitsContract]		=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				,[dblPurchasePaidUnitsSpot]			=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				-- Paid Amounts
				,[dblPurchasePaidAmountDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN BD.dblTotal+ BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountContract]	=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountSpot]		=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblICInventoryReceiptItem IRI
				ON IRI.intSourceId = T.intTicketId
				AND T.intItemId = IRI.intItemId
			INNER JOIN tblICInventoryReceipt IR
				ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
				AND IR.intSourceType = 1
			INNER JOIN tblAPBillDetail BD
				ON BD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
				AND BD.intItemId = IRI.intItemId
			INNER JOIN tblAPBill B
				ON B.intBillId = BD.intBillId
			INNER JOIN tblAPPaymentDetail PD
				ON PD.intBillId = B.intBillId
			INNER JOIN tblAPPayment P
				ON P.intPaymentId = PD.intPaymentId
			LEFT JOIN tblGRCustomerStorage CS
				ON CS.intTicketId = T.intTicketId
				AND CS.ysnTransferStorage = 0
			LEFT JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND P.ysnPosted = 1
			GROUP BY IR.intLocationId, I.intCommodityId		
		) PAID_TICKET
			ON MC.intCommodityId = PAID_TICKET.intCommodityId
			AND MC.intCompanyLocationId = PAID_TICKET.intCompanyLocationId
		OUTER APPLY (
			SELECT
				-- Paid Units
				[dblPurchasePaidUnitsDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				,[dblPurchasePaidUnitsContract]		=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				,[dblPurchasePaidUnitsSpot]			=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN
															CASE 
																WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																ELSE BD.dblNetWeight
															END
														ELSE 0 END)
				-- Paid Amounts
				,[dblPurchasePaidAmountDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN BD.dblTotal+ BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountContract]	=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountSpot]		=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)
			FROM tblGRSettleStorage SS
			INNER JOIN tblGRSettleStorageTicket SST
				ON SST.intSettleStorageId = SS.intSettleStorageId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = SST.intCustomerStorageId
				AND CS.ysnTransferStorage = 0
			INNER JOIN tblICItem I
				ON I.intItemId = CS.intItemId
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			INNER JOIN tblGRSettleStorageBillDetail SSBD
				ON SSBD.intSettleStorageId = SS.intSettleStorageId
			INNER JOIN tblAPBill B
				ON B.intBillId = SSBD.intBillId
			INNER JOIN tblAPBillDetail BD
				ON BD.intBillId = B.intBillId
				AND BD.intSettleStorageId = SS.intSettleStorageId
				AND BD.intCustomerStorageId = CS.intCustomerStorageId
				AND BD.intItemId = CS.intItemId
			INNER JOIN tblAPPaymentDetail PD
				ON PD.intBillId = B.intBillId
			INNER JOIN tblAPPayment P
				ON P.intPaymentId = PD.intPaymentId			
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND ST.ysnDPOwnedType = 0
				AND P.ysnPosted = 1
				AND MC.intCommodityId = I.intCommodityId
				AND MC.intCompanyLocationId = SS.intCompanyLocationId
		) PAID_STORAGE
		-- OUTER APPLY (

		-- ) STORAGE_EARNED
	),
	-- SALES CTE
	SalesCTE AS (
		SELECT
			[intCompanyLocationId]				= MC.intCompanyLocationId
			,[intCommodityId]					= MC.intCommodityId

			,[dblSalesGrainTransfer]			= ISNULL(TRANS.dblSalesGrainTransfer, 0)
			,[dblSalesGrainContract]			= ISNULL(OUTBOUND.dblSalesGrainContract, 0)
			,[dblSalesGrainSpot]				= ISNULL(OUTBOUND.dblSalesGrainSpot, 0)

			-- Paid Units
			,[dblSalesPaidUnitsContract]		= ISNULL(PAID_TICKET.dblSalesPaidUnitsContract, 0)
			,[dblSalesPaidUnitsSpot]			= ISNULL(PAID_TICKET.dblSalesPaidUnitsSpot, 0)

			-- Paid Amounts
			,[dblSalesPaidAmountContract]		= ISNULL(PAID_TICKET.dblSalesPaidAmountContract, 0)
			,[dblSalesPaidAmountSpot]			= ISNULL(PAID_TICKET.dblSalesPaidAmountSpot, 0)

			-- Adjustments
			,[dblSalesAdjustment]				= 0
		FROM PurchaseCTE MC
		LEFT JOIN (
			SELECT
				[intCommodityId]				=	CO.intCommodityId
				,[intCompanyLocationId]			=	S.intShipFromLocationId
				,[dblSalesGrainContract]		=	SUM(CASE WHEN CD.intContractDetailId IS NOT NULL THEN SI.dblQuantity ELSE 0 END)
				,[dblSalesGrainSpot]			=	SUM(CASE WHEN CD.intContractDetailId IS NULL THEN SI.dblQuantity ELSE 0 END)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblICCommodity CO
				ON CO.intCommodityId = I.intCommodityId
			INNER JOIN tblICInventoryShipmentItem SI
				ON SI.intSourceId = T.intTicketId
				AND T.intItemId = SI.intItemId
			INNER JOIN tblICInventoryShipment S
				ON S.intInventoryShipmentId = SI.intInventoryShipmentId
				AND S.intSourceType = 1
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = SI.intOrderId
				AND CD.intContractDetailId = SI.intLineNo
			WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (CD.intMarketZoneId IS NULL
					OR (CD.intMarketZoneId IS NOT NULL AND CD.intMarketZoneId IN (SELECT intId FROM @tblMarketZoneId)))
				AND ((EXISTS(SELECT 1 FROM @tblEntityId) AND S.intEntityCustomerId IN (SELECT intId FROM @tblEntityId))
					OR NOT EXISTS (SELECT 1 FROM @tblEntityId)
				)
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) OUTBOUND
			ON MC.intCommodityId = OUTBOUND.intCommodityId
			AND MC.intCompanyLocationId = OUTBOUND.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IT.intToLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblSalesGrainTransfer]		=	-SUM(MT.dblNetUnits)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblSCTicketType TT
				ON TT.intTicketTypeId = T.intTicketTypeId
			INNER JOIN tblSCTicket MT
				ON MT.intTicketId = T.intMatchTicketId
			INNER JOIN tblICInventoryTransferDetail TD
				ON TD.intInventoryTransferId = MT.intInventoryTransferId
			INNER JOIN tblICInventoryTransfer IT
				ON IT.intInventoryTransferId = TD.intInventoryTransferId
			WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND TT.intListTicketTypeId = 3 -- Transfer In
				AND IT.ysnPosted = 1
			GROUP BY IT.intToLocationId, I.intCommodityId
		) TRANS
			ON MC.intCommodityId = TRANS.intCommodityId
			AND MC.intCompanyLocationId = TRANS.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]				=	S.intShipFromLocationId
				,[intCommodityId]					=	CO.intCommodityId
				-- Paid Units
				,[dblSalesPaidUnitsContract]		=	SUM(CASE WHEN ID.intContractDetailId IS NOT NULL THEN ID.dblQtyShipped ELSE 0 END)
				,[dblSalesPaidUnitsSpot]			=	SUM(CASE WHEN ID.intContractDetailId IS NULL THEN ID.dblQtyShipped ELSE 0 END)
				-- Paid Amounts
				,[dblSalesPaidAmountContract]	=	SUM(CASE WHEN ID.intContractDetailId IS NOT NULL THEN ID.dblTotal + ID.dblTotalTax ELSE 0 END)
				,[dblSalesPaidAmountSpot]		=	SUM(CASE WHEN ID.intContractDetailId IS NULL THEN ID.dblTotal + ID.dblTotalTax ELSE 0 END)
			FROM tblSCTicket T
			INNER JOIN tblICItem I
				ON I.intItemId = T.intItemId
			INNER JOIN tblICCommodity CO
				ON CO.intCommodityId = I.intCommodityId
			INNER JOIN tblICInventoryShipmentItem SI
				ON SI.intSourceId = T.intTicketId
				AND T.intItemId = SI.intItemId
			INNER JOIN tblICInventoryShipment S
				ON S.intInventoryShipmentId = SI.intInventoryShipmentId
				AND S.intSourceType = 1
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = SI.intOrderId
				AND CD.intContractDetailId = SI.intLineNo
			INNER JOIN tblARInvoiceDetail ID
				ON ID.intInventoryShipmentItemId = SI.intInventoryShipmentItemId
			INNER JOIN tblARInvoice INV
				ON INV.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblARPaymentDetail PD
				ON PD.intInvoiceId = INV.intInvoiceId
			INNER JOIN tblARPayment P
				ON P.intPaymentId = PD.intPaymentId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND P.ysnPosted = 1
				AND (CD.intMarketZoneId IS NULL
					OR (CD.intMarketZoneId IS NOT NULL AND CD.intMarketZoneId IN (SELECT intId FROM @tblMarketZoneId)))
				AND ((EXISTS(SELECT 1 FROM @tblEntityId) AND S.intEntityCustomerId IN (SELECT intId FROM @tblEntityId))
					OR NOT EXISTS (SELECT 1 FROM @tblEntityId)
				)
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) PAID_TICKET
			ON MC.intCommodityId = PAID_TICKET.intCommodityId
			AND MC.intCompanyLocationId = PAID_TICKET.intCompanyLocationId
	)
	-- MAIN QUERY
	SELECT
		[dtmDeliveryDateFrom]				= @dtmDeliveryDateFromParam
		,[dtmDeliveryDateTo]				= @dtmDeliveryDateToParam
		,[strLocationName]					= CL.strLocationNumber + ' ' + CL.strLocationName
		,[strCommodityCode]					= CM.strCommodityCode + ' - ' + CM.strDescription
		-- Purchase
		,[P].[intCommodityId]
		,[P].[intCompanyLocationId]
		,[P].[strUnitMeasure]
		,[P].[dblPurchaseGrainDP]
		,[P].[dblPurchaseGrainOS]
		,[P].[dblPurchaseGrainTransfer]
		,[P].[dblPurchaseGrainContract]
		,[P].[dblPurchaseGrainSpot]
		,[P].[dblPurchasePaidUnitsDP]
		,[P].[dblPurchasePaidUnitsContract]
		,[P].[dblPurchasePaidUnitsSpot]
		,[P].[dblPurchasePaidAmountDP]
		,[P].[dblPurchasePaidAmountContract]
		,[P].[dblPurchasePaidAmountSpot]
		,[P].[dblPurchaseAdjustment]
		,[P].[dblPurchaseStorageEarnedDP]
		,[P].[dblPurchaseStorageEarnedOS]
		-- Sales
		,[S].[dblSalesGrainTransfer]
		,[S].[dblSalesGrainContract]
		,[S].[dblSalesGrainSpot]
		,[S].[dblSalesPaidUnitsContract]
		,[S].[dblSalesPaidUnitsSpot]
		,[S].[dblSalesPaidAmountContract]
		,[S].[dblSalesPaidAmountSpot]
		,[S].[dblSalesAdjustment]
		-- XML
		,[strXML]							= @xmlParam
	FROM PurchaseCTE P
	LEFT JOIN SalesCTE S ON P.intCompanyLocationId = S.intCompanyLocationId AND P.intCommodityId = S.intCommodityId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = P.intCompanyLocationId
	LEFT JOIN tblICCommodity CM ON CM.intCommodityId = P.intCommodityId
	ORDER BY P.intCompanyLocationId, P.intCommodityId

END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH