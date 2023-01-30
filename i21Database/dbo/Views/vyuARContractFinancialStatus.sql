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
	 , strStatus				= CASE WHEN ISNULL(CTD.dblBalance, 0) = 0 OR I.strType = 'Provisional' 
									   THEN 
											CASE WHEN I.strType <> 'Provisional' AND I.ysnFinalized = 0 
												 THEN 'Direct Invoiced' 
												 ELSE 
													CASE WHEN I.ysnFinalized = 0 
														 THEN 'Provisionally Invoiced' 
														 ELSE 'Final Invoiced' 
													END 
									   END
								  ELSE 
									CASE WHEN I.ysnFinalized = 1 
										 THEN 'Final Invoiced'
										 ELSE NULL
									END
								  END COLLATE Latin1_General_CI_AS 
FROM (
	SELECT intInvoiceId				= I.intInvoiceId
		 , intFinalInvoiceId		= NULL
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , strFinalInvoiceNumber	= NULL
		 , strType					= I.strType
		 , ysnFinalized				= CAST(0 AS BIT)
	FROM tblARInvoice I
	WHERE I.strType = 'Provisional'
	  AND (I.ysnProcessed = 1 OR I.ysnPosted = 1)

	UNION ALL

	SELECT intInvoiceId				= I.intInvoiceId
		 , intFinalInvoiceId		= NULL
		 , strInvoiceNumber			= I.strInvoiceNumber
		 , strFinalInvoiceNumber	= NULL
		 , strType					= I.strType
		 , ysnFinalized				= ISNULL(I.ysnFromProvisional, 0)
	FROM tblARInvoice I
	WHERE I.strType <> 'Provisional'
	  AND I.ysnPosted = 1
) I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblCTContractDetail CTD ON ID.intContractDetailId = CTD.intContractDetailId
INNER JOIN tblCTContractHeader CHD ON CTD.intContractHeaderId = CHD.intContractHeaderId
WHERE ID.intContractDetailId IS NOT NULL