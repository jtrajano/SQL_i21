﻿CREATE VIEW [dbo].[vyuRKGetM2MCPESummary]

AS

SELECT intM2MCPESummaryId = ROW_NUMBER() OVER(ORDER BY intEntityId)
	, intM2MHeaderId
	, strEntityName
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