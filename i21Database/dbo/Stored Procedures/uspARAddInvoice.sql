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

DECLARE @ZeroDecimal			DECIMAL(18,6)
	  , @ARAccountId			INT
	  , @EntityId				INT
	  , @intFreightItemId		INT
	  , @intSurchargeItemId		INT
	  , @ysnItemizeSurcharge	BIT
	  , @intLocationId			INT
	  , @intFreightItemUOMId	INT
	  , @intSurchargeItemUOMId	INT

SET @ZeroDecimal = 0.000000
SET @ARAccountId = ISNULL((SELECT TOP 1 intARAccountId FROM tblARCompanyPreference WHERE intARAccountId IS NOT NULL AND intARAccountId <> 0),0)

IF(@ARAccountId IS NULL OR @ARAccountId = 0)  
	BEGIN			
		RAISERROR('There is no setup for AR Account in the Company Configuration.', 16, 1) 
		RETURN 0
	END

DECLARE @StartingNumberId_Invoice	INT = 19
	  , @total						INT
	  , @incval						INT
	  , @InvoiceNumber				NVARCHAR(50)
	  , @intCompanyLocationId		INT

DECLARE @temp TABLE (intId			INT IDENTITY PRIMARY KEY CLUSTERED
				   , Customer		INT
				   , Location		INT
				   , strSource		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				   , dtmDate		DATETIME
				   , Currency		INT
				   , Salesperson	INT
				   , Shipvia		INT
				   , Comments		NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL
				   , PurchaseOrder	NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
				   , InvoiceNumber	NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				   , InvoiceId		INT NULL)

