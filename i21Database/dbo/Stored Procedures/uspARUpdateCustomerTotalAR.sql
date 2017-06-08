CREATE PROCEDURE [dbo].[uspARUpdateCustomerTotalAR]
AS

DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
	,[intEntityCustomerId]		INT
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepayments]			NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)
	,[strSourceTransaction]		NVARCHAR(100))
	
INSERT INTO @temp_aging_table(
	 [strCustomerName]			--= [strCustomerName]
	,[strEntityNo]				--= [strEntityNo]
	,[intEntityCustomerId]		--= [intEntityCustomerId]
	,[dblCreditLimit]			--= [dblCreditLimit]
	,[dblTotalAR]				--= [dblTotalAR]
	,[dblFuture]				--= [dblFuture]
	,[dbl0Days]					--= [dbl0Days]
	,[dbl10Days]				--= [dbl10Days]
	,[dbl30Days]				--= [dbl30Days]
	,[dbl60Days]				--= [dbl60Days]
	,[dbl90Days]				--= [dbl90Days]
	,[dbl91Days]				--= [dbl91Days]
	,[dblTotalDue]				--= [dblTotalDue]
	,[dblAmountPaid]			--= [dblAmountPaid]
	,[dblCredits]				--= [dblCredits]
	,[dblPrepayments]			--= [dblPrepayments]
	,[dblPrepaids]				--= [dblPrepaids]
	,[dtmAsOfDate]				--= [dtmAsOfDate]
	,[strSalespersonName]		--= [strSalespersonName]
	,[strSourceTransaction]		--= [strSourceTransaction]
)
EXEC uspARCustomerAgingAsOfDateReport NULL, NULL, NULL, NULL

UPDATE CUSTOMER
SET dblARBalance = AGING.dblTotalAR
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	INNER JOIN (SELECT intEntityCustomerId
					 , dblTotalAR = ISNULL(dblTotalAR, 0)
				FROM @temp_aging_table
	) AGING ON CUSTOMER.intEntityId = AGING.intEntityCustomerId
