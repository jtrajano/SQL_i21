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
		,@EntityId int
		,@intFreightItemId int
SET @ZeroDecimal = 0.000000;
	



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
    InvoiceNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
    InvoiceId int NULL
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
				  InvoiceNumber,
				  InvoiceId 
				  )
		select intEntityCustomerId,intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,IE.strPurchaseOrder,null,intInvoiceId from @InvoiceEntries IE
				       group by IE.intEntityCustomerId,IE.intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,IE.strPurchaseOrder,IE.intInvoiceId

--select @total = count(*) from @temp;
--set @incval = 1 
--WHILE @incval <=@total 
WHILE EXISTS(SELECT NULL FROM @temp WHERE ISNULL(InvoiceNumber,'') = '' AND ISNULL(InvoiceId,0) = 0)
BEGIN
	SELECT TOP 1 @incval = intId FROM @temp WHERE ISNULL(InvoiceNumber,'') = '' AND ISNULL(InvoiceId,0) = 0 ORDER BY intId 
	
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
   --SET @incval = @incval + 1;
END;	

SELECT @EntityId =intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @intUserId;

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
		,[intDistributionHeaderId]
		,[intConcurrencyId]
		,[intEntityId]
		,[strDeliverPickup]
		,[strActualCostId]
		,[strBOLNumber]
)
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
	,ISNULL(min(IE.intShipToLocationId), min(EL.[intEntityLocationId]))			--[intShipToLocationId] 
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
	,IE.intSourceId
	,1
	,@EntityId
	,IE.strDeliverPickup
	,IE.strActualCostId
	,IE.strBOLNumber
FROM
	@InvoiceEntries IE
	Join @temp TE
       on TE.Customer = IE.intEntityCustomerId 
	   and TE.Location = IE.intLocationId 
	   and TE.strSource = IE.strSourceId
	   and TE.dtmDate = IE.dtmDate
	   and TE.Currency = IE.intCurrencyId
       and TE.Salesperson = IE.intSalesPersonId
	   and TE.Shipvia = IE.intShipViaId
	   and TE.Comments = IE.strComments
	   and TE.PurchaseOrder = IE.strPurchaseOrder	  
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
		ON IE.[intShipToLocationId] = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON AC.intShipToId = BL.intEntityLocationId	
WHERE
	IE.intInvoiceId IS NULL OR IE.intInvoiceId = 0
group by TE.InvoiceNumber,IE.intEntityCustomerId,IE.intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,EL.intTermsId,IE.strPurchaseOrder,IE.intSourceId,IE.strDeliverPickup,IE.strActualCostId,IE.strBOLNumber;				


ENABLE TRIGGER dbo.trgInvoiceNumber ON dbo.tblARInvoice;

UPDATE [tblARInvoice]
SET	   
	 [strInvoiceOriginId]		= IE.strSourceId
	,[intEntityCustomerId]		= IE.[intEntityCustomerId]
	,[dtmDate]					= IE.dtmDate
	,[dtmDueDate]				= dbo.fnGetDueDateBasedOnTerm(IE.dtmDate, ISNULL(EL.[intTermsId],0))
	,[intCurrencyId]			= ISNULL(IE.intCurrencyId,AC.[intCurrencyId])
	,[intCompanyLocationId]		= ISNULL(IE.intLocationId, (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1))
	,[intEntitySalespersonId]	= ISNULL(IE.[intSalesPersonId],AC.[intSalespersonId])
	,[dtmShipDate]				= IE.dtmDate
	,[intShipViaId]				= ISNULL(IE.intShipViaId,ISNULL(EL.[intShipViaId], 0))
	,[strPONumber]				= IE.strPurchaseOrder
	,[intTermId]				= EL.[intTermsId]
	,[dblInvoiceSubtotal]		= @ZeroDecimal
	,[dblShipping]				= @ZeroDecimal
	,[dblTax]					= @ZeroDecimal
	,[dblInvoiceTotal]			= @ZeroDecimal
	,[dblDiscount]				= @ZeroDecimal
	,[dblAmountDue]				= @ZeroDecimal
	,[dblPayment]				= @ZeroDecimal
	,[strTransactionType]		= 'Invoice'
	,[intPaymentMethodId]		= 0
	,[strComments]				= IE.strComments
	,[intAccountId]				= @ARAccountId
	,[dtmPostDate]				= NULL
	,[ysnPosted]				= 0
	,[ysnPaid]					= 0
	,[intShipToLocationId]		= ISNULL(IE.[intShipToLocationId], EL.[intEntityLocationId]) 
	,[strShipToLocationName]	= SL.[strLocationName]
	,[strShipToAddress]			= SL.[strAddress]
	,[strShipToCity]			= SL.[strCity]
	,[strShipToState]			= SL.[strState]
	,[strShipToZipCode]			= SL.[strZipCode]
	,[strShipToCountry]			= SL.[strCountry]
	,[intBillToLocationId]		= ISNULL(AC.[intBillToId],EL.[intEntityLocationId])
	,[strBillToLocationName]	= BL.[strLocationName]
	,[strBillToAddress]			= BL.[strAddress]
	,[strBillToCity]			= BL.[strCity]
	,[strBillToState]			= BL.[strState]
	,[strBillToZipCode]			= BL.[strZipCode]
	,[strBillToCountry]			= BL.[strCountry]
	,[intDistributionHeaderId]	= IE.intSourceId
	,[intConcurrencyId]			= I.[intConcurrencyId] + 1
	,[intEntityId]				= @EntityId
	,[strDeliverPickup]			= IE.strDeliverPickup   
	,[strActualCostId]  		= IE.strActualCostId
	,[strBOLNumber]  			= IE.[strBOLNumber]
