CREATE VIEW [dbo].[vyuARSalesTaxReportForDashboard]
AS

SELECT 
	strAccountStatusCode		 = CustomerStatus.strAccountStatusCode, 
	strCustomerNumber			 = tblARCustomer.strCustomerNumber, 
	strDisplayName				 = vyuARTaxReport.strDisplayName,
	strShipToLocationAddress     = vyuARTaxReport.strShipToLocationAddress,
	strLocationName				 = CASE WHEN freight.strFobPoint = 'Destination' THEN  locship.strLocationName ELSE   loc.strLocationName END,
	strInvoiceNumber			 = vyuARTaxReport.strInvoiceNumber,
	dtmDate						 = vyuARTaxReport.dtmDate,
	strItemNo					 = vyuARTaxReport.strItemNo, 
	strDescription				 = tblICItem.strDescription,
	dblQtyShipped                = vyuARTaxReport.dblQtyShipped,
	dblUnitPrice				 = vyuARTaxReport.dblUnitPrice,
	strItemCategory				 = vyuARTaxReport.strItemCategory,
	strCity						 = CASE WHEN freight.strFobPoint = 'Destination' THEN  locship.strCity  ELSE   loc.strCity END,
	strState					 = CASE WHEN freight.strFobPoint = 'Destination' THEN  locship.strState ELSE   loc.strStateProvince END,
	dblRate						 = SUM(dblRate),
	dblNonTaxable			     = SUM(dblNonTaxable),
	dblTaxable					 = SUM(dblTaxable),
	dblAdjustedTax				 = SUM(dblAdjustedTax),
	dblTax						 = SUM(dblTax),
	dblTotalAdjustedTax			 = SUM(dblTotalAdjustedTax),
	dblTotalTax                  = SUM(dblTotalTax), 
	dblTaxDifference             = SUM(dblTaxDifference),
	dblTaxAmount                 = SUM(dblTaxAmount), 
	dblTotalSales                = SUM(dblTotalSales),
	dblTaxCollected              = SUM(dblTaxCollected),
	dblQtyShippedxUnitPrice      = vyuARTaxReport.dblQtyShipped * vyuARTaxReport.dblUnitPrice ,
	dblInvoiceTotal				 = vyuARTaxReport.dblInvoiceTotal,
	[FETG], [FETCD], [ARSG], [ARSDD], [ILSCD], [ILST], [ILL], [ILEIF], [FL], [ILPPG], [ARPEV], [ARSCD], [MOSCD], [ILSG], [MOSG], [ILSDD], [MOSDD], [ARST], [INST], [MOST], [ILPPD], [ERG], [ERD], [MOIF], [MOTF], [MODD], [MODG], [ERB11C], [ERB11D], [ERGH], [ERB5D], [ERB20D], [ERB50D], [ERB5C], [ERB20C], [ERB50C], [ERB2C], [ERB2D], [ERC], [ILStateSalesTaxZero]
FROM vyuARTaxReport  
INNER JOIN tblARCustomer  ON vyuARTaxReport.strCustomerNumber = tblARCustomer.strCustomerNumber
INNER JOIN tblICItem ON tblICItem.strItemNo = vyuARTaxReport.strItemNo
LEFT JOIN tblSMFreightTerms freight  ON freight.intFreightTermId= vyuARTaxReport.intFreightTermId
LEFT JOIN tblEMEntityLocation locship ON locship.intEntityLocationId = vyuARTaxReport.intShipToLocationId
LEFT JOIN tblSMCompanyLocation loc	ON  loc.intCompanyLocationId = vyuARTaxReport.intCompanyLocationId
OUTER APPLY(
	SELECT
	strAccountStatusCode = STUFF((SELECT  ',' + strAccountStatusCode
	FROM tblARCustomerAccountStatus customerstatus
	LEFT JOIN tblARAccountStatus accountstatus ON customerstatus.intAccountStatusId=accountstatus.intAccountStatusId
	WHERE tblARCustomer.intEntityId=customerstatus.intEntityCustomerId
	ORDER BY intCustomerAccountStatusId DESC
			  FOR XML PATH('')), 1, 1, '')
)CustomerStatus

