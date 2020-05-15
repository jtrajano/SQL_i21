CREATE PROCEDURE [dbo].[uspICLogRiskPositionFromOnHand]
	@strBatchId AS NVARCHAR(40)
	,@strTransactionId AS NVARCHAR(50) = NULL 
	,@intBucketType AS INT = 1
	,@intActionType AS INT 
	,@intEntityUserSecurityId AS INT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strBucketType AS NVARCHAR(50) 
		,@strActionType AS NVARCHAR(500)

SELECT @strBucketType = 
	CASE 
		WHEN @intBucketType = 1 THEN 'Company Owned'
		WHEN @intBucketType = 2 THEN 'Sales In-Transit'
		WHEN @intBucketType = 3 THEN 'Purchase In-Transit'
		WHEN @intBucketType = 4 THEN 'In-House'
	END

SELECT @strActionType =
	CASE 
		WHEN @intActionType = 1 THEN 'Work Order Production'
		WHEN @intActionType = 2 THEN 'Work Order Consumption'
		WHEN @intActionType = 3 THEN 'Inventory Adjustment'
		WHEN @intActionType = 4 THEN 'Inventory Transfer'
		WHEN @intActionType = 5 THEN 'Receipt on Purchase Priced Contract'
		WHEN @intActionType = 6 THEN 'Receipt on Purchase Basis Contract (PBD)'
		WHEN @intActionType = 7 THEN 'Receipt on Company Owned Storage'
		WHEN @intActionType = 8 THEN 'Receipt on Spot Priced'
		WHEN @intActionType = 9 THEN 'Customer owned to Company owned Storage'
		WHEN @intActionType = 10 THEN 'Delivery on Sales Priced Contract'
		WHEN @intActionType = 11 THEN 'Delivery on Sales Basis Contract (SBD)'
		WHEN @intActionType = 12 THEN 'Shipment on Spot Priced'
	END

-----------------------------------------
-- Call Risk Module's Summary Log sp
-----------------------------------------
BEGIN 
	DECLARE @SummaryLogs AS RKSummaryLog 

	BEGIN 
		INSERT INTO @SummaryLogs (	
			strBatchId
			,strBucketType
			,strTransactionType
			,intTransactionRecordHeaderId
			,intTransactionRecordId
			,strTransactionNumber 
			,dtmTransactionDate 
			,intContractDetailId 
			,intContractHeaderId 
			,intTicketId 
			,intCommodityId 
			,intCommodityUOMId 
			,intItemId 
			,intBookId 
			,intSubBookId 
			,intLocationId 
			,intFutureMarketId 
			,intFutureMonthId 
			,dblNoOfLots 
			,dblQty 
			,dblPrice 
			,intEntityId 
			,ysnDelete 
			,intUserId 
			,strNotes
			,strDistributionType
			--,intInventoryTransactionId
		)
		SELECT 
			strBatchId = t.strBatchId
			,strBucketType = @strBucketType
			,strTransactionType = v.strTransactionType
			,intTransactionRecordHeaderId = t.intTransactionId
			,intTransactionRecordId = t.intTransactionDetailId
			,strTransactionNumber = t.strTransactionId
			,dtmTransactionDate = t.dtmDate
			,intContractDetailId = NULL
			,intContractHeaderId = NULL
			,intTicketId = v.intTicketId
			,intCommodityId = v.intCommodityId
			,intCommodityUOMId = commodityUOM.intCommodityUnitMeasureId
			,intItemId = t.intItemId
			,intBookId = NULL
			,intSubBookId = NULL
			,intLocationId = v.intLocationId
			,intFutureMarketId = NULL
			,intFutureMonthId = NULL
			,dblNoOfLots = NULL
			,dblQty = t.dblQty
			,dblPrice = t.dblCost
			,intEntityId = v.intEntityId
			,ysnDelete = 0
			,intUserId = @intEntityUserSecurityId
			,strNotes = t.strDescription
			,strDistributionType = ''
			--,intInventoryTransactionId = t.intInventoryTransactionId
		FROM	
			tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
				ON t.intInventoryTransactionId = v.intInventoryTransactionId
			INNER JOIN tblICItemUOM iu
				ON iu.intItemUOMId = t.intItemUOMId
			INNER JOIN tblICUnitMeasure u
				ON u.intUnitMeasureId = iu.intUnitMeasureId
			INNER JOIN tblICCommodityUnitMeasure commodityUOM
				ON commodityUOM.intCommodityId = v.intCommodityId 
				AND commodityUOM.intUnitMeasureId = u.intUnitMeasureId	

		WHERE
			(t.strTransactionId = @strTransactionId OR @strTransactionId IS NULL) 
			AND t.strBatchId = @strBatchId
			AND t.dblQty <> 0 
			AND v.ysnInTransit = 0
			AND ISNULL(t.ysnIsUnposted,0) = 0
	END
	
	EXEC uspRKLogRiskPosition @SummaryLogs
END 

