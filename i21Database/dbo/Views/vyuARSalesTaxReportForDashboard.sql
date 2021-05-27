CREATE VIEW [dbo].[vyuARSalesTaxReportForDashboard]
AS
SELECT 
	tblARAccountStatus.strAccountStatusCode, 
	tblARCustomer.strCustomerNumber, 
	strDisplayName,
	strShipToLocationAddress,
	strLocationName,
	strCity,
	strState, 
	vyuARTaxReport.strInvoiceNumber,
	dtmDate,
	vyuARTaxReport.strItemNo, 
	tblICItem.strDescription,
	strItemCategory,
	strCalculationMethod,
	dblRate,
	dblQtyShipped,
	dblUnitPrice,
	dblNonTaxable,
	dblTaxable,
	dblAdjustedTax,
	dblTax,
	dblTotalAdjustedTax,
	dblTotalTax, 
	dblTaxDifference,
	dblTaxAmount, 
	dblTotalSales,
	dblTaxCollected,
	strSalesTaxAccount,
	strPurchaseTaxAccount,
	dblQtyShipped * dblUnitPrice [dblQtyShippedxUnitPrice],
	dblInvoiceTotal,
	FETG, FETCD, ARSG, ARSDD, ILSCD, ILST, ILL, ILEIF, FL, ILPPG, ARPEV, ARSCD, MOSCD, ILSG, MOSG, ILSDD, MOSDD, ARST, INST, MOST, ILPPD, ERG, ERD, MOIF, MOTF, MODD, MODG, ERB11C, ERB11D, ERGH, ERB5D, ERB20D, ERB50D, ERB5C, ERB20C, ERB50C, ERB2C, ERB2D, ERC,ILStateSalesTaxZero
FROM vyuARTaxReport 
INNER JOIN tblARCustomer  ON vyuARTaxReport.strCustomerNumber = tblARCustomer.strCustomerNumber
INNER JOIN tblICItem ON tblICItem.strItemNo = vyuARTaxReport.strItemNo
LEFT JOIN tblARCustomerAccountStatus ON tblARCustomer.intEntityId=tblARCustomerAccountStatus.intEntityCustomerId
LEFT JOIN tblARAccountStatus  ON tblARCustomerAccountStatus.intAccountStatusId = tblARAccountStatus.intAccountStatusId
LEFT JOIN  (
	SELECT intEntityCustomerId,strInvoiceNumber,strItemNo,intTaxCodeId,ISNULL([FETG],0)[FETG], ISNULL([FETCD],0)[FETCD], ISNULL([ARSG],0)[ARSG], ISNULL([ARSDD],0)[ARSDD], ISNULL([ILSCD],0)[ILSCD], ISNULL([ILST],0)[ILST], ISNULL([ILL],0)[ILL], ISNULL([ILEIF],0)[ILEIF], ISNULL([FL],0)[FL], ISNULL([ILPPG],0)[ILPPG], ISNULL([ARPEV],0)[ARPEV], ISNULL([ARSCD],0)[ARSCD], ISNULL([MOSCD],0)[MOSCD], ISNULL([ILSG],0)[ILSG], ISNULL([MOSG],0)[MOSG], ISNULL([ILSDD],0)[ILSDD], ISNULL([MOSDD],0)[MOSDD], ISNULL([ARST],0)[ARST], ISNULL([INST],0)[INST], ISNULL([MOST],0)[MOST], ISNULL([ILPPD],0)[ILPPD], ISNULL([ERG],0)[ERG], ISNULL([ERD],0)[ERD], ISNULL([MOIF],0)[MOIF], ISNULL([MOTF],0)[MOTF], ISNULL([MODD],0)[MODD], ISNULL([MODG],0)[MODG], ISNULL([ERB11C],0)[ERB11C], ISNULL([ERB11D],0)[ERB11D], ISNULL([ERGH],0)[ERGH], ISNULL([ERB5D],0)[ERB5D], ISNULL([ERB20D],0)[ERB20D], ISNULL([ERB50D],0)[ERB50D], ISNULL([ERB5C],0)[ERB5C], ISNULL([ERB20C],0)[ERB20C], ISNULL([ERB50C],0)[ERB50C], ISNULL([ERB2C],0)[ERB2C], ISNULL([ERB2D],0)[ERB2D], ISNULL([ERC],0)[ERC], ISNULL([ILStateSalesTaxZero],0)[ILStateSalesTaxZero]
FROM 
(
   SELECT intEntityCustomerId,TAX.strTaxCode,dblTaxAmount,strInvoiceNumber,strItemNo,TAX.intTaxCodeId  from tblSMTaxCode TAX
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

)TaxColumn ON
  TaxColumn.intEntityCustomerId=vyuARTaxReport.intEntityCustomerId 
  AND TaxColumn.strInvoiceNumber=vyuARTaxReport.strInvoiceNumber 
  AND TaxColumn.strItemNo=vyuARTaxReport.strItemNo
  AND TaxColumn.intTaxCodeId = vyuARTaxReport.intTaxCodeId