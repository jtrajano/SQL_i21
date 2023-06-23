CREATE PROCEDURE [dbo].[uspMBILBuildOrder]
	@intDriverId		AS INT,
	@intShiftId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

BEGIN TRANSACTION;

-- ++++++ CLEAN-OUT DRIVER's ORDER LIST ++++++ --
IF (ISNULL(@intShiftId, '') != '')
BEGIN
	DELETE tblMBILOrder WHERE intShiftId = @intShiftId
END
ELSE
BEGIN
	DELETE tblMBILOrder 
	WHERE intDriverId = @intDriverId AND 
	NOT EXISTS (
		SELECT intOrderId FROM tblMBILInvoice
		WHERE tblMBILInvoice.intOrderId = tblMBILOrder.intOrderId
	)
END

-- ++++++ CLEAN-OUT ORDERS WITH POSTED INVOICE  ++++++ --
--BEGIN
--	DELETE tblMBILOrder 
--	WHERE NOT EXISTS (
--		SELECT intOrderId FROM tblMBILInvoice
--		WHERE tblMBILInvoice.intOrderId = tblMBILOrder.intOrderId
--		AND ysnPosted = 1
--	)
--END

---- ++++++ CALL TM SP FOR OVERRAGE ++++++
--DECLARE  @TMDispatchId INT = NULL

--SELECT intDispatchID 
--INTO #TMOrderDispatch
--FROM tblTMDispatch
--WHERE intDriverID = @intDriverId
--AND strWillCallStatus IN ('Dispatched','Routed')

