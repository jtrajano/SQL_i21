CREATE PROC [dbo].[uspRKGetInventoryBalance]
	@dtmFromTransactionDate date = null
	, @dtmToTransactionDate date = null
	, @intCommodityId int =  null
	, @intItemId int= null
	, @strPositionIncludes nvarchar(100) = NULL
	, @intLocationId int = null

AS

DECLARE @tblResultInventory TABLE (Id INT identity(1,1)
	, dtmDate datetime
	, tranShipmentNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, tranShipQty NUMERIC(24,10)
	, tranReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, tranRecQty NUMERIC(24,10)
	, BalanceForward NUMERIC(24,10)
	, tranAdjNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblAdjustmentQty NUMERIC(24,10)
	, tranCountNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblCountQty NUMERIC(24,10)
	, tranInvoiceNumber nvarchar(50) COLLATE Latin1_General_CI_AS
	, dblInvoiceQty NUMERIC(24,10)
	, dblSalesInTransit NUMERIC(24,10)
	, tranDSInQty NUMERIC(24,10))

IF (ISNULL(@intItemId, 0) = 0)
BEGIN
	SET @intItemId = NULL
END
IF (ISNULL(@intLocationId, 0) = 0)
BEGIN
	SET @intLocationId = NULL
END

DECLARE @intCommodityUnitMeasureId INT= NULL
SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

SELECT *
	, isnull(tranRecQty,0) - isnull(ABS(tranShipQty),0) +isnull(dblAdjustmentQty,0)+isnull(dblCountQty,0)+isnull(dblInvoiceQty,0) BalanceForward
