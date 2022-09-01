

Create VIEW [dbo].vyuCTPrepaidHistory

AS

SELECT ID.intInvoiceDetailId
	 , I.intInvoiceId
	 , CH.intItemContractHeaderId
	 , I.strInvoiceNumber 
FROM tblCTItemContractHeader CH
INNER JOIN tblCTItemContractDetail CD on CH.intItemContractHeaderId = CD.intItemContractHeaderId
INNER JOIN tblARInvoiceDetail ID on ID.intItemContractHeaderId = CD.intItemContractHeaderId AND ID.intItemContractDetailId = CD.intItemContractDetailId
INNER JOIN tblARInvoice I on I.intInvoiceId = ID.intInvoiceId




GO

