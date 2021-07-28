CREATE PROCEDURE [dbo].[uspARInvoiceGrossMarginSummary]
	@ysnRebuild				BIT = 0,
	@InvoiceId				InvoiceId	READONLY    
AS
IF ISNULL(@ysnRebuild, 0) = 1
	BEGIN
		TRUNCATE TABLE tblARInvoiceGrossMarginSummary
		INSERT INTO tblARInvoiceGrossMarginSummary (
			  strType
			, intInvoiceId
			, dblAmount
			, dtmDate
			, intConcurrencyId
		)
		SELECT strType				= strType 
		     , intInvoiceId			= intInvoiceId
			 , dblAmount			= SUM(dblAmount)
			 , dtmDate				= dtmDate
			 , intConcurrencyId		= 1  
		FROM vyuARInvoiceGrossMargin 
		GROUP BY intInvoiceId
		       , strType
			   , dtmDate
	END
ELSE
BEGIN
	DECLARE @InvoiceMarginSummary TABLE (
		  intInvoiceId	INT
		, strType		NVARCHAR(100)
		, dblAmount		NUMERIC(18, 6)
		, dtmDate		DATETIME
	)
	
	INSERT INTO @InvoiceMarginSummary (
		  intInvoiceId
		, strType
		, dblAmount
		, dtmDate
	)
	EXEC dbo.uspARInvoiceGrossMargin @InvoiceId

    INSERT INTO tblARInvoiceGrossMarginSummary (
		  strType
		, intInvoiceId
		, dblAmount
		, dtmDate
		, intConcurrencyId
	)
    SELECT strType
		, intInvoiceId
		, dblAmount
		, dtmDate
		, intConcurrencyId	= 1
	FROM @InvoiceMarginSummary
END