CREATE VIEW [dbo].[vyuRKGetM2MCPESummary]

AS

SELECT intM2MCPESummaryId = CAST(ROW_NUMBER() OVER(ORDER BY intEntityId) AS INT)
	, intM2MHeaderId
	, strEntityName
	, intEntityId
	, dblFixedPurchaseVolume = ISNULL(SUM(dblFixedPurchaseVolume), 0.00)
	, dblUnfixedPurchaseVolume = ISNULL(SUM(dblUnfixedPurchaseVolume), 0.00)
	, dblTotalCommittedVolume = ISNULL(SUM(dblTotalCommittedVolume), 0.00)
	, dblFixedPurchaseValue = ISNULL(SUM(dblFixedPurchaseValue), 0.00)
	, dblUnfixedPurchaseValue = ISNULL(SUM(dblUnfixedPurchaseValue), 0.00)
	, dblTotalCommittedValue = ISNULL(SUM(dblTotalCommittedValue), 0.00)
	, strRiskIndicator
	, dblRiskTotalBusinessVolume
	, intRiskUnitOfMeasureId
	, dblCompanyExposurePercentage
	, dblSupplierSalesPercentage
FROM (
	SELECT CPE.*
		, strRiskIndicator
		, dblRiskTotalBusinessVolume = ISNULL(dblRiskTotalBusinessVolume, 0.00)
		, intRiskUnitOfMeasureId
		, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0), 2)
		, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0), 2)
		, intEntityId
	FROM tblRKM2MCounterPartyExposure CPE
	JOIN tblAPVendor e ON e.intEntityId = CPE.intVendorId
	LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
) t
GROUP BY strEntityName
	, strRiskIndicator
	, dblRiskTotalBusinessVolume
	, intRiskUnitOfMeasureId
	, dblCompanyExposurePercentage
	, dblSupplierSalesPercentage
	, intEntityId
	, intM2MHeaderId