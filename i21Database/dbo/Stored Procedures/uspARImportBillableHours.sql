﻿CREATE PROCEDURE [dbo].[uspARImportBillableHours]
	 @HoursWorkedIDs	AS NVARCHAR(MAX)	= 'all'
	,@Post				AS BIT				= 0	
	,@UserId			AS INT				= 1
	,@IsSuccess			AS BIT				= 0		OUTPUT
	,@BatchIdUsed		AS NVARCHAR(20)		= NULL	OUTPUT
	,@SuccessfulCount	AS INT				= 0		OUTPUT
	,@InvalidCount		AS INT				= 0		OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal decimal(18,6)
		,@DateOnly DATETIME
		,@Currency int

SET @ZeroDecimal = 0.000000
	
SELECT @DateOnly = CAST(GETDATE() as date)

SET @Currency = ISNULL((SELECT strValue FROM tblSMPreferences WHERE strPreference = 'defaultCurrency'),0)

DECLARE @TicketHoursWorked TABLE(
		intTicketHoursWorkedId INT)
		
IF (@HoursWorkedIDs IS NOT NULL) 
BEGIN
	IF(@HoursWorkedIDs = 'all')
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId] FROM vyuARBillableHoursForImport
	END
	ELSE
	BEGIN
		INSERT INTO @TicketHoursWorked SELECT [intTicketHoursWorkedId] FROM vyuARBillableHoursForImport WHERE [intTicketHoursWorkedId] IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@HoursWorkedIDs))
	END
END		

INSERT INTO 
	[tblARInvoice]
		([strInvoiceOriginId]
		,[intEntityCustomerId]
		,[dtmDate]
		,[dtmDueDate]
		,[intCurrencyId]
		,[intCompanyLocationId]
		,[intEntitySalespersonId]
		,[dtmShipDate]
		,[intShipViaId]
		,[strPONumber]
		,[intTermId]
		,[dblInvoiceSubtotal]
		,[dblShipping]
		,[dblTax]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[strTransactionType]
		,[intPaymentMethodId]
		,[strComments]
		,[intAccountId]
		,[dtmPostDate]
		,[ysnPosted]
		,[ysnPaid]
		,[strShipToLocationName]
		,[strShipToAddress]
		,[strShipToCity]
		,[strShipToState]
		,[strShipToZipCode]
		,[strShipToCountry]
		,[strBillToLocationName]
		,[strBillToAddress]
		,[strBillToCity]
		,[strBillToState]
		,[strBillToZipCode]
		,[strBillToCountry]
		,[intConcurrencyId]
		,[intEntityId])
SELECT
	NULL						--[strInvoiceOriginId]
	,V.[intEntityCustomerId]	--[intEntityCustomerId]
	,V.[dtmDate]				--[dtmDate]
	,dbo.fnGetDueDateBasedOnTerm(V.[dtmDate], ISNULL(EL.[intTermsId],0))	--[dtmDueDate]
	,ISNULL(C.[intCurrencyId], @Currency)									--[intCurrencyId]
	,V.[intCompanyLocationId]	--[intCompanyLocationId]
	,V.[intAgentEntityId]		--[intEntitySalespersonId]
	,V.[dtmDate]				--[dtmShipDate]
	,ISNULL(EL.[intShipViaId], 0)											--[intShipViaId]
	,''							--[strPONumber]
	,EL.[intTermsId]			--[intTermId]
	,V.[dblTotal]				--[dblInvoiceSubtotal]
	,@ZeroDecimal				--[dblShipping]
	,@ZeroDecimal				--[dblTax]
	,V.[dblTotal]				--[dblInvoiceTotal]
	,@ZeroDecimal				--[dblDiscount]
	,V.[dblTotal]				--[[dblAmountDue]]
	,@ZeroDecimal				--[dblPayment]
	,'Invoice'					--[strTransactionType]
	,0							--[intPaymentMethodId]
	,V.[intTicketHoursWorkedId]	--[strComments] 
	,CL.[intARAccount]			--[intAccountId]
	,NULL						--[dtmPostDate]
	,0							--[ysnPosted]
	,0							--[ysnPaid]
	,SL.[strLocationName]		--[strShipToLocationName]
	,SL.[strAddress]			--[strShipToAddress]
	,SL.[strCity]				--[strShipToCity]
	,SL.[strState]				--[strShipToState]
	,SL.[strZipCode]			--[strShipToZipCode]
	,SL.[strCountry]			--[strShipToCountry]
	,BL.[strLocationName]		--[strBillToLocationName]
	,BL.[strAddress]			--[strBillToAddress]
	,BL.[strCity]				--[strBillToCity]
	,BL.[strState]				--[strBillToState]
	,BL.[strZipCode]			--[strBillToZipCode]
	,BL.[strCountry]			--[strBillToCountry]
	,1
	,@UserId
FROM
	vyuARBillableHoursForImport V
