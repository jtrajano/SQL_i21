﻿CREATE PROCEDURE [dbo].[uspSOProcessToInvoice]
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

--VALIDATE IF SO IS FOR APPROVAL
IF EXISTS(SELECT NULL FROM vyuARForApprovalTransction WHERE strScreenName = 'Sales Order' AND intTransactionId = @SalesOrderId)
	BEGIN
		RAISERROR('Sales Order is still waiting for approval.', 16, 1)
		RETURN;
	END

--VALIDATE IF SO HAS BUNDLE-OPTION ITEM
IF EXISTS(SELECT NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblICItem I ON SOD.intItemId = I.intItemId WHERE intSalesOrderId = @SalesOrderId AND I.strType = 'Bundle' AND I.strBundleType = 'Option')
	BEGIN
		RAISERROR('Option bundle cannot be processed directly to invoice/shipment', 16, 1)
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

		--POST RESERVATION FOR PICK LIST
		EXEC dbo.uspSOUpdateReservedStock @SalesOrderId, 1

		--INSERT TO INVOICE
		EXEC dbo.uspARInsertToInvoice @SalesOrderId, @UserId, NULL, 0, @NewInvoiceId OUTPUT

		--UPDATE OVERRAGE CONTRACTS
		IF EXISTS (SELECT TOP 1 NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SOD.intContractDetailId AND SOD.dblQtyOrdered > CTD.dblBalance WHERE SOD.intSalesOrderId = @SalesOrderId)
			BEGIN
				EXEC dbo.uspARUpdateOverageContracts @intInvoiceId = @NewInvoiceId
												   , @intScaleUOMId = NULL
												   , @intUserId = @UserId
												   , @dblNetWeight = 0
												   , @ysnFromSalesOrder = 1
												   , @intTicketId = NULL
			END

		IF EXISTS (SELECT TOP 1 NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblCTItemContractDetail ICTD ON ICTD.intItemContractDetailId = SOD.intItemContractDetailId AND SOD.dblQtyOrdered > ICTD.dblBalance WHERE SOD.intSalesOrderId = @SalesOrderId)
			BEGIN
				EXEC dbo.uspARUpdateOverageItemContracts @intInvoiceId = @NewInvoiceId
												   	   , @intUserId = @UserId
			END
		
		IF ISNULL(@NewInvoiceId, 0) > 0
			EXEC dbo.uspARUpdateGrainOpenBalance @NewInvoiceId, 0, @UserId
	END

END