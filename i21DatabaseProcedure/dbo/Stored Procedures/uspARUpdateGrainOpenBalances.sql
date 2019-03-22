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
	
	DECLARE @IdsForUpdate AS InvoiceId;
	INSERT INTO @IdsForUpdate
	SELECT * FROM @InvoiceIds
		
	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsForUpdate ORDER BY intHeaderId)
	BEGIN				
		DECLARE  @InvoiceId INT
				,@ForDelete INT
				,@UserId INT;
					
		SELECT TOP 1 
			 @InvoiceId	= intHeaderId
			,@ForDelete	= ysnForDelete
			,@UserId	= @UserId
		FROM @IdsForUpdate
		ORDER BY intHeaderId

		EXEC dbo.[uspARUpdateGrainOpenBalance] @InvoiceId, @ForDelete, @UserId
			
		DELETE FROM @IdsForUpdate WHERE intHeaderId = @InvoiceId
	END
			 
END

GO