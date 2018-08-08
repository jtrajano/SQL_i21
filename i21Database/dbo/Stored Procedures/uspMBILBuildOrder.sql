CREATE PROCEDURE [dbo].[uspMBILBuildOrder]
	@intDriverId		AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

-- ++++++ CLEAN-OUT DRIVER's ORDER LIST ++++++ --
DELETE tblMBILOrder WHERE intDriverId = @intDriverId

SELECT intDispatchId = Dispatch.intDispatchID
	, strOrderNumber = Dispatch.strOrderNumber
	, strOrderStatus = Dispatch.strWillCallStatus
	, dtmRequestedDate = Dispatch.dtmRequestedDate
	, intItemId = Item.intItemId
	, ItemUOM.intItemUOMId
	, intEntityId = Site.intCustomerID
	, intSiteId = Site.intSiteID
	, intContractDetailId = Dispatch.intContractId
	, dblQuantity = CASE WHEN ISNULL(Dispatch.dblMinimumQuantity,0) = 0 THEN Dispatch.dblQuantity ELSE Dispatch.dblMinimumQuantity END
	, Dispatch.dblPrice
	, intTermId = Dispatch.intDeliveryTermID
	, strComments = Dispatch.strComments
	, intDriverId = Dispatch.intDriverID
	, intRouteId = K.intRouteId
	, intStopNumber = L.intSequence
	, Site.intTaxStateID	
	, Customer.intShipToId	
	, Site.intLocationId
INTO #Dispatch
FROM tblTMDispatch Dispatch
INNER JOIN tblTMSite Site ON Dispatch.intSiteID = Site.intSiteID
LEFT JOIN tblLGRoute K ON Dispatch.intRouteId = K.intRouteId
LEFT JOIN tblLGRouteOrder L ON K.intRouteId = L.intRouteId AND Dispatch.intDispatchID = L.intDispatchID
LEFT JOIN tblICItem Item ON Item.intItemId = Site.intProduct
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.ysnStockUnit = 1
LEFT JOIN tblARCustomer Customer ON Customer.intEntityId = Site.intCustomerID

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
	, intLocationId)
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
FROM #Dispatch
WHERE intDriverId = @intDriverId AND strOrderStatus = 'Open'

-- ++++++ CREATE ORDER's ITEM LIST ++++++ --
INSERT INTO tblMBILOrderItem(intOrderId
	, intSiteId
	, intItemId
	, intItemUOMId
	, dblQuantity
	, dblPrice)
SELECT [Order].intOrderId	
	, #Dispatch.intSiteId
	, #Dispatch.intItemId
	, #Dispatch.intItemUOMId	
	, #Dispatch.[dblQuantity]
	, #Dispatch.[dblPrice]
FROM #Dispatch
LEFT JOIN vyuMBILOrder [Order] ON #Dispatch.intDispatchId = [Order].intDispatchId
WHERE [Order].intDriverId = @intDriverId


-- ++++++ ITEM TAX CODE PROCESS ++++++ --
SELECT *
INTO #tempDriverOrder
FROM (
	SELECT A.*
		,B.intOrderItemId
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
	DELETE #tempDriverOrder WHERE intMBILOrderItemId = @MBILOrderId
END

--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspMBILBuildOrder] 125
