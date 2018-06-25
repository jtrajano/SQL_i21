﻿CREATE PROCEDURE [dbo].[uspARImportBillableHours]
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

SELECT intEntityCustomerId				= intEntityId
	 , intTicketId						= intTicketId
	 , intTicketHoursWorkedId			= intTicketHoursWorkedId
	 , intCompanyLocationId				= intCompanyLocationId
	 , intCurrencyId					= intCurrencyId
	 , intSubCurrencyId					= intSubCurrencyId
	 , intItemId						= intItemId
	 , intItemUOMId						= intItemUOMId
	 , intCurrencyExchangeRateTypeId	= intCurrencyExchangeRateTypeId	 
	 , strItemNo						= strItemNo
	 , dblHours							= CAST(intHours AS NUMERIC(18, 6))
	 , dblPrice							= dblPrice
	 , dblCurrencyExchangeRate			= dblCurrencyExchangeRate
	 , dblSubCurrencyRate				= dblSubCurrencyRate
	 , strTicketNumber					= CAST(strTicketNumber COLLATE Latin1_General_CI_AS AS NVARCHAR(100))
	 , strSubject						= CAST(strSubject COLLATE Latin1_General_CI_AS AS NVARCHAR(300))
INTO #BILLABLE
FROM vyuARBillableHoursForImport
WHERE 1 = 0
		
IF ISNULL(@HoursWorkedIDs, 'all') = 'all'
	BEGIN
		INSERT INTO #BILLABLE 
		SELECT intEntityCustomerId				= BILLABLE.intEntityId
			 , intTicketId						= BILLABLE.intTicketId
			 , intTicketHoursWorkedId			= BILLABLE.intTicketHoursWorkedId
			 , intCompanyLocationId				= ISNULL(BILLABLE.intEntityWarehouseId, ISNULL(@intCompanyLocationId, BILLABLE.intCompanyLocationId))
			 , intCurrencyId					= BILLABLE.intCurrencyId
			 , intSubCurrencyId					= BILLABLE.intSubCurrencyId
			 , intItemId						= BILLABLE.intItemId
			 , intItemUOMId						= BILLABLE.intItemUOMId
			 , intCurrencyExchangeRateTypeId	= BILLABLE.intCurrencyExchangeRateTypeId	 
			 , strItemNo						= BILLABLE.strItemNo
			 , dblHours							= CAST(BILLABLE.intHours AS NUMERIC(18, 6))
			 , dblPrice							= BILLABLE.dblPrice
			 , dblCurrencyExchangeRate			= BILLABLE.dblCurrencyExchangeRate
			 , dblSubCurrencyRate				= BILLABLE.dblSubCurrencyRate
			 , strTicketNumber					= BILLABLE.strTicketNumber
			 , strSubject						= BILLABLE.strSubject
		FROM vyuARBillableHoursForImport BILLABLE
	END
ELSE
	BEGIN
		INSERT INTO #BILLABLE 
		SELECT intEntityCustomerId				= BILLABLE.intEntityId
			 , intTicketId						= BILLABLE.intTicketId
			 , intTicketHoursWorkedId			= BILLABLE.intTicketHoursWorkedId
			 , intCompanyLocationId				= ISNULL(BILLABLE.intEntityWarehouseId, ISNULL(@intCompanyLocationId, BILLABLE.intCompanyLocationId))
			 , intCurrencyId					= BILLABLE.intCurrencyId
			 , intSubCurrencyId					= BILLABLE.intSubCurrencyId
			 , intItemId						= BILLABLE.intItemId
			 , intItemUOMId						= BILLABLE.intItemUOMId
			 , intCurrencyExchangeRateTypeId	= BILLABLE.intCurrencyExchangeRateTypeId	 
			 , strItemNo						= BILLABLE.strItemNo
			 , dblHours							= CAST(BILLABLE.intHours AS NUMERIC(18, 6))
			 , dblPrice							= BILLABLE.dblPrice
			 , dblCurrencyExchangeRate			= BILLABLE.dblCurrencyExchangeRate
			 , dblSubCurrencyRate				= BILLABLE.dblSubCurrencyRate
			 , strTicketNumber					= BILLABLE.strTicketNumber
			 , strSubject						= BILLABLE.strSubject
		FROM vyuARBillableHoursForImport BILLABLE
		INNER JOIN fnGetRowsFromDelimitedValues(@HoursWorkedIDs) SELECTED
		ON SELECTED.intID = BILLABLE.intTicketHoursWorkedId
	END

IF(OBJECT_ID('tempdb..#INACTIVECUSTOMERS') IS NOT NULL)
BEGIN
    DROP TABLE #INACTIVECUSTOMERS
END

SELECT C.strName
INTO #INACTIVECUSTOMERS
FROM #BILLABLE B
INNER JOIN vyuARCustomerSearch C ON B.intEntityCustomerId = C.intEntityCustomerId
WHERE C.ysnActive = 0

IF EXISTS (SELECT TOP 1 NULL FROM #INACTIVECUSTOMERS)
	BEGIN
		DECLARE @strErrorMsg  NVARCHAR(500) = 'Customer: ' + ISNULL((SELECT TOP 1 strName FROM #INACTIVECUSTOMERS), '') + ' is Inactive.'
		SET @IsSuccess = 0

		RAISERROR(@strErrorMsg, 16, 1)
		RETURN 0
	END
	
INSERT INTO @tblInvoiceEntries (
	 [strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
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
	,[intSubCurrencyId]
	,[dblSubCurrencyRate]
	,[intCurrencyExchangeRateTypeId]
)
SELECT 
	 [strSourceTransaction]				= 'Direct'
	,[intSourceId]						= 0
	,[strSourceId]						= BILLABLE.strTicketNumber
	,[intEntityCustomerId]				= BILLABLE.intEntityCustomerId
	,[intCompanyLocationId]				= BILLABLE.intCompanyLocationId
	,[intCurrencyId]					= BILLABLE.intCurrencyId
	,[dtmDate]							= @dtmDateOnly
	,[dtmPostDate]						= @dtmDateOnly
	,[intEntityId]						= @UserId
	,[ysnPost]							= 0
	,[intItemId]						= BILLABLE.intItemId
	,[ysnInventory]						= 0
	,[strItemDescription]				= BILLABLE.strTicketNumber + ' - ' + BILLABLE.strSubject
	,[intOrderUOMId]					= BILLABLE.intItemUOMId
	,[dblQtyOrdered]					= BILLABLE.dblHours
	,[intItemUOMId]						= BILLABLE.intItemUOMId
	,[dblQtyShipped]					= BILLABLE.dblHours
	,[dblPrice]							= BILLABLE.dblPrice
	,[ysnRefreshPrice]					= 0
	,[ysnRecomputeTax]					= 1
	,[intTicketHoursWorkedId]			= BILLABLE.intTicketHoursWorkedId
	,[dblCurrencyExchangeRate]			= BILLABLE.dblCurrencyExchangeRate
	,[intSubCurrencyId]					= BILLABLE.intSubCurrencyId
	,[dblSubCurrencyRate]				= BILLABLE.dblSubCurrencyRate
	,[intCurrencyExchangeRateTypeId]	= BILLABLE.intCurrencyExchangeRateTypeId
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
					DECLARE	@batchId		NVARCHAR(20),
							@SuccessCount	INT,
							@InvCount		INT
				
					EXEC [dbo].[uspARPostInvoice]
							@post				= 1,
							@recap				= 0,
							@param				= @strCreatedInvoices,
							@userId				= @UserId,
							@successfulCount	= @SuccessCount OUT,
							@invalidCount		= @InvCount OUT,
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