INSERT INTO @temp(Customer ,
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

WHILE EXISTS(SELECT NULL FROM @temp WHERE ISNULL(InvoiceNumber,'') = '' AND ISNULL(InvoiceId,0) = 0)
BEGIN
	SELECT TOP 1 @incval = intId, @intCompanyLocationId = Location FROM @temp WHERE ISNULL(InvoiceNumber,'') = '' AND ISNULL(InvoiceId,0) = 0 ORDER BY intId 
	
   EXEC dbo.uspSMGetStartingNumber @StartingNumberId_Invoice, @InvoiceNumber OUTPUT, @intCompanyLocationId 

   IF @InvoiceNumber IS NULL 
   BEGIN 
	-- Raise the error:
	-- Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.
	   RAISERROR('Unable to generate the Transaction Id. Please ask your local administrator to check the starting numbers setup.', 11, 1);
	   RETURN;
   END 
   UPDATE @temp SET InvoiceNumber = @InvoiceNumber WHERE intId = @incval 
   SET @intCompanyLocationId = NULL
END;	

SELECT @EntityId = [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @intUserId;

DISABLE TRIGGER dbo.trgInvoiceNumber ON dbo.tblARInvoice;

INSERT INTO [tblARInvoice]	   
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
		,[strType]
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
		,[intLoadDistributionHeaderId]
		,[intConcurrencyId]
		,[intEntityId]
		,[strDeliverPickup]
		,[strActualCostId]
		,[strBOLNumber]
)
SELECT TE.InvoiceNumber														-- invoice number
	 , IE.strSourceId														--[strInvoiceOriginId]
	 , IE.[intEntityCustomerId]												--[intEntityCustomerId]
	 , CAST(IE.dtmDate AS DATE)												--[dtmDate]
	 , dbo.fnGetDueDateBasedOnTerm(CAST(IE.dtmDate AS DATE), ISNULL(AC.[intTermsId],0))	--[dtmDueDate]
	 , ISNULL(MIN(AC.intCurrencyId), IE.intCurrencyId)						--[intCurrencyId]
	 , ISNULL(IE.intLocationId, (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1))	--[intCompanyLocationId]
	 , ISNULL(IE.[intSalesPersonId], MIN(AC.[intSalespersonId]))			--[intEntitySalespersonId]
	 , CAST(IE.dtmDate AS DATE)												--[dtmShipDate]
	 , ISNULL(IE.intShipViaId, ISNULL(MIN(EL.[intShipViaId]), 0))			--[intShipViaId]
	 , IE.strPurchaseOrder    												--[strPONumber]
	 , AC.[intTermsId]														--[intTermId]
	 , 0          															--[dblInvoiceSubtotal] need to check
	 , @ZeroDecimal															--[dblShipping]
	 , @ZeroDecimal															--[dblTax]
	 , 0        															--[dblInvoiceTotal] need to check
	 , @ZeroDecimal															--[dblDiscount]
	 , 0																	--[[dblAmountDue]] need to check
	 , @ZeroDecimal															--[dblPayment]
	 , 'Invoice'															--[strTransactionType]
	 , CASE WHEN IE.strSourceScreenName IN ('Transport Load', 'Transport Loads') THEN 'Transport Delivery' ELSE 'Standard' END
	 , 0																	--[intPaymentMethodId]
	 , IE.strComments        												--[strComments] 
	 , @ARAccountId															--[intAccountId]
	 , CAST(IE.dtmDate AS DATE)												--[dtmPostDate] need to check
	 , 0																	--[ysnPosted]
	 , 0																	--[ysnPaid]
	 , ISNULL(min(IE.intShipToLocationId), MIN(EL.[intEntityLocationId]))	--[intShipToLocationId] 
	 , MIN(SL.[strLocationName])											--[strShipToLocationName]
	 , MIN(SL.[strAddress])													--[strShipToAddress]
	 , MIN(SL.[strCity])													--[strShipToCity]
	 , MIN(SL.[strState])													--[strShipToState]
	 , MIN(SL.[strZipCode])													--[strShipToZipCode]
	 , MIN(SL.[strCountry])													--[strShipToCountry]
	 , ISNULL(MIN(AC.[intBillToId]), MIN(EL.[intEntityLocationId]))			--[intBillToLocationId] 
	 , MIN(BL.[strLocationName])											--[strBillToLocationName]
	 , MIN(BL.[strAddress])													--[strBillToAddress]
	 , MIN(BL.[strCity])													--[strBillToCity]
	 , MIN(BL.[strState])													--[strBillToState]
	 , MIN(BL.[strZipCode])													--[strBillToZipCode]
	 , MIN(BL.[strCountry])													--[strBillToCountry]
	 , CASE WHEN IE.strSourceScreenName = 'Transport Load' THEN IE.intSourceId ELSE NULL END
	 , CASE WHEN IE.strSourceScreenName = 'Transport Loads' THEN IE.intSourceId ELSE NULL END
	 , 1
	 , @EntityId
	 , IE.strDeliverPickup
	 , IE.strActualCostId
	 , IE.strBOLNumber
FROM @InvoiceEntries IE
JOIN @temp TE ON TE.Customer		= IE.intEntityCustomerId 
			 AND TE.Location		= IE.intLocationId 
			 AND TE.strSource		= IE.strSourceId
			 AND TE.dtmDate			= IE.dtmDate
			 AND TE.Currency		= IE.intCurrencyId
			 AND TE.Salesperson		= IE.intSalesPersonId
			 AND TE.Shipvia			= IE.intShipViaId
			 AND TE.Comments		= IE.strComments
			 AND TE.PurchaseOrder	= IE.strPurchaseOrder	  
INNER JOIN tblARCustomer AC
		ON IE.[intEntityCustomerId] = AC.[intEntityId]
LEFT OUTER JOIN (SELECT [intEntityLocationId]
					  , [intEntityId] 
					  , [strCountry]
					  , [strState]
					  , [strCity]
					  , [intTermsId]
					  , [intShipViaId]
					FROM [tblEMEntityLocation]
					WHERE ysnDefaultLocation = 1 ) EL
						ON AC.[intEntityId] = EL.[intEntityId]
LEFT OUTER JOIN [tblEMEntityLocation] SL
		ON IE.[intShipToLocationId] = SL.intEntityLocationId
LEFT OUTER JOIN [tblEMEntityLocation] BL
		ON AC.[intBillToId] = BL.intEntityLocationId	
WHERE IE.intInvoiceId IS NULL OR IE.intInvoiceId = 0
GROUP BY TE.InvoiceNumber,IE.intEntityCustomerId,IE.intLocationId,IE.strSourceId,IE.dtmDate,IE.intCurrencyId,IE.intSalesPersonId,IE.intShipViaId,IE.strComments,AC.intTermsId,IE.strPurchaseOrder,IE.intSourceId,IE.strDeliverPickup,IE.strActualCostId,IE.strBOLNumber,IE.strSourceScreenName;				

ENABLE TRIGGER dbo.trgInvoiceNumber ON dbo.tblARInvoice;

UPDATE [tblARInvoice]
SET	   
	 [strInvoiceOriginId]			= IE.strSourceId
	,[intEntityCustomerId]			= IE.[intEntityCustomerId]
	,[dtmDate]						= CAST(IE.dtmDate AS DATE)
	,[dtmDueDate]					= dbo.fnGetDueDateBasedOnTerm(CAST(IE.dtmDate AS DATE), ISNULL(AC.[intTermsId],0))
	,[intCurrencyId]				= ISNULL(IE.intCurrencyId,AC.[intCurrencyId])
	,[intCompanyLocationId]			= ISNULL(IE.intLocationId, (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1))
	,[intEntitySalespersonId]		= ISNULL(IE.[intSalesPersonId],AC.[intSalespersonId])
	,[dtmShipDate]					= CAST(IE.dtmDate AS DATE)
	,[intShipViaId]					= ISNULL(IE.intShipViaId,ISNULL(EL.[intShipViaId], 0))
	,[strPONumber]					= IE.strPurchaseOrder
	,[intTermId]					= AC.[intTermsId]
	,[dblInvoiceSubtotal]			= @ZeroDecimal
	,[dblShipping]					= @ZeroDecimal
	,[dblTax]						= @ZeroDecimal
	,[dblInvoiceTotal]				= @ZeroDecimal
	,[dblDiscount]					= @ZeroDecimal
	,[dblAmountDue]					= @ZeroDecimal
	,[dblPayment]					= @ZeroDecimal
	,[strTransactionType]			= 'Invoice'
	,[strType]						= CASE WHEN IE.strSourceScreenName IN ('Transport Load', 'Transport Loads') THEN 'Transport Delivery' ELSE 'Standard' END
	,[intPaymentMethodId]			= 0
	,[strComments]					= IE.strComments
	,[intAccountId]					= @ARAccountId
	,[dtmPostDate]					= NULL
	,[intShipToLocationId]			= ISNULL(IE.[intShipToLocationId], EL.[intEntityLocationId]) 
	,[strShipToLocationName]		= SL.[strLocationName]
	,[strShipToAddress]				= SL.[strAddress]
	,[strShipToCity]				= SL.[strCity]
	,[strShipToState]				= SL.[strState]
	,[strShipToZipCode]				= SL.[strZipCode]
	,[strShipToCountry]				= SL.[strCountry]
	,[intBillToLocationId]			= ISNULL(AC.[intBillToId],EL.[intEntityLocationId])
	,[strBillToLocationName]		= BL.[strLocationName]
	,[strBillToAddress]				= BL.[strAddress]
	,[strBillToCity]				= BL.[strCity]
	,[strBillToState]				= BL.[strState]
	,[strBillToZipCode]				= BL.[strZipCode]
	,[strBillToCountry]				= BL.[strCountry]
	,[intDistributionHeaderId]		= CASE WHEN IE.strSourceScreenName = 'Transport Load' THEN IE.intSourceId ELSE NULL END
	,[intLoadDistributionHeaderId]	= CASE WHEN IE.strSourceScreenName = 'Transport Loads' THEN IE.intSourceId ELSE NULL END
	,[intConcurrencyId]				= I.[intConcurrencyId] + 1
	,[intEntityId]					= @EntityId
	,[strDeliverPickup]				= IE.strDeliverPickup   
	,[strActualCostId]  			= IE.strActualCostId
	,[strBOLNumber]  				= IE.[strBOLNumber]
FROM [tblARInvoice] I
INNER JOIN  @InvoiceEntries IE
		ON I.intInvoiceId = IE.intInvoiceId 
JOIN @temp TE ON TE.Customer		= IE.intEntityCustomerId 
	         AND TE.Location		= IE.intLocationId 
	         AND TE.strSource		= IE.strSourceId
	         AND TE.dtmDate			= IE.dtmDate
	         AND TE.Currency		= IE.intCurrencyId
             AND TE.Salesperson		= IE.intSalesPersonId
	         AND TE.Shipvia			= IE.intShipViaId
	         AND TE.Comments		= IE.strComments
	         AND TE.PurchaseOrder	= IE.strPurchaseOrder	  
INNER JOIN tblARCustomer AC
		ON IE.[intEntityCustomerId] = AC.[intEntityId]
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
					[tblEMEntityLocation]
					WHERE
						ysnDefaultLocation = 1
				) EL
					ON AC.[intEntityId] = EL.[intEntityId]
