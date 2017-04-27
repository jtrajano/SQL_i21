CREATE PROCEDURE [dbo].[uspARImportBillableHours]
	 @HoursWorkedIDs		AS NVARCHAR(MAX)	= 'all'
	,@Post					AS BIT				= 0	
	,@UserId				AS INT				= 1
	,@IsSuccess				AS BIT				= 0		OUTPUT
	,@BatchIdUsed			AS NVARCHAR(20)		= NULL	OUTPUT
	,@SuccessfulCount		AS INT				= 0		OUTPUT
	,@InvalidCount			AS INT				= 0		OUTPUT
	,@DocumentMaintenanceId AS INT				= NULL
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
SET @CompanyLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1)

DECLARE @TicketHoursWorked TABLE(
		intTicketHoursWorkedId INT,
		intEntityCustomerId INT,
		intTicketId INT)
		
IF (@HoursWorkedIDs IS NOT NULL) 
BEGIN
	IF(@HoursWorkedIDs = 'all')
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId], [intEntityCustomerId], [intTicketId] FROM vyuARBillableHoursForImport
	END
	ELSE
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId], [intEntityCustomerId], [intTicketId] FROM vyuARBillableHoursForImport WHERE [intTicketHoursWorkedId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@HoursWorkedIDs))
	END
END

--VALIDATE NULL TERMS

DECLARE @NullTermsTable TABLE(intEntityCustomerId INT)
INSERT INTO @NullTermsTable 
SELECT
	THW.intEntityCustomerId 
FROM
	@TicketHoursWorked THW
INNER JOIN
	(SELECT intEntityCustomerId, intTermsId FROM tblARCustomer) ARC ON THW.intEntityCustomerId = ARC.intEntityCustomerId 
WHERE ARC.intTermsId IS NULL


IF EXISTS(SELECT * FROM @NullTermsTable)
BEGIN
	RAISERROR('Some of the customers doesn''t have Terms setup.', 16, 1) 
	RETURN 0
END

DECLARE @NewInvoices AS TABLE (intEntityCustomerId INT, intCompanyLocationId INT)
DECLARE @NewlyCreatedInvoices AS TABLE (intInvoiceId INT)

INSERT INTO @NewInvoices
SELECT DISTINCT
	V.[intEntityCustomerId]
	,ISNULL(V.[intCompanyLocationId], @CompanyLocationId)
FROM
	vyuARBillableHoursForImport V
INNER JOIN
	@TicketHoursWorked HW
		ON V.[intTicketId] = HW.[intTicketId]
INNER JOIN
	tblARCustomer C
		ON V.[intEntityCustomerId] = C.[intEntityCustomerId]		
GROUP BY
	V.[intEntityCustomerId]
	,ISNULL(V.[intCompanyLocationId], @CompanyLocationId)

WHILE EXISTS(SELECT TOP 1 NULL FROM @NewInvoices)
	BEGIN
		DECLARE @EntityCustomerId AS INT
				,@ComLocationId AS INT
				,@NewInvoiceId AS INT
				,@ErrorMessage nvarchar(250)
				
		SELECT TOP 1 @EntityCustomerId = intEntityCustomerId, @ComLocationId = intCompanyLocationId FROM @NewInvoices
 
 

				
		EXEC [dbo].[uspARCreateCustomerInvoice]
			@EntityCustomerId = @EntityCustomerId,
			@InvoiceDate = @DateOnly,
			@CompanyLocationId = @ComLocationId,
			@EntityId = @UserId,
			@NewInvoiceId = @NewInvoiceId OUTPUT,
			@ErrorMessage = @ErrorMessage OUTPUT,
			@DocumentMaintenanceId = @DocumentMaintenanceId
			
		IF @NewInvoiceId IS NULL 
		BEGIN
			RAISERROR(@ErrorMessage, 11, 1) 
			RETURN 0
		END
		
		INSERT INTO [tblARInvoiceDetail]
			([intInvoiceId]
			,[intItemId]
			,[strItemDescription]
			,[intItemUOMId]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[dblQtyShipped]
			,[dblPrice]
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
			,IC.[strDescription] + ' - ' + V.strTicketNumber			--strItemDescription] 
			,V.intItemUOMId												--[intItemUOMId]
			,ISNULL(IL.intIssueUOMId, V.intItemUOMId)					--[intOrderUOMId]
			,V.[intHours]												--[dblQtyOrdered]
			,V.[intHours]												--[dblQtyShipped]
			,V.[dblPrice] 												--[dblPrice]
			,V.[dblTotal]  												--[dblTotal]
			,Acct.[intAccountId]										--[intAccountId]
			,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
			,Acct.[intSalesAccountId]									--[intSalesAccountId]
			,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
			,V.[intTicketHoursWorkedId]									--[intTicketHoursWorkedId]
			,1															--[intConcurrencyId]
		FROM
			vyuARBillableHoursForImport V
		INNER JOIN
			@TicketHoursWorked HW
				ON V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]
		INNER JOIN
			tblICItem IC
				ON V.[intItemId] = IC.[intItemId]
		INNER JOIN
			tblICItemLocation IL
				ON V.intItemId = IL.intItemId
				AND V.intCompanyLocationId = IL.intLocationId
		LEFT OUTER JOIN
			vyuARGetItemAccount Acct
				ON V.[intItemId] = Acct.[intItemId]
					AND V.[intCompanyLocationId] = Acct.[intLocationId]
		WHERE
			V.intEntityCustomerId = @EntityCustomerId
			AND ISNULL(V.intCompanyLocationId,@CompanyLocationId) = @ComLocationId
		
		EXEC dbo.uspARReComputeInvoiceTaxes @InvoiceId = @NewInvoiceId
		
		INSERT INTO @NewlyCreatedInvoices
		SELECT @NewInvoiceId
		
		DELETE FROM @NewInvoices WHERE intEntityCustomerId = @EntityCustomerId AND intCompanyLocationId = @ComLocationId
	END
							
UPDATE
	tblHDTicketHoursWorked
SET
	tblHDTicketHoursWorked.[intInvoiceId] = I.[intInvoiceId]
FROM
	[tblARInvoice] I
INNER JOIN
	[tblARInvoiceDetail] D
		ON I.[intInvoiceId] = D.[intInvoiceId]
INNER JOIN
	tblHDTicketHoursWorked V
		ON D.[intTicketHoursWorkedId] = V.[intTicketHoursWorkedId]
INNER JOIN
	@TicketHoursWorked HW
		ON V.[intTicketId] = HW.[intTicketId]
		AND V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId] 
		                    
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