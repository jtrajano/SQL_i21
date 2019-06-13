CREATE VIEW [dbo].[vyuRKDPRDailyPositionByCommodity]

AS

SELECT OpenPurchasesQty
	, OpenSalesQty
	, intCommodityId
	, strCommodityCode
	, strUnitMeasure
	, dblCompanyTitled = ISNULL(CompanyTitled, 0)
	, dblCaseExposure = ISNULL(CashExposure, 0)
	, dblBasisExposure = (ISNULL(CompanyTitled, 0) + (ISNULL(OpenPurchasesQty, 0) - ISNULL(OpenSalesQty, 0)))
	, dblAvailForSale = (ISNULL(CompanyTitled, 0) + (ISNULL(OpenPurchasesQty, 0) - ISNULL(OpenSalesQty, 0))) - ISNULL(ReceiptProductQty, 0)
	, dblInHouse = ISNULL(CompanyTitled, 0)
	, OpenPurQty
	, OpenSalQty
FROM (
	SELECT intCommodityId
		, strCommodityCode
		, strUnitMeasure
		, CompanyTitled = (invQty) - CASE WHEN (SELECT TOP 1 ysnIncludeInTransitInCompanyTitled FROM tblRKCompanyPreference) = 1 THEN ISNULL(ReserveQty, 0)ELSE 0 END
									+ CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled FROM tblRKCompanyPreference) = 1 THEN OffSite ELSE 0 END
									+ CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference) = 1 THEN DP ELSE 0 END
									+ dblCollatralSales + SlsBasisDeliveries
		, OpenSalQty
		, CashExposure = (ISNULL(invQty, 0) - ISNULL(ReserveQty, 0))
						+ (ISNULL(OpenPurQty, 0) - ISNULL(OpenSalQty, 0))
						+ (((ISNULL(FutLBalTransQty, 0) - ISNULL(FutMatchedQty, 0)) - (ISNULL(FutSBalTransQty, 0) - ISNULL(FutMatchedQty, 0))) * ISNULL(dblContractSize, 1))
						+ CASE WHEN (SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled FROM tblRKCompanyPreference) = 1 THEN OffSite ELSE 0 END
						+ CASE WHEN (SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference) = 1 THEN DP ELSE 0 END
						+ dblCollatralSales + SlsBasisDeliveries
		, ReceiptProductQty
		, OpenPurchasesQty
		, OpenSalesQty
		, OpenPurQty
	FROM (
		SELECT DISTINCT c.intCommodityId
			, strCommodityCode
			, u.intUnitMeasureId
			, u.strUnitMeasure
			, OpenPurQty = (SELECT Qty = ISNULL(SUM(CD.dblBalance), 0)
							FROM tblCTContractDetail CD
							JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CD.intContractStatusId <> 3
							JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1
							JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1, 3)
							JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId WHERE CH.intCommodityId = c.intCommodityId)
			, OffSite = (SELECT dblTotal = ISNULL(SUM(Balance), 0)
						FROM vyuGRGetStorageDetail CH
						WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company'
							AND CH.intCommodityId = c.intCommodityId)
			, DP = (SELECT DP = ISNULL(SUM(Balance), 0)
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId = c.intCommodityId AND ysnDPOwnedType = 1)
			, OpenSalQty = (SELECT Qty = ISNULL(SUM(CD.dblBalance), 0)
							FROM tblCTContractDetail CD
							JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CD.intContractStatusId <> 3
							JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 2
							JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1, 3)
							JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId WHERE CH.intCommodityId = c.intCommodityId)
			, ReceiptProductQty = (SELECT Qty = ISNULL(SUM(CD.dblBalance), 0)
									FROM tblCTContractDetail CD
									JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CD.intContractStatusId <> 3
									JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1
									JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1, 2)
									JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId WHERE CH.intCommodityId = c.intCommodityId)
			, OpenPurchasesQty = (SELECT Qty = ISNULL(SUM(CD.dblBalance), 0)
								FROM tblCTContractDetail CD
								JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CD.intContractStatusId <> 3
								JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 1
								JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1, 2)
								JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId WHERE CH.intCommodityId = c.intCommodityId)
			, OpenSalesQty = (SELECT Qty = ISNULL(SUM(CD.dblBalance), 0)
							FROM tblCTContractDetail CD
							JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId AND CD.intContractStatusId <> 3
							JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId AND CH.intContractTypeId = 2
							JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId AND PT.intPricingTypeId IN (1, 2)
							JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId WHERE CH.intCommodityId = c.intCommodityId)
			, dblContractSize = (SELECT TOP 1 dblContractSize = rfm.dblContractSize
								FROM tblRKFutOptTransaction otr
								JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
								WHERE otr.intCommodityId = c.intCommodityId
								GROUP BY rfm.intFutureMarketId, rfm.dblContractSize)
			, FutSBalTransQty = (SELECT ISNULL(SUM(dblNoOfContract), 0)
								FROM tblRKFutOptTransaction otr
								WHERE otr.strBuySell = 'Sell' AND otr.intCommodityId = c.intCommodityId)
			, FutLBalTransQty = (SELECT ISNULL(SUM(dblNoOfContract), 0)
								FROM tblRKFutOptTransaction otr
								WHERE otr.strBuySell = 'Buy' AND otr.intCommodityId = c.intCommodityId)
			, FutMatchedQty = (SELECT SUM(psd.dblMatchQty)
								FROM tblRKMatchFuturesPSHeader psh
								JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
								WHERE intCommodityId = c.intCommodityId)
			, invQty = (SELECT SUM(ISNULL(it1.dblUnitOnHand, 0))
						FROM tblICItem i1
						JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId AND i1.intCommodityId = c.intCommodityId)
			, ReserveQty = (SELECT SUM(ISNULL(sr1.dblQty, 0))
							FROM tblICItem i1
							JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
							JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
							WHERE i1.intCommodityId = c.intCommodityId)
			, dblCollatralSales = (SELECT dblCollatralSales = ISNULL(SUM(dblOriginalQuantity), 0) - ISNULL(SUM(dblAdjustmentAmount), 0)
								FROM (
									SELECT dblAdjustmentAmount = SUM(dblAdjustmentAmount)
										, intContractHeaderId
										, dblOriginalQuantity = ISNULL(SUM(dblOriginalQuantity), 0)
									FROM tblRKCollateral c1
									INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
									WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId
									GROUP BY intContractHeaderId
								) t WHERE dblAdjustmentAmount <> dblOriginalQuantity)
			, SlsBasisDeliveries = (SELECT SlsBasisDeliveries = ISNULL(SUM(ISNULL(ri.dblQuantity, 0)), 0)
									FROM tblICInventoryShipment r
									INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
									INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intContractStatusId <> 3
										AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1
									INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
									WHERE ch.intCommodityId = c.intCommodityId)
		FROM tblICCommodity c
		LEFT JOIN tblICCommodityUnitMeasure um ON c.intCommodityId = um.intCommodityId
		JOIN tblICUnitMeasure u ON um.intUnitMeasureId = u.intUnitMeasureId AND ysnDefault = 1
		GROUP BY c.intCommodityId
			, strCommodityCode
			, u.intUnitMeasureId
			, u.strUnitMeasure
	) t
) t1