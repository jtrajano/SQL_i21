CREATE TABLE [dbo].[tblARCollectionOverdueDetail] (
	[intCounter]				INT             IDENTITY (1, 1) NOT NULL
	,intCompanyLocationId		INT
	,strCompanyName				NVARCHAR(100)
	,strCompanyAddress			NVARCHAR(MAX)
	,strCompanyPhone			NVARCHAR(100)
	,intEntityCustomerId		INT
	,strCustomerNumber			NVARCHAR(100)
	,strCustomerName			NVARCHAR(100)
	,strCustomerAddress			NVARCHAR(MAX)
	,strCustomerPhone			NVARCHAR(100)
	,strAccountNumber			NVARCHAR(100)
	,intInvoiceId				INT
	,strInvoiceNumber			NVARCHAR(100)
	,strBOLNumber				NVARCHAR(100)
	,dblCreditLimit				NUMERIC(18,6)
	,intTermId					INT
	,strTerm					NVARCHAR(100)
	,dblTotalAR					NUMERIC(18,6)
	,dblFuture					NUMERIC(18,6)
	,dbl0Days					NUMERIC(18,6)
	,dbl10Days					NUMERIC(18,6)
	,dbl30Days					NUMERIC(18,6)
	,dbl60Days					NUMERIC(18,6)
	,dbl90Days					NUMERIC(18,6)
	,dbl120Days					NUMERIC(18,6)
	,dbl121Days					NUMERIC(18,6)
	,dblTotalDue				NUMERIC(18,6)
	,dblAmountPaid				NUMERIC(18,6)
	,dblInvoiceTotal			NUMERIC(18,6)
	,dblCredits					NUMERIC(18,6)
	,dblPrepaids				NUMERIC(18,6)
	,dtmDate					DATETIME
	,dtmDueDate					DATETIME
	,[intConcurrencyId]			INT NOT NULL DEFAULT 0
)