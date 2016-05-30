CREATE VIEW [dbo].[vyuARPrepaidAndCredit]
AS

SELECT
	 [intInvoiceId]						= NULL
	,[intInvoiceDetailId]				= NULL
	,[intPrepaymentId]					= ARI.[intInvoiceId]
	,[intPrepaymentDetailId]			= ARID.[intInvoiceDetailId]
	,[strPrepaymentNumber]				= ARI.[strInvoiceNumber]
	,[strPrepayType]					= (	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN 'Standard'
												WHEN ARID.[intPrepayTypeId] =  2 THEN 'Unit'
												WHEN ARID.[intPrepayTypeId] =  3 THEN 'Percentage'
												ELSE ''
											END
										  )
	,[intPrepayTypeId]					= [intPrepayTypeId]
	,[ysnRestricted]					= ARID.[ysnRestricted]
	,[intContractHeaderId]				= CTCHV.[intContractHeaderId]
	,[strContractNumber]				= CTCHV.[strContractNumber]
	,[intContractDetailId]				= CTCDV.[intContractDetailId]
	,[strSequenceNumber]				= CTCDV.[strSequenceNumber]
	,[intItemId]						= ICI.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ARID.[strItemDescription]
	,[dblPrepayRate]					= ARID.[dblPrepayRate]
	,[dblLineItemTotal]					= ARID.[dblTotal]
	,[dblInvoiceTotal]					= ARI.[dblInvoiceTotal]
	,[dblPrepaidAmount]					= (	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN ARI.[dblInvoiceTotal]
												WHEN ARID.[intPrepayTypeId] =  2 THEN ARID.[dblTotal]
												WHEN ARID.[intPrepayTypeId] =  3 THEN ARID.[dblTotal] * (ISNULL(ARID.[dblPrepayRate],1.000000)/100.000000)
												ELSE 0.000000
											END
										  )
	,[dblPostedAmount]					= 0.000000
	,[dblPostedDetailAmount]			= 0.000000
	,[dblAppliedInvoiceAmount]			= 0.000000
	,[dblAppliedInvoiceDetailAmount]	= 0.000000
	,[dblInvoiceBalance]				= 0.000000
	,[dblInvoiceDetailBalance]			= 0.000000
	,[ysnApplied]						= 0
	,[ysnPosted]						= 0	
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		AND ARI.[strTransactionType] = 'Prepayment'
INNER JOIN
	tblARPayment ARP
		ON ARI.[intPaymentId] = ARP.[intPaymentId]
		AND ARP.[ysnPosted] = 1
LEFT OUTER JOIN
	vyuCTContractHeaderView CTCHV
		ON ARID.[intContractHeaderId] = CTCHV.[intContractHeaderId]
LEFT OUTER JOIN
	vyuCTContractDetailView CTCDV
		ON ARID.[intContractDetailId] = CTCDV.[intContractDetailId]
LEFT OUTER JOIN
	tblICItem ICI
		ON ARID.[intItemId] = ICI.[intItemId]
WHERE
	ISNULL(ARID.[intPrepayTypeId],0) IN (1,2,3)
	
	
UNION


SELECT
	 [intInvoiceId]						= ARPAC.[intInvoiceId]
	,[intInvoiceDetailId]				= ARPAC.[intInvoiceDetailId]
	,[intPrepaymentId]					= ARI.[intInvoiceId]
	,[intPrepaymentDetailId]			= ARID.[intInvoiceDetailId]
	,[strPrepaymentNumber]				= ARI.[strInvoiceNumber]
	,[strPrepayType]					= (	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN 'Standard'
												WHEN ARID.[intPrepayTypeId] =  2 THEN 'Unit'
												WHEN ARID.[intPrepayTypeId] =  3 THEN 'Percentage'
												ELSE ''
											END
										  )
	,[intPrepayTypeId]					= [intPrepayTypeId]
	,[ysnRestricted]					= ARID.[ysnRestricted]
	,[intContractHeaderId]				= CTCHV.[intContractHeaderId]
	,[strContractNumber]				= CTCHV.[strContractNumber]
	,[intContractDetailId]				= CTCDV.[intContractDetailId]
	,[strSequenceNumber]				= CTCDV.[strSequenceNumber]
	,[intItemId]						= ICI.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ARID.[strItemDescription]
	,[dblPrepayRate]					= ARID.[dblPrepayRate]
	,[dblLineItemTotal]					= ARID.[dblTotal]
	,[dblInvoiceTotal]					= ARI.[dblInvoiceTotal]
	,[dblPrepaidAmount]					= (	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN ARI.[dblInvoiceTotal]
												WHEN ARID.[intPrepayTypeId] =  2 THEN ARID.[dblTotal]
												WHEN ARID.[intPrepayTypeId] =  3 THEN ARID.[dblTotal] * (ISNULL(ARID.[dblPrepayRate],1.000000)/100.000000)
												ELSE 0.000000
											END
										  )
	,[dblPostedAmount]					= ARPAC.[dblPostedAmount]
	,[dblPostedDetailAmount]			= ARPAC.[dblPostedDetailAmount]
	,[dblAppliedInvoiceAmount]			= ARPAC.[dblAppliedInvoiceAmount]
	,[dblAppliedInvoiceDetailAmount]	= ARPAC.[dblAppliedInvoiceDetailAmount]
	,[dblInvoiceBalance]				= 0.000000
	,[dblInvoiceDetailBalance]			= 0.000000
	,[ysnApplied]						= ARPAC.[ysnApplied]
	,[ysnPosted]						= ARPAC.[ysnPosted]	
	
FROM
	tblARPrepaidAndCredit ARPAC
INNER JOIN
	tblARInvoiceDetail ARID
		ON ARPAC.[intPrepaymentDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		AND ARI.[strTransactionType] = 'Prepayment'
INNER JOIN
	tblARPayment ARP
		ON ARI.[intPaymentId] = ARP.[intPaymentId]
		AND ARP.[ysnPosted] = 1
LEFT OUTER JOIN
	vyuCTContractHeaderView CTCHV
		ON ARID.[intContractHeaderId] = CTCHV.[intContractHeaderId]
LEFT OUTER JOIN
	vyuCTContractDetailView CTCDV
		ON ARID.[intContractDetailId] = CTCDV.[intContractDetailId]
LEFT OUTER JOIN
	tblICItem ICI
		ON ARID.[intItemId] = ICI.[intItemId]
WHERE
	ISNULL(ARID.[intPrepayTypeId],0) IN (1,2,3)