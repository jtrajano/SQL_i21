CREATE VIEW [dbo].[vyuARContractFinancialStatus]
AS
SELECT intInvoiceId				= I.intInvoiceId
	 , intInvoiceDetailId		= ID.intInvoiceDetailId
	 , intContractDetailId		= ID.intContractDetailId
	 , intContractHeaderId		= CTD.intContractHeaderId
	 , intFinalInvoiceId		= I.intInvoiceId
	 , strInvoiceNumber			= I.strInvoiceNumber
	 , strFinalInvoiceNumber	= I.strInvoiceNumber
	 , strContractNumber		= CHD.strContractNumber
	 , intContractSeq			= CTD.intContractSeq
	 , strStatus				= CASE WHEN I.strType <> 'Provisional' THEN 'Direct Invoiced' ELSE CASE WHEN ISNULL(I.ysnFinalized, 0) = 0 THEN 'Provisionally Invoiced' ELSE 'Final Invoiced' END END 
FROM (
	SELECT intInvoiceId				= I.intInvoiceId
		 , intFinalInvoiceId		= FI.intInvoiceId
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , strFinalInvoiceNumber	= FI.strInvoiceNumber
		 , strType					= I.strType
		 , ysnFinalized				= CASE WHEN ISNULL(FI.intInvoiceId, 0) = 0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	FROM tblARInvoice I
	LEFT JOIN tblARInvoice FI ON I.intInvoiceId = FI.intOriginalInvoiceId
							 AND I.strInvoiceNumber = FI.strInvoiceOriginId
							 AND FI.strTransactionType IN ('Invoice', 'Credit Memo')
							 AND FI.ysnPosted = 1
							 AND FI.ysnFromProvisional = 1
	WHERE I.strType = 'Provisional'
	  AND I.ysnPosted = 1

	UNION ALL

	SELECT intInvoiceId				= I.intInvoiceId
		 , intFinalInvoiceId		= NULL
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , strFinalInvoiceNumber	= NULL
		 , strType					= I.strType
		 , ysnFinalized				= CAST(0 AS BIT)
	FROM tblARInvoice I
	WHERE I.strType <> 'Provisional'
	  AND I.ysnPosted = 1
	  AND I.ysnFromProvisional = 0
) I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
INNER JOIN tblCTContractHeader CHD ON CTD.intContractHeaderId = CHD.intContractHeaderId