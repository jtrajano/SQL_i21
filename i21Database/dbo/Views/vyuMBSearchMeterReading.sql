CREATE VIEW [dbo].[vyuMBSearchMeterReading]
	AS

SELECT MRDetail.intMeterReadingDetailId
	, MRDetail.intMeterReadingId
	, MRDetail.strTransactionId
	, MRDetail.intEntityCustomerId
	, MRDetail.strCustomerName
	, MRDetail.strCustomerNumber
	, MRDetail.intEntityLocationId
	, MRDetail.strCustomerLocation
	, MRDetail.intCompanyLocationId
	, MRDetail.strCompanyLocation
	, MRDetail.dtmTransaction
	, MRDetail.intMeterAccountId
	, MRDetail.intMeterAccountDetailId
	, MRDetail.strInvoiceComment
	, MRDetail.intInvoiceId
	, MRDetail.strInvoiceNumber
	, MRDetail.strPriceType
	, MRDetail.intTaxGroupId
	, MRDetail.intItemId
	, MRDetail.strItemNo
	, MRDetail.strItemDescription
	, MRDetail.intItemUOMId
	, MRDetail.strUnitMeasure
	, MRDetail.dblGrossPrice
	, MRDetail.dblNetPrice
	, MRDetail.strMeterKey
	, MRDetail.dblLastReading
	, MRDetail.dblCurrentReading
	, MRDetail.dblQuantitySold
	, MRDetail.dblLastDollars
	, MRDetail.dblCurrentDollars
	, MRDetail.dblDollarsSold
	, dblUnitCost = ISNULL(ICTransaction.dblCost, 0)
	, dblTotalCost = (ISNULL(ICTransaction.dblCost, 0) * ISNULL(MRDetail.dblQuantitySold, 0))
	, MRDetail.dblDollarsOwed
	, MRDetail.dblDifference
	, dblTotalTax = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN 0.00
						ELSE (ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0)) * MRDetail.dblQuantitySold END)
	, dblJobberMargin = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN (CASE WHEN ConRate.strRateType = 'Jobber' THEN ISNULL(ConRate.dblBaseRate, 0)
																					ELSE MRDetail.dblGrossPrice - ISNULL(ConRate.dblBaseRate, 0) END)
							ELSE (CASE WHEN ConRate.strRateType = 'Jobber' THEN ISNULL(ConRate.dblBaseRate, 0)
									ELSE MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRate.dblBaseRate, 0)) END) END)	
	, dblJobberProfit = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN (CASE WHEN ConRate.strRateType = 'Jobber' THEN ISNULL(ConRate.dblBaseRate, 0) * MRDetail.dblQuantitySold
																					ELSE (MRDetail.dblGrossPrice - ISNULL(ConRate.dblBaseRate, 0)) * MRDetail.dblQuantitySold END)
							ELSE (CASE WHEN ConRate.strRateType = 'Jobber' THEN ISNULL(ConRate.dblBaseRate, 0) * MRDetail.dblQuantitySold
									ELSE (MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRate.dblBaseRate, 0))) * MRDetail.dblQuantitySold END) END)
	, dblDealerMargin = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN ((CASE WHEN ConRate.strRateType = 'Jobber' THEN MRDetail.dblGrossPrice - ISNULL(ConRate.dblBaseRate, 0)
																					ELSE ISNULL(ConRate.dblBaseRate, 0) END))
							ELSE ((CASE WHEN ConRate.strRateType = 'Jobber' THEN MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRate.dblBaseRate, 0))
									ELSE ISNULL(ConRate.dblBaseRate, 0) END)) END)
	, dblDealerProfit = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN ((CASE WHEN ConRate.strRateType = 'Jobber' THEN (MRDetail.dblGrossPrice - ISNULL(ConRate.dblBaseRate, 0)) * MRDetail.dblQuantitySold
																					ELSE ISNULL(ConRate.dblBaseRate, 0) * MRDetail.dblQuantitySold END))
							ELSE ((CASE WHEN ConRate.strRateType = 'Jobber' THEN (MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRate.dblBaseRate, 0))) * MRDetail.dblQuantitySold
									ELSE ISNULL(ConRate.dblBaseRate, 0) * MRDetail.dblQuantitySold END)) END)
	, MRDetail.ysnPosted
	, MRDetail.dtmPostedDate
	, MRDetail.intSort
	, MRDetail.intConsignmentGroupId
FROM vyuMBGetMeterReadingDetail MRDetail
LEFT JOIN tblARInvoiceDetail Invoice ON Invoice.intInvoiceId = MRDetail.intInvoiceId
	AND Invoice.intItemId = MRDetail.intItemId
LEFT JOIN tblICInventoryTransaction ICTransaction ON ICTransaction.intTransactionId = Invoice.intInvoiceId
	AND ICTransaction.strTransactionForm = 'Invoice'
	AND ICTransaction.intItemId = MRDetail.intItemId
	AND ISNULL(ICTransaction.ysnIsUnposted, 0) = 0
OUTER APPLY (
	SELECT TOP 100 PERCENT * FROM vyuMBGetConsignmentRateDetail ConDetail
	WHERE ConDetail.intConsignmentGroupId = MRDetail.intConsignmentGroupId
		AND MRDetail.dtmTransaction >= ConDetail.dtmEffectiveDate
		AND ConDetail.intItemId = MRDetail.intItemId
	ORDER BY ConDetail.dtmEffectiveDate
) ConRate