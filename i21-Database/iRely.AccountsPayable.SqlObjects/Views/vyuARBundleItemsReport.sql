CREATE VIEW [dbo].[vyuARBundleItemsReport]
AS
SELECT intTransactionId		= TRANSACTIONS.intTransactionId
	 , intCompanyLocationId = TRANSACTIONS.intCompanyLocationId
	 , intItemId			= TRANSACTIONS.intItemId
	 , intBundleItemId		= COMPONENTS.intComponentItemId     
	 , strTransactionType	= TRANSACTIONS.strTransactionType
     , strItemNo			= COMPONENTS.strItemNo
     , strItemDescription	= COMPONENTS.strItemNo + ' - ' + COMPONENTS.strDescription
     , strUnitMeasure		= COMPONENTS.strUnitMeasure
     , dblQuantity			= COMPONENTS.dblQuantity * TRANSACTIONS.dblQuantity
     , dblPrice				= COMPONENTS.dblPrice
	 , dblTotal				= COMPONENTS.dblPrice * TRANSACTIONS.dblQuantity * COMPONENTS.dblQuantity
FROM (
	SELECT intTransactionId		= SOD.intSalesOrderDetailId
		 , intCompanyLocationId = SO.intCompanyLocationId
		 , strTransactionType	= 'Sales Order'
		 , intItemId			= SOD.intItemId
		 , dblQuantity			= SOD.dblQtyOrdered
	FROM dbo.tblSOSalesOrderDetail SOD WITH (NOLOCK)
	INNER JOIN (
		SELECT intSalesOrderId
			 , intCompanyLocationId
		FROM dbo.tblSOSalesOrder WITH (NOLOCK)
	) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
	WHERE ISNULL(SOD.intItemId, 0) <> 0

	UNION ALL
 
	SELECT intTransactionId		= ID.intInvoiceDetailId
	     , intCompanyLocationId = I.intCompanyLocationId
		 , strTransactionType	= 'Invoice'
		 , intItemId			= ID.intItemId
		 , dblQuantity			= ID.dblQtyShipped
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	INNER JOIN (
		SELECT intInvoiceId
			 , intCompanyLocationId
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) I ON ID.intInvoiceId = I.intInvoiceId
	WHERE ISNULL(ID.intItemId, 0) <> 0
) TRANSACTIONS
INNER JOIN (
	SELECT intItemId
	FROM dbo.tblICItem WITH (NOLOCK)
	WHERE strType = 'Bundle'
	  AND ysnListBundleSeparately = 1
) ITEM ON TRANSACTIONS.intItemId = ITEM.intItemId
INNER JOIN (
	SELECT intItemId
		 , intComponentItemId
		 , intCompanyLocationId
		 , strItemNo 
		 , strDescription
		 , strUnitMeasure
		 , dblPrice
		 , dblQuantity
	FROM dbo.vyuARGetItemComponents WITH (NOLOCK)
	WHERE strType = 'Bundle'
) COMPONENTS ON TRANSACTIONS.intItemId = COMPONENTS.intItemId
			AND TRANSACTIONS.intCompanyLocationId = COMPONENTS.intCompanyLocationId