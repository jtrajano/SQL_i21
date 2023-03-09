CREATE VIEW [dbo].[vyuGRPhysicalInventoryTransaction]
AS
SELECT
    IT.intTransactionId
    ,IT.strTransactionId
    ,IT.dtmDate
    ,I.intItemId
    ,I.strItemNo
    ,IT.intItemLocationId
    ,I.intCommodityId
    ,C.strCommodityCode
    ,CL.intCompanyLocationId
    ,CL.strLocationName
    ,CL.strLocationNumber
    ,IT.intInTransitSourceLocationId
    ,CL.ysnLicensed
    ,IT.dblQty
    ,dblCommodityUOMQty = ISNULL(CUOMQTY.dblResultQty, 0)
    ,[strTransactionUnitMeasureSymbol] = UOM_FROM.strSymbol
    ,[strCommodityUnitMeasureSymbol] = UOM.strSymbol
FROM tblICInventoryTransaction IT
INNER JOIN tblICItemUOM IUOM_FROM
	ON IUOM_FROM.intItemUOMId = IT.intItemUOMId
INNER JOIN tblICUnitMeasure UOM_FROM
	ON UOM_FROM.intUnitMeasureId = IUOM_FROM.intUnitMeasureId
INNER JOIN tblICItem I 
	ON I.intItemId = IT.intItemId
INNER JOIN tblICCommodity C
    ON C.intCommodityId = I.intCommodityId
INNER JOIN tblICCommodityUnitMeasure CUOM_TO
	ON CUOM_TO.intCommodityId = I.intCommodityId
    AND CUOM_TO.ysnStockUnit = 1
INNER JOIN tblICCommodityUnitMeasure CUOM_FROM
    ON CUOM_FROM.intUnitMeasureId = UOM_FROM.intUnitMeasureId
    AND CUOM_FROM.intCommodityId = I.intCommodityId
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = CUOM_TO.intUnitMeasureId
INNER JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = IT.intCompanyLocationId
OUTER APPLY dbo.fnGRTConvertQuantityToTargetCommodityUOM(CUOM_FROM.intCommodityUnitMeasureId, CUOM_TO.intCommodityUnitMeasureId, IT.dblQty) CUOMQTY
WHERE IT.ysnIsUnposted <> 1
	AND (IT.intCostingMethod = 5 AND IT.strTransactionForm = 'Invoice' --get the ACTUAL PRICE only for the invoice transactions
			OR (IT.intCostingMethod IS NOT NULL AND (IT.intCostingMethod <> 5 AND IT.strTransactionForm <> 'Invoice'))
		)

UNION ALL

SELECT
    IT.intTransactionId
    ,IT.strTransactionId
    ,IT.dtmDate
    ,I.intItemId
    ,I.strItemNo
    ,IT.intItemLocationId
    ,I.intCommodityId
    ,C.strCommodityCode
    ,CL.intCompanyLocationId
    ,CL.strLocationName
    ,CL.strLocationNumber		
    ,NULL intInTransitSourceLocationId
    ,CL.ysnLicensed
    ,IT.dblQty
    ,dblCommodityUOMQty = ISNULL(CUOMQTY.dblResultQty, 0)
    ,[strTransactionUnitMeasureSymbol] = UOM_FROM.strSymbol
    ,[strCommodityUnitMeasureSymbol] = UOM.strSymbol
FROM tblICInventoryTransactionStorage IT
INNER JOIN tblICItemLocation IL
    ON IL.intItemLocationId = IT.intItemLocationId
INNER JOIN tblICItemUOM IUOM_FROM
	ON IUOM_FROM.intItemUOMId = IT.intItemUOMId
INNER JOIN tblICUnitMeasure UOM_FROM
	ON UOM_FROM.intUnitMeasureId = IUOM_FROM.intUnitMeasureId
INNER JOIN tblICItem I 
	ON I.intItemId = IT.intItemId
INNER JOIN tblICCommodity C
    ON C.intCommodityId = I.intCommodityId
INNER JOIN tblICCommodityUnitMeasure CUOM_TO
	ON CUOM_TO.intCommodityId = I.intCommodityId
    AND CUOM_TO.ysnStockUnit = 1
INNER JOIN tblICCommodityUnitMeasure CUOM_FROM
    ON CUOM_FROM.intUnitMeasureId = UOM_FROM.intUnitMeasureId
    AND CUOM_FROM.intCommodityId = I.intCommodityId
INNER JOIN tblICUnitMeasure UOM
	ON UOM.intUnitMeasureId = CUOM_TO.intUnitMeasureId
INNER JOIN tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = IL.intLocationId
OUTER APPLY dbo.fnGRTConvertQuantityToTargetCommodityUOM(CUOM_FROM.intCommodityUnitMeasureId, CUOM_TO.intCommodityUnitMeasureId, IT.dblQty) CUOMQTY
WHERE IT.ysnIsUnposted <> 1