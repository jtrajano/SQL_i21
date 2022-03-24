CREATE PROCEDURE [dbo].[uspARPostItemResevation]
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
FROM ##ARPostInvoiceDetail ARID
INNER JOIN tblICStockReservation ICSR ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
                                     AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
                                     AND ARID.[intItemId] = ICSR.[intItemId]
WHERE ICSR.[ysnPosted] <> ARID.[ysnPost]
  AND ICSR.intInventoryTransactionType = @TransactionTypeId

UNION

SELECT [intHeaderId]  = ARID.[intInvoiceId]
     , [ysnPost]      = ARID.[ysnPost] 
FROM ##ARPostInvoiceDetail ARID
JOIN tblICItemBundle BDL ON BDL.intItemId = ARID.intItemId
INNER JOIN tblICStockReservation ICSR ON ARID.[intInvoiceId] = ICSR.[intTransactionId] 
                                     AND ARID.[strInvoiceNumber] = ICSR.[strTransactionId]
                                     AND BDL.[intBundleItemId] = ICSR.[intItemId]
WHERE ICSR.[ysnPosted] <> ARID.[ysnPost]
  AND ICSR.intInventoryTransactionType = @TransactionTypeId

WHILE EXISTS(SELECT NULL FROM @InvoiceIds)
BEGIN
    DECLARE @InvoiceId INT, @Post BIT
    SELECT TOP 1 @InvoiceId = [intHeaderId], @Post = [ysnPost] FROM @InvoiceIds

    EXEC    [dbo].[uspICPostStockReservation]
                 @intTransactionId		= @InvoiceId
                ,@intTransactionTypeId	= @TransactionTypeId
                ,@ysnPosted				= @Post

    DELETE FROM @InvoiceIds WHERE [intHeaderId] = @InvoiceId
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