INTO #temp
FROM (
	SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		, (SELECT strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipmentNumber
		, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ABS(dblQty))) FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber=it.strTransactionId) tranShipQty
		, (SELECT strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranReceiptNumber
		, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(dblQty)) FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber=it.strTransactionId) tranRecQty
		, (SELECT strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber
		, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(dblQty)) FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId ) dblAdjustmentQty
		, (SELECT strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId) tranCountNumber
		, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(dblQty)) FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId ) dblCountQty
		, (SELECT top 1 strInvoiceNumber FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  WHERE ia.strInvoiceNumber=it.strTransactionId) tranInvoiceNumber
		, ROUND((SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(dblQty)) FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId and isnull(ad.strShipmentNumber,'')=''  WHERE ia.strInvoiceNumber=it.strTransactionId ),6) dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM tblICInventoryTransaction it 
	JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(4, 5, 15, 10, 23, 33, 45, 47)
	join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
	JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																									ELSE isnull(ysnLicensed, 0) END)
		and isnull(il.strDescription,'') <> 'In-Transit'
	WHERE i.intCommodityId=@intCommodityId  
	and i.intItemId = isnull(@intItemId, i.intItemId)
	and il.intLocationId =  isnull(@intLocationId, il.intLocationId)
	group by dtmDate,strTransactionId,ium.intCommodityUnitMeasureId

	UNION ALL --Consume, Produce and Outbound Shipment
	SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		, CASE WHEN it.intTransactionTypeId  = 8 OR it.intTransactionTypeId  = 46 THEN it.strTransactionId ELSE '' END tranShipmentNumber
		, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId  = 46 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE  0.0 END tranShipQty
		, CASE WHEN it.intTransactionTypeId = 9 THEN it.strTransactionId ELSE '' END tranReceiptNumber
		, CASE WHEN it.intTransactionTypeId = 9 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM tblICInventoryTransaction it 
	JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(8,9,46)
	join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
	JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																									ELSE isnull(ysnLicensed, 0) END)
		and isnull(il.strDescription,'') <> 'In-Transit'
	WHERE i.intCommodityId=@intCommodityId  
	and i.intItemId = isnull(@intItemId, i.intItemId)
	and il.intLocationId = isnull(@intLocationId, il.intLocationId)
	group by dtmDate, intTransactionTypeId,strTransactionId,ium.intCommodityUnitMeasureId
	
	UNION ALL --Inventory Transfer
	SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		, CASE WHEN it.dblQty < 0 THEN it.strTransactionId ELSE '' END tranShipmentNumber
		, CASE WHEN it.dblQty < 0  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ABS(it.dblQty),0)) ELSE  0.0 END tranShipQty
		, CASE WHEN it.dblQty > 0  THEN it.strTransactionId ELSE '' END tranReceiptNumber
		, CASE WHEN it.dblQty > 0  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(it.dblQty,0)) ELSE 0.0 END tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM tblICInventoryTransaction it 
	JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(12)
	join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
	JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																									WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																									WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																									ELSE isnull(ysnLicensed, 0) END)
		and isnull(il.strDescription,'') <> 'In-Transit'
	WHERE i.intCommodityId=@intCommodityId  
	and i.intItemId = isnull(@intItemId, i.intItemId)
	and il.intLocationId = isnull(@intLocationId, il.intLocationId)


	UNION ALL --Inventory Adjustment (Storage)
	SELECT dtmDate
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
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
			, round(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
			, IA.strAdjustmentNo strAdjustmentNo
			, IA.intInventoryAdjustmentId intInventoryAdjustmentId
		FROM tblICInventoryAdjustment IA
		INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
		INNER JOIN tblICItem i on i.intItemId=IAD.intItemId
		WHERE IAD.intOwnershipType = 2 --Storage
			AND IA.ysnPosted = 1
			AND i.intCommodityId=@intCommodityId  
			AND i.intItemId = isnull(@intItemId, i.intItemId)
			AND IA.intAdjustmentType <> 3
			AND IA.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
	) a
	
	UNION ALL --Direct From Scale
	SELECT dtmDate
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, strReceiptNumber tranReceiptNumber
		, dblInQty tranRecQty
		, ''  tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10), st.dtmTicketDateTime,110) dtmDate
			, CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty
			, r.strReceiptNumber
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE i.intCommodityId = @intCommodityId
			and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			and gs.strOwnedPhysicalStock='Customer' and  gs.intStorageScheduleTypeId > 0 and st.intDeliverySheetId IS NULL
			and st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			and r.intSourceType = 1
	) a
	
	UNION ALL --Delivery Sheet
	SELECT dtmDate
		, '' tranShipmentNumber
		, 0.0 tranShipQty
		, strReceiptNumber tranReceiptNumber
		, dblInQty tranRecQty
		, ''  tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty
			, r.strReceiptNumber
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE i.intCommodityId= @intCommodityId and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			and gs.strOwnedPhysicalStock = 'Customer' and gs.intStorageScheduleTypeId > 0 and st.intDeliverySheetId IS NOT NULL
			and st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			and r.intSourceType = 1 and r.ysnPosted = 1
		
		UNION ALL --Delivery Sheet Split
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			,CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblOpenReceive) ELSE 0 END dblInQty
			,r.strReceiptNumber
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId 
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE  i.intCommodityId= @intCommodityId and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			and ri.intOwnershipType = 2 and st.intStorageScheduleTypeId = -4 and st.intDeliverySheetId IS NOT NULL
			and st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			and r.intSourceType = 1 and r.ysnPosted = 1
	) a
	
	--Shipment against customer storage	
	UNION ALL SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		, '' tranShipmentNumber
		, ABS(dblOutQty) tranShipQty
		, '' tranReceiptNumber
		, 0.0 tranRecQty
		, '' tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, ISNULL(dblSalesInTransit,0) dblSalesInTransit 
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, CASE WHEN strInOutFlag='O' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) ELSE 0 END dblOutQty
			, r.strShipmentNumber
			, ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId and ia.ysnPosted = 1) THEN 0
						ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
		join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
		JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId  
		JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE  i.intCommodityId= @intCommodityId and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			and gs.strOwnedPhysicalStock='Customer' and ri.intOwnershipType = 2
			and st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
	) a
	
	--Shipment against company owned (this is to get the Sales In Transit)
	UNION ALL SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
		, '' tranShipmentNumber
		, 0 tranShipQty
		, '' tranReceiptNumber
		, 0.0 tranRecQty
		, ''  tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, ISNULL(dblSalesInTransit,0) dblSalesInTransit
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10),r.dtmShipDate,110) dtmDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) dblOutQty
			, r.strShipmentNumber
			, ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad on  ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId and ia.ysnPosted = 1) THEN 0
						ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
		FROM tblICInventoryShipment r
		JOIN tblICInventoryShipmentItem ri on ri.intInventoryShipmentId = r.intInventoryShipmentId
		JOIN tblICItem i on i.intItemId = ri.intItemId AND r.intShipFromLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																						WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																						ELSE isnull(ysnLicensed, 0) END)
		JOIN tblICItemUOM u on ri.intItemId=u.intItemId and u.ysnStockUnit=1
		WHERE i.intCommodityId = @intCommodityId and i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			and ri.intOwnershipType = 1 and r.intShipFromLocationId = isnull(@intLocationId, r.intShipFromLocationId)
	) a
	
	--On Hold without Delivery Sheet
	UNION ALL select dtmDate
		, '' tranShipmentNumber
		, abs(isnull(tranShipQty,0)) tranShipQty
		, '' tranReceiptNumber
		, tranRecQty tranRecQty
		, ''  tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
	FROM (
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, st.strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' as tranShipmentNumber
			, (CASE WHEN strInOutFlag='O' THEN ABS(dblNetUnits)  ELSE 0 END) tranShipQty
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
		WHERE i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) and isnull(strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = isnull(@intLocationId, st.intProcessingLocationId)
			AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
												WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1
												WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0
												ELSE isnull(ysnLicensed, 0) END)
			AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H'
	) t1

	UNION ALL
	SELECT dtmDate
		, '' tranShipmentNumber
		, isnull(ABS(dblOutQty),0) tranShipQty
		, '' tranReceiptNumber
		, dblInQty tranRecQty
		, ''  tranAdjNumber
		, 0.0 dblAdjustmentQty
		, '' tranCountNumber
		, 0.0 dblCountQty
		, '' tranInvoiceNumber
		, 0.0 dblInvoiceQty
		, 0.0 dblSalesInTransit
		, 0.0 tranDSInQty
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

			WHERE 
			--convert(datetime,CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110) BETWEEN
			--						convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			--					AND
								 CS.intCommodityId= @intCommodityId
								and CS.intItemId= case when isnull(@intItemId,0)=0 then CS.intItemId else @intItemId end 
								AND  CS.intCompanyLocationId  IN (
																			SELECT intCompanyLocationId FROM tblSMCompanyLocation
																			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																			WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																			ELSE isnull(ysnLicensed, 0) END)
				
								AND CS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CS.intCompanyLocationId  else @intLocationId end
								AND strType IN ('Settlement','Reverse Settlement')
								AND SH.intSettleStorageId IS NULL
								AND S.ysnDPOwnedType <> 1
	) a

)t

