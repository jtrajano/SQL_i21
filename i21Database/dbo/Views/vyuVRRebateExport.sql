CREATE VIEW [dbo].[vyuVRRebateExport]
AS  
SELECT 
	  invoice.strInvoiceNumber
	, rebate.intRebateId
	, vendorSetup.strCompany1Id
	, vendorSetup.strCompany2Id
	, invoice.dtmShipDate
	, invoice.dtmDate dtmInvoiceDate
	, invoice.strBOLNumber
	, vendorXRef.strVendorProduct
	, rebate.dblQuantity
	, invoiceDetail.dblPrice
	, invoiceDetail.intItemUOMId
	, category.strCategoryCode
	, strVendorCategory = categoryVendor.strVendorDepartment
	, item.strItemNo
	, strVendorItemNo = vendorXRef.strVendorProduct
	, strVendorUOM = uomXref.strVendorUOM
	, intProgramId = program.intProgramId
	, vendorSetup.intVendorSetupId
	, invoice.intInvoiceId
	, uom.strUnitMeasure
	, program.strVendorProgram
	, program.strProgramDescription
	, customerXref.strVendorCustomer
	, rebate.intConcurrencyId
	, invoiceDetail.intInvoiceDetailId
	, strVendorName = vendorEntity.strName
	, customer.strCustomerNumber
	, customerEntity.strName strCustomerName
	, rebate.dblRebateRate
	, vendorSetup.strMarketerAccountNo
	, vendorSetup.strMarketerEmail
	, vendorSetup.strDataFileTemplate
	, vendorSetup.strExportFilePath
	, rebate.strSubmitted
FROM tblVRRebate rebate
INNER JOIN tblARInvoiceDetail invoiceDetail ON invoiceDetail.intInvoiceDetailId = rebate.intInvoiceDetailId
INNER JOIN tblARInvoice invoice ON invoice.intInvoiceId = invoiceDetail.intInvoiceId
INNER JOIN tblICItem item ON item.intItemId = invoiceDetail.intItemId
INNER JOIN tblICCategory category ON category.intCategoryId = item.intCategoryId
INNER JOIN tblICItemUOM itemUOM ON itemUOM.intItemUOMId = invoiceDetail.intItemUOMId
INNER JOIN tblICUnitMeasure uom ON uom.intUnitMeasureId = itemUOM.intUnitMeasureId
INNER JOIN tblARCustomer customer ON customer.intEntityId = invoice.intEntityCustomerId
INNER JOIN tblEMEntity customerEntity ON customerEntity.intEntityId = customer.intEntityId
INNER JOIN tblVRProgram program ON program.intProgramId = rebate.intProgramId
INNER JOIN tblVRVendorSetup vendorSetup ON vendorSetup.intVendorSetupId = program.intVendorSetupId
INNER JOIN tblAPVendor vendor ON vendor.intEntityId = vendorSetup.intEntityId
INNER JOIN tblEMEntity vendorEntity ON vendorEntity.intEntityId = vendor.intEntityId
INNER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = invoice.intCompanyLocationId
LEFT OUTER JOIN tblICItemVendorXref vendorXRef ON vendorXRef.intItemId = item.intItemId
    AND vendorXRef.intVendorSetupId = vendorSetup.intVendorSetupId
LEFT OUTER JOIN tblICCategoryVendor categoryVendor ON categoryVendor.intCategoryId = category.intCategoryId
    AND categoryVendor.intVendorSetupId = vendorSetup.intVendorSetupId
LEFT OUTER JOIN tblVRUOMXref uomXref ON uomXref.intUnitMeasureId = uom.intUnitMeasureId
    AND vendorSetup.intVendorSetupId = uomXref.intVendorSetupId
LEFT OUTER JOIN tblVRCustomerXref customerXref ON customerXref.intVendorSetupId = vendorSetup.intVendorSetupId
    AND customerXref.intEntityId = invoice.intEntityCustomerId
WHERE program.ysnActive = 1