CREATE VIEW [dbo].[vyuARSearchRebuild]
AS 
SELECT ARR.*, ysnFiscalOpen
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
	) ARI
	WHERE strTransactionForm = 'Invoice'
	AND strInvoiceNumber IS NULL
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
	) ARI
	WHERE ICIT.strTransactionForm = 'Invoice'
	AND ARI.strInvoiceNumber IS NULL
	AND ICIT.ysnIsUnposted = 0

	UNION ALL

	SELECT 
		 [strIssue]			= 'Invoice missing inventory entry' 
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
	AND ARI.ysnImpactInventory = 1
	AND ARI.strInvoiceNumber NOT IN (SELECT strTransactionId FROM tblICInventoryTransaction)
	AND ICI.strType = 'Inventory'


	UNION ALL

	SELECT 
		 [strIssue]			= 'Invoice missing inventory GL' 
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
	AND ARI.ysnImpactInventory = 1
	AND ARI.strInvoiceNumber NOT IN (SELECT strTransactionId FROM tblGLDetail WHERE strCode = 'IC')
	AND ICI.strType = 'Inventory'

	UNION ALL

	SELECT 
		 [strIssue]			= 'Invoice not yet posted or deleted but has posted GL entry'
		,[dtmDate]			= ARI.dtmDate
		,[intTransactionId] = ARI.intInvoiceId
		,[strTransactionId] = ARI.strInvoiceNumber 
		,[strBatchId]		= GLD.strBatchId
		,[ysnAllowRebuild]	= CAST(1 AS BIT)
	FROM tblARInvoice ARI
	OUTER APPLY
	(
		SELECT strTransactionId, strBatchId
		FROM tblGLDetail
		WHERE ysnIsUnposted = 0
		AND  strTransactionId = ARI.strInvoiceNumber
		AND strTransactionForm = 'Invoice'
	) GLD
	WHERE GLD.strTransactionId IS NOT NULL
	AND ARI.ysnPosted = 0
) ARR
OUTER APPLY
(
	SELECT TOP 1 ysnFiscalOpen = CASE WHEN ysnOpen = 1 AND ysnAROpen = 1 AND ysnINVOpen = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM tblGLFiscalYearPeriod
	WHERE CAST(ARR.dtmDate AS DATE) BETWEEN CAST(dtmStartDate AS DATE) AND CAST(dtmEndDate AS DATE)
	ORDER BY dtmStartDate
) ARI
GROUP BY [strIssue], [dtmDate], [intTransactionId], [strTransactionId], [strBatchId], [ysnAllowRebuild], [ysnFiscalOpen]
