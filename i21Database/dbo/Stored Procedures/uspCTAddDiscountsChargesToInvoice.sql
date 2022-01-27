CREATE PROCEDURE [dbo].[uspCTAddDiscountsChargesToInvoice]
	@intContractDetailId int
	,@intInventoryShipmentId int
	,@UserId int
	,@intInvoiceDetailId int
	,@dblQuantityToCharge numeric(18,6)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE
	@ErrMsg				NVARCHAR(MAX)
	,@ZeroDecimal		DECIMAL(18,6) = 0.000000
	,@ZeroBit			DECIMAL(18,6) = convert(bit,0)
	,@OneBit			DECIMAL(18,6) = convert(bit,1)
    ,@DateOnly			DATETIME = convert(date, getdate())
	,@ErrorMessage		NVARCHAR(250)
	,@CreatedIvoices	NVARCHAR(MAX)
	,@UpdatedIvoices	NVARCHAR(MAX)
	,@dblQuantity		numeric(18,6)
	,@intInvoiceId		int
	,@dblISTotalQuantity		numeric(18,6)
	,@NewInvoiceDetailId int
	,@intActiveInventoryShipmentChargeId int
	,@strChargesLink nvarchar(100)
	,@strInvoiceDiscountsChargesIds nvarchar(500) = ''
	;

declare
	 @InvoiceId								INT
	,@ItemId								INT
	,@ItemPrepayRate						NUMERIC(18,6)
	,@ItemIsBlended							BIT
	,@ItemDocumentNumber					NVARCHAR(100)
	,@ItemDescription						NVARCHAR(500)
	,@ItemOrderUOMId						INT
	,@ItemPriceUOMId						INT
	,@ItemQtyOrdered						NUMERIC(38,20)
	,@ItemUOMId								INT
	,@ItemQtyShipped						NUMERIC(38,20)
	,@ItemDiscount							NUMERIC(18,6)
	,@ItemTermDiscount						NUMERIC(18,6)
	,@ItemTermDiscountBy					NVARCHAR(50)
	,@ItemPrice								NUMERIC(18,6)
	,@ItemUnitPrice							NUMERIC(18,6)
	,@ItemPricing							NVARCHAR(250)
	,@ItemMaintenanceAmount					NUMERIC(18,6)
	,@ItemLicenseAmount						NUMERIC(18,6)
	,@ItemTaxGroupId						INT
	,@ItemStorageLocationId					INT
	,@ItemCompanyLocationSubLocationId		INT
	,@ItemInventoryShipmentItemId			INT
	,@ItemInventoryShipmentChargeId			INT
	,@ItemShipmentNumber					NVARCHAR(50)
	,@ItemRecipeItemId						INT
	,@ItemRecipeId							INT
	,@ItemSublocationId						INT
	,@ItemCostTypeId						INT
	,@ItemMarginById						INT
	,@ItemCommentTypeId						INT
	,@ItemMargin							NUMERIC(18,6)
	,@ItemRecipeQty							NUMERIC(18,6)
	,@ItemSalesOrderDetailId				INT
	,@ItemSalesOrderNumber					NVARCHAR(50)
	,@ItemContractHeaderId					INT
	,@ItemContractDetailId					INT
	,@ItemShipmentId						INT
	,@ItemWeightUOMId						INT
	,@ItemWeight							NUMERIC(38,20)
	,@ItemShipmentGrossWt					NUMERIC(38,20)
	,@ItemShipmentTareWt					NUMERIC(38,20)
	,@ItemShipmentNetWt						NUMERIC(38,20)
	,@ItemTicketId							INT
	,@ItemConversionFactor					NUMERIC(18,8)
	,@ItemLeaseBilling						BIT
	,@EntitySalespersonId					INT
	,@ItemCurrencyExchangeRateTypeId		INT
	,@ItemCurrencyExchangeRateId			INT
	,@ItemCurrencyExchangeRate				NUMERIC(18,8)
	,@ItemSubCurrencyId						INT
	,@ItemSubCurrencyRate					NUMERIC(18,8)
	,@ItemStorageScheduleTypeId				INT
	,@ItemDestinationGradeId				INT
	,@ItemDestinationWeightId				INT
	;

