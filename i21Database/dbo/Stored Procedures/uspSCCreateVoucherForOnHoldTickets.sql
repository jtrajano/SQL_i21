CREATE PROCEDURE [dbo].[uspSCCreateVoucherForOnHoldTickets]
@intTicketId INT 
AS
BEGIN
	/*
		The story of create voucher on Hold Tickets
		Once upon a time, http://jira.irelyserver.com/browse/SC-4822
		The process flow for on hold tickets

		- tickets with "On Hold" ticket completion is almost the same as spot auto distribution
		- the difference is that the on-hold ticket will not create a voucher
		- the ticket apply screen will be the one responsible for creating the voucher for the ticket completed as On Hold
		- the process below is copied from IC "uspICConvertReceiptToVoucher"
		- it is using IC's function to generate payables and get the information needed to create a voucher
		- the generated inventory item sets the allow voucher to true and the allow payable to false
			- that way, we can reuse IC's function 
		- after that, we link the ticket spot used and contract used table to distribute the unit in the voucher
		- there is a contract scheduling and balance update in this procedure as well
			- it will immediately add and deduct the schedule before updating the balance 
		- this procedure also uses the Contract's procedure to create a voucher based on the voucher item generated from the IC's function

	*/
	DECLARE @voucherItems AS VoucherPayable
	DECLARE @voucherItemsTax AS VoucherDetailTax

	DECLARE @throwedError AS NVARCHAR(1000);
	DECLARE @strBillIds NVARCHAR(MAX);
	DECLARE @INVENTORY_RECEIPT_ID INT 
	DECLARE @TICKET_ID INT = @intTicketId
	DECLARE @intTicketItemUOMId INT

	-- # Get information from the scale ticket table
	SELECT	
		@intTicketItemUOMId = SC.intItemUOMIdTo	
		,@INVENTORY_RECEIPT_ID  = SC.intInventoryReceiptId
	FROM dbo.tblSCTicket SC 
		WHERE SC.intTicketId = @TICKET_ID 


	-- # Generate voucher item using IC's fnICGeneratePayables
	-- # this is where we link the spot used and contract used information
	INSERT INTO @voucherItems(
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
				,[strLoadShipmentNumber]		
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
				,[dtmVoucherDate]
				,[intStorageLocationId]
				,[intSubLocationId]
				,[intBookId]
				,[intSubBookId]
				,[intLotId]
				/*Payment Info*/
				, [intPayFromBankAccountId]
				, [strFinancingSourcedFrom]
				, [strFinancingTransactionNumber]
				/*Trade Finance Info*/
				, [strFinanceTradeNo]
				, [intBankId]
				, [intBankAccountId]
				, [intBorrowingFacilityId]
				, [strBankReferenceNo]
				, [intBorrowingFacilityLimitId]
				, [intBorrowingFacilityLimitDetailId]
				, [strReferenceNo]
				, [intBankValuationRuleId]
				, [strComments]
				, [strTaxPoint]
				, [intTaxLocationId]
				, [ysnOverrideTaxGroup]
				/*Quality and Optionality Premium*/
				,[dblQualityPremium] 
 				,[dblOptionalityPremium] 
		)

	SELECT 

		GP.[intEntityVendorId]
			,GP.[intTransactionType]
			,GP.[intLocationId]	
			,[intShipToId] = GP.intLocationId	
			,[intShipFromId] = GP.intShipFromId	 		
			,[intShipFromEntityId] = GP.intShipFromEntityId
			,[intPayToAddressId] = GP.intPayToAddressId
			,GP.[intCurrencyId]					
			,GP.[dtmDate]				
			,GP.[strVendorOrderNumber]		
			,GP.[strReference]						
			,GP.[strSourceNumber]					
			,GP.[intPurchaseDetailId]			
			--MON'S SPACE
			,TICKET_APPLY_INFO.[intContractHeaderId]				
			,TICKET_APPLY_INFO.[intContractDetailId]				
			--MON'S SPACE
			,[intContractSeqId] = NULL					
			,GP.[intScaleTicketId]					
			,GP.[intInventoryReceiptItemId]		
			,GP.[intInventoryReceiptChargeId]		
			,GP.[intInventoryShipmentItemId]		
			,GP.[intInventoryShipmentChargeId]		
			,GP.strLoadShipmentNumber			
			,GP.[intLoadShipmentId]				
			,GP.[intLoadShipmentDetailId]	
			,GP.[intLoadShipmentCostId]				
			,GP.[intItemId]						
			,GP.[intPurchaseTaxGroupId]			
			,GP.[strMiscDescription]				
			, GP.dblOrderQty --CASE WHEN @billTypeToUse = @type_DebitMemo THEN -GP.[dblOrderQty]	ELSE GP.dblOrderQty END
			,[dblOrderUnitQty] = 0.00					
			,[intOrderUOMId] = NULL	 
			-- MON'S SPACE
			--, GP.[dblQuantityToBill] --CASE WHEN @billTypeToUse = @type_DebitMemo THEN -GP.[dblQuantityToBill]	ELSE GP.[dblQuantityToBill] END	
			, TICKET_APPLY_INFO.dblQty
			--
			,GP.[dblQtyToBillUnitQty]				
			,GP.[intQtyToBillUOMId]				
			-- MON'S SPACE
			,[dblCost] = TICKET_APPLY_INFO.dblUnitCost
			--
			,ISNULL(GP.[dblCostUnitQty], 1) 
			,GP.[intCostUOMId]	
			--MON'S SPACE
			--,GP.[dblNetWeight]
			,dbo.fnCalculateQtyBetweenUOM(GP.intQtyToBillUOMId, GP.intWeightUOMId, TICKET_APPLY_INFO.dblQty)
			,ISNULL([dblWeightUnitQty], 1) 
			,GP.[intWeightUOMId]					
			,GP.[intCostCurrencyId]
			,GP.[dblTax]							
			,GP.[dblDiscount]
			,GP.[intCurrencyExchangeRateTypeId]	
			,[dblExchangeRate] = GP.dblRate					
			,GP.[ysnSubCurrency]					
			,GP.[intSubCurrencyCents]				
			,GP.[intAccountId]						
			,GP.[intShipViaId]						
			,GP.[intTermId]			
			,GP.[intFreightTermId]								
			,GP.[strBillOfLading]					
			,GP.[ysnReturn]	
			,GP.dtmDate
			,GP.intStorageLocationId
			,GP.intSubLocationId
			,GP.intBookId
			,GP.intSubBookId
			,GP.intLotId
			/*Payment Info*/
			, [intPayFromBankAccountId]
			, [strFinancingSourcedFrom]
			, [strFinancingTransactionNumber]
			/*Trade Finance Info*/
			, [strFinanceTradeNo]
			, [intBankId]
			, [intBankAccountId]
			, [intBorrowingFacilityId]
			, [strBankReferenceNo]
			, [intBorrowingFacilityLimitId]
			, [intBorrowingFacilityLimitDetailId]
			, [strReferenceNo]
			, [intBankValuationRuleId]
			, [strComments]
			, [strTaxPoint]
			, [intTaxLocationId]
			, [ysnOverrideTaxGroup]
			/*Quality and Optionality Premium*/
			,GP.[dblQualityPremium] 
 			,GP.[dblOptionalityPremium] 
	
		FROM dbo.fnICGeneratePayables(@INVENTORY_RECEIPT_ID, 1, 1, 'Purchase Contract') GP
		CROSS APPLY(
			
			SELECT 
				dblQty,
				(ISNULL(dblUnitBasis, 0) + ISNULL(dblUnitFuture, 0)) dblUnitCost,
				NULL AS intContractDetailId,
				NULL AS intContractHeaderId
			FROM tblSCTicketSpotUsed 
				WHERE intTicketId = @TICKET_ID
			
			UNION ALL
			
			SELECT TICKET_CONTRACT.dblScheduleQty AS dblQty, 
					CONTRACT_DETAIL.dblCashPrice AS dblUnitCost, 
					CONTRACT_DETAIL.intContractDetailId, 
					CONTRACT_DETAIL.intContractHeaderId
			FROM tblSCTicketContractUsed TICKET_CONTRACT
			JOIN tblCTContractDetail CONTRACT_DETAIL
				ON TICKET_CONTRACT.intContractDetailId = CONTRACT_DETAIL.intContractDetailId
			WHERE intTicketId = @TICKET_ID

		

		) TICKET_APPLY_INFO

	-- # Get item tax and uses fnICGeneratePayablesTaxes
	INSERT INTO @voucherItemsTax(
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
	SELECT [intVoucherPayableId]
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
		@voucherItems
		,@INVENTORY_RECEIPT_ID
		,DEFAULT 
	)
	

	-- # Voucher creation process
	BEGIN 		
		-- # Contract temp table to get all the contract associated in the ticket apply
		DECLARE @CONTRACT_TABLE TABLE (
			id INT IDENTITY(1,1)
			,intContractDetailId INT
			,dblScheduleQuantity DECIMAL(18, 6) NULL		
		)

		--# Variables that will be used in the loop
		DECLARE @LOOP_ID INT
		DECLARE @LOOP_CONTRACT_DETAIL_ID INT
		DECLARE @LOOP_SCHEDULE_QUANTITY DECIMAL(18,6)
		DECLARE @ysnLoadContract BIT

		-- # Get the Contracts
		INSERT INTO @CONTRACT_TABLE
		(intContractDetailId, dblScheduleQuantity)
		SELECT 
			intContractDetailId
			,dblScheduleQty
		FROM tblSCTicketContractUsed 
			WHERE intTicketId = @TICKET_ID
	
		-- # Start looping through the contracts
		SELECT @LOOP_ID = MIN(id) 
			FROM @CONTRACT_TABLE

		
		WHILE(@LOOP_ID IS NOT NULL)
		BEGIN
			-- # Loop data
			SELECT
				@LOOP_CONTRACT_DETAIL_ID = intContractDetailId,
				@LOOP_SCHEDULE_QUANTITY = dblScheduleQuantity
			FROM @CONTRACT_TABLE
			WHERE id = @LOOP_ID

			-- # Contract Scheduling and Balance update
			BEGIN 
				BEGIN	
					-- # this will check if the contract can be used 
					exec uspSCCheckContractStatus  @intContractDetailId = @LOOP_CONTRACT_DETAIL_ID

							
					SET @ysnLoadContract = 0
					SELECT TOP 1 @ysnLoadContract = ISNULL(ysnLoad,0)
					FROM tblCTContractHeader A
					INNER JOIN tblCTContractDetail B
						ON A.intContractHeaderId = B.intContractHeaderId
					WHERE B.intContractDetailId = @LOOP_CONTRACT_DETAIL_ID

					-- # Add contract schedule
					SET @LOOP_SCHEDULE_QUANTITY = ABS(@LOOP_SCHEDULE_QUANTITY)				
					EXEC uspCTUpdateScheduleQuantityUsingUOM @LOOP_CONTRACT_DETAIL_ID, @LOOP_SCHEDULE_QUANTITY, 1, @TICKET_ID, 'Auto - Scale', @intTicketItemUOMId  
					-- # Remove contract schedule
					SET @LOOP_SCHEDULE_QUANTITY = ABS(@LOOP_SCHEDULE_QUANTITY) * -1
					EXEC uspCTUpdateScheduleQuantityUsingUOM @LOOP_CONTRACT_DETAIL_ID, @LOOP_SCHEDULE_QUANTITY, 1, @TICKET_ID, 'Auto - Scale', @intTicketItemUOMId  

					-- # Update contract balance 
					SET @LOOP_SCHEDULE_QUANTITY = ABS(@LOOP_SCHEDULE_QUANTITY)
					EXEC uspCTUpdateSequenceBalance 
								 @intContractDetailId = @LOOP_CONTRACT_DETAIL_ID
								,@dblQuantityToUpdate = @LOOP_SCHEDULE_QUANTITY
								,@intUserId = 1
								,@intExternalId = @TICKET_ID
								,@strScreenName = 'Auto - Scale'
								
				END  						

			
			END	

			SELECT @LOOP_ID = MIN(id) 
			FROM @CONTRACT_TABLE
				WHERE id > @LOOP_ID
			
		END;

		-- # Clean up
		DELETE FROM @CONTRACT_TABLE
		SELECT 
			@LOOP_ID = NULL
			,@LOOP_SCHEDULE_QUANTITY = NULL			
			,@LOOP_CONTRACT_DETAIL_ID = NULL

		-- # create the voucher
		EXEC uspCTCreateVoucher
			@voucherPayables = @voucherItems
			,@voucherPayableTax = @voucherItemsTax
			,@userId = 1
			,@throwError = 0
			,@error = @throwedError OUTPUT
			,@createdVouchersId = @strBillIds OUTPUT
	

		
	END


END
