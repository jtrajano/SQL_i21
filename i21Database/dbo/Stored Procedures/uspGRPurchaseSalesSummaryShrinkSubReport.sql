CREATE PROCEDURE [dbo].[uspGRPurchaseSalesSummaryShrinkSubReport]
	@xmlParam NVARCHAR(MAX),
    @intCommodityCode INT,
    @intLocationId INT,
    @ysnPurchase BIT
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
    DECLARE @tblItemId Id

	SELECT @dtmDeliveryDateFromParam = ISNULL([from], DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDeliveryDate'

	SELECT @dtmDeliveryDateToParam = ISNULL(DATEADD(MILLISECOND, -3, ISNULL(CAST([to] AS DATETIME), CAST([from] AS DATETIME)) + 1), GETDATE())
	FROM @temp_xml_table WHERE [fieldname] = 'dtmDeliveryDate'

	SELECT TOP 1 @ysnIncludeInterLocationTransfers = CONVERT(BIT, [from])
	FROM @temp_xml_table WHERE [fieldname] = 'ysnIncludeInterLocationTransfers'

	SELECT TOP 1 @ysnPrintConsolidatedTotals = CONVERT(BIT, [from])
	FROM @temp_xml_table WHERE [fieldname] = 'ysnPrintConsolidatedTotals'

	INSERT INTO @tblEntityId
	SELECT Z.intEntityId FROM @temp_xml_table X
	INNER JOIN tblEMEntity Z ON Z.strName = [from] COLLATE Latin1_General_CI_AS
	WHERE [fieldname] = 'strEntityName'

    INSERT INTO @tblMarketZoneId
    SELECT Z.intMarketZoneId FROM @temp_xml_table X
    INNER JOIN tblARMarketZone Z ON Z.strMarketZoneCode = [from] COLLATE Latin1_General_CI_AS
    WHERE [fieldname] = 'strMarketZoneCode'
    
    INSERT INTO @tblItemId
	SELECT Z.intItemId FROM @temp_xml_table X
	INNER JOIN tblICItem Z ON Z.strItemNo = X.[from] COLLATE Latin1_General_CI_AS
	WHERE [fieldname] = 'strItemNo'
	-- End extraction of parameters from XML

    IF @ysnPurchase = 1
    BEGIN
        SELECT
            [intDiscountTypeId]     =   DT.intDiscountTypeId
            ,[strDiscountType]      =   DT.strDiscountType
            ,[dblGrainDP]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 1 THEN ISNULL(IRI.dblGross * (TD.dblShrinkPercent/100), 0) ELSE 0 END)
            ,[dblGrainOS]			=	SUM(CASE WHEN ST.ysnDPOwnedType = 0 THEN IRI.dblGross * (TD.dblShrinkPercent/100) ELSE 0 END)
            ,[dblGrainContract]		=	SUM(CASE WHEN CD.intContractDetailId IS NOT NULL AND ST.ysnDPOwnedType = 0 THEN IRI.dblGross * (TD.dblShrinkPercent/100) ELSE 0 END)
            ,[dblGrainSpot]			=	SUM(CASE WHEN CD.intContractDetailId IS NULL AND IRI.intOwnershipType = 1 THEN IRI.dblGross * (TD.dblShrinkPercent/100) ELSE 0 END)
        FROM tblSCTicket T
        INNER JOIN tblICItem I
            ON I.intItemId = T.intItemId
        INNER JOIN tblICCommodity CO
            ON CO.intCommodityId = I.intCommodityId
        INNER JOIN tblICInventoryReceiptItem IRI
            ON IRI.intSourceId = T.intTicketId
            AND T.intItemId = IRI.intItemId
        INNER JOIN tblICInventoryReceipt IR
            ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
            AND IR.intSourceType = 1
        LEFT JOIN tblCTContractDetail CD
            ON CD.intContractHeaderId = IRI.intContractHeaderId
            AND CD.intContractDetailId = IRI.intContractDetailId
        LEFT JOIN tblGRCustomerStorage CS
            ON CS.intTicketId = T.intTicketId
            AND CS.ysnTransferStorage = 0
        LEFT JOIN tblGRStorageType ST
            ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        LEFT JOIN tblQMTicketDiscount TD
            ON TD.intTicketId = T.intTicketId
            AND TD.strSourceType = 'Scale'
        LEFT JOIN tblGRDiscountScheduleCode DSC
            ON DSC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
        LEFT JOIN tblSCDiscountType DT
            ON DT.intDiscountTypeId = DSC.intDiscountTypeId
        LEFT JOIN tblICItem CI
            ON CI.intItemId = DSC.intItemId
        WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
            AND DT.intDiscountTypeId IS NOT NULL
            AND TD.dblShrinkPercent > 0
            AND CO.intCommodityId = @intCommodityCode
            AND IR.intLocationId = @intLocationId
            AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
                OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
            AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
                OR EXISTS (SELECT 1 FROM @tblEntityId WHERE IR.intEntityVendorId = intId))
            AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
        GROUP BY DT.intDiscountTypeId, DT.strDiscountType
    END
    ELSE
    BEGIN
        SELECT
            [intDiscountTypeId]     =   DT.intDiscountTypeId
            ,[strDiscountType]      =   DT.strDiscountType
            ,[dblGrainDP]			=	0
            ,[dblGrainOS]			=	0
            ,[dblGrainContract]		=	SUM(CASE WHEN CD.intContractDetailId IS NOT NULL THEN SI.dblGross * (TD.dblShrinkPercent/100) ELSE 0 END)
            ,[dblGrainSpot]			=	SUM(CASE WHEN CD.intContractDetailId IS NULL THEN SI.dblGross * (TD.dblShrinkPercent/100) ELSE 0 END)
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
        LEFT JOIN tblQMTicketDiscount TD
            ON TD.intTicketId = T.intTicketId
            AND TD.strSourceType = 'Scale'
        LEFT JOIN tblGRDiscountScheduleCode DSC
            ON DSC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
        LEFT JOIN tblSCDiscountType DT
            ON DT.intDiscountTypeId = DSC.intDiscountTypeId
        LEFT JOIN tblICItem CI
            ON CI.intItemId = DSC.intItemId
        WHERE T.dtmTicketDateTime BETWEEN @dtmDeliveryDateFromParam AND @dtmDeliveryDateToParam
            AND (CD.intMarketZoneId IS NULL
                OR (CD.intMarketZoneId IS NOT NULL AND CD.intMarketZoneId IN (SELECT intId FROM @tblMarketZoneId)))
            AND DT.intDiscountTypeId IS NOT NULL
            AND TD.dblShrinkPercent > 0
            AND CO.intCommodityId = @intCommodityCode
            AND S.intShipFromLocationId = @intLocationId
            AND (NOT EXISTS(SELECT 1 FROM @tblMarketZoneId)
                OR EXISTS (SELECT 1 FROM @tblMarketZoneId WHERE CD.intMarketZoneId = intId))
            AND (NOT EXISTS(SELECT 1 FROM @tblEntityId)
                OR EXISTS (SELECT 1 FROM @tblEntityId WHERE S.intEntityCustomerId = intId))
            AND (NOT EXISTS(SELECT 1 FROM @tblItemId)
					OR EXISTS (SELECT 1 FROM @tblItemId WHERE I.intItemId = intId))
        GROUP BY DT.intDiscountTypeId, DT.strDiscountType
    END

END TRY

BEGIN CATCH
	DECLARE @ErrMsg NVARCHAR(MAX)
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH