  
  
Create VIEW [dbo].[vyuCTPrepaidHistory]  
  
AS  
  
SELECT intInvoiceDetailId    =   ID.intInvoiceDetailId  
  , intInvoiceId      =   I.intInvoiceId  
  , intItemContractHeaderId   =   ICH.intItemContractHeaderId  
  , strInvoiceNumber     =   I.strInvoiceNumber   
  
  , strContractNumber    =   ICH.strContractNumber   
  , strItemNumber     =   ID.strItemDescription  
  , strPrepayType     =   CASE WHEN ID.intPrepayTypeId = 1 THEN 'Standard'   
              WHEN ID.intPrepayTypeId = 2 THEN 'Unit'   
              WHEN ID.intPrepayTypeId = 3 THEN 'Percentage'   
              ELSE ''  
             END COLLATE Latin1_General_CI_AS  
  , dblQuantity      =   ID.dblQtyShipped  
  , strUnitMeasure     =   IOUM.strUnitMeasure  
  , strCurrencyUnit     =   CUR.strCurrency  
  , dblPrice       =   ID.dblPrice  
  , dblSubTotal      =   CASE WHEN I.strTransactionType = 'Customer Prepayment' THEN 0   
             ELSE  I.dblInvoiceSubtotal END  
  , dblTax       =   I.dblTax  
  , dblTotalAmount     =   ID.dblTotal  
  , dblAmountReceived    =   CASE WHEN strTransactionType = 'Customer Prepayment' AND ysnPosted = 1 and ysnPaid = 0 THEN dblAmountDue   
               WHEN strTransactionType = 'Customer Prepayment' AND ysnPosted = 1 and ysnPaid = 1 THEN 0  
               WHEN strTransactionType = 'Customer Prepayment' AND  ysnPosted = 0 THEN 0  
             ELSE dblPayment END  
  , dblAmountDue      =   CASE WHEN strTransactionType = 'Customer Prepayment' AND ysnPosted = 1 and ysnPaid = 0 THEN dblAmountDue * -1.0  
               WHEN strTransactionType = 'Customer Prepayment' AND (ysnRefundProcessed = 1 or ysnPaid = 0)  THEN 0  
             ELSE dblAmountDue END  
FROM tblCTItemContractHeader ICH  
INNER JOIN (

	select intItemContractDetailId, intItemContractHeaderId, 'Item' strContractCategoryId from tblCTItemContractDetail
	UNION ALL
	SELECT intItemCategoryId, intItemContractHeaderId, 'Dollar' strContractCategoryId FROM tblCTItemContractHeaderCategory

) ICD  on ICH.intItemContractHeaderId = ICD.intItemContractHeaderId  and ICH.strContractCategoryId = ICD.strContractCategoryId
INNER JOIN tblARInvoiceDetail ID on ID.intItemContractHeaderId = ICD.intItemContractHeaderId AND CASE WHEN ICD.strContractCategoryId = 'Item' THEN ID.intItemContractDetailId ELSE ID.intItemCategoryId END = ICD.intItemContractDetailId  
INNER JOIN tblARInvoice I on I.intInvoiceId = ID.intInvoiceId  
LEFT JOIN tblCTContractHeader CH on CH.intContractHeaderId = ID.intContractHeaderId  
LEFT JOIN vyuARItemUOM IOUM ON IOUM.intItemUOMId = ID.intItemUOMId  
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = ID.intSubCurrencyId 

Go