CREATE PROCEDURE [dbo].[uspARInterCompanyIntegrationSource]
	 @BatchId		NVARCHAR(40)
	,@Post			BIT = 0
	,@raiseError	BIT = 1
	,@strSessionId	NVARCHAR(50) = NULL
AS
	DECLARE @strDatabaseName NVARCHAR(50)
	DECLARE @strInvoiceNumber NVARCHAR(50)
	DECLARE @strBatchId NVARCHAR(50)
	DECLARE @ysnPosted BIT
	DECLARE @intInvoiceId INT = 0

	SELECT @strDatabaseName = strDatabaseName, @strInvoiceNumber = strInvoiceNumber
	FROM tblARPostInvoiceHeader I
	INNER JOIN tblARCustomer C ON I.intEntityCustomerId = C.intEntityId
	INNER JOIN tblSMInterCompany IC ON C.intInterCompanyId = IC.intInterCompanyId
	WHERE I.strTransactionType = 'Invoice'
	  AND I.strSessionId = @strSessionId

	IF(ISNULL(@strDatabaseName, '') <> '')
	BEGIN
		DECLARE @sqlInsertInventoryReceiptStaging NVARCHAR(MAX) = 
			'
			DECLARE @ReceiptNumber nvarchar(15)

			INSERT INTO [' + @strDatabaseName + '].[dbo].[tblARInventoryReceiptStaging]
				([intInvoiceId]
				,[strInvoiceNumber]
				,[intVendorId]
				,[intCompanyLocationId]
				,[strItemNo]
				,[dtmDate]
				,[dblExchangeRate]
				,[dblQty]
				,[dblCost],
				[strTaxGroup],
				[strFreightTerm]) 
			SELECT 
				 [intInvoiceId]			= ARI.intInvoiceId
				,[strInvoiceNumber]		= ARI.strInvoiceNumber
				,[intVendorId]			= ARC.intInterCompanyVendorId
				,[intCompanyLocationId]	= ARC.intInterCompanyLocationId
				,[strItemNo]			= ICI.strItemNo
				,[dtmDate]				= ARI.dtmDate
				,[dblExchangeRate]		= ARI.dblCurrencyExchangeRate
				,[dblQty]				= ARID.dblQtyShipped
				,[dblCost]				= ARID.dblPrice
				,[strTaxGroup]			= SMTG.strTaxGroup
				,[strFreightTerm]		= SMFT.strFreightTerm
			FROM 
				tblARInvoice ARI
			INNER JOIN tblARInvoiceDetail ARID
				ON ARI.intInvoiceId = ARID.intInvoiceId
			INNER JOIN tblICItem ICI
				ON ARID.intItemId = ICI.intItemId
			INNER JOIN tblARCustomer ARC
				ON ARI.intEntityCustomerId = ARC.intEntityId
			INNER JOIN tblSMFreightTerms SMFT
				ON ARI.intFreightTermId = SMFT.intFreightTermId
			LEFT JOIN tblARInvoiceDetailTax ARIDT
				ON ARID.intInvoiceDetailId = ARIDT.intInvoiceDetailId
			LEFT JOIN tblSMTaxGroup SMTG
				ON ARIDT.intTaxGroupId = SMTG.intTaxGroupId
			WHERE 
				strInvoiceNumber = ''' + @strInvoiceNumber + '''
			GROUP BY 
				 ARI.intInvoiceId
				,ARI.strInvoiceNumber
				,ARC.intInterCompanyVendorId
				,ARC.intInterCompanyLocationId
				,ICI.strItemNo
				,ARI.dtmDate
				,ARI.dblCurrencyExchangeRate
				,ARID.dblQtyShipped
				,ARID.dblPrice
				,SMTG.strTaxGroup
				,SMFT.strFreightTerm
		
			EXEC [' + @strDatabaseName + '].[dbo].[uspARInterCompanyIntegrationDestination] @InvoiceNumber = ''' + @strInvoiceNumber + ''', @BatchId = ''' + ISNULL(@BatchId, '') +''', @Post = ' + CAST(@Post AS NVARCHAR(1))+ ', @UserId = 1, @ReceiptNumber = @ReceiptNumber OUTPUT
		
			SELECT @strReceiptNumber = @ReceiptNumber'

		DECLARE @strReceiptNumber nvarchar(15);
		DECLARE @strReceiptNumberParam nvarchar(500);
		SET @strReceiptNumberParam = N'@strReceiptNumber NVARCHAR(15) OUTPUT';

		EXEC sp_executesql @sqlInsertInventoryReceiptStaging, @strReceiptNumberParam, @strReceiptNumber = @strReceiptNumber OUTPUT
	
		UPDATE tblARInvoice
		SET ysnInterCompany = 1, strReceiptNumber = @strReceiptNumber
		WHERE strInvoiceNumber = @strInvoiceNumber
	END
RETURN 0