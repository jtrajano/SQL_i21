CREATE PROCEDURE [dbo].[uspSOProcessToInvoice]
	@SalesOrderId		INT,
	@UserId				INT,
	@NewInvoiceId		INT = NULL OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--VALIDATE IF SO IS ALREADY CLOSED
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [strOrderStatus] = 'Closed') 
	BEGIN
		RAISERROR('Sales Order already closed.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO HAS ZERO TOTAL AMOUNT
IF EXISTS(SELECT NULL FROM tblSOSalesOrder WHERE [intSalesOrderId] = @SalesOrderId AND [dblSalesOrderTotal]  = 0)
	BEGIN
		RAISERROR('Cannot process Sales Order with zero(0) amount.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO IS FOR APPROVAL
IF EXISTS(SELECT NULL FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order' AND intTransactionId = @SalesOrderId)
	BEGIN
		RAISERROR('Sales Order is still waiting for approval.', 16, 1)
		RETURN;
	END

--VALIDATE IF HAS NON-STOCK ITEMS
IF NOT EXISTS (SELECT NULL FROM tblSOSalesOrder SO INNER JOIN vyuARGetSalesOrderItems SI ON SO.intSalesOrderId = SI.intSalesOrderId AND SO.intSalesOrderId = @SalesOrderId AND SI.dblQtyRemaining > 0)
	BEGIN
		RAISERROR('Process To Invoice Failed. There is no item to process to Invoice.', 16, 1);
        RETURN;
	END
ELSE
	BEGIN
		--AUTO-BLEND ITEMS
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
		WHERE SOD.intSalesOrderId = @SalesOrderId
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

				EXEC [dbo].[uspMFAutoBlend] @intSalesOrderDetailId	= @intSalesOrderDetailId
										  , @intItemId				= @intItemId
										  , @dblQtyToProduce		= @dblQtyOrdered
										  , @intItemUOMId			= @intItemUOMId
										  , @intLocationId			= @intCompanyLocationId
										  , @intSubLocationId		= @intSubLocationId
										  , @intStorageLocationId	= @intStorageLocationId
										  , @intUserId				= @UserId
										  , @dblMaxQtyToProduce		= @dblMaxQtyToProduce OUT
										  , @dtmDate				= @dtmDate

				IF ISNULL(@dblMaxQtyToProduce, 0) > 0
					BEGIN
						UPDATE tblSOSalesOrderDetail SET dblQtyOrdered = @dblMaxQtyToProduce WHERE intSalesOrderDetailId = @intSalesOrderDetailId

						EXEC [dbo].[uspMFAutoBlend] @intSalesOrderDetailId	= @intSalesOrderDetailId
												  , @intItemId				= @intItemId
												  , @dblQtyToProduce		= @dblMaxQtyToProduce
												  , @intItemUOMId			= @intItemUOMId
												  , @intLocationId			= @intCompanyLocationId
												  , @intSubLocationId		= @intSubLocationId
												  , @intStorageLocationId	= @intStorageLocationId
												  , @intUserId				= @UserId
												  , @dblMaxQtyToProduce		= @dblMaxQtyToProduce OUT
												  , @dtmDate				= @dtmDate
					END

				UPDATE tblSOSalesOrderDetail SET ysnBlended = 1 WHERE intSalesOrderDetailId = @intSalesOrderDetailId
							
				DELETE FROM #UNBLENDEDITEMS WHERE intSalesOrderDetailId  = @intSalesOrderDetailId
			END
		
		--CONVERT PROSPECT TO CUSTOMER
		DECLARE @intEntityCustomerId	INT
			  , @intTermsId				INT

		SELECT @intEntityCustomerId = intEntityCustomerId
			 , @intTermsId			= intTermId
		FROM dbo.tblSOSalesOrder WITH(NOLOCK) 
		where intSalesOrderId = @SalesOrderId

		IF EXISTS(SELECT top 1 1 FROM tblEMEntityType WITH(NOLOCK) WHERE intEntityId = @intEntityCustomerId AND strType = 'Prospect')
			AND NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WITH(NOLOCK) WHERE intEntityId = @intEntityCustomerId AND strType = 'Customer')
		BEGIN
			UPDATE tblEMEntityType 
			SET strType = 'Customer'
			WHERE intEntityId = @intEntityCustomerId 
			 AND strType = 'Prospect'
			 AND NOT EXISTS (SELECT top 1 1 FROM tblEMEntityType WHERE intEntityId = @intEntityCustomerId AND strType ='Customer')

			UPDATE tblARCustomer 
			SET intTermsId = @intTermsId 
			WHERE intEntityId = @intEntityCustomerId
		END


		--INSERT TO INVOICE
		EXEC dbo.uspARInsertToInvoice @SalesOrderId, @UserId, NULL, 0, @NewInvoiceId OUTPUT
		
		IF ISNULL(@NewInvoiceId, 0) > 0
			EXEC dbo.uspARUpdateGrainOpenBalance @NewInvoiceId, 0, @UserId
	END

END