CREATE PROCEDURE [dbo].[uspARAddInvoice]
	 @InvoiceEntries InvoiceStagingTable READONLY	
	,@intUserId AS INT		
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal decimal(18,6)
		,@ARAccountId int

SET @ZeroDecimal = 0.000000
	



SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)


IF(@ARAccountId IS NULL OR @ARAccountId = 0)  
	BEGIN			
		RAISERROR('There is no setup for AR Account in the Company Preference.', 11, 1) 
		RETURN 0
	END

DECLARE @StartingNumberId_Invoice AS INT = 19;
DECLARE @total as INT;
DECLARE @incval as INT;
DECLARE @InvoiceNumber as nvarchar(50);
DECLARE @temp TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
    Customer int,
	Location int,
	strSource nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	dtmDate DATETIME ,
	Currency int ,
	Salesperson int ,
	Shipvia int,
	Comments nvarchar(250) COLLATE Latin1_General_CI_AS NULL,
	PurchaseOrder nvarchar(25) COLLATE Latin1_General_CI_AS NULL,
    InvoiceNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL
    )

insert into @temp(Customer ,
				  Location,
				  strSource,
				  dtmDate,
				  Currency,
				  Salesperson,
				  Shipvia,
				  Comments,
				  PurchaseOrder,
				  InvoiceNumber 
				  )
		select intEntityCustomerId,intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,IE.strPurchaseOrder,null from @InvoiceEntries IE
				       group by IE.intEntityCustomerId,IE.intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,IE.strPurchaseOrder

select @total = count(*) from @temp;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   EXEC dbo.uspSMGetStartingNumber @StartingNumberId_Invoice, @InvoiceNumber OUTPUT 

   IF @InvoiceNumber IS NULL 
   BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	   RAISERROR(50030, 11, 1);
	   RETURN;
   END 
   update @temp 
       set InvoiceNumber = @InvoiceNumber
         where intId = @incval 
   SET @incval = @incval + 1;
END;	

DISABLE TRIGGER dbo.trgInvoiceNumber ON dbo.tblARInvoice;
INSERT INTO 
	[tblARInvoice]	   
		([strInvoiceNumber]
		,[strInvoiceOriginId]
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
		,[intShipToLocationId] 
		,[strShipToLocationName]
		,[strShipToAddress]
		,[strShipToCity]
		,[strShipToState]
		,[strShipToZipCode]
		,[strShipToCountry]
		,[intBillToLocationId]
		,[strBillToLocationName]
		,[strBillToAddress]
		,[strBillToCity]
		,[strBillToState]
		,[strBillToZipCode]
		,[strBillToCountry]
		,[intConcurrencyId]
		,[intEntityId])
SELECT
     TE.InvoiceNumber           -- invoice number
	,IE.strSourceId				--[strInvoiceOriginId]
	,IE.[intEntityCustomerId]	--[intEntityCustomerId]
	,IE.dtmDate  				--[dtmDate]
	,dbo.fnGetDueDateBasedOnTerm(IE.dtmDate, ISNULL(EL.[intTermsId],0))	--[dtmDueDate]
	,ISNULL(IE.intCurrencyId,min(AC.[intCurrencyId]))									--[intCurrencyId]
	,ISNULL(IE.intLocationId, (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1))	--[intCompanyLocationId]
	,ISNULL(IE.[intSalesPersonId],min(AC.[intSalespersonId]))		--[intEntitySalespersonId]
	,IE.dtmDate  				--[dtmShipDate]
	,ISNULL(IE.intShipViaId,ISNULL(min(EL.[intShipViaId]), 0))  --[intShipViaId]
	,IE.strPurchaseOrder    	--[strPONumber]
	,EL.[intTermsId]			--[intTermId]
	,0          				--[dblInvoiceSubtotal] need to check
	,@ZeroDecimal				--[dblShipping]
	,@ZeroDecimal				--[dblTax]
	,0        				    --[dblInvoiceTotal] need to check
	,@ZeroDecimal				--[dblDiscount]
	,0				            --[[dblAmountDue]] need to check
	,@ZeroDecimal				--[dblPayment]
	,'Invoice'					--[strTransactionType]
	,0							--[intPaymentMethodId]
	,IE.strComments        	    --[strComments] 
	,@ARAccountId				--[intAccountId]
	,IE.dtmDate 				--[dtmPostDate] need to check
	,0							--[ysnPosted]
	,0							--[ysnPaid]
	,ISNULL(min(AC.[intShipToId]), min(EL.[intEntityLocationId]))			--[intShipToLocationId] 
	,min(SL.[strLocationName])		--[strShipToLocationName]
	,min(SL.[strAddress])			--[strShipToAddress]
	,min(SL.[strCity])				--[strShipToCity]
	,min(SL.[strState])				--[strShipToState]
	,min(SL.[strZipCode])			--[strShipToZipCode]
	,min(SL.[strCountry])			--[strShipToCountry]
	,ISNULL(min(AC.[intBillToId]), min(EL.[intEntityLocationId]))			--[intBillToLocationId] 
	,min(BL.[strLocationName])		--[strBillToLocationName]
	,min(BL.[strAddress])			--[strBillToAddress]
	,min(BL.[strCity])				--[strBillToCity]
	,min(BL.[strState])				--[strBillToState]
	,min(BL.[strZipCode])			--[strBillToZipCode]
	,min(BL.[strCountry])			--[strBillToCountry]
	,1
	,@intUserId
