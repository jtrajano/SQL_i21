CREATE FUNCTION dbo.fnGREndOfMonthProcedureInventory(
	@strPeriod NVARCHAR(50)
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
    ,dblUnits = SUM(dblUnits)
    ,dblPrice = COST.dblCost --SUM(dblExtended) / SUM(dblUnits)
    ,dblExtended = ROUND(SUM(ISNULL(dblUnits, 0)) * COST.dblCost, 4)
    ,dblInTransit = INTRANSIT.dblInTransit
    ,dblInTransitExtended = INTRANSIT.dblInTransit * COST.dblCost
    ,LIABILITY.dblLiability
    ,dblLiabilityExtended = LIABILITY.dblLiability * COST.dblCost
FROM (
    SELECT
        I.intItemId
        ,C.strCommodityCode
        ,C.intCommodityId
        ,CL.strLocationNumber
        ,CL.intCompanyLocationId
        ,IL.intItemLocationId
        -- Aggregate values
        ,dblUnits = ROUND(SUM(ISNULL(IT.dblQty, 0)), 4)
        -- ,dblPrice = COST.dblCost
        -- ,dblExtended = ROUND(SUM(ISNULL(IT.dblQty, 0)) * COST.dblCost, 4)
        ,FYP.dtmEndDate
    FROM tblICInventoryTransaction IT
    INNER JOIN tblICItem I ON I.intItemId = IT.intItemId
    INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
    INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IT.intCompanyLocationId
    INNER JOIN tblICItemLocation IL ON IL.intLocationId = CL.intCompanyLocationId AND IL.intItemId = I.intItemId
    INNER JOIN tblGLFiscalYearPeriod FYP ON IT.dtmDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
    
    -- dbo.fnICGetItemCostByEffectiveDate(FYP.dtmEndDate, I.intItemId, IL.intItemLocationId, DEFAULT) COST
    WHERE FYP.strPeriod = @strPeriod
    -- AND CL.intCompanyLocationId = @intLocationId
    AND IT.dblQty > 0
    -- AND C.intCommodityId = @intCommodityId
    -- AND IT.intCompanyLocationId = @intLocationId
    GROUP BY
        I.intItemId
        ,C.strCommodityCode
        ,C.intCommodityId
        ,CL.strLocationNumber
        ,CL.intCompanyLocationId
        ,IL.intItemLocationId
        -- ,COST.dblCost
        ,FYP.dtmEndDate
) R
OUTER APPLY (SELECT dblCost = dbo.fnGRGetitemAverageCostAsOfDate(R.intItemId, R.intItemLocationId, R.dtmEndDate)) COST
OUTER APPLY (
    SELECT
        dblInTransit = SUM(dbo.fnCTConvertQtyToTargetCommodityUOM(I.intCommodityId, IUOM.intUnitMeasureId, CUOM.intUnitMeasureId, ISNULL(INSI.dblQuantity, 0)))
    FROM tblICInventoryShipmentItem INSI
    INNER JOIN tblICInventoryShipment INS ON INS.intInventoryShipmentId = INSI.intInventoryShipmentId
    INNER JOIN tblICItem I ON I.intItemId = INSI.intItemId
    INNER JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityId = I.intCommodityId AND CUOM.ysnStockUnit = 1
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = INSI.intItemUOMId
    LEFT JOIN (tblARInvoiceDetail ID INNER JOIN tblARInvoice INV ON INV.intInvoiceId = ID.intInvoiceId)
        ON ID.intInventoryShipmentItemId = INSI.intInventoryShipmentItemId
        AND INV.dtmPostDate <= R.dtmEndDate
    WHERE INS.dtmShipDate <= R.dtmEndDate
    AND I.intCommodityId = R.intCommodityId
    AND INS.intShipFromLocationId = R.intCompanyLocationId
    AND INS.ysnPosted = 1
    AND ID.intInvoiceDetailId IS NULL
) INTRANSIT
OUTER APPLY (
    SELECT
        dblLiability = SUM(dbo.fnCTConvertQtyToTargetCommodityUOM(I.intCommodityId, IUOM.intUnitMeasureId, CUOM.intUnitMeasureId, ISNULL(IRI.dblNet, 0)))
    FROM tblICInventoryReceiptItem IRI
    INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
    INNER JOIN tblICItem I ON I.intItemId = IRI.intItemId
    INNER JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityId = I.intCommodityId AND CUOM.ysnStockUnit = 1
    INNER JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = IRI.intWeightUOMId
    INNER JOIN tblCTContractHeader CTH ON CTH.intContractHeaderId = IRI.intContractHeaderId AND CTH.intPricingTypeId = 5 --DP
    LEFT JOIN (tblAPBillDetail BD INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId)
        ON BD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
        AND B.dtmDate <= R.dtmEndDate
    WHERE IR.dtmReceiptDate <= R.dtmEndDate
    AND I.intCommodityId = R.intCommodityId
    AND IR.intLocationId = R.intCompanyLocationId
    AND B.ysnPosted = 1
    AND BD.intBillId IS NULL
) LIABILITY
WHERE COST.dblCost IS NOT NULL AND COST.dblCost > 0
GROUP BY
    R.strCommodityCode
    ,R.intCommodityId
    ,R.strLocationNumber
    ,R.intCompanyLocationId
    ,R.dtmEndDate
    ,COST.dblCost
    ,INTRANSIT.dblInTransit
    ,LIABILITY.dblLiability

GO