LEFT OUTER JOIN [tblEMEntityLocation] SL
		ON IE.[intShipToLocationId] = SL.intEntityLocationId
LEFT OUTER JOIN [tblEMEntityLocation] BL
		ON AC.[intBillToId] = BL.intEntityLocationId	
WHERE IE.intInvoiceId IS NOT NULL AND IE.intInvoiceId <> 0
	
DECLARE @InvoicesForUpdate AS TABLE(intInvoiceID INT)

INSERT INTO @InvoicesForUpdate 
SELECT DISTINCT [intInvoiceId]
FROM @InvoiceEntries
WHERE intInvoiceId IS NOT NULL AND intInvoiceId <> 0

--Log Update 
DECLARE @strDescription			NVARCHAR(100)
	  , @strSourceId			NVARCHAR(250)
	  , @strInvoiceNumber		NVARCHAR(250)
	  , @intNewInvoiceId		INT   
	  , @intUpdatedInvoiceId	INT   
	  , @InvoiceIdForUpdate		INT

WHILE EXISTS(SELECT NULL FROM @InvoicesForUpdate)
BEGIN
	SELECT TOP 1 @InvoiceIdForUpdate = [intInvoiceID] FROM @InvoicesForUpdate

    -- Create an Audit Log
    SELECT TOP 1
		@intUpdatedInvoiceId = I.intInvoiceId 
		,@strInvoiceNumber = I.strInvoiceNumber 
		,@strSourceId = RTRIM(LTRIM(IE.strSourceId))
		,@strDescription = RTRIM(LTRIM(IE.strSourceScreenName)) + + ' to Invoice'
	FROM
		@InvoiceEntries IE
	INNER JOIN
		tblARInvoice I
			ON IE.intSourceId = CASE WHEN IE.strSourceScreenName = 'Transport Load' THEN I.intDistributionHeaderId ELSE I.intLoadDistributionHeaderId END
	WHERE
		ISNULL(IE.intInvoiceId,0) <> 0
		AND I.intInvoiceId = @InvoiceIdForUpdate
		
	IF ISNULL(@intUpdatedInvoiceId,0) <> 0	
    BEGIN                                
        EXEC dbo.uspSMAuditLog 
			 @keyValue			= @intUpdatedInvoiceId              -- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsReceivable.view.Invoice' -- Screen Namespace
			,@entityId			= @EntityId                         -- Entity Id.
			,@actionType		= 'Processed'                       -- Action Type
			,@changeDescription	= @strDescription					-- Description
			,@fromValue			= @strSourceId                      -- Previous Value
			,@toValue			= @strInvoiceNumber                 -- New Value
    END

	DELETE FROM @InvoicesForUpdate WHERE [intInvoiceID] = @InvoiceIdForUpdate
