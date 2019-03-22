CREATE PROCEDURE [dbo].[uspARPrePostInvoiceIntegration]     
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

--DECLARE @InvoiceSplitIds TABLE(
--	id  	INT
--)
--INSERT INTO @InvoiceSplitIds(id)
--SELECT DISTINCT intInvoiceId FROM @PostInvoiceData

--WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceSplitIds ORDER BY id)
--BEGIN				
--	DECLARE @InvoiceId1 INT
					
--	SELECT TOP 1 @InvoiceId1 = id FROM @InvoiceSplitIds ORDER BY id
		
--	EXEC dbo.[uspARUpdateReservedStock] @InvoiceId1, 0, @userId, 1, @post

--	DELETE FROM @InvoiceSplitIds WHERE id = @InvoiceId1
--END	 
-- EXEC [dbo].[uspARPostItemResevation] -- MDG this is moved prior to the validation of posting due to stock sensitivity

--Process Finished Good Items
--DECLARE @FinishedGoodItems TABLE(
--	  intInvoiceDetailId		INT
--	, intItemId					INT
--	, dblQuantity				NUMERIC(18,6)
--	, intItemUOMId				INT
--	, intLocationId				INT
--	, intSublocationId			INT
--	, intStorageLocationId		INT
--	, dtmDate					DATETIME
--)
--INSERT INTO @FinishedGoodItems
--SELECT
--	 [intInvoiceDetailId]
--    ,[intItemId]
--    ,[dblQtyShipped]
--    ,[intItemUOMId]
--    ,[intCompanyLocationId]
--    ,[intSubLocationId]
--    ,[intStorageLocationId]
--    ,[dtmDate]
--FROM @PostInvoiceData
--WHERE
--    [intInvoiceDetailId] IS NOT NULL
--    AND [ysnBlended] <> [ysnPost]
--    AND [ysnAutoBlend] = 1
--    AND [strTransactionType] NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
--    AND 
--        (
--        [ysnPost] = 0
--        OR
--        (
--            [ysnPost] = 1
--            AND 
--            [dblUnitOnHand] = @ZeroDecimal
--            AND 
--            [intAllowNegativeInventory] = 3
--        )
--        )

--BEGIN TRY
--	IF @post = 1
--		BEGIN
--			WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
--				BEGIN
--					DECLARE @intInvoiceDetailId		INT
--						  , @intItemId				INT
--						  , @dblQuantity			NUMERIC(18,6)
--						  , @dblMaxQuantity			NUMERIC(18,6) = 0
--						  , @intItemUOMId			INT
--						  , @intLocationId			INT
--						  , @intSublocationId		INT
--						  , @intStorageLocationId	INT
--						  , @dtmDate			DATETIME
			
--					SELECT TOP 1 
--						  @intInvoiceDetailId	= intInvoiceDetailId
--						, @intItemId			= intItemId
--						, @dblQuantity			= dblQuantity				
--						, @intItemUOMId			= intItemUOMId
--						, @intLocationId		= intLocationId
--						, @intSublocationId		= intSublocationId
--						, @intStorageLocationId	= intStorageLocationId
--						, @dtmDate				= dtmDate 
--					FROM @FinishedGoodItems 
				  
--					BEGIN TRY
--					IF @post = 1
--						BEGIN
--							EXEC dbo.uspMFAutoBlend
--								@intSalesOrderDetailId	= NULL,
--								@intInvoiceDetailId		= @intInvoiceDetailId,
--								@intItemId				= @intItemId,
--								@dblQtyToProduce		= @dblQuantity,
--								@intItemUOMId			= @intItemUOMId,
--								@intLocationId			= @intLocationId,
--								@intSubLocationId		= @intSublocationId,
--								@intStorageLocationId	= @intStorageLocationId,
--								@intUserId				= @userId,
--								@dblMaxQtyToProduce		= @dblMaxQuantity OUT,
--								@dtmDate				= @dtmDate

