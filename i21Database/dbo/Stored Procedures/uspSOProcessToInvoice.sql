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
		DECLARE @EntityCustomerId INT
		DECLARE @TermsId INT

		select @EntityCustomerId = intEntityCustomerId,
			@TermsId = intTermId
			from tblSOSalesOrder with(nolock) where intSalesOrderId = @SalesOrderId

		if exists(select top 1 1 from tblEMEntityType with(nolock) where intEntityId = @EntityCustomerId and strType = 'Prospect')
			and not exists(select top 1 1 from tblEMEntityType with(nolock) where intEntityId = @EntityCustomerId and strType = 'Customer')
		BEGIN
			update tblEMEntityType 
				set strType = 'Customer'
					where intEntityId = @EntityCustomerId and strType = 'Prospect'
						and not exists ( select top 1 1 
											from tblEMEntityType 
												where intEntityId = @EntityCustomerId 
													and strType ='Customer')

			update tblARCustomer set intTermsId = @TermsId where intEntityId = @EntityCustomerId
		END



		--INSERT TO INVOICE
		EXEC dbo.uspARInsertToInvoice @SalesOrderId, @UserId, NULL, 0, @NewInvoiceId OUTPUT
		
		IF ISNULL(@NewInvoiceId, 0) > 0
			EXEC dbo.uspARUpdateGrainOpenBalance @NewInvoiceId, 0, @UserId
	END

END