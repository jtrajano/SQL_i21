CREATE PROCEDURE [dbo].[uspARAutoBlendSalesOrderItems]
	@intSalesOrderId	INT,
	@intUserId			INT
AS

DECLARE @strErrorMessage NVARCHAR(MAX)

IF(OBJECT_ID('tempdb..#UNBLENDEDITEMS') IS NOT NULL)
BEGIN
	DROP TABLE #UNBLENDEDITEMS
END
		
CREATE TABLE #UNBLENDEDITEMS (
	  intSalesOrderDetailId	INT NULL
	, intItemId				INT NULL
	, intItemUOMId			INT NULL
	, intCompanyLocationId	INT NULL
	, intSubLocationId		INT NULL
	, intStorageLocationId	INT NULL
	, dblQtyOrdered			NUMERIC(18, 6) NULL
	, dtmDate				DATETIME NULL
)

INSERT INTO #UNBLENDEDITEMS
SELECT intSalesOrderDetailId	= SOD.intSalesOrderDetailId
	 , intItemId				= SOD.intItemId			 
	 , intItemUOMId				= SOD.intItemUOMId
	 , intCompanyLocationId		= SO.intCompanyLocationId
	 , intSubLocationId			= SOD.intSubLocationId
	 , intStorageLocationId		= SOD.intStorageLocationId
	 , dblQtyOrdered			= SOD.dblQtyOrdered
	 , dtmDate					= SO.dtmDate
FROM tblSOSalesOrderDetail SOD
INNER JOIN tblSOSalesOrder SO ON SOD.intSalesOrderId = SO.intSalesOrderId
INNER JOIN tblICItem ITEM ON ITEM.intItemId = SOD.intItemId		
WHERE SOD.intSalesOrderId = @intSalesOrderId
	AND ISNULL(SOD.ysnBlended, 0) = 0
	AND ITEM.strType = 'Finished Good'
	AND ITEM.ysnAutoBlend = 1
		
WHILE EXISTS (SELECT TOP 1 NULL FROM #UNBLENDEDITEMS)
	BEGIN
		DECLARE @intSalesOrderDetailId	INT = NULL
			  , @intItemId				INT = NULL
			  , @intItemUOMId			INT = NULL
			  , @intCompanyLocationId	INT = NULL
			  , @intSubLocationId		INT = NULL
			  , @intStorageLocationId	INT = NULL
			  , @dblQtyOrdered			NUMERIC(18, 6) = 0
			  , @dblMaxQtyToProduce		NUMERIC(18, 6) = 0
			  , @dtmDate				DATETIME = NULL

		SELECT TOP 1 @intSalesOrderDetailId = intSalesOrderDetailId
				   , @intItemId				= intItemId			 
				   , @intItemUOMId			= intItemUOMId
				   , @intCompanyLocationId	= intCompanyLocationId
				   , @intSubLocationId		= intSubLocationId
				   , @intStorageLocationId	= intStorageLocationId
				   , @dblQtyOrdered			= dblQtyOrdered
				   , @dtmDate				= dtmDate
		FROM #UNBLENDEDITEMS
		ORDER BY intSalesOrderDetailId

		BEGIN TRY				
			EXEC [dbo].[uspMFAutoBlend] @intSalesOrderDetailId	= @intSalesOrderDetailId
									  , @intItemId				= @intItemId
									  , @dblQtyToProduce		= @dblQtyOrdered
									  , @intItemUOMId			= @intItemUOMId
									  , @intLocationId			= @intCompanyLocationId
									  , @intSubLocationId		= @intSubLocationId
									  , @intStorageLocationId	= @intStorageLocationId
									  , @intUserId				= @intUserId
									  , @dblMaxQtyToProduce		= @dblMaxQtyToProduce OUT
									  , @dtmDate				= @dtmDate

			IF ISNULL(@dblMaxQtyToProduce, 0) > 0
				BEGIN
					EXEC [dbo].[uspMFAutoBlend] @intSalesOrderDetailId	= @intSalesOrderDetailId
											  , @intItemId				= @intItemId
											  , @dblQtyToProduce		= @dblMaxQtyToProduce
											  , @intItemUOMId			= @intItemUOMId
											  , @intLocationId			= @intCompanyLocationId
											  , @intSubLocationId		= @intSubLocationId
											  , @intStorageLocationId	= @intStorageLocationId
											  , @intUserId				= @intUserId
											  , @dblMaxQtyToProduce		= @dblMaxQtyToProduce OUT
											  , @dtmDate				= @dtmDate
				END
		END TRY
		BEGIN CATCH
			SET @strErrorMessage	= ERROR_MESSAGE()

			RAISERROR(@strErrorMessage, 11, 1)
			RETURN
		END CATCH

		UPDATE tblSOSalesOrderDetail 
		SET dblQtyOrdered	= CASE WHEN ISNULL(@dblMaxQtyToProduce, 0) > 0 AND ISNULL(@dblMaxQtyToProduce, 0) <> dblQtyOrdered THEN @dblMaxQtyToProduce ELSE dblQtyOrdered END
		  , ysnBlended		= 1
		WHERE intSalesOrderDetailId = @intSalesOrderDetailId
							
		DELETE FROM #UNBLENDEDITEMS WHERE intSalesOrderDetailId  = @intSalesOrderDetailId
	END