--							IF ISNULL(@dblMaxQuantity, 0) > 0
--								BEGIN
--									EXEC dbo.uspMFAutoBlend
--										@intSalesOrderDetailId	= NULL,
--										@intInvoiceDetailId		= @intInvoiceDetailId,
--										@intItemId				= @intItemId,
--										@dblQtyToProduce		= @dblMaxQuantity,
--										@intItemUOMId			= @intItemUOMId,
--										@intLocationId			= @intLocationId,
--										@intSubLocationId		= @intSublocationId,
--										@intStorageLocationId	= @intStorageLocationId,
--										@intUserId				= @userId,
--										@dblMaxQtyToProduce		= @dblMaxQuantity OUT,
--										@dtmDate				= @dtmDate
--								END
--						END
					
--					END TRY
--					BEGIN CATCH
--						SELECT @ErrorMerssage = ERROR_MESSAGE()
--						IF @raiseError = 0
--							BEGIN
--								IF @InitTranCount = 0
--									IF (XACT_STATE()) <> 0
--										ROLLBACK TRANSACTION
--								ELSE
--									IF (XACT_STATE()) <> 0
--										ROLLBACK TRANSACTION @Savepoint
												
--								SET @CurrentTranCount = @@TRANCOUNT
--								SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
--								IF @CurrentTranCount = 0
--									BEGIN TRANSACTION
--								ELSE
--									SAVE TRANSACTION @CurrentSavepoint
									
--								EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

--								IF @CurrentTranCount = 0
--									BEGIN
--										IF (XACT_STATE()) = -1
--											ROLLBACK TRANSACTION
--										IF (XACT_STATE()) = 1
--											COMMIT TRANSACTION
--									END		
--								ELSE
--									BEGIN
--										IF (XACT_STATE()) = -1
--											ROLLBACK TRANSACTION  @CurrentSavepoint
--										--IF (XACT_STATE()) = 1
--										--	COMMIT TRANSACTION  @Savepoint
--									END	
--							END						
--						IF @raiseError = 1
--							RAISERROR(@ErrorMerssage, 11, 1)
		
--						GOTO Post_Exit
--					END CATCH
					
--					UPDATE tblARInvoiceDetail SET ysnBlended = 1 WHERE intInvoiceDetailId = @intInvoiceDetailId

--					DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
--				END	
--		END	
--END TRY
--BEGIN CATCH
--	SELECT @ErrorMerssage = ERROR_MESSAGE()
--	IF @raiseError = 0
--		BEGIN
--			IF @InitTranCount = 0
--				IF (XACT_STATE()) <> 0
--					ROLLBACK TRANSACTION
--			ELSE
--				IF (XACT_STATE()) <> 0
--					ROLLBACK TRANSACTION @Savepoint
												
--			SET @CurrentTranCount = @@TRANCOUNT
--			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
--			IF @CurrentTranCount = 0
--				BEGIN TRANSACTION
--			ELSE
--				SAVE TRANSACTION @CurrentSavepoint
															
--			EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

--			IF @CurrentTranCount = 0
--				BEGIN
--					IF (XACT_STATE()) = -1
--						ROLLBACK TRANSACTION
--					IF (XACT_STATE()) = 1
--						COMMIT TRANSACTION
--				END		
--			ELSE
--				BEGIN
--					IF (XACT_STATE()) = -1
--						ROLLBACK TRANSACTION  @CurrentSavepoint
--					--IF (XACT_STATE()) = 1
--					--	COMMIT TRANSACTION  @Savepoint
--				END	
--		END						
--	IF @raiseError = 1
--		RAISERROR(@ErrorMerssage, 11, 1)
		
--	GOTO Post_Exit
--END CATCH
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
FROM #ARPostInvoiceDetail
WHERE
    [ysnBlended] = 0
    AND [ysnAutoBlend] = 1
    AND [strTransactionType] NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
    --AND [dblUnitOnHand] = @ZeroDecimal
    --AND [intAllowNegativeInventory] = 3

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
SET
    ARI.[ysnProvisionalWithGL] = ARI1.[ysnProvisionalWithGL]
FROM
    tblARInvoice ARI
INNER JOIN
    #ARPostInvoiceHeader ARI1
		ON ARI.[intInvoiceId] = ARI1.[intInvoiceId]
		AND ARI.[strType] = 'Provisional'

RETURN 1
