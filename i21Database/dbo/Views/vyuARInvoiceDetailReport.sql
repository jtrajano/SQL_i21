CREATE VIEW [dbo].[vyuARInvoiceDetailReport]
AS
SELECT intInvoiceId				= I.intInvoiceId
	 , intEntityCustomerId		= I.intEntityCustomerId
	 , intCompanyLocationId		= I.intCompanyLocationId
	 , strLocationName			= L.strLocationName
	 , strTransactionType		= I.strTransactionType
	 , strType					= CASE WHEN ISNULL(I.intOriginalInvoiceId, 0) <> 0 THEN 'Final'
									   WHEN I.strType = 'Provisional' THEN 'Provisional'
									   ELSE 'Direct' 
								  END COLLATE Latin1_General_CI_AS
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strPONumber				= I.strPONumber
	 , dtmDate					= I.dtmDate
	 , strContractNumber		= CT.strContractNumber
	 , intContractSeq			= CT.intContractSeq
	 , strCustomerName			= C.strName
	 , strCustomerNumber		= C.strCustomerNumber	
	 , strItemNo 				= ITEM.strItemNo 
	 , strUnitCostCurrency		= ID.strUnitCostCurrency
	 , strItemDescription		= ITEM.strDescription
	 , strComments				= I.strComments
	 , dblQtyShipped			= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblQtyShipped, 0) ELSE ISNULL(ID.dblQtyShipped, 0) * -1 END
	 , dblItemWeight			= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblItemWeight, 0) ELSE ISNULL(ID.dblItemWeight, 0) * -1 END
	 , dblUnitCost				= CASE WHEN CT.intContractHeaderId IS NOT NULL THEN ISNUlL(ID.dblUnitPrice,0) ELSE ISNULL( ID.dblPrice,0) END
	 , dblCostPerUOM			= ISNULL(ID.dblPrice, 0)
	 , dblUnitCostCurrency		= ISNULL(ID.dblPrice, 0)
	 , dblTotalTax				= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblTotalTax, 0) ELSE ISNULL(ID.dblTotalTax, 0) * -1 END
	 , dblDiscount				= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblDiscount, 0) ELSE ISNULL(ID.dblDiscount, 0) * -1 END
	 , dblTotal					= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblTotal, 0) ELSE ISNULL(ID.dblTotal, 0) * -1 END
	 , ysnPosted				= ISNULL(I.ysnPosted, 0)
	 , ysnImpactInventory		= ISNULL(I.ysnImpactInventory, 0)
	 , dtmAccountingPeriod      = CASE WHEN ISNULL(I.ysnPosted, 0) = 1 
								  THEN DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, I.dtmPostDate) + 1, 0))
								  ELSE NULL END

FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId
		 , intInvoiceDetailId
		 , intContractHeaderId
		 , intContractDetailId
		 , intItemId
		 , dblQtyShipped
		 , dblItemWeight
		 , dblPrice
		 , dblUnitPrice
		 , dblTotalTax
		 , dblDiscount
		 , dblTotal
		 , strUnitCostCurrency = SC.strCurrency
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intCurrencyID
		     , strCurrency
		FROM dbo.tblSMCurrency
	) SC ON ID.intSubCurrencyId = SC.intCurrencyID
) ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN (
	SELECT EME.intEntityId
		 , EME.strName
		 , ARC.strCustomerNumber
	FROM dbo.tblEMEntity EME WITH (NOLOCK)  
	LEFT JOIN (
		SELECT intEntityId
			 , strCustomerNumber
		FROM tblARCustomer WITH (NOLOCK)
	) ARC ON EME.intEntityId = ARC.intEntityId
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
				, CTD.dblCashPrice
		   FROM 
			dbo.tblCTContractHeader CTH WITH (NOLOCK)
		   INNER JOIN (SELECT intContractHeaderId
							, intContractDetailId
							, intContractSeq
							, dblCashPrice
					   FROM 
						dbo.tblCTContractDetail WITH (NOLOCK)
					 ) CTD ON CTH.intContractHeaderId = CTD.intContractHeaderId
			) CT ON ID.intContractHeaderId = CT.intContractHeaderId
				AND ID.intContractDetailId = CT.intContractDetailId
LEFT OUTER JOIN(
	SELECT intCompanyLocationId, strLocationName FROM tblSMCompanyLocation WITH (NOLOCK)
) L ON I.intCompanyLocationId = L.intCompanyLocationId