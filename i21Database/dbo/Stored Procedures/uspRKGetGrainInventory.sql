CREATE PROC [dbo].[uspRKGetGrainInventory]
	@dtmFromTransactionDate date = null
	, @dtmToTransactionDate date = null
	, @intCommodityId int =  null
	, @intItemId int= null
	, @strPositionIncludes nvarchar(100) = NULL
	, @intLocationId int = null

AS

DECLARE @tblResult TABLE (Id INT identity(1,1)
	, dtmDate datetime
	, tranShipmentNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, tranShipQty NUMERIC(24,10)
	, tranReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, tranRecQty NUMERIC(24,10)
	, BalanceForward NUMERIC(24,10)
	, tranAdjNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblAdjustmentQty NUMERIC(24,10)
	, tranInvoiceNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblInvoiceQty NUMERIC(24,10)
	, tranCountNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblCountQty NUMERIC(24,10)
	, strDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
	, strShipDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
	, strAdjDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
	, strCountDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
	, intInventoryReceiptId int
	, intInventoryShipmentId int
	, intInventoryAdjustmentId int
	, intInventoryCountId int
	, intInvoiceId int
	, intDeliverySheetId int
	, deliverySheetNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, intTicketId int
	, ticketNumber nvarchar(50) COLLATE Latin1_General_CI_AS)

DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

SELECT intCompanyLocationId
INTO #LicensedLocation
FROM tblSMCompanyLocation
WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
ELSE isnull(ysnLicensed, 0) END

IF (ISNULL(@intItemId, 0) = 0)
BEGIN
	SET @intItemId = NULL
END
IF (ISNULL(@intLocationId, 0) = 0)
BEGIN
	SET @intLocationId = NULL
END

INSERT INTO @tblResult(dtmDate
	, strDistributionOption
	, strShipDistributionOption
	, strAdjDistributionOption
	, strCountDistributionOption
	, tranShipmentNumber
	, tranShipQty
	, tranReceiptNumber
	, tranRecQty
	, tranAdjNumber
	, dblAdjustmentQty
	, tranCountNumber
	, dblCountQty
	, tranInvoiceNumber
	, dblInvoiceQty
	, intInventoryReceiptId
	, intInventoryShipmentId
	, intInventoryAdjustmentId
	, intInventoryCountId
	, intInvoiceId
	, intDeliverySheetId
	, deliverySheetNumber
	, intTicketId
	, ticketNumber
	, BalanceForward)
SELECT *
	, round(isnull(tranShipQty,0)+isnull(tranRecQty,0)+isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0),6) BalanceForward
