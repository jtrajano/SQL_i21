CREATE PROCEDURE [dbo].[uspARPrePostInvoiceIntegration]
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


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

DECLARE @FinishedGoodItems TABLE
    ([intInvoiceDetailId]   INT
    ,[intItemId]            INT
    ,[dblQuantity]          NUMERIC(18,6)
    ,[intItemUOMId]         INT
    ,[intLocationId]        INT
    ,[intSublocationId]     INT
    ,[intStorageLocationId] INT
    ,[intUserId]            INT
    ,[dtmDate]              DATETIME)

INSERT INTO @FinishedGoodItems
SELECT
     [intInvoiceDetailId]   = [intInvoiceDetailId]
    ,[intItemId]            = [intItemId]
    ,[dblQuantity]          = [dblQtyShipped]
    ,[intItemUOMId]         = [intItemUOMId]
    ,[intLocationId]        = [intCompanyLocationId]
    ,[intSublocationId]     = [intSubLocationId]
    ,[intStorageLocationId] = [intStorageLocationId]
    ,[intUserId]            = [intUserId]
    ,[dtmDate]              = [dtmPostDate] 
FROM ##ARPostInvoiceDetail
WHERE [ysnBlended] = 0
  AND [ysnAutoBlend] = 1
  AND [strTransactionType] NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
  AND [strType] NOT IN ('Transport Delivery')
  AND [ysnImpactInventory] = 1

WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
BEGIN
    DECLARE  @intInvoiceDetailId    INT
            ,@intItemId             INT
            ,@dblQuantity           NUMERIC(18,6)
            ,@dblMaxQuantity        NUMERIC(18,6) = 0
            ,@intItemUOMId          INT
            ,@intLocationId         INT
            ,@intSublocationId      INT
            ,@intStorageLocationId  INT
            ,@intUserId             INT
            ,@dtmDate               DATETIME
			
    SELECT TOP 1 
             @intInvoiceDetailId    = intInvoiceDetailId
            ,@intItemId             = intItemId
            ,@dblQuantity           = dblQuantity				
            ,@intItemUOMId          = intItemUOMId
            ,@intLocationId         = intLocationId
            ,@intSublocationId      = intSublocationId
            ,@intStorageLocationId  = intStorageLocationId
            ,@intUserId             = intUserId
            ,@dtmDate               = dtmDate 
		FROM
            @FinishedGoodItems

    EXEC dbo.uspMFAutoBlend
            @intSalesOrderDetailId	= NULL,
            @intInvoiceDetailId		= @intInvoiceDetailId,
            @intItemId				= @intItemId,
            @dblQtyToProduce		= @dblQuantity,
            @intItemUOMId			= @intItemUOMId,
            @intLocationId			= @intLocationId,
            @intSubLocationId		= @intSublocationId,
            @intStorageLocationId	= @intStorageLocationId,
            @intUserId				= @intUserId,
            @dblMaxQtyToProduce		= @dblMaxQuantity OUT,
            @dtmDate				= @dtmDate

    IF ISNULL(@dblMaxQuantity, 0) > 0
        BEGIN
            EXEC dbo.uspMFAutoBlend
                    @intSalesOrderDetailId	= NULL,
                    @intInvoiceDetailId		= @intInvoiceDetailId,
                    @intItemId				= @intItemId,
                    @dblQtyToProduce		= @dblMaxQuantity,
                    @intItemUOMId			= @intItemUOMId,
                    @intLocationId			= @intLocationId,
                    @intSubLocationId		= @intSublocationId,
                    @intStorageLocationId	= @intStorageLocationId,
                    @intUserId				= @intUserId,
                    @dblMaxQtyToProduce		= @dblMaxQuantity OUT,
                    @dtmDate				= @dtmDate
        END
				  					
    UPDATE tblARInvoiceDetail SET ysnBlended = 1 WHERE intInvoiceDetailId = @intInvoiceDetailId

    DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
END

UPDATE ARI
SET ARI.[ysnProvisionalWithGL] = ARI1.[ysnProvisionalWithGL]
FROM tblARInvoice ARI
INNER JOIN ##ARPostInvoiceHeader ARI1 ON ARI.[intInvoiceId] = ARI1.[intInvoiceId] AND ARI.[strType] = 'Provisional'

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
