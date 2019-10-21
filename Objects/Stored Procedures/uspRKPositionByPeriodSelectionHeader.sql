CREATE PROC [dbo].[uspRKPositionByPeriodSelectionHeader]
	@intCommodityId INT
	, @intCompanyLocationId NVARCHAR(MAX)
	, @intQuantityUOMId INT
	, @intItemId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY
	DECLARE @strCommodityCode NVARCHAR(100)
	
	SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
	
	SELECT intSeqId = 1
		, strType = 'Ownership'
		, dblTotal = ISNULL(invQty, 0) + ISNULL(ReserveQty, 0) + ISNULL(InTransite, 0) + (ISNULL(dblPurchase,0) - ISNULL(dblSales,0))
	INTO #temp
	FROM (
		SELECT invQty = (SELECT SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(it1.dblUnitOnHand, 0)), 0))
						FROM tblICItem i
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
						INNER JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
						INNER JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
						JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = i.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
						INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
						WHERE i.intCommodityId = @intCommodityId
							AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
							ANd i.intItemId = ISNULL(@intItemId, i.intItemId))
			, ReserveQty = (SELECT SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(sr1.dblQty, 0)), 0))
						FROM tblICItem i
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId
						INNER JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
						INNER JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
						JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = i.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
						INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
						WHERE i.intCommodityId = @intCommodityId
							AND il.intLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
							AND i.intItemId = ISNULL(@intItemId, i.intItemId))
			, InTransite = (SELECT SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblStockQty, 0)), 0))
						FROM vyuLGInventoryView iv
						JOIN tblICItem i ON iv.intItemId = i.intItemId
						JOIN vyuRKPositionByPeriodContDetView cd ON iv.intContractDetailId = cd.intContractDetailId AND cd.intContractStatusId <> 3
						JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
						JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
						WHERE cd.intCommodityId = @intCommodityId
							AND cd.intCompanyLocationId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
							AND i.intItemId = ISNULL(@intItemId, i.intItemId))
			, dblSales = (SELECT ISNULL(SUM(dblOriginalQuantity), 0) - ISNULL(SUM(dblAdjustmentAmount), 0) dblTotal
						FROM (
							SELECT dblAdjustmentAmount = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblAdjustmentAmount, 0)), 0))
								, c.intCollateralId
								, dblOriginalQuantity = (SELECT ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblOriginalQuantity, 0)), 0)
														FROM tblRKCollateral cc
														WHERE cc.intCollateralId = c.intCollateralId)
							FROM tblRKCollateral c
							JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
							JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = c.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
							LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
							WHERE strType = 'Sale'
								AND c.intCommodityId = @intCommodityId
								AND c.intLocationId IN (SELECT Item COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
							GROUP BY c.intCollateralId
								, ium.intCommodityUnitMeasureId
								, ium1.intCommodityUnitMeasureId) t
						WHERE dblAdjustmentAmount <> dblOriginalQuantity)
			, dblPurchase = (SELECT ISNULL(SUM(dblOriginalQuantity), 0) - ISNULL(SUM(dblAdjustmentAmount), 0) dblTotal
							FROM (
								SELECT dblAdjustmentAmount = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblAdjustmentAmount, 0)), 0))
									, c.intCollateralId
									, dblOriginalQuantity = (SELECT ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblOriginalQuantity, 0)), 0)
															FROM tblRKCollateral cc
															WHERE cc.intCollateralId = c.intCollateralId)
								FROM tblRKCollateral c
								JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
								JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = c.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
								LEFT JOIN tblRKCollateralAdjustment ca ON c.intCollateralId = ca.intCollateralId
								WHERE strType = 'Purchase'
									AND c.intCommodityId = @intCommodityId
									AND c.intLocationId IN (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
								GROUP BY c.intCollateralId
									, ium.intCommodityUnitMeasureId
									, ium1.intCommodityUnitMeasureId) t
							WHERE dblAdjustmentAmount <> dblOriginalQuantity)) t

	UNION SELECT intSeqId = 2
		, strType = 'Delayed Price'
		, dblTotal = dblBalance
	FROM (
		SELECT dblBalance = (CASE WHEN (gh.strType = 'Reduced By Inventory Shipment' OR gh.strType = 'Settlement')
									THEN - SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(gh.dblUnits, 0)), 0))
								ELSE SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(gh.dblUnits, 0)), 0)) END)
		FROM tblGRStorageHistory gh
		LEFT JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
		LEFT JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
		LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
		LEFT JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = a.intCommodityId AND a.intUnitMeasureId = ium.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = a.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
		WHERE ISNULL(a.strStorageType,'') <> 'ITR'
			AND b.ysnDPOwnedType = 1
			AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V'
			AND a.intCommodityId = @intCommodityId
			AND a.intItemId = ISNULL(@intItemId, a.intItemId)
		GROUP BY gh.strType) t


	UNION SELECT intSeqId = 3
		, strType = 'Purchase Basis Delivery'
		, dblTotal = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(ris.dblReceived, 0)), 0))
	FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
	INNER JOIN vyuICGetReceiptItemSource ris ON ris.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
	INNER JOIN vyuRKPositionByPeriodContDetView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId 
	JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
	WHERE cd.intCommodityId = @intCommodityId AND cd.intCompanyLocationId IN (SELECT Item COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		AND ri.intItemId = ISNULL(@intItemId, ri.intItemId)
		
	UNION SELECT intSeqId = 4
		, strType = 'Sales Basis Delivery'
		, dblTotal = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(ri.dblQuantity, 0)), 0))
	FROM tblICInventoryShipment r
	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
	INNER JOIN vyuRKPositionByPeriodContDetView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
	JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
	WHERE cd.intCommodityId = @intCommodityId
		AND ri.intItemId = ISNULL(@intItemId, ri.intItemId)
		AND cd.intCompanyLocationId IN (SELECT Item COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ','))
		
	SELECT @strCommodityCode
		, strType = 'Inventory'
		, strSecondSubHeading = 'Inventory'
		, strSubHeading = strType
		, strMonth = 'Inventory'
		, dblTotal = ROUND(ISNULL(dblTotal, 0), 4)
	FROM #temp

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH