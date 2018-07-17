print('/*******************  BEGIN Update tblARInvoice Service Charge Starting Numbers  *******************/')
GO

DECLARE @invoicesToUpdate		TABLE(intInvoiceId INT, strInvoiceNumber NVARCHAR(50))
DECLARE @intStartingNumberId	INT
      , @InvoiceNumber			NVARCHAR(50)
      , @intInvoiceId			INT	  
SET @intStartingNumberId = (SELECT TOP 1 intStartingNumberId FROM tblSMStartingNumber WHERE strTransactionType = 'Service Charge')

INSERT INTO @invoicesToUpdate
SELECT intInvoiceId
	 , strInvoiceNumber
FROM tblARInvoice 
WHERE strTransactionType = 'Invoice' 
  AND strType = 'Service Charge' 
  AND SUBSTRING(strInvoiceNumber, 0, 3) = 'SI'

IF EXISTS(SELECT NULL FROM @invoicesToUpdate) AND ISNULL(@intStartingNumberId, 0) > 0
	BEGIN
		WHILE EXISTS(SELECT NULL FROM @invoicesToUpdate)
			BEGIN
				SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @invoicesToUpdate ORDER BY intInvoiceId

				EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT

				UPDATE tblARInvoice SET strInvoiceNumber = @InvoiceNumber  WHERE intInvoiceId = @intInvoiceId
				
				DELETE FROM @invoicesToUpdate WHERE intInvoiceId = @intInvoiceId
			END
	END
	
GO
print('/*******************  END Update tblARInvoice Service Charge Starting Numbers  *******************/')