FROM
	@InvoiceEntries IE
	Join @temp TE
       on TE.Customer = IE.intEntityCustomerId and TE.Location = IE.intLocationId
INNER JOIN
	tblARCustomer AC
		ON IE.[intEntityCustomerId] = AC.[intEntityCustomerId]
LEFT OUTER JOIN
				(	SELECT
						[intEntityLocationId]
						,[intEntityId] 
						,[strCountry]
						,[strState]
						,[strCity]
						,[intTermsId]
						,[intShipViaId]
					FROM 
					tblEntityLocation
					WHERE
						ysnDefaultLocation = 1
				) EL
					ON AC.[intEntityCustomerId] = EL.[intEntityId]
LEFT OUTER JOIN
	tblEntityLocation SL
		ON AC.intShipToId = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON AC.intShipToId = BL.intEntityLocationId	
group by TE.InvoiceNumber,IE.intEntityCustomerId,IE.intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,EL.intTermsId,IE.strPurchaseOrder;				


ENABLE TRIGGER dbo.trgInvoiceNumber ON dbo.tblARInvoice;
		
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
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
	IV.[intInvoiceId]											--[intInvoiceId]
	,IE.[intItemId]												--[intItemId]
	,IC.[strDescription]										--strItemDescription] 
	,(SELECT	TOP 1 
										IU.intItemUOMId		
										FROM	dbo.tblICItemUOM IU
										WHERE	IU.intItemId = IE.intItemId)	--[intItemUOMId]
	,IE.dblQty   												--[dblQtyOrdered]
	,IE.dblQty  												--[dblQtyShipped]
	,IE.[dblPrice] 												--[dblPrice]
	,0          												--[dblTotal]
	,Acct.[intAccountId]										--[intAccountId]
	,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
	,Acct.[intSalesAccountId]									--[intSalesAccountId]
	,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
	,1															--[intConcurrencyId]
FROM
    @InvoiceEntries IE
	JOIN @temp TE
	on TE.Customer = IE.intEntityCustomerId and TE.Location = IE.intLocationId	
	JOIN tblARInvoice IV
	    on TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
    INNER JOIN
	 	tblICItem IC
	 		ON IE.[intItemId] = IC.[intItemId] 
	 LEFT OUTER JOIN
	 	vyuARGetItemAccount Acct
	 		ON IE.[intItemId] = Acct.[intItemId]
	 			AND IE.[intLocationId] = Acct.[intLocationId]
		

		
DECLARE @Invoices AS TABLE(intInvoiceID INT)
INSERT INTO @Invoices 
SELECT DISTINCT
	IV.[intInvoiceId]
FROM 
	[tblARInvoice] IV
JOIN @temp TE
     on TE.InvoiceNumber = IV.strInvoiceNumber;

DECLARE @InvoiceId as int;		
WHILE EXISTS(SELECT NULL FROM @Invoices)
BEGIN
	SELECT TOP 1 @InvoiceId = [intInvoiceID] FROM @Invoices
	EXEC [dbo].[uspARReComputeInvoiceTaxes] @InvoiceId
	--this is added because the reCompute invoice Taxes does not update the totals correctly
	-- need to review this
    UPDATE
		tblARInvoiceDetail
		SET [dblTotal]		= ROUND((([dblPrice] * [dblQtyShipped]) + [dblTotalTax]),2)
		where intInvoiceId = @InvoiceId
	
	UPDATE
		tblARInvoice
		SET [dblInvoiceTotal]		= (select SUM(dblTotal) from tblARInvoiceDetail where intInvoiceId = @InvoiceId)
		where intInvoiceId = @InvoiceId

	DELETE FROM @Invoices WHERE [intInvoiceID] = @InvoiceId
END
  
-- Output the values to calling SP  
      
select IE.intSourceId,
       IV.intInvoiceId
FROM
    @InvoiceEntries IE
	JOIN @temp TE
	on TE.Customer = IE.intEntityCustomerId and TE.Location = IE.intLocationId	
	JOIN tblARInvoice IV
	    on TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId	       
END           