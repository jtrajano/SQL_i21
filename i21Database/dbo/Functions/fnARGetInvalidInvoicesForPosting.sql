﻿CREATE FUNCTION [dbo].[fnARGetInvalidInvoicesForPosting]
(
     @Invoices      [dbo].[InvoicePostingTable] Readonly
    ,@ItemAccounts  [dbo].[InvoiceItemAccount]  Readonly
    ,@Post          BIT	= 0
    ,@Recap         BIT = 0
)
RETURNS @returntable TABLE
(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)
AS
BEGIN

DECLARE @ZeroDecimal DECIMAL(18,6)

SET @ZeroDecimal = 0.000000

IF(ISNULL(@Post,0)) = 1
	BEGIN
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		--ALREADY POSTED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The transaction is already posted.'
		FROM 
			@Invoices I
		INNER JOIN  tblARInvoice ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			ARI.[ysnPosted] = 1

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		--INVENTORY IMPACT UNCHECKED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Inventory Impact should be checked on type Invoice, Cash  or Cash Refund.'
		FROM 
			@Invoices I
		INNER JOIN  tblARInvoice ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			(ARI.[strTransactionType] = 'Invoice' OR ARI.[strTransactionType] = 'Cash Refund' OR ARI.[strTransactionType] = 'Cash')
			AND ARI.[ysnImpactInventory] = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		--Recurring Invoice
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Posting recurring invoice(' + I.[strInvoiceNumber] + ') is not allowed.'
		FROM 
			@Invoices I
		INNER JOIN  tblARInvoice ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			ARI.[ysnRecurring] = 1

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Fiscal Year
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Unable to find an open fiscal year period to match the transaction date.'
		FROM 					
			@Invoices I	
		WHERE  
			ISNULL(dbo.isOpenAccountingDate(ISNULL(I.[dtmPostDate], I.[dtmDate])), 0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--If ysnAllowUserSelfPost is True in User Role
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN @Recap = 0 THEN 'You cannot Post transactions you did not create.' ELSE 'You cannot Preview transactions you did not create.' END
		FROM 					
			@Invoices I
		WHERE  
			I.[intEntityId] <> I.[intUserId]
			AND (I.[ysnUserAllowedToPostOtherTrans] IS NOT NULL AND I.[ysnUserAllowedToPostOtherTrans] = 1)			

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		-- Tank consumption site
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Unable to find a tank consumption site for item no. ' + ICI.[strItemNo]
		FROM 
			@Invoices I					
		INNER JOIN dbo.tblARInvoiceDetail ARID 
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN dbo.tblICItem ICI 
				ON ARID.[intItemId] = ICI.[intItemId]	
		WHERE
			ARID.[intSiteId] IS NULL
			AND I.[strType] = 'Tank Delivery'
			AND ICI.[ysnTankRequired] = 1
			AND ISNULL(ICI.[strType],'') <> 'Comment'		
		
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--zero amount
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice ' THEN 'You cannot post an ' + I.[strTransactionType] + ' with zero amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with zero amount.' END
		FROM 
			@Invoices I					
		WHERE
			I.[dblInvoiceTotal] = @ZeroDecimal
			AND strTransactionType != 'Cash Refund'
			AND ISNULL(I.[strImportFormat], '') <> 'CarQuest'		
			AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID WHERE ARID.[intInvoiceId] = I.[intInvoiceId] AND ISNULL(ARID.[intItemId], 0) <> 0)		

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice ' THEN 'You cannot post an ' + I.[strTransactionType] + ' with zero amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with zero amount.' END
		FROM 
			@Invoices I					
		WHERE
			I.[dblInvoiceTotal] = @ZeroDecimal
			AND EXISTS (
				SELECT a.intItemId FROM tblARInvoiceDetail  a join tblICItem  b on a.intItemId = b.intItemId where intInvoiceId = I.[intInvoiceId] and b.strType = 'Comment'
			)
			AND NOT EXISTS(
				SELECT a.intItemId FROM tblARInvoiceDetail  a join tblICItem  b on a.intItemId = b.intItemId where intInvoiceId = I.[intInvoiceId] and b.strType <> 'Comment')		

		


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--zero amount
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN I.[strTransactionType] = 'Invoice' THEN 'You cannot post an ' + I.[strTransactionType] + ' with negative amount.' ELSE 'You cannot post a ' + I.[strTransactionType] + ' with negative amount.' END
		FROM 
			@Invoices I					
		WHERE
			I.[dblInvoiceTotal] < @ZeroDecimal	
		
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Inactive Customer
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Customer - ' + ARC.strCustomerNumber + ' is not active!'
		FROM 
			@Invoices I	
		INNER JOIN dbo.tblARCustomer  ARC
				ON I.[intEntityCustomerId] = ARC.[intEntityId]						
		WHERE
			ARC.[ysnActive] = 0
		
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Inactive Customer
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Customer credit limit is blank! Only Cash Sale transaction is allowed.'
		FROM 
			@Invoices I	
		INNER JOIN dbo.tblARCustomer  ARC
				ON I.[intEntityCustomerId] = ARC.[intEntityId]						
		WHERE
			ARC.dblCreditLimit is null and I.[strTransactionType] != 'Cash' and I.[strType] != 'POS'
			

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Invoice - ' + I.strInvoiceNumber + ' is not yet Approved!'
		FROM 
			@Invoices I	
		INNER JOIN
			(SELECT intTransactionId FROM dbo.vyuARForApprovalTransction WITH (NOLOCK) WHERE strScreenName = 'Invoice') FAT
				ON I.intInvoiceId = FAT.intTransactionId
		
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--UOM is required
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'UOM is required for item ' + ISNULL(NULLIF(ARID.[strItemDescription], ''), IST.[strItemNo]) + '.'
		FROM 
			@Invoices I	
		INNER JOIN dbo.tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN dbo.vyuICGetItemStock IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId]		 
		WHERE
			I.[strTransactionType] = 'Invoice'	
			AND (ARID.[intItemUOMId] IS NULL OR ARID.[intItemUOMId] = 0) 
			AND (ARID.[intInventoryShipmentItemId] IS NULL OR ARID.[intInventoryShipmentItemId] = 0)
			AND (ARID.[intSalesOrderDetailId] IS NULL OR ARID.[intSalesOrderDetailId] = 0)
			AND (ARID.[intLoadDetailId] IS NULL OR ARID.[intLoadDetailId] = 0)
			AND (ARID.[intItemId] IS NOT NULL OR ARID.[intItemId] <> 0)
			AND ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software', 'Comment', '')	

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Dsicount Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN ' The Receivable Discount account assigned to item ' + IT.[strItemNo] + ' is not valid.' ELSE 'Receivable Discount account was not set up for item ' + IT.[strItemNo] END
		FROM 
			@Invoices I	
		INNER JOIN dbo.tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN @ItemAccounts  IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 
		LEFT OUTER JOIN dbo.tblICItem  IT
				ON ARID.[intItemId] = IT.[intItemId]
		LEFT OUTER JOIN dbo.tblGLAccount GLA
				ON ISNULL(IST.[intDiscountAccountId], I.[intDiscountAccountId]) = GLA.[intAccountId]		 
		WHERE
			((ISNULL(IST.[intDiscountAccountId],0) = 0  AND  ISNULL(I.[intDiscountAccountId],0) = 0) OR GLA.[intAccountId] IS NULL)
			AND ARID.[dblDiscount] <> 0		
			AND ISNULL(IT.[strType],'') <> 'Comment'	

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Currency is required
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'No currency has been specified.'
		FROM 
			@Invoices I			 
		WHERE
			ISNULL(I.[intCurrencyId], 0) = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--No Terms specified
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'No terms has been specified.'
		FROM 
			@Invoices I			 
		WHERE
			ISNULL(I.[intTermId], 0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--NOT BALANCE
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The debit and credit amounts are not balanced.'
		FROM 
			@Invoices I			 
		WHERE
			I.[dblInvoiceTotal] <> ((SELECT SUM([dblTotal]) FROM tblARInvoiceDetail ARID WITH (NOLOCK) WHERE ARID.[intInvoiceId] = I.[intInvoiceId]) + ISNULL(I.[dblShipping],0.0) + ISNULL(I.[dblTax],0.0))

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Header Account ID
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The AR account is not valid.' ELSE 'The AR account is not specified.' END
		FROM 
			@Invoices I
		LEFT OUTER JOIN tblGLAccount GLA 
				ON ISNULL(I.[intAccountId], 0) = GLA.[intAccountId]		 
		WHERE
			(ISNULL(I.[intAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Company Location
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Company location of ' + I.[strInvoiceNumber] + ' was not set.'
		FROM 
			@Invoices I
		LEFT OUTER JOIN tblSMCompanyLocation SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId] 
		WHERE
			SMCL.[intCompanyLocationId] IS NULL


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Freight Expenses Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Freight Income account is not valid.' ELSE 'The Freight Income account of Company Location ' + SMCL.[strLocationName] + ' was not set.' END
		FROM 
			@Invoices I
		INNER JOIN tblSMCompanyLocation SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON SMCL.[intFreightIncome] = GLA.[intAccountId]						
		WHERE
			(ISNULL(SMCL.[intFreightIncome], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(I.[dblShipping],0) <> 0.0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Undeposited Funds Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Undeposited Funds account of Company Location ' + SMCL.[strLocationName] + ' is not valid.' ELSE 'The Undeposited Funds account of Company Location ' + SMCL.[strLocationName] + ' was not set.' END
		FROM 
			@Invoices I
		INNER JOIN tblSMCompanyLocation SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN tblGLAccount  GLA
				ON SMCL.[intUndepositedFundsId] = GLA.[intAccountId]						
					
		WHERE
			(ISNULL(SMCL.[intUndepositedFundsId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND (
				I.[strTransactionType] IN ('Cash','Cash Refund')
				OR
				(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.[intInvoiceId] = I.[intInvoiceId] AND tblARPrepaidAndCredit.[ysnApplied] = 1 AND tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount] <> 0 ))
				)

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Sales Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales account of Company Location ' + SMCL.[strLocationName] + ' is not valid.' ELSE 'The Sales account of Company Location ' + SMCL.[strLocationName] + ' was not set.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId] 				 
		INNER JOIN tblSMCompanyLocation  SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN tblGLAccount  GLA
				ON SMCL.[intSalesAccount] = GLA.[intAccountId]			
		WHERE
			(ISNULL(SMCL.[intSalesAccount], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ARID.[intServiceChargeAccountId],0) = 0
			AND ISNULL(ARID.[intSalesAccountId], 0) = 0
			AND ISNULL(ARID.[intItemId],0) = 0
			AND ARID.[dblTotal] <> @ZeroDecimal


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Accrual Not in Fiscal Year
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= I.[strInvoiceNumber] + ' has an Accrual setup up to ' + CONVERT(NVARCHAR(30),DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate])), 101) + ' which does not fall into a valid Fiscal Period.'
		FROM 
			@Invoices I
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1  
			AND ISNULL(dbo.isOpenAccountingDate(DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate]))), 0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Accrual Not in Fiscal Year
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= I.[strInvoiceNumber] + ' has an Accrual setup up to ' + CONVERT(NVARCHAR(30),DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate])), 101) + ' which does not fall into a valid Fiscal Period.'
		FROM 
			@Invoices I
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1  
			AND ISNULL(dbo.isOpenAccountingDate(DATEADD(mm, (ISNULL(I.[intPeriodsToAccrue],1) - 1), ISNULL(I.[dtmPostDate], I.[dtmDate]))), 0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Deferred Revenue Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Deferred Revenue account in the Company Configuration was not set.'
		FROM 
			@Invoices I
		WHERE
			ISNULL(I.intPeriodsToAccrue,0) > 1
			AND ISNULL(I.[intDeferredRevenueAccountId], 0) = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Deferred Revenue Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Deferred Revenue account is not valid.'
		FROM 
			@Invoices I
		WHERE
			ISNULL(I.[intPeriodsToAccrue], 0) > 1
			AND ISNULL(I.[intDeferredRevenueAccountId], 0) <> 0
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WITH (NOLOCK) WHERE GLA.[intAccountId] = I.[intDeferredRevenueAccountId])


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Invoice for accrual with Inventory Items
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Invoice : ' + I.[strInvoiceNumber] + ' is for accrual and must not include an inventory item : ' + ICI.[strItemNo] + '.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]	 				
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Invoice for accrual with Inventory Items
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Invoice : ' + I.[strInvoiceNumber] + ' is for accrual and must not include an inventory item : ' + ICI.[strItemNo] + '.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]	 				
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Provisional Invoice Posting
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Posting Provisional Invoice is disabled in Company Configuration.'
		FROM 
			@Invoices I					
		WHERE
			I.[strType] = 'Provisional'
			AND ISNULL(I.[ysnProvisionalWithGL],0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--General Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The General Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem  ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId]
				AND ARID.[intItemId] = Acct.[intItemId] 		
		LEFT OUTER JOIN tblGLAccount GLA
				ON Acct.[intGeneralAccountId] = GLA.[intAccountId]
		WHERE
			(ISNULL(Acct.[intGeneralAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') IN ('Non-Inventory','Service')
			AND ISNULL(ICI.[strType],'') <> 'Comment'


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Type
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Maintenance Type of item - ' + ICI.[strItemNo] + ' is not valid.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') NOT IN ('License/Maintenance', 'Maintenance Only', 'SaaS', 'License Only')


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Frequency
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Maintenance Frequency of item - ' + ICI.[strItemNo] + ' is not valid.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') NOT IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Date
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Maintenance Start Date of item - ' + ICI.[strItemNo] + ' is required.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ARID.[dtmMaintenanceDate] IS NULL

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - License Amount
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The License Amount of item - ' + ICI.[strItemNo] + ' does not match the Price.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License Only')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal) <> ISNULL(ARID.[dblPrice], @ZeroDecimal)


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Amount
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Maintenance Amount of item - ' + ICI.[strItemNo] + ' does not match the Price.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) <> ISNULL(ARID.[dblPrice], @ZeroDecimal)


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Amount + License
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Maintenance Amount + License Amount of item - ' + ICI.[strItemNo] + ' does not match the Price.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail  ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem  ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) + ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal)) <> ISNULL(ARID.[dblPrice], @ZeroDecimal))

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - Maintenance Sales
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Maintenance Sales account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Maintenance Sales of item - ' + ICI.[strItemNo] + ' were not specified.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON Acct.[intMaintenanceSalesAccountId] = GLA.[intAccountId]	 								
		WHERE
			(ISNULL(Acct.[intMaintenanceSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Software'	
			AND ARID.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Software - General Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The General account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The General Accounts of item - ' + ICI.[strItemNo] + ' were not specified.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId]
				AND ARID.[intItemId] = Acct.[intItemId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON Acct.[intGeneralAccountId] = GLA.[intAccountId]	 			
		WHERE
			(ISNULL(Acct.[intGeneralAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Software'	
			AND ARID.[strMaintenanceType] IN ('License/Maintenance', 'License Only')


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Other Charge Income Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Other Charge Income account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Other Charge Income Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId] 		 	
		LEFT OUTER JOIN tblGLAccount GLA
				ON Acct.intOtherChargeIncomeAccountId = GLA.[intAccountId]
		WHERE
			(ISNULL(Acct.[intOtherChargeIncomeAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Other Charge'

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Sales Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= ICI.[strItemNo] + ' at ' + SMCL.strLocationName + ' is missing a GL account setup for Sales account category.'
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId] 	
		LEFT OUTER JOIN tblGLAccount GLA
				ON Acct.[intSalesAccountId] = GLA.[intAccountId]	
		LEFT OUTER JOIN tblSMCompanyLocation SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId] 
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal 
			AND (ARID.[intItemId] IS NOT NULL OR ARID.[intItemId] <> 0)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
			AND (ISNULL(Acct.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND (I.[strTransactionType] <> 'Debit Memo' OR (I.[strTransactionType] = 'Debit Memo' AND ISNULL(I.[strType],'') IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
			AND ISNULL(I.[intPeriodsToAccrue], 0) <= 1


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Sales Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Account of line item - ' + ARID.[strItemDescription] + ' is not valid.' ELSE 'The Sales Account of line item - ' + ARID.[strItemDescription] + ' was not specified.' END
		FROM 
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON ARID.[intSalesAccountId] = GLA.[intAccountId]
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal 
			AND (ISNULL(ARID.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] = 'Debit Memo'
			AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
			AND ISNULL(I.[intPeriodsToAccrue],0) <= 1


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Sales Tax Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' is not valid.' ELSE 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.' END
		FROM tblARInvoiceDetailTax ARIDT
		INNER JOIN tblARInvoiceDetail ARID
				ON ARIDT.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]			
		LEFT OUTER JOIN tblSMTaxCode  SMTC
				ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) = GLA.[intAccountId]	
		WHERE
			ARIDT.[dblAdjustedTax] <> @ZeroDecimal
			AND (ISNULL(ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]), 0) = 0 OR GLA.[intAccountId] IS NULL)


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--COGS Account -- SHIPPED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			tblARInvoiceDetail ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]					
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		INNER JOIN tblICItemUOM ItemUOM 
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		LEFT OUTER JOIN @ItemAccounts IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 			
		INNER JOIN tblICInventoryShipmentItem ISD
				ON 	ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
		INNER JOIN tblICInventoryShipment ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		INNER JOIN tblICInventoryTransaction ICT
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						 
		LEFT OUTER JOIN tblGLAccount GLA
				ON IST.[intCOGSAccountId] = GLA.[intAccountId]
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND (ISNULL(IST.[intCOGSAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] <> 'Debit Memo'

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Inventory In-Transit Account Account -- SHIPPED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM tblARInvoiceDetail ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]						  
		INNER JOIN tblICItemUOM ItemUOM 
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN @ItemAccounts IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 							
		INNER JOIN tblICInventoryShipmentItem  ISD
				ON 	ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
		INNER JOIN tblICInventoryShipment ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		INNER JOIN tblICInventoryTransaction ICT
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						  
		LEFT OUTER JOIN tblGLAccount GLA
				ON IST.[intInventoryInTransitAccountId] = GLA.[intAccountId]				
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] <> 'Debit Memo'	
			AND (ISNULL(IST.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--COGS Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM tblARInvoiceDetail ARID				 
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]	
		INNER JOIN tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		LEFT OUTER JOIN @ItemAccounts ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
		LEFT OUTER JOIN tblGLAccount GLA
				ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	
			
			
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--COGS Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of component - ' + ARIA.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of component - ' + ARIA.[strItemNo] + ' was not specified.' END
		FROM vyuARGetItemComponents ARIC
		INNER JOIN tblARInvoiceDetail ARID
				ON ARIC.[intItemId] = ARID.[intItemId] and ARID.intInventoryShipmentItemId is null
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]		
		INNER JOIN tblICItem ICI
				ON ARIC.[intComponentItemId] = ICI.[intItemId]
		LEFT OUTER JOIN  @ItemAccounts ARIA
				ON ARIC.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 	
		LEFT OUTER JOIN  tblGLAccount  GLA
				ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	 
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId],0) <> 0
			AND ISNULL(ARIC.[intComponentItemId],0) <> 0
			AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] <> 'Debit Memo'	
			AND (ISNULL(ARIC.[strType],'') NOT IN ('Finished Good','Comment') OR ICI.[ysnAutoBlend] <> 1)
					

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Inventory In-Transit Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM tblARInvoiceDetail ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]
		INNER JOIN tblICItem  ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		LEFT OUTER JOIN @ItemAccounts ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
		LEFT OUTER JOIN tblGLAccount GLA
				ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId]
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Inventory In-Transit Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ARIA.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ARIA.[strItemNo] + ' was not specified.' END
		FROM vyuARGetItemComponents ARIC
		INNER JOIN tblARInvoiceDetail ARID
				ON ARIC.[intItemId] = ARID.[intItemId] and ARID.intInventoryShipmentItemId is null
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]
		INNER JOIN tblICItem ICI
				ON ARIC.[intComponentItemId] = ICI.[intItemId]
		LEFT OUTER JOIN tblICItemUOM ICIUOM
				ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
		LEFT OUTER JOIN @ItemAccounts ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId]
		LEFT OUTER JOIN tblGLAccount GLA
				ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId] 		 		 
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId],0) <> 0
			AND ISNULL(ARIC.[intComponentItemId],0) <> 0
			AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] <> 'Debit Memo'																		
			AND (ISNULL(ARIC.[strType],'') NOT IN ('Finished Good','Comment') OR ICI.[ysnAutoBlend] <> 1)


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Zero Contract Item Price
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The contract item - ' + ICI.[strItemNo] + ' price cannot be zero.'
		FROM 					
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK) WHERE strType NOT IN ('Other Charge') ) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		INNER JOIN
			(SELECT [intContractHeaderId], [intContractDetailId], [strPricingType] FROM vyuCTCustomerContract WITH (NOLOCK)) CTCD
				ON ARID.[intContractHeaderId] = CTCD.[intContractHeaderId] 
				AND ARID.[intContractDetailId] = CTCD.[intContractDetailId] 
		WHERE
			ARID.[dblPrice] = @ZeroDecimal
			AND I.strTransactionType <> 'Credit Memo'
			AND CTCD.[strPricingType] <> 'Index'
			AND ISNULL(ARID.[intLoadDetailId],0) = 0


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Contract Item Price not Equal to Contract Sequence Cash Price
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The contract item - ' + ICI.[strItemNo] + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARID.[dblUnitPrice],@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY),2) + ').'
		FROM 					
			@Invoices I
		INNER JOIN tblARInvoiceDetail ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK) WHERE strType NOT IN ('Other Charge')) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		INNER JOIN 
			(SELECT [intInvoiceId], intOriginalInvoiceId FROM tblARInvoice WITH (NOLOCK) WHERE intOriginalInvoiceId IS NULL) ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN vyuCTCustomerContract ARCC
				ON ARID.[intContractHeaderId] = ARCC.[intContractHeaderId] 
				AND ARID.[intContractDetailId] = ARCC.[intContractDetailId] 			 				
		WHERE
			ARID.[dblUnitPrice] <> @ZeroDecimal				
			AND CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY) <> CAST(ISNULL(ARID.[dblUnitPrice], @ZeroDecimal) AS MONEY)
			AND ARCC.[strPricingType] <> 'Index'
			AND I.strTransactionType <> 'Credit Memo'
			AND ISNULL(ARID.[intLoadDetailId],0) = 0
			AND ISNULL(ARID.[intShipmentId],0) = 0
			AND ISNULL(ARID.[intInventoryShipmentItemId],0) = 0
			AND ARID.[strPricing] NOT IN ('Contracts-Max Price','Contracts-Pricing Level')
			

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Lot Tracked
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= ARID.[intInvoiceDetailId]
			,[intItemId]			= ARID.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The Qty Ship for ' + ARID.[strItemDescription] + ' is ' + CONVERT(NVARCHAR(50), CAST(ARID.dblQtyShipped AS DECIMAL(16, 2))) + '. Total Lot Qty is ' + CONVERT(NVARCHAR(50), CAST(ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2))) + ' The difference is ' + CONVERT(NVARCHAR(50), ABS(CAST(ARID.dblQtyShipped - ISNULL(LOT.dblTotalQtyShipped, 0) AS DECIMAL(16, 2)))) + '.' 
		FROM @Invoices I	
		INNER JOIN (
			SELECT [intInvoiceId]
				 , [intItemId]
				 , [intInvoiceDetailId]
				 , [strItemDescription]
				 , [dblQtyShipped]
			FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
			WHERE ISNULL(ARID.[intItemId],0) <> 0
			  AND [dbo].[fnGetItemLotType](ARID.[intItemId]) <> 0
			  AND ISNULL(ARID.[intInventoryShipmentItemId],0) = 0
			  AND ISNULL(ARID.[intLoadDetailId],0) = 0
			  AND ISNULL(ARID.[intTicketId],0) = 0
			  AND ISNULL(ARID.[ysnBlended],0) = 0
		) ARID ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT JOIN (
			SELECT [intLoadId]
				 , [intPurchaseSale]
			FROM dbo.tblLGLoad WITH (NOLOCK)
		) LG ON I.[intLoadId] = LG.[intLoadId]
		OUTER APPLY (
			SELECT [dblTotalQtyShipped] = SUM(ISNULL(dblQuantityShipped, 0))
			FROM dbo.tblARInvoiceDetailLot ARIDL WITH (NOLOCK)
			WHERE ARID.intInvoiceDetailId = ARIDL.intInvoiceDetailId
		) LOT
		WHERE ARID.dblQtyShipped <> ISNULL(LOT.[dblTotalQtyShipped], 0)
		  AND ISNULL(I.[intLoadDistributionHeaderId],0) = 0
		  AND ((ISNULL(I.[intLoadId], 0) IS NOT NULL AND ISNULL(LG.[intPurchaseSale], 0) NOT IN (2, 3)) OR ISNULL(I.[intLoadId], 0) IS NULL)

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--CASH REFUND AMOUNT IS NOT EQUAL TO PREPAIDS
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Cash Refund amount is not equal to prepaids/credits applied.'
		FROM 					
			@Invoices I
		OUTER APPLY (
			SELECT dblAppliedInvoiceAmount	= SUM(ISNULL(dblAppliedInvoiceDetailAmount, 0))
			FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
			WHERE intInvoiceId = I.intInvoiceId 
			  AND ysnApplied = 1
			  AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0			
		) PREPAIDS
		WHERE I.strTransactionType = 'Cash Refund'
		AND I.dblInvoiceTotal <> ISNULL(PREPAIDS.dblAppliedInvoiceAmount, 0)

		-- IC Costing
		DECLARE @ItemsForCosting [ItemCostingTableType]
		DELETE FROM @ItemsForCosting
		INSERT INTO @ItemsForCosting
			([intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate])
		SELECT
			 [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
		FROM
			[dbo].[fnARGetItemsForCosting](@Invoices, @Post, 1)

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		SELECT
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError] -- + '[fnICGetInvalidInvoicesForCosting]'
		FROM 
			[dbo].[fnICGetInvalidInvoicesForCosting](@ItemsForCosting, @Post)


		-- IC In Transit Costing
		DECLARE @ItemsForInTransitCosting [ItemInTransitCostingTableType]
		DELETE FROM @ItemsForInTransitCosting
		INSERT INTO @ItemsForInTransitCosting
			([intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intSourceTransactionDetailId]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate])
		SELECT
			 [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intSourceTransactionDetailId]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
		FROM
			[dbo].[fnARGetItemsForInTransitCosting](@Invoices, @Post)

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		SELECT
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError] -- + '[fnICGetInvalidInvoicesForInTransitCosting]'
		FROM 
			[dbo].[fnICGetInvalidInvoicesForInTransitCosting](@ItemsForInTransitCosting, @Post)


		-- IC Item Storage
		DECLARE @ItemsForStoragePosting [ItemCostingTableType]
		DELETE FROM @ItemsForStoragePosting
		INSERT INTO @ItemsForStoragePosting
			([intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate])
		SELECT
			 [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
		FROM
			[dbo].[fnARGetItemsForStoragePosting](@Invoices, @Post) 


		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		SELECT
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError] -- + '[fnICGetInvalidInvoicesForItemStoragePosting]'
		FROM 
			[dbo].[fnICGetInvalidInvoicesForItemStoragePosting](@ItemsForStoragePosting, @Post)

	END
