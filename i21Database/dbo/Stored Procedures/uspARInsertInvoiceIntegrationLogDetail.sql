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
		,[intId]
		,[strErrorMessage]
		,[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intSourceId]
		,[strSourceId]
		,[ysnPost]
		,[ysnInsert]
		,[ysnHeader]
		,[ysnSuccess]
		,[intConcurrencyId])
	SELECT
		 [intIntegrationLogId]			= [intIntegrationLogId]
		,[intInvoiceId]					= [intInvoiceId]
		,[intInvoiceDetailId]			= [intInvoiceDetailId]
		,[intId]						= [intId]
		,[strErrorMessage]				= [strErrorMessage]
		,[strTransactionType]			= [strTransactionType]
		,[strType]						= [strType]
		,[strSourceTransaction]			= [strSourceTransaction]
		,[intSourceId]					= [intSourceId]
		,[strSourceId]					= [strSourceId]
		,[ysnPost]						= [ysnPost]
		,[ysnInsert]					= [ysnInsert]
		,[ysnHeader]					= [ysnHeader]
		,[ysnSuccess]					= [ysnSuccess]
		,[intConcurrencyId]				= 1
	FROM
		@IntegrationLogEntries
	
RETURN 1
END

