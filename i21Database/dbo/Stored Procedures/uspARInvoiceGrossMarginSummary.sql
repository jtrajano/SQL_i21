CREATE PROCEDURE [dbo].[uspARInvoiceGrossMarginSummary]
	@ysnRebuild				BIT = 0,
	@InvoiceId				InvoiceId	READONLY    
AS
IF ISNULL(@ysnRebuild, 0) = 1
	BEGIN
		TRUNCATE TABLE tblARInvoiceGrossMarginSummary
		
		INSERT INTO tblARInvoiceGrossMarginSummary WITH (TABLOCK) (
			  strType
			, intInvoiceId
			, dblAmount
			, dtmDate
			, intConcurrencyId
		)
		SELECT strType			= 'Revenue'
			, intIntInvoiceId	= SAR.intTransactionId
			, dblAmount			= SUM(SAR.dblLineTotal)
			, dtmDate			= SAR.dtmDate
			, intConcurrencyId	= 1
		FROM tblARSalesAnalysisStagingReport SAR 
		GROUP BY SAR.intTransactionId, SAR.dtmDate

		UNION ALL

		SELECT strType			= 'Net'
			, intIntInvoiceId	= SAR.intTransactionId
			, dblAmount			= SUM(SAR.dblMargin)
			, dtmDate			= SAR.dtmDate
			, intConcurrencyId	= 1
		FROM tblARSalesAnalysisStagingReport SAR 
		GROUP BY SAR.intTransactionId, SAR.dtmDate

		UNION ALL

		SELECT strType			= 'Expense'
			, intIntInvoiceId	= SAR.intTransactionId
			, dblAmount			= SUM(SAR.dblTotalCost)
			, dtmDate			= SAR.dtmDate
			, intConcurrencyId	= 1
		FROM tblARSalesAnalysisStagingReport SAR 
		GROUP BY SAR.intTransactionId, SAR.dtmDate
	END
ELSE
BEGIN
    INSERT INTO tblARInvoiceGrossMarginSummary WITH (TABLOCK) (
		  strType
		, intInvoiceId
		, dblAmount
		, dtmDate
		, intConcurrencyId
	)
    SELECT strType			= 'Revenue'
		, intIntInvoiceId	= SAR.intTransactionId
		, dblAmount			= SUM(SAR.dblLineTotal)
		, dtmDate			= SAR.dtmDate
		, intConcurrencyId	= 1
	FROM tblARSalesAnalysisStagingReport SAR 
	INNER JOIN @InvoiceId II ON SAR.intTransactionId = II.intHeaderId
	GROUP BY SAR.intTransactionId, SAR.dtmDate

	UNION ALL

	SELECT strType			= 'Net'
		, intIntInvoiceId	= SAR.intTransactionId
		, dblAmount			= SUM(SAR.dblMargin)
		, dtmDate			= SAR.dtmDate
		, intConcurrencyId	= 1
	FROM tblARSalesAnalysisStagingReport SAR 
	INNER JOIN @InvoiceId II ON SAR.intTransactionId = II.intHeaderId
	GROUP BY SAR.intTransactionId, SAR.dtmDate

	UNION ALL

	SELECT strType			= 'Expense'
		, intIntInvoiceId	= SAR.intTransactionId
		, dblAmount			= SUM(SAR.dblTotalCost)
		, dtmDate			= SAR.dtmDate
		, intConcurrencyId	= 1
	FROM tblARSalesAnalysisStagingReport SAR 
	INNER JOIN @InvoiceId II ON SAR.intTransactionId = II.intHeaderId
	GROUP BY SAR.intTransactionId, SAR.dtmDate
END