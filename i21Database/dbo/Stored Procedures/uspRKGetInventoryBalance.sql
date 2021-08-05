CREATE PROCEDURE [dbo].[uspRKGetInventoryBalance]
	@dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL

AS

BEGIN
	DECLARE @tblResultInventory TABLE (Id INT IDENTITY(1,1)
		, dtmDate DATETIME
		, tranShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, tranShipQty NUMERIC(24,10)
		, tranReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, tranRecQty NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, tranAdjNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblAdjustmentQty NUMERIC(24,10)
		, tranCountNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblCountQty NUMERIC(24,10)
		, tranInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
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

	DECLARE @intCommodityUnitMeasureId INT = NULL
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE ISNULL(ysnLicensed, 0) END

	SELECT *
		, ISNULL(tranRecQty, 0) - ISNULL(ABS(tranShipQty), 0) + ISNULL(dblAdjustmentQty, 0) + ISNULL(dblCountQty, 0) + ISNULL(dblInvoiceQty, 0) BalanceForward
	INTO #temp
	FROM (
		SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, (SELECT strShipmentNumber FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber = it.strTransactionId) tranShipmentNumber
			, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(ABS(dblQty))) FROM tblICInventoryShipment sh WHERE sh.strShipmentNumber = it.strTransactionId) tranShipQty
			, (SELECT strReceiptNumber FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber = it.strTransactionId) tranReceiptNumber
			, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(dblQty)) FROM tblICInventoryReceipt ir WHERE ir.strReceiptNumber = it.strTransactionId) tranRecQty
			, (SELECT strAdjustmentNo FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo=it.strTransactionId) tranAdjNumber
			, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(dblQty)) FROM tblICInventoryAdjustment ia WHERE ia.strAdjustmentNo = it.strTransactionId) dblAdjustmentQty
			, (SELECT strCountNo FROM tblICInventoryCount ia WHERE ia.strCountNo=it.strTransactionId) tranCountNumber
			, (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(dblQty)) FROM tblICInventoryCount ia WHERE ia.strCountNo = it.strTransactionId) dblCountQty
			, (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice ia JOIN tblARInvoiceDetail ad ON ia.intInvoiceId = ad.intInvoiceId AND ISNULL(ad.strShipmentNumber, '') = '' WHERE ia.strInvoiceNumber = it.strTransactionId) tranInvoiceNumber
			, ROUND((SELECT TOP 1 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(dblQty)) FROM tblARInvoice ia JOIN tblARInvoiceDetail ad ON ia.intInvoiceId = ad.intInvoiceId AND ISNULL(ad.strShipmentNumber, '') = '' WHERE ia.strInvoiceNumber = it.strTransactionId), 6) dblInvoiceQty
			, 0.0 dblSalesInTransit
			, 0.0 tranDSInQty
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i ON i.intItemId = it.intItemId AND it.ysnIsUnposted = 0 AND it.intTransactionTypeId IN (4, 5, 15, 10, 23, 33, 45, 47)
			AND i.intCommodityId = @intCommodityId 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		JOIN tblICItemUOM u ON it.intItemId = u.intItemId AND u.intItemUOMId = it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = @intCommodityId AND u.intUnitMeasureId = ium.intUnitMeasureId 
		JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation) AND ISNULL(il.strDescription,'') <> 'In-Transit'
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		--WHERE i.intCommodityId = @intCommodityId 
		--	AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		--	AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		GROUP BY dtmDate
			, strTransactionId
			, ium.intCommodityUnitMeasureId
		
		--Consume, Produce AND Outbound Shipment
		UNION ALL SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId = 46 THEN it.strTransactionId ELSE '' END tranShipmentNumber
			, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId = 46 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranShipQty
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
		JOIN tblICItem i ON i.intItemId=it.intItemId AND it.ysnIsUnposted=0 AND it.intTransactionTypeId in(8,9,46)
			AND i.intCommodityId=@intCommodityId 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		JOIN tblICItemUOM u ON it.intItemId=u.intItemId AND u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICItemLocation il ON it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation) AND ISNULL(il.strDescription,'') <> 'In-Transit'
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		--WHERE i.intCommodityId=@intCommodityId 
		--	AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		--	AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		GROUP BY dtmDate
			, intTransactionTypeId
			, strTransactionId
			, ium.intCommodityUnitMeasureId

		--Inventory Transfer
		UNION ALL SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, CASE WHEN it.dblQty < 0 THEN it.strTransactionId ELSE '' END tranShipmentNumber
			, CASE WHEN it.dblQty < 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ABS(it.dblQty),0)) ELSE 0.0 END tranShipQty
			, CASE WHEN it.dblQty > 0 THEN it.strTransactionId ELSE '' END tranReceiptNumber
			, CASE WHEN it.dblQty > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(it.dblQty,0)) ELSE 0.0 END tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, 0.0 dblSalesInTransit
			, 0.0 tranDSInQty
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i ON i.intItemId=it.intItemId AND it.ysnIsUnposted=0 AND it.intTransactionTypeId in(12)
			AND i.intCommodityId=@intCommodityId 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		JOIN tblICItemUOM u ON it.intItemId=u.intItemId AND u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICItemLocation il ON it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation) AND ISNULL(il.strDescription,'') <> 'In-Transit'
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		--WHERE i.intCommodityId=@intCommodityId 
		--	AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		--	AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)

		--Inventory Adjustment (Storage)
		UNION ALL SELECT dtmDate
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
				, ROUND(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
				, IA.strAdjustmentNo strAdjustmentNo
				, IA.intInventoryAdjustmentId intInventoryAdjustmentId
			FROM tblICInventoryAdjustment IA
			INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
				AND IAD.intOwnershipType = 2 --Storage
			INNER JOIN tblICItem i ON i.intItemId=IAD.intItemId
				AND i.intCommodityId = @intCommodityId 
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			WHERE --IAD.intOwnershipType = 2 AND --Storage
				IA.ysnPosted = 1
				--AND i.intCommodityId=@intCommodityId 
				--AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND IA.intAdjustmentType <> 3
				AND IA.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		) a

		--Direct From Scale
		UNION ALL SELECT dtmDate
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
			, 0.0 dblSalesInTransit
			, 0.0 tranDSInQty
		FROM (
			SELECT CONVERT(VARCHAR(10), st.dtmTicketDateTime,110) dtmDate
				, CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty
				, r.strReceiptNumber
			FROM tblSCTicket st
			JOIN tblICItem i ON i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND i.intCommodityId = @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId) 
				AND ISNULL(strType,'') <> 'Other Charge'
			JOIN tblICInventoryReceiptItem ri ON ri.intSourceId=st.intTicketId
			JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId=ri.intInventoryReceiptId
				AND r.intSourceType = 1
			JOIN tblGRStorageType gs ON gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
				AND gs.strOwnedPhysicalStock='Customer' AND gs.intStorageScheduleTypeId > 0
			JOIN tblICItemUOM u ON st.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE --i.intCommodityId = @intCommodityId
				--AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
				--AND gs.strOwnedPhysicalStock='Customer' AND gs.intStorageScheduleTypeId > 0 AND
				st.intDeliverySheetId IS NULL
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				--AND r.intSourceType = 1
		) a

		--Delivery Sheet
		UNION ALL SELECT dtmDate
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
			, 0.0 dblSalesInTransit
			, 0.0 tranDSInQty
		FROM (
			SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				, CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,dblNetUnits) ELSE 0 END dblInQty
				, r.strReceiptNumber
			FROM tblSCTicket st
			JOIN tblICItem i ON i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			JOIN tblICInventoryReceiptItem ri ON ri.intSourceId=st.intTicketId
			JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId=ri.intInventoryReceiptId
			JOIN tblGRStorageType gs ON gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
			JOIN tblICItemUOM u ON st.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE i.intCommodityId= @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
				AND gs.strOwnedPhysicalStock = 'Customer' AND gs.intStorageScheduleTypeId > 0 AND st.intDeliverySheetId IS NOT NULL
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				AND r.intSourceType = 1 AND r.ysnPosted = 1

			--Delivery Sheet Split
			UNION ALL SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				,CASE WHEN strInOutFlag='I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblOpenReceive) ELSE 0 END dblInQty
				,r.strReceiptNumber
			FROM tblSCTicket st
			JOIN tblICItem i ON i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND i.intCommodityId= @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
			JOIN tblICInventoryReceiptItem ri ON ri.intSourceId=st.intTicketId
				AND ri.intOwnershipType = 2 
			JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId=ri.intInventoryReceiptId 
				AND r.intSourceType = 1 AND r.ysnPosted = 1
			JOIN tblICItemUOM u ON st.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE --i.intCommodityId= @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
				--AND ri.intOwnershipType = 2 AND 
				st.intStorageScheduleTypeId = -4 AND st.intDeliverySheetId IS NOT NULL
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				--AND r.intSourceType = 1 AND r.ysnPosted = 1
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
				, ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad ON ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId AND ia.ysnPosted = 1) THEN 0
			ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
			FROM tblSCTicket st
			JOIN tblICItem i ON i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND i.intCommodityId= @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
			JOIN tblICInventoryShipmentItem ri ON ri.intSourceId=st.intTicketId
				AND ri.intOwnershipType = 2 
			JOIN tblICInventoryShipment r ON r.intInventoryShipmentId=ri.intInventoryShipmentId
			JOIN tblGRStorageType gs ON gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
				AND gs.strOwnedPhysicalStock='Customer' 
			JOIN tblICItemUOM u ON st.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE --i.intCommodityId= @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
				--AND gs.strOwnedPhysicalStock='Customer' AND ri.intOwnershipType = 2 AND
				st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
		) a

		--Shipment against company owned (this is to get the Sales In Transit)
		UNION ALL SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, '' tranShipmentNumber
			, 0 tranShipQty
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
			SELECT CONVERT(VARCHAR(10),r.dtmShipDate,110) dtmDate
				, dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ri.dblQuantity) dblOutQty
				, r.strShipmentNumber
				, ROUND(CASE WHEN EXISTS(SELECT TOP 1 * FROM tblARInvoice ia JOIN tblARInvoiceDetail ad ON ia.intInvoiceId=ad.intInvoiceId WHERE ad.intInventoryShipmentItemId=ri.intInventoryShipmentItemId AND ia.ysnPosted = 1) THEN 0
			ELSE dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId, case when ri.intOwnershipType = 1 then ri.dblQuantity else 0 end) END,6) dblSalesInTransit
			FROM tblICInventoryShipment r
			JOIN tblICInventoryShipmentItem ri ON ri.intInventoryShipmentId = r.intInventoryShipmentId
				AND ri.intOwnershipType = 1 
			JOIN tblICItem i ON i.intItemId = ri.intItemId AND r.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
			JOIN tblICItemUOM u ON ri.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE --i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
				--AND ri.intOwnershipType = 1 AND 
				r.intShipFromLocationId = ISNULL(@intLocationId, r.intShipFromLocationId)
		) a

		--On Hold without Delivery Sheet
		UNION ALL SELECT dtmDate
			, '' tranShipmentNumber
			, abs(ISNULL(tranShipQty,0)) tranShipQty
			, '' tranReceiptNumber
			, tranRecQty tranRecQty
			, '' tranAdjNumber
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
				, (CASE WHEN strInOutFlag='O' THEN ABS(dblNetUnits) ELSE 0 END) tranShipQty
				, '' tranReceiptNumber
				, (CASE WHEN strInOutFlag='I' THEN dblNetUnits ELSE 0 END) tranRecQty
				, '' tranAdjNumber
				, 0.0 dblAdjustmentQty
				, '' tranCountNumber
				, 0.0 dblCountQty
				, '' tranInvoiceNumber
				, 0.0 dblInvoiceQty
				, NULL intInventoryReceiptId
				, NULL intInventoryShipmentId
				, NULL intInventoryAdjustmentId
				, NULL intInventoryCountId
				, NULL intInvoiceId
				, NULL intDeliverySheetId
				, '' AS deliverySheetNumber
				, st.intTicketId
				, st.strTicketNumber AS ticketNumber
			FROM tblSCTicket st
			JOIN tblICItem i ON i.intItemId=st.intItemId
				AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge'
			WHERE --i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType,'') <> 'Other Charge' AND 
				st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H'
		) t1

		UNION ALL SELECT dtmDate
			, '' tranShipmentNumber
			, ISNULL(ABS(dblOutQty),0) tranShipQty
			, '' tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, 0.0 dblSalesInTransit
			, 0.0 tranDSInQty
		FROM (
			SELECT CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
				, S.strStorageTypeCode strDistributionOption
				, CASE WHEN strType = 'Reverse Settlement' THEN ABS(dblUnits) ELSE 0 END AS dblOutQty
				, CASE WHEN strType = 'Settlement' THEN ABS(dblUnits) ELSE 0 END AS dblInQty
				, S.intStorageScheduleTypeId
				, SH.intSettleStorageId
				, SH.strSettleTicket
			FROM tblGRCustomerStorage CS
			INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
				AND strType IN ('Settlement','Reverse Settlement')
				AND SH.intSettleStorageId IS NULL
			INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
				AND S.ysnDPOwnedType <> 1
			WHERE CS.intCommodityId = @intCommodityId
				AND CS.intItemId = ISNULL(@intItemId, CS.intItemId)
				AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
				--AND strType IN ('Settlement','Reverse Settlement')
				--AND SH.intSettleStorageId IS NULL
				--AND S.ysnDPOwnedType <> 1
		) a
	) t

	--Previous value start 
	INSERT INTO @tblResultInventory (BalanceForward)
	SELECT sum(BalanceForward) BalanceForward
	FROM (
		SELECT BalanceForward + tranDSInQty as BalanceForward FROM #temp
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
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
		, ISNULL(ABS(tranShipQty),0) + CASE WHEN dblInvoiceQty < 0 THEN ABS(dblInvoiceQty) ELSE 0 END
		, tranReceiptNumber
		, ISNULL(tranRecQty,0) + CASE WHEN dblInvoiceQty > 0 THEN dblInvoiceQty ELSE 0 END
		, tranAdjNumber
		, dblAdjustmentQty
		, tranCountNumber
		, dblCountQty
		, tranInvoiceNumber
		, dblInvoiceQty
		, ISNULL(tranRecQty,0) - ISNULL(ABS(tranShipQty),0) + ISNULL(dblAdjustmentQty,0) + ISNULL(dblCountQty,0) + ISNULL(dblInvoiceQty,0) BalanceForward
		, dblSalesInTransit
		, tranDSInQty
	FROM (
		SELECT *
		FROM #temp
		WHERE CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
	) t

	DROP TABLE #LicensedLocation

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
		FROM @tblResultInventory T1 
		GROUP BY dtmDate
	)t
END