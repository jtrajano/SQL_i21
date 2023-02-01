﻿CREATE VIEW [dbo].[vyuTRQuoteReport]
	AS

SELECT TOP 100 PERCENT intQuoteDetailId = ISNULL(QD.intQuoteDetailId, 0)
	, strCompanyName = CompanySetup.strCompanyName
	, strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, CompanySetup.strAddress, CompanySetup.strCity, CompanySetup.strState, CompanySetup.strZip, CompanySetup.strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
	, QH.strQuoteNumber
	, GETDATE() AS dtmGeneratedDate
	, QH.dtmQuoteDate
	, strCustomer = dbo.fnARFormatCustomerAddress(NULL, NULL, AR.strBillToLocationName, AR.strBillToAddress, AR.strBillToCity, AR.strBillToState, AR.strBillToZipCode, AR.strBillToCountry, AR.strName, AR.ysnIncludeEntityName) COLLATE Latin1_General_CI_AS
	, strSalesperson = dbo.fnARFormatCustomerAddress(SP.strName, SP.strPhone, SP.strEmail, NULL, NULL, NULL, NULL, NULL, NULL, 0) COLLATE Latin1_General_CI_AS
	, EL.strLocationName
	, strItemNo = IC.strDescription
	, TR.strSupplyPoint
	, QH.dtmQuoteEffectiveDate
	, dblPriceChange = CASE WHEN ISNULL(QuotePrice.dblQuotePrice, 0) = 0 THEN CAST('N/A' AS NVARCHAR(50))
							WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) < 0 THEN CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50))
							WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) = 0 THEN CAST('0.00' AS NVARCHAR(50))
							ELSE '+' + CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50)) END COLLATE Latin1_General_CI_AS
	--, dblQuotePrice = (CASE WHEN CustomerTransports.ysnShowTaxDetail = 0 AND CustomerTransports.ysnShowFeightDetail = 0 THEN ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0)--Roll-up
	--						WHEN CustomerTransports.ysnShowTaxDetail = 1 AND CustomerTransports.ysnShowFeightDetail = 1 THEN ISNULL(QD.dblQuotePrice, 0) - ISNULL(QD.dblFreightRate, 0)--Itemize
	--						WHEN CustomerTransports.ysnShowTaxDetail = 1 AND CustomerTransports.ysnShowFeightDetail = 0 THEN ISNULL(QD.dblQuotePrice, 0)--Rollup
	--						WHEN CustomerTransports.ysnShowTaxDetail = 0 AND CustomerTransports.ysnShowFeightDetail = 1 THEN ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0) - ISNULL(QD.dblFreightRate, 0) END)--Rollup

	, dblQuotePrice = (CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Roll-up' THEN ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0)
							ELSE ISNULL(QD.dblQuotePrice, 0) - (ISNULL(QD.dblFreightRate, 0) + (CASE WHEN TransportsCompanyPreference.ysnIncludeSurchargeInQuote = 1 THEN ISNULL(dblSurcharge, 0) ELSE 0 END)) END)

	--, dblTotalPrice = ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0)
	, dblTotalPrice = (CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Exclude' THEN ISNULL(QD.dblQuotePrice, 0) - (ISNULL(QD.dblFreightRate, 0) + (CASE WHEN TransportsCompanyPreference.ysnIncludeSurchargeInQuote = 1 THEN ISNULL(dblSurcharge, 0) ELSE 0 END))
							ELSE ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0) END)
	, ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) 
									FROM vyuARCustomerContacts CC 
									WHERE CC.intCustomerEntityId = QH.intEntityCustomerId 
										AND ISNULL(CC.strEmail, '') <> ''
										AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) 
							ELSE CONVERT(BIT, 0) END
	, QH.intQuoteHeaderId
	, QH.strQuoteComments
	, strNote = (CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Roll-up' THEN 'Note: Tax and Fees inclusive.' ELSE null END) COLLATE Latin1_General_CI_AS
	--, CustomerTransports.ysnShowTaxDetail
	, ysnShowTaxDetail = (CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Itemize' THEN convert(bit,1) ELSE convert(bit,0) END)
	, dblTax = ISNULL(QD.dblTax, 0)
	--, CustomerTransports.ysnShowFeightDetail
	, ysnShowFeightDetail = (CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Itemize' THEN convert(bit,1) ELSE convert(bit,0) END)
	, dblFreight = ISNULL(QD.dblFreightRate, 0)
	, dblSurcharge = ISNULL(QD.dblFreightRate, 0)
	, ysnShowSurcharge = CASE WHEN ((CASE WHEN CustomerTransports.strShowTaxFeeDetail = 'Itemize' THEN convert(bit,1) ELSE convert(bit,0) END) = 1 AND ISNULL(TransportsCompanyPreference.ysnIncludeSurchargeInQuote, 0) = 1) THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
FROM tblTRQuoteHeader QH
CROSS APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
CROSS APPLY (SELECT TOP 1 * FROM tblTRCompanyPreference) TransportsCompanyPreference
LEFT JOIN tblTRQuoteDetail QD ON QD.intQuoteHeaderId = QH.intQuoteHeaderId
LEFT JOIN vyuARCustomerSearch AR ON QH.intEntityCustomerId = AR.intEntityId
LEFT JOIN tblARCustomerRackQuoteHeader CustomerTransports ON CustomerTransports.intEntityCustomerId = AR.intEntityId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntityId = AR.intSalespersonId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = QD.intShipToLocationId
	AND EL.intEntityId = QH.intEntityCustomerId
LEFT JOIN tblICItem IC ON IC.intItemId = QD.intItemId
LEFT JOIN vyuTRSupplyPointView TR ON TR.intSupplyPointId = QD.intSupplyPointId
OUTER APPLY (
	SELECT TOP 1 dblQuotePrice = ISNULL(PQD.dblQuotePrice, 0)
	FROM tblTRQuoteHeader PQH
	JOIN tblTRQuoteDetail PQD on PQH.intQuoteHeaderId = PQD.intQuoteHeaderId
	WHERE PQH.dtmQuoteEffectiveDate < QH.dtmQuoteEffectiveDate 
		AND PQH.intEntityCustomerId = QH.intEntityCustomerId 
		AND PQH.strQuoteStatus in ('Confirmed','Sent')
		AND PQD.intItemId = QD.intItemId 
		AND PQD.intShipToLocationId = QD.intShipToLocationId
	ORDER BY PQH.dtmQuoteEffectiveDate DESC, PQH.intQuoteHeaderId DESC
) QuotePrice
WHERE QH.strQuoteStatus = 'Confirmed'
	OR QH.strQuoteStatus = 'Sent'
ORDER BY EL.strLocationName, IC.strItemNo, dblQuotePrice ASC
	/*
SELECT TOP 100 PERCENT QD.intQuoteDetailId
	, strCompanyName = CompanySetup.strCompanyName
	, strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, CompanySetup.strAddress, CompanySetup.strCity, CompanySetup.strState, CompanySetup.strZip, CompanySetup.strCountry, NULL, 0)
	, QH.strQuoteNumber
	, GETDATE() AS dtmGeneratedDate
	, QH.dtmQuoteDate
	, strCustomer = dbo.fnARFormatCustomerAddress(NULL, NULL, AR.strBillToLocationName, AR.strBillToAddress, AR.strBillToCity, AR.strBillToState, AR.strBillToZipCode, AR.strBillToCountry, AR.strName, AR.ysnIncludeEntityName)
	, strSalesperson = dbo.fnARFormatCustomerAddress(SP.strName, SP.strPhone, SP.strEmail, NULL, NULL, NULL, NULL, NULL, NULL, 0)
	, EL.strLocationName
	, strItemNo = IC.strDescription
	, TR.strSupplyPoint
	, QH.dtmQuoteEffectiveDate
	, dblPriceChange = CASE WHEN ISNULL(QuotePrice.dblQuotePrice, 0) = 0 THEN CAST('N/A' AS NVARCHAR(50))
							WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) < 0 THEN CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50))
							WHEN (ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) = 0 THEN CAST('0.00' AS NVARCHAR(50))
							ELSE '+' + CAST((ISNULL(QD.dblQuotePrice, 0) - ISNULL(QuotePrice.dblQuotePrice, 0)) AS NVARCHAR(50)) END
	, dblQuotePrice = (CASE WHEN CustomerTransports.ysnShowTaxDetail = 0 AND CustomerTransports.ysnShowFeightDetail = 0 THEN ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0)
							WHEN CustomerTransports.ysnShowTaxDetail = 1 AND CustomerTransports.ysnShowFeightDetail = 1 THEN ISNULL(QD.dblQuotePrice, 0) - ISNULL(QD.dblFreightRate, 0)
							WHEN CustomerTransports.ysnShowTaxDetail = 1 AND CustomerTransports.ysnShowFeightDetail = 0 THEN ISNULL(QD.dblQuotePrice, 0)
							WHEN CustomerTransports.ysnShowTaxDetail = 0 AND CustomerTransports.ysnShowFeightDetail = 1 THEN ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0) - ISNULL(QD.dblFreightRate, 0) END)
	, dblTotalPrice = ISNULL(QD.dblQuotePrice, 0) + ISNULL(QD.dblTax, 0)
	, ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) 
									FROM vyuARCustomerContacts CC 
									WHERE CC.intCustomerEntityId = QH.intEntityCustomerId 
										AND ISNULL(CC.strEmail, '') <> ''
										AND CC.strEmailDistributionOption LIKE '%' + 'Transport Quote' + '%') > 0 THEN CONVERT(BIT, 1) 
							ELSE CONVERT(BIT, 0) END
	, QH.intQuoteHeaderId
	, QH.strQuoteComments
	, CustomerTransports.ysnShowTaxDetail
	, dblTax = ISNULL(QD.dblTax, 0)
	, CustomerTransports.ysnShowFeightDetail
	, dblFreight = ISNULL(QD.dblFreightRate, 0)
FROM tblTRQuoteHeader QH
CROSS APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) CompanySetup
LEFT JOIN tblTRQuoteDetail QD ON QD.intQuoteHeaderId = QH.intQuoteHeaderId
LEFT JOIN vyuARCustomerSearch AR ON QH.intEntityCustomerId = AR.intEntityId
LEFT JOIN tblARCustomerRackQuoteHeader CustomerTransports ON CustomerTransports.intEntityCustomerId = AR.intEntityId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntityId = AR.intSalespersonId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = QD.intShipToLocationId
	AND EL.intEntityId = QH.intEntityCustomerId
LEFT JOIN tblICItem IC ON IC.intItemId = QD.intItemId
LEFT JOIN vyuTRSupplyPointView TR ON TR.intSupplyPointId = QD.intSupplyPointId
OUTER APPLY (
	SELECT TOP 1 dblQuotePrice = ISNULL(PQD.dblQuotePrice, 0)
	FROM tblTRQuoteHeader PQH
	JOIN tblTRQuoteDetail PQD on PQH.intQuoteHeaderId = PQD.intQuoteHeaderId
	WHERE PQH.dtmQuoteEffectiveDate < QH.dtmQuoteEffectiveDate 
		AND PQH.intEntityCustomerId = QH.intEntityCustomerId 
		AND PQH.strQuoteStatus in ('Confirmed','Sent')
		AND PQD.intItemId = QD.intItemId 
		AND PQD.intShipToLocationId = QD.intShipToLocationId
	ORDER BY PQH.dtmQuoteEffectiveDate DESC, PQH.intQuoteHeaderId DESC
) QuotePrice
WHERE QH.strQuoteStatus = 'Confirmed'
	OR QH.strQuoteStatus = 'Sent'
ORDER BY EL.strLocationName, IC.strItemNo, dblQuotePrice ASC
*/