--Previous value start 
INSERT INTO @tblResultInventory (BalanceForward)
SELECT sum(BalanceForward) BalanceForward
FROM (
	SELECT BalanceForward  + tranDSInQty as BalanceForward FROM #temp
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)  < CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
) t

--Previous value End
INSERT INTO @tblResultInventory (dtmDate
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
	, BalanceForward
	, dblSalesInTransit
	, tranDSInQty)
SELECT dtmDate
	, tranShipmentNumber
	, isnull(ABS(tranShipQty),0) + CASE WHEN dblInvoiceQty < 0 THEN ABS(dblInvoiceQty) ELSE 0 END
	, tranReceiptNumber
	, isnull(tranRecQty,0) + CASE WHEN dblInvoiceQty > 0 THEN dblInvoiceQty ELSE 0 END
	, tranAdjNumber
	, dblAdjustmentQty
	, tranCountNumber
	, dblCountQty
	, tranInvoiceNumber
	, dblInvoiceQty
	, isnull(tranRecQty,0) - isnull(ABS(tranShipQty),0) + isnull(dblAdjustmentQty,0) + isnull(dblCountQty,0) + isnull(dblInvoiceQty,0) BalanceForward
	, dblSalesInTransit
	, tranDSInQty
FROM (
	SELECT *
	FROM #temp
	WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN
		 convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
) t

SELECT *
FROM (
	SELECT ISNULL(dtmDate,'') dtmDate
		, sum(tranShipQty) tranShipQty
		, sum(tranRecQty) tranRecQty
		, sum(dblAdjustmentQty) dblAdjustmentQty
		, sum(dblCountQty) dblCountQty
		, sum(dblInvoiceQty) dblInvoiceQty
		, sum(BalanceForward) BalanceForward
		, sum(dblSalesInTransit) dblSalesInTransit
		, sum(tranDSInQty) tranDSInQty
	from @tblResultInventory T1 
	group by dtmDate
)t