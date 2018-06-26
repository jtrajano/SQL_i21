CREATE PROCEDURE [dbo].[uspARImportBillableHours]
	 @HoursWorkedIDs		AS NVARCHAR(MAX)	= 'all'
	,@Post					AS BIT				= 0	
	,@UserId				AS INT				= 1
	,@IsSuccess				AS BIT				= 0		OUTPUT
	,@BatchIdUsed			AS NVARCHAR(20)		= NULL	OUTPUT
	,@SuccessfulCount		AS INT				= 0		OUTPUT
	,@InvalidCount			AS INT				= 0		OUTPUT
	,@DocumentMaintenanceId AS INT				= NULL
	,@DefaultLocationId		AS INT				= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @tblInvoiceEntries		InvoiceIntegrationStagingTable
DECLARE	@tblTaxEntries			LineItemTaxDetailStagingTable
DECLARE @dblZeroDecimal			NUMERIC(18,6)	= 0
	  , @dtmDateOnly			DATETIME		= CAST(GETDATE() AS DATE)
	  , @intCompanyLocationId	INT				= @DefaultLocationId
	  , @strErrorMessage		NVARCHAR(MAX)	= ''
	  , @strCreatedInvoices		NVARCHAR(MAX)	= ''

IF(OBJECT_ID('tempdb..#BILLABLE') IS NOT NULL)
BEGIN
    DROP TABLE #BILLABLE
END

SELECT intEntityCustomerId		= intEntityId
	 , intTicketId				= intTicketId
	 , intTicketHoursWorkedId	= intTicketHoursWorkedId
	 , intCompanyLocationId		= intCompanyLocationId
	 , intItemId				= intItemId
	 , intItemUOMId				= intItemUOMId	 
	 , strItemNo				= strItemNo
	 , dblHours					= CAST(intHours AS NUMERIC(18, 6))
	 , dblPrice					= dblPrice
	 , strTicketNumber			= CAST(strTicketNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(100))
INTO #BILLABLE
FROM vyuARBillableHoursForImport
WHERE 1 = 0
		
IF ISNULL(@HoursWorkedIDs, 'all') = 'all'
	BEGIN
		INSERT INTO #BILLABLE 
		SELECT intEntityCustomerId		= BILLABLE.intEntityId
			 , intTicketId				= BILLABLE.intTicketId
			 , intTicketHoursWorkedId	= BILLABLE.intTicketHoursWorkedId
			 , intCompanyLocationId		= ISNULL(BILLABLE.intEntityWarehouseId, ISNULL(@intCompanyLocationId, BILLABLE.intCompanyLocationId))
			 , intItemId				= BILLABLE.intItemId
			 , intItemUOMId				= BILLABLE.intItemUOMId	 
			 , strItemNo				= BILLABLE.strItemNo
			 , dblHours					= CAST(BILLABLE.intHours AS NUMERIC(18, 6))
			 , dblPrice					= BILLABLE.dblPrice
			 , strTicketNumber			= BILLABLE.strTicketNumber
		FROM vyuARBillableHoursForImport BILLABLE
	END
ELSE
	BEGIN
		INSERT INTO #BILLABLE 
		SELECT intEntityCustomerId		= BILLABLE.intEntityId
			 , intTicketId				= BILLABLE.intTicketId
			 , intTicketHoursWorkedId	= BILLABLE.intTicketHoursWorkedId
			 , intCompanyLocationId		= ISNULL(BILLABLE.intEntityWarehouseId, ISNULL(@intCompanyLocationId, BILLABLE.intCompanyLocationId))
			 , intItemId				= BILLABLE.intItemId
			 , intItemUOMId				= BILLABLE.intItemUOMId	 
			 , strItemNo				= BILLABLE.strItemNo
			 , dblHours					= CAST(BILLABLE.intHours AS NUMERIC(18, 6))
			 , dblPrice					= BILLABLE.dblPrice
			 , strTicketNumber			= BILLABLE.strTicketNumber
		FROM vyuARBillableHoursForImport BILLABLE
		INNER JOIN fnGetRowsFromDelimitedValues(@HoursWorkedIDs) SELECTED
		ON SELECTED.intID = BILLABLE.intTicketHoursWorkedId
	END
	
