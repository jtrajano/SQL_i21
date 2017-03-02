CREATE TABLE [dbo].[tblARCollectionOverdueDetail] (
	[intCounter]				INT             IDENTITY (1, 1) NOT NULL
	,[intCompanyLocationId]		INT
	,[strCompanyName]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strCompanyAddress]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS
	,[strCompanyPhone]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]		INT
	,[strCustomerNumber]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strCustomerName]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strCustomerAddress]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS
	,[strCustomerPhone]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strAccountNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intInvoiceId]				INT
	,[strInvoiceNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strBOLNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[dblCreditLimit]			NUMERIC(18,6)	
	,[intTermId]				INT
	,[strTerm]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl120Days]				NUMERIC(18,6)
	,[dbl121Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblInvoiceTotal]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmDate]					DATETIME
	,[dtmDueDate]				DATETIME
	,[intConcurrencyId]			INT NOT NULL	DEFAULT 0
	)

GO

CREATE NONCLUSTERED INDEX [PIndex1]
ON [dbo].[tblARCollectionOverdueDetail] ([intEntityCustomerId])
INCLUDE ([intCompanyLocationId],[strCompanyName],[strCompanyAddress],[strCompanyPhone],[strCustomerNumber],[strCustomerName],[strCustomerAddress],[strCustomerPhone],[strAccountNumber],[intInvoiceId],[strInvoiceNumber],[strBOLNumber],[dblCreditLimit],[intTermId],[strTerm],[dblTotalAR],[dblFuture],[dbl0Days],[dbl10Days],[dbl30Days],[dbl60Days],[dbl90Days],[dbl120Days],[dbl121Days],[dblTotalDue],[dblAmountPaid],[dblInvoiceTotal],[dblCredits],[dblPrepaids],[dtmDate],[dtmDueDate])