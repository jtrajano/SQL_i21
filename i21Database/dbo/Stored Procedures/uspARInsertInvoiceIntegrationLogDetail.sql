CREATE PROCEDURE [dbo].[uspARInsertInvoiceIntegrationLogDetail]
	 @IntegrationLogEntries	InvoiceIntegrationLogStagingTable	READONLY		
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	INSERT INTO [tblARInvoiceIntegrationLogDetail]
		([intIntegrationLogId]
		,[intInvoiceId]
		,[intInvoiceDetailId]
		,[intTemporaryDetailIdForTax]
		,[intId]
		,[strMessage]	
		,[strPostingMessage]
		,[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[ysnPost]
		,[ysnRecap]
		,[ysnInsert]
		,[ysnHeader]
		,[ysnSuccess]
		,[ysnPosted]
		,[ysnUnPosted]
		,[ysnAccrueLicense]
		,[ysnUpdateAvailableDiscount]
		,[strBatchId]
		,[intConcurrencyId])
	SELECT
		 [intIntegrationLogId]			= [intIntegrationLogId]
		,[intInvoiceId]					= [intInvoiceId]
		,[intInvoiceDetailId]			= [intInvoiceDetailId]
		,[intTemporaryDetailIdForTax]	= [intTemporaryDetailIdForTax]
		,[intId]						= [intId]
		,[strMessage]					= [strMessage]
		,[strPostingMessage]			= [strPostingMessage]
		,[strTransactionType]			= [strTransactionType]
		,[strType]						= [strType]
		,[strSourceTransaction]			= [strSourceTransaction]
		,[intSourceId]					= [intSourceId]
		,[strSourceId]					= [strSourceId]
		,[ysnPost]						= [ysnPost]
		,[ysnRecap]						= [ysnRecap]
		,[ysnInsert]					= [ysnInsert]
		,[ysnHeader]					= [ysnHeader]
		,[ysnSuccess]					= [ysnSuccess]
		,[ysnPosted]					= [ysnPosted]
		,[ysnUnPosted]					= [ysnUnPosted]
		,[ysnAccrueLicense]				= [ysnAccrueLicense]
		,[ysnUpdateAvailableDiscount]	= [ysnUpdateAvailableDiscount]
		,[strBatchId]					= [strBatchId]
		,[intConcurrencyId]				= 1
	FROM
		@IntegrationLogEntries
	
RETURN 1
END

