CREATE VIEW [dbo].[vyuRKGetM2MCustomerExposureSummary]

AS

SELECT intM2MCustomerExposureSummaryId = CONVERT(INT, ROW_NUMBER() OVER(ORDER BY strEntityName))
	, intM2MHeaderId
	, strEntityName
	, intCustomerId
	--, strRiskIndicator
	, dblFixedSalesVolume = CONVERT(NUMERIC(16, 2), dblFixedSalesVolume)
	, dblUnfixedSalesVolume = CONVERT(NUMERIC(16,2),dblUnfixedSalesVolume)
	, dblTotalCommittedVolume = CONVERT(NUMERIC(16, 2), dblTotalCommittedVolume)
	, dblFixedSalesValue = CONVERT(NUMERIC(16, 2), dblFixedSalesValue)
	, dblUnfixedSalesValue = CONVERT(NUMERIC(16, 2), dblUnfixedSalesValue)
	, dblTotalCommittedValue = CONVERT(NUMERIC(16, 2), dblTotalCommittedValue)
	, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
	--, dblShareWithSupplier
	, dblMToM
	--, dblCompanyExposurePercentage
	--, dblPotentialAdditionalVolume = CASE WHEN (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) < 0 THEN 0
	--									ELSE (ISNULL(dblPotentialAdditionalVolume, 0) - ISNULL(dblTotalCommittedVolume, 0)) END
	, strCountry
	, dblCreditLimit 
	, dblOpenInvoicedValue
	, dblVariance 
	, intConcurrencyId = 0