ELSE
	BEGIN
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		--NOT YET POSTED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The transaction has not been posted yet.'
		FROM 
			@Invoices I
		INNER JOIN  tblARInvoice ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			ARI.[ysnPosted] = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		select
			 [intInvoiceId]			= c.[intInvoiceId]
			,[strInvoiceNumber]		= c.[strInvoiceNumber]		
			,[strTransactionType]	= c.[strTransactionType]
			,[intInvoiceDetailId]	= c.[intInvoiceDetailId]
			,[intItemId]			= c.[intItemId]
			,[strBatchId]			= c.[strBatchId]
			,[strPostingError]		= 'You cannot unpost an Invoice with Service Charge Invoice created-' + b.strInvoiceNumber +  '.'

			from (select intInvoiceDetailId, intItemId, 
						intSCInvoiceId, intInvoiceId from 
							tblARInvoiceDetail) a
				join (select intInvoiceId, strInvoiceNumber,
						strTransactionType from tblARInvoice with (nolock)
					) b on a.intInvoiceId = b.intInvoiceId
				join @Invoices c
					on a.intSCInvoiceId = c.intInvoiceId			
		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Fiscal Year
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Unable to find an open fiscal year period to match the transaction date.'
		FROM 					
			@Invoices I	
		WHERE  
			ISNULL(dbo.isOpenAccountingDate(ISNULL(I.[dtmPostDate], I.[dtmDate])), 0) = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])

		SELECT 
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'You cannot unpost an Invoice with ' + ISNULL(I2.strTransactionType,'') + ' created- ' + ISNULL(I2.strInvoiceNumber ,'')
		FROM @Invoices I
		INNER JOIN tblARInvoiceDetail D
			ON D.intInvoiceId = I.intInvoiceId
		INNER JOIN tblARInvoiceDetail D2
			ON D2.intOriginalInvoiceDetailId = D.intInvoiceDetailId
		INNER JOIN tblARInvoice I2
			ON I2.intInvoiceId = D2.intInvoiceId

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--If ysnAllowUserSelfPost is True in User Role
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		=  CASE WHEN @Recap = 0 THEN 'You cannot Unpost transactions you did not create.' ELSE 'You cannot Preview transactions you did not create.' END
		FROM 					
			@Invoices I
		WHERE  
			I.[intEntityId] <> I.[intUserId]
			AND (I.[ysnUserAllowedToPostOtherTrans] IS NOT NULL AND I.[ysnUserAllowedToPostOtherTrans] = 1)			

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--ALREADY HAVE PAYMENTS
		--AR-5542 added the additional comment for have payments
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= ARP.[strRecordNumber] + ' payment was already made on this ' + I.strTransactionType + '.' + CASE WHEN I.strTransactionType = 'Credit Memo' THEN ' Please remove payment record and try again.' ELSE '' END
		FROM tblARPayment ARP
		INNER JOIN tblARPaymentDetail ARPD 
				ON ARP.[intPaymentId] = ARPD.[intPaymentId]						
		INNER JOIN 
			@Invoices I
				ON ARPD.[intInvoiceId] = I.[intInvoiceId]
		WHERE @Recap = 0 AND I.strTransactionType != 'Cash Refund'

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Payments from Pay Voucher
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= APP.[strPaymentRecordNum] + ' payment was already made on this ' + I.strTransactionType + '.' + CASE WHEN I.strTransactionType = 'Credit Memo' THEN ' Please remove payment record and try again.' ELSE '' END
		FROM tblAPPayment APP
		INNER JOIN tblAPPaymentDetail APPD 
				ON APP.[intPaymentId] = APPD.[intPaymentId]						
		INNER JOIN 
			@Invoices I
				ON APPD.[intInvoiceId] = I.[intInvoiceId]
		WHERE @Recap = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--Invoice with created Bank Deposit
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'You cannot unpost invoice with created Bank Deposit.'
		FROM 
			@Invoices I
		INNER JOIN tblCMUndepositedFund CMUF 
				ON I.[intInvoiceId] = CMUF.[intSourceTransactionId] 
				AND I.[strInvoiceNumber] = CMUF.[strSourceTransactionId]
		INNER JOIN tblCMBankTransactionDetail CMBTD
				ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
		WHERE 
			CMUF.[strSourceSystem] = 'AR'

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--INVOICE CREATED FROM PATRONAGE
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'This Invoice was created from Patronage > Issue Stock - ' + ISNULL(PAT.strIssueNo, '') + '. Unpost it from there.'
		FROM 
			@Invoices I
		CROSS APPLY (
			SELECT TOP 1 P.strIssueNo
			FROM dbo.tblPATIssueStock P WITH (NOLOCK)
			WHERE P.intInvoiceId = I.intInvoiceId
			  AND P.ysnPosted = 1
		) PAT
		WHERE @Recap = 0

		INSERT INTO @returntable(
			 [intInvoiceId]
			,[strInvoiceNumber]
			,[strTransactionType]
			,[intInvoiceDetailId]
			,[intItemId]
			,[strBatchId]
			,[strPostingError])
		--CASH REFUND ALREADY APPLIED IN PAY VOUCHER
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'This ' + I.[strTransactionType] + ' was already applied in ' + ISNULL(VOUCHER.strPaymentRecordNum, '') + '.'
		FROM 
			@Invoices I
		CROSS APPLY (
			SELECT TOP 1 P.strPaymentRecordNum
			FROM dbo.tblAPPayment P WITH (NOLOCK)
			INNER JOIN tblAPPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
			WHERE PD.intInvoiceId = I.intInvoiceId
		) VOUCHER

		--Don't allow Imported Invoice from Origin to be unposted
		DECLARE @IsAG BIT = 0
		DECLARE @IsPT BIT = 0

		IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'coctlmst')
			SELECT TOP 1 
				@IsAG	= CASE WHEN ISNULL(coctl_ag, '') = 'Y' AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst') THEN 1 ELSE 0 END
				,@IsPT	= CASE WHEN ISNULL(coctl_pt, '') = 'Y' AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst') THEN 1 ELSE 0 END 
			FROM
				coctlmst

		IF @IsAG = 1
			BEGIN
				INSERT INTO @returntable(
					 [intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError])

				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]	
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= ARI.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
				FROM 
					(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [strInvoiceOriginId], [ysnPosted], [ysnImportedAsPosted], [ysnImportedFromOrigin] FROM tblARInvoice WITH (NOLOCK)) ARI 
				INNER JOIN 
					@Invoices I
						ON ARI.[intInvoiceId] = I.[intInvoiceId]
				INNER JOIN
					(SELECT [agivc_ivc_no] FROM agivcmst WITH (NOLOCK)) OI
						ON ARI.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[agivc_ivc_no] COLLATE Latin1_General_CI_AS
				WHERE  
					ARI.[ysnPosted] = 1
					AND ARI.[ysnImportedAsPosted] = 1 
					AND ARI.[ysnImportedFromOrigin] = 1														
			END

		IF @IsPT = 1
			BEGIN
				INSERT INTO @returntable(
					 [intInvoiceId]
					,[strInvoiceNumber]
					,[strTransactionType]
					,[intInvoiceDetailId]
					,[intItemId]
					,[strBatchId]
					,[strPostingError])

				SELECT
					 [intInvoiceId]			= I.[intInvoiceId]
					,[strInvoiceNumber]		= I.[strInvoiceNumber]		
					,[strTransactionType]	= I.[strTransactionType]
					,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
					,[intItemId]			= I.[intItemId]
					,[strBatchId]			= I.[strBatchId]
					,[strPostingError]		= ARI.[strInvoiceNumber] + ' was imported from origin. Unpost is not allowed!'
				FROM 
					(SELECT [intInvoiceId], [strInvoiceNumber], [strTransactionType], [strInvoiceOriginId], [ysnPosted], [ysnImportedAsPosted], [ysnImportedFromOrigin] FROM tblARInvoice WITH (NOLOCK)) ARI 
				INNER JOIN 
					@Invoices I
						ON ARI.[intInvoiceId] = I.[intInvoiceId]
				INNER JOIN
					(SELECT [ptivc_invc_no] FROM ptivcmst WITH (NOLOCK)) OI
						ON ARI.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS = OI.[ptivc_invc_no] COLLATE Latin1_General_CI_AS
				WHERE   ARI.[ysnPosted] = 1
					AND ARI.[ysnImportedAsPosted] = 1 
					AND ARI.[ysnImportedFromOrigin] = 1												
			END
	END


