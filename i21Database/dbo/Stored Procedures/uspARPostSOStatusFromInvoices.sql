CREATE PROCEDURE [dbo].[uspARPostSOStatusFromInvoices]
	@InvoiceIds		InvoiceId	READONLY
AS
BEGIN	
	DECLARE @InvoiceToUpdate TABLE (intInvoiceId INT, ysnForDelete BIT, ysnProcessed BIT);

	INSERT INTO @InvoiceToUpdate(intInvoiceId, ysnForDelete, ysnProcessed)
	SELECT DISTINCT [intHeaderId], ISNULL([ysnForDelete],0), 0
	FROM 
		@InvoiceIds

	
	WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceToUpdate WHERE [ysnProcessed] = 0 ORDER BY intInvoiceId)
	BEGIN				
		DECLARE @InvoiceId INT, @ysnForDelete BIT;
					
		SELECT TOP 1 @InvoiceId = intInvoiceId, @ysnForDelete = ysnForDelete FROM @InvoiceToUpdate WHERE [ysnProcessed] = 0 ORDER BY intInvoiceId
		--AR-4146TODO -- eliminate looping in [uspARUpdateSOStatusFromInvoice]
		EXEC dbo.[uspARUpdateSOStatusFromInvoice] @InvoiceId, @ysnForDelete
			
		UPDATE @InvoiceToUpdate SET [ysnProcessed] = 1  WHERE intInvoiceId = @InvoiceId
	END 
END