﻿CREATE PROCEDURE [dbo].[uspRKGenerateDPI]
	@dtmFromTransactionDate DATE = null
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = null
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL
	, @GUID UNIQUEIDENTIFIER = NULL

AS

BEGIN
	DECLARE @intDPIHeaderId INT
	SELECT intCompanyLocationId
	INTO #LicensedLocations
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END
	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END

	SELECT TOP 1 @intDPIHeaderId = intDPIHeaderId FROM tblRKDPIHeader WHERE imgReportId = @GUID
	IF ISNULL(@intDPIHeaderId, 0) = 0
	BEGIN
		INSERT INTO tblRKDPIHeader(imgReportId
			, strPositionIncludes
			, dtmStartDate
			, dtmEndDate
			, intCommodityId
			, intItemId
			, intLocationId)
		VALUES (@GUID
			, @strPositionIncludes
			, @dtmFromTransactionDate
			, @dtmToTransactionDate
			, @intCommodityId
			, @intItemId
			, @intLocationId)

		SET @intDPIHeaderId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE tblRKDPIHeader
		SET strPositionIncludes = @strPositionIncludes
			, dtmStartDate = @dtmFromTransactionDate
			, dtmEndDate = @dtmToTransactionDate
			, intCommodityId = @intCommodityId
			, intItemId = @intItemId
			, intLocationId = @intItemId
		WHERE intDPIHeaderId = @intDPIHeaderId

		DELETE FROM tblRKDPISummary WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPIInventory WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPICompanyOwnership WHERE intDPIHeaderId = @intDPIHeaderId
	END

	DECLARE @intCommodityUnitMeasureId INT = NULL
			, @ysnIncludeDPPurchasesInCompanyTitled BIT
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
	
	SELECT TOP 1 @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference

	------------------------------------
	---- Generate Company Ownership ----
	------------------------------------
	DECLARE @dtmOrigFromTransactionDate DATETIME

	--Grab the original start date and assinged to a varialbe to be used laster on.
	SET @dtmOrigFromTransactionDate = @dtmFromTransactionDate
	--Set the Start date as the beggining date "1900"
	SET @dtmFromTransactionDate =  '1900-01-01 00:00:00'

	DECLARE @CompanyOwnershipResult TABLE (Id INT identity(1, 1)
		, dtmDate DATETIME
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24, 10)
		, dblUnpaidOut NUMERIC(24, 10)
		, dblUnpaidBalance NUMERIC(24, 10)
		, dblPaidBalance  NUMERIC(24, 10)
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, InventoryBalanceCarryForward NUMERIC(24, 10)
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intReceiptId INT)
	
	DECLARE @DPTable TABLE (Id INT IDENTITY(1, 1)
		, dtmDate DATETIME
		, dblBalance NUMERIC(24, 10)
		, intStorageTypeId INT
		, strStorageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intCommodityUnitMeasureId INT
		, intTicketId INT
		, strTicketType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId INT
		, intInventoryShipmentId INT
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intStorageScheduleTypeId INT
		, intCommodityId INT
		, intCompanyLocationId INT
		, ysnDPOwnedType BIT
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS)

	IF (@ysnIncludeDPPurchasesInCompanyTitled = 1)
	BEGIN
		INSERT INTO @DPTable
		SELECT *
		FROM (
			SELECT CONVERT(VARCHAR(10), gh.dtmDistributionDate,110) dtmDate
				, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
				, a.intStorageTypeId
				, strStorageType = b.strStorageTypeDescription
				, i.intItemId
				, i.strItemNo
				, ium.intCommodityUnitMeasureId
				, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
									WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
									WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
									ELSE gh.intCustomerStorageId END)
				, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
									WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
									WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
									ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
				, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
									WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
									WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
									ELSE a.strStorageTicketNumber END)
				, gh.intInventoryReceiptId
				, gh.intInventoryShipmentId
				, strReceiptNumber = ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '')
				, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
				, b.intStorageScheduleTypeId
				, a.intCommodityId
				, a.intCompanyLocationId
				, ysnDPOwnedType
				, strDistributionOption = 'DP'
			FROM tblGRStorageHistory gh
			JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			JOIN tblICItem i ON i.intItemId = a.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
			WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
				AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
				
			UNION ALL
			SELECT CONVERT(VARCHAR(10), gh.dtmDistributionDate,110) dtmDate
				, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
				, a.intStorageTypeId
				, strStorageType = b.strStorageTypeDescription
				, i.intItemId
				, i.strItemNo
				, ium.intCommodityUnitMeasureId
				, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
									WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
									WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
									ELSE gh.intCustomerStorageId END)
				, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
									WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
									WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
									ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
				, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN NULL
									WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
									WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
									ELSE a.strStorageTicketNumber END)
				, intInventoryReceiptId = (CASE WHEN gh.strType = 'From Inventory Adjustment' THEN gh.intInventoryAdjustmentId ELSE gh.intInventoryReceiptId END)
				, gh.intInventoryShipmentId
				, strReceiptNumber = (CASE WHEN gh.strType ='From Inventory Adjustment' THEN gh.strTransactionId
										ELSE ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '') END)
				, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
				, b.intStorageScheduleTypeId
				, a.intCommodityId
				, a.intCompanyLocationId
				, ysnDPOwnedType
				, strDistributionOption = 'DP'
			FROM tblGRStorageHistory gh
			JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			JOIN tblICItem i ON i.intItemId = a.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
				AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
		)t
	END	

	SELECT strItemNo
		, dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidIn - dblUnpaidOut as dblUnpaidBalance
		, CASE WHEN ysnPaid = 0 AND dblUnpaidOut = 0 THEN 0 ELSE  dblUnpaidOut END  as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	INTO #tmpCompanyOwnership
	FROM (
		--From Settle Storage
		SELECT *
			, round(dblInQty, 2) dblUnpaidIn
			, round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110) dtmDate
				, gr.dblUnits dblUnitCost1
				, '' as intInventoryReceiptItemId--ir.intInventoryReceiptItemId
				, i.strItemNo
				, ISNULL(bd.dblQtyReceived, 0) dblInQty
				, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				, gs.strStorageTypeCode  as strDistributionOption
				, b.strBillId AS strReceiptNumber
				, b.intBillId AS intReceiptId
				, b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			INNER JOIN tblGRStorageHistory gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRCustomerStorage grs ON  gr.intCustomerStorageId = grs.intCustomerStorageId
			INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=grs.intStorageTypeId 
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110)
				AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(i.strType, '') <> 'Other Charge'
				AND b.intShipToId = ISNULL(@intLocationId, b.intShipToId)
				AND gs.strStorageTypeCode NOT IN ('CNT', '')

		) t
	) t2
	
	UNION ALL SELECT i.strItemNo
		, CONVERT(VARCHAR(10), dtmTicketDateTime, 110) AS dtmDate
		, dblGrossUnits AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblGrossUnits AS dblUnpaidBalance
		, dblGrossUnits as dblPaidBalance
		, strDistributionOption 
		, r.strReceiptNumber
		, r.intInventoryReceiptId
	FROM tblICInventoryReceiptItem ir
	JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
	JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	JOIN tblICItem i ON i.intItemId = ir.intItemId
	JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND ISNULL(ysnDPOwnedType, 0) = 1
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110))
		AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge'
		AND ir.intSubLocationId = ISNULL(@intLocationId, ir.intSubLocationId)
		AND st.strDistributionOption NOT IN ('CNT', '')
	
	--IS decressing the Unpaid Balance and Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblInQty as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, SI.dblUnitPrice dblUnitCost1
			, SI.intInventoryShipmentItemId
			, I.strItemNo
			, ABS(ISNULL(SI.dblQuantity, 0)) * -1 dblInQty
			, 0 AS dblOutQty
			, CASE WHEN SI.intStorageScheduleTypeId IS NULL AND SI.intOrderId IS NULL THEN 'SPT' COLLATE Latin1_General_CI_AS WHEN SI.intOrderId IS NOT NULL THEN ST.strDistributionOption ELSE STT.strStorageTypeCode END strDistributionOption
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.strInvoiceNumber ELSE  S.strShipmentNumber END AS strReceiptNumber
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.intInvoiceId ELSE  S.intInventoryShipmentId END  AS intReceiptId
		FROM vyuSCTicketView ST
		INNER JOIN tblICInventoryShipmentItem SI ON ST.intTicketId = SI.intSourceId
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
		LEFT JOIN tblARInvoice Inv ON ID.intInvoiceId = Inv.intInvoiceId
		LEFT JOIN tblGRStorageType STT ON SI.intStorageScheduleTypeId = STT.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND SI.intOwnershipType = 1
	)t

	--IR decressing the Unpaid Balance and Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, ISNULL(RI.dblNet, 0) dblInQty
			, 0 AS dblOutQty
			, GST.strStorageTypeCode strDistributionOption
			, R.strReceiptNumber AS strReceiptNumber
			, R.intInventoryReceiptId AS intReceiptId
		FROM tblSCTicket ST
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON ST.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
			--AND RI.dblBillQty = 0
			AND R.intSourceType = 1
			AND RI.intInventoryReceiptItemId NOT IN (select intInventoryReceiptItemId from tblGRSettleStorage gr 
					INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
					INNER JOIN vyuSCGetScaleDistribution sc ON  grt.intCustomerStorageId = sc.intCustomerStorageId)
	) t
	
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblAdjustmentQty as dblPaidBalance
		, 'ADJ' COLLATE Latin1_General_CI_AS as strDistributionOption
		, strAdjustmentNo as strReceiptNumber
		, intInventoryAdjustmentId as intReceiptId
	FROM (
		--Own
		SELECT CONVERT(VARCHAR(10),IT.dtmDate,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
			, IT.strTransactionId strAdjustmentNo
			, IT.intTransactionId intInventoryAdjustmentId
			, strItemNo
		FROM tblICInventoryTransaction IT
		INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		WHERE IT.intTransactionTypeId IN (10,15,47) AND IT.ysnIsUnposted = 0
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND IT.intItemId = ISNULL(@intItemId, IT.intItemId)
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
	)a

	--Inventory Transfers
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblTransferQty as dblPaidBalance
		, '' COLLATE Latin1_General_CI_AS as strDistributionOption
		, strTransactionId as strReceiptNumber
		, intTransactionId as intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(SUM(it.dblQty),0)) dblTransferQty
			, it.intTransactionId
			, i.strItemNo
			, it.strTransactionId
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(12)
		join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
		JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			and ISNULL(il.strDescription,'') <> 'In-Transit'
		WHERE i.intCommodityId=@intCommodityId  
			and i.intItemId = ISNULL(@intItemId, i.intItemId)
			and il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
			and CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		group by dtmDate, strItemNo, it.intTransactionId, it.strTransactionId, intCommodityUnitMeasureId
	)a WHERE dblTransferQty <> 0

	--Delivery Sheet
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			,RI.dblUnitCost dblUnitCost1
			,RI.intInventoryReceiptItemId
			,I.strItemNo
			,ISNULL(RI.dblNet, 0) - ISNULL(RI.dblBillQty,0) dblInQty
			,0 AS dblOutQty
			,GST.strStorageTypeCode strDistributionOption
			,R.strReceiptNumber
			,R.intInventoryReceiptId
		FROM tblSCDeliverySheetSplit DSS
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
	)t
	
	--Delivery Sheet With Voucher
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT 
			CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			,RI.dblUnitCost dblUnitCost1
			,RI.intInventoryReceiptItemId
			,I.strItemNo
			,ISNULL(BD.dblQtyReceived, 0) dblInQty
			,0 AS dblOutQty
			,GST.strStorageTypeCode strDistributionOption
			,Bill.strBillId AS strReceiptNumber
			,Bill.intBillId AS intReceiptId
		FROM tblSCDeliverySheetSplit DSS 
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		INNER JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
		INNER JOIN tblAPBill Bill ON BD.intBillId = Bill.intBillId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
			AND ST.intProcessingLocationId = case when ISNULL(@intLocationId,0)=0 then ST.intProcessingLocationId else @intLocationId end 
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND Bill.ysnPosted = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
			AND RI.dblBillQty <> 0
	)t

	--Direct from Invoice
	UNION ALL SELECT strItemNo
		, dtmDate
		,dblInQty AS dblUnpaidIn
		,0 AS dblUnpaidOut
		,0 AS dblUnpaidBalance
		,ABS(dblInQty) + ABS(ISNULL(dblOutQty, 0)) * CASE WHEN dblOutQty < 0 THEN 1 ELSE -1 END as dblPaidBalance
		,strDistributionOption
		,strReceiptNumber
		,intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
			,0 dblUnitCost1
			,I.intInvoiceId intInventoryReceiptItemId
			,Itm.strItemNo
			,CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(ID.dblQtyShipped, 0) ELSE 0.0  END dblInQty
			,CASE WHEN I.strTransactionType = 'Credit Memo' THEN 0.0 ELSE ISNULL(ID.dblQtyShipped, 0)  END dblOutQty
			,'' strDistributionOption
			,I.strInvoiceNumber AS strReceiptNumber
			,I.intInvoiceId AS intReceiptId
		FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblICItemLocation ItmLoc ON  Itm.intItemId = ItmLoc.intItemId AND I.intCompanyLocationId = ItmLoc.intLocationId
		WHERE I.ysnPosted = 1
			AND ID.intInventoryShipmentItemId IS NULL
			AND ID.intInventoryShipmentChargeId IS NULL
			AND Itm.strType IN ('Inventory', 'Raw Material', 'Finished Good')
			AND I.strTransactionType NOT IN  ('Customer Prepayment')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND ID.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
			AND I.intCompanyLocationId = case when ISNULL(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
			AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND (( (ID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ID.[intItemId], ItmLoc.[intItemLocationId], ID.[intItemUOMId]) <> 0)) ) 
	)t

	--Direct Inventory Shipment (This will show the Invoice Number once Shipment is invoiced)
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblInQty as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryShipmentItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), S.dtmShipDate, 110) dtmDate
			, SI.dblUnitPrice dblUnitCost1
			, SI.intInventoryShipmentItemId
			, Itm.strItemNo
			, ABS(ISNULL(SI.dblQuantity, 0)) * -1 dblInQty
			, 0 AS dblOutQty
			, '' strDistributionOption
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.strInvoiceNumber ELSE  S.strShipmentNumber END AS strReceiptNumber
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.intInvoiceId ELSE  S.intInventoryShipmentId END  AS intReceiptId
		FROM tblICInventoryShipmentItem SI 
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId AND ID.intInventoryShipmentItemId IS NOT NULL
		LEFT JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		WHERE S.ysnPosted = 1
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
			AND S.intShipFromLocationId = ISNULL(@intLocationId, S.intShipFromLocationId)
			AND S.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND SI.intOwnershipType = 1
			AND S.intSourceType = 0
	) t

	--Direct Inventory Receipt (This will show the Bill Number once Receipt is vouchered)
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), R.dtmReceiptDate, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, Itm.strItemNo
			, ISNULL(RI.dblOpenReceive, 0) dblInQty
			, 0 AS dblOutQty
			, '' strDistributionOption
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.strBillId ELSE  R.strReceiptNumber END AS strReceiptNumber
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.intBillId ELSE  R.intInventoryReceiptId END  AS intReceiptId
		FROM tblICInventoryReceiptItem RI 
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId AND BD.intInventoryReceiptItemId IS NOT NULL
		LEFT JOIN tblAPBill B ON BD.intBillId = B.intBillId
		WHERE R.ysnPosted = 1
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
			AND R.intLocationId = ISNULL(@intLocationId, R.intLocationId)
			AND R.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 0
	) t

	--DP with Settle Storage
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10),SH.dtmDistributionDate,110) dtmDate
			, S.strStorageTypeCode strDistributionOption
			, 0  AS dblOutQty
			, CASE WHEN SH.strType = 'Settlement' THEN ABS(dblUnits)
					WHEN  SH.strType = 'Reverse Settlement' THEN ABS(dblUnits) * -1
					ELSE 0 END AS dblInQty
			, S.intStorageScheduleTypeId
			, SH.intSettleStorageId as intInventoryReceiptItemId
			, SH.strSettleTicket as strReceiptNumber
			, I.strItemNo
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
		INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
		INNER JOIN tblICItem I ON CS.intItemId = I.intItemId
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmDistributionDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND CS.intCommodityId = @intCommodityId
			AND CS.intItemId = ISNULL(@intItemId, CS.intItemId)
			AND CS.intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
			AND SH.strType IN ('Settlement','Reverse Settlement')
			AND S.ysnDPOwnedType = 1
			AND SH.intBillId IS NULL
	) t

	-- DP Table
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblUnpaidIn = SUM(dblTotal)
		, dblUnpaidOut = 0.00
		, dblUnpaidBalance = SUM(dblTotal)
		, dblPaidBalance = 0.00
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId = intInventoryReceiptId
	FROM (
		SELECT intTicketId
			, strTicketType
			, strTicketNumber
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
			, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
			, dtmDate
			, intItemId
			, strItemNo
			, intCompanyLocationId
			, strDistributionOption
			, strReceiptNumber
			, intInventoryReceiptId
		FROM @DPTable ch
		WHERE ch.intCommodityId  = @intCommodityId
			AND ysnDPOwnedType = 1
			AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
		)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	GROUP BY strItemNo
		, dtmDate
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptId

	--Get Balance Forward
	INSERT INTO @CompanyOwnershipResult (dblUnpaidBalance
		, InventoryBalanceCarryForward)
	select sum(dblUnpaidBalance), sum(dblPaidBalance) from #tmpCompanyOwnership WHERE dtmDate < @dtmOrigFromTransactionDate

	--Filter it by orignal filter date
	INSERT INTO @CompanyOwnershipResult (strItemNo
		, dtmDate
		, strDistributionOption
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, strReceiptNumber
		, intReceiptId)
	SELECT strItemNo
		, ISNULL(dtmDate,'') dtmDate
		, strDistributionOption [strDistribution]
		, dblUnpaidIn [dblUnpaidIN]
		, dblUnpaidOut [dblUnpaidOut]
		, dblUnpaidBalance [dblUnpaidBalance]
		, dblPaidBalance
		, strReceiptNumber
		, intReceiptId
	FROM #tmpCompanyOwnership T1
	WHERE dtmDate between @dtmOrigFromTransactionDate and @dtmToTransactionDate

	INSERT INTO tblRKDPICompanyOwnership(intDPIHeaderId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId)
	SELECT @intDPIHeaderId
		, ISNULL(dtmDate,'') dtmDate
		, strDistributionOption [strDistribution]
		, dblUnpaidIn [dblUnpaidIN]
		, dblUnpaidOut [dblUnpaidOut]
		, dblUnpaidBalance [dblUnpaidBalance]
		, dblPaidBalance
		, InventoryBalanceCarryForward dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM @CompanyOwnershipResult T1
	ORDER BY dtmDate DESC
		, strReceiptNumber DESC

	SET @dtmFromTransactionDate = @dtmOrigFromTransactionDate

	DROP TABLE #tmpCompanyOwnership

	--------------------------------------------
	---- Generate Inventory Balance Headers ----
	--------------------------------------------
	DECLARE @tblDateList TABLE (Id INT identity(1,1)
		, DateData datetime)

	DECLARE @StartDateTime DATETIME
	DECLARE @EndDateTime DATETIME

	SET @StartDateTime = @dtmFromTransactionDate
	SET @EndDateTime = @dtmToTransactionDate;

	WITH DateRange(DateData) AS (
		SELECT @StartDateTime as Date
		UNION ALL
		SELECT DATEADD(d,1,DateData)
		FROM DateRange 
		WHERE DateData < @EndDateTime
	)
	INSERT INTO @tblDateList(DateData)
	SELECT DateData FROM DateRange
	OPTION (MAXRECURSION 0)

	DECLARE @tblResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, [Distribution] nvarchar(50) COLLATE Latin1_General_CI_AS
		, [Unpaid IN] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, [InventoryBalanceCarryForward] NUMERIC(24,10)
		, strReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, intReceiptId int)

	DECLARE @tblFirstResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, tranShipQty NUMERIC(24,10)
		, tranRecQty NUMERIC(24,10)
		, dblAdjustmentQty NUMERIC(24,10)
		, dblCountQty NUMERIC(24,10)
		, dblInvoiceQty NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	DECLARE @tblResultFinal TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, dblUnpaidBalance NUMERIC(24,10)
		, dblPaidBalance NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10))

	DECLARE @CompanyTitleByDate AS TABLE (
			dtmDate  DATE  NULL
			,dblUnpaidIncrease  NUMERIC(18,6)
			,dblUnpaidDecrease  NUMERIC(18,6)
			,dblUnpaidBalance  NUMERIC(18,6)
			,dblPaidBalance  NUMERIC(18,6)
			,dblCompanyTitled  NUMERIC(18,6)
	)

	EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	INSERT INTO @tblResult (intRowNum
		, dtmDate
		, [Distribution]
		, [Unpaid IN]
		, [Unpaid Out]
		, [Unpaid Balance]
		, [Paid Balance]
		, InventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId)
	SELECT intDPICompanyOwnershipId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM tblRKDPICompanyOwnership
	WHERE intDPIHeaderId = @intDPIHeaderId

	INSERT INTO @tblFirstResult (dtmDate
		, tranShipQty
		, tranRecQty
		, dblAdjustmentQty
		, dblCountQty
		, dblInvoiceQty
		, BalanceForward
		, dblSalesInTransit
		, tranDSInQty)
	EXEC uspRKGetInventoryBalance @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId


	
	INSERT INTO @CompanyTitleByDate(
		dtmDate
		,dblUnpaidIncrease
		,dblUnpaidDecrease
		,dblUnpaidBalance 
		,dblPaidBalance
		,dblCompanyTitled
	)
	EXEC uspRKGetCompanyTitled @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	INSERT INTO @tblResultFinal (dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, BalanceForward
		, dblUnpaidBalance
		, dblPaidBalance
		, InventoryBalanceCarryForward)
	SELECT dtmDate
		, sum([Unpaid IN]) tranRecQty
		, sum([Unpaid Out]) tranShipQty
		, sum([Unpaid Balance]) dblUnpaidBalance
		, (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(T1.dtmDate,'01/01/1900')) AS [Unpaid Balance]
		, sum(T1.[Paid Balance]) dblPaidBalance
		, sum(InventoryBalanceCarryForward) InventoryBalanceCarryForward
	FROM @tblResult T1 
	GROUP BY dtmDate

	DECLARE @tblInHouseByDate TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, dblInvIn NUMERIC(24,10)
		, dblInvOut NUMERIC(24,10)
		, dblAdjustments NUMERIC(24,10)
		, dblInventoryCount NUMERIC(24,10)
		, dblBalanceInv NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
	)

	DECLARE @tblConsolidatedResult TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, [Receive In] NUMERIC(24,10)
		, [Ship Out] NUMERIC(24,10)
		, [Adjustments] NUMERIC(24,10)
		, [dblCount] NUMERIC(24,10)
		, [dblInvoiceQty] NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10)
		, [Unpaid In] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, [Balance] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	INSERT INTO @tblInHouseByDate (dtmDate
		, dblInvIn
		, dblInvOut
		, dblAdjustments
		, dblInventoryCount
		, dblBalanceInv
		)
	EXEC uspRKGetInHouse @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId


	SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
		, *
	INTO #final
	FROM (
		SELECT 
			dtmDate
			,dblInvIn
			,dblInvOut
			,dblAdjustments
			,dblInventoryCount
			,dblBalanceInv
			,dblSalesInTransit
		FROM @tblInHouseByDate
	)t2 ORDER BY dtmDate

	INSERT INTO tblRKDPISummary(intDPIHeaderId
		, dtmTransactionDate
		, dblReceiveIn
		, dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance
		, dblSalesInTransit
		, strDistributionA
		, dblAIn
		, dblAOut
		, dblANet
		, strDistributionB
		, dblBIn
		, dblBOut
		, dblBNet
		, strDistributionC
		, dblCIn
		, dblCOut
		, dblCNet
		, strDistributionD
		, dblDIn
		, dblDOut
		, dblDNet
		, strDistributionE
		, dblEIn
		, dblEOut
		, dblENet
		, strDistributionF
		, dblFIn
		, dblFOut
		, dblFNet
		, strDistributionG
		, dblGIn
		, dblGOut
		, dblGNet
		, strDistributionH
		, dblHIn
		, dblHOut
		, dblHNet
		, strDistributionI
		, dblIIn
		, dblIOut
		, dblINet
		, strDistributionJ
		, dblJIn
		, dblJOut
		, dblJNet
		, strDistributionK
		, dblKIn
		, dblKOut
		, dblKNet
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, dblPaidBalance
		, dblTotalCompanyOwned
		, dblUnpaidBalance)
	SELECT DISTINCT @intDPIHeaderId
		, dtmDate
		, dblInvIn 
		, dblInvOut
		, dblAdjustments 
		, dblInventoryCount 
		, dblInvoiceQty = 0
		, dblBalanceInv
		, dblSalesInTransit
		, strDistributionA
		, [dblAIn] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblAIn], 0) END
		, [dblAOut] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblAOut], 0) END
		, [dblANet] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblANet], 0) END
		, strDistributionB
		, [dblBIn] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBIn], 0) END
		, [dblBOut] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBOut], 0) END
		, [dblBNet] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBNet], 0) END
		, strDistributionC
		, [dblCIn] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCIn], 0) END
		, [dblCOut] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCOut], 0) END
		, [dblCNet] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCNet], 0) END
		, strDistributionD
		, [dblDIn] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDIn], 0) END
		, [dblDOut] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDOut], 0) END
		, [dblDNet] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDNet], 0) END
		, strDistributionE
		, [dblEIn] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblEIn], 0) END
		, [dblEOut] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblEOut], 0) END
		, [dblENet] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblENet], 0) END
		, strDistributionF
		, [dblFIn] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFIn], 0) END
		, [dblFOut] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFOut], 0) END
		, [dblFNet] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFNet], 0) END
		, strDistributionG
		, [dblGIn] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGIn], 0) END
		, [dblGOut] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGOut], 0) END
		, [dblGNet] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGNet], 0) END
		, strDistributionH
		, [dblHIn] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHIn], 0) END
		, [dblHOut] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHOut], 0) END
		, [dblHNet] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHNet], 0) END
		, strDistributionI
		, [dblIIn] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblIIn], 0) END
		, [dblIOut] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblIOut], 0) END
		, [dblINet] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblINet], 0) END
		, strDistributionJ
		, [dblJIn] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJIn], 0) END
		, [dblJOut] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJOut], 0) END
		, [dblJNet] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJNet], 0) END
		, strDistributionK
		, [dblKIn] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKIn], 0) END
		, [dblKOut] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKOut], 0) END
		, [dblKNet] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKNet], 0) END
		, dblUnpaidIn = ISNULL(dblUnpaidIn, 0)
		, dblUnpaidOut = ISNULL(dblUnpaidOut, 0)
		, dblBalance = ISNULL(dblBalance, 0)
		, dblPaidBalance = ISNULL(dblPaidBalance, 0)
		, dblTotalCompanyOwned --= (ISNULL(dblBalance, 0) + ISNULL(dblTotalCompanyOwned, 0))
		, dblUnpaidBalance = ISNULL(dblUnpaidBalance, 0)
	FROM (
		SELECT DISTINCT intRowNum
			, list.dtmDate dtmDate
			, dblInvIn
			, dblInvOut
			, dblAdjustments
			, dblInventoryCount
			, dblBalanceInv
			, abs(ISNULL(list.dblSalesInTransit, 0)) dblSalesInTransit
			, strDistributionA = (CASE WHEN strDistributionA is null then (SELECT DISTINCT TOP 1 strDistributionA FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionA,'') <>'') else strDistributionA end)
			, [dblAIn]
			, [dblAOut]
			, [dblANet] = (SELECT SUM(dblANet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionB = (CASE WHEN strDistributionB is null then (SELECT DISTINCT TOP 1 strDistributionB FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionB,'') <>'') else strDistributionB end)
			, [dblBIn]
			, [dblBOut]
			, [dblBNet] = (SELECT SUM(dblBNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionC = (CASE WHEN strDistributionC is null then (SELECT DISTINCT TOP 1 strDistributionC FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionC,'') <>'') else strDistributionC end)
			, [dblCIn]
			, [dblCOut]
			, [dblCNet] = (SELECT SUM(dblCNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionD = (CASE WHEN strDistributionD is null then (SELECT DISTINCT TOP 1 strDistributionD FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionD,'') <>'') else strDistributionD end)
			, [dblDIn]
			, [dblDOut]
			, [dblDNet] = (SELECT SUM(dblDNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionE = (CASE WHEN strDistributionE is null then (SELECT DISTINCT TOP 1 strDistributionE FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionE,'') <>'') else strDistributionE end)
			, [dblEIn]
			, [dblEOut]
			, [dblENet] = (SELECT SUM(dblENet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionF = (CASE WHEN strDistributionF is null then (SELECT DISTINCT TOP 1 strDistributionF FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionF,'') <>'') else strDistributionF end)
			, [dblFIn]
			, [dblFOut]
			, [dblFNet] = (SELECT SUM(dblFNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionG = (CASE WHEN strDistributionG is null then (SELECT DISTINCT TOP 1 strDistributionG FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionG,'') <>'') else strDistributionG end)
			, [dblGIn]
			, [dblGOut]
			, [dblGNet] = (SELECT SUM(dblGNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionH = (CASE WHEN strDistributionH is null then (SELECT DISTINCT TOP 1 strDistributionH FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionH,'') <>'') else strDistributionH end)
			, [dblHIn]
			, [dblHOut]
			, [dblHNet] = (SELECT SUM(dblHNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionI = (CASE WHEN strDistributionI is null then (SELECT DISTINCT TOP 1 strDistributionI FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionI,'') <>'') else strDistributionI end)
			, [dblIIn]
			, [dblIOut]
			, [dblINet] = (SELECT SUM(dblINet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionJ = (CASE WHEN strDistributionJ is null then (SELECT DISTINCT TOP 1 strDistributionJ FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionJ,'') <>'') else strDistributionJ end)
			, [dblJIn]
			, [dblJOut]
			, [dblJNet] = (SELECT SUM(dblJNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionK = (CASE WHEN strDistributionK is null then (SELECT DISTINCT TOP 1 strDistributionK FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionK,'') <>'') else strDistributionK end)
			, [dblKIn]
			, [dblKOut]
			, [dblKNet] = (SELECT SUM(dblKNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, dblUnpaidIn = ct.dblUnpaidIncrease
			, dblUnpaidOut = ct.dblUnpaidDecrease
			, dblBalance = ct.dblUnpaidBalance
			, dblPaidBalance = ct.dblPaidBalance
			, dblTotalCompanyOwned = ct.dblCompanyTitled
			, dblUnpaidBalance = ct.dblUnpaidBalance
		FROM #final list
		FULL JOIN tblRKDailyPositionForCustomer t ON ISNULL(t.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
		FULL JOIN @CompanyTitleByDate ct ON ISNULL(ct.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
	)t 
	ORDER BY dtmDate


	----------------------------------
	---- Generate Grain Inventory ----
	----------------------------------
	DECLARE @tblInvResult TABLE (Id INT identity(1,1)
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

	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END
	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END

	INSERT INTO @tblInvResult(dtmDate
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
		, round(ISNULL(tranShipQty,0)+ISNULL(tranRecQty,0)+ISNULL(dblAdjustmentQty,0)+ISNULL(dblCountQty,0),6) BalanceForward
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
			JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
			JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
			join tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId = @intCommodityId
				and i.intItemId = ISNULL(@intItemId, i.intItemId) and ISNULL(strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
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
			JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			join tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
			join tblGRStorageHistory gsh on gsh.intInventoryReceiptId = r.intInventoryReceiptId
			join tblGRCustomerStorage gh on gh.intCustomerStorageId = gsh.intCustomerStorageId
			JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId = gh.intStorageTypeId 
			join tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=1 AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId= @intCommodityId and i.intItemId = ISNULL(@intItemId, i.intItemId) and ISNULL(i.strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
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
			INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			WHERE IT.intTransactionTypeId IN (10,15,47)
				AND IT.ysnIsUnposted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId 
				AND IT.intItemId = ISNULL(@intItemId, IT.intItemId) AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		
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
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId 
				AND IAD.intItemId = ISNULL(@intItemId, IAD.intItemId)
				AND IA.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
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
										AND  st.intProcessingLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
			join tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
			LEFT JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=ri.intStorageScheduleTypeId  
			JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN
			 CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND i.intCommodityId= @intCommodityId
			and i.intItemId= ISNULL(@intItemId, i.intItemId) and ISNULL(strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
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
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND i.intCommodityId= @intCommodityId
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) and ISNULL(strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
			AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
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
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId
				AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
				AND R.intLocationId = ISNULL(@intLocationId, R.intLocationId)
				AND R.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
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
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND Itm.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
			AND S.intShipFromLocationId = case when ISNULL(@intLocationId,0)=0 then S.intShipFromLocationId else @intLocationId end 
			AND S.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND SI.intOwnershipType = 1
			AND S.intSourceType = 0 
		)a

	UNION ALL --Direct Invoice
	SELECT dtmDate,'' strDistributionOption,strDistributionOption strShipDistributionOption,
			'' as strAdjDistributionOption,
			'' as strCountDistributionOption,
			strShipmentNumber tranShipmentNumber,
			CASE WHEN strTransactionType = 'Credit Memo' THEN 0.0 ELSE  ISNULL(dblOutQty, 0) END  tranShipQty,
			'' tranReceiptNumber,
			CASE WHEN strTransactionType = 'Credit Memo' THEN ISNULL(dblOutQty, 0) ELSE 0.0 END tranRecQty,
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
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND ID.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
			AND I.intCompanyLocationId = case when ISNULL(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
			AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
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
												AND  il.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				and ISNULL(il.strDescription,'') <> 'In-Transit'
			WHERE i.intCommodityId=@intCommodityId
				and i.intItemId = ISNULL(@intItemId, i.intItemId)
				and il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
				and CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
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
			JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				and ISNULL(il.strDescription,'') <> 'In-Transit'
			WHERE i.intCommodityId=@intCommodityId  
			and i.intItemId = ISNULL(@intItemId, i.intItemId)
			and il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
			and CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
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
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110)
				BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND CS.intCommodityId = @intCommodityId
				and CS.intItemId = ISNULL(@intItemId, CS.intItemId)
				AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
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

				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110) BETWEEN
										CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
									AND CS.intCommodityId= @intCommodityId
									and CS.intItemId= case when ISNULL(@intItemId,0)=0 then CS.intItemId else @intItemId end 
									AND  CS.intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocations)
									AND CS.intCompanyLocationId = case when ISNULL(@intLocationId,0)=0 then CS.intCompanyLocationId  else @intLocationId end
									AND strType IN ('Settlement','Reverse Settlement')
									AND SH.intSettleStorageId IS NULL
									AND S.ysnDPOwnedType <> 1
		) a

	

	 )t

	INSERT INTO tblRKDPIInventory(intDPIHeaderId
		, dtmTransactionDate
		, strReceiptNumber
		, strDistribution
		, dblIn
		, strShipTicketNo
		, dblOut
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, strDeliverySheetNumber
		, intTicketId
		, strTicketNumber)
	SELECT @intDPIHeaderId
		, dtmDate
		, strReceiptNumber
		, strDistribution
		, dblIN
		, strShipTicketNo
		, dblOUT
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
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
	FROM (
		SELECT DISTINCT dtmDate [dtmDate]
			, case when ISNULL(tranReceiptNumber,'') <> '' then tranReceiptNumber
					when ISNULL(tranShipmentNumber,'') <> '' then tranShipmentNumber
					when ISNULL(tranAdjNumber,'') <> '' then tranAdjNumber
					when ISNULL(tranInvoiceNumber,'') <> '' then tranInvoiceNumber
					when ISNULL(tranCountNumber,'') <> '' then tranCountNumber
					when ISNULL(deliverySheetNumber,'') <> '' then deliverySheetNumber
					when ISNULL(ticketNumber,'') <> '' then ticketNumber end [strReceiptNumber]
			, CASE WHEN ISNULL(strDistributionOption,'') <> '' THEN strDistributionOption
					WHEN ISNULL(strShipDistributionOption,'') <> '' then strShipDistributionOption
					WHEN ISNULL(strAdjDistributionOption,'') <> '' then strAdjDistributionOption END strDistribution
			, tranRecQty [dblIN]
			, ISNULL(tranShipmentNumber,'') [strShipTicketNo]
			, ISNULL(tranShipQty,0) + ISNULL(dblInvoiceQty,0) [dblOUT]
			, tranAdjNumber [strAdjNo]
			, dblAdjustmentQty [dblAdjQty]
			, tranCountNumber [strCountNumber]
			, dblCountQty [dblCountQty]
			, BalanceForward dblDummy
			, (SELECT SUM(BalanceForward) FROM @tblInvResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward
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
		FROM @tblInvResult T1
	)t order by dtmDate desc,strReceiptNumber desc

	DROP TABLE #LicensedLocations

END