OUTER APPLY (
SELECT intEntityCustomerId,strInvoiceNumber,strItemNo,ISNULL([FETG],0)[FETG], ISNULL([FETCD],0)[FETCD], ISNULL([ARSG],0)[ARSG], ISNULL([ARSDD],0)[ARSDD], ISNULL([ILSCD],0)[ILSCD], ISNULL([ILST],0)[ILST], ISNULL([ILL],0)[ILL], ISNULL([ILEIF],0)[ILEIF], ISNULL([FL],0)[FL], ISNULL([ILPPG],0)[ILPPG], ISNULL([ARPEV],0)[ARPEV], ISNULL([ARSCD],0)[ARSCD], ISNULL([MOSCD],0)[MOSCD], ISNULL([ILSG],0)[ILSG], ISNULL([MOSG],0)[MOSG], ISNULL([ILSDD],0)[ILSDD], ISNULL([MOSDD],0)[MOSDD], ISNULL([ARST],0)[ARST], ISNULL([INST],0)[INST], ISNULL([MOST],0)[MOST], ISNULL([ILPPD],0)[ILPPD], ISNULL([ERG],0)[ERG], ISNULL([ERD],0)[ERD], ISNULL([MOIF],0)[MOIF], ISNULL([MOTF],0)[MOTF], ISNULL([MODD],0)[MODD], ISNULL([MODG],0)[MODG], ISNULL([ERB11C],0)[ERB11C], ISNULL([ERB11D],0)[ERB11D], ISNULL([ERGH],0)[ERGH], ISNULL([ERB5D],0)[ERB5D], ISNULL([ERB20D],0)[ERB20D], ISNULL([ERB50D],0)[ERB50D], ISNULL([ERB5C],0)[ERB5C], ISNULL([ERB20C],0)[ERB20C], ISNULL([ERB50C],0)[ERB50C], ISNULL([ERB2C],0)[ERB2C], ISNULL([ERB2D],0)[ERB2D], ISNULL([ERC],0)[ERC], ISNULL([ILStateSalesTaxZero],0)[ILStateSalesTaxZero]
FROM 
(
   SELECT intEntityCustomerId,TAX.strTaxCode,dblTaxAmount,strInvoiceNumber,strItemNo  from tblSMTaxCode TAX
  left join (
	SELECT intEntityCustomerId,strTaxCode,dblTaxAmount,strInvoiceNumber,strItemNo,intTaxCodeId from vyuARTaxReport  TAXReport 
  )TaxReport ON TaxReport.intTaxCodeId = TAX.intTaxCodeId


    GROUP BY intEntityCustomerId,dblTaxAmount,strInvoiceNumber,strItemNo,TAX.intTaxCodeId,TAX.strTaxCode 
) src
pivot
(
  SUM(dblTaxAmount)
  FOR strTaxCode in ([FETG], [FETCD], [ARSG], [ARSDD], [ILSCD], [ILST], [ILL], [ILEIF], [FL], [ILPPG], [ARPEV], [ARSCD], [MOSCD], [ILSG], [MOSG], [ILSDD], [MOSDD], [ARST], [INST], [MOST], [ILPPD], [ERG], [ERD], [MOIF], [MOTF], [MODD], [MODG], [ERB11C], [ERB11D], [ERGH], [ERB5D], [ERB20D], [ERB50D], [ERB5C], [ERB20C], [ERB50C], [ERB2C], [ERB2D], [ERC], [ILStateSalesTaxZero])
) piv
 WHERE
  piv.intEntityCustomerId=tblARCustomer.intEntityId
  AND piv.strInvoiceNumber=vyuARTaxReport.strInvoiceNumber 
  AND piv.strItemNo=vyuARTaxReport.strItemNo

)TaxColumn

	GROUP BY
	strItemCategory,
	locship.strCity,
	locship.strState,
	loc.strCity,
	loc.strStateProvince,
	freight.strFobPoint,
	CustomerStatus.strAccountStatusCode, 
	tblARCustomer.strCustomerNumber, 
	strDisplayName,
	strShipToLocationAddress,
	locship.strLocationName,
	loc.strLocationName,
	vyuARTaxReport.strInvoiceNumber,
	dtmDate,
	vyuARTaxReport.strItemNo, 
	tblICItem.strDescription,
	dblQtyShipped,
	dblUnitPrice,
	dblInvoiceTotal,
	[FETG], [FETCD], [ARSG], [ARSDD], [ILSCD], [ILST], [ILL], [ILEIF], [FL], [ILPPG], [ARPEV], [ARSCD], [MOSCD], [ILSG], [MOSG], [ILSDD], [MOSDD], [ARST], [INST], [MOST], [ILPPD], [ERG], [ERD], [MOIF], [MOTF], [MODD], [MODG], [ERB11C], [ERB11D], [ERGH], [ERB5D], [ERB20D], [ERB50D], [ERB5C], [ERB20C], [ERB50C], [ERB2C], [ERB2D], [ERC], [ILStateSalesTaxZero]
