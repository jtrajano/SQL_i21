--print('/*******************  BEGIN Update AR/SO Transaction account IDs  *******************/')
--GO

--IF EXISTS(SELECT NULL FROM tblARCompanyPreference WHERE ISNULL([ysnLineItemAccountUpdate],0) = 0)
--BEGIN
--	DECLARE @ZeroDecimal DECIMAL(18,6)
--	SET @ZeroDecimal = 0.000000	
		
--	DECLARE @DetailIds AS TABLE(
--		 [intDetailId]			INT
--		,[intId]				INT
--		,[strTransactionNumber]	NVARCHAR(200)
--		,[strTransactionType]	NVARCHAR(200)
--		,[strSoftwareType]		NVARCHAR(200)
--	)
--	--Invoice
--	INSERT INTO @DetailIds(
--		 [intDetailId]
--		,[intId]
--		,[strTransactionNumber]
--		,[strTransactionType]
--		,[strSoftwareType]
--	)
--	SELECT
--		 [intDetailId]			= ARID.[intInvoiceDetailId]
--		,[intId]				= ARI.[intInvoiceId] 
--		,[strTransactionNumber]	= ARI.[strInvoiceNumber]
--		,[strTransactionType]	= ARI.[strTransactionType]
--		,[strSoftwareType]		= CASE WHEN ARID.strMaintenanceType IN ('Maintenance Only','SaaS') THEN 'Maintenance' 
--									   WHEN ARID.strMaintenanceType IN ('License Only') THEN 'License' 
--									   WHEN ARID.strMaintenanceType IN ('License/Maintenance') THEN 'Both' 
--									   ELSE ''
--								  END
--	FROM
--		tblARInvoiceDetail ARID
--	INNER JOIN
--		tblARInvoice ARI
--			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
--	WHERE
--		ISNULL(ARI.[ysnPosted],0) = 1
		
--	WHILE EXISTS(SELECT TOP 1 NULL FROM @DetailIds)
--	BEGIN
--		DECLARE @InvoiceDetailId	INT
--				,@InvoiceId			INT
--				,@InvoiceNumber		NVARCHAR(200)
--				,@TransactionType	NVARCHAR(200)
--				,@SoftWareItemType	NVARCHAR(200)
--				,@AccountId			INT
--				,@LicenseAccount	INT
--				,@MaintAccount		INT
				
--		SELECT TOP 1
--			@InvoiceDetailId	= [intDetailId]
--			,@InvoiceId			= [intId]
--			,@InvoiceNumber		= [strTransactionNumber]
--			,@TransactionType	= [strTransactionType]
--			,@SoftWareItemType	= [strSoftwareType]
--		FROM 
--			@DetailIds
--		ORDER BY [intDetailId]
		
--		SELECT TOP 1
--			@AccountId = GLD.[intAccountId]
--		FROM
--			tblGLDetail GLD
--		WHERE
--			GLD.[intJournalLineNo] = @InvoiceDetailId
--			AND ISNULL(GLD.[ysnIsUnposted],0) = 0
--			AND GLD.[intTransactionId] = @InvoiceId
--			AND GLD.[strTransactionId] = @InvoiceNumber
--			AND GLD.[strCode] = 'AR'
--			AND (
--					(GLD.dblCredit > @ZeroDecimal AND @TransactionType IN ('Invoice', 'Cash'))
--				OR
--					(GLD.dblDebit > @ZeroDecimal AND @TransactionType NOT IN ('Invoice', 'Cash'))
--				)
--			AND RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) = ''
--		ORDER BY
--			GLD.dtmDate 
				
				
--		SELECT TOP 1
--			@MaintAccount = GLD.[intAccountId]
--		FROM
--			tblGLDetail GLD
--		WHERE
--			GLD.[intJournalLineNo] = @InvoiceDetailId
--			AND ISNULL(GLD.[ysnIsUnposted],0) = 0
--			AND GLD.[intTransactionId] = @InvoiceId
--			AND GLD.[strTransactionId] = @InvoiceNumber
--			AND GLD.[strCode] = 'AR'
--			AND (
--					(GLD.dblCredit > @ZeroDecimal AND @TransactionType IN ('Invoice', 'Cash'))
--				OR
--					(GLD.dblDebit > @ZeroDecimal AND @TransactionType NOT IN ('Invoice', 'Cash'))
--				)
--			AND (
--				RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) IN ('Maintenance', 'Both')
--				AND
--				EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'Maintenance Sales')
--				)
--		ORDER BY
--			GLD.dtmDate 
				
--		SELECT TOP 1
--			@LicenseAccount = GLD.[intAccountId]
--		FROM
--			tblGLDetail GLD
--		WHERE
--			GLD.[intJournalLineNo] = @InvoiceDetailId
--			AND ISNULL(GLD.[ysnIsUnposted],0) = 0
--			AND GLD.[intTransactionId] = @InvoiceId
--			AND GLD.[strTransactionId] = @InvoiceNumber
--			AND GLD.[strCode] = 'AR'
--			AND (
--					(GLD.dblCredit > @ZeroDecimal AND @TransactionType IN ('Invoice', 'Cash'))
--				OR
--					(GLD.dblDebit > @ZeroDecimal AND @TransactionType NOT IN ('Invoice', 'Cash'))
--				)
--			AND (
--					RTRIM(LTRIM(ISNULL(@SoftWareItemType, ''))) IN ('License', 'Both')
--				AND
--					(
--						EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'General')
--					OR
--						EXISTS(SELECT NULL FROM vyuGLAccountDetail GLAD WHERE GLAD.[intAccountId] = GLD.[intAccountId] AND GLAD.[strAccountCategory] = 'Sales Account')
--					)
--				)
--		ORDER BY
--			GLD.dtmDate 			
				
--		UPDATE tblARInvoiceDetail
--		SET
--			 intAccountId			 = ISNULL(@AccountId, intAccountId)
--			,intLicenseAccountId	 = ISNULL(@LicenseAccount, intLicenseAccountId)
--			,intMaintenanceAccountId = ISNULL(@MaintAccount, intMaintenanceAccountId)
--		WHERE
--			[intInvoiceDetailId] = @InvoiceDetailId
		
--		DELETE FROM @DetailIds WHERE [intDetailId] = @InvoiceDetailId
--	END
	
	
--	--Sales Order
--	DECLARE @SalesOrderIds Id
--	INSERT INTO @SalesOrderIds(
--		[intId] 
--	)
--	SELECT
--		 [intId]				= SO.[intSalesOrderId] 	
--	FROM
--		tblSOSalesOrder SO			
--	WHERE
--		SO.[strTransactionType] = 'Order'
		
--	EXEC dbo.[uspARUpdateTransactionAccounts] @Ids = @SalesOrderIds, @TransactionType	= 2
	
	
	
--	UPDATE tblARCompanyPreference SET ysnLineItemAccountUpdate = 1
	
--END




--GO
--print('/*******************  END Update AR/SO Transaction account IDs  *******************/')