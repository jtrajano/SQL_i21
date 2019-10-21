CREATE PROCEDURE [dbo].[uspARUpdateSOStatusFromInvoices]
	@InvoiceIds		InvoiceId	READONLY
AS
BEGIN
	DECLARE @InvoicesToProcess TABLE (intInvoiceId INT, ysnForDelete BIT)

	INSERT INTO @InvoicesToProcess
	SELECT intHeaderId, ISNULL(ysnForDelete, 0)
	FROM @InvoiceIds
		
	WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicesToProcess)
	BEGIN				
		DECLARE @intInvoiceId INT = NULL, @ysnForDelete BIT;
					
		SELECT TOP 1 @intInvoiceId = intInvoiceId
		           , @ysnForDelete = ysnForDelete 
		FROM @InvoicesToProcess 
		ORDER BY intInvoiceId
		
		EXEC dbo.uspSOUpdateOrderShipmentStatus @intInvoiceId, 'Invoice', @ysnForDelete
			
		DELETE FROM @InvoicesToProcess WHERE intInvoiceId = @intInvoiceId
	END 
END