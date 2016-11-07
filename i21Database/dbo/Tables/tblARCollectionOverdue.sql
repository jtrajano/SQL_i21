CREATE TABLE [dbo].[tblARCollectionOverdue] (	
	[intCounter]				INT             IDENTITY (1, 1) NOT NULL
	,[intEntityCustomerId]		INT	
	,[dblCreditLimitSum]		NUMERIC(18,6)	
	,[dblTotalARSum]			NUMERIC(18,6)
	,[dblFutureSum]				NUMERIC(18,6)
	,[dbl0DaysSum]				NUMERIC(18,6)
	,[dbl10DaysSum]				NUMERIC(18,6)
	,[dbl30DaysSum]				NUMERIC(18,6)
	,[dbl60DaysSum]				NUMERIC(18,6)
	,[dbl90DaysSum]				NUMERIC(18,6)
	,[dbl120DaysSum]			NUMERIC(18,6)
	,[dbl121DaysSum]			NUMERIC(18,6)
	,[dblTotalDueSum]			NUMERIC(18,6)
	,[dblAmountPaidSum]			NUMERIC(18,6)
	,[dblInvoiceTotalSum]		NUMERIC(18,6)
	,[dblCreditsSum]			NUMERIC(18,6)
	,[dblPrepaidsSum]			NUMERIC(18,6)
	,[intConcurrencyId]			INT NOT NULL	DEFAULT 0
)