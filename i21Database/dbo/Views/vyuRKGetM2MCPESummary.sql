CREATE VIEW [dbo].[vyuRKGetM2MCPESummary]

AS

SELECT strEntityName
	, intEntityId
	, dblFixedPurchaseVolume = SUM(dblFixedPurchaseVolume)
	, dblUnfixedPurchaseVolume = SUM(dblUnfixedPurchaseVolume)
	, dblTotalCommittedVolume = SUM(dblTotalCommittedVolume)
	, dblFixedPurchaseValue = SUM(dblFixedPurchaseValue)
	, dblUnfixedPurchaseValue = SUM(dblUnfixedPurchaseValue)
	, dblTotalCommittedValue = SUM(dblTotalCommittedValue)		
	, strRiskIndicator
	, dblRiskTotalBusinessVolume
	, intRiskUnitOfMeasureId
	, dblCompanyExposurePercentage
	, dblSupplierSalesPercentage
FROM (
	SELECT CPE.*
		, strRiskIndicator
		, dblRiskTotalBusinessVolume
		, intRiskUnitOfMeasureId
		, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0), 2)
		, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0), 2)
		, intEntityId
	FROM tblRKM2MCounterPartyExposure CPE
	--JOIN tblCTContractDetail det ON CPE.intContractDetailId = det.intContractDetailId
	--JOIN tblICItemUOM ic ON det.intPriceItemUOMId = ic.intItemUOMId
	--JOIN tblSMCurrency c ON det.intCurrencyId = c.intCurrencyID
	JOIN tblAPVendor e ON e.intEntityId = CPE.intVendorId
	--LEFT JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = e.intRiskUnitOfMeasureId
	LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
	--WHERE strContractOrInventoryType IN ('Contract(P)', 'In-transit(P)', 'Inventory (P)')
) t
GROUP BY strEntityName
	, strRiskIndicator
	, dblRiskTotalBusinessVolume
	, intRiskUnitOfMeasureId
	, dblCompanyExposurePercentage
	, dblSupplierSalesPercentage
	, intEntityId