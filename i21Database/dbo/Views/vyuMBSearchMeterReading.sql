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
	, dblJobberMargin = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN (CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN ISNULL(ConRateDetail.dblBaseRate, 0)
																					ELSE MRDetail.dblGrossPrice - ISNULL(ConRateDetail.dblBaseRate, 0) END)
							ELSE (CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN ISNULL(ConRateDetail.dblBaseRate, 0)
									ELSE MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRateDetail.dblBaseRate, 0)) END) END)	
	, dblJobberProfit = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN (CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN ISNULL(ConRateDetail.dblBaseRate, 0) * MRDetail.dblQuantitySold
																					ELSE (MRDetail.dblGrossPrice - ISNULL(ConRateDetail.dblBaseRate, 0)) * MRDetail.dblQuantitySold END)
							ELSE (CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN ISNULL(ConRateDetail.dblBaseRate, 0) * MRDetail.dblQuantitySold
									ELSE (MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRateDetail.dblBaseRate, 0))) * MRDetail.dblQuantitySold END) END)
	, dblDealerMargin = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN ((CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN MRDetail.dblGrossPrice - ISNULL(ConRateDetail.dblBaseRate, 0)
																					ELSE ISNULL(ConRateDetail.dblBaseRate, 0) END))
							ELSE ((CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRateDetail.dblBaseRate, 0))
									ELSE ISNULL(ConRateDetail.dblBaseRate, 0) END)) END)
	, dblDealerProfit = (CASE WHEN ISNULL(Invoice.intInvoiceId, '') = '' OR ISNULL(Invoice.dblQtyShipped, 0) = 0 THEN ((CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN (MRDetail.dblGrossPrice - ISNULL(ConRateDetail.dblBaseRate, 0)) * MRDetail.dblQuantitySold
																					ELSE ISNULL(ConRateDetail.dblBaseRate, 0) * MRDetail.dblQuantitySold END))
							ELSE ((CASE WHEN ConRateDetail.strRateType = 'Jobber' THEN (MRDetail.dblGrossPrice - (ISNULL(ICTransaction.dblCost, 0) + ((ISNULL(Invoice.dblTotalTax, 0) / ISNULL(Invoice.dblQtyShipped, 0))) + ISNULL(ConRateDetail.dblBaseRate, 0))) * MRDetail.dblQuantitySold
									ELSE ISNULL(ConRateDetail.dblBaseRate, 0) * MRDetail.dblQuantitySold END)) END)
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
LEFT JOIN (
	SELECT ConDetail.intConsignmentGroupId, ConDetail.intConsignmentRateId, ConDetail.intItemId, ConDetail.dtmEffectiveDate FROM vyuMBGetConsignmentRateDetail ConDetail
	GROUP BY ConDetail.intConsignmentGroupId, ConDetail.intConsignmentRateId, ConDetail.intItemId, ConDetail.dtmEffectiveDate
	HAVING MAX(ConDetail.dtmEffectiveDate) = ConDetail.dtmEffectiveDate
) ConRate ON ConRate.intConsignmentGroupId = MRDetail.intConsignmentGroupId
		AND MRDetail.dtmTransaction >= ConRate.dtmEffectiveDate
		AND ConRate.intItemId = MRDetail.intItemId
LEFT JOIN tblMBConsignmentRateDetail ConRateDetail ON ConRateDetail.intConsignmentRateId = ConRate.intConsignmentRateId
	AND ConRateDetail.intItemId = MRDetail.intItemId