--WHILE EXISTS(SELECT 1 FROM #TMOrderDispatch)
--BEGIN
--	SELECT TOP 1 @TMDispatchId = [intDispatchID] FROM #TMOrderDispatch

--	DELETE tblTMOrder WHERE intDispatchId =  @TMDispatchId and strSource = 'Mobile Billing'
--	EXEC uspTMCreateOrder @TMDispatchId, 'Mobile Billing'

--	DELETE #TMOrderDispatch WHERE [intDispatchID] = @TMDispatchId
--END


-- ++++++ PREPARE TM ORDER ++++++
SELECT intDispatchId = TMOrder.intDispatchId
	, strOrderNumber = TMOrder.strOrderNumber
	, strOrderStatus = Dispatch.strWillCallStatus
	, dtmRequestedDate = Dispatch.dtmRequestedDate
	, intItemId = Item.intItemId
	, ItemUOM.intItemUOMId
	, intEntityId = Customer.intEntityId
	, intSiteId = Site.intSiteID
	, intContractDetailId = TMOrder.intContractDetailId
	, dblQuantity = TMOrder.dblQuantity
	, TMOrder.dblPrice
	, intTermId = Dispatch.intDeliveryTermID
	, strComments = Dispatch.strComments
	, intDriverId = Dispatch.intDriverID
	, intRouteId = K.intRouteId
	, intStopNumber = L.intSequence
	, Site.intTaxStateID	
	, Customer.intShipToId	
	, Site.intLocationId
	, intShiftId = @intShiftId
	, Dispatch.ysnLockPrice
	, Site.strRecurringPONumber
INTO #Dispatch
FROM tblTMOrder TMOrder
INNER JOIN tblTMDispatch Dispatch ON TMOrder.intDispatchId = Dispatch.intDispatchID
INNER JOIN tblTMSite Site ON Dispatch.intSiteID = Site.intSiteID
INNER JOIN tblTMCustomer B
	ON Site.intCustomerID = B.intCustomerID
INNER JOIN tblEMEntity C
	ON B.intCustomerNumber = C.intEntityId
LEFT JOIN tblLGRoute K ON Dispatch.intRouteId = K.intRouteId
LEFT JOIN tblLGRouteOrder L ON K.intRouteId = L.intRouteId AND Dispatch.intDispatchID = L.intDispatchID
LEFT JOIN tblICItem Item ON Item.intItemId = Site.intProduct
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1
LEFT JOIN tblARCustomer Customer ON Customer.intEntityId =  C.intEntityId
WHERE Dispatch.intDriverID = @intDriverId AND 
	  NOT EXISTS (SELECT strOrderNumber COLLATE Latin1_General_CI_AS 
					FROM tblMBILOrder 
					WHERE intDriverId = @intDriverId AND
					EXISTS (
							SELECT intOrderId FROM tblMBILInvoice
							WHERE tblMBILInvoice.intOrderId = tblMBILOrder.intOrderId
							AND intOrderId IS NOT NULL
						)
					AND TMOrder.strOrderNumber = tblMBILOrder.strOrderNumber COLLATE Latin1_General_CI_AS)

-- ++++++ CREATE DRIVER's ORDER LIST ++++++ --
INSERT INTO tblMBILOrder(intDispatchId
	, strOrderNumber
	, strOrderStatus
	, dtmRequestedDate
	, intEntityId
	, intTermId
	, strComments
	, intDriverId
	, intRouteId
	, intStopNumber
	, intTaxStateId
	, intShipToId
	, intLocationId
	, ysnLockPrice
	, strRecurringPONumber)
SELECT DISTINCT intDispatchId
	, strOrderNumber
	, strOrderStatus
	, dtmRequestedDate
	, intEntityId
	, intTermId
	, strComments
	, intDriverId
	, intRouteId
	, intStopNumber
	, intTaxStateID
	, intShipToId
	, intLocationId
	, ysnLockPrice
	, strRecurringPONumber
FROM #Dispatch
LEFT JOIN tblSMTerm ON tblSMTerm.intTermID = #Dispatch.intTermId
WHERE intDriverId = @intDriverId AND strOrderStatus IN ('Dispatched','Routed')

-- ++++++ CREATE ORDER's ITEM LIST ++++++ --
INSERT INTO tblMBILOrderItem(intOrderId
	, intSiteId
	, intItemId
	, intItemUOMId
	, dblQuantity
	, dblPrice
	, intContractDetailId)
SELECT [Order].intOrderId	
	, #Dispatch.intSiteId
	, #Dispatch.intItemId
	, #Dispatch.intItemUOMId	
	, #Dispatch.[dblQuantity]
	, #Dispatch.[dblPrice]
	, #Dispatch.[intContractDetailId]
FROM #Dispatch
LEFT JOIN vyuMBILOrder [Order] ON #Dispatch.intDispatchId = [Order].intDispatchId
WHERE [Order].intDriverId = @intDriverId


-- ++++++ ITEM TAX CODE PROCESS ++++++ --
SELECT *
INTO #tempDriverOrder
FROM (
	SELECT A.*
		, B.intOrderItemId
		, B.intItemId
		, B.intItemUOMId
		, B.intSiteId
	FROM tblMBILOrder A
	LEFT JOIN tblMBILOrderItem B ON A.intOrderId = B.intOrderId
	WHERE A.intDriverId = @intDriverId) tblOrder


DECLARE  @MBILOrderId					INT				= NULL
		,@ItemId						INT				= NULL
		,@LocationId					INT				= NULL
		,@CustomerId					INT				= NULL	
		,@CustomerLocationId			INT				= NULL	
		,@TransactionDate				DATETIME		= NULL
		,@TaxGroupId					INT				= NULL		
		,@SiteId						INT				= NULL
		,@FreightTermId					INT				= NULL
		,@CardId						INT				= NULL
		,@VehicleId						INT				= NULL
		,@DisregardExemptionSetup		BIT				= 0
		,@ItemUOMId						INT				= NULL
		,@CFSiteId						INT				= NULL
		,@IsDeliver						BIT				= NULL
		,@CurrencyId					INT				= NULL
		,@CurrencyExchangeRateTypeId	INT				= NULL
		,@CurrencyExchangeRate			NUMERIC(18,6)	= NULL


CREATE TABLE #tempOrderTaxCode (
	[intTransactionDetailTaxId]	INT
	,[intInvoiceDetailId]		INT
	,[intTaxGroupMasterId]		INT
	,[intTaxGroupId]			INT
	,[intTaxCodeId]				INT
	,[intTaxClassId]			INT
	,[strTaxableByOtherTaxes]	NVARCHAR(MAX)
	,[strCalculationMethod]		NVARCHAR(MAX)
	,[dblRate]					NUMERIC(18, 6)
	,[dblBaseRate]				NUMERIC(18, 6)
	,[dblExemptionPercent]		NUMERIC(18, 6)
	,[dblTax]					NUMERIC(18, 6)
	,[dblAdjustedTax]			NUMERIC(18, 6)
	,[dblBaseAdjustedTax]		NUMERIC(18, 6)
	,[intSalesTaxAccountId]		INT
	,[intSalesTaxExemptionAccountId] INT
	,[ysnSeparateOnInvoice]		BIT
	,[ysnCheckoffTax]			BIT
	,[strTaxCode]				NVARCHAR(MAX)
	,[ysnTaxExempt]				BIT
	,[ysnTaxOnly]				BIT
	,[ysnInvalidSetup]			BIT
	,[strTaxGroup]				NVARCHAR(MAX)
	,[strNotes]					NVARCHAR(MAX)
	,[intUnitMeasureId]			INT
	,[strUnitMeasure]			NVARCHAR(MAX)
	,[strTaxClass]				NVARCHAR(MAX)
	,[ysnAddToCost]				BIT
	,[ysnOverrideTaxGroup]  BIT 
);

