CREATE VIEW [dbo].[vyuVROpenRebate]
AS
SELECT *
	, dblRebateAmount = CASE WHEN strRebateBy = 'Unit' THEN CAST((dblRebateQuantity * dblRebateRate) AS NUMERIC(18, 6))
		ELSE CAST((dblRebateQuantity * dblRebateRate * dblCost / 100) AS NUMERIC(18, 6))
		END
FROM (
	SELECT
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
		, unitMeasure.strUnitMeasure
		, uom.dblUnitQty
		, dblCost = invoiceDetail.dblPrice
		, dblRebateRate = ISNULL(programItem.dblRebateRate, ISNULL(programCategory.dblRebateRate, 0.00))
		, dblRebateQuantity = CASE WHEN invoice.strTransactionType = 'Credit Memo' THEN
				ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, ISNULL(programItem.intItemUOMId, ISNULL(uom.intItemUOMId, 0.00)), invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)) * -1,
					(invoiceDetail.dblQtyShipped * -1))
				ELSE
				ISNULL(CAST((dbo.fnCalculateQtyBetweenUOM(invoiceDetail.intItemUOMId, ISNULL(programItem.intItemUOMId, ISNULL(uom.intItemUOMId, 0.00)), invoiceDetail.dblQtyShipped)) AS NUMERIC(18, 6)),
					invoiceDetail.dblQtyShipped)
				END
		, invoiceDetail.intInvoiceDetailId
		, invoiceDetail.intConcurrencyId
		, program.intProgramId
		, strRebateBy = ISNULL(programItem.strRebateBy, programCategory.strRebateBy)
		, companyLocation.strLocationName
		, intVendorSetupId = program.intVendorSetupId
		, invoice.intInvoiceId
		, program.ysnActive
	FROM tblARInvoiceDetail invoiceDetail
		INNER JOIN tblARInvoice invoice ON invoice.intInvoiceId = invoiceDetail.intInvoiceId
		INNER JOIN tblICItem item ON item.intItemId = invoiceDetail.intItemId
		INNER JOIN tblICCategory category ON category.intCategoryId = item.intCategoryId
		LEFT OUTER JOIN tblARCustomer customer ON customer.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblEMEntity entityCustomer ON entityCustomer.intEntityId = customer.intEntityId
		--LEFT OUTER JOIN tblVRCustomerXref customerXref ON customerXref.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblVRProgramCustomer programCustomer ON programCustomer.intEntityId = invoice.intEntityCustomerId
		LEFT OUTER JOIN tblVRProgram program ON program.intProgramId = programCustomer.intProgramId
		LEFT OUTER JOIN tblVRVendorSetup vendorSetup ON vendorSetup.intVendorSetupId = program.intVendorSetupId
		LEFT OUTER JOIN (
			SELECT
				pi.*, uom.intItemUOMId
			FROM tblVRProgramItem pi
				LEFT JOIN tblICItemUOM uom
				ON pi.intItemId = uom.intItemId
					AND pi.intUnitMeasureId = uom.intUnitMeasureId
			) programItem ON programItem.intProgramId = program.intProgramId
				AND item.intItemId = programItem.intItemId
				AND invoice.dtmDate >= programItem.dtmBeginDate
				AND invoice.dtmDate <= ISNULL(programItem.dtmEndDate, '12/31/9999')
				AND (ISNULL(programItem.dblRebateRate, 0) <> 0)
		LEFT OUTER JOIN tblVRProgramItem programCategory ON programCategory.intProgramId = programItem.intProgramId
			AND programCategory.intCategoryId = item.intCategoryId
			AND invoice.dtmDate >= programCategory.dtmBeginDate
			AND invoice.dtmDate <= ISNULL(programCategory.dtmEndDate, '12/31/9999')
			AND ISNULL(programCategory.dblRebateRate, 0) <> 0
		LEFT OUTER JOIN tblICItemUOM uom ON uom.intItemId = invoiceDetail.intItemId
			AND uom.intUnitMeasureId = programItem.intUnitMeasureId
		LEFT OUTER JOIN tblICUnitMeasure unitMeasure ON unitMeasure.intUnitMeasureId = uom.intUnitMeasureId
		LEFT OUTER JOIN tblAPVendor vendor ON vendor.intEntityId = vendorSetup.intEntityId
		LEFT OUTER JOIN tblEMEntity entity ON entity.intEntityId = vendor.intEntityId
		LEFT OUTER JOIN tblSMCompanyLocation companyLocation ON companyLocation.intCompanyLocationId = invoice.intCompanyLocationId
	WHERE  NOT EXISTS(SELECT TOP 1 1 FROM tblVRRebate WHERE intInvoiceDetailId = invoiceDetail.intInvoiceDetailId)
		AND invoice.ysnPosted = 1
		AND invoice.strTransactionType IN ('Invoice', 'Credit Memo')
) openRebates
WHERE openRebates.strProgram IS NOT NULL
	AND openRebates.dblRebateRate <> 0


	