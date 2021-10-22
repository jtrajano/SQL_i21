CREATE PROCEDURE [dbo].[uspCTCreateVoucher]
	@voucherPayables AS VoucherPayable READONLY
	,@voucherPayableTax AS VoucherDetailTax READONLY
	,@userId INT
	,@throwError BIT = 1
	,@error NVARCHAR(1000) = NULL OUTPUT
	,@createdVouchersId NVARCHAR(MAX) OUT
AS

begin try
	
	/*Process immediately if the IR is not created for Contract*/
	if exists (
	select
		top 1 1
	from
		tblICInventoryReceipt ir
		,tblICInventoryReceiptItem ri
		,@voucherPayables vp
	where
		ri.intInventoryReceiptItemId = vp.intInventoryReceiptItemId
		and ir.intInventoryReceiptId = ri.intInventoryReceiptId
		and (ir.strReceiptType <> 'Purchase Contract' or isnull(vp.intContractDetailId,0) = 0)
	)
	begin

	   exec uspAPCreateVoucher    
		@voucherPayables = @voucherPayables    
		,@voucherPayableTax = @voucherPayableTax    
		,@userId = @userId    
		,@throwError = @throwError  
		,@error = @error    
		,@createdVouchersId  = @createdVouchersId out  

		goto _return;

	end
	
	declare
		@voucherPayablesFinal			VoucherPayable
		,@voucherPayableTaxFinal		VoucherDetailTax
		,@voucherPayableProRatedCharges VoucherPayable
		,@voucherPayableProRatedChargeTaxes	VoucherDetailTax
		,@intPartitionId				INT 
		,@intBillId						INT 
		,@intEntityVendorId				INT
		,@intTransactionType			INT
		,@intLocationId					INT
		,@intShipToId					INT
		,@intShipFromId					INT
		,@intShipFromEntityId			INT
		,@intPayToAddressId				INT
		,@intCurrencyId					INT
		,@dtmDate						DATETIME
		,@dtmVoucherDate				DATETIME
		,@dtmDueDate					DATETIME
		,@strVendorOrderNumber			NVARCHAR (MAX)
		,@strReference					NVARCHAR(400)
		,@strSourceNumber				NVARCHAR(400)
		,@intSubCurrencyCents			INT
		,@intShipViaId					INT
		,@intTermId						INT
		,@strBillOfLading				NVARCHAR(400)
		,@strCheckComment				NVARCHAR (200)
		,@intAPAccount					INT
		,@strMiscDescription			NVARCHAR(1000)
		,@intItemId						INT
		,@ysnSubCurrency				INT
		,@intAccountId					INT
		,@ysnReturn						BIT
		,@intLineNo						INT
		,@intItemLocationId				INT
		,@intStorageLocationId			INT
		,@intSubLocationId				INT
		,@dblBasis						DECIMAL(18, 6)
		,@dblFutures					DECIMAL(18, 6)
		,@intPurchaseDetailId			INT
		,@intContractHeaderId			INT
		,@intContractCostId				INT
		,@intContractSeqId				INT
		,@intContractDetailId			INT
		,@intScaleTicketId				INT
		,@intInventoryReceiptItemId		INT
		,@intInventoryReceiptChargeId	INT
		,@intInventoryShipmentItemId	INT
		,@intInventoryShipmentChargeId	INT
		,@intLoadShipmentId				INT
		,@intLoadShipmentDetailId		INT
		,@intLoadShipmentCostId			INT
		,@intPaycheckHeaderId			INT
		,@intCustomerStorageId			INT
		,@intSettleStorageId			INT
		,@intCCSiteDetailId				INT
		,@intInvoiceId					INT
		,@intBuybackChargeId			INT
		,@intTicketId					INT
		,@dblOrderQty					DECIMAL(38,15)
		,@dblOrderUnitQty				DECIMAL(38,20)
		,@intOrderUOMId					INT
		,@dblQuantityToBill				DECIMAL(38,15)
		,@dblQtyToBillUnitQty			DECIMAL(38,20)
		,@intQtyToBillUOMId				INT
		,@dblCost						DECIMAL(38,20)
		,@dblOldCost					DECIMAL(38,20)
		,@dblCostUnitQty				DECIMAL(38,20)
		,@intCostUOMId					INT
		,@intCostCurrencyId				INT
		,@dblWeight						DECIMAL(18,6)
		,@dblNetWeight					DECIMAL(18,6)
		,@dblWeightUnitQty				DECIMAL(38,20)
		,@intWeightUOMId				INT
		,@intCurrencyExchangeRateTypeId	INT
		,@dblExchangeRate				DECIMAL(18,6)
		,@intPurchaseTaxGroupId			INT
		,@dblTax						DECIMAL(18,2)
		,@dblDiscount					DECIMAL(18,2)
		,@dblDetailDiscountPercent		DECIMAL(18,2)
		,@ysnDiscountOverride			BIT
		,@intDeferredVoucherId			INT
		,@dtmDeferredInterestDate		DATETIME
		,@dtmInterestAccruedThru		DATETIME
		,@dblPrepayPercentage			DECIMAL(18,6)
		,@intPrepayTypeId				INT
		,@dblNetShippedWeight			DECIMAL(18,6)
		,@dblWeightLoss					DECIMAL(18,6)
		,@dblFranchiseWeight			DECIMAL(18,6)
		,@dblFranchiseAmount			DECIMAL(18,6)
		,@dblActual						DECIMAL(18,6)
		,@dblDifference					DECIMAL(18,6)
		,@int1099Form					INT
		,@int1099Category				INT
		,@dbl1099						DECIMAL(18,6)
		,@ysnStage						BIT;

	declare @voucherPayablesDataTemp as table (
		intVoucherPayableId int
		,dblQuantityToBill decimal(38,15)
		,intContractDetailId int
		,intInventoryReceiptItemId int
		,intQtyToBillUOMId int 
	);

	declare @availablePrice as table (
		intId int
		,intPriceFixationId int
		,intPriceFixationDetailId int
		,dblFinalPrice numeric(18,6)
		,dblAvailablePriceQuantity numeric(18,6)
		,dtmFixationDate datetime
		,dblPriceQuantity numeric(18,6)
		,intAvailablePriceLoad int
		,intPricingTypeId int
		,intFreightTermId int
		,intCompanyLocationId int
	);

	declare 
		@intVoucherPayableId int
		,@previous_intVoucherPayableId INT
		,@intContractTypeId int
		,@intPriceFixationId int
		,@intPriceFixationDetailId int
		,@dblFinalPrice numeric(18,6)
		,@dblAvailablePriceQuantity numeric(18,6)
		,@dtmFixationDate datetime
		,@dblPriceQuantity numeric(18,6)
		,@intAvailablePriceLoad int
		,@dblTransactionQuantity numeric(18,6)
		,@ysnLoad bit = 0
		,@intInventoryReceiptId int
		,@ysnSuccessBillPosting bit
  		,@receiptDetails InventoryUpdateBillQty
  		,@intId int
		,@intPricingTypeId int
		,@intFreightTermId int
		,@intCompanyLocationId int
		;

	declare @CreatedVoucher as table(
		intBillId int   
	   ,intBillDetailId int
	   ,intPriceFixationDetailId int
	   ,intInventoryReceiptId int
	   ,intInventoryReceiptItemId int
	   ,dblQtyReceived numeric(18,6)
	   ,intQtyToBillUOMId int
	);

	insert into
		@voucherPayablesDataTemp
	select
		intVoucherPayableId = a.intVoucherPayableId
		,dblQuantityToBill = (case when a.dblQuantityToBill > ri.dblOpenReceive then ri.dblOpenReceive else a.dblQuantityToBill end)
		,intContractDetailId = a.intContractDetailId
		,intInventoryReceiptItemId = a.intInventoryReceiptItemId
		,intQtyToBillUOMId = a.intQtyToBillUOMId
	from
		@voucherPayables a
		join tblICInventoryReceiptItem ri on ri.intInventoryReceiptItemId = a.intInventoryReceiptItemId
	where
		isnull(a.intInventoryReceiptChargeId,0) = 0
		and a.intContractDetailId is not null;

	--Loop through Payables data
	select @intVoucherPayableId = min(intVoucherPayableId) from @voucherPayablesDataTemp where isnull(dblQuantityToBill,0) > 0;
	while (@intVoucherPayableId is not null)
	begin

		select
			@intVoucherPayableId = intVoucherPayableId
			,@dblQuantityToBill = dblQuantityToBill
			,@intContractDetailId = intContractDetailId
			,@intInventoryReceiptItemId = intInventoryReceiptItemId
			,@intQtyToBillUOMId = intQtyToBillUOMId
		from
			@voucherPayablesDataTemp
		where
			intVoucherPayableId = @intVoucherPayableId

		--Get Receipt Id
		select @intInventoryReceiptId = intInventoryReceiptId from tblICInventoryReceiptItem where intInventoryReceiptItemId = @intInventoryReceiptItemId;

		--Check if Load base contract
		select @ysnLoad = ysnLoad from tblCTContractDetail cd, tblCTContractHeader ch where cd.intContractDetailId = @intContractDetailId and ch.intContractHeaderId = cd.intContractHeaderId;
		if (isnull(@ysnLoad,0) = 1)
		begin
			select @dblTransactionQuantity = count(distinct bd.intBillId) from tblAPBillDetail bd where bd.intInventoryReceiptItemId = @intInventoryReceiptItemId;
			--If load based and Receipt has voucher, remove from the list and continue loop
			if (isnull(@dblTransactionQuantity,0) > 0)
			begin
				delete from @voucherPayablesDataTemp where intVoucherPayableId = @intVoucherPayableId;
				goto ReciptNextLoop;
			end
		end

		/*Check if there's available priced quantity*/ 
		delete from @availablePrice;
		insert into @availablePrice
		select
			intId = intId
			,intPriceFixationId = intPriceFixationId  
			,intPriceFixationDetailId = intPriceFixationDetailId  
			,dblFinalPrice = dblFinalprice  
			,dblAvailablePriceQuantity = dblAvailableQuantity  
			,dtmFixationDate = dtmFixationDate  
			,dblPriceQuantity = dblQuantity  
			,intAvailablePriceLoad = intAvailableLoad
			,intPricingTypeId = intPricingTypeId
			,intFreightTermId = intFreightTermId
			,intCompanyLocationId = intCompanyLocationId 
		from  
			vyuCTGetAvailablePriceForVoucher  
		where  
			intContractDetailId = @intContractDetailId  
		order by intPriceFixationDetailId 

		/*Loop Pricing*/
		select @intId = min(intId) from @availablePrice where (isnull(dblAvailablePriceQuantity,0) > 0 or isnull(intAvailablePriceLoad,0) > 0);
		while (@intId is not null and isnull(@dblQuantityToBill,0) > 0)
		begin
		
			/*Get Price Details*/
			select
				@intPriceFixationId = intPriceFixationId 
				,@dblFinalPrice = dblFinalPrice  
				,@dblAvailablePriceQuantity = dblAvailablePriceQuantity  
				,@dtmFixationDate = dtmFixationDate  
				,@dblPriceQuantity = dblPriceQuantity  
				,@intAvailablePriceLoad = intAvailablePriceLoad
				,@intPriceFixationDetailId = intPriceFixationDetailId 
				,@intPricingTypeId = intPricingTypeId
				,@intFreightTermId = intFreightTermId
				,@intCompanyLocationId = intCompanyLocationId 
			from  
				@availablePrice  
			where
				intId = @intId

			--Set @dblTransactionQuantity = @dblQuantityToBill by default (this is also correct quantity for Load Based)
			set @dblTransactionQuantity = @dblQuantityToBill;

			if (isnull(@ysnLoad,0) = 0 and @dblTransactionQuantity > @dblAvailablePriceQuantity)
			begin
				--If not load based and the @dblAvailablePriceQuantity is less than the @dblQuantityToBill, price quantity should be the quantity to bill
				set @dblTransactionQuantity = @dblAvailablePriceQuantity;
			end
			else
			begin
				--If load based, deduct 1 load from the available priced load
				update @availablePrice set intAvailablePriceLoad = (intAvailablePriceLoad - 1) where intPriceFixationDetailId = @intPriceFixationDetailId;
			end

			--Deduct the quantity
			set @dblQuantityToBill = (@dblQuantityToBill - @dblTransactionQuantity);
			update @voucherPayablesDataTemp set dblQuantityToBill = (dblQuantityToBill - @dblTransactionQuantity) where intVoucherPayableId = @intVoucherPayableId;
			update @availablePrice set dblAvailablePriceQuantity = (dblAvailablePriceQuantity - @dblTransactionQuantity) where intPriceFixationDetailId = @intPriceFixationDetailId;
			
			--Construct voucher data
			insert into @voucherPayablesFinal (
				intPartitionId
				,intBillId
				,intEntityVendorId
				,intTransactionType
				,intLocationId
				,intShipToId
				,intShipFromId
				,intShipFromEntityId
				,intPayToAddressId
				,intCurrencyId
				,dtmDate
				,dtmVoucherDate
				,dtmDueDate
				,strVendorOrderNumber
				,strReference
				,strSourceNumber
				,intSubCurrencyCents
				,intShipViaId
				,intTermId
				,strBillOfLading
				,strCheckComment
				,intAPAccount
				,strMiscDescription
				,intItemId
				,ysnSubCurrency
				,intAccountId
				,ysnReturn
				,intLineNo
				,intItemLocationId
				,intStorageLocationId
				,intSubLocationId
				,dblBasis
				,dblFutures
				,intPurchaseDetailId
				,intContractHeaderId
				,intContractCostId
				,intContractSeqId
				,intContractDetailId
				,intScaleTicketId
				,intInventoryReceiptItemId
				,intInventoryReceiptChargeId
				,intInventoryShipmentItemId
				,intInventoryShipmentChargeId
				,intLoadShipmentId
				,intLoadShipmentDetailId
				,intLoadShipmentCostId
				,intPaycheckHeaderId
				,intCustomerStorageId
				,intSettleStorageId
				,intCCSiteDetailId
				,intInvoiceId
				,intBuybackChargeId
				,intTicketId
				,dblOrderQty
				,dblOrderUnitQty
				,intOrderUOMId
				,dblQuantityToBill
				,dblQtyToBillUnitQty
				,intQtyToBillUOMId
				,dblCost
				,dblOldCost
				,dblCostUnitQty
				,intCostUOMId
				,intCostCurrencyId
				,dblWeight
				,dblNetWeight
				,dblWeightUnitQty
				,intWeightUOMId
				,intCurrencyExchangeRateTypeId
				,dblExchangeRate
				,intPurchaseTaxGroupId
				,dblTax
				,dblDiscount
				,dblDetailDiscountPercent
				,ysnDiscountOverride
				,intDeferredVoucherId
				,dtmDeferredInterestDate
				,dtmInterestAccruedThru
				,dblPrepayPercentage
				,intPrepayTypeId
				,dblNetShippedWeight
				,dblWeightLoss
				,dblFranchiseWeight
				,dblFranchiseAmount
				,dblActual
				,dblDifference
				,int1099Form
				,int1099Category
				,dbl1099
				,ysnStage				
				,dblRatio
				,intPriceFixationDetailId
			)
			select
				intPartitionId = vp.intPartitionId
				,intBillId = vp.intBillId
				,intEntityVendorId = vp.intEntityVendorId
				,intTransactionType = vp.intTransactionType
				,intLocationId = vp.intLocationId
				,intShipToId = vp.intShipToId
				,intShipFromId = vp.intShipFromId
				,intShipFromEntityId = vp.intShipFromEntityId
				,intPayToAddressId = vp.intPayToAddressId
				,intCurrencyId = vp.intCurrencyId
				,dtmDate = vp.dtmDate
				,dtmVoucherDate = vp.dtmVoucherDate
				,dtmDueDate = vp.dtmDueDate
				,strVendorOrderNumber = vp.strVendorOrderNumber
				,strReference = vp.strReference
				,strSourceNumber = vp.strSourceNumber
				,intSubCurrencyCents = vp.intSubCurrencyCents
				,intShipViaId = vp.intShipViaId
				,intTermId = vp.intTermId
				,strBillOfLading = vp.strBillOfLading
				,strCheckComment = vp.strCheckComment
				,intAPAccount = vp.intAPAccount
				,strMiscDescription = vp.strMiscDescription
				,intItemId = vp.intItemId
				,ysnSubCurrency = vp.ysnSubCurrency
				,intAccountId = vp.intAccountId
				,ysnReturn = vp.ysnReturn
				,intLineNo = vp.intLineNo
				,intItemLocationId = vp.intItemLocationId
				,intStorageLocationId = vp.intStorageLocationId
				,intSubLocationId = vp.intSubLocationId
				,dblBasis = vp.dblBasis
				,dblFutures = vp.dblFutures
				,intPurchaseDetailId = vp.intPurchaseDetailId
				,intContractHeaderId = vp.intContractHeaderId
				,intContractCostId = vp.intContractCostId
				,intContractSeqId = vp.intContractSeqId
				,intContractDetailId = vp.intContractDetailId
				,intScaleTicketId = vp.intScaleTicketId
				,intInventoryReceiptItemId = vp.intInventoryReceiptItemId
				,intInventoryReceiptChargeId = vp.intInventoryReceiptChargeId
				,intInventoryShipmentItemId = vp.intInventoryShipmentItemId
				,intInventoryShipmentChargeId = vp.intInventoryShipmentChargeId
				,intLoadShipmentId = vp.intLoadShipmentId
				,intLoadShipmentDetailId = vp.intLoadShipmentDetailId
				,intLoadShipmentCostId = vp.intLoadShipmentCostId
				,intPaycheckHeaderId = vp.intPaycheckHeaderId
				,intCustomerStorageId = vp.intCustomerStorageId
				,intSettleStorageId = vp.intSettleStorageId
				,intCCSiteDetailId = vp.intCCSiteDetailId
				,intInvoiceId = vp.intInvoiceId
				,intBuybackChargeId = vp.intBuybackChargeId
				,intTicketId = vp.intTicketId
				,dblOrderQty = vp.dblOrderQty
				,dblOrderUnitQty = vp.dblOrderUnitQty
				,intOrderUOMId = vp.intOrderUOMId
				,dblQuantityToBill = @dblTransactionQuantity
				,dblQtyToBillUnitQty = vp.dblQtyToBillUnitQty
				,intQtyToBillUOMId = vp.intQtyToBillUOMId
				,dblCost = @dblFinalPrice
				,dblOldCost = vp.dblOldCost
				,dblCostUnitQty = vp.dblCostUnitQty
				,intCostUOMId = vp.intCostUOMId
				,intCostCurrencyId = vp.intCostCurrencyId
				,dblWeight = vp.dblWeight
				,dblNetWeight = @dblTransactionQuantity
				,dblWeightUnitQty = vp.dblWeightUnitQty
				,intWeightUOMId = vp.intWeightUOMId
				,intCurrencyExchangeRateTypeId = vp.intCurrencyExchangeRateTypeId
				,dblExchangeRate = vp.dblExchangeRate
				,intPurchaseTaxGroupId = (case when isnull(vp.intPurchaseTaxGroupId,0) = 0 then dbo.fnGetTaxGroupIdForVendor(vp.intEntityVendorId,@intCompanyLocationId,vp.intItemId,em.intEntityLocationId,@intFreightTermId) else vp.intPurchaseTaxGroupId end)
				,dblTax = vp.dblTax
				,dblDiscount = vp.dblDiscount
				,dblDetailDiscountPercent = vp.dblDetailDiscountPercent
				,ysnDiscountOverride = vp.ysnDiscountOverride
				,intDeferredVoucherId = vp.intDeferredVoucherId
				,dtmDeferredInterestDate = vp.dtmDeferredInterestDate
				,dtmInterestAccruedThru = vp.dtmInterestAccruedThru
				,dblPrepayPercentage = vp.dblPrepayPercentage
				,intPrepayTypeId = vp.intPrepayTypeId
				,dblNetShippedWeight = vp.dblNetShippedWeight
				,dblWeightLoss = vp.dblWeightLoss
				,dblFranchiseWeight = vp.dblFranchiseWeight
				,dblFranchiseAmount = vp.dblFranchiseAmount
				,dblActual = vp.dblActual
				,dblDifference = vp.dblDifference
				,int1099Form = vp.int1099Form
				,int1099Category = vp.int1099Category
				,dbl1099 = vp.dbl1099
				,ysnStage = 
					CASE WHEN hasExistingPayable.intVoucherPayableId IS NOT NULL THEN 1 ELSE 0 END 
				,dblRatio = 
					dbo.fnDivide(
						@dblTransactionQuantity
						,dblQuantityToBill
					)
				,intPriceFixationDetailId = @intPriceFixationDetailId
			from
				@voucherPayables vp
				left join tblEMEntityLocation em ON em.intEntityId = vp.intEntityVendorId and isnull(em.ysnDefaultLocation,0) = 1
				OUTER APPLY (
					SELECT TOP 1 
						ap.intVoucherPayableId
					FROM
						tblAPVoucherPayable ap
					WHERE
						ap.strSourceNumber = vp.strSourceNumber
						AND ap.intInventoryReceiptItemId = vp.intInventoryReceiptItemId 
						AND ap.intInventoryReceiptChargeId IS NULL 
						AND vp.intInventoryReceiptChargeId IS NULL										
				) hasExistingPayable
			where
				vp.intVoucherPayableId = @intVoucherPayableId
				
			-- Get the pro-rated other charges. 
			DELETE FROM @voucherPayableProRatedCharges
			INSERT INTO @voucherPayableProRatedCharges (
				[intEntityVendorId]			
				,[intTransactionType]		
				,[intLocationId]	
				,[intShipToId]	
				,[intShipFromId]			
				,[intShipFromEntityId]
				,[intPayToAddressId]
				,[intCurrencyId]					
				,[dtmDate]				
				,[strVendorOrderNumber]			
				,[strReference]						
				,[strSourceNumber]					
				,[intPurchaseDetailId]				
				,[intContractHeaderId]				
				,[intContractDetailId]				
				,[intContractSeqId]					
				,[intScaleTicketId]					
				,[intInventoryReceiptItemId]		
				,[intInventoryReceiptChargeId]		
				,[intInventoryShipmentItemId]		
				,[intInventoryShipmentChargeId]		
				,[intLoadShipmentId]				
				,[intLoadShipmentDetailId]	
				,[intLoadShipmentCostId]		
				,[intItemId]						
				,[intPurchaseTaxGroupId]			
				,[strMiscDescription]				
				,[dblOrderQty]						
				,[dblOrderUnitQty]					
				,[intOrderUOMId]					
				,[dblQuantityToBill]				
				,[dblQtyToBillUnitQty]				
				,[intQtyToBillUOMId]				
				,[dblCost]							
				,[dblCostUnitQty]					
				,[intCostUOMId]						
				,[dblNetWeight]						
				,[dblWeightUnitQty]					
				,[intWeightUOMId]					
				,[intCostCurrencyId]
				,[dblTax]							
				,[dblDiscount]
				,[intCurrencyExchangeRateTypeId]	
				,[dblExchangeRate]					
				,[ysnSubCurrency]					
				,[intSubCurrencyCents]				
				,[intAccountId]						
				,[intShipViaId]						
				,[intTermId]		
				,[intFreightTermId]				
				,[strBillOfLading]					
				,[ysnReturn]
				,[ysnStage]
				,[dblRatio]
			)
			EXEC uspICGetProRatedReceiptCharges
				@intInventoryReceiptItemId = @intInventoryReceiptItemId
				,@intBillUOMId = @intQtyToBillUOMId
				,@dblQtyBilled = @dblTransactionQuantity			
			
			-- Insert the pro-rated other charges. 
			INSERT INTO @voucherPayablesFinal (
				[intEntityVendorId]			
				,[intTransactionType]		
				,[intLocationId]	
				,[intShipToId]	
				,[intShipFromId]			
				,[intShipFromEntityId]
				,[intPayToAddressId]
				,[intCurrencyId]					
				,[dtmDate]				
				,[strVendorOrderNumber]			
				,[strReference]						
				,[strSourceNumber]					
				,[intPurchaseDetailId]				
				,[intContractHeaderId]				
				,[intContractDetailId]				
				,[intContractSeqId]					
				,[intScaleTicketId]					
				,[intInventoryReceiptItemId]		
				,[intInventoryReceiptChargeId]		
				,[intInventoryShipmentItemId]		
				,[intInventoryShipmentChargeId]		
				,[intLoadShipmentId]				
				,[intLoadShipmentDetailId]	
				,[intLoadShipmentCostId]		
				,[intItemId]						
				,[intPurchaseTaxGroupId]			
				,[strMiscDescription]				
				,[dblOrderQty]						
				,[dblOrderUnitQty]					
				,[intOrderUOMId]					
				,[dblQuantityToBill]				
				,[dblQtyToBillUnitQty]				
				,[intQtyToBillUOMId]				
				,[dblCost]							
				,[dblCostUnitQty]					
				,[intCostUOMId]						
				,[dblNetWeight]						
				,[dblWeightUnitQty]					
				,[intWeightUOMId]					
				,[intCostCurrencyId]
				,[dblTax]							
				,[dblDiscount]
				,[intCurrencyExchangeRateTypeId]	
				,[dblExchangeRate]					
				,[ysnSubCurrency]					
				,[intSubCurrencyCents]				
				,[intAccountId]						
				,[intShipViaId]						
				,[intTermId]		
				,[intFreightTermId]				
				,[strBillOfLading]					
				,[ysnReturn]
				,[ysnStage]
				,[dblRatio]
			)
			SELECT 
				[intEntityVendorId]			
				,[intTransactionType]		
				,[intLocationId]	
				,[intShipToId]	
				,[intShipFromId]			
				,[intShipFromEntityId]
				,[intPayToAddressId]
				,[intCurrencyId]					
				,[dtmDate]				
				,[strVendorOrderNumber]			
				,[strReference]						
				,[strSourceNumber]					
				,[intPurchaseDetailId]				
				,[intContractHeaderId]				
				,[intContractDetailId]				
				,[intContractSeqId]					
				,[intScaleTicketId]					
				,[intInventoryReceiptItemId]		
				,[intInventoryReceiptChargeId]		
				,[intInventoryShipmentItemId]		
				,[intInventoryShipmentChargeId]		
				,[intLoadShipmentId]				
				,[intLoadShipmentDetailId]	
				,[intLoadShipmentCostId]		
				,[intItemId]						
				,[intPurchaseTaxGroupId]			
				,[strMiscDescription]				
				,[dblOrderQty]						
				,[dblOrderUnitQty]					
				,[intOrderUOMId]					
				,[dblQuantityToBill]				
				,[dblQtyToBillUnitQty]				
				,[intQtyToBillUOMId]				
				,[dblCost]							
				,[dblCostUnitQty]					
				,[intCostUOMId]						
				,[dblNetWeight]						
				,[dblWeightUnitQty]					
				,[intWeightUOMId]					
				,[intCostCurrencyId]
				,[dblTax]							
				,[dblDiscount]
				,[intCurrencyExchangeRateTypeId]	
				,[dblExchangeRate]					
				,[ysnSubCurrency]					
				,[intSubCurrencyCents]				
				,[intAccountId]						
				,[intShipViaId]						
				,[intTermId]		
				,[intFreightTermId]				
				,[strBillOfLading]					
				,[ysnReturn]
				,[ysnStage]
				,[dblRatio]
			FROM 
				@voucherPayableProRatedCharges				

			--select @intPriceFixationDetailId = null;
			select @intId = min(intId) from @availablePrice where (isnull(dblAvailablePriceQuantity,0) > 0 or isnull(intAvailablePriceLoad,0) > 0) and intId > @intId;
		end
					
		ReciptNextLoop:
		SELECT @previous_intVoucherPayableId = @intVoucherPayableId
		select @intVoucherPayableId = null
		select @intVoucherPayableId = min(intVoucherPayableId) from @voucherPayablesDataTemp where isnull(dblQuantityToBill,0) > 0 and intVoucherPayableId > @previous_intVoucherPayableId;  
	end
	
	--add the non-contract items (charges, overage/spot....)
	insert into @voucherPayablesFinal(
				intPartitionId
				,intBillId
				,intEntityVendorId
				,intTransactionType
				,intLocationId
				,intShipToId
				,intShipFromId
				,intShipFromEntityId
				,intPayToAddressId
				,intCurrencyId
				,dtmDate
				,dtmVoucherDate
				,dtmDueDate
				,strVendorOrderNumber
				,strReference
				,strSourceNumber
				,intSubCurrencyCents
				,intShipViaId
				,intTermId
				,strBillOfLading
				,strCheckComment
				,intAPAccount
				,strMiscDescription
				,intItemId
				,ysnSubCurrency
				,intAccountId
				,ysnReturn
				,intLineNo
				,intItemLocationId
				,intStorageLocationId
				,intSubLocationId
				,dblBasis
				,dblFutures
				,intPurchaseDetailId
				,intContractHeaderId
				,intContractCostId
				,intContractSeqId
				,intContractDetailId
				,intScaleTicketId
				,intInventoryReceiptItemId
				,intInventoryReceiptChargeId
				,intInventoryShipmentItemId
				,intInventoryShipmentChargeId
				,intLoadShipmentId
				,intLoadShipmentDetailId
				,intLoadShipmentCostId
				,intPaycheckHeaderId
				,intCustomerStorageId
				,intSettleStorageId
				,intCCSiteDetailId
				,intInvoiceId
				,intBuybackChargeId
				,intTicketId
				,dblOrderQty
				,dblOrderUnitQty
				,intOrderUOMId
				,dblQuantityToBill
				,dblQtyToBillUnitQty
				,intQtyToBillUOMId
				,dblCost
				,dblOldCost
				,dblCostUnitQty
				,intCostUOMId
				,intCostCurrencyId
				,dblWeight
				,dblNetWeight
				,dblWeightUnitQty
				,intWeightUOMId
				,intCurrencyExchangeRateTypeId
				,dblExchangeRate
				,intPurchaseTaxGroupId
				,dblTax
				,dblDiscount
				,dblDetailDiscountPercent
				,ysnDiscountOverride
				,intDeferredVoucherId
				,dtmDeferredInterestDate
				,dtmInterestAccruedThru
				,dblPrepayPercentage
				,intPrepayTypeId
				,dblNetShippedWeight
				,dblWeightLoss
				,dblFranchiseWeight
				,dblFranchiseAmount
				,dblActual
				,dblDifference
				,int1099Form
				,int1099Category
				,dbl1099
				,ysnStage
	)
	SELECT
		intPartitionId = vp.intPartitionId
		,intBillId = vp.intBillId
		,intEntityVendorId = vp.intEntityVendorId
		,intTransactionType = vp.intTransactionType
		,intLocationId = vp.intLocationId
		,intShipToId = vp.intShipToId
		,intShipFromId = vp.intShipFromId
		,intShipFromEntityId = vp.intShipFromEntityId
		,intPayToAddressId = vp.intPayToAddressId
		,intCurrencyId = vp.intCurrencyId
		,dtmDate = vp.dtmDate
		,dtmVoucherDate = vp.dtmVoucherDate
		,dtmDueDate = vp.dtmDueDate
		,strVendorOrderNumber = vp.strVendorOrderNumber
		,strReference = vp.strReference
		,strSourceNumber = vp.strSourceNumber
		,intSubCurrencyCents = vp.intSubCurrencyCents
		,intShipViaId = vp.intShipViaId
		,intTermId = vp.intTermId
		,strBillOfLading = vp.strBillOfLading
		,strCheckComment = vp.strCheckComment
		,intAPAccount = vp.intAPAccount
		,strMiscDescription = vp.strMiscDescription
		,intItemId = vp.intItemId
		,ysnSubCurrency = vp.ysnSubCurrency
		,intAccountId = vp.intAccountId
		,ysnReturn = vp.ysnReturn
		,intLineNo = vp.intLineNo
		,intItemLocationId = vp.intItemLocationId
		,intStorageLocationId = vp.intStorageLocationId
		,intSubLocationId = vp.intSubLocationId
		,dblBasis = vp.dblBasis
		,dblFutures = vp.dblFutures
		,intPurchaseDetailId = vp.intPurchaseDetailId
		,intContractHeaderId = vp.intContractHeaderId
		,intContractCostId = vp.intContractCostId
		,intContractSeqId = vp.intContractSeqId
		,intContractDetailId = vp.intContractDetailId
		,intScaleTicketId = vp.intScaleTicketId
		,intInventoryReceiptItemId = vp.intInventoryReceiptItemId
		,intInventoryReceiptChargeId = vp.intInventoryReceiptChargeId
		,intInventoryShipmentItemId = vp.intInventoryShipmentItemId
		,intInventoryShipmentChargeId = vp.intInventoryShipmentChargeId
		,intLoadShipmentId = vp.intLoadShipmentId
		,intLoadShipmentDetailId = vp.intLoadShipmentDetailId
		,intLoadShipmentCostId = vp.intLoadShipmentCostId
		,intPaycheckHeaderId = vp.intPaycheckHeaderId
		,intCustomerStorageId = vp.intCustomerStorageId
		,intSettleStorageId = vp.intSettleStorageId
		,intCCSiteDetailId = vp.intCCSiteDetailId
		,intInvoiceId = vp.intInvoiceId
		,intBuybackChargeId = vp.intBuybackChargeId
		,intTicketId = vp.intTicketId
		,dblOrderQty = vp.dblOrderQty
		,dblOrderUnitQty = vp.dblOrderUnitQty
		,intOrderUOMId = vp.intOrderUOMId
		,dblQuantityToBill = vp.dblQuantityToBill
		,dblQtyToBillUnitQty = vp.dblQtyToBillUnitQty
		,intQtyToBillUOMId = vp.intQtyToBillUOMId
		,dblCost = vp.dblCost
		,dblOldCost = vp.dblOldCost
		,dblCostUnitQty = vp.dblCostUnitQty
		,intCostUOMId = vp.intCostUOMId
		,intCostCurrencyId = vp.intCostCurrencyId
		,dblWeight = vp.dblWeight
		,dblNetWeight = vp.dblNetWeight
		,dblWeightUnitQty = vp.dblWeightUnitQty
		,intWeightUOMId = vp.intWeightUOMId
		,intCurrencyExchangeRateTypeId = vp.intCurrencyExchangeRateTypeId
		,dblExchangeRate = vp.dblExchangeRate
		,intPurchaseTaxGroupId = vp.intPurchaseTaxGroupId
		,dblTax = vp.dblTax
		,dblDiscount = vp.dblDiscount
		,dblDetailDiscountPercent = vp.dblDetailDiscountPercent
		,ysnDiscountOverride = vp.ysnDiscountOverride
		,intDeferredVoucherId = vp.intDeferredVoucherId
		,dtmDeferredInterestDate = vp.dtmDeferredInterestDate
		,dtmInterestAccruedThru = vp.dtmInterestAccruedThru
		,dblPrepayPercentage = vp.dblPrepayPercentage
		,intPrepayTypeId = vp.intPrepayTypeId
		,dblNetShippedWeight = vp.dblNetShippedWeight
		,dblWeightLoss = vp.dblWeightLoss
		,dblFranchiseWeight = vp.dblFranchiseWeight
		,dblFranchiseAmount = vp.dblFranchiseAmount
		,dblActual = vp.dblActual
		,dblDifference = vp.dblDifference
		,int1099Form = vp.int1099Form
		,int1099Category = vp.int1099Category
		,dbl1099 = vp.dbl1099
		,ysnStage = vp.ysnStage
	FROM
		@voucherPayables vp
	WHERE
		--ISNULL(vp.intInventoryReceiptChargeId,0) = 0 
		ISNULL(vp.intContractDetailId,0) = 0

	if exists (select top 1 1 from @voucherPayablesFinal)
	begin
		/*Construct Tax*/  
		delete from @voucherPayableTaxFinal;
		INSERT INTO @voucherPayableTaxFinal(  
			[intVoucherPayableId]  
			,[intTaxGroupId]      
			,[intTaxCodeId]      
			,[intTaxClassId]      
			,[strTaxableByOtherTaxes]   
			,[strCalculationMethod]    
			,[dblRate]       
			,[intAccountId]      
			,[dblTax]       
			,[dblAdjustedTax]     
			,[ysnTaxAdjusted]     
			,[ysnSeparateOnBill]     
			,[ysnCheckOffTax]    
			,[ysnTaxExempt]   
			,[ysnTaxOnly]  
		)  
		SELECT
			[intVoucherPayableId]  
			,[intTaxGroupId]      
			,[intTaxCodeId]      
			,[intTaxClassId]      
			,[strTaxableByOtherTaxes]   
			,[strCalculationMethod]    
			,[dblRate]       
			,[intAccountId]      
			,[dblTax]       
			,[dblAdjustedTax]     
			,[ysnTaxAdjusted]     
			,[ysnSeparateOnBill]     
			,[ysnCheckOffTax]    
			,[ysnTaxExempt]   
			,[ysnTaxOnly]   
		FROM dbo.fnICGeneratePayablesTaxes(  
			@voucherPayablesFinal  
			,@intInventoryReceiptId  
			,DEFAULT   
		) 

		/*Create new Voucher*/ 
		IF OBJECT_ID(N'tempdb..#returnData') IS NOT NULL
		BEGIN
			drop table #returnData
		END

		create table #returnData(
			intBillId int, 
			intBillDetailId int, 
			intPriceFixationDetailId int,
			intInventoryReceiptItemId int,
			dblQtyReceived decimal (38,15)
		)

		exec uspAPCreateVoucher  
			@voucherPayables = @voucherPayablesFinal  
			,@voucherPayableTax = @voucherPayableTaxFinal  
			,@userId = @userId  
			,@throwError = @throwError
			,@error = @error  
			,@createdVouchersId  = @createdVouchersId out

		insert into @CreatedVoucher
		(
			intBillId
		   ,intBillDetailId
		   ,intPriceFixationDetailId
		   ,intInventoryReceiptItemId
		   ,dblQtyReceived
		)
		select
			intBillId
		   ,intBillDetailId
		   ,intPriceFixationDetailId
		   ,intInventoryReceiptItemId
		   ,dblQtyReceived
		from
			#returnData

		--Code here to process the return table from uspAPCreateVoucher
		if exists (select top 1 1 from @CreatedVoucher)
		begin
			declare
				@intCreatedBillId int
				,@intCreatedBillDetailId int = 0
				,@intCreatedPriceFixationDetailId int
				,@intCreatedInventoryReceiptId int
				,@intCreatedInventoryReceiptItemId int
				,@dblCreatedQtyReceived numeric(18,6);

			select @intCreatedBillDetailId = min(intBillDetailId) from @CreatedVoucher where intBillDetailId >  @intCreatedBillDetailId
			while (@intCreatedBillDetailId is not null and @intCreatedBillDetailId > 0)
			begin
				select
					@intCreatedBillId = intBillId
					,@intCreatedBillDetailId = intBillDetailId
					,@intCreatedPriceFixationDetailId = intPriceFixationDetailId
					,@intCreatedInventoryReceiptItemId = intInventoryReceiptItemId
					,@dblCreatedQtyReceived = dblQtyReceived
				from
					@CreatedVoucher
				where
					intBillDetailId = @intCreatedBillDetailId

				select @intCreatedInventoryReceiptId = intInventoryReceiptId from tblICInventoryReceiptItem where intInventoryReceiptItemId = @intCreatedInventoryReceiptItemId;

				-- DO NOT USE uspICAddProRatedReceiptChargesToVoucher. Instead, use uspICGetProRatedReceiptCharges and uspICGetProRatedReceiptChargeTaxes
				----1. Process Pro Rated Charges
				--EXEC uspICAddProRatedReceiptChargesToVoucher
				--	@intInventoryReceiptItemId = @intCreatedInventoryReceiptItemId
				--	,@intBillId = @intCreatedBillId
				--	,@intBillDetailId = @intCreatedBillDetailId
					

				--2. Insert into Contract Helper table tblCTPriceFixationDetailAPAR
				if (isnull(@intCreatedPriceFixationDetailId,0) > 0)
				begin
					INSERT INTO tblCTPriceFixationDetailAPAR(
						intPriceFixationDetailId
						,intBillId
						,intBillDetailId
						,intSourceId
						,dblQuantity
						,dtmCreatedDate
						,intConcurrencyId  
					)  
					SELECT   
						intPriceFixationDetailId = @intCreatedPriceFixationDetailId  
						,intBillId = @intCreatedBillId  
						,intBillDetailId = @intCreatedBillDetailId 
						,intSourceId = @intCreatedInventoryReceiptItemId
						,dblQuantity = @dblCreatedQtyReceived
						,dtmCreatedDate = getdate()
						,intConcurrencyId = 1 
				end

			    declare @processedPayment table (
			    	intBillId int
			    );

				--4. Apply PrePay

				declare @prePayId Id;
				delete from @prePayId

				insert into
					@prePayId([intId])
				select distinct
					BD.intBillId
				from
					tblAPBillDetail BD
					join tblAPBill BL ON BL.intBillId = BD.intBillId
				where
					BD.intContractDetailId = @intContractDetailId
					and BL.intTransactionType in(2, 13)
					and BL.ysnPosted = 1
					and BL.ysnPaid = 0

     			if (exists(select top 1 1 from @prePayId) and not exists (select top 1 1 from @processedPayment where intBillId = @intCreatedBillId))
				begin
      				insert into @processedPayment select intBillId = @intCreatedBillId;
					EXEC uspAPApplyPrepaid @intCreatedBillId, @prePayId
				end

				/**
				-- NOTE: See CT-5484. 
				-- Commented this code out because there is no need to call uspICUpdateBillQty
				-- when it is already called inside uspAPCreateVoucher and uspICAddProRatedReceiptChargesToVoucher

				--DELETE FROM @receiptDetails
				--INSERT INTO @receiptDetails
				--(
				--	[intInventoryReceiptItemId],
				--	[intInventoryReceiptChargeId],
				--	[intInventoryShipmentChargeId],
				--	[intSourceTransactionNoId],
				--	[strSourceTransactionNo],
				--	[intItemId],
				--	[intToBillUOMId],
				--	[dblToBillQty]
				--)
				--SELECT
				--	[intInventoryReceiptItemId],
				--	[intInventoryReceiptChargeId],
				--	[intInventoryShipmentChargeId],
				--	[intSourceTransactionNoId],
				--	[strSourceTransactionNo],
				--	[intItemId],
				--	[intToBillUOMId],
				--	[dblToBillQty]
				--FROM
				--	dbo.fnCTGenerateReceiptDetail(@intCreatedInventoryReceiptItemId, @intCreatedBillId, @intCreatedBillDetailId, @dblCreatedQtyReceived, 0)

				--EXEC uspICUpdateBillQty @updateDetails = @receiptDetails
				**/
				
				select @intCreatedBillDetailId = min(intBillDetailId) from @CreatedVoucher where intBillDetailId >  @intCreatedBillDetailId
			end

			--3. Post all created Vuchers
			set @intCreatedBillId = 0;
			select @intCreatedBillId = min(intBillId) from @CreatedVoucher where intBillId >  @intCreatedBillId;
			while (@intCreatedBillId is not null and @intCreatedBillId > 0)
			begin
				EXEC [dbo].[uspAPPostBill] @post = 1,@recap = 0,@isBatch = 0,@param = @intCreatedBillId,@userId = @userId,@success = @ysnSuccessBillPosting OUTPUT
				select @intCreatedBillId = min(intBillId) from @CreatedVoucher where intBillId >  @intCreatedBillId;
			end

		end

	end

	_return:
	
end try
begin catch
	set @error = ERROR_MESSAGE()  
	raiserror (@error,18,1,'WITH NOWAIT')  
end catch