WHILE EXISTS(SELECT 1 FROM #tempDriverOrder)
BEGIN
	
	SELECT TOP 1 @MBILOrderId					= [intOrderItemId]
				,@ItemId						= [intItemId]
				,@LocationId					= [intLocationId]
				,@CustomerId					= [intEntityId]
				,@CustomerLocationId			= [intShipToId]
				,@TransactionDate				= GETDATE()
				,@TaxGroupId					= [intTaxStateId]
				,@SiteId						= [intSiteId]
				,@FreightTermId					= NULL
				,@CardId						= NULL
				,@VehicleId						= NULL
				,@DisregardExemptionSetup		= 0
				,@ItemUOMId						= [intItemUOMId]
				,@CFSiteId						= NULL
				,@IsDeliver						= NULL
				,@CurrencyId					= NULL
				,@CurrencyExchangeRateTypeId	= NULL
				,@CurrencyExchangeRate			= NULL
			FROM #tempDriverOrder


	INSERT INTO #tempOrderTaxCode ([intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblBaseRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[intSalesTaxExemptionAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure]
									,[strTaxClass]
									,[ysnAddToCost]
									,[ysnOverrideTaxGroup])
	EXEC uspARGetItemTaxes @ItemId
						  ,@LocationId
						  ,@CustomerId
						  ,@CustomerLocationId
						  ,@TransactionDate
						  ,@TaxGroupId
						  ,@SiteId
						  ,@FreightTermId
						  ,@CardId
						  ,@VehicleId
						  ,@DisregardExemptionSetup
						  ,@ItemUOMId
						  ,@CFSiteId
						  ,@IsDeliver
						  , NULL
						  ,@CurrencyId
						  ,@CurrencyExchangeRateTypeId
						  ,@CurrencyExchangeRate


	INSERT INTO tblMBILOrderTaxCode ([intOrderItemId]
									,[intItemId]
									,[intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure])

	SELECT							 @MBILOrderId
									,@ItemId
									,[intTransactionDetailTaxId]
									,[intInvoiceDetailId]
									,[intTaxGroupMasterId]
									,[intTaxGroupId]
									,[intTaxCodeId]
									,[intTaxClassId]
									,[strTaxableByOtherTaxes]
									,[strCalculationMethod]
									,[dblRate]
									,[dblExemptionPercent]
									,[dblTax]
									,[dblAdjustedTax]
									,[dblBaseAdjustedTax]
									,[intSalesTaxAccountId]
									,[ysnSeparateOnInvoice]
									,[ysnCheckoffTax]
									,[strTaxCode]
									,[ysnTaxExempt]
									,[ysnTaxOnly]
									,[ysnInvalidSetup]
									,[strTaxGroup]
									,[strNotes]
									,[intUnitMeasureId]
									,[strUnitMeasure]
			FROM #tempOrderTaxCode

	DELETE #tempOrderTaxCode
	DELETE #tempDriverOrder WHERE intOrderItemId = @MBILOrderId
END

COMMIT TRANSACTION