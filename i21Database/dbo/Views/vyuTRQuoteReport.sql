CREATE VIEW [dbo].[vyuTRQuoteReport]
	AS 
SELECT TOP 100 PERCENT
   strCompanyName = CompanySetup.strCompanyName
   , strCompanyAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, CompanySetup.strAddress, CompanySetup.strCity, CompanySetup.strState, CompanySetup.strZip, CompanySetup.strCountry, NULL)
   , QH.strQuoteNumber
   , GETDATE() AS dtmGeneratedDate
   , QH.dtmQuoteDate
   , strCustomer = [dbo].fnARFormatCustomerAddress(NULL, NULL, AR.strBillToLocationName, AR.strBillToAddress, AR.strBillToCity, AR.strBillToState, AR.strBillToZipCode, AR.strBillToCountry, AR.strName)
   , strSalesperson = [dbo].fnARFormatCustomerAddress(SP.strPhone, SP.strEmail, NULL, NULL, NULL, NULL, NULL, NULL, SP.strName)
   , EL.strLocationName
   , IC.strItemNo
   , TR.strSupplyPoint
   , QH.dtmQuoteEffectiveDate
   , dblPriceChange = (QD.dblQuotePrice - (SELECT TOP 1 PQD.dblQuotePrice
							FROM tblTRQuoteHeader PQH
							JOIN tblTRQuoteDetail PQD on PQH.intQuoteHeaderId = PQD.intQuoteHeaderId
							WHERE PQH.strQuoteNumber < QH.strQuoteNumber 
								AND PQH.intEntityCustomerId = QH.intEntityCustomerId 
								AND PQH.strQuoteStatus = 'Confirmed' 
								AND PQD.intItemId = QD.intItemId 
								AND PQD.intShipToLocationId = QD.intShipToLocationId
							ORDER BY PQH.strQuoteNumber DESC))
	, QD.dblQuotePrice
	, ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) 
									FROM vyuARCustomerContacts CC 
									WHERE CC.intCustomerEntityId = QH.intEntityCustomerId 
										AND ISNULL(CC.strEmail, '') <> '' 
										AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) 
							ELSE CONVERT(BIT, 0) END
	, QH.intQuoteHeaderId
	, QH.strQuoteComments
FROM dbo.tblTRQuoteHeader QH
JOIN tblSMCompanySetup CompanySetup ON ISNULL(CompanySetup.intCompanySetupID, '') <> ''
LEFT JOIN dbo.tblTRQuoteDetail QD ON QD.intQuoteHeaderId = QH.intQuoteHeaderId
JOIN dbo.vyuARCustomer AR ON QH.intEntityCustomerId = AR.intEntityCustomerId
LEFT JOIN dbo.vyuEMSalesperson SP ON SP.intEntitySalespersonId = AR.intSalespersonId
LEFT JOIN dbo.tblEntityLocation EL ON EL.intEntityLocationId = QD.intShipToLocationId
	AND EL.intEntityId = QH.intEntityCustomerId
LEFT JOIN dbo.tblICItem IC ON IC.intItemId = QD.intItemId
LEFT JOIN dbo.vyuTRSupplyPointView TR ON TR.intSupplyPointId = QD.intSupplyPointId
WHERE QH.strQuoteStatus = 'Confirmed'
	OR QH.strQuoteStatus = 'Sent'
ORDER BY EL.strLocationName, IC.strItemNo, dblQuotePrice ASC