CREATE PROCEDURE [dbo].[uspARPostItemReservation]
	 @strSessionId		NVARCHAR(50)= NULL
	,@ysnReversePost	BIT			= 0
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON  

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

BEGIN TRY

DECLARE @InvoiceIds AS [InvoiceId]
DECLARE @TransactionTypeId AS INT = 33
SELECT @TransactionTypeId = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WHERE [strName] = 'Invoice'

INSERT INTO @InvoiceIds (
      [intHeaderId]
    , [ysnPost]
)
SELECT [intHeaderId]  = ARID.[intInvoiceId]
     , [ysnPost]      = ARID.[ysnPost]
FROM tblARPostInvoiceDetail ARID
INNER JOIN tblICStockReservation ICSR ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
                                     AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
                                     AND ARID.[intItemId] = ICSR.[intItemId]
WHERE (ICSR.[ysnPosted] <> ARID.[ysnPost] OR @ysnReversePost = 1)
  AND ICSR.intInventoryTransactionType = @TransactionTypeId
  AND ARID.strSessionId = @strSessionId

UNION

SELECT [intHeaderId]  = ARID.[intInvoiceId]
     , [ysnPost]      = ARID.[ysnPost] 
FROM tblARPostInvoiceDetail ARID
JOIN tblICItemBundle BDL ON BDL.intItemId = ARID.intItemId
INNER JOIN tblICStockReservation ICSR ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
                                     AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
                                     AND BDL.[intBundleItemId] = ICSR.[intItemId]
WHERE (ICSR.[ysnPosted] <> ARID.[ysnPost] OR @ysnReversePost = 1)
  AND ICSR.intInventoryTransactionType = @TransactionTypeId
  AND ARID.strSessionId = @strSessionId



IF EXISTS(SELECT TOP 1 1 FROM @InvoiceIds)
BEGIN
	DECLARE @ItemsToReserve AS ItemReservationTableType

	INSERT INTO @ItemsToReserve (
		  intItemId
	    , intItemLocationId
	    , intItemUOMId
	    , intLotId
	    , dblQty
	    , intTransactionId
	    , strTransactionId
	    , intTransactionTypeId
	    , intSubLocationId
	    , intStorageLocationId
	    , dtmDate
	)
	SELECT intItemId				= SR.intItemId
		, intItemLocationId			= SR.intItemLocationId
		, intItemUOMId				= SR.intItemUOMId
		, intLotId					= SR.intLotId
		, dblQty					= CASE WHEN I.ysnPost = 1 
										THEN -SR.dblQty 
										ELSE SR.dblQty 
									  END * CASE WHEN @ysnReversePost = 1 THEN -1 ELSE 1 END
		, intTransactionId			= SR.intTransactionId
		, strTransactionId			= SR.strTransactionId
		, intTransactionTypeId		= SR.intInventoryTransactionType
		, intSubLocationId			= SR.intSubLocationId
		, intStorageLocationId		= SR.intStorageLocationId
		, dtmDate					= SR.dtmDate
	FROM tblICStockReservation SR
	INNER JOIN @InvoiceIds I ON SR.intTransactionId = I.intHeaderId
	WHERE SR.intInventoryTransactionType = @TransactionTypeId

	IF EXISTS (SELECT TOP 1 1 FROM @ItemsToReserve) 
		BEGIN 
			EXEC dbo.uspICIncreaseReservedQty @ItemsToReserve

			UPDATE SR 			
			SET	ysnPosted = CASE 
								WHEN @ysnReversePost = 1 THEN CASE WHEN I.ysnPost = 1 THEN 0 ELSE 1 END 
								ELSE I.ysnPost 
							END
			FROM tblICStockReservation SR
			INNER JOIN @InvoiceIds I ON SR.intTransactionId = I.intHeaderId
			WHERE SR.intInventoryTransactionType = @TransactionTypeId
		END 
END

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    IF @InitTranCount = 0
        IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


IF @InitTranCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
		RETURN 1;
	END	


Post_Exit:
	RETURN 0;