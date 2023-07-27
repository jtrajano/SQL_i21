CREATE PROCEDURE [dbo].[uspARUpdateGrainOpenBalances]
	   @InvoiceIds	InvoiceId	READONLY
	 , @EntityId	INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @tblInvoices TABLE (
		  intInvoiceId	INT
		, ysnForDelete	BIT
	)

	INSERT INTO @tblInvoices (
		  intInvoiceId
		, ysnForDelete
	)
	SELECT DISTINCT intInvoiceId	= ID.intInvoiceId
				  , ysnForDelete	= II.ysnForDelete
	FROM tblARInvoiceDetail ID 
	INNER JOIN @InvoiceIds II ON ID.intInvoiceId = II.intHeaderId
	WHERE ID.intStorageScheduleTypeId IS NOT NULL
		
	WHILE EXISTS(SELECT TOP 1 NULL FROM @tblInvoices ORDER BY intInvoiceId)
	BEGIN				
		DECLARE @intInvoiceId INT = NULL
			  , @ysnForDelete BIT = NULL
					
		SELECT TOP 1 @intInvoiceId	= intInvoiceId
				   , @ysnForDelete	= ysnForDelete
		FROM @tblInvoices
		ORDER BY intInvoiceId

		EXEC dbo.[uspARUpdateGrainOpenBalance] @intInvoiceId, @ysnForDelete, @EntityId
			
		DELETE FROM @tblInvoices WHERE intInvoiceId = @intInvoiceId
	END
			 
END

GO