CREATE VIEW [dbo].[vyuTRQuoteReport]
	AS

SELECT TOP 100 PERCENT strCompanyName = CompanySetup.strCompanyName
	, strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, CompanySetup.strAddress, CompanySetup.strCity, CompanySetup.strState, CompanySetup.strZip, CompanySetup.strCountry, NULL, 0)
	, QH.strQuoteNumber
	, GETDATE() AS dtmGeneratedDate
	, QH.dtmQuoteDate
	, strCustomer = dbo.fnARFormatCustomerAddress(NULL, NULL, AR.strBillToLocationName, AR.strBillToAddress, AR.strBillToCity, AR.strBillToState, AR.strBillToZipCode, AR.strBillToCountry, AR.strName, 0)
	, strSalesperson = dbo.fnARFormatCustomerAddress(SP.strPhone, SP.strEmail, NULL, NULL, NULL, NULL, NULL, NULL, SP.strName, 0)
	, EL.strLocationName
	, strItemNo = IC.strDescription
	, TR.strSupplyPoint
	, QH.dtmQuoteEffectiveDate
	, dblPriceChange = CASE WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) < 0 THEN CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50))
							WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) = 0 THEN CAST('0.00' AS NVARCHAR(50))
							ELSE '+' + CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50)) END
	, dblQuotePrice = ISNULL(QuotePrice.dblQuotePrice, 0)
	, ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) 
									FROM vyuARCustomerContacts CC 
									WHERE CC.intCustomerEntityId = QH.intEntityCustomerId 
										AND ISNULL(CC.strEmail, '') <> ''
										AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) 
							ELSE CONVERT(BIT, 0) END
	, QH.intQuoteHeaderId
	, QH.strQuoteComments
FROM tblTRQuoteHeader QH
CROSS APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
LEFT JOIN tblTRQuoteDetail QD ON QD.intQuoteHeaderId = QH.intQuoteHeaderId
LEFT JOIN vyuARCustomer AR ON QH.intEntityCustomerId = AR.intEntityCustomerId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntitySalespersonId = AR.intSalespersonId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = QD.intShipToLocationId
	AND EL.intEntityId = QH.intEntityCustomerId
LEFT JOIN tblICItem IC ON IC.intItemId = QD.intItemId
LEFT JOIN vyuTRSupplyPointView TR ON TR.intSupplyPointId = QD.intSupplyPointId
CROSS APPLY (
	SELECT TOP 1 dblQuotePrice = ISNULL(PQD.dblQuotePrice, 0)
	FROM tblTRQuoteHeader PQH
	JOIN tblTRQuoteDetail PQD on PQH.intQuoteHeaderId = PQD.intQuoteHeaderId
	WHERE PQH.strQuoteNumber < QH.strQuoteNumber 
		AND PQH.intEntityCustomerId = QH.intEntityCustomerId 
		AND PQH.strQuoteStatus = 'Confirmed' 
		AND PQD.intItemId = QD.intItemId 
		AND PQD.intShipToLocationId = QD.intShipToLocationId
	ORDER BY PQH.strQuoteNumber DESC
) QuotePrice
WHERE QH.strQuoteStatus = 'Confirmed'
	OR QH.strQuoteStatus = 'Sent'
ORDER BY EL.strLocationName, IC.strItemNo, dblQuotePrice ASC
