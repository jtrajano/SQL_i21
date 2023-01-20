CREATE VIEW dbo.vyuARZugInvoiceDetailView
AS
SELECT 'Type'					= I.strType
	 , 'Transaction Type'		= I.strTransactionType
	 , 'Invoice Number'			= I.strInvoiceNumber
	 , 'PO Number'				= I.strPONumber
	 , 'Base Date'				= I.dtmDate
	 , 'Accounting Period'		= FYP.strPeriod
	 , 'Contract Number'		= CH.strContractNumber
	 , 'Contract Sequnce No.'	= CD.intContractSeq
	 , 'Location'				= CL.strLocationName
	 , 'Customer No.'			= C.strCustomerNumber
	 , 'Customer Name'			= E.strName
	 , 'Item Description'		= ISNULL(ITEM.strDescription, ID.strItemDescription)
	 , 'Quantity Shipped'		= CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(ID.dblQtyShipped, 0) ELSE ISNULL(ID.dblQtyShipped, 0) * -1 END
	 , 'Net Weight Shipped'		= CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(ID.dblShipmentNetWt, 0) ELSE ISNULL(ID.dblShipmentNetWt, 0) * -1 END
	 , 'Unit Cost'				= CASE WHEN CH.intContractHeaderId IS NOT NULL AND ISNUlL(ID.dblUnitPrice, 0) <> 0 THEN ISNUlL(ID.dblUnitPrice, 0) ELSE ISNULL(ID.dblPrice, 0) END
	 , 'Cost Per UOM'			= ISNULL(ID.dblPrice, 0)
	 , 'Unit Cost Currency'		= ISNULL(ID.dblPrice, 0)
	 , 'Tax'					= CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(ID.dblTotalTax, 0) ELSE ISNULL(ID.dblTotalTax, 0) * -1 END
	 , 'Discount'				= CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(ID.dblDiscount, 0) ELSE ISNULL(ID.dblDiscount, 0) * -1 END
	 , 'Invoice Line Amount'	= CASE WHEN I.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice') THEN ISNULL(ID.dblTotal, 0) ELSE ISNULL(ID.dblTotal, 0) * -1 END
	 , 'Comments'				= I.strComments
	 , 'Impact Inventory'		= ISNULL(I.ysnImpactInventory, 0)
	 , 'Invoice Id'				= I.intInvoiceId
FROM tblARInvoice I
INNER JOIN tblSMCompanyLocation CL ON I.intCompanyLocationId = CL.intCompanyLocationId
INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityId
INNER JOIN tblEMEntity E ON C.intEntityId = E.intEntityId
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
LEFT JOIN tblICItem ITEM ON ID.intItemId = ITEM.intItemId
LEFT JOIN tblGLFiscalYearPeriod FYP ON I.intPeriodId = FYP.intGLFiscalYearPeriodId
LEFT JOIN tblCTContractDetail CD ON ID.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId