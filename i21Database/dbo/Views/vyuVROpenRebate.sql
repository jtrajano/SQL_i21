CREATE VIEW [dbo].[vyuVROpenRebate]
AS
SELECT *
	, dblRebateAmount = CASE WHEN strRebateBy = 'Percentage' THEN  CAST((dblRebateQuantity * dblRebateRate * dblCost / 100) AS NUMERIC(18, 6))
		ELSE CAST((dblRebateQuantity * dblRebateRate) AS NUMERIC(18, 6))
		END
FROM (
	SELECT CASE WHEN pi.intItemId IS NULL THEN 'Category Level' ELSE 'Item Level' END AS Mode,
		intRowId = CAST(ROW_NUMBER() OVER(ORDER BY invoice.intInvoiceId) AS INT)
		, strVendorNumber = vendor.strVendorId
		, strVendorName = entity.strName
		, program.strProgram
		, customer.strCustomerNumber
		, strVendorCustomer = entityCustomer.strName
		, invoice.strInvoiceNumber
		, invoice.strBOLNumber
		, invoice.dtmDate
		, strItemNumber = item.strItemNo
		, strItemDescription = item.strDescription
		, category.strCategoryCode
		, dblQtyShipped = CASE WHEN invoice.strTransactionType = 'Credit Memo' THEN (invoiceDetail.dblQtyShipped * -1) ELSE invoiceDetail.dblQtyShipped END
		, strUnitMeasure = CASE WHEN pi.intItemId IS NULL THEN unitMeasure.strUnitMeasure ELSE itemUnitMeasure.strUnitMeasure END
		, dblUnitQty = CASE WHEN pi.intItemId IS NULL THEN uom.dblUnitQty ELSE itemUOM.dblUnitQty END
		, dblCost = invoiceDetail.dblPrice
		, dblRebateRate = CASE WHEN pi.intItemId IS NULL THEN ISNULL(programCategory.dblRebateRate, 0.00) ELSE ISNULL(pi.dblRebateRate, 0.00) END
		, dblRebateQuantity =
			CASE WHEN pi.intItemId IS NULL THEN 
				CASE WHEN invoice.strTransactionType = 'Credit Memo' THEN
					ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, 
						uom.intItemUOMId, invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)) * -1,
						(invoiceDetail.dblQtyShipped * -1))
					ELSE ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, uom.intItemUOMId, 
						invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)),
							invoiceDetail.dblQtyShipped)
				END
			ELSE
				CASE WHEN invoice.strTransactionType = 'Credit Memo' THEN
					ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, 
						itemUOM.intItemUOMId, invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)) * -1,
						(invoiceDetail.dblQtyShipped * -1))
					ELSE ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, itemUOM.intItemUOMId, 
						invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)), invoiceDetail.dblQtyShipped)
				END
			END	
		, invoiceDetail.intInvoiceDetailId
		, invoiceDetail.intConcurrencyId
		, program.intProgramId
		, strRebateBy = CASE WHEN pi.intItemId IS NULL THEN programCategory.strRebateBy ELSE pi.strRebateBy END
		, companyLocation.strLocationName
		, intVendorSetupId = program.intVendorSetupId
		, invoice.intInvoiceId
		, program.ysnActive
		, strInvoiceUnitMeasure = invoiceUnitMeasure.strUnitMeasure
		, dm.strBillId strDebitMemoVoucherNumber
		, dm.intBillId intDebitMemoVoucherId
	FROM tblARInvoiceDetail invoiceDetail
		INNER JOIN tblARInvoice invoice ON invoice.intInvoiceId = invoiceDetail.intInvoiceId
		INNER JOIN tblICItem item ON item.intItemId = invoiceDetail.intItemId
		INNER JOIN tblICCategory category ON category.intCategoryId = item.intCategoryId
		LEFT OUTER JOIN tblICItemUOM invoiceItemUOM ON invoiceItemUOM.intItemUOMId = invoiceDetail.intItemUOMId
			AND invoiceItemUOM.intItemId = invoiceDetail.intItemId
		LEFT OUTER JOIN tblICUnitMeasure invoiceUnitMeasure ON invoiceUnitMeasure.intUnitMeasureId = invoiceItemUOM.intUnitMeasureId
		LEFT OUTER JOIN tblARCustomer customer ON customer.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblEMEntity entityCustomer ON entityCustomer.intEntityId = customer.intEntityId
		--LEFT OUTER JOIN tblVRCustomerXref customerXref ON customerXref.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblVRProgramCustomer programCustomer ON programCustomer.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblVRProgram program ON program.intProgramId = programCustomer.intProgramId
		LEFT OUTER JOIN tblVRVendorSetup vendorSetup ON vendorSetup.intVendorSetupId = program.intVendorSetupId
		LEFT OUTER JOIN (
			SELECT pi.*, uom.intItemUOMId
			FROM tblVRProgramItem pi
				LEFT JOIN tblICItemUOM uom ON pi.intItemId = uom.intItemId
					AND pi.intUnitMeasureId = uom.intUnitMeasureId
		) programCategory ON programCategory.intProgramId = program.intProgramId
			AND programCategory.intItemId IS NULL
			AND invoice.dtmDate >= programCategory.dtmBeginDate
			AND invoice.dtmDate <= ISNULL(programCategory.dtmEndDate, '12/31/9999')
			AND (ISNULL(programCategory.dblRebateRate, 0) <> 0)
			AND programCategory.intCategoryId = item.intCategoryId
			AND NOT EXISTS (
				SELECT TOP 1 1
				FROM vyuVROpenRebateAll v
				WHERE Mode = 'Item Level'
					AND v.intInvoiceDetailId = invoiceDetail.intInvoiceDetailId
					AND v.strItemNumber = item.strItemNo
					AND v.intVendorSetupId = program.intVendorSetupId
			)
		LEFT OUTER JOIN tblICItemUOM uom ON uom.intItemId = invoiceDetail.intItemId
			AND uom.intUnitMeasureId = programCategory.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = uom.intUnitMeasureId
		LEFT OUTER JOIN tblAPVendor vendor ON vendor.intEntityId = vendorSetup.intEntityId
		LEFT OUTER JOIN tblEMEntity entity ON entity.intEntityId = vendor.intEntityId
		LEFT OUTER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = invoice.intCompanyLocationId

		LEFT OUTER JOIN tblVRProgramItem pi ON pi.intProgramId = program.intProgramId
			AND pi.intItemId = item.intItemId
			AND invoice.dtmDate >= pi.dtmBeginDate
			AND invoice.dtmDate <= ISNULL(pi.dtmEndDate, '12/31/9999')
		LEFT OUTER JOIN tblICItemUOM itemUOM ON itemUOM.intItemId = invoiceDetail.intItemId
			and itemUOM.intUnitMeasureId = pi.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure itemUnitMeasure ON itemUnitMeasure.intUnitMeasureId = pi.intUnitMeasureId
		OUTER APPLY (
			SELECT TOP 1 b.strBillId, b.intBillId
			FROM tblAPBill b
			WHERE b.strVendorOrderNumber = invoice.strInvoiceNumber
		) dm
	WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblVRRebate WHERE intInvoiceDetailId = invoiceDetail.intInvoiceDetailId)
		AND invoice.ysnPosted = 1
		AND invoice.strTransactionType IN ('Invoice', 'Credit Memo', 'Cash')
) openRebates
WHERE openRebates.strProgram IS NOT NULL
	AND openRebates.dblRebateRate <> 0
	AND openRebates.ysnActive = 1