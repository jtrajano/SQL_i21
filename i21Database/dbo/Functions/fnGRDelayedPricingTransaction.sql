CREATE FUNCTION [dbo].[fnGRDelayedPricingTransaction] (
    @dtmDate DATETIME
	,@intCommodityId INT
	,@intLocationId INT
	,@intItemId INT = NULL
)
RETURNS TABLE AS RETURN
SELECT
    dtmDate = DP.dtmTransactionDate
    ,strTransactionNumber
    ,dblDPQty = SUM(CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
                        THEN CASE WHEN uomTo.dblUnitQty <> 0 
                            THEN CAST((ISNULL((DP.dblTotal), 0) * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
                            ELSE NULL
                            END
                        ELSE ISNULL((DP.dblTotal), 0)
                        END)
    ,intLocationId
    ,strLocationName
FROM dbo.fnRKGetBucketDelayedPricing(@dtmDate,@intCommodityId,NULL) DP
LEFT JOIN tblICCommodityUnitMeasure uomFrom
    ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
LEFT JOIN tblICCommodityUnitMeasure uomTo
    ON uomTo.intCommodityId = DP.intCommodityId
    AND uomTo.ysnStockUnit = 1
WHERE (@intItemId IS NULL OR (@intItemId IS NOT NULL AND DP.intItemId = @intItemId))
    AND (@intLocationId IS NULL OR (@intLocationId IS NOT NULL AND DP.intLocationId = @intLocationId))
GROUP BY DP.dtmTransactionDate
    ,strTransactionNumber
    ,intLocationId
    ,strLocationName

GO