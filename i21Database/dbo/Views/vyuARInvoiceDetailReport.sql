CREATE VIEW [dbo].[vyuARInvoiceDetailReport]
AS
SELECT I.intInvoiceId
	 , I.intEntityCustomerId
	 , I.intCompanyLocationId
	 , strLocationName = L.strLocationName
	 , strType				= CASE WHEN ISNULL(I.intOriginalInvoiceId, 0) <> 0 THEN 'Final'
								   WHEN I.strType = 'Provisional' THEN 'Provisional'
								   ELSE 'Direct' 
							  END
	 , I.strInvoiceNumber
	 , I.dtmDate
	 , CT.strContractNumber
	 , CT.intContractSeq
	 , strCustomerName		= C.strName
	 , strCustomerNumber	= C.strCustomerNumber	
	 , strItemNo = ITEM.strItemNo 
	 , strItemDescription	= ITEM.strDescription
	 , dblQtyShipped		= ISNULL(ID.dblQtyShipped, 0)
	 , dblItemWeight		= ISNULL(ID.dblItemWeight, 0)
	 , dblUnitCost			= ISNULL(ID.dblPrice, 0)
	 , dblCostPerUOM		= ISNULL(ID.dblPrice, 0)
	 , dblUnitCostCurrency  = ISNULL(ID.dblPrice, 0)
	 , dblTotalTax			= ISNULL(ID.dblTotalTax, 0)
	 , dblDiscount			= ISNULL(ID.dblDiscount, 0)
	 , dblTotal				= ISNULL(ID.dblTotal, 0)
	 , ysnPosted			= I.ysnPosted
FROM 
	dbo.tblARInvoice I WITH (NOLOCK)
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
			FROM 
				dbo.tblARInvoiceDetail WITH (NOLOCK)
			) ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN (SELECT EME.intEntityId
				 , EME.strName
				 , ARC.strCustomerNumber
			FROM dbo.tblEMEntity EME WITH (NOLOCK)  
			LEFT JOIN (SELECT intEntityId
							, strCustomerNumber
						 FROM 
							tblARCustomer WITH (NOLOCK)) ARC ON EME.intEntityId = ARC.intEntityId
			) C ON I.intEntityCustomerId = C.intEntityId
LEFT JOIN (SELECT intItemId
				, strItemNo
				, strDescription
		   FROM 
			dbo.tblICItem WITH (NOLOCK)
			) ITEM ON ID.intItemId = ITEM.intItemId
LEFT JOIN (SELECT CTH.intContractHeaderId
				, CTH.strContractNumber
				, CTD.intContractDetailId
				, CTD.intContractSeq
		   FROM 
			dbo.tblCTContractHeader CTH WITH (NOLOCK)
		   INNER JOIN (SELECT intContractHeaderId
							, intContractDetailId
							, intContractSeq
					   FROM 
						dbo.tblCTContractDetail WITH (NOLOCK)
					 ) CTD ON CTH.intContractHeaderId = CTD.intContractHeaderId
			) CT ON ID.intContractHeaderId = CT.intContractHeaderId
				AND ID.intContractDetailId = CT.intContractDetailId
LEFT OUTER JOIN(
	SELECT intCompanyLocationId, strLocationName FROM tblSMCompanyLocation WITH (NOLOCK)
) L ON I.intCompanyLocationId = L.intCompanyLocationId