--Invoice Split
DECLARE @PostInvoiceDataFromIntegration AS [InvoicePostingTable]
DELETE FROM @PostInvoiceDataFromIntegration
INSERT INTO
	@PostInvoiceDataFromIntegration
SELECT
	PID.*
FROM
	@Invoices PID
WHERE
	PID.[ysnSplitted] = 0 
	AND ISNULL(PID.[intSplitId], 0) > 0
INSERT INTO @returntable(
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError])
SELECT
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError] -- + '[fnARGetInvalidInvoicesForInvoiceSplits]'
FROM 
	[dbo].[fnARGetInvalidInvoicesForInvoiceSplits](@PostInvoiceDataFromIntegration, @Post) ICC


----GR Grain
--DELETE FROM @PostInvoiceDataFromIntegration
--INSERT INTO @PostInvoiceDataFromIntegration(
--				 [intInvoiceId]
--				,[strInvoiceNumber]
--				,[strTransactionType]
--				,[strType]
--				,[dtmDate]
--				,[dtmPostDate]
--				,[dtmShipDate]
--				,[intEntityCustomerId]
--				,[intCompanyLocationId]
--				,[intAccountId]
--				,[intDeferredRevenueAccountId]
--				,[intCurrencyId]
--				,[intTermId]
--				,[dblInvoiceTotal]
--				,[dblShipping]
--				,[dblTax]
--				,[strImportFormat]
--				,[intDistributionHeaderId]
--				,[intLoadDistributionHeaderId]
--				,[strActualCostId]
--				,[intPeriodsToAccrue]
--				,[ysnAccrueLicense]
--				,[intSplitId]
--				,[dblSplitPercent]
--				,[ysnImpactInventory]
--				,[ysnSplitted]
--				,[intEntityId]
--				,[ysnPost]
--				,[intInvoiceDetailId]
--				,[intItemId]
--				,[intItemUOMId]
--				,[intDiscountAccountId]
--				,[intCustomerStorageId]
--				,[intStorageScheduleTypeId]
--				,[intSubLocationId]
--				,[intStorageLocationId]
--				,[dblQuantity]
--				,[dblMaxQuantity]
--				,[strOptionType]
--				,[strSourceType]
--				,[strBatchId]
--				,[strPostingMessage]
--				,[intUserId]
--				,[ysnAllowOtherUserToPost]
--			)
--			 SELECT DISTINCT
--				 [intInvoiceId]					= PID.[intInvoiceId]
--				,[strInvoiceNumber]				= PID.[strInvoiceNumber]
--				,[strTransactionType]			= PID.[strTransactionType]
--				,[strType]						= PID.[strType]
--				,[dtmDate]						= PID.[dtmDate]
--				,[dtmPostDate]					= PID.[dtmPostDate]
--				,[dtmShipDate]					= PID.[dtmShipDate]
--				,[intEntityCustomerId]			= PID.[intEntityCustomerId]
--				,[intCompanyLocationId]			= PID.[intCompanyLocationId]
--				,[intAccountId]					= PID.[intAccountId]
--				,[intDeferredRevenueAccountId]	= PID.[intDeferredRevenueAccountId]
--				,[intCurrencyId]				= PID.[intCurrencyId]
--				,[intTermId]					= PID.[intTermId]
--				,[dblInvoiceTotal]				= PID.[dblInvoiceTotal]
--				,[dblShipping]					= PID.[dblShipping]
--				,[dblTax]						= PID.[dblTax]
--				,[strImportFormat]				= PID.[strImportFormat]
--				,[intDistributionHeaderId]		= PID.[intDistributionHeaderId]
--				,[intLoadDistributionHeaderId]	= PID.[intLoadDistributionHeaderId]
--				,[strActualCostId]				= PID.[strActualCostId]
--				,[intPeriodsToAccrue]			= PID.[intPeriodsToAccrue]
--				,[ysnAccrueLicense]				= PID.[ysnAccrueLicense]
--				,[intSplitId]					= PID.[intSplitId]
--				,[dblSplitPercent]				= PID.[dblSplitPercent]			
--				,[ysnSplitted]					= PID.[ysnSplitted]
--				,[ysnImpactInventory]			= PID.[ysnImpactInventory]
--				,[intEntityId]					= PID.[intEntityId]
--				,[ysnPost]						= @Post
--				,[intInvoiceDetailId]			= ARID.[intInvoiceDetailId]
--				,[intItemId]					= ARID.[intItemId]
--				,[intItemUOMId]					= ARID.[intItemUOMId]
--				,[intDiscountAccountId]			= PID.[intDiscountAccountId]
--				,[intCustomerStorageId]			= ARID.[intCustomerStorageId]
--				,[intStorageScheduleTypeId]		= ARID.[intStorageScheduleTypeId]
--				,[intSubLocationId]				= NULL
--				,[intStorageLocationId]			= ARID.[intStorageLocationId]
--				,[dblQuantity]					= dbo.fnCalculateStockUnitQty(ARID.[dblQtyShipped], ICIU.[dblUnitQty])
--				,[dblMaxQuantity]				= @ZeroDecimal
--				,[strOptionType]				= 'Update'
--				,[strSourceType]				= 'Invoice'
--				,[strBatchId]					= PID.[strBatchId]
--				,[strPostingMessage]			= ''
--				,[intUserId]					= PID.[intUserId]
--				,[ysnAllowOtherUserToPost]		= PID.[ysnAllowOtherUserToPost]
--FROM
--	(SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [dblQtyShipped], [intItemUOMId], [intStorageScheduleTypeId], [intCustomerStorageId], [intStorageLocationId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
--INNER JOIN 
--	@Invoices PID
--		ON PID.[intInvoiceId] = ARID.[intInvoiceId]
--INNER JOIN
--	(SELECT [intItemId], [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH (NOLOCK)) ICIU  
--		ON ARID.[intItemId] = ICIU.[intItemId] AND ARID.[intItemUOMId] = ICIU.[intItemUOMId]
--WHERE 
--	ARID.[intStorageScheduleTypeId] IS NOT NULL
--	AND ARID.[dblQtyShipped] <> @ZeroDecimal


--INSERT INTO @returntable(
--	 [intInvoiceId]
--	,[strInvoiceNumber]
--	,[strTransactionType]
--	,[intInvoiceDetailId]
--	,[intItemId]
--	,[strBatchId]
--	,[strPostingError])
--SELECT
--	 [intInvoiceId]
--	,[strInvoiceNumber]
--	,[strTransactionType]
--	,[intInvoiceDetailId]
--	,[intItemId]
--	,[strBatchId]
--	,[strPostingError] -- + '[fnGRGetInvalidInvoicesForPosting]'
--FROM 
--	[dbo].[fnGRGetInvalidInvoicesForPosting](@PostInvoiceDataFromIntegration, @Post) ICC


--TM Sync
DELETE FROM @PostInvoiceDataFromIntegration
INSERT INTO
	@PostInvoiceDataFromIntegration
SELECT
	PID.*
FROM
	(SELECT [intInvoiceId], [intSiteId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN
	@Invoices PID
		ON ARID.[intInvoiceId] = PID.[intInvoiceId]
INNER JOIN
	(SELECT [intSiteID] FROM tblTMSite WITH (NOLOCK)) TMS
		ON ARID.[intSiteId] = TMS.[intSiteID]

INSERT INTO @returntable(
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError])

SELECT
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError] -- + '[fnTMGetInvalidInvoicesForSync]'
FROM 
	[dbo].[fnTMGetInvalidInvoicesForSync](@PostInvoiceDataFromIntegration, @Post)

--MFG Auto Blend
DELETE FROM @PostInvoiceDataFromIntegration
INSERT INTO @PostInvoiceDataFromIntegration(
				 [intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[strType]
				,[dtmDate]
				,[dtmPostDate]
				,[dtmShipDate]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intDeferredRevenueAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[dblInvoiceTotal]
				,[dblShipping]
				,[dblTax]
				,[strImportFormat]
				,[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]
				,[strActualCostId]
				,[intPeriodsToAccrue]
				,[ysnAccrueLicense]
				,[intSplitId]
				,[dblSplitPercent]
				,[ysnImpactInventory]
				,[ysnSplitted]
				,[intEntityId]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[intItemUOMId]
				,[intDiscountAccountId]
				,[intCustomerStorageId]
				,[intStorageScheduleTypeId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQuantity]
				,[dblMaxQuantity]
				,[strOptionType]
				,[strSourceType]
				,[strBatchId]
				,[strPostingMessage]
				,[intUserId]
				,[ysnUserAllowedToPostOtherTrans]
			)
			 SELECT DISTINCT
				 [intInvoiceId]					= PID.[intInvoiceId]
				,[strInvoiceNumber]				= PID.[strInvoiceNumber]
				,[strTransactionType]			= PID.[strTransactionType]
				,[strType]						= PID.[strType]
				,[dtmDate]						= PID.[dtmDate]
				,[dtmPostDate]					= PID.[dtmPostDate]
				,[dtmShipDate]					= ISNULL(PID.[dtmShipDate], PID.[dtmPostDate])
				,[intEntityCustomerId]			= PID.[intEntityCustomerId]
				,[intCompanyLocationId]			= PID.[intCompanyLocationId]
				,[intAccountId]					= PID.[intAccountId]
				,[intDeferredRevenueAccountId]	= PID.[intDeferredRevenueAccountId]
				,[intCurrencyId]				= PID.[intCurrencyId]
				,[intTermId]					= PID.[intTermId]
				,[dblInvoiceTotal]				= PID.[dblInvoiceTotal]
				,[dblShipping]					= PID.[dblShipping]
				,[dblTax]						= PID.[dblTax]
				,[strImportFormat]				= PID.[strImportFormat]
				,[intDistributionHeaderId]		= PID.[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]	= PID.[intLoadDistributionHeaderId]
				,[strActualCostId]				= PID.[strActualCostId]
				,[intPeriodsToAccrue]			= PID.[intPeriodsToAccrue]
				,[ysnAccrueLicense]				= PID.[ysnAccrueLicense]
				,[intSplitId]					= PID.[intSplitId]
				,[dblSplitPercent]				= PID.[dblSplitPercent]			
				,[ysnSplitted]					= PID.[ysnSplitted]
				,[ysnImpactInventory]			= PID.[ysnImpactInventory]
				,[intEntityId]					= PID.[intEntityId]
				,[ysnPost]						= @Post
				,[intInvoiceDetailId]			= ARID.[intInvoiceDetailId]
				,[intItemId]					= ARID.[intItemId]
				,[intItemUOMId]					= ARID.[intItemUOMId]
				,[intDiscountAccountId]			= PID.[intDiscountAccountId]
				,[intCustomerStorageId]			= ARID.[intCustomerStorageId]
				,[intStorageScheduleTypeId]		= ARID.[intStorageScheduleTypeId]
				,[intSubLocationId]				= NULL
				,[intStorageLocationId]			= ARID.[intStorageLocationId]
				,[dblQuantity]					= ARID.[dblQtyShipped]
				,[dblMaxQuantity]				= @ZeroDecimal
				,[strOptionType]				= ''
				,[strSourceType]				= ''
				,[strBatchId]					= PID.[strBatchId]
				,[strPostingMessage]			= ''
				,[intUserId]					= PID.[intUserId]
				,[ysnUserAllowedToPostOtherTrans]		= PID.[ysnUserAllowedToPostOtherTrans]
FROM
	(SELECT [intInvoiceId], [intInvoiceDetailId], [intItemId], [dblQtyShipped], [intItemUOMId], [intStorageScheduleTypeId], [intCustomerStorageId], [intStorageLocationId], [ysnBlended] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
INNER JOIN 
	@Invoices PID
		ON PID.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN
	(SELECT [intItemId], [ysnAutoBlend], [strType] FROM tblICItem WITH (NOLOCK)) ICI  
		ON ARID.[intItemId] = ICI.[intItemId]
INNER JOIN
	(SELECT [intItemId], [intLocationId] FROM tblICItemLocation WITH (NOLOCK)) ICIL  
		ON ARID.[intItemId] = ICIL.[intItemId]
		AND PID.[intCompanyLocationId] = ICIL.[intLocationId]
WHERE 
	ARID.[ysnBlended] <> @Post
	AND ICI.[ysnAutoBlend] = 1
	--AND ISNULL(ICI.[strType],'') = 'Finished Good' --AR-6677

INSERT INTO @returntable(
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError])
SELECT
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError] -- + '[fnMFGetInvalidInvoicesForPosting]'
FROM 
	[dbo].[fnMFGetInvalidInvoicesForPosting](@PostInvoiceDataFromIntegration, @Post)


UPDATE RT
SET RT.[strBatchId] = I.[strBatchId]
FROM
	@returntable RT
INNER JOIN
	@Invoices I
		ON RT.[intInvoiceId] = I.[intInvoiceId]
WHERE 
	LTRIM(RTRIM(ISNULL(RT.[strBatchId],''))) = ''

RETURN

END