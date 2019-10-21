CREATE VIEW [dbo].[vyuARAddOnItemsInvoiceReport]
AS 
SELECT intInvoiceId				= ID.intInvoiceId
	 , intInvoiceDetailId		= ID.intInvoiceDetailId
	 , intCommentTypeId			= ID.intCommentTypeId
	 , dblTotalTax				= ID.dblTotalTax
	 , dblContractBalance		= CONTRACTS.dblBalance
	 , dblQtyShipped			= ID.dblQtyShipped
	 , dblQtyOrdered			= ID.dblQtyOrdered
	 , dblDiscount				= ID.dblDiscount
	 , dblPrice					= ID.dblPrice
	 , dblTotal					= ID.dblTotal
	 , strVFDDocumentNumber		= ID.strVFDDocumentNumber
	 , strSCInvoiceNumber		= ID.strSCInvoiceNumber
	 , strUnitMeasure			= UOM.strUnitMeasure
	 , dblBalance				= CONTRACTS.dblBalance
	 , strContractNumber		= CONTRACTS.strContractNumber
	 , dblTax					= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblTotalTax, 0) * -1 ELSE ISNULL(ID.dblTotalTax, 0) END
									ELSE NULL 
								  END
	 , intTaxCodeId				= TAX.intTaxCodeId
	 , dblAdjustedTax			= TAX.dblAdjustedTax
	 , strTaxCode				= TAX.strTaxCode
	 , strItem					= CASE WHEN ISNULL(ITEM.strItemNo, '') = '' THEN ISNULL(ID.strItemDescription, ID.strSCInvoiceNumber) ELSE LTRIM(RTRIM(ITEM.strItemNo)) + '-' + ISNULL(ID.strItemDescription, '') END
	 , strItemNo				= ITEM.strItemNo
	 , strInvoiceComments		= ITEM.strInvoiceComments
	 , strItemType				= ITEM.strType
	 , strItemDescription		= CASE WHEN ISNULL(ID.strItemDescription, '') <> '' THEN ID.strItemDescription ELSE ITEM.strDescription END
	 , dblItemPrice				= CASE WHEN ISNULL(ID.intCommentTypeId, 0) = 0 THEN
									CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment') THEN ISNULL(ID.dblTotal, 0) * -1 ELSE ISNULL(ID.dblTotal, 0) END
									ELSE NULL 
								  END
	 , strBOLNumber				= SO.strBOLNumber
	 , ysnListBundleSeparately	= ITEM.ysnListBundleSeparately
	 , intRecipeId				= RECIPE.intRecipeId
	 , intOneLinePrintId		= RECIPE.intOneLinePrintId
	 , intSiteID				= [SITE].intSiteID
	 , strSiteNumber			= [SITE].strSiteNumber
	 , dblEstimatedPercentLeft	= [SITE].dblEstimatedPercentLeft
	 , dblPercentFull			= ID.dblPercentFull
	 , strAddonDetailKey		= ID.strAddonDetailKey
	 , ysnAddonParent			= ID.ysnAddonParent
FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId
		 , strTransactionType 
	FROM tblARInvoice WITH (NOLOCK)
) INV ON ID.intInvoiceId = INV.intInvoiceId
LEFT JOIN (
	SELECT intItemId
		 , strItemNo
		 , strDescription
		 , strInvoiceComments
		 , strType
		 , ysnListBundleSeparately
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ID.intItemId = ITEM.intItemId
LEFT JOIN (
	SELECT intItemUOMId
		 , intItemId
		 , strUnitMeasure
	FROM dbo. vyuARItemUOM WITH (NOLOCK)
) UOM ON ID.intItemUOMId = UOM.intItemUOMId
	 AND ID.intItemId = UOM.intItemId
LEFT JOIN (
	SELECT intSalesOrderDetailId
			, intSalesOrderId
	FROM dbo.tblSOSalesOrderDetail WITH (NOLOCK)
) SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
LEFT JOIN (
	SELECT intSalesOrderId
		 , strBOLNumber
	FROM dbo.tblSOSalesOrder WITH (NOLOCK)
) SO ON SOD.intSalesOrderId = SO.intSalesOrderId
LEFT JOIN (
	SELECT IDT.intInvoiceDetailId
		 , IDT.intTaxCodeId
		 , IDT.dblAdjustedTax
		 , TAXCODE.strTaxCode
	FROM dbo.tblARInvoiceDetailTax IDT WITH (NOLOCK)
	LEFT JOIN (
		SELECT intTaxCodeId
			 , strTaxCode
		FROM dbo.tblSMTaxCode WITH (NOLOCK)
	) TAXCODE ON IDT.intTaxCodeId = TAXCODE.intTaxCodeId
	WHERE dblAdjustedTax <> 0
) TAX ON ID.intInvoiceDetailId = TAX.intInvoiceDetailId
	 AND ID.intItemId <> ISNULL((SELECT TOP 1 intItemForFreightId FROM dbo.tblTRCompanyPreference WITH (NOLOCK)), 0)
LEFT JOIN (
	SELECT CH.intContractHeaderId
		 , CD.intContractDetailId
		 , CD.dblBalance
		 , strContractNumber
	FROM dbo.tblCTContractHeader CH WITH (NOLOCK)
	LEFT JOIN (
		SELECT intContractHeaderId
			 , intContractDetailId
			 , dblBalance
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
	) CD ON CH.intContractHeaderId = CD.intContractHeaderId
) CONTRACTS ON ID.intContractDetailId = CONTRACTS.intContractDetailId
LEFT JOIN (
	SELECT intRecipeId
		 , intOneLinePrintId
	FROM dbo.tblMFRecipe WITH (NOLOCK)
) RECIPE ON ID.intRecipeId = RECIPE.intRecipeId	
LEFT JOIN (
	SELECT intSiteID
		 , strSiteNumber = (CASE WHEN intSiteNumber < 9 THEN '00' + CONVERT(VARCHAR,intSiteNumber) ELSE '0' + CONVERT(VARCHAR,intSiteNumber) END ) + ' - ' + strDescription
		 , dblEstimatedPercentLeft 
	FROM tblTMSite
) [SITE] ON [SITE].intSiteID = ID.intSiteId
WHERE(ID.ysnAddonParent = 0)
