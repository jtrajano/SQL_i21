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

	INSERT INTO @temp_xml_table
    SELECT *
    FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2) WITH 
    (
        [fieldname] NVARCHAR(50)
        ,condition NVARCHAR(20)
        ,[from] NVARCHAR(4000)
        ,[to] NVARCHAR(4000)
        ,[join] NVARCHAR(10)
        ,[begingroup] NVARCHAR(50)
        ,[endgroup] NVARCHAR(50)
        ,[datatype] NVARCHAR(50)
    )

	DECLARE @strReportLogId AS NVARCHAR(100)

    SELECT @strReportLogId = [from]
    FROM @temp_xml_table
    WHERE [fieldname] = 'strReportLogId'

    IF @strReportLogId IS NOT NULL
    BEGIN
        IF EXISTS (SELECT TOP 1 1 FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
        BEGIN
            RETURN
        END
        ELSE
        BEGIN
            INSERT INTO tblSRReportLog (strReportLogId, dtmDate) VALUES (@strReportLogId, GETUTCDATE())
        END
    END

	DECLARE
		@dtmDeliveryDateFromParam DATETIME
		,@dtmDeliveryDateToParam DATETIME
		,@ysnIncludeInterLocationTransfers BIT
		,@ysnPrintConsolidatedTotals BIT
	
	DECLARE @tblLocationId Id
	DECLARE @tblEntityId Id
	DECLARE @tblCommodityId Id
	DECLARE @tblItemId Id
	DECLARE @tblMarketZoneId Id

	SELECT @dtmDeliveryDateFromParam = ISNULL([from], DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDeliveryDate'

	SELECT @dtmDeliveryDateToParam = ISNULL(DATEADD(MILLISECOND, -3, ISNULL(CAST([to] AS DATETIME), CAST([from] AS DATETIME)) + 1), GETDATE())
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

	INSERT INTO @tblItemId
	SELECT Z.intItemId FROM @temp_xml_table X
	INNER JOIN tblICItem Z ON Z.strItemNo = X.[from] COLLATE Latin1_General_CI_AS
	WHERE [fieldname] = 'strItemNo'

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
		AND (
			(NOT EXISTS(SELECT 1 FROM @tblItemId) AND EXISTS (SELECT 1 FROM @tblCommodityId WHERE intId = CM.intCommodityId))
			OR EXISTS(SELECT 1 FROM @tblItemId) AND EXISTS (SELECT 1 FROM @tblItemId I INNER JOIN tblICItem IC ON IC.intItemId = I.intId WHERE IC.intCommodityId = CM.intCommodityId)
		)
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
			,[dblPurchaseAdjustment]			= ISNULL(ADJUSTMENT.dblPurchaseAdjustment, 0)

			,[dblPurchaseStorageEarnedDP]		= STORAGE_EARNED.dblPurchaseStorageEarnedDP
			,[dblPurchaseStorageEarnedOS]		= STORAGE_EARNED.dblPurchaseStorageEarnedOS

			-- WAP
			,[dblPurchaseBasisWAPNet]			=	(ISNULL(PAID_TICKET.dblPurchaseBasisTotal, 0) + ISNULL(PAID_STORAGE.dblPurchaseBasisTotal, 0)) / (ISNULL(PAID_TICKET.dblPurchasePaidUnitsNet, 1) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsNet, 1))
			,[dblPurchaseWAPGross]				=	(ISNULL(PAID_TICKET.dblPurchasePriceTotal, 0) + ISNULL(PAID_STORAGE.dblPurchasePriceTotal, 0)) / (ISNULL(PAID_TICKET.dblPurchasePaidUnitsGross, 1) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsGross, 1))
			,[dblPurchaseWAPNet]				=	(ISNULL(PAID_TICKET.dblPurchasePriceTotal, 0) + ISNULL(PAID_STORAGE.dblPurchasePriceTotal, 0)) / (ISNULL(PAID_TICKET.dblPurchasePaidUnitsNet, 1) + ISNULL(PAID_STORAGE.dblPurchasePaidUnitsNet, 1))
		FROM MainCTE MC
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IR.intLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblPurchaseGrainDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN ISNULL(IRI.dblNet, 0) ELSE 0 END)
				,[dblPurchaseGrainOS]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 0 THEN IRI.dblNet ELSE 0 END)
				,[dblPurchaseGrainContract]		=	SUM(CASE WHEN IRI.intContractDetailId IS NOT NULL AND ISNULL(ST.ysnDPOwnedType, 0) = 0 THEN IRI.dblNet ELSE 0 END)
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
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = IRI.intContractHeaderId
				AND CD.intContractDetailId = IRI.intContractDetailId
			WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE IRI.intItemId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE IR.intEntityVendorId = intId))
			GROUP BY IR.intLocationId, I.intCommodityId
		) INBOUND
			ON MC.intCommodityId = INBOUND.intCommodityId
			AND MC.intCompanyLocationId = INBOUND.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IR.intLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblPurchaseBasisTotal]		=	SUM(TSU.dblUnitBasis * IRI.dblNet)
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
			INNER JOIN tblSCTicketSpotUsed TSU
				ON TSU.intTicketId = T.intTicketId
				AND TSU.intEntityId = IR.intEntityVendorId
			INNER JOIN tblAPBillDetail BD
				ON BD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
				AND BD.intItemId = IRI.intItemId
			INNER JOIN tblAPBill B
				ON B.intBillId = BD.intBillId
			INNER JOIN tblAPPaymentDetail PD
				ON PD.intBillId = B.intBillId
			INNER JOIN tblAPPayment P
				ON P.intPaymentId = PD.intPaymentId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE IR.intEntityVendorId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE IRI.intItemId = intId))
			GROUP BY IR.intLocationId, I.intCommodityId
		) WAP_SPOT
			ON MC.intCommodityId = WAP_SPOT.intCommodityId
			AND MC.intCompanyLocationId = WAP_SPOT.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCompanyLocationId]			=	IR.intLocationId
				,[intCommodityId]				=	I.intCommodityId
				,[dblPurchaseBasisTotal]		=	SUM(IRI.dblNet * dbo.fnCalculateQtyBetweenUOM(CD.intBasisUOMId, IRI.intUnitMeasureId, CD.dblBasis))
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
			INNER JOIN tblCTContractDetail CD
				ON CD.intContractHeaderId = IRI.intContractHeaderId
				AND CD.intContractDetailId = IRI.intContractDetailId
			INNER JOIN tblAPBillDetail BD
				ON BD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
				AND BD.intItemId = IRI.intItemId
			INNER JOIN tblAPBill B
				ON B.intBillId = BD.intBillId
			INNER JOIN tblAPPaymentDetail PD
				ON PD.intBillId = B.intBillId
			INNER JOIN tblAPPayment P
				ON P.intPaymentId = PD.intPaymentId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE IR.intEntityVendorId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE IRI.intItemId = intId))
			GROUP BY IR.intLocationId, I.intCommodityId
		) WAP_CONTRACT
			ON MC.intCommodityId = WAP_CONTRACT.intCommodityId
			AND MC.intCompanyLocationId = WAP_CONTRACT.intCompanyLocationId
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
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
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
				,[dblPurchasePaidUnitsContract]		=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL AND ISNULL(ST.ysnDPOwnedType, 0) = 0 THEN
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
				,[dblPurchasePaidAmountContract]	=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL AND ISNULL(ST.ysnDPOwnedType, 0) = 0 THEN BD.dblTotal + BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountSpot]		=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)

				,[dblPurchaseBasisTotal]			=	SUM(
															CASE WHEN BD.intContractDetailId IS NOT NULL THEN
																CASE 
																	WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																	ELSE BD.dblNetWeight
																END
															ELSE 0 END
															*
															CASE WHEN CD.intContractDetailId IS NULL THEN 0 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intBasisUOMId, BD.intUnitOfMeasureId, CD.dblBasis) END
														)
				,[dblPurchasePriceTotal]			=	SUM(BD.dblTotal)

				,[dblPurchasePaidUnitsGross]		=	SUM(IRI.dblGross)
				,[dblPurchasePaidUnitsNet]			=	SUM(IRI.dblNet)
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
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractDetailId = BD.intContractDetailId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND P.ysnPosted = 1
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE IR.intEntityVendorId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
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
				,[dblPurchasePaidUnitsContract]		=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL AND ISNULL(ST.ysnDPOwnedType, 0) = 0 THEN
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
				,[dblPurchasePaidAmountContract]	=	SUM(CASE WHEN BD.intContractDetailId IS NOT NULL AND ISNULL(ST.ysnDPOwnedType, 0) = 0 THEN BD.dblTotal + BD.dblTax ELSE 0 END)
				,[dblPurchasePaidAmountSpot]		=	SUM(CASE WHEN BD.intContractDetailId IS NULL THEN BD.dblTotal + BD.dblTax ELSE 0 END)

				,[dblPurchaseBasisTotal]			=	SUM(
															CASE WHEN BD.intContractDetailId IS NOT NULL THEN
																CASE 
																	WHEN ISNULL(BD.intUnitOfMeasureId,0) > 0 AND ISNULL(BD.intCostUOMId,0) > 0 THEN dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,BD.intCostUOMId,BD.dblNetWeight) 
																	ELSE BD.dblNetWeight
																END
															ELSE 0 END
															*
															CASE WHEN CD.intContractDetailId IS NULL THEN SS.dblFuturesBasis ELSE dbo.fnCalculateQtyBetweenUOM(CD.intBasisUOMId, BD.intUnitOfMeasureId, CD.dblBasis) END
														)
				,[dblPurchasePriceTotal]			=	SUM(BD.dblTotal)

				,[dblPurchasePaidUnitsGross]		=	SUM(SST.dblUnits * (CS.dblGrossQuantity / CS.dblOriginalBalance))
				,[dblPurchasePaidUnitsNet]			=	SUM(SST.dblUnits)
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
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractDetailId = BD.intContractDetailId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND ST.ysnDPOwnedType = 0
				AND P.ysnPosted = 1
				AND MC.intCommodityId = I.intCommodityId
				AND MC.intCompanyLocationId = SS.intCompanyLocationId
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE B.intEntityVendorId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
		) PAID_STORAGE
		OUTER APPLY (
			SELECT
				[dblPurchaseStorageEarnedDP]			=	-SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN BD.dblTotal ELSE 0 END)
				,[dblPurchaseStorageEarnedOS]			=	-SUM(CASE WHEN ST.ysnDPOwnedType = 0 THEN BD.dblTotal ELSE 0 END)
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
			INNER JOIN tblICItem SC
				ON SC.strType = 'Other Charge' 
				AND SC.strCostType = 'Storage Charge'
				AND SC.intItemId = BD.intItemId
			INNER JOIN tblAPPaymentDetail PD
				ON PD.intBillId = B.intBillId
			INNER JOIN tblAPPayment P
				ON P.intPaymentId = PD.intPaymentId
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractDetailId = BD.intContractDetailId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND P.ysnPosted = 1
				AND MC.intCommodityId = I.intCommodityId
				AND MC.intCompanyLocationId = SS.intCompanyLocationId
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE B.intEntityVendorId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
		) STORAGE_EARNED
		OUTER APPLY (
			SELECT
				dblPurchaseAdjustment = SUM(ISNULL(SAS.dblAdjustmentAmount, 0))
			FROM vyuGRSearchAdjustSettlements SAS
			INNER JOIN tblICItem I2
				ON I2.intItemId = SAS.intItemId
			INNER JOIN tblICCommodity C2
				ON C2.intCommodityId = I2.intCommodityId
			WHERE MC.intCommodityId = C2.intCommodityId
				AND MC.intCompanyLocationId = SAS.intCompanyLocationId
				AND SAS.intTypeId = 1 -- Purchase
		) ADJUSTMENT
	),
	-- SALES CTE
	SalesCTE AS (
		SELECT
			[intCompanyLocationId]				= MC.intCompanyLocationId
			,[intCommodityId]					= MC.intCommodityId

			,[dblSalesGrainTransfer]			= ISNULL(TRANS.dblSalesGrainTransfer, 0)
			,[dblSalesGrainContract]			= ISNULL(OUTBOUND.dblSalesGrainContract, 0) + ISNULL(OUTBOUND_D.dblSalesGrainContract, 0)
			,[dblSalesGrainSpot]				= ISNULL(OUTBOUND.dblSalesGrainSpot, 0) + ISNULL(OUTBOUND_D.dblSalesGrainSpot, 0)

			-- Paid Units
			,[dblSalesPaidUnitsContract]		= ISNULL(PAID_TICKET.dblSalesPaidUnitsContract, 0)
			,[dblSalesPaidUnitsSpot]			= ISNULL(PAID_TICKET.dblSalesPaidUnitsSpot, 0)

			-- Paid Amounts
			,[dblSalesPaidAmountContract]		= ISNULL(PAID_TICKET.dblSalesPaidAmountContract, 0)
			,[dblSalesPaidAmountSpot]			= ISNULL(PAID_TICKET.dblSalesPaidAmountSpot, 0)

			-- Adjustments
			,[dblSalesAdjustment]				=	ISNULL(ADJUSTMENT.dblSalesAdjustment, 0)

			-- WAP
			,[dblSalesBasisWAPNet]				=	(ISNULL(WAP_CONTRACT.dblSalesBasisTotal, 0) + ISNULL(WAP_SPOT.dblSalesBasisTotal, 0)) / ISNULL(PAID_TICKET.dblSalesPaidUnitsNet, 1)
			,[dblSalesWAPGross]					=	(ISNULL(WAP_CONTRACT.dblSalesPriceTotal, 0) + ISNULL(WAP_SPOT.dblSalesPriceTotal, 0)) / ISNULL(PAID_TICKET.dblSalesPaidUnitsGross, 1)
			,[dblSalesWAPNet]					=	(ISNULL(WAP_CONTRACT.dblSalesPriceTotal, 0) + ISNULL(WAP_SPOT.dblSalesPriceTotal, 0)) / ISNULL(PAID_TICKET.dblSalesPaidUnitsNet, 1)
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
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) OUTBOUND
			ON MC.intCommodityId = OUTBOUND.intCommodityId
			AND MC.intCompanyLocationId = OUTBOUND.intCompanyLocationId
		LEFT JOIN ( -- Destination qty adjustments for the selected period
			SELECT
				[intCommodityId]				=	CO.intCommodityId
				,[intCompanyLocationId]			=	S.intShipFromLocationId
				,[dblSalesGrainContract]		=	SUM(CASE WHEN CD.intContractDetailId IS NOT NULL THEN SI.dblDestinationQuantity - SI.dblQuantity ELSE 0 END)
				,[dblSalesGrainSpot]			=	SUM(CASE WHEN CD.intContractDetailId IS NULL THEN SI.dblDestinationQuantity - SI.dblQuantity ELSE 0 END)
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
			WHERE S.dtmDestinationDate BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) OUTBOUND_D
			ON MC.intCommodityId = OUTBOUND_D.intCommodityId
			AND MC.intCompanyLocationId = OUTBOUND_D.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCommodityId]				=	CO.intCommodityId
				,[intCompanyLocationId]			=	S.intShipFromLocationId
				,[dblSalesBasisTotal]			=	SUM(TSU.dblUnitBasis * SI.dblQuantity)
				,[dblSalesPriceTotal]			=	SUM(PD.dblBaseInvoiceTotal)
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
			INNER JOIN tblSCTicketSpotUsed TSU
				ON TSU.intTicketId = T.intTicketId
				AND TSU.intEntityId = S.intEntityCustomerId
			INNER JOIN tblARInvoiceDetail ID
				ON ID.intInventoryShipmentItemId = SI.intInventoryShipmentItemId
			INNER JOIN tblARInvoice INV
				ON INV.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblARPaymentDetail PD
				ON PD.intInvoiceId = INV.intInvoiceId
			INNER JOIN tblARPayment P
				ON P.intPaymentId = PD.intPaymentId
			WHERE P.dtmDatePaid BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) WAP_SPOT
			ON MC.intCommodityId = WAP_SPOT.intCommodityId
			AND MC.intCompanyLocationId = WAP_SPOT.intCompanyLocationId
		LEFT JOIN (
			SELECT
				[intCommodityId]				=	CO.intCommodityId
				,[intCompanyLocationId]			=	S.intShipFromLocationId
				,[dblSalesBasisTotal]			=	SUM(SI.dblQuantity * dbo.fnCalculateQtyBetweenUOM(CD.intBasisUOMId, SI.intItemUOMId, CD.dblBasis))
				,[dblSalesPriceTotal]			=	SUM(PD.dblBaseInvoiceTotal)
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
			INNER JOIN tblCTContractDetail CD
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
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) WAP_CONTRACT
			ON MC.intCommodityId = WAP_CONTRACT.intCommodityId
			AND MC.intCompanyLocationId = WAP_CONTRACT.intCompanyLocationId
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
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
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
				,[dblSalesPaidAmountContract]		=	SUM(CASE WHEN ID.intContractDetailId IS NOT NULL THEN ID.dblTotal + ID.dblTotalTax ELSE 0 END)
				,[dblSalesPaidAmountSpot]			=	SUM(CASE WHEN ID.intContractDetailId IS NULL THEN ID.dblTotal + ID.dblTotalTax ELSE 0 END)
				
				,[dblSalesPaidUnitsGross]			=	SUM(SI.dblGross)
				,[dblSalesPaidUnitsNet]				=	SUM(SI.dblQuantity)
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
				AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
					OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
					OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
				AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
			GROUP BY S.intShipFromLocationId, CO.intCommodityId
		) PAID_TICKET
			ON MC.intCommodityId = PAID_TICKET.intCommodityId
			AND MC.intCompanyLocationId = PAID_TICKET.intCompanyLocationId
		OUTER APPLY (
			SELECT
				dblSalesAdjustment = SUM(ISNULL(SAS.dblAdjustmentAmount, 0))
			FROM vyuGRSearchAdjustSettlements SAS
			INNER JOIN tblICItem I2
				ON I2.intItemId = SAS.intItemId
			INNER JOIN tblICCommodity C2
				ON C2.intCommodityId = I2.intCommodityId
			WHERE MC.intCommodityId = C2.intCommodityId
				AND MC.intCompanyLocationId = SAS.intCompanyLocationId
				AND SAS.intTypeId = 2 -- Sales
		) ADJUSTMENT
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
		,[P].[dblPurchaseWAPGross]
		,[P].[dblPurchaseWAPNet]
		,[P].[dblPurchaseBasisWAPNet]
		-- Sales
		,[S].[dblSalesGrainTransfer]
		,[S].[dblSalesGrainContract]
		,[S].[dblSalesGrainSpot]
		,[S].[dblSalesPaidUnitsContract]
		,[S].[dblSalesPaidUnitsSpot]
		,[S].[dblSalesPaidAmountContract]
		,[S].[dblSalesPaidAmountSpot]
		,[S].[dblSalesAdjustment]
		,[S].[dblSalesWAPGross]
		,[S].[dblSalesWAPNet]
		,[S].[dblSalesBasisWAPNet]
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