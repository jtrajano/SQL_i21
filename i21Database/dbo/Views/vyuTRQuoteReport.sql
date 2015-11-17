CREATE VIEW [dbo].[vyuTRQuoteReport]
	AS 
SELECT 
   (select top 1 CM.strCompanyName from tblSMCompanySetup CM ) as strCompanyName,
   (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, CCM.strAddress, CCM.strCity, CCM.strState, CCM.strZip, CCM.strCountry, NULL) FROM tblSMCompanySetup CCM) as strCompanyAddress,
   QH.strQuoteNumber,
   getdate() as dtmGeneratedDate,   
   QH.dtmQuoteDate,
   strCustomer = [dbo].fnARFormatCustomerAddress(NULL, NULL, AR.strBillToLocationName, AR.strBillToAddress, AR.strBillToCity, AR.strBillToState, AR.strBillToZipCode, AR.strBillToCountry, AR.strName),
   strSalesperson = [dbo].fnARFormatCustomerAddress(SP.strPhone, SP.strEmail, NULL, NULL, NULL, NULL, NULL, NULL, SP.strName),
   EL.strLocationName,
   IC.strItemNo,
   TR.strSupplyPoint,
   QH.dtmQuoteEffectiveDate,
   (QD.dblQuotePrice - (select top 1 PQD.dblQuotePrice from tblTRQuoteHeader PQH
                                join tblTRQuoteDetail PQD on PQH.intQuoteHeaderId = PQD.intQuoteHeaderId
           where PQH.strQuoteNumber < QH.strQuoteNumber and PQH.intEntityCustomerId = QH.intEntityCustomerId and PQH.strQuoteStatus = 'Confirmed' and PQD.intItemId = QD.intItemId and PQD.intShipToLocationId = QD.intShipToLocationId
           order by PQH.strQuoteNumber DESC)) as dblPriceChange,
   QD.dblQuotePrice,
   ysnHasEmailSetup = CASE WHEN (SELECT COUNT(*) FROM vyuARCustomerContacts CC WHERE CC.intCustomerEntityId = QH.intEntityCustomerId AND ISNULL(CC.strEmail, '') <> '' AND CC.strEmailDistributionOption LIKE '%' + 'Quotes' + '%') > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END, 
   QH.intQuoteHeaderId,
   QH.strQuoteComments	
FROM
    dbo.tblTRQuoteHeader QH
	left join dbo.tblTRQuoteDetail QD on QD.intQuoteHeaderId = QH.intQuoteHeaderId
	join dbo.vyuARCustomer AR on QH.intEntityCustomerId = AR.intEntityCustomerId
	left join dbo.vyuEMSalesperson SP on SP.intEntitySalespersonId = AR.intSalespersonId
	left join dbo.tblEntityLocation EL on EL.intEntityLocationId = QD.intShipToLocationId and EL.intEntityId = QH.intEntityCustomerId
	left join dbo.tblICItem IC on IC.intItemId = QD.intItemId
	left join dbo.vyuTRSupplyPointView TR on TR.intSupplyPointId = QD.intSupplyPointId
where QH.strQuoteStatus = 'Confirmed'