FROM (
	SELECT dtmDate
		, strDistributionOption strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, strReceiptNumber tranReceiptNumber
		, dblInQty tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intInventoryReceiptId
		, null intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN ri.dblOpenReceive ELSE 0 END) ,6) dblInQty
			, r.strReceiptNumber
			, strDistributionOption
			, r.intInventoryReceiptId
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
		join tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
		WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND i.intCommodityId = @intCommodityId
			and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			AND r.intSourceType = 1 AND st.intDeliverySheetId IS NULL
	) a
	
	UNION ALL --Delivery Sheet
	SELECT dtmDate,strDistributionOption strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, strReceiptNumber tranReceiptNumber
		, dblInQty tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intInventoryReceiptId
		, null intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN ri.dblOpenReceive ELSE 0 END) ,6) dblInQty
			, r.strReceiptNumber
			, gs.strStorageTypeCode strDistributionOption
			, r.intInventoryReceiptId
		FROM vyuSCTicketView st
		JOIN tblICItem i on i.intItemId=st.intItemId
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		join tblGRStorageHistory gsh on gsh.intInventoryReceiptId = r.intInventoryReceiptId
		join tblGRCustomerStorage gh on gh.intCustomerStorageId = gsh.intCustomerStorageId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId = gh.intStorageTypeId 
		join tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=1 AND u.intUnitMeasureId=ium.intUnitMeasureId
		WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND i.intCommodityId= @intCommodityId and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(i.strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			AND r.intSourceType = 1 AND st.intDeliverySheetId IS NOT NULL
	) a

	UNION ALL --Inventory Adjustments
	SELECT dtmDate
		, '' strDistributionOption
		, '' strShipDistributionOption
		, 'ADJ' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, '' tranReceiptNumber
		, 0.0 tranRecQty
		, strAdjustmentNo tranAdjNumber
		, dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, null intInventoryReceiptId
		, null intInventoryShipmentId
		, intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		--Own
		SELECT CONVERT(VARCHAR(10),IT.dtmDate,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
			, IT.strTransactionId strAdjustmentNo
			, IT.intTransactionId intInventoryAdjustmentId
		FROM tblICInventoryTransaction IT
		INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		WHERE IT.intTransactionTypeId IN (10,15,47)
			AND IT.ysnIsUnposted = 0
			AND convert(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND IT.intItemId = isnull(@intItemId, IT.intItemId) AND il.intLocationId = isnull(@intLocationId, il.intLocationId)
		
		--Storage
		UNION ALL SELECT CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
			, round(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
			, IA.strAdjustmentNo strAdjustmentNo
			, IA.intInventoryAdjustmentId intInventoryAdjustmentId
		FROM tblICInventoryAdjustment IA
		INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
		INNER JOIN tblICItem Itm ON IAD.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		WHERE IAD.intOwnershipType = 2 --Storage
			AND IA.ysnPosted = 1
			AND convert(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND IAD.intItemId = isnull(@intItemId, IAD.intItemId)
			AND IA.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	) a
	
	UNION SELECT dtmDate
		, '' strDistributionOption
		, strDistributionOption strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, strShipmentNumber tranShipmentNumber
		, dblOutQty tranShipQty
		, '' tranReceiptNumber
		, 0.0 tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, null intInventoryReceiptId
		, intInventoryShipmentId intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='O' THEN ri.dblQuantity ELSE 0 END) ,6) dblOutQty
			, r.strShipmentNumber
			, CASE WHEN ri.intStorageScheduleTypeId IS NULL AND ri.intOrderId IS NULL THEN 'SPT' WHEN ri.intOrderId IS NOT NULL THEN st.strDistributionOption ELSE gs.strStorageTypeCode END strDistributionOption,r.intInventoryShipmentId
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId 
									AND  st.intProcessingLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
		LEFT JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=ri.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
		WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		and i.intItemId= isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
		AND st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
	) a
	
	UNION ALL --On Hold without Delivery Sheet
	SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
		, st.strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, '' as tranShipmentNumber
		, (CASE WHEN strInOutFlag='O' THEN dblNetUnits  ELSE 0 END)  tranShipQty
		, '' tranReceiptNumber
		, (CASE WHEN strInOutFlag='I' THEN dblNetUnits  ELSE 0 END) tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, null intInventoryReceiptId
		, NULL intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber 
		, st.intTicketId
		, st.strTicketNumber AS ticketNumber
	FROM tblSCTicket st
	JOIN tblICItem i on i.intItemId=st.intItemId
	WHERE convert(datetime,CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		AND i.intCommodityId= @intCommodityId
		AND i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
		AND st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
		AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H'
		
	UNION ALL --Direct IR
	SELECT dtmDate
		, strDistributionOption strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, strReceiptNumber tranReceiptNumber
		, dblInQty tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intInventoryReceiptId
		, null intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),R.dtmReceiptDate,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,RI.dblOpenReceive) ,6) dblInQty
			, R.strReceiptNumber
			, '' strDistributionOption
			, R.intInventoryReceiptId
		FROM tblICInventoryReceiptItem RI
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE R.ysnPosted = 1
			AND convert(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND Itm.intItemId = isnull(@intItemId, Itm.intItemId)
			AND R.intLocationId = isnull(@intLocationId, R.intLocationId)
			AND R.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND RI.intOwnershipType = 1 
			AND R.intSourceType = 0
	) t
	
	UNION ALL --Direct IS
	SELECT dtmDate
		, '' strDistributionOption
		, strDistributionOption strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, strShipmentNumber tranShipmentNumber
		, dblOutQty tranShipQty
		, '' tranReceiptNumber
		, 0.0 tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, null intInventoryReceiptId
		, intInventoryShipmentId intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),S.dtmShipDate,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,SI.dblQuantity) ,6) dblOutQty
			, S.strShipmentNumber
			, '' strDistributionOption
			, S.intInventoryShipmentId
		FROM tblICInventoryShipmentItem SI
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE S.ysnPosted = 1
		AND convert(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND C.intCommodityId = @intCommodityId 
		AND Itm.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
		AND S.intShipFromLocationId = case when isnull(@intLocationId,0)=0 then S.intShipFromLocationId else @intLocationId end 
		AND S.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		AND SI.intOwnershipType = 1
		AND S.intSourceType = 0 
	)a

