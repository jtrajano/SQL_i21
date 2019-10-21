CREATE PROCEDURE [dbo].[uspARDeleteInvoice]
	 @InvoiceId	INT
	,@UserId	INT
	,@InvoiceDetailId	INT  = NULL
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

	IF(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE intPrepaymentId = @InvoiceId AND ISNULL(ysnApplied,0) = 1))
		BEGIN
			DECLARE @strInvoiceNumber 	NVARCHAR(100) = NULL
				  , @strPrepaidNumber 	NVARCHAR(100) = NULL
				  , @strError			NVARCHAR(200) = NULL

			SELECT @strPrepaidNumber = strInvoiceNumber
			FROM tblARInvoice I
			WHERE intInvoiceId = @InvoiceId

			SELECT TOP 1 @strInvoiceNumber = strInvoiceNumber
			FROM tblARInvoice I
			INNER JOIN tblARPrepaidAndCredit PC ON I.intInvoiceId = PC.intInvoiceId
			WHERE PC.intPrepaymentId = @InvoiceId

			SET @strError = 'Unable to delete prepaid/credit! ' + @strPrepaidNumber + ' was already applied in ' + @strInvoiceNumber + '.'

			RAISERROR(@strError, 16, 1);
		END		

	IF @InvoiceDetailId IS NOT NULL
		BEGIN
			EXEC [dbo].[uspARInsertTransactionDetail] @InvoiceId = @InvoiceId

			DELETE FROM tblARInvoiceDetailTax 
			WHERE intInvoiceDetailId = @InvoiceDetailId

			DELETE FROM tblARInvoiceDetail 
			WHERE intInvoiceDetailId = @InvoiceDetailId

			EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @InvoiceId, @ForDelete = 0, @UserId = @UserEntityID

			--Audit Log
			DECLARE @details NVARCHAR(max) = '{"change": "tblARInvoiceDetail", "iconCls": "small-tree-grid","changeDescription": "Details", "children": [{"action": "Deleted", "change": "Deleted-Record: '+CAST(@InvoiceDetailId as varchar(15))+'", "keyValue": '+CAST(@InvoiceDetailId as varchar(15))+', "iconCls": "small-new-minus", "leaf": true}]}';

			EXEC uspSMAuditLog
			@screenName = 'AccountsReceivable.view.Invoice',
			@entityId = @UserEntityID,
			@actionType = 'Updated',
			@actionIcon = 'small-tree-modified',
			@keyValue = @InvoiceId,
			@details = @details
		END
	ELSE
		BEGIN

			EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @InvoiceId, @ForDelete = 1, @UserId = @UserEntityID

			DELETE FROM tblARInvoiceDetailTax 
			WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)

			DELETE FROM tblARPrepaidAndCredit
			WHERE intPrepaymentId = @InvoiceId
			  AND ysnApplied = 0

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
		END

END TRY
BEGIN CATCH	
	DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()									
	RAISERROR(@ErrorMerssage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END