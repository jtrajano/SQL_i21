CREATE VIEW [dbo].[vyuARInvoiceDetailReport]
AS
SELECT I.intInvoiceId
	 , I.strInvoiceNumber
	 , CT.strContractNumber
	 , CT.intContractSeq
	 , strCustomerName		= C.strName
	 , strItemDescription	= ITEM.strDescription
	 , dblQtyShipped		= ISNULL(ID.dblQtyShipped, 0)
	 , dblItemWeight		= ISNULL(ID.dblItemWeight, 0)
	 , dblUnitCost			= ISNULL(ID.dblPrice, 0)
	 , dblCostPerUOM		= ISNULL(ID.dblPrice, 0)
	 , dblUnitCostCurrency  = ISNULL(ID.dblPrice, 0)
	 , dblTotalTax			= ISNULL(ID.dblTotalTax, 0)
	 , dblDiscount			= ISNULL(ID.dblDiscount, 0)
	 , dblTotal				= ISNULL(ID.dblTotal, 0)
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (SELECT intInvoiceId
			     , intInvoiceDetailId
				 , intContractHeaderId
				 , intContractDetailId
				 , intItemId
				 , dblQtyShipped
				 , dblItemWeight
				 , dblPrice
				 , dblTotalTax
				 , dblDiscount
				 , dblTotal
			FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
) ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN (SELECT intEntityId
				 , strName
			FROM dbo.tblEMEntity WITH (NOLOCK)
) C ON I.intEntityCustomerId = C.intEntityId
LEFT JOIN (SELECT intItemId
				, strDescription
		   FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ID.intItemId = ITEM.intItemId
LEFT JOIN (SELECT CTH.intContractHeaderId
				, CTH.strContractNumber
				, CTD.intContractDetailId
				, CTD.intContractSeq
		   FROM dbo.tblCTContractHeader CTH WITH (NOLOCK)
		   INNER JOIN (SELECT intContractHeaderId
							, intContractDetailId
							, intContractSeq
					   FROM dbo.tblCTContractDetail WITH (NOLOCK)
		   ) CTD ON CTH.intContractHeaderId = CTD.intContractHeaderId
) CT ON ID.intContractHeaderId = CT.intContractHeaderId
    AND ID.intContractDetailId = CT.intContractDetailId