UNION ALL --Direct Invoice
SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
		'' as strAdjDistributionOption,
		'' as strCountDistributionOption,
		strShipmentNumber tranShipmentNumber,
		CASE WHEN strTransactionType = 'Credit Memo' THEN 0.0 ELSE  isnull(dblOutQty, 0) END  tranShipQty,
		'' tranReceiptNumber,
		CASE WHEN strTransactionType = 'Credit Memo' THEN isnull(dblOutQty, 0) ELSE 0.0 END tranRecQty,
		'' tranAdjNumber,
		0.0 dblAdjustmentQty,
		'' tranCountNumber,
		0.0 dblCountQty,
		'' tranInvoiceNumber,
		0.0 dblInvoiceQty,
		null intInventoryReceiptId,
		null intInventoryShipmentId,
		null intInventoryAdjustmentId,
		null intInventoryCountId,
		intInvoiceId,
		null intDeliverySheetId,
		'' AS deliverySheetNumber,
		null intTicketId,
		'' AS ticketNumber    
FROM(
	SELECT  
		CONVERT(VARCHAR(10),I.dtmPostDate,110) dtmDate
		,round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ID.dblQtyShipped) ,6) dblOutQty
		,I.strInvoiceNumber strShipmentNumber
		,'' strDistributionOption 
		,I.intInvoiceId
		,I.strTransactionType
	FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
	WHERE I.ysnPosted = 1
		AND ID.intInventoryShipmentItemId IS NULL
		AND ISNULL(ID.strShipmentNumber,'') = ''
		AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND C.intCommodityId = @intCommodityId 
		AND ID.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
		AND I.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
		AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	)a

	UNION ALL --Consume, Produce and Outbound Shipment
	SELECT dtmDate
		, '' strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, tranShipmentNumber
		, tranShipQty
		, tranReceiptNumber
		, tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intTransactionId intInventoryReceiptId
		, intTransactionId intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, CASE WHEN it.intTransactionTypeId  = 8 OR it.intTransactionTypeId  = 46 THEN it.strTransactionId ELSE '' END tranShipmentNumber
			, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId  = 46 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE  0.0 END tranShipQty
			, CASE WHEN it.intTransactionTypeId = 9 THEN it.strTransactionId ELSE '' END tranReceiptNumber
			, CASE WHEN it.intTransactionTypeId = 9 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranRecQty
			, it.intTransactionId
		FROM tblICInventoryTransaction it
		JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(8,9,46)
		join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
		JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId
											AND  il.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			and isnull(il.strDescription,'') <> 'In-Transit'
		WHERE i.intCommodityId=@intCommodityId
			and i.intItemId = isnull(@intItemId, i.intItemId)
			and il.intLocationId = isnull(@intLocationId, il.intLocationId)
			and convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		group by dtmDate, intTransactionTypeId,strTransactionId,ium.intCommodityUnitMeasureId,intTransactionId
	) a


	UNION ALL --Inventory Transfer
	SELECT dtmDate
		, '' strDistributionOption
		, '' strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, tranShipmentNumber
		, tranShipQty
		, tranReceiptNumber
		, tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intTransactionId intInventoryReceiptId
		, intTransactionId intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, CASE WHEN it.dblQty < 0 THEN it.strTransactionId ELSE '' END tranShipmentNumber
			, CASE WHEN it.dblQty < 0  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ABS(it.dblQty),0)) ELSE  0.0 END tranShipQty
			, CASE WHEN it.dblQty > 0  THEN it.strTransactionId ELSE '' END tranReceiptNumber
			, CASE WHEN it.dblQty > 0  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(it.dblQty,0)) ELSE 0.0 END tranRecQty
			, it.intTransactionId
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(12)
		join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
		JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			and isnull(il.strDescription,'') <> 'In-Transit'
		WHERE i.intCommodityId=@intCommodityId  
		and i.intItemId = isnull(@intItemId, i.intItemId)
		and il.intLocationId = isnull(@intLocationId, il.intLocationId)
		and convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
	) t

	UNION ALL --Storage Transfer
	SELECT dtmDate
		, strDistributionOption
		, strDistributionOption strShipDistributionOption
		, '' as strAdjDistributionOption
		, '' as strCountDistributionOption
		, strTransferTicket tranShipmentNumber
		, dblOutQty tranShipQty
		, strTransferTicket tranReceiptNumber
		, dblInQty tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, intTransferStorageId intInventoryReceiptId
		, intTransferStorageId intInventoryShipmentId
		, null intInventoryAdjustmentId
		, null intInventoryCountId
		, null intInvoiceId
		, null intDeliverySheetId
		, '' AS deliverySheetNumber
		, null intTicketId
		, '' AS ticketNumber
	FROM (
		SELECT CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
			, S.strStorageTypeCode strDistributionOption
			, CASE WHEN strType = 'From Transfer' THEN dblUnits
					ELSE 0 END AS dblInQty
			, CASE WHEN strType = 'Transfer' THEN ABS(dblUnits)
					ELSE 0 END AS dblOutQty
			, S.intStorageScheduleTypeId
			, SH.intTransferStorageId
			, SH.strTransferTicket
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
		INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
		WHERE convert(datetime,CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110)
			BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND CS.intCommodityId = @intCommodityId
			and CS.intItemId = isnull(@intItemId, CS.intItemId)
			AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND CS.intCompanyLocationId = isnull(@intLocationId, CS.intCompanyLocationId)
			AND strType IN ('From Transfer','Transfer')
	) a

	UNION ALL --Storage Settlement 
	SELECT dtmDate,strDistributionOption,strDistributionOption strShipDistributionOption,
			'' as strAdjDistributionOption,
			'' as strCountDistributionOption,
			strSettleTicket tranShipmentNumber,
			dblOutQty tranShipQty,
			strSettleTicket tranReceiptNumber,
			dblInQty tranRecQty,
			'' tranAdjNumber,
			0.0 dblAdjustmentQty,
			'' tranCountNumber,
			0.0 dblCountQty,
			'' tranInvoiceNumber,
			0.0 dblInvoiceQty,
			intSettleStorageId intInventoryReceiptId,
			intSettleStorageId intInventoryShipmentId,
			null intInventoryAdjustmentId,
			null intInventoryCountId,
			null intInvoiceId,
			null intDeliverySheetId,
			'' AS deliverySheetNumber,
			null intTicketId,
			'' AS ticketNumber    
	FROM(

		select
				CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
				,S.strStorageTypeCode strDistributionOption
				, CASE WHEN strType = 'Reverse Settlement' THEN
					ABS(dblUnits)
					ELSE 0 END  AS dblOutQty
				,CASE WHEN strType = 'Settlement' THEN
					ABS(dblUnits)
					ELSE 0 END AS dblInQty
				,S.intStorageScheduleTypeId
				,SH.intSettleStorageId
				,SH.strSettleTicket

			from 
			tblGRCustomerStorage CS
			INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
			INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId

			WHERE convert(datetime,CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110) BETWEEN
									convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
								AND CS.intCommodityId= @intCommodityId
								and CS.intItemId= case when isnull(@intItemId,0)=0 then CS.intItemId else @intItemId end 
								AND  CS.intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
								AND CS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CS.intCompanyLocationId  else @intLocationId end
								AND strType IN ('Settlement','Reverse Settlement')
								AND SH.intSettleStorageId IS NULL
								AND S.ysnDPOwnedType <> 1
	) a

	

 )t