FROM (
	SELECT strEntityName
		, intCustomerId
		, intM2MHeaderId
		--, strRiskIndicator
		, dblFixedSalesVolume
		, dblUnfixedSalesVolume
		, dblTotalCommittedVolume
		, dblFixedSalesValue
		, dblUnfixedSalesValue
		, dblTotalCommittedValue
		, dblTotalSpend = CONVERT(NUMERIC(16, 2), dblTotalSpend)
		--, dblShareWithSupplier = CONVERT(NUMERIC(16, 2), dblShareWithSupplier)
		, dblMToM
		--, dblCompanyExposurePercentage
		--, a = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
		--, b = (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
		--, dblPotentialAdditionalVolume = CASE WHEN CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END > dblCompanyExposurePercentage THEN 0
		--									WHEN CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END > dblSupplierSalesPercentage THEN 0
		--									WHEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
		--										<= (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage
		--										THEN (dblTotalCommittedVolume / CASE WHEN ISNULL(dblTotalSpend, 0) = 0 THEN 1 ELSE dblTotalSpend END) * dblCompanyExposurePercentage
		--									ELSE (dblTotalCommittedVolume / CASE WHEN ISNULL(dblShareWithSupplier, 0) = 0 THEN 1 ELSE dblShareWithSupplier END) * dblSupplierSalesPercentage END
		, strCountry
		, dblCreditLimit 
		, dblOpenInvoicedValue
		, dblVariance 
	FROM (
		SELECT strEntityName
			, intCustomerId
			, intM2MHeaderId
			--, strRiskIndicator
			, dblFixedSalesVolume
			, dblUnfixedSalesVolume
			, dblTotalCommittedVolume
			, dblFixedSalesValue
			, dblUnfixedSalesValue
			, dblTotalCommittedValue
			, dblTotalSpend = (ISNULL(dblTotalCommittedValue, 0)/ SUM(CASE WHEN ISNULL(dblTotalCommittedValue, 0) = 0 THEN 1 ELSE dblTotalCommittedValue END) OVER (PARTITION BY intM2MHeaderId)) * 100
			--, dblShareWithSupplier = (CASE WHEN ISNULL(dblRiskTotalBusinessVolume, 0) = 0 THEN 0 ELSE ISNULL(dblTotalCommittedVolume, 0) / dblRiskTotalBusinessVolume END) * 100
			, dblMToM
			--, dblCompanyExposurePercentage
			--, dblSupplierSalesPercentage
			, strCountry
			, dblCreditLimit 
			, dblOpenInvoicedValue
			, dblVariance 
		FROM (
			SELECT strEntityName
				, intCustomerId
				, intM2MHeaderId
				, dblFixedSalesVolume
				, dblUnfixedSalesVolume
				, dblTotalCommittedVolume = dblFixedSalesVolume + dblUnfixedSalesVolume
				, dblFixedSalesValue
				, dblUnfixedSalesValue
				, dblTotalCommittedValue = dblFixedSalesValue + dblUnfixedSalesValue
				, dblMToM
				--, strRiskIndicator
				--, intRiskUnitOfMeasureId
				--, dblRiskTotalBusinessVolume
				--, dblCompanyExposurePercentage
				--, dblSupplierSalesPercentage
				, strCountry
				, dblCreditLimit 
				, dblOpenInvoicedValue
				, dblVariance 
			FROM (
				SELECT strEntityName
					, intCustomerId
					, intM2MHeaderId
					, dblFixedSalesVolume = SUM(dblFixedSalesVolume)
					, dblUnfixedSalesVolume = SUM(dblUnfixedSalesVolume)
					, dblFixedSalesValue = SUM(dblFixedSalesValue)
					, dblUnfixedSalesValue = SUM(dblUnfixedSalesValue)
					, dblMToM = SUM(dblMToM)
					--, strRiskIndicator
					--, dblRiskTotalBusinessVolume
					--, intRiskUnitOfMeasureId
					--, dblCompanyExposurePercentage
					--, dblSupplierSalesPercentage
					, strCountry
					, dblCreditLimit = MAX(dblCreditLimit)
					, dblOpenInvoicedValue = MAX(dblOpenInvoicedValue)
					, dblVariance = MAX(dblVariance)
				FROM (
					SELECT CPE.*
						--, strRiskIndicator
						--, dblRiskTotalBusinessVolume = dbo.fnCTConvertQuantityToTargetCommodityUOM(toUOM.intCommodityUnitMeasureId
						--														, CASE WHEN ISNULL(fromUOM.intCommodityUnitMeasureId, 0) = 0 THEN toUOM.intCommodityUnitMeasureId ELSE fromUOM.intCommodityUnitMeasureId END
						--														, ISNULL(dblRiskTotalBusinessVolume, 0.00))
						--, intRiskUnitOfMeasureId
						--, dblCompanyExposurePercentage = ROUND(ISNULL(dblCompanyExposurePercentage, 0.00), 2)
						--, dblSupplierSalesPercentage = ROUND(ISNULL(dblSupplierSalesPercentage, 0.00), 2)
					FROM tblRKM2MCustomerExposure CPE
					JOIN tblRKM2MHeader M2M ON M2M.intM2MHeaderId = CPE.intM2MHeaderId
					--JOIN tblARCustomer e ON e.intEntityId = CPE.intCustomerId
					--JOIN tblAPVendor e ON e.intEntityId = CPE.intVendorId
					LEFT JOIN tblICCommodityUnitMeasure fromUOM ON M2M.intCommodityId = fromUOM.intCommodityId AND fromUOM.intUnitMeasureId = M2M.intQtyUOMId
					--LEFT JOIN tblICCommodityUnitMeasure toUOM ON M2M.intCommodityId = toUOM.intCommodityId AND toUOM.intUnitMeasureId = e.intRiskUnitOfMeasureId
					--LEFT JOIN tblRKVendorPriceFixationLimit pf ON pf.intVendorPriceFixationLimitId = e.intRiskVendorPriceFixationLimitId
				) t1
				GROUP BY strEntityName
					--, strRiskIndicator
					--, dblRiskTotalBusinessVolume
					--, intRiskUnitOfMeasureId
					--, dblCompanyExposurePercentage
					--, dblSupplierSalesPercentage
					, intCustomerId
					, intM2MHeaderId
					, strCountry
			)t2
		)t2
	)t3
)t4