END	

DELETE FROM tblARInvoiceDetailTax 
WHERE intInvoiceDetailId IN (SELECT intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceEntries WHERE intInvoiceId IS NOT NULL))

DELETE FROM tblARInvoiceDetail 
WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceEntries WHERE intInvoiceId IS NOT NULL )

UPDATE @temp 
SET InvoiceNumber = I.strInvoiceNumber 
FROM @temp T
INNER JOIN tblARInvoice I
	ON T.InvoiceId = I.intInvoiceId 
INNER JOIN @InvoiceEntries I2
	ON I2.intInvoiceId = I.intInvoiceId 
WHERE T.InvoiceId = I2.intInvoiceId
		
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intItemId]
	,[strItemDescription]
	,[strDocumentNumber]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
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
	,IC.[strDescription]										--[strItemDescription] 
	,IE.strSourceId												--[strDocumentNumber]
	,IE.intItemUOMId                                            --[intItemUOMId]
	,IE.dblQty   												--[dblQtyOrdered]
	,IE.intItemUOMId                                            --[intItemUOMId]
	,IE.dblQty  												--[dblQtyShipped]		
	,dblPrice = CASE WHEN IE.ysnFreightInPrice = 0  
	                   THEN IE.[dblPrice]					
					 WHEN IE.ysnFreightInPrice = 1 and isNull(IE.dblSurcharge,0) != 0
					   THEN	IE.[dblPrice] + isNull(IE.[dblFreightRate],0) + (isNull(IE.[dblFreightRate],0) *(IE.dblSurcharge / 100))
					 WHEN IE.ysnFreightInPrice = 1
					   THEN	IE.[dblPrice] + isNull(IE.[dblFreightRate],0) 
			    END 											--[dblPrice]
	,0          												--[dblTotal]
	,Acct.[intAccountId]										--[intAccountId]
	,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
	,Acct.[intSalesAccountId]									--[intSalesAccountId]
	,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
	,(SELECT intContractHeaderId FROM vyuCTContractDetailView CT WHERE CT.intContractDetailId = IE.intContractDetailId)   --[intContractHeaderId]
	,IE.intContractDetailId                                     --[intContractDetailId]
	,IE.[intTaxGroupId]											--[intTaxGroupId]
	,1															--[intConcurrencyId]
