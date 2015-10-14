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
		  , @dtmDate			DATETIME
		  , @intSplitEntityId	INT
		  , @dblSplitPercent	NUMERIC(18,6)
		  , @newInvoiceNumber	NVARCHAR(50)	
	
	SET @dtmDate = GETDATE()

	SELECT @intSplitId = intSplitId	       
	FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId

	INSERT INTO @splitDetails(intSplitDetailId, intEntityId, dblSplitPercent)
	SELECT intSplitDetailId, intEntityId, dblSplitPercent FROM tblEntitySplitDetail WHERE intSplitId = @intSplitId

	WHILE EXISTS(SELECT NULL FROM @splitDetails)
		BEGIN
			DECLARE @newInvoiceId INT
			SELECT @intSplitDetailId = NULL
			     , @newInvoiceNumber = NULL			

			SELECT TOP 1 @intSplitDetailId = intSplitDetailId FROM @splitDetails ORDER BY intSplitDetailId

			IF (SELECT COUNT(*) FROM @splitDetails) = 1
				GOTO UPDATE_CURRENT_INVOICE;

			EXEC dbo.uspARDuplicateInvoice @intInvoiceId, @dtmDate, @intUserId, @intSplitDetailId, @newInvoiceNumber OUT

			IF ISNULL(@newInvoiceNumber, '') <> ''
				BEGIN
					SELECT @newInvoiceId = intInvoiceId FROM tblARInvoice WHERE strInvoiceNumber = @newInvoiceNumber
					SELECT @invoicesToAdd = ISNULL(@invoicesToAdd, '') + CONVERT(NVARCHAR(20), @newInvoiceId) + ','					
				END

			DELETE FROM @splitDetails WHERE intSplitDetailId = @intSplitDetailId
		END

	UPDATE_CURRENT_INVOICE:
	SELECT @intSplitEntityId = intEntityId
		 , @dblSplitPercent = dblSplitPercent/100 
	FROM tblEntitySplitDetail 
	WHERE intSplitDetailId = @intSplitDetailId

	UPDATE tblARInvoice 
	SET ysnSplitted			= 1
	  , intSplitId			= NULL
	  , strInvoiceOriginId  = strInvoiceNumber
	  , intEntityCustomerId = @intSplitEntityId
	  , dblAmountDue		= dblAmountDue * @dblSplitPercent	  
	  , dblInvoiceSubtotal  = dblInvoiceSubtotal * @dblSplitPercent
	  , dblInvoiceTotal     = dblInvoiceTotal * @dblSplitPercent
	  , dblTax				= dblTax * @dblSplitPercent
	WHERE intInvoiceId = @intInvoiceId
		
	INSERT INTO @InvoiceDetails
	SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intInvoiceId

	WHILE EXISTS(SELECT NULL FROM @InvoiceDetails)
		BEGIN
			DECLARE @intInvoiceDetailId INT
			SELECT TOP 1 @intInvoiceDetailId = intInvoiceDetailId FROM @InvoiceDetails ORDER BY intInvoiceDetailId

			UPDATE tblARInvoiceDetail
			SET dblDiscount		= dblDiscount * @dblSplitPercent
			  , dblPrice		= dblPrice * @dblSplitPercent
			  , dblTotalTax	    = dblTotalTax * @dblSplitPercent
			  , dblTotal		= dblTotal * @dblSplitPercent
			  , dblQtyOrdered	= dblQtyShipped * @dblSplitPercent
			  , dblQtyShipped	= dblQtyShipped * @dblSplitPercent
			WHERE intInvoiceDetailId = @intInvoiceDetailId

			UPDATE tblARInvoiceDetailTax
			SET dblTax = dblTax * @dblSplitPercent
			  , dblAdjustedTax = dblAdjustedTax * @dblSplitPercent
			WHERE intInvoiceDetailId = @intInvoiceDetailId

			DELETE FROM @InvoiceDetails WHERE intInvoiceDetailId = @intInvoiceDetailId
		END
	
	SELECT @invoicesToAdd = ISNULL(@invoicesToAdd, '') + CONVERT(NVARCHAR(20), @intInvoiceId)	
END