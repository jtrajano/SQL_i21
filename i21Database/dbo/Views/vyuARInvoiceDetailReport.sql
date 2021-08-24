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
	 , strUnitMeasure 			= ID.[strUnitMeasure]
	 , dblItemWeight			= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblShipmentNetWt, 0) ELSE ISNULL(ID.dblShipmentNetWt, 0) * -1 END
	 , dblUnitCost				= CASE WHEN CT.intContractHeaderId IS NOT NULL AND ISNUlL(ID.dblUnitPrice, 0) <> 0 THEN ISNUlL(ID.dblUnitPrice, 0) ELSE ISNULL( ID.dblPrice, 0) END
	 , dblCostPerUOM			= ISNULL(ID.dblPrice, 0)
	 , dblUnitCostCurrency		= ISNULL(ID.dblPrice, 0)
	 , dblTotalTax				= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblTotalTax, 0) ELSE ISNULL(ID.dblTotalTax, 0) * -1 END
	 , dblDiscount				= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblDiscount, 0) ELSE ISNULL(ID.dblDiscount, 0) * -1 END
	 , dblTotal					= CASE WHEN (I.strTransactionType  IN ('Invoice', 'Debit Memo', 'Cash', 'Proforma Invoice')) THEN ISNULL(ID.dblTotal, 0) ELSE ISNULL(ID.dblTotal, 0) * -1 END
	 , ysnPosted				= ISNULL(I.ysnPosted, 0)
	 , ysnImpactInventory		= ISNULL(I.ysnImpactInventory, 0)
	 , strAccountingPeriod      = AccPeriod.strAccountingPeriod
	 , intDaysOld				= DATEDIFF(DAYOFYEAR, I.dtmDate, CAST(GETDATE() AS DATE))
	 , intDaysToPay				= CASE WHEN I.ysnPaid = 0 OR I.strTransactionType IN ('Cash') THEN 0 
								   	   ELSE DATEDIFF(DAYOFYEAR, I.dtmDate, CAST(FULLPAY.dtmDatePaid AS DATE))
							  	  END
	 , intItemId				= ITEM.intItemId
	 , strCategoryName			= CATEGORY.strCategoryCode
	 , intCategoryId			= CATEGORY.intCategoryId
	 , strSalespersonName		= ESP.strName
	 , strShipToState			= RTRIM(strShipToState)
	 , intEntitySalespersonId	= I.intEntitySalespersonId
	 , strAccountStatusCode 	= STATUSCODES.strAccountStatusCode
	 , intBillToLocationId		= I.intBillToLocationId
	 , intShipToLocationId		= I.intShipToLocationId
	 , strBinNumber				= ID.strBinNumber
	 , strGroupNumber			= ID.strGroupNumber
	 , strFeedDiet				= ID.strFeedDiet
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN (
	SELECT intInvoiceId
		 , intInvoiceDetailId
		 , intContractHeaderId
		 , intContractDetailId
		 , ID.intItemId
		 , dblQtyShipped
		 , dblItemWeight
		 , dblPrice
		 , dblUnitPrice
		 , dblTotalTax
		 , dblDiscount
		 , dblTotal
		 , strUnitCostCurrency = SC.strCurrency
		 , ID.intItemUOMId
		 , strUnitMeasure
		 , strBinNumber
		 , strGroupNumber
		 , strFeedDiet
		 , dblShipmentNetWt
		 , intEntitySalespersonId
	FROM dbo.tblARInvoiceDetail ID WITH (NOLOCK)
	LEFT JOIN (
		SELECT intCurrencyID
		     , strCurrency
		FROM dbo.tblSMCurrency
	) SC ON ID.intSubCurrencyId = SC.intCurrencyID
	LEFT JOIN (
		SELECT intItemUOMId
				, intItemId
				, IU.intUnitMeasureId
				, IU.strUpcCode
				,strUnitMeasure
		FROM dbo.tblICItemUOM IU WITH (NOLOCK)
		INNER JOIN (
			SELECT intUnitMeasureId
					, strUnitMeasure
			FROM dbo.tblICUnitMeasure WITH (NOLOCK)
		) UM ON IU.intUnitMeasureId = UM.intUnitMeasureId
	) U ON ID.intItemId = U.intItemId 
	   AND U.intItemUOMId = ID.intItemUOMId
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
LEFT JOIN (
	SELECT intItemId
		 , intCategoryId
		 , strItemNo
		 , strDescription
	FROM dbo.tblICItem WITH (NOLOCK)
) ITEM ON ID.intItemId = ITEM.intItemId

LEFT JOIN (
	SELECT intCategoryId
		 , strCategoryCode
	FROM dbo.tblICCategory WITH (NOLOCK)
) CATEGORY ON ITEM.intCategoryId = CATEGORY.intCategoryId
LEFT JOIN (
	tblARSalesperson SP 
	INNER JOIN tblEMEntity ESP ON SP.[intEntityId] = ESP.intEntityId
) ON I.intEntitySalespersonId = SP.[intEntityId]
OUTER APPLY (
	 SELECT strAccountStatusCode = LEFT(strAccountStatusCode, LEN(strAccountStatusCode) - 1) COLLATE Latin1_General_CI_AS
	 FROM (
	  SELECT CAST(ARAS.strAccountStatusCode AS VARCHAR(200))  + ', '
	  FROM dbo.tblARCustomerAccountStatus CAS WITH(NOLOCK)
	  INNER JOIN (
	   SELECT intAccountStatusId
		 , strAccountStatusCode
	   FROM dbo.tblARAccountStatus WITH (NOLOCK)
	  ) ARAS ON CAS.intAccountStatusId = ARAS.intAccountStatusId
	  WHERE CAS.intEntityCustomerId = I.intEntityCustomerId
	  FOR XML PATH ('')
	 ) SC (strAccountStatusCode)
) STATUSCODES
LEFT JOIN (
	SELECT CTH.intContractHeaderId
		 , CTH.strContractNumber
		 , CTD.intContractDetailId
		 , CTD.intContractSeq
	FROM dbo.tblCTContractHeader CTH WITH (NOLOCK)
	INNER JOIN (
		SELECT intContractHeaderId
			 , intContractDetailId
			 , intContractSeq
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
	) CTD ON CTH.intContractHeaderId = CTD.intContractHeaderId
) CT ON ID.intContractDetailId = CT.intContractDetailId
LEFT JOIN (
	SELECT intGLFiscalYearPeriodId
		 , strAccountingPeriod = P.strPeriod
	FROM tblGLFiscalYearPeriod P	
) AccPeriod ON I.intPeriodId = AccPeriod.intGLFiscalYearPeriodId
INNER JOIN (
	SELECT intCompanyLocationId
		 , strLocationName 
	FROM tblSMCompanyLocation WITH (NOLOCK)
) L ON I.intCompanyLocationId = L.intCompanyLocationId
OUTER APPLY (
	SELECT TOP 1 P.dtmDatePaid
	FROM tblARPaymentDetail PD
	INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId
	WHERE PD.intInvoiceId = I.intInvoiceId
	  AND P.ysnPosted = 1
	  AND P.ysnInvoicePrepayment = 0
	ORDER BY P.dtmDatePaid DESC
) FULLPAY