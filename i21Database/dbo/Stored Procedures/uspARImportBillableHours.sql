CREATE PROCEDURE [dbo].[uspARImportBillableHours]
	 @HoursWorkedIDs		AS NVARCHAR(MAX)	= 'all'
	,@Post					AS BIT				= 0	
	,@UserId				AS INT				= 1
	,@IsSuccess				AS BIT				= 0		OUTPUT
	,@BatchIdUsed			AS NVARCHAR(20)		= NULL	OUTPUT
	,@SuccessfulCount		AS INT				= 0		OUTPUT
	,@InvalidCount			AS INT				= 0		OUTPUT
	,@DocumentMaintenanceId AS INT				= NULL
	,@DefaultLocationId AS INT				= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal		NUMERIC(18,6)
	  , @DateOnly			DATETIME
	  , @CompanyLocationId	INT

SET @ZeroDecimal = 0.000000	
SET @DateOnly = CAST(GETDATE() AS DATE)
SET @CompanyLocationId = @DefaultLocationId

DECLARE @TicketHoursWorked TABLE(intTicketHoursWorkedId INT, intEntityCustomerId INT, intTicketId INT)
		
IF (@HoursWorkedIDs IS NOT NULL) 
BEGIN
	IF(@HoursWorkedIDs = 'all')
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId], [intEntityId], [intTicketId] FROM vyuARBillableHoursForImport
	END
	ELSE
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId], [intEntityId], [intTicketId] FROM vyuARBillableHoursForImport WHERE [intTicketHoursWorkedId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@HoursWorkedIDs))
	END
END

--VALIDATE NULL TERMS
IF EXISTS(SELECT THW.intEntityCustomerId 
		  FROM @TicketHoursWorked THW
		  INNER JOIN (
				SELECT intEntityId
					 , intTermsId 
				FROM dbo.tblARCustomer WITH (NOLOCK)
		  ) ARC ON THW.intEntityCustomerId = ARC.intEntityId
		  WHERE ARC.intTermsId IS NULL)
BEGIN
	RAISERROR('Some of the customers doesn''t have Terms setup.', 16, 1) 
	RETURN 0
END

DECLARE @NewInvoices TABLE(intEntityCustomerId INT
	, intCompanyLocationId INT
	, intCurrencyId INT
	, intCurrencyExchangeRateTypeId INT
	, dblCurrencyExchangeRate DECIMAL(18,6)
	, intSubCurrencyId INT
	, dblSubCurrencyRate DECIMAL(18,6))
DECLARE @NewlyCreatedInvoices TABLE(intInvoiceId INT)

INSERT INTO @NewInvoices
SELECT DISTINCT V.intEntityId
			  , ISNULL(V.intEntityWarehouseId, ISNULL(@CompanyLocationId,V.intCompanyLocationId))
			  , MAX(V.intCurrencyId)
			  , MAX(V.intCurrencyExchangeRateTypeId)
			  , MAX(V.dblCurrencyExchangeRate)
			  , MAX(V.intSubCurrencyId)
			  , MAX(V.dblSubCurrencyRate)
FROM vyuARBillableHoursForImport V
INNER JOIN @TicketHoursWorked HW ON V.intTicketId = HW.intTicketId
INNER JOIN tblARCustomer C ON V.intEntityId = C.intEntityId
GROUP BY V.intEntityId, ISNULL(V.intEntityWarehouseId, ISNULL(@CompanyLocationId,V.intCompanyLocationId))