FROM
    @InvoiceEntries IE
	JOIN @temp TE
	 ON TE.Customer = IE.intEntityCustomerId 
	   AND TE.Location = IE.intLocationId 
	   AND TE.strSource = IE.strSourceId
	   AND TE.dtmDate = IE.dtmDate
	   AND TE.Currency = IE.intCurrencyId
       AND TE.Salesperson = IE.intSalesPersonId
	   AND TE.Shipvia = IE.intShipViaId
	   AND TE.Comments = IE.strComments
	   AND TE.PurchaseOrder = IE.strPurchaseOrder	  
	JOIN tblARInvoice IV
	    ON TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
    INNER JOIN
	 	tblICItem IC
	 		ON IE.[intItemId] = IC.[intItemId] 
	 LEFT OUTER JOIN
	 	vyuARGetItemAccount Acct
	 		ON IE.[intItemId] = Acct.[intItemId]
	 			AND IE.[intLocationId] = Acct.[intLocationId]

--VALIDATE FREIGHT AND SURCHARGE ITEM				
SELECT TOP 1
	   @intFreightItemId	= intItemForFreightId
     , @intSurchargeItemId	= intSurchargeItemId
	 , @ysnItemizeSurcharge = ysnItemizeSurcharge
FROM tblTRCompanyPreference

SELECT TOP 1 @intLocationId = intLocationId FROM @InvoiceEntries 

IF ISNULL(@intFreightItemId, 0) > 0
	BEGIN		
		SELECT TOP 1 @intFreightItemUOMId = intIssueUOMId FROM tblICItemLocation WHERE intItemId = @intFreightItemId AND intLocationId = @intLocationId

		IF ISNULL(@intFreightItemUOMId, 0) = 0
			BEGIN
				SELECT TOP 1 @intFreightItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intFreightItemId ORDER BY ysnStockUnit DESC
			END

		IF ISNULL(@intFreightItemUOMId, 0) = 0 AND EXISTS(SELECT TOP 1 1 FROM @InvoiceEntries WHERE ISNULL(dblFreightRate, @ZeroDecimal) > @ZeroDecimal)
			BEGIN
				RAISERROR('Freight Item doesn''t have default Sales UOM and stock UOM!', 16, 1) 
				RETURN 0
			END
	END

