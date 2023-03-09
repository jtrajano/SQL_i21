CREATE FUNCTION [dbo].[fnGRInTransitTransaction] (
    @dtmDate DATETIME
	,@intCommodityId INT
	,@intLocationId INT
	,@intItemId INT = NULL
)
RETURNS TABLE AS RETURN
SELECT
    dtmDate = InTran.dtmTransactionDate
    ,strTransactionNumber
    ,dblInTransitQty = SUM(CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
                        THEN CASE WHEN uomTo.dblUnitQty <> 0 
                            THEN CAST((ISNULL((InTran.dblTotal), 0) * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
                            ELSE NULL
                            END
                        ELSE ISNULL((InTran.dblTotal), 0)
                        END)
    ,intLocationId
    ,strLocationName
FROM dbo.fnRKGetBucketInTransit(@dtmDate,@intCommodityId,NULL) InTran
LEFT JOIN tblICCommodityUnitMeasure uomFrom
    ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
LEFT JOIN tblICCommodityUnitMeasure uomTo
    ON uomTo.intCommodityId = InTran.intCommodityId
    AND uomTo.ysnStockUnit = 1
WHERE InTran.strBucketType = 'Sales In-Transit'
    AND (@intItemId IS NULL OR (@intItemId IS NOT NULL AND InTran.intItemId = @intItemId))
    AND (@intLocationId IS NULL OR (@intLocationId IS NOT NULL AND InTran.intLocationId = @intLocationId))
GROUP BY InTran.dtmTransactionDate
    ,strTransactionNumber
    ,intLocationId
    ,strLocationName

GO