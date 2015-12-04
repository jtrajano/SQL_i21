print('/*******************  BEGIN Update NULL dblQtyShipped in tblSOSalesOrderDetail with zero  *******************/')
GO

DECLARE @customerTable TABLE(intEntityCustomerId INT, dblARBalance NUMERIC(18,6))
DECLARE @temp_aging_table TABLE(	
	 [strCustomerName]			NVARCHAR(100)
	,[strEntityNo]				NVARCHAR(100)
	,[intEntityCustomerId]		INT
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl91Days]				NUMERIC(18,6)
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100))
DECLARE @dateFrom   DATETIME
	  , @dateTo		DATETIME

SET @dateFrom = CAST(-53690 AS DATETIME)
SET @dateTo = CAST(GETDATE() AS DATETIME)

INSERT INTO @temp_aging_table
EXEC uspARCustomerAgingAsOfDateReport @dateFrom, @dateTo, NULL

INSERT INTO @customerTable (intEntityCustomerId, dblARBalance)
SELECT intEntityCustomerId, dblTotalAR FROM @temp_aging_table

SELECT * FROM @customerTable

WHILE EXISTS(SELECT NULL FROM @customerTable)
	BEGIN
		DECLARE @customerId INT,
		        @arBalance NUMERIC(18,6)

		SELECT TOP 1 @customerId = intEntityCustomerId, @arBalance = dblARBalance FROM @customerTable ORDER BY intEntityCustomerId

		UPDATE tblARCustomer SET dblARBalance = @arBalance WHERE intEntityCustomerId = @customerId 

		DELETE FROM @customerTable WHERE intEntityCustomerId = @customerId
	END

print('/*******************  END Update tblARCustomer Total AR Balance  *******************/')
GO