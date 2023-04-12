CREATE VIEW [dbo].[vyuVRRebate]
AS  
SELECT
	  rebate.intConcurrencyId 
	, rebate.intRebateId
	, rebate.strSubmitted
	, rebate.intProgramId
	, rebate.ysnExported
	, dtmSubmittedDate = rebate.dtmDate
	, dblCost = invoiceDetail.dblPrice
	, dblRebateRate = rebate.dblRebateRate
	, dblRebateAmount = rebate.dblRebateAmount
	, dblQuantity = rebate.dblQuantity
	, invoiceDetail.intInvoiceDetailId
	, invoice.intInvoiceId
	, invoice.strInvoiceNumber
	, invoice.strBOLNumber
	, invoice.dtmDate
	, strItemNumber = item.strItemNo
	, strItemDescription = item.strDescription
	, category.strCategoryCode
	, itemUOM.dblUnitQty
	, uom.strUnitMeasure
	, customer.strCustomerNumber
	, program.strProgram
	, vendorSetup.intVendorSetupId
	, vendorSetup.strDataFileTemplate
	, strVendorNumber = vendor.strVendorId
	, strVendorName = vendorEntity.strName
	, companyLocation.strLocationName
	, strVendorCustomer = customerEntity.strName
	, dm.strBillId strDebitMemoVoucherNumber
	, dm.intBillId intDebitMemoVoucherId
	, rebate.ysnChevronUploaded
	, dm.strBillId strDebitMemoVoucherNumber
	, dm.intBillId intDebitMemoVoucherId
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
	OUTER APPLY (
		SELECT TOP 1 b.strBillId, b.intBillId
		FROM tblAPBill b
		WHERE b.strVendorOrderNumber = invoice.strInvoiceNumber
	) dm