INSERT INTO @tblInvoiceEntries (
	 [strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[dtmDate]
	,[dtmPostDate]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[ysnRecomputeTax]
	,[intTicketHoursWorkedId]
	,[dblCurrencyExchangeRate]
)
SELECT 
	 [strSourceTransaction]		= 'Direct'
	,[intSourceId]				= 0
	,[strSourceId]				= BILLABLE.strTicketNumber
	,[intEntityCustomerId]		= BILLABLE.intEntityCustomerId
	,[intCompanyLocationId]		= BILLABLE.intCompanyLocationId
	,[dtmDate]					= @dtmDateOnly
	,[dtmPostDate]				= @dtmDateOnly
	,[intEntityId]				= @UserId
	,[ysnPost]					= 0
	,[intItemId]				= BILLABLE.intItemId
	,[ysnInventory]				= 0
	,[strItemDescription]		= BILLABLE.strTicketNumber
	,[intOrderUOMId]			= BILLABLE.intItemUOMId
	,[dblQtyOrdered]			= BILLABLE.dblHours
	,[intItemUOMId]				= BILLABLE.intItemUOMId
	,[dblQtyShipped]			= BILLABLE.dblHours
	,[dblPrice]					= BILLABLE.dblPrice
	,[ysnRefreshPrice]			= 0
	,[ysnRecomputeTax]			= 1
	,[intTicketHoursWorkedId]	= BILLABLE.intTicketHoursWorkedId
	,[dblCurrencyExchangeRate]	= 1.000000
FROM #BILLABLE BILLABLE

IF EXISTS (SELECT TOP 1 NULL FROM @tblInvoiceEntries)
	BEGIN
		EXEC dbo.[uspARProcessInvoices]
			 @InvoiceEntries				= @tblInvoiceEntries
			,@LineItemTaxEntries			= @tblTaxEntries
			,@UserId						= @UserId
			,@GroupingOption				= 5
			,@RaiseError					= 0
			,@ErrorMessage					= @strErrorMessage OUT
			,@CreatedIvoices				= @strCreatedInvoices OUT

		IF ISNULL(@strCreatedInvoices, '') <> ''
			BEGIN
				UPDATE TICKETS
				SET	TICKETS.intInvoiceId	= ID.intInvoiceId
				   ,TICKETS.ysnBilled		= CONVERT(BIT, 1)
				   ,TICKETS.dtmBilled		= @dtmDateOnly
				FROM tblHDTicketHoursWorked TICKETS
				INNER JOIN (
					SELECT intTicketHoursWorkedId
						 , intInvoiceId
					FROM dbo.tblARInvoiceDetail ID
					INNER JOIN fnGetRowsFromDelimitedValues(@strCreatedInvoices) I
					ON ID.intInvoiceId = I.intID
				) ID ON TICKETS.intTicketHoursWorkedId = ID.intTicketHoursWorkedId
				INNER JOIN #BILLABLE HW 
				ON TICKETS.intTicketId = HW.intTicketId
				AND TICKETS.intTicketHoursWorkedId = HW.intTicketHoursWorkedId

				UPDATE ID
				SET ID.strDocumentNumber = HW.strTicketNumber
				FROM tblARInvoiceDetail ID
				INNER JOIN fnGetRowsFromDelimitedValues(@strCreatedInvoices) I ON ID.intInvoiceId = I.intID
				INNER JOIN #BILLABLE HW ON ID.intTicketHoursWorkedId = HW.intTicketHoursWorkedId
	
				IF @Post = 1
				BEGIN
					EXEC [dbo].[uspARPostInvoice]
							@post				= 1,
							@recap				= 0,
							@param				= @strCreatedInvoices,
							@userId				= @UserId,
							@successfulCount	= @SuccessfulCount OUT,
							@invalidCount		= @InvalidCount OUT,
							@success			= @IsSuccess OUT,
							@batchIdUsed		= @BatchIdUsed OUT,
							@recapId			= NULL,
							@transType			= N'Invoice'				
				END 
			END
	END
	        
SET @IsSuccess = 1           
RETURN 1

END