DROP TABLE #LicensedLocation

SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
	, *
FROM (
	SELECT DISTINCT dtmDate [dtmDate]
		, case when isnull(tranReceiptNumber,'') <> '' then tranReceiptNumber
				when isnull(tranShipmentNumber,'') <> '' then tranShipmentNumber
				when isnull(tranAdjNumber,'') <> '' then tranAdjNumber
				when isnull(tranInvoiceNumber,'') <> '' then tranInvoiceNumber
				when isnull(tranCountNumber,'') <> '' then tranCountNumber
				when isnull(deliverySheetNumber,'') <> '' then deliverySheetNumber
				when isnull(ticketNumber,'') <> '' then ticketNumber end [strReceiptNumber]
		, CASE WHEN isnull(strDistributionOption,'') <> '' THEN strDistributionOption
				WHEN isnull(strShipDistributionOption,'') <> '' then strShipDistributionOption
				WHEN isnull(strAdjDistributionOption,'') <> '' then strAdjDistributionOption END strDistribution
		, tranRecQty [dblIN]
		, isnull(tranShipmentNumber,'') [strShipTicketNo]
		, isnull(tranShipQty,0) + isnull(dblInvoiceQty,0) [dblOUT]
		, tranAdjNumber [strAdjNo]
		, dblAdjustmentQty [dblAdjQty]
		, tranCountNumber [strCountNumber]
		, dblCountQty [dblCountQty]
		, BalanceForward dblDummy
		, (SELECT SUM(BalanceForward) FROM @tblResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, deliverySheetNumber
		, intTicketId
		, ticketNumber
	FROM @tblResult T1
)t order by dtmDate desc,strReceiptNumber desc
