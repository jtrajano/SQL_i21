﻿CREATE PROCEDURE [dbo].[uspARUpdateCustomerTotalAR]
	@InvoiceId	INT = NULL,
	@CustomerId INT = NULL
AS

DECLARE @dateFrom   DATETIME
	  , @dateTo		DATETIME
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

SET @dateFrom = CAST(-53690 AS DATETIME)
SET @dateTo = CAST(GETDATE() AS DATETIME)

INSERT INTO @temp_aging_table
EXEC uspARCustomerAgingAsOfDateReport @dateFrom, @dateTo, NULL

IF ISNULL(@CustomerId, 0) = 0 AND ISNULL(@InvoiceId, 0) > 0 --AFTER POST INVOICE
	BEGIN
		SELECT TOP 1 @CustomerId = intEntityCustomerId FROM tblARInvoice WHERE intInvoiceId = @InvoiceId

		INSERT INTO @customerTable (intEntityCustomerId, dblARBalance)
		SELECT intEntityCustomerId, dblTotalAR FROM @temp_aging_table WHERE intEntityCustomerId = @CustomerId
	END
ELSE IF ISNULL(@CustomerId, 0) > 0 AND ISNULL(@InvoiceId, 0) = 0 --AFTER POST PAYMENT
	BEGIN
		INSERT INTO @customerTable (intEntityCustomerId, dblARBalance)
		SELECT intEntityCustomerId, dblTotalAR FROM @temp_aging_table WHERE intEntityCustomerId = @CustomerId
	END
ELSE --DATAFIX FOR NEW DATABASE
	BEGIN
		INSERT INTO @customerTable (intEntityCustomerId, dblARBalance)
		SELECT intEntityCustomerId, dblTotalAR FROM @temp_aging_table
	END

IF EXISTS(SELECT NULL FROM @customerTable)
	BEGIN
		WHILE EXISTS(SELECT NULL FROM @customerTable)
			BEGIN
				DECLARE @entityCustomerId INT,
						@arBalance NUMERIC(18,6)

				SELECT TOP 1 @entityCustomerId = intEntityCustomerId
				           , @arBalance = ISNULL(dblARBalance, 0.000000) 
				FROM @customerTable ORDER BY intEntityCustomerId

				UPDATE tblARCustomer SET dblARBalance = @arBalance WHERE intEntityCustomerId = @entityCustomerId 

				DELETE FROM @customerTable WHERE intEntityCustomerId = @entityCustomerId
			END
	END