CREATE VIEW [dbo].[vyuARContractFinancialStatus]
AS
SELECT intInvoiceId				= I.intInvoiceId
	 , intInvoiceDetailId		= ID.intInvoiceDetailId
	 , intContractDetailId		= ID.intContractDetailId
	 , intContractHeaderId		= CTD.intContractHeaderId
	 , intFinalInvoiceId		= FI.intInvoiceId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strFinalInvoiceNumber	= FI.strInvoiceNumber
	 , strContractNumber		= CHD.strContractNumber
	 , intContractSeq			= CTD.intContractSeq
	 , strStatus				= CASE WHEN I.strType <> 'Provisional' THEN 'Direct Invoiced' ELSE CASE WHEN ISNULL(FI.intInvoiceId, 0) = 0 THEN 'Provisionally Invoiced' ELSE 'Final Invoiced' END END
FROM tblARInvoiceDetail ID
INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
INNER JOIN tblCTContractHeader CHD ON CTD.intContractHeaderId = CHD.intContractHeaderId
OUTER APPLY (
	SELECT TOP 1 FI.intInvoiceId
			   , FI.strInvoiceNumber
	FROM tblARInvoice FI
	WHERE FI.ysnPosted = 1
	  AND FI.strInvoiceOriginId = I.strInvoiceNumber
	  AND FI.intOriginalInvoiceId = I.intInvoiceId
	  AND I.strType = 'Provisional'
) FI
WHERE I.ysnPosted = 1