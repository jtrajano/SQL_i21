CREATE VIEW [dbo].[vyuARRestrictedChemicalsReport]
AS
SELECT strCompanyName		= (CASE WHEN CL.strUseLocationAddress = 'Letterhead'
										THEN ''
									ELSE
										(SELECT TOP 1 strCompanyName FROM tblSMCompanySetup)
								END)
	, strCompanyAddress		= (CASE WHEN CL.strUseLocationAddress IS NULL OR CL.strUseLocationAddress = 'No' OR CL.strUseLocationAddress = '' OR CL.strUseLocationAddress = 'Always'
										THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, ysnIncludeEntityName) FROM tblSMCompanySetup)
									WHEN CL.strUseLocationAddress = 'Yes'
										THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, CL.strAddress, CL.strCity, CL.strStateProvince, CL.strZipPostalCode, CL.strCountry, NULL, ysnIncludeEntityName)
									WHEN CL.strUseLocationAddress = 'Letterhead'
										THEN ''
								END)
  , I.intCompanyLocationId
  , CL.strLocationName
  , ICI.intCategoryId
  , ICC.strCategoryCode
  , ID.intItemId
  , ID.strItemDescription
  , ICI.strItemNo
  , ICI.strDescription
  , ICI.strEPANumber
  , ICI.intManufacturerId
  , ICM.strManufacturer
  , I.intEntityCustomerId
  , C.strCustomerNumber
  , E.strName
  , strCustomerAddress = [dbo].fnARFormatCustomerAddress(NULL, NULL, I.strBillToLocationName, I.strBillToAddress, I.strBillToCity, I.strBillToState, I.strBillToZipCode, I.strBillToCountry, E.strName, C.ysnIncludeEntityName)
  , I.dtmDate
  , I.intInvoiceId
  , I.strInvoiceNumber
  , ID.dblQtyShipped
  , ID.intItemUOMId
  , UOM.strUnitMeasure
  , ID.dblPrice
  , ID.dblTotal
FROM tblARInvoice I
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
	INNER JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
	INNER JOIN (tblARCustomer C INNER JOIN tblEMEntity E ON C.intEntityCustomerId = E.intEntityId) ON C.intEntityCustomerId = I.intEntityCustomerId
	LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
	LEFT JOIN tblICManufacturer ICM ON ICI.intManufacturerId = ICM.intManufacturerId
	LEFT JOIN vyuARItemUOM UOM ON ID.intItemUOMId = UOM.intItemUOMId
WHERE I.ysnPosted = 1
AND ((I.strType = 'Service Charge' AND I.ysnForgiven = 0) OR ((I.strType <> 'Service Charge' AND I.ysnForgiven = 1) OR (I.strType <> 'Service Charge' AND I.ysnForgiven = 0)))
AND ICI.ysnRestrictedChemical = 1