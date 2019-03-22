CREATE PROCEDURE [dbo].[uspARInsertPaymentIntegrationLogDetail]
	 @IntegrationLogEntries	PaymentIntegrationLogStagingTable	READONLY		
AS
BEGIN
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	INSERT INTO [tblARPaymentIntegrationLogDetail]
		([intIntegrationLogId]
		,[intPaymentId]
		,[intPaymentDetailId]
		,[intId]
		,[strMessage]	
		,[strPostingMessage]
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
		,[strBatchId]
		,[intConcurrencyId])
	SELECT
		 [intIntegrationLogId]			= [intIntegrationLogId]
		,[intPaymentId]					= [intPaymentId]
		,[intPaymentDetailId]			= [intPaymentDetailId]
		,[intId]						= [intId]
		,[strMessage]					= [strMessage]
		,[strPostingMessage]			= [strPostingMessage]
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
		,[strBatchId]					= [strBatchId]
		,[intConcurrencyId]				= 1
	FROM
		@IntegrationLogEntries
	
RETURN 1
END