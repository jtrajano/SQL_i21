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
    INSERT INTO tblARInvoiceGrossMarginSummary (
		  strType
		, intInvoiceId
		, dblAmount
		, dtmDate
		, intConcurrencyId
	)
    SELECT strType				= IGM.strType 
	    , intInvoiceId			= IGM.intInvoiceId
		, dblAmount				= SUM(IGM.dblAmount) * CASE WHEN II.ysnPost = 1 THEN 1 ELSE - 1 END
		, dtmDate				= CASE WHEN II.ysnPost = 1 THEN IGM.dtmDate ELSE '01-01-1900'END
		, intConcurrencyId		= 1  
	FROM vyuARInvoiceGrossMargin IGM
	INNER JOIN @InvoiceId II ON IGM.intInvoiceId = II.intHeaderId
	GROUP BY IGM.strType
		   , IGM.dtmDate
		   , IGM.intInvoiceId       
		   , II.ysnPost
END