IF (@ysnItemizeSurcharge = 1 AND ISNULL(@intSurchargeItemId, 0) > 0)
	BEGIN
		SELECT TOP 1 @intSurchargeItemUOMId = intIssueUOMId FROM tblICItemLocation WHERE intItemId = @intSurchargeItemId AND intLocationId = @intLocationId

		IF ISNULL(@intSurchargeItemUOMId, 0) = 0
			BEGIN
				SELECT TOP 1 @intSurchargeItemUOMId = intItemUOMId FROM tblICItemUOM WHERE intItemId = @intFreightItemId ORDER BY ysnStockUnit DESC
			END

		IF ISNULL(@intSurchargeItemUOMId, 0) = 0 AND EXISTS(SELECT TOP 1 1 FROM @InvoiceEntries WHERE ISNULL(dblSurcharge, @ZeroDecimal) > @ZeroDecimal)
			BEGIN
				RAISERROR('Surcharge doesn''t have default Sales UOM and stock UOM.', 16, 1) 
				RETURN 0
			END
	END
	
--Freight Items
INSERT INTO [tblARInvoiceDetail]
	([intInvoiceId]
	,[intItemId]
	,[strItemDescription]
	,[strDocumentNumber]
	,[intOrderUOMId]
	,[dblQtyOrdered]
	,[intItemUOMId]
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
	,IE.strSourceId
	,@intFreightItemUOMId										--[intItemUOMId]
	,IE.dblQty   												--[dblQtyOrdered]
	,@intFreightItemUOMId										--[intItemUOMId]
	,IE.dblQty  												--[dblQtyShipped]
	,dblPrice = CASE		
					WHEN ISNULL(IE.dblSurcharge,0) != 0 AND @ysnItemizeSurcharge = 0
					   THEN	ISNULL(IE.[dblFreightRate],0) + (ISNULL(IE.[dblFreightRate],0) * (IE.dblSurcharge / 100))
					WHEN ISNULL(IE.dblSurcharge,0) = 0 OR @ysnItemizeSurcharge = 1
					   THEN	 ISNULL(IE.[dblFreightRate],0) 
			        END 
	,0          												--[dblTotal]
	,Acct.[intAccountId]										--[intAccountId]
	,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
	,Acct.[intSalesAccountId]									--[intSalesAccountId]
	,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
	,NULL														--[intContractHeaderId]
	,NULL														--[intContractDetailId]
	,NULL														--[intTaxGroupId]
	,1															--[intConcurrencyId]
FROM @InvoiceEntries IE
JOIN @temp TE
	 ON TE.Customer = IE.intEntityCustomerId 
	   AND TE.Location = IE.intLocationId 
	   AND TE.strSource = IE.strSourceId
	   AND TE.dtmDate = IE.dtmDate
	   AND TE.Currency = IE.intCurrencyId
       AND TE.Salesperson = IE.intSalesPersonId
	   AND TE.Shipvia = IE.intShipViaId
	   AND TE.Comments = IE.strComments
	   AND TE.PurchaseOrder = IE.strPurchaseOrder	  
	JOIN tblARInvoice IV
	    ON TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
    INNER JOIN
	 	tblICItem IC
	 		ON @intFreightItemId = IC.[intItemId] 
	 LEFT OUTER JOIN
	 	vyuARGetItemAccount Acct
	 		ON @intFreightItemId = Acct.[intItemId]
	 			AND IE.[intLocationId] = Acct.[intLocationId]
     WHERE ISNULL(IE.dblFreightRate,0) != 0 and IE.ysnFreightInPrice !=1

--Surcharge Item
IF @ysnItemizeSurcharge = 1 AND ISNULL(@intSurchargeItemId, 0) > 0
	BEGIN
		INSERT INTO [tblARInvoiceDetail]
			([intInvoiceId]
			,[intItemId]
			,[strItemDescription]
			,[strDocumentNumber]			
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
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
			,@intSurchargeItemId										    --[intItemId]
			,IC.[strDescription]										--strItemDescription] 
			,IE.strSourceId
			,@intSurchargeItemUOMId										--[intItemUOMId]
			,1   	
			,@intSurchargeItemUOMId														--[dblQtyOrdered]
			,1  														--[dblQtyShipped]
			,dblPrice = ISNULL(IE.dblQty, @ZeroDecimal) * (ISNULL(IE.[dblFreightRate], @ZeroDecimal) * (ISNULL(IE.dblSurcharge, @ZeroDecimal) / 100))
			,0          												--[dblTotal]
			,Acct.[intAccountId]										--[intAccountId]
			,Acct.[intCOGSAccountId]									--[intCOGSAccountId]
			,Acct.[intSalesAccountId]									--[intSalesAccountId]
			,Acct.[intInventoryAccountId]								--[intInventoryAccountId]
			,NULL														--[intContractHeaderId]
			,NULL														--[intContractDetailId]
			,NULL														--[intTaxGroupId]
			,1															--[intConcurrencyId]
		FROM @InvoiceEntries IE
		JOIN @temp TE
			 ON TE.Customer = IE.intEntityCustomerId 
			   AND TE.Location = IE.intLocationId 
			   AND TE.strSource = IE.strSourceId
			   AND TE.dtmDate = IE.dtmDate
			   AND TE.Currency = IE.intCurrencyId
			   AND TE.Salesperson = IE.intSalesPersonId
			   AND TE.Shipvia = IE.intShipViaId
			   AND ISNULL(TE.Comments, '')		= ISNULL(IE.strComments, '')
			   AND ISNULL(TE.PurchaseOrder, '')	= ISNULL(IE.strPurchaseOrder, '')	  
			JOIN tblARInvoice IV
				ON TE.InvoiceNumber = IV.strInvoiceNumber and IE.strSourceId = IV.strInvoiceOriginId
			INNER JOIN
	 			tblICItem IC
	 				ON @intFreightItemId = IC.[intItemId] 
			 LEFT OUTER JOIN
	 			vyuARGetItemAccount Acct
	 				ON @intFreightItemId = Acct.[intItemId]
	 					AND IE.[intLocationId] = Acct.[intLocationId]
			 WHERE ISNULL(IE.dblFreightRate,0) != 0 and IE.ysnFreightInPrice != 1
	END
	
--Log Insert	
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
	EXEC [dbo].[uspARReComputeInvoiceTaxes] @InvoiceId = @InvoiceId

    SELECT TOP 1
		@intNewInvoiceId = I.intInvoiceId 
		,@strInvoiceNumber = I.strInvoiceNumber 
		,@strSourceId = RTRIM(LTRIM(IE.strSourceId))
		,@strDescription = RTRIM(LTRIM(IE.strSourceScreenName)) + + ' to Invoice'
	FROM
		@InvoiceEntries IE
	INNER JOIN
		tblARInvoice I
			ON IE.intSourceId = CASE WHEN IE.strSourceScreenName = 'Transport Load' THEN I.intDistributionHeaderId ELSE I.intLoadDistributionHeaderId END
	WHERE
		ISNULL(IE.intInvoiceId,0) = 0
		AND I.intInvoiceId = @InvoiceId
		
	IF ISNULL(@intNewInvoiceId,0) <> 0	
    BEGIN
		EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @intNewInvoiceId, @ForDelete = 0, @UserId = @intUserId

        EXEC dbo.uspSMAuditLog 
			 @keyValue			= @intNewInvoiceId                  -- Primary Key Value of the Invoice. 
			,@screenName		= 'AccountsReceivable.view.Invoice' -- Screen Namespace
			,@entityId			= @EntityId                         -- Entity Id.
			,@actionType		= 'Processed'                       -- Action Type
			,@changeDescription	= @strDescription					-- Description
			,@fromValue			= @strSourceId                      -- Previous Value
			,@toValue			= @strInvoiceNumber                 -- New Value
    END

	DELETE FROM @Invoices WHERE [intInvoiceID] = @InvoiceId
END
  
-- Output the values to calling SP  
      
SELECT IE.intSourceId,
       IV.intInvoiceId
FROM @InvoiceEntries IE
	JOIN @temp TE
		ON TE.Customer = IE.intEntityCustomerId AND TE.Location = IE.intLocationId	
	JOIN tblARInvoice IV
	    ON TE.InvoiceNumber = IV.strInvoiceNumber AND IE.strSourceId = IV.strInvoiceOriginId	       
END           