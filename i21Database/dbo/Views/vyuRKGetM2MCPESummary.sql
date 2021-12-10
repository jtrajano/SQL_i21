CREATE VIEW [dbo].[vyuRKGetM2MCPESummary]

AS

SELECT intM2MCPESummaryId = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strEntityName))
	, intM2MHeaderId
	, strEntityName
	, intEntityId intVendorId
	, strRiskIndicator
	, dblFixedPurchaseVolume = CONVERT(NUMERIC(16, 2), dblFixedPurchaseVolume)
	, dblUnfixedPurchaseVolume = CONVERT(NUMERIC(16,2),dblUnfixedPurchaseVolume)
	, dblTotalCommittedVolume = CONVERT(NUMERIC(16, 2), dblTotalCommittedVolume)
	, dblFixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblFixedPurchaseValue)
	, dblUnfixedPurchaseValue = CONVERT(NUMERIC(16, 2), dblUnfixedPurchaseValue)
	, dblTotalCommittedValue = CONVERT(NUMERIC(16, 2), dblTotalCommittedValue)
	, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
	, dblShareWithSupplier
	, dblMToM
	, dblCompanyExposurePercentage
	, dblPotentialAdditionalVolume = CASE WHEN (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) < 0 THEN 0
										ELSE (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) END
	, intConcurrencyId = 0
	, strCountry
FROM (
	SELECT strEntityName
		, t3.intEntityId
		, intM2MHeaderId
		, strRiskIndicator
		, dblFixedPurchaseVolume
		, dblUnfixedPurchaseVolume
		, dblTotalCommittedVolume
		, dblFixedPurchaseValue
		, dblUnfixedPurchaseValue
		, dblTotalCommittedValue
		, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
		, dblShareWithSupplier = CONVERT(NUMERIC(16, 2), dblShareWithSupplier)
		, dblMToM
		, dblCompanyExposurePercentage
		, a = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
		, b = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
		, dblPotentialAdditionalVolume = CASE WHEN CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END > dblCompanyExposurePercentage THEN 0
											WHEN CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END > dblSupplierSalesPercentage THEN 0
											WHEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
												<= (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
												THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
											ELSE (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage END
		, Loc.strCountry
	FROM (
		SELECT strEntityName
			, intEntityId
			, intM2MHeaderId
			, strRiskIndicator
			, dblFixedPurchaseVolume
			, dblUnfixedPurchaseVolume
			, dblTotalCommittedVolume
			, dblFixedPurchaseValue
			, dblUnfixedPurchaseValue
			, dblTotalCommittedValue
			, dblTotalSpend = (ISNULL(dblTotalCommittedValue, 0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue, 0) = 0 THEN 1 ELSE dblTotalCommittedValue END) OVER (PARTITION BY intM2MHeaderId)) * 100
			, dblShareWithSupplier = (CASE WHEN ISNULL(dblRiskTotalBusinessVolume, 0) = 0 THEN 0 ELSE ISNULL(dblTotalCommittedVolume, 0) / dblRiskTotalBusinessVolume END) * 100
			, dblMToM
			, dblCompanyExposurePercentage
			, dblSupplierSalesPercentage
		FROM (
			SELECT strEntityName
				, intEntityId
				, intM2MHeaderId
				, dblFixedPurchaseVolume
				, dblUnfixedPurchaseVolume
				, dblTotalCommittedVolume = dblFixedPurchaseVolume + dblUnfixedPurchaseVolume
				, dblFixedPurchaseValue
				, dblUnfixedPurchaseValue
				, dblTotalCommittedValue = dblFixedPurchaseValue + dblUnfixedPurchaseValue
				, dblMToM
				, strRiskIndicator
				, intRiskUnitOfMeasureId
				, dblRiskTotalBusinessVolume
				, dblCompanyExposurePercentage
				, dblSupplierSalesPercentage
			FROM (
				SELECT strEntityName
					, intEntityId
					, intM2MHeaderId
					, dblFixedPurchaseVolume = SUM(dblFixedPurchaseVolume)
					, dblUnfixedPurchaseVolume = SUM(dblUnfixedPurchaseVolume)
					, dblFixedPurchaseValue = SUM(dblFixedPurchaseValue)
					, dblUnfixedPurchaseValue = SUM(dblUnfixedPurchaseValue)
					, dblMToM = SUM(dblMToM)
					, strRiskIndicator
					, dblRiskTotalBusinessVolume
					, intRiskUnitOfMeasureId
					, dblCompanyExposurePercentage
					, dblSupplierSalesPercentage
				FROM (
					SELECT CPE.*
						, strRiskIndicator
						, dblRiskTotalBusinessVolume = dbo.fnCTConvertQuantityToTargetCommodityUOM(toUOM.intCommodityUnitMeasureId
																				, CASE WHEN ISNULL(fromUOM.intCommodityUnitMeasureId, 0) = 0 THEN toUOM.intCommodityUnitMeasureId ELSE fromUOM.intCommodityUnitMeasureId END
																				, ISNULL(dblRiskTotalBusinessVolume, 0.00))
						, intRiskUnitOfMeasureId
						, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0.00), 2)
						, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0.00), 2)
						, intEntityId
					FROM tblRKM2MCounterPartyExposure CPE
					JOIN tblRKM2MHeader M2M ON M2M.intM2MHeaderId = CPE.intM2MHeaderId
					JOIN tblAPVendor e ON e.intEntityId = CPE.intVendorId
					LEFT JOIN tblICCommodityUnitMeasure fromUOM ON M2M.intCommodityId = fromUOM.intCommodityId AND fromUOM.intUnitMeasureId = M2M.intQtyUOMId
					LEFT JOIN tblICCommodityUnitMeasure toUOM ON M2M.intCommodityId = toUOM.intCommodityId AND toUOM.intUnitMeasureId = e.intRiskUnitOfMeasureId
					LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
				) t1
				GROUP BY strEntityName
					, strRiskIndicator
					, dblRiskTotalBusinessVolume
					, intRiskUnitOfMeasureId
					, dblCompanyExposurePercentage
					, dblSupplierSalesPercentage
					, intEntityId
					, intM2MHeaderId
			)t2
		)t2
	)t3
	LEFT JOIN tblEMEntityLocation AS Loc ON t3.intEntityId = Loc.intEntityId AND Loc.ysnDefaultLocation = 1
)t4