WHILE EXISTS(SELECT TOP 1 NULL FROM @NewInvoices)
	BEGIN
		DECLARE @EntityCustomerId INT
			  , @ComLocationId INT
			  , @NewInvoiceId INT
			  , @ErrorMessage NVARCHAR(250)
			  , @CustomerName NVARCHAR(250)
			  , @CurrencyId INT
			  , @ItemCurrencyExchangeRateTypeId INT
			  , @ItemCurrencyExchangeRate DECIMAL(18,6)
			  , @ItemSubCurrencyId INT
			  , @ItemSubCurrencyRate DECIMAL(18,6)

		SELECT TOP 1 @EntityCustomerId = intEntityCustomerId
		           , @ComLocationId = intCompanyLocationId 
				   , @CurrencyId = intCurrencyId
				   , @ItemCurrencyExchangeRateTypeId = intCurrencyExchangeRateTypeId
				   , @ItemCurrencyExchangeRate = dblCurrencyExchangeRate
				   , @ItemSubCurrencyId = intSubCurrencyId
				   , @ItemSubCurrencyRate = dblSubCurrencyRate
		FROM @NewInvoices
				
		EXEC [dbo].[uspARCreateCustomerInvoice]
			@EntityCustomerId = @EntityCustomerId,
			@InvoiceDate = @DateOnly,
			@CompanyLocationId = @ComLocationId,
			@EntityId = @UserId,
			@NewInvoiceId = @NewInvoiceId OUTPUT,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@DocumentMaintenanceId = @DocumentMaintenanceId,
			@CurrencyId = @CurrencyId,
			@ItemCurrencyExchangeRateTypeId = @ItemCurrencyExchangeRateTypeId,
			@ItemCurrencyExchangeRate = @ItemCurrencyExchangeRate,
			@ItemSubCurrencyId = @ItemSubCurrencyId,
			@ItemSubCurrencyRate = @ItemSubCurrencyRate
			
		IF ISNULL(@NewInvoiceId, 0) = 0 OR ISNULL(@ErrorMessage, '') <> ''
		BEGIN
			IF NOT EXISTS (SELECT NULL FROM tblSMCompanyLocation WHERE intCompanyLocationId = @ComLocationId AND ysnLocationActive = 1)
				BEGIN
					SELECT TOP 1 @CustomerName = strName FROM tblEMEntity WHERE intEntityId = @EntityCustomerId
					SET @ErrorMessage = 'The Company Location provided for Customer: ' + @CustomerName + ' is not active!'
				END

			DELETE FROM @TicketHoursWorked WHERE intEntityCustomerId = @EntityCustomerId
			SET @NewInvoiceId = NULL
			RAISERROR(@ErrorMessage, 11, 1) 
			BREAK
		END
		
		INSERT INTO [tblARInvoiceDetail]
			([intInvoiceId]
			,[intItemId]
			,[strItemDescription]
			,[intItemUOMId]
			--,[intOrderUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblPrice]
			,[intCurrencyExchangeRateTypeId]
			,[dblCurrencyExchangeRate]
			,[dblTotal]
			,[intAccountId]
			,[intCOGSAccountId]
			,[intSalesAccountId]
			,[intInventoryAccountId]
			,[intTicketHoursWorkedId]
			,[intConcurrencyId])
		SELECT
			@NewInvoiceId												--[intInvoiceId]
			,V.[intItemId]												--[intItemId]
			--,IC.[strDescription] + ' - ' + V.strTicketNumber			--strItemDescription] 
			,V.strTicketNumber + ' - ' + V.strSubject					--strItemDescription] 
			,V.intItemUOMId												--[intItemUOMId]
			--,ISNULL(IL.intIssueUOMId, V.intItemUOMId)					--[intOrderUOMId]
			,V.[intHours]												--[dblQtyOrdered]
			,V.[intHours]												--[dblQtyShipped]
			,V.[dblPrice] 												--[dblPrice]
			,V.[intCurrencyExchangeRateTypeId]
			,V.[dblCurrencyExchangeRate]
			,V.[dblTotal]  												--[dblTotal]
			,Acct.[intAccountId]										--[intAccountId]
			,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
			,Acct.[intSalesAccountId]									--[intSalesAccountId]
			,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
			,V.[intTicketHoursWorkedId]									--[intTicketHoursWorkedId]
			,1															--[intConcurrencyId]
		FROM vyuARBillableHoursForImport V
		INNER JOIN @TicketHoursWorked HW ON V.intTicketHoursWorkedId = HW.intTicketHoursWorkedId
		INNER JOIN tblICItem IC ON V.intItemId = IC.intItemId
		--INNER JOIN tblICItemLocation IL ON V.intItemId = IL.intItemId
		--							   AND V.intCompanyLocationId = IL.intLocationId
		LEFT OUTER JOIN vyuARGetItemAccount Acct ON V.intItemId = Acct.intItemId
									  AND V.intCompanyLocationId = Acct.intLocationId
		WHERE V.intEntityId = @EntityCustomerId
			AND ISNULL(@CompanyLocationId, V.intCompanyLocationId) = @ComLocationId
		
		EXEC dbo.uspARReComputeInvoiceTaxes @InvoiceId = @NewInvoiceId
		
		IF ISNULL(@NewInvoiceId, 0) <> 0
			BEGIN
				INSERT INTO @NewlyCreatedInvoices
				SELECT @NewInvoiceId
			END
		
		DELETE FROM @NewInvoices WHERE intEntityCustomerId = @EntityCustomerId AND intCompanyLocationId = @ComLocationId
	END
	
