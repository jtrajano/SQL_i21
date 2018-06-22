CREATE PROCEDURE [dbo].[uspSOProcessToInvoice]
	@SalesOrderId		INT,
	@UserId				INT,
	@NewInvoiceId		INT = NULL OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT OFF  
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

--VALIDATE IF HAS NON-STOCK ITEMS
IF NOT EXISTS (SELECT NULL FROM tblSOSalesOrder SO INNER JOIN vyuARGetSalesOrderItems SI ON SO.intSalesOrderId = SI.intSalesOrderId
				LEFT JOIN tblICItem I ON SI.intItemId = I.intItemId WHERE ISNULL(I.strLotTracking, 'No') = 'No' AND SO.intSalesOrderId = @SalesOrderId AND SI.dblQtyRemaining > 0)
	BEGIN
		RAISERROR('Process To Invoice Failed. There is no item to process to Invoice.', 16, 1);
        RETURN;
	END
ELSE
	BEGIN
		--AUTO-BLEND ITEMS
		DECLARE @strErrorMessage NVARCHAR(MAX)

		BEGIN TRY
			EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @SalesOrderId, @intUserId = @UserId
		END TRY
		BEGIN CATCH
			SET @strErrorMessage = ERROR_MESSAGE()
			RAISERROR(@strErrorMessage, 11, 1)
			RETURN
		END CATCH
		
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