declare @ChargesDiscounts table (
	intInventoryShipmentChargeId int
)

begin try

	if (isnull(@dblQuantityToCharge,0) = 0) return;

	select
		@dblQuantity = case when isnull(@dblQuantityToCharge,0) = 0 then di.dblQtyShipped else @dblQuantityToCharge end
		,@intInvoiceId = di.intInvoiceId
		,@dblISTotalQuantity = isnull(si.dblDestinationQuantity,si.dblQuantity)
		,@strChargesLink = si.strChargesLink
	from
		tblARInvoiceDetail di
		join tblICInventoryShipmentItem si on si.intInventoryShipmentItemId = di.intInventoryShipmentItemId
	where
		di.intInvoiceDetailId = @intInvoiceDetailId

	insert into @ChargesDiscounts
	select
		isc.intInventoryShipmentChargeId
	from
		tblICInventoryShipmentCharge isc
	where
		isc.intInventoryShipmentId = @intInventoryShipmentId
		and isc.strChargesLink = @strChargesLink


	if exists (select top 1 1 from @ChargesDiscounts)
	begin
		select @intActiveInventoryShipmentChargeId = min(intInventoryShipmentChargeId) from @ChargesDiscounts;
		while (@intActiveInventoryShipmentChargeId is not null)
		begin

			SELECT
				@ItemShipmentId                         = ICIS.[intInventoryShipmentId]
				,@ItemShipmentNumber                    = ICIS.[strShipmentNumber]
				,@InvoiceId								= @intInvoiceId
				,@EntitySalespersonId					= ch.intSalespersonId
				,@ItemContractHeaderId                  = ARSI.[intContractHeaderId]
				,@ItemId								= ARSI.[intItemId]
				,@ItemPrepayRate                        = @ZeroDecimal
				,@ItemDocumentNumber                    = ARSI.[strTransactionNumber]
				,@ItemDescription						= ARSI.[strItemDescription]
				,@ItemOrderUOMId                        = ARSI.[intOrderUOMId]
				,@ItemQtyOrdered                        = dbo.fnCTConvertQtyToTargetItemUOM(ICISI.intItemUOMId,ARSI.[intOrderUOMId],ICISI.dblQuantity)
				,@ItemUOMId								= ARSI.[intItemUOMId]
				,@ItemPriceUOMId                        = ARSI.[intPriceUOMId]
				,@ItemQtyShipped                        = ARSI.dblQtyShipped
				,@ItemDiscount                          = ARSI.[dblDiscount]
				,@ItemTermDiscount						= @ZeroDecimal
				,@ItemTermDiscountBy					= ''
				,@ItemWeight							= ARSI.[dblWeight]
				,@ItemWeightUOMId						= ARSI.[intWeightUOMId]
				,@ItemPrice                             = (@dblQuantity / @dblISTotalQuantity) * ARSI.[dblShipmentUnitPrice]
				,@ItemUnitPrice                         = (@dblQuantity / @dblISTotalQuantity) * ARSI.[dblUnitPrice]
				,@ItemPricing                           = ARSI.[strPricing]
				,@ItemMaintenanceAmount                 = @ZeroDecimal
				,@ItemLicenseAmount                     = @ZeroDecimal
				,@ItemTaxGroupId                        = ARSI.[intTaxGroupId] 
				,@ItemStorageLocationId                 = ARSI.[intStorageLocationId] 
				,@ItemCompanyLocationSubLocationId      = ARSI.[intSubLocationId]
				,@ItemInventoryShipmentItemId           = ARSI.[intInventoryShipmentItemId] 
				,@ItemInventoryShipmentChargeId         = ARSI.[intInventoryShipmentChargeId]
				,@ItemRecipeItemId                      = ARSI.[intRecipeItemId]
				,@ItemRecipeId                          = ARSI.[intRecipeId]
				,@ItemSublocationId                     = ARSI.[intSubLocationId]
				,@ItemCostTypeId                        = ARSI.[intCostTypeId]
				,@ItemMarginById                        = ARSI.[intMarginById]
				,@ItemCommentTypeId                     = ARSI.[intCommentTypeId]
				,@ItemMargin                            = ARSI.[dblMargin]
				,@ItemRecipeQty							= ARSI.[dblRecipeQuantity]
				,@ItemSalesOrderDetailId                = ARSI.[intSalesOrderDetailId]
				,@ItemSalesOrderNumber                  = ARSI.[strSalesOrderNumber]
				,@ItemContractDetailId                  = ARSI.[intContractDetailId]
				,@ItemShipmentGrossWt                   = ARSI.[dblGrossWt]
				,@ItemShipmentTareWt                    = ARSI.[dblTareWt]
				,@ItemShipmentNetWt                     = ARSI.[dblNetWt]
				,@ItemTicketId                          = ARSI.[intTicketId]
				,@ItemConversionFactor                  = @ZeroDecimal
				,@ItemLeaseBilling                      = @ZeroBit
				,@ItemCurrencyExchangeRateTypeId        = ARSI.[intCurrencyExchangeRateTypeId]
				,@ItemCurrencyExchangeRateId            = ARSI.[intCurrencyExchangeRateId]
				,@ItemCurrencyExchangeRate              = ARSI.[dblCurrencyExchangeRate]
				,@ItemSubCurrencyId                     = ARSI.[intSubCurrencyId]
				,@ItemSubCurrencyRate                   = ARSI.[dblSubCurrencyRate]
				,@ItemIsBlended                         = ARSI.[ysnBlended]
				,@ItemStorageScheduleTypeId             = ARSI.[intStorageScheduleTypeId]
				,@ItemDestinationGradeId                = ARSI.[intDestinationGradeId]
				,@ItemDestinationWeightId               = ARSI.[intDestinationWeightId]
			FROM
				tblICInventoryShipment ICIS with (nolock)
				INNER JOIN tblICInventoryShipmentItem ICISI with (nolock) on ICISI.intInventoryShipmentId = ICIS.intInventoryShipmentId and ICISI.intLineNo = @intContractDetailId
				INNER JOIN vyuARShippedItems ARSI with (nolock) ON ICIS.[intInventoryShipmentId] = ARSI.[intInventoryShipmentId] and ARSI.intContractDetailId = ICISI.intLineNo
				LEFT JOIN tblCTContractDetail CD with (nolock) ON CD.intContractDetailId = ARSI.intContractDetailId 
				left join tblCTContractHeader ch with (nolock) on ch.intContractHeaderId = CD.intContractHeaderId
			WHERE
				 ARSI.strTransactionType = 'Inventory Shipment'
				 and ARSI.intInventoryShipmentChargeId = @intActiveInventoryShipmentChargeId
				 AND ICIS.[intInventoryShipmentId] = @intInventoryShipmentId

			EXEC [uspARAddItemToInvoice]
				@InvoiceId                             =	@InvoiceId
				,@ItemId                                =	@ItemId
				,@ItemPrepayRate                        =	@ItemPrepayRate
				,@ItemIsBlended                         =	@ItemIsBlended
				,@RaiseError                            =	1           
				,@ItemDocumentNumber					=	@ItemDocumentNumber
				,@ItemDescription                       =	@ItemDescription
				,@ItemOrderUOMId                        =	@ItemOrderUOMId
				,@ItemPriceUOMId                        =	@ItemPriceUOMId
				,@ItemQtyOrdered                        =	@ItemQtyOrdered
				,@ItemUOMId                             =	@ItemUOMId
				,@ItemQtyShipped                        =	@ItemQtyShipped
				,@ItemDiscount                          =	@ItemDiscount
				,@ItemTermDiscount                      =	@ItemTermDiscount
				,@ItemTermDiscountBy					=	@ItemTermDiscountBy
				,@ItemPrice                             =	@ItemPrice
				,@ItemUnitPrice                         =	@ItemUnitPrice
				,@ItemPricing                           =	@ItemPricing
				,@RefreshPrice                          =	0
				,@ItemMaintenanceAmount                 =	@ItemMaintenanceAmount
				,@ItemLicenseAmount                     =	@ItemLicenseAmount
				,@ItemTaxGroupId                        =	@ItemTaxGroupId
				,@ItemStorageLocationId                 =	@ItemStorageLocationId
				,@ItemCompanyLocationSubLocationId		=	@ItemCompanyLocationSubLocationId
				,@RecomputeTax							=	1
				,@ItemInventoryShipmentItemId			=	@ItemInventoryShipmentItemId
				,@ItemInventoryShipmentChargeId			=	@ItemInventoryShipmentChargeId
				,@ItemShipmentNumber					=	@ItemShipmentNumber
				,@ItemRecipeItemId						=	@ItemRecipeItemId
				,@ItemRecipeId							=	@ItemRecipeId
				,@ItemSublocationId						=	@ItemSublocationId
				,@ItemCostTypeId						=	@ItemCostTypeId
				,@ItemMarginById						=	@ItemMarginById
				,@ItemCommentTypeId						=	@ItemCommentTypeId
				,@ItemMargin							=	@ItemMargin
				,@ItemRecipeQty							=	@ItemRecipeQty
				,@ItemSalesOrderDetailId				=	@ItemSalesOrderDetailId
				,@ItemSalesOrderNumber					=	@ItemSalesOrderNumber
				,@ContractHeaderId						=	@ItemContractHeaderId
				,@ContractDetailId						=	@ItemContractDetailId
				,@ItemShipmentId						=	@ItemShipmentId
				,@ItemWeightUOMId                       =	@ItemWeightUOMId
				,@ItemWeight                            =	@ItemWeight
				,@ItemShipmentGrossWt                   =	@ItemShipmentGrossWt
				,@ItemShipmentTareWt					=	@ItemShipmentTareWt
				,@ItemShipmentNetWt                     =	@ItemShipmentNetWt
				,@ItemTicketId                          =	@ItemTicketId
				,@ItemConversionFactor                  =	@ItemConversionFactor
				,@ItemLeaseBilling                      =	@ItemLeaseBilling
				,@EntitySalespersonId                   =	@EntitySalespersonId
				,@ItemCurrencyExchangeRateTypeId		=	@ItemCurrencyExchangeRateTypeId
				,@ItemCurrencyExchangeRateId			=	@ItemCurrencyExchangeRateId
				,@ItemCurrencyExchangeRate				=	@ItemCurrencyExchangeRate
				,@ItemSubCurrencyId                     =	@ItemSubCurrencyId
				,@ItemSubCurrencyRate                   =	@ItemSubCurrencyRate
				,@ItemStorageScheduleTypeId				=	@ItemStorageScheduleTypeId
				,@ItemDestinationGradeId				=	@ItemDestinationGradeId
				,@ItemDestinationWeightId				=	@ItemDestinationWeightId
				,@NewInvoiceDetailId					=	@NewInvoiceDetailId	OUTPUT	

			if (isnull(@NewInvoiceDetailId,0) > 0)
			begin
				select @strInvoiceDiscountsChargesIds = @strInvoiceDiscountsChargesIds + convert(nvarchar(20),@NewInvoiceDetailId) + ',';
			end

			select @intActiveInventoryShipmentChargeId = min(intInventoryShipmentChargeId) from @ChargesDiscounts where intInventoryShipmentChargeId > @intActiveInventoryShipmentChargeId;
		end

	end

	if (isnull(@strInvoiceDiscountsChargesIds,'') <> '')
	begin
		update tblCTPriceFixationDetailAPAR set strInvoiceDiscountsChargesIds = @strInvoiceDiscountsChargesIds where intInvoiceDetailId = @intInvoiceDetailId;
	end

	EXEC dbo.uspARUpdateInvoiceIntegrations @InvoiceId = @intInvoiceId, @UserId = @UserId, @ysnLogRisk	= 0

end try
begin catch
	
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

end catch

