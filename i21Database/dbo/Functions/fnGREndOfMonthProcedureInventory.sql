CREATE FUNCTION dbo.fnGREndOfMonthProcedureInventory(
	@strPeriod NVARCHAR(50)
    ,@strItemNo NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
SELECT
    R.strCommodityCode
    ,R.intCommodityId
    ,R.strLocationNumber
    ,R.intCompanyLocationId
    ,R.dtmEndDate
    ,dblUnits = SUM(ISNULL(dblUnits, 0))
    ,dblPrice = COST.dblCost --SUM(dblExtended) / SUM(dblUnits)
    ,dblExtended = SUM(ISNULL(dblUnits, 0)) * COST.dblCost
    ,dblInTransit = ISNULL(INTRANSIT.dblInTransitQtyTotal, 0)
    ,dblInTransitExtended = ISNULL(INTRANSIT.dblInTransitQtyTotal, 0) * COST.dblCost
    ,[dblDPQtyTotal] = ISNULL(LIABILITY.dblDPQtyTotal, 0)
    ,dblLiabilityExtended = ISNULL(LIABILITY.dblDPQtyTotal, 0) * COST.dblCost
FROM (
    SELECT
        IT.intItemId
        ,IT.strCommodityCode
        ,IT.intCommodityId
        ,IT.strLocationNumber
        ,IT.intCompanyLocationId
        ,IT.intItemLocationId
        -- Aggregate values
        ,dblUnits = SUM(ISNULL(IT.dblCommodityUOMQty, 0))
        ,FYP.dtmEndDate
    FROM vyuGRPhysicalInventoryTransaction IT
    INNER JOIN tblGLFiscalYearPeriod FYP ON IT.dtmDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
    WHERE FYP.strPeriod = @strPeriod
    AND (@strItemNo IS NULL OR (@strItemNo IS NOT NULL AND IT.strItemNo = @strItemNo))
    GROUP BY
        IT.intItemId
        ,IT.strCommodityCode
        ,IT.intCommodityId
        ,IT.strLocationNumber
        ,IT.intCompanyLocationId
        ,IT.intItemLocationId
        -- ,COST.dblCost
        ,FYP.dtmEndDate
) R
OUTER APPLY (SELECT dblCost = dbo.fnGRGetitemAverageCostAsOfDate(R.intItemId, R.intItemLocationId, R.dtmEndDate)) COST
OUTER APPLY (
    SELECT [dblInTransitQtyTotal] = SUM(ISNULL(R1.dblInTransitQty, 0))
    FROM dbo.fnGRInTransitTransaction(R.dtmEndDate, R.intCommodityId, R.intCompanyLocationId, NULL) R1
) INTRANSIT
OUTER APPLY (
    SELECT [dblDPQtyTotal] = SUM(ISNULL(R1.dblDPQty, 0)), COUNT(1) dblCount
    FROM dbo.fnGRDelayedPricingTransaction(R.dtmEndDate, R.intCommodityId, R.intCompanyLocationId, NULL) R1
) LIABILITY
WHERE COST.dblCost IS NOT NULL AND COST.dblCost > 0
GROUP BY
    R.strCommodityCode
    ,R.intCommodityId
    ,R.strLocationNumber
    ,R.intCompanyLocationId
    ,R.dtmEndDate
    ,COST.dblCost
    ,INTRANSIT.dblInTransitQtyTotal
    ,LIABILITY.dblDPQtyTotal

GO