UPDATE 
	tblHDTicketHoursWorked
SET
	 tblHDTicketHoursWorked.intInvoiceId = I.intInvoiceId
	,tblHDTicketHoursWorked.ysnBilled = convert(bit,1)
	,tblHDTicketHoursWorked.dtmBilled = GETDATE()
FROM 
	@NewlyCreatedInvoices I
INNER JOIN
	tblARInvoiceDetail D 
		ON I.intInvoiceId = D.intInvoiceId
INNER JOIN
	tblHDTicketHoursWorked V 
		ON D.intTicketHoursWorkedId = V.intTicketHoursWorkedId
INNER JOIN
	@TicketHoursWorked HW 
		ON V.intTicketId = HW.intTicketId
		AND V.intTicketHoursWorkedId = HW.intTicketHoursWorkedId
		                    
IF @Post = 1
	BEGIN
		DECLARE	@return_value	INT,
				@success		BIT,
				@params			NVARCHAR(MAX),
				@batchId		NVARCHAR(20),
				@SuccessCount	INT,
				@InvCount		INT
				
		WHILE EXISTS(SELECT TOP 1 NULL FROM @NewlyCreatedInvoices)
			BEGIN
				DECLARE @intInvoiceId INT
				
				SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @NewlyCreatedInvoices ORDER BY intInvoiceId
				
				IF (SELECT COUNT(*) FROM @NewlyCreatedInvoices) > 1
					SELECT @params = ISNULL(@params, '') + CONVERT(NVARCHAR(50), intInvoiceId) + ', ' FROM @NewlyCreatedInvoices WHERE intInvoiceId = @intInvoiceId
				ELSE
					SELECT @params = ISNULL(@params, '') + CONVERT(NVARCHAR(50), intInvoiceId) FROM @NewlyCreatedInvoices WHERE intInvoiceId = @intInvoiceId

				DELETE FROM @NewlyCreatedInvoices WHERE intInvoiceId = @intInvoiceId
			END
		
		SELECT @params = intInvoiceId FROM @NewlyCreatedInvoices									
				
		EXEC	@return_value = [dbo].[uspARPostInvoice]
				@batchId = NULL,
				@post = 1,
				@recap = 0,
				@param = @params,
				@userId = @UserId,
				@beginDate = NULL,
				@endDate = NULL,
				@exclude = NULL,
				@successfulCount = @SuccessCount OUTPUT,
				@invalidCount = @InvCount OUTPUT,
				@success = @IsSuccess OUTPUT,
				@batchIdUsed = @batchId OUTPUT,
				@recapId = NULL,
				@transType = N'Invoice'
				
		SET @BatchIdUsed = @batchId
		SET @SuccessfulCount = @SuccessCount
		SET @InvalidCount = @InvCount
	END 
	        
SET @IsSuccess = 1           
RETURN 1

END