INNER JOIN
	@TicketHoursWorked HW
		ON V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]
INNER JOIN
	tblARCustomer C
		ON V.[intEntityCustomerId] = C.[intEntityCustomerId]
INNER JOIN
	tblEntityLocation EL
		ON C.[intEntityCustomerId] = EL.[intEntityId]
INNER JOIN
	tblSMCompanyLocation CL
		ON V.[intCompanyLocationId] = CL.[intCompanyLocationId]
LEFT OUTER JOIN
	tblEntityLocation SL
		ON C.intShipToId = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON C.intShipToId = BL.intEntityLocationId							

		
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intCompanyLocationId]
	,[intItemId]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblPrice]
	,[dblTotal]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intConcurrencyId])
SELECT
	I.[intInvoiceId]											--[intInvoiceId]
	,V.[intCompanyLocationId]									--[intCompanyLocationId]
	,V.[intItemId]												--[intItemId]
	,V.[strTicketNumber] + ' - ' + V.[strJobCode]				--strItemDescription]
	,NULL														--[intItemUOMId]
	,V.[intHours]												--[dblQtyOrdered]
	,V.[intHours]												--[dblQtyShipped]
	,V.[dblPrice] 												--[dblPrice]
	,V.[dblTotal]  												--[dblTotal]
	,ISNULL(Acct.[intAccountId], CL.[intServiceCharges])		--[intAccountId]
	,ISNULL(Acct.[intCOGSAccountId], CL.[intCostofGoodsSold])	--[intCOGSAccountId]
	,ISNULL(Acct.[intSalesAccountId], CL.[intSalesAccount])		--[intSalesAccountId]
	,ISNULL(Acct.[intInventoryAccountId], CL.[intInventory])	--[intInventoryAccountId]
	,1															--[intConcurrencyId]
FROM
	[tblARInvoice] I
INNER JOIN
	vyuARBillableHoursForImport V
		ON RTRIM(I.[strComments]) = RTRIM(CONVERT(nvarchar(250),V.[intTicketHoursWorkedId]))
INNER JOIN
	@TicketHoursWorked HW
		ON V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]
LEFT OUTER JOIN
	vyuARGetItemAccount Acct
		ON V.[intItemId] = Acct.[intItemId]
LEFT OUTER JOIN
	tblSMCompanyLocation CL
		ON V.[intCompanyLocationId] = CL.[intCompanyLocationId]

		
UPDATE
	tblHDTicketHoursWorked
SET
	tblHDTicketHoursWorked.[intInvoiceId] = I.[intInvoiceId]
FROM
	[tblARInvoice] I
INNER JOIN
	tblHDTicketHoursWorked V
		ON RTRIM(I.[strComments]) = RTRIM(CONVERT(nvarchar(250),V.[intTicketHoursWorkedId]))
INNER JOIN
	@TicketHoursWorked HW
		ON V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]
	          
           
IF @Post = 1
	BEGIN
		DECLARE	@return_value int,
				@success bit,
				@minId int,
				@maxId int
				
		SELECT
			 @minId = MIN(I.[intInvoiceId])
			,@maxId = MAX(I.[intInvoiceId])
		FROM				
			[tblARInvoice] I
		INNER JOIN
			tblHDTicketHoursWorked V
				ON RTRIM(I.[strComments]) = RTRIM(CONVERT(nvarchar(250),V.[intTicketHoursWorkedId]))
		INNER JOIN
			@TicketHoursWorked HW
				ON V.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]				
				

		EXEC	@return_value = [dbo].[uspARPostInvoice]
				@batchId = NULL,
				@post = 1,
				@recap = 0,
				@param = NULL,
				@userId = @UserId,
				@beginDate = NULL,
				@endDate = NULL,
				@beginTransaction = @minId,
				@endTransaction = @maxId,
				@exclude = NULL,
				@successfulCount = @SuccessfulCount OUTPUT,
				@invalidCount = @InvalidCount OUTPUT,
				@success = @IsSuccess OUTPUT,
				@batchIdUsed = @BatchIdUsed OUTPUT,
				@recapId = NULL,
				@transType = N'Invoice'
	END 
	
	
UPDATE
	[tblARInvoice]
SET
	[tblARInvoice].[strComments] = T.[strTicketNumber] + ' - ' + JC.[strJobCode] 
FROM
	 tblHDTicketHoursWorked H
INNER JOIN
	tblHDJobCode JC
		ON H.[intJobCodeId] = JC.[intJobCodeId] 
INNER JOIN
	@TicketHoursWorked HW
		ON H.[intTicketHoursWorkedId] = HW.[intTicketHoursWorkedId]
INNER JOIN
	tblHDTicket T
		ON H.[intTicketId] = T.[intTicketId] 
WHERE
	[tblARInvoice].[strComments] = RTRIM(CONVERT(nvarchar(250),H.[intTicketHoursWorkedId])) 	  
	
	        
SET @IsSuccess = 1           
RETURN 1

END