FROM
	[tblARInvoice] I
INNER JOIN 
	@InvoiceEntries IE
		ON I.intInvoiceId = IE.intInvoiceId 
Join @temp TE
       on TE.Customer = IE.intEntityCustomerId 
	   and TE.Location = IE.intLocationId 
	   and TE.strSource = IE.strSourceId
	   and TE.dtmDate = IE.dtmDate
	   and TE.Currency = IE.intCurrencyId
       and TE.Salesperson = IE.intSalesPersonId
	   and TE.Shipvia = IE.intShipViaId
	   and TE.Comments = IE.strComments
	   and TE.PurchaseOrder = IE.strPurchaseOrder	  
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
		ON IE.[intShipToLocationId] = SL.intEntityLocationId
LEFT OUTER JOIN
	tblEntityLocation BL
		ON AC.intShipToId = BL.intEntityLocationId	
WHERE
	IE.intInvoiceId IS NOT NULL 
	AND IE.intInvoiceId <> 0


DELETE FROM tblARInvoiceDetailTax 
WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceEntries WHERE intInvoiceId IS NULL OR intInvoiceId = 0))

DELETE FROM tblARInvoiceDetail 
WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceEntries WHERE intInvoiceId IS NULL OR intInvoiceId = 0)

UPDATE @temp 
SET 
	InvoiceNumber = I.strInvoiceNumber 
FROM
	@temp T
INNER JOIN	
	tblARInvoice I
		ON T.InvoiceId = I.intInvoiceId 
INNER JOIN
	@InvoiceEntries I2
		ON I2.intInvoiceId = I.intInvoiceId 
WHERE
	T.InvoiceId = I2.intInvoiceId
		
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
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intTaxGroupId] 
	,[intConcurrencyId])
SELECT
	IV.[intInvoiceId]											--[intInvoiceId]
	,IE.[intItemId]												--[intItemId]
	,IC.[strDescription]										--strItemDescription] 
	,IE.intItemUOMId                                            --[intItemUOMId]
	,IE.dblQty   												--[dblQtyOrdered]
	,IE.dblQty  												--[dblQtyShipped]		
	,dblPrice = CASE
                    WHEN IE.ysnFreightInPrice = 0  
	                   THEN IE.[dblPrice]					
					WHEN IE.ysnFreightInPrice = 1 and isNull(IE.dblSurcharge,0) != 0
					   THEN	IE.[dblPrice] + isNull(IE.[dblFreightRate],0) + (isNull(IE.[dblFreightRate],0) *(IE.dblSurcharge / 100))
					WHEN IE.ysnFreightInPrice = 1
					   THEN	IE.[dblPrice] + isNull(IE.[dblFreightRate],0) 
			        END 	                                    --[dblPrice]
	,0          												--[dblTotal]
	,Acct.[intAccountId]										--[intAccountId]
	,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
	,Acct.[intSalesAccountId]									--[intSalesAccountId]
	,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
	,(select intContractHeaderId from vyuCTContractDetailView CT where CT.intContractDetailId = IE.intContractDetailId)   --[intContractHeaderId]
	,IE.intContractDetailId                                     --[intContractDetailId]
	,IE.[intTaxGroupId]											--[intTaxGroupId]
	,1															--[intConcurrencyId]
FROM
    @InvoiceEntries IE
	JOIN @temp TE
	 on TE.Customer = IE.intEntityCustomerId 
	   and TE.Location = IE.intLocationId 
	   and TE.strSource = IE.strSourceId
	   and TE.dtmDate = IE.dtmDate
	   and TE.Currency = IE.intCurrencyId
       and TE.Salesperson = IE.intSalesPersonId
	   and TE.Shipvia = IE.intShipViaId
	   and TE.Comments = IE.strComments
	   and TE.PurchaseOrder = IE.strPurchaseOrder	  
	JOIN tblARInvoice IV
	    on TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
    INNER JOIN
	 	tblICItem IC
	 		ON IE.[intItemId] = IC.[intItemId] 
	 LEFT OUTER JOIN
	 	vyuARGetItemAccount Acct
	 		ON IE.[intItemId] = Acct.[intItemId]
	 			AND IE.[intLocationId] = Acct.[intLocationId]


select @intFreightItemId = intItemForFreightId from tblTRCompanyPreference
		
--Freight Items
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
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intTaxGroupId] 
	,[intConcurrencyId])
SELECT
	IV.[intInvoiceId]											--[intInvoiceId]
	,@intFreightItemId										    --[intItemId]
	,IC.[strDescription]										--strItemDescription] 
	,(SELECT	TOP 1 IU.intItemUOMId											
						FROM dbo.tblICItemUOM IU 
						WHERE	IU.intItemId = @intFreightItemId and IU.ysnStockUnit = 1)                                            --[intItemUOMId]
	,IE.dblQty   												--[dblQtyOrdered]
	,IE.dblQty  												--[dblQtyShipped]
	,dblPrice = CASE		
					WHEN isNull(IE.dblSurcharge,0) != 0
					   THEN	isNull(IE.[dblFreightRate],0) + (isNull(IE.[dblFreightRate],0) * (IE.dblSurcharge / 100))
					WHEN isNull(IE.dblSurcharge,0) = 0
					   THEN	 isNull(IE.[dblFreightRate],0) 
			        END 
	,0          												--[dblTotal]
	,Acct.[intAccountId]										--[intAccountId]
	,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
	,Acct.[intSalesAccountId]									--[intSalesAccountId]
	,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
	,null   --[intContractHeaderId]
	,null                                    --[intContractDetailId]
	,IE.[intTaxGroupId]											--[intTaxGroupId]
	,1															--[intConcurrencyId]
FROM
    @InvoiceEntries IE
	JOIN @temp TE
	 on TE.Customer = IE.intEntityCustomerId 
	   and TE.Location = IE.intLocationId 
	   and TE.strSource = IE.strSourceId
	   and TE.dtmDate = IE.dtmDate
	   and TE.Currency = IE.intCurrencyId
       and TE.Salesperson = IE.intSalesPersonId
	   and TE.Shipvia = IE.intShipViaId
	   and TE.Comments = IE.strComments
	   and TE.PurchaseOrder = IE.strPurchaseOrder	  
	JOIN tblARInvoice IV
	    on TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
    INNER JOIN
	 	tblICItem IC
	 		ON @intFreightItemId = IC.[intItemId] 
	 LEFT OUTER JOIN
	 	vyuARGetItemAccount Acct
	 		ON @intFreightItemId = Acct.[intItemId]
	 			AND IE.[intLocationId] = Acct.[intLocationId]
     where isNull(IE.dblFreightRate,0) != 0 and IE.ysnFreightInPrice !=1
		
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
 --   UPDATE
	--	tblARInvoiceDetail
	--	SET [dblTotal]		= ROUND(((isNull([dblPrice],0) )* isNull(([dblQtyShipped]),0) ),2)
	--	where intInvoiceId = @InvoiceId
	
	--UPDATE
	--	tblARInvoice
	--	SET [dblInvoiceTotal]		= isNull((select SUM(dblTotal) from tblARInvoiceDetail where intInvoiceId = @InvoiceId),0)
	--	where intInvoiceId = @InvoiceId

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