CREATE PROCEDURE [dbo].[uspSOProcessToInvoice]
	@SalesOrderId		INT,
	@UserId				INT,
	@NewInvoiceId		INT = NULL OUTPUT,
	@dtmDateProcessed	DATETIME = NULL, 
	@intTicketId		INT = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT OFF  
SET ANSI_WARNINGS OFF

DECLARE @strErrorMessage NVARCHAR(MAX)

SET @dtmDateProcessed	= CAST(ISNULL(@dtmDateProcessed, GETDATE()) AS DATE)

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

--VALIDATE IF STORAGE LOCATION IS BLANK WHEN STORAGE UNIT IS SELECTED
DECLARE @strItemBlankStorageLocation NVARCHAR(MAX) = NULL;

SELECT @strItemBlankStorageLocation = COALESCE(@strItemBlankStorageLocation + ', ' + I.strItemNo, I.strItemNo)
FROM tblSOSalesOrder SO
INNER JOIN tblSOSalesOrderDetail SOD
ON SO.intSalesOrderId = SOD.intSalesOrderId
INNER JOIN tblICItem I
ON SOD.intItemId = I.intItemId
WHERE ISNULL(SOD.intStorageLocationId, 0) > 0
AND ISNULL(SOD.intSubLocationId, 0) = 0
AND SO.intSalesOrderId = @SalesOrderId

IF (@strItemBlankStorageLocation IS NOT NULL)
	BEGIN
		SET @strErrorMessage = 'The Storage Location field is required if the Storage Unit field is populated.  Please review these fields for Item(s) (' + @strItemBlankStorageLocation + ') and make the appropriate edits.'
		RAISERROR(@strErrorMessage, 16, 1)
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
		BEGIN TRY
			EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @SalesOrderId, @intUserId = @UserId, @dtmDateProcessed = @dtmDateProcessed
		END TRY
		BEGIN CATCH
			SET @strErrorMessage = ERROR_MESSAGE()
			RAISERROR(@strErrorMessage, 11, 1)
			RETURN
		END CATCH
		
		--CONVERT PROSPECT TO CUSTOMER
		DECLARE @intEntityCustomerId	INT
			  , @intTermsId				INT
			  , @intShipToLocationId	INT

		SELECT @intEntityCustomerId = intEntityCustomerId
			 , @intTermsId			= intTermId
			 , @intShipToLocationId	= intShipToLocationId
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
		EXEC dbo.uspARInsertToInvoice @SalesOrderId	     	= @SalesOrderId
									, @UserId			    = @UserId
									, @ShipmentId			= NULL
									, @FromShipping		 	= 0
									, @intShipToLocationId	= @intShipToLocationId
									, @NewInvoiceId		 	= @NewInvoiceId OUT
									, @dtmDateProcessed		= @dtmDateProcessed

		--UPDATE OVERRAGE CONTRACTS
		IF EXISTS (SELECT TOP 1 NULL FROM tblSOSalesOrderDetail SOD INNER JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SOD.intContractDetailId AND SOD.dblQtyOrdered > CTD.dblBalance WHERE SOD.intSalesOrderId = @SalesOrderId) AND ISNULL(@intTicketId, 0) = 0
			BEGIN
				EXEC dbo.uspARUpdateOverageContracts @intInvoiceId = @NewInvoiceId
												   , @intScaleUOMId = NULL
												   , @intUserId = @UserId
												   , @dblNetWeight = 0
												   , @ysnFromSalesOrder = 1												   
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