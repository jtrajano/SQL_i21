CREATE PROCEDURE [dbo].[uspARDeleteInvoicesFromTransport]
	 @TransportLoadId	INT
	,@UserId			INT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @UserEntityID INT
SET @UserEntityID = ISNULL((SELECT intEntityUserSecurityId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @userId),@userId) 

BEGIN TRY
WHILE EXISTS(
			SELECT 
				NULL 
			FROM
				tblARInvoice I
			INNER JOIN
				tblTRDistributionHeader DH
					ON I.intDistributionHeaderId = DH.intDistributionHeaderId
			INNER JOIN
				tblTRTransportReceipt TR
					ON DH.intTransportReceiptId = TR.intTransportReceiptId
			INNER JOIN
				tblTRTransportLoad TL
					ON TR.intTransportLoadId = TL.intTransportLoadId 
			WHERE
				TL.intTransportLoadId = @TransportLoadId
			)
	BEGIN

		DECLARE @invoiceId int
		
		IF(EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @invoiceId AND ISNULL(ysnPosted,0) = 1))
			RAISERROR('Posted invoice cannot be deleted!', 11, 1);
			
		SELECT TOP 1
			@invoiceId = I.intInvoiceId 
		FROM
			tblARInvoice I
		INNER JOIN
			tblTRDistributionHeader DH
				ON I.intDistributionHeaderId = DH.intDistributionHeaderId
		INNER JOIN
			tblTRTransportReceipt TR
				ON DH.intTransportReceiptId = TR.intTransportReceiptId
		INNER JOIN
			tblTRTransportLoad TL
				ON TR.intTransportLoadId = TL.intTransportLoadId
		WHERE
			TL.intTransportLoadId = @TransportLoadId			

		DELETE FROM tblARInvoiceDetailTax 
		WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @invoiceId)

		DELETE FROM tblARInvoiceDetail 
		WHERE intInvoiceId = @invoiceId

		DELETE FROM tblARInvoice 
		WHERE intInvoiceId = @invoiceId
		
		--Audit Log          
		EXEC dbo.uspSMAuditLog 
			 @keyValue			= @invoiceId						-- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
			,@entityId			= @UserEntityID						-- Entity Id.
			,@actionType		= 'Deleted'							-- Action Type
			,@changeDescription	= ''								-- Description
			,@fromValue			= ''								-- Previous Value
			,@toValue			= ''								-- New Value

	END
	
END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
END CATCH		
		                     
RETURN 1

END