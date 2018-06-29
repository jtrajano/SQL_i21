CREATE TRIGGER trgARInvoiceNumber
ON dbo.tblARInvoice
AFTER INSERT
AS

DECLARE @inserted TABLE(intInvoiceId INT, strTransactionType NVARCHAR(25), strType NVARCHAR(100), intCompanyLocationId INT)
DECLARE @count INT = 0
DECLARE @intInvoiceId INT
DECLARE @intCompanyLocationId INT
DECLARE @InvoiceNumber NVARCHAR(50)
DECLARE @strTransactionType NVARCHAR(25)
DECLARE @strType NVARCHAR(100)
DECLARE @intMaxCount INT = 0
DECLARE @intStartingNumberId INT = 0

INSERT INTO @inserted
SELECT intInvoiceId, strTransactionType, strType, intCompanyLocationId FROM INSERTED WHERE strInvoiceNumber IS NULL ORDER BY intInvoiceId

WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
BEGIN
	SET @intStartingNumberId = 19
	
	SELECT TOP 1 @intInvoiceId = intInvoiceId, @strTransactionType = strTransactionType, @strType = strType, @intCompanyLocationId = intCompanyLocationId FROM @inserted

	SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = CASE WHEN @strTransactionType = 'Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Customer Prepayment' THEN 'Customer Prepayment' 
									WHEN @strTransactionType = 'Overpayment' THEN 'Customer Overpayment'
									WHEN @strTransactionType = 'Invoice' AND @strType = 'Service Charge' THEN 'Service Charge'
									WHEN @strTransactionType = 'Invoice' AND @strType = 'Provisional' THEN 'Provisional'
									WHEN @strTransactionType = 'Credit Note' THEN 'Credit Note' 
									ELSE 'Invoice' END
		
	EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT, @intCompanyLocationId
	
	IF(@InvoiceNumber IS NOT NULL)
	BEGIN
		IF EXISTS (SELECT NULL FROM tblARInvoice WHERE strInvoiceNumber = @InvoiceNumber)
			BEGIN
				SET @InvoiceNumber = NULL
				DECLARE @intStartIndex INT = 4
				IF (@strTransactionType = 'Prepayment' OR @strTransactionType = 'Customer Prepayment') OR @strTransactionType = 'Overpayment'
					SET @intStartIndex = 5
				
				SELECT @intMaxCount = MAX(CONVERT(INT, SUBSTRING(strInvoiceNumber, @intStartIndex, 10))) FROM tblARInvoice WHERE strTransactionType = @strTransactionType

				UPDATE tblSMStartingNumber SET intNumber = @intMaxCount + 1 WHERE intStartingNumberId = @intStartingNumberId
				EXEC uspSMGetStartingNumber @intStartingNumberId, @InvoiceNumber OUT, @intCompanyLocationId			
			END

		UPDATE tblARInvoice
			SET tblARInvoice.strInvoiceNumber = @InvoiceNumber
		FROM tblARInvoice A
		WHERE A.intInvoiceId = @intInvoiceId
	END

	DELETE FROM @inserted
	WHERE intInvoiceId = @intInvoiceId

END
GO