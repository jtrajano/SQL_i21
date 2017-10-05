﻿CREATE FUNCTION [dbo].[fnARGetInvalidInvoicesForPosting]
(
	 @Invoices	[dbo].[InvoicePostingTable] Readonly
	,@Post		BIT	= 0
	,@Recap		BIT = 0
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
		INNER JOIN 
			(SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			ARI.[ysnPosted] = 1

		UNION
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


		UNION
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
			AND (I.[ysnAllowOtherUserToPost] IS NOT NULL AND I.[ysnAllowOtherUserToPost] = 1)			

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [intSiteId] FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID 
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN 
			(SELECT [intItemId], [strItemNo], [ysnTankRequired], [strType] FROM dbo.tblICItem WITH (NOLOCK)) ICI 
				ON ARID.[intItemId] = ICI.[intItemId]	
		WHERE
			ARID.[intSiteId] IS NULL
			AND I.[strType] = 'Tank Delivery'
			AND ICI.[ysnTankRequired] = 1
			AND ISNULL(ICI.[strType],'') <> 'Comment'		
		
		UNION
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
			AND ISNULL(I.[strImportFormat], '') <> 'CarQuest'		
			AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID WHERE ARID.[intInvoiceId] = I.[intInvoiceId] AND ISNULL(ARID.[intItemId], 0) <> 0)		

		UNION
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
		
		UNION
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
		INNER JOIN
			(SELECT [intEntityId], [strCustomerNumber], [ysnActive] FROM dbo.tblARCustomer WITH (NOLOCK)) ARC
				ON I.[intEntityCustomerId] = ARC.[intEntityId]						
		WHERE
			ARC.[ysnActive] = 0		
		
		
		UNION
		--UOM is required
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'UOM is required for item ' + ARID.[strItemDescription] + '.'
		FROM 
			@Invoices I	
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strItemDescription], [intItemUOMId], [intInventoryShipmentItemId], [intSalesOrderDetailId], [intLoadDetailId] FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [strType] FROM dbo.vyuICGetItemStock WITH (NOLOCK)) IST
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

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [dblDiscount] FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intDiscountAccountId] FROM dbo.vyuARGetItemAccount WITH (NOLOCK)) IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 
		LEFT OUTER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM dbo.tblICItem WITH (NOLOCK)) IT
				ON ARID.[intItemId] = IT.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM dbo.tblGLAccount WITH (NOLOCK)) GLA
				ON ISNULL(IST.[intDiscountAccountId], I.[intDiscountAccountId]) = GLA.[intAccountId]		 
		WHERE
			((ISNULL(IST.[intDiscountAccountId],0) = 0  AND  ISNULL(I.[intDiscountAccountId],0) = 0) OR GLA.[intAccountId] IS NULL)
			AND ARID.[dblDiscount] <> 0		
			AND ISNULL(IT.[strType],'') <> 'Comment'	

		UNION
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

		UNION
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


		UNION
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

		UNION
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
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA 
				ON ISNULL(I.[intAccountId], 0) = GLA.[intAccountId]		 
		WHERE
			(ISNULL(I.[intAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)

		UNION
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
		LEFT OUTER JOIN
			(SELECT [intCompanyLocationId] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId] 
		WHERE
			SMCL.[intCompanyLocationId] IS NULL


		UNION
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
		INNER JOIN
			(SELECT [intCompanyLocationId], [strLocationName], [intFreightIncome] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON SMCL.[intFreightIncome] = GLA.[intAccountId]						
		WHERE
			(ISNULL(SMCL.[intFreightIncome], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(I.[dblShipping],0) <> 0.0

		UNION
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
		INNER JOIN
			(SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON SMCL.[intUndepositedFundsId] = GLA.[intAccountId]						
					
		WHERE
			(ISNULL(SMCL.[intUndepositedFundsId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND (
				I.[strTransactionType] IN ('Cash','Cash Refund')
				OR
				(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.[intInvoiceId] = I.[intInvoiceId] AND tblARPrepaidAndCredit.[ysnApplied] = 1 AND tblARPrepaidAndCredit.[dblAppliedInvoiceDetailAmount] <> 0 ))
				)

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intServiceChargeAccountId], [intSalesAccountId], [intItemId], [dblTotal] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId] 				 
		INNER JOIN
			(SELECT [intCompanyLocationId], [strLocationName], [intSalesAccount] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON I.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON SMCL.[intSalesAccount] = GLA.[intAccountId]			
		WHERE
			(ISNULL(SMCL.[intSalesAccount], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ARID.[intServiceChargeAccountId],0) = 0
			AND ISNULL(ARID.[intSalesAccountId], 0) = 0
			AND ISNULL(ARID.[intItemId],0) = 0
			AND ARID.[dblTotal] <> @ZeroDecimal


		UNION
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


		UNION
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


		UNION
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

		UNION
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


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]	 				
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]	 				
		WHERE
			ISNULL(I.[intPeriodsToAccrue],0) > 1
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intItemId], [intGeneralAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId]
				AND ARID.[intItemId] = Acct.[intItemId] 		
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK))GLA
				ON Acct.[intGeneralAccountId] = GLA.[intAccountId]
		WHERE
			(ISNULL(Acct.[intGeneralAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') IN ('Non-Inventory','Service')
			AND ISNULL(ICI.[strType],'') <> 'Comment'


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') NOT IN ('License/Maintenance', 'Maintenance Only', 'SaaS', 'License Only')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType], [strFrequency] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') NOT IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType], [strFrequency], [dtmMaintenanceDate] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ARID.[dtmMaintenanceDate] IS NULL

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType], [strFrequency], [dtmMaintenanceDate], [dblLicenseAmount], [dblPrice] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License Only')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal) <> ISNULL(ARID.[dblPrice], @ZeroDecimal)


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType], [strFrequency], [dtmMaintenanceDate], [dblMaintenanceAmount], [dblPrice] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('Maintenance Only', 'SaaS')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) <> ISNULL(ARID.[dblPrice], @ZeroDecimal)


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType], [strFrequency], [dtmMaintenanceDate], [dblMaintenanceAmount], [dblLicenseAmount], [dblPrice] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]											
		WHERE
			ISNULL(ICI.[strType],'') = 'Software'	
			AND ISNULL(ARID.[strMaintenanceType], '') IN ('License/Maintenance')
			AND ISNULL(ARID.[strFrequency], '') IN ('Monthly', 'Bi-Monthly', 'Quarterly', 'Semi-Annually', 'Annually')
			AND ((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) + ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal)) <> ISNULL(ARID.[dblPrice], @ZeroDecimal))

		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem  WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intItemId], [intMaintenanceSalesAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON Acct.[intMaintenanceSalesAccountId] = GLA.[intAccountId]	 								
		WHERE
			(ISNULL(Acct.[intMaintenanceSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Software'	
			AND ARID.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [strMaintenanceType] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intItemId], [intGeneralAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId]
				AND ARID.[intItemId] = Acct.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON Acct.[intGeneralAccountId] = GLA.[intAccountId]	 			
		WHERE
			(ISNULL(Acct.[intGeneralAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Software'	
			AND ARID.[strMaintenanceType] IN ('License/Maintenance', 'License Only')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intOtherChargeIncomeAccountId], [intItemId] FROM vyuARGetItemAccount WITH (NOLOCK)) Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId] 		 	
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON Acct.intOtherChargeIncomeAccountId = GLA.[intAccountId]
		WHERE
			(ISNULL(Acct.[intOtherChargeIncomeAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') = 'Other Charge'

		UNION
		--Sales Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Sales Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 
			@Invoices I
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [dblTotal] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intItemId], [intSalesAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) Acct
				ON I.[intCompanyLocationId] = Acct.[intLocationId] 
				AND ARID.[intItemId] = Acct.[intItemId] 	
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON Acct.[intSalesAccountId] = GLA.[intAccountId]	
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal 
			AND (ARID.[intItemId] IS NOT NULL OR ARID.[intItemId] <> 0)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
			AND (ISNULL(Acct.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND (I.[strTransactionType] <> 'Debit Memo' OR (I.[strTransactionType] = 'Debit Memo' AND ISNULL(I.[strType],'') IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
			AND ISNULL(I.[intPeriodsToAccrue], 0) <= 1


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intSalesAccountId], [strItemDescription], [dblTotal] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ARID.[intSalesAccountId] = GLA.[intAccountId]
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal 
			AND (ISNULL(ARID.[intSalesAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] = 'Debit Memo'
			AND I.[strType] NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
			AND ISNULL(I.[intPeriodsToAccrue],0) <= 1


		UNION
		--Sales Tax Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' is not valid.' ELSE 'The Sales Tax account of Tax Code - ' + SMTC.[strTaxCode] + ' was not set.' END
		FROM 			
			(SELECT [intInvoiceDetailId], [intTaxCodeId], [intSalesTaxAccountId], [dblAdjustedTax] FROM tblARInvoiceDetailTax WITH (NOLOCK)) ARIDT
		INNER JOIN
			(SELECT [intInvoiceId], [intInvoiceDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON ARIDT.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]			
		LEFT OUTER JOIN
			(SELECT [intTaxCodeId], [intSalesTaxAccountId], [strTaxCode] FROM tblSMTaxCode WITH (NOLOCK)) SMTC
				ON ARIDT.[intTaxCodeId] = SMTC.[intTaxCodeId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]) = GLA.[intAccountId]	
		WHERE
			ARIDT.[dblAdjustedTax] <> @ZeroDecimal
			AND (ISNULL(ISNULL(ARIDT.[intSalesTaxAccountId], SMTC.[intSalesTaxAccountId]), 0) = 0 OR GLA.[intAccountId] IS NULL)


		UNION
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
			(SELECT [intInvoiceId], [intItemId], [intItemUOMId], [intInventoryShipmentItemId], [dblTotal], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]					
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		INNER JOIN
			(SELECT [intItemUOMId] FROM tblICItemUOM WITH (NOLOCK)) ItemUOM 
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intCOGSAccountId], [intLocationId], [strType] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 			
		INNER JOIN
			(SELECT [intInventoryShipmentItemId], [intInventoryShipmentId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ISD
				ON 	ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
		INNER JOIN
			(SELECT [intInventoryShipmentId], [strShipmentNumber] FROM tblICInventoryShipment WITH (NOLOCK)) ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		INNER JOIN
			(SELECT [intTransactionId], [intTransactionDetailId], [strTransactionId] FROM tblICInventoryTransaction WITH (NOLOCK)) ICT
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						 
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON IST.[intCOGSAccountId] = GLA.[intAccountId]
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND (ISNULL(IST.[intCOGSAccountId],0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] <> 'Debit Memo'

		UNION
		--Inventory In-Transit Account Account -- SHIPPED
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			(SELECT [intInvoiceId], [intItemId], intItemUOMId, [intInventoryShipmentItemId], [dblTotal], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]						  
		INNER JOIN
			(SELECT [intItemUOMId] FROM tblICItemUOM WITH (NOLOCK)) ItemUOM 
				ON ItemUOM.[intItemUOMId] = ARID.[intItemUOMId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intLocationId], [intItemId], [intInventoryInTransitAccountId], [strType] FROM vyuARGetItemAccount WITH (NOLOCK))IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND I.[intCompanyLocationId] = IST.[intLocationId] 							
		INNER JOIN
			(SELECT [intInventoryShipmentItemId], [intInventoryShipmentId] FROM tblICInventoryShipmentItem WITH (NOLOCK)) ISD
				ON 	ARID.[intInventoryShipmentItemId] = ISD.[intInventoryShipmentItemId]
		INNER JOIN
			(SELECT [intInventoryShipmentId], [strShipmentNumber] FROM tblICInventoryShipment WITH (NOLOCK)) ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		INNER JOIN
			(SELECT [intTransactionId], [intTransactionDetailId], [strTransactionId] FROM tblICInventoryTransaction WITH (NOLOCK)) ICT
				ON ISD.[intInventoryShipmentItemId] = ICT.[intTransactionDetailId] 
				AND ISH.[intInventoryShipmentId] = ICT.[intTransactionId]
				AND ISH.[strShipmentNumber] = ICT.[strTransactionId]						  
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON IST.[intInventoryInTransitAccountId] = GLA.[intAccountId]				
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND ISNULL(IST.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] <> 'Debit Memo'	
			AND (ISNULL(IST.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)


		UNION
		--COGS Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			(SELECT [intInvoiceId], [intItemId], [dblTotal], [intInventoryShipmentItemId], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID				 
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]	
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		LEFT OUTER JOIN
			(SELECT [intCOGSAccountId], [intItemId], [intLocationId] FROM vyuARGetItemAccount WITH (NOLOCK)) ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	
			
			
		UNION
		--COGS Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The COGS Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			(SELECT [intItemId], [intComponentItemId], [intItemUnitMeasureId], [intCompanyLocationId], [strType] FROM vyuARGetItemComponents WITH (NOLOCK)) ARIC
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [dblTotal], [intInventoryShipmentItemId], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON ARIC.[intItemId] = ARID.[intItemId]
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]		
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARIC.[intComponentItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intCOGSAccountId], [intItemId], [intLocationId] FROM vyuARGetItemAccount WITH (NOLOCK)) ARIA
				ON ARIC.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 	
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ARIA.[intCOGSAccountId] = GLA.[intAccountId]	 
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId],0) <> 0
			AND ISNULL(ARIC.[intComponentItemId],0) <> 0
			AND (ISNULL(ARIA.[intCOGSAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] <> 'Debit Memo'	
			AND ISNULL(ARIC.[strType],'') NOT IN ('Finished Good','Comment')			
					

		UNION
		--Inventory In-Transit Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			(SELECT [intInvoiceId], [intItemId], [dblTotal], [intInventoryShipmentItemId], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARID.[intItemId] = ICI.[intItemId] 
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intInventoryInTransitAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId] 
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId]
		WHERE
			ARID.dblTotal <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId], 0) <> 0
			AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND ISNULL(ICI.[strType],'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle','Comment')
			AND I.[strTransactionType] IN ('Invoice', 'Credit Memo', 'Credit Note')	


		UNION
		--Inventory In-Transit Account
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= CASE WHEN GLA.[intAccountId] IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.[strItemNo] + ' was not specified.' END
		FROM 			
			(SELECT [intCompanyLocationId], [intItemId], [intComponentItemId], [intItemUnitMeasureId], [strType] FROM vyuARGetItemComponents WITH (NOLOCK)) ARIC
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [dblTotal], [intInventoryShipmentItemId], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON ARIC.[intItemId] = ARID.[intItemId]
		INNER JOIN			
			@Invoices I
				ON ARID.[intInvoiceId] = I.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK)) ICI
				ON ARIC.[intComponentItemId] = ICI.[intItemId]
		LEFT OUTER JOIN
			(SELECT [intItemUOMId] FROM tblICItemUOM WITH (NOLOCK)) ICIUOM
				ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
		LEFT OUTER JOIN
			(SELECT [intInventoryInTransitAccountId], [intItemId], [intLocationId] FROM vyuARGetItemAccount WITH (NOLOCK)) ARIA
				ON ARID.[intItemId] = ARIA.[intItemId] 
				AND I.[intCompanyLocationId] = ARIA.[intLocationId]
		LEFT OUTER JOIN
			(SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK)) GLA
				ON ARIA.[intInventoryInTransitAccountId] = GLA.[intAccountId] 		 
		WHERE
			ARID.[dblTotal] <> @ZeroDecimal
			AND (ISNULL(ARID.[intInventoryShipmentItemId],0) <> 0 OR ISNULL(ARID.[intLoadDetailId],0) <> 0)
			AND ISNULL(ARID.[intItemId],0) <> 0
			AND ISNULL(ARIC.[intComponentItemId],0) <> 0
			AND (ISNULL(ARIA.[intInventoryInTransitAccountId], 0) = 0 OR GLA.[intAccountId] IS NULL)
			AND I.[strTransactionType] <> 'Debit Memo'																		
			AND ISNULL(ARIC.[strType],'') NOT IN ('Finished Good','Comment')


		UNION
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
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [intContractHeaderId], [intContractDetailId], [dblPrice], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK) WHERE strType NOT IN ('Other Charge') ) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		INNER JOIN
			(SELECT [intContractHeaderId], [intContractDetailId], [strPricingType] FROM vyuARCustomerContract WITH (NOLOCK)) CTCD
				ON ARID.[intContractHeaderId] = CTCD.[intContractHeaderId] 
				AND ARID.[intContractDetailId] = CTCD.[intContractDetailId] 
		WHERE
			ARID.[dblPrice] = @ZeroDecimal
			AND CTCD.[strPricingType] <> 'Index'
			AND ISNULL(ARID.[intLoadDetailId],0) = 0


		UNION
		--Contract Item Price not Equal to Contract Sequence Cash Price
		SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId]
			,[intItemId]			= I.[intItemId]
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'The contract item - ' + ICI.[strItemNo] + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARID.[dblPrice],@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY),2) + ').'
		FROM 					
			@Invoices I
		INNER JOIN
			(SELECT [intInvoiceId], [intItemId], [intContractHeaderId], [intContractDetailId], [dblPrice], [intLoadDetailId] FROM tblARInvoiceDetail WITH (NOLOCK)) ARID
				ON I.[intInvoiceId] = ARID.[intInvoiceId]
		INNER JOIN
			(SELECT [intItemId], [strItemNo] FROM tblICItem WITH (NOLOCK) WHERE strType NOT IN ('Other Charge')) ICI
				ON ARID.[intItemId] = ICI.[intItemId]
		INNER JOIN 
			(SELECT [intInvoiceId], intOriginalInvoiceId FROM tblARInvoice WITH (NOLOCK) WHERE intOriginalInvoiceId IS NULL) ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		INNER JOIN
			(SELECT [intContractHeaderId], [intContractDetailId], [dblCashPrice], [strPricingType] FROM vyuARCustomerContract WITH (NOLOCK)) ARCC
				ON ARID.[intContractHeaderId] = ARCC.[intContractHeaderId] 
				AND ARID.[intContractDetailId] = ARCC.[intContractDetailId] 			 				
		WHERE
			ARID.[dblPrice] <> @ZeroDecimal				
			AND CAST(ISNULL(ARCC.[dblCashPrice], @ZeroDecimal) AS MONEY) <> CAST(ISNULL(ARID.[dblPrice], @ZeroDecimal) AS MONEY)
			AND ARCC.[strPricingType] <> 'Index'
			AND ISNULL(ARID.[intLoadDetailId],0) = 0
																																			
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
		INNER JOIN 
			(SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
				ON I.[intInvoiceId] = ARI.[intInvoiceId]
		WHERE  
			ARI.[ysnPosted] = 0

		UNION
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

		UNION
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
			AND (I.[ysnAllowOtherUserToPost] IS NOT NULL AND I.[ysnAllowOtherUserToPost] = 1)			

		UNION
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
		FROM 
			(SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment WITH (NOLOCK)) ARP
		INNER JOIN 
			(SELECT [intPaymentId], [intInvoiceId] FROM tblARPaymentDetail WITH (NOLOCK)) ARPD 
				ON ARP.[intPaymentId] = ARPD.[intPaymentId]						
		INNER JOIN 
			@Invoices I
				ON ARPD.[intInvoiceId] = I.[intInvoiceId]

		UNION
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
		INNER JOIN
			(SELECT [intSourceTransactionId], [strSourceTransactionId], [intUndepositedFundId], [strSourceSystem] FROM tblCMUndepositedFund WITH (NOLOCK)) CMUF 
				ON I.[intInvoiceId] = CMUF.[intSourceTransactionId] 
				AND I.[strInvoiceNumber] = CMUF.[strSourceTransactionId]
		INNER JOIN
			(SELECT [intUndepositedFundId] FROM tblCMBankTransactionDetail WITH (NOLOCK)) CMBTD
				ON CMUF.[intUndepositedFundId] = CMBTD.[intUndepositedFundId]
		WHERE 
			CMUF.[strSourceSystem] = 'AR'
				

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
				,[ysnAllowOtherUserToPost]
			)
			 SELECT DISTINCT
				 [intInvoiceId]					= PID.[intInvoiceId]
				,[strInvoiceNumber]				= PID.[strInvoiceNumber]
				,[strTransactionType]			= PID.[strTransactionType]
				,[strType]						= PID.[strType]
				,[dtmDate]						= PID.[dtmDate]
				,[dtmPostDate]					= PID.[dtmPostDate]
				,[dtmShipDate]					= PID.[dtmShipDate]
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
				,[ysnAllowOtherUserToPost]		= PID.[ysnAllowOtherUserToPost]
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
	AND ISNULL(ICI.[strType],'') = 'Finished Good'

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
	[dbo].[fnARGetItemsForCosting](@Invoices, @Post)

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

RETURN

END
