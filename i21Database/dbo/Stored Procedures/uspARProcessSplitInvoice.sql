CREATE PROCEDURE [dbo].[uspARProcessSplitInvoice]
	@intInvoiceId		INT,
	@intUserId			INT,
	@invoicesToAdd		NVARCHAR(MAX) = NULL OUTPUT
AS

BEGIN
	DECLARE @InvoiceDetails TABLE(intInvoiceDetailId INT)
	DECLARE @splitDetails TABLE(intSplitId INT, intSplitDetailId INT, intEntityId INT, dblSplitPercent NUMERIC(18,6))
	DECLARE @intSplitId			INT
	      , @intSplitDetailId	INT
		  , @dtmDate			DATETIME = GETDATE()
		  , @intSplitEntityId	INT
		  , @dblSplitPercent	NUMERIC(18,6)
		  , @newInvoiceNumber	NVARCHAR(50)	
		  , @newTermId			INT
		  , @newShipToId		INT
		  , @newBillToId		INT
		  , @customerId			INT

	SELECT @intSplitId = intSplitId
		 , @customerId = intEntityCustomerId
	FROM dbo.tblARInvoice 
	WHERE intInvoiceId = @intInvoiceId

	INSERT INTO @splitDetails(intSplitDetailId, intEntityId, dblSplitPercent)
	SELECT EMESD.intSplitDetailId
		 , EMESD.intEntityId
		 , EMESD.dblSplitPercent
	FROM dbo.tblEMEntitySplitDetail EMESD
	INNER JOIN dbo.tblARCustomer ARC
			ON EMESD.[intEntityId] = ARC.[intEntityId] 
	WHERE EMESD.intSplitId = @intSplitId

	WHILE EXISTS(SELECT NULL FROM @splitDetails)
		BEGIN
			DECLARE @newInvoiceId	INT = NULL
				  , @newCustomerId	INT = NULL
			
			SELECT TOP 1 @intSplitDetailId = intSplitDetailId FROM @splitDetails WHERE intEntityId <> @customerId ORDER BY intSplitDetailId

			IF (SELECT COUNT(*) FROM @splitDetails) = 1
				BEGIN
					SELECT TOP 1 @intSplitDetailId = intSplitDetailId FROM @splitDetails ORDER BY intSplitDetailId
					GOTO UPDATE_CURRENT_INVOICE;
				END

			EXEC dbo.uspARSplitInvoice @intInvoiceId, @dtmDate, @intUserId, @intSplitDetailId, @newInvoiceNumber OUT

			IF ISNULL(@newInvoiceNumber, '') <> ''
				BEGIN
					SELECT @newInvoiceId	= intInvoiceId
					     , @newCustomerId	= intEntityCustomerId 
					FROM tblARInvoice 
					WHERE strInvoiceNumber = @newInvoiceNumber

					SELECT @newShipToId = intShipToId
					     , @newBillToId = intBillToId
						 , @newTermId	= intTermsId 
					FROM vyuARCustomerSearch 
					WHERE [intEntityId] = @newCustomerId

					UPDATE tblARInvoice
					SET intShipToLocationId	= @newShipToId
					  , intBillToLocationId	= @newBillToId
					  , intTermId			= @newTermId
					  , dtmDueDate			= dbo.fnGetDueDateBasedOnTerm(dtmDate, @newTermId)
					WHERE intInvoiceId = @newInvoiceId

					SELECT @invoicesToAdd = ISNULL(@invoicesToAdd, '') + CONVERT(NVARCHAR(20), @newInvoiceId) + ','					
				END

			DELETE FROM @splitDetails WHERE intSplitDetailId = @intSplitDetailId
		END

	UPDATE_CURRENT_INVOICE:
	SELECT @intSplitEntityId = intEntityId
		 , @dblSplitPercent = dblSplitPercent/100 
	FROM [tblEMEntitySplitDetail] 
	WHERE intSplitDetailId = @intSplitDetailId

	SELECT @newShipToId = intShipToId
		 , @newBillToId = intBillToId
		 , @newTermId	= intTermsId 
	FROM vyuARCustomerSearch 
	WHERE [intEntityId] = @intSplitEntityId

	UPDATE tblARInvoice 
	SET ysnSplitted			= 1
	  , intSplitId			= intSplitId
	  , strInvoiceOriginId  = strInvoiceNumber
	  , intEntityCustomerId = @intSplitEntityId
	  , intShipToLocationId	= @newShipToId
	  , intBillToLocationId	= @newBillToId
	  , intTermId			= @newTermId
	  , dtmDueDate			= dbo.fnGetDueDateBasedOnTerm(dtmDate, @newTermId)
	  , dblAmountDue		= dblAmountDue * @dblSplitPercent	  
	  , dblInvoiceSubtotal  = dblInvoiceSubtotal * @dblSplitPercent
	  , dblInvoiceTotal     = dblInvoiceTotal * @dblSplitPercent
	  , dblTax				= dblTax * @dblSplitPercent
	  , dblSplitPercent     = ISNULL(@dblSplitPercent, 1)
	WHERE ISNULL(@intSplitEntityId, 0) <> 0 
	AND intInvoiceId = @intInvoiceId
		
	INSERT INTO @InvoiceDetails
	SELECT intInvoiceDetailId 
	FROM tblARInvoiceDetail 
	WHERE ISNULL(@intSplitEntityId, 0) <> 0 
	  AND intInvoiceId = @intInvoiceId 

	DECLARE @TransactionType NVARCHAR(20)
	
	SELECT TOP 1 @TransactionType = strTransactionType 
	FROM dbo.tblARInvoice 
	WHERE ISNULL(@intSplitEntityId, 0) <> 0 
	  AND intInvoiceId = @intInvoiceId

	WHILE EXISTS(SELECT NULL FROM @InvoiceDetails)
		BEGIN
			DECLARE @intInvoiceDetailId INT
			SELECT TOP 1 @intInvoiceDetailId = intInvoiceDetailId FROM @InvoiceDetails ORDER BY intInvoiceDetailId

			UPDATE tblARInvoiceDetail
			SET dblDiscount		= dblDiscount
			  , dblTotalTax	    = dblTotalTax * @dblSplitPercent
			  , dblTotal		= dblTotal * @dblSplitPercent
			  , dblQtyOrdered	= (CASE WHEN  @TransactionType='Invoice' 
										AND ((intInventoryShipmentItemId is not null OR intSalesOrderDetailId is not null) 
										OR (intInventoryShipmentItemId is null OR intSalesOrderDetailId is null))
			                            THEN dblQtyShipped * @dblSplitPercent  ELSE 0 END)
			  , dblQtyShipped	= dblQtyShipped * @dblSplitPercent
			WHERE intInvoiceDetailId = @intInvoiceDetailId
				
			UPDATE tblARInvoiceDetailTax
			SET dblTax = dblTax * @dblSplitPercent
			  , dblAdjustedTax = dblAdjustedTax * @dblSplitPercent
			WHERE intInvoiceDetailId = @intInvoiceDetailId

			DELETE FROM @InvoiceDetails WHERE intInvoiceDetailId = @intInvoiceDetailId
		END
	
	SELECT @invoicesToAdd = ISNULL(@invoicesToAdd, '') + CONVERT(NVARCHAR(20), @intInvoiceId)	

	EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId

	DECLARE @AddedInvoices AS [dbo].[Id]
	INSERT INTO @AddedInvoices([intId])
	SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd)

	WHILE EXISTS(SELECT NULL FROM @AddedInvoices)
		BEGIN
			DECLARE @AddedInvoiceId INT

			SELECT TOP 1 @AddedInvoiceId = [intId] FROM @AddedInvoices

			EXEC dbo.uspARReComputeInvoiceTaxes @AddedInvoiceId

			DELETE FROM @AddedInvoices WHERE [intId] = @AddedInvoiceId
		END
END