CREATE VIEW [dbo].[vyuARSearchRebuild]
AS 

SELECT *
FROM (
	--Get mismatched strBatchId in tblGLDetail
	SELECT 
		 [strIssue]			= 'Invoice and GL batch id mismatch'
		,[dtmDate]			= GLD.dtmDate
		,[intTransactionId] = GLD.intTransactionId
		,[strTransactionId] = GLD.strTransactionId 
		,[strBatchId]		= GLD.strBatchId
		,[ysnAllowRebuild]	= CAST(1 AS BIT)
	FROM tblGLDetail GLD
	OUTER APPLY
	(
		SELECT strInvoiceNumber, strBatchId
		FROM tblARInvoice
		WHERE ysnPosted = 1
		AND strInvoiceNumber = GLD.strTransactionId
		AND strBatchId = GLD.strBatchId
	) I
	WHERE strTransactionForm = 'Invoice'
	AND strInvoiceNumber IS NULL
	AND strCode = 'IC'
	AND ysnIsUnposted = 0

	UNION ALL

	--Get mismatched strBatchId in tblICInventoryTransaction
	SELECT 
		 [strIssue]			= 'Invoice and inventory batch id mismatch' 
		,[dtmDate]			= ICIT.dtmDate
		,[intTransactionId] = ICIT.intTransactionId
		,[strTransactionId] = ICIT.strTransactionId 
		,[strBatchId]		= ICIT.strBatchId
		,[ysnAllowRebuild]	= CAST(1 AS BIT)
	FROM tblICInventoryTransaction ICIT
	OUTER APPLY
	(
		SELECT strInvoiceNumber, strBatchId
		FROM tblARInvoice
		WHERE ysnPosted = 1
		AND strInvoiceNumber = ICIT.strTransactionId
		AND strBatchId = ICIT.strBatchId
	) I
	WHERE strTransactionForm = 'Invoice'
	AND strInvoiceNumber IS NULL
	AND ysnIsUnposted = 0

	UNION ALL

	SELECT 
		 [strIssue]			= 'Invoice missing IC' 
		,[dtmDate]			= ARI.dtmDate
		,[intTransactionId] = ARI.intInvoiceId
		,[strTransactionId] = ARI.strInvoiceNumber
		,[strBatchId]		= ARI.strBatchId
		,[ysnAllowRebuild]	= CAST(0 AS BIT)
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI
	ON ARI.intInvoiceId = ARID.intInvoiceId
	INNER JOIN tblICItem ICI
	ON ARID.intItemId = ICI.intItemId
	WHERE ysnPosted = 1
	AND ysnImpactInventory = 1
	AND strInvoiceNumber NOT IN (SELECT strTransactionId FROM tblICInventoryTransaction)

	UNION ALL

	SELECT 
		 [strIssue]			= 'Invoice missing GL' 
		,[dtmDate]			= ARI.dtmDate
		,[intTransactionId] = ARI.intInvoiceId
		,[strTransactionId] = ARI.strInvoiceNumber
		,[strBatchId]		= ARI.strBatchId
		,[ysnAllowRebuild]	= CAST(0 AS BIT)
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI
	ON ARI.intInvoiceId = ARID.intInvoiceId
	INNER JOIN tblICItem ICI
	ON ARID.intItemId = ICI.intItemId
	WHERE ysnPosted = 1
	AND ysnImpactInventory = 1
	AND strInvoiceNumber NOT IN (SELECT strTransactionId FROM tblGLDetail WHERE strCode <> 'AR')
) R
GROUP BY [strIssue], [dtmDate], [intTransactionId], [strTransactionId], [strBatchId], [ysnAllowRebuild]
