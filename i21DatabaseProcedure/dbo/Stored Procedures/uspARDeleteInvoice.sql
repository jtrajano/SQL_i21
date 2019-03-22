CREATE PROCEDURE [dbo].[uspARDeleteInvoice]
	 @InvoiceId	INT
	,@UserId	INT
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @UserEntityID INT
	SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId) 
		
	IF(EXISTS(SELECT NULL FROM tblARInvoice WHERE intInvoiceId = @InvoiceId AND ISNULL(ysnPosted,0) = 1))
		RAISERROR('Posted invoice cannot be deleted!', 16, 1);		
	

	EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @InvoiceId, @ForDelete = 1, @UserId = @UserEntityID		

	DELETE FROM tblARInvoiceDetailTax 
	WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)

	DELETE FROM tblARInvoiceDetail 
	WHERE intInvoiceId = @InvoiceId

	DELETE FROM tblARInvoice 
	WHERE intInvoiceId = @InvoiceId
	
	--Audit Log          
	EXEC dbo.uspSMAuditLog 
		 @keyValue			= @InvoiceId						-- Primary Key Value of the Invoice. 
		,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
		,@entityId			= @UserEntityID						-- Entity Id.
		,@actionType		= 'Deleted'							-- Action Type
		,@changeDescription	= ''								-- Description
		,@fromValue			= ''								-- Previous Value
		,@toValue			= ''								-- New Value

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END