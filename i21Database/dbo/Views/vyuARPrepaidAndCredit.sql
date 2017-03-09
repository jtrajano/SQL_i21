CREATE VIEW [dbo].[vyuARPrepaidAndCredit]
AS

SELECT
	 [intPrepaidAndCreditId]			= NULL
	,[intInvoiceId]						= NULL
	,[intInvoiceDetailId]				= NULL
	,[intPrepaymentId]					= ARI.[intInvoiceId]
	,[intPrepaymentDetailId]			= ARID.[intInvoiceDetailId]	
	,[strPrepaymentNumber]				= ARI.[strInvoiceNumber]
	,[intEntityCustomerId]				= ARI.[intEntityCustomerId] 
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
	,[intContractSeq]					= CTCDV.[intContractSeq]
	,[intItemId]						= ICI.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ARID.[strItemDescription]
	,[dblPrepayRate]					= ARID.[dblPrepayRate]
	,[dblLineItemTotal]					= ARID.[dblTotal]
	,[dblInvoiceTotal]					= ARI.[dblInvoiceTotal]
	,[dblPrepaidAmount]					= ISNULL((	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN ARI.[dblInvoiceTotal]
														WHEN ARID.[intPrepayTypeId] =  2 THEN ARID.[dblTotal]
														WHEN ARID.[intPrepayTypeId] =  3 THEN ARID.[dblTotal] * (ISNULL(ARID.[dblPrepayRate],1.000000)/100.000000)
														ELSE 0.000000
													END
										  ), 0.000000)
	,[dblTotalPostedAmount]				= ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentId] = ARI.[intInvoiceId]
										  ), 0.000000)
	,[dblTotalPostedDetailAmount]		= ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceDetailAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentDetailId] = ARID.[intInvoiceDetailId]
										  ), 0.000000)
	,[dblAppliedInvoiceAmount]			= 0.000000
	,[dblAppliedInvoiceDetailAmount]	= 0.000000
	,[dblInvoiceBalance]				= ARI.[dblInvoiceTotal]
										  -
										  ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentId] = ARI.[intInvoiceId]
										  ), 0.000000)
	,[dblInvoiceDetailBalance]			= ARID.[dblTotal]
										  -
										  ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceDetailAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentDetailId] = ARID.[intInvoiceDetailId]
										  ), 0.000000)
	,[ysnApplied]						= NULL
	,[ysnPosted]						= NULL	
FROM
	tblARInvoiceDetail ARID
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		AND ARI.[strTransactionType] = 'Customer Prepayment'
		AND ARI.[ysnPaid] = 0
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
	 [intPrepaidAndCreditId]			= ARPAC.[intPrepaidAndCreditId]
	,[intInvoiceId]						= ARPAC.[intInvoiceId]
	,[intInvoiceDetailId]				= ARPAC.[intInvoiceDetailId]
	,[intPrepaymentId]					= ARPAC.[intPrepaymentId]
	,[intPrepaymentDetailId]			= ARPAC.[intPrepaymentDetailId]
	,[strPrepaymentNumber]				= ARI.[strInvoiceNumber]
	,[intEntityCustomerId]				= ARI.[intEntityCustomerId] 
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
	,[intContractSeq]					= CTCDV.[intContractSeq]
	,[intItemId]						= ICI.[intItemId]
	,[strItemNo]						= ICI.[strItemNo]
	,[strItemDescription]				= ARID.[strItemDescription]
	,[dblPrepayRate]					= ARID.[dblPrepayRate]
	,[dblLineItemTotal]					= ARID.[dblTotal]
	,[dblInvoiceTotal]					= ARI.[dblInvoiceTotal]
	,[dblPrepaidAmount]					= ISNULL((	CASE WHEN ARID.[intPrepayTypeId] = 1 THEN ARI.[dblInvoiceTotal]
														WHEN ARID.[intPrepayTypeId] =  2 THEN ARID.[dblTotal]
														WHEN ARID.[intPrepayTypeId] =  3 THEN ARID.[dblTotal] * (ISNULL(ARID.[dblPrepayRate],1.000000)/100.000000)
														ELSE 0.000000
													END
										  ), 0.000000)
	,[dblTotalPostedAmount]				= ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentId] = ARPAC.[intPrepaymentId]
										  ), 0.000000)
	,[dblTotalPostedDetailAmount]		= ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceDetailAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentDetailId] = ARPAC.[intPrepaymentDetailId]
										  ), 0.000000)
	,[dblAppliedInvoiceAmount]			= ARPAC.[dblAppliedInvoiceAmount]
	,[dblAppliedInvoiceDetailAmount]	= ARPAC.[dblAppliedInvoiceDetailAmount]
	,[dblInvoiceBalance]				= ARI.[dblInvoiceTotal]
										  -
										  ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentId] = ARPAC.[intPrepaymentId]
										  ), 0.000000)
	,[dblInvoiceDetailBalance]			= ARID.[dblTotal]
										  -
										  ISNULL((
												SELECT
													SUM(PAC.[dblAppliedInvoiceDetailAmount])
												FROM 
													tblARPrepaidAndCredit PAC 
												INNER JOIN
													tblARInvoice I
														ON PAC.[intInvoiceId] = I.intInvoiceId 
														AND I.ysnPosted = 1
												WHERE
													PAC.[intPrepaymentDetailId] = ARPAC.[intPrepaymentDetailId]
										  ), 0.000000)
	,[ysnApplied]						= ISNULL(ARPAC.[ysnApplied],0)
	,[ysnPosted]						= ISNULL(ARPAC.[ysnPosted],0)
	
FROM
	tblARPrepaidAndCredit ARPAC
INNER JOIN
	tblARInvoiceDetail ARID
		ON ARPAC.[intPrepaymentDetailId] = ARID.[intInvoiceDetailId]
INNER JOIN
	tblARInvoice ARI
		ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
		AND ARI.[strTransactionType] = 'Customer Prepayment'
		--AND ARI.[ysnPaid] = 0
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