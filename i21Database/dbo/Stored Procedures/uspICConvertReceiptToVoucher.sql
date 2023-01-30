﻿CREATE PROCEDURE [dbo].[uspICConvertReceiptToVoucher]
	@intReceiptId INT,
	@intEntityUserSecurityId INT,
	@strType NVARCHAR(50) = NULL,
	@intBillId INT OUTPUT,
	@strBillIds NVARCHAR(MAX) = NULL OUTPUT,
	@intScreenId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intEntityVendorId AS INT				
		,@type_Voucher AS INT = 1
		,@type_DebitMemo AS INT = 3
		,@billTypeToUse AS INT 
		,@intSourceType AS INT 
		,@strReceiptNumber AS NVARCHAR(50)
		,@dtmReceiptDate AS DATETIME

		,@voucherItems AS VoucherPayable
		,@voucherItemsTax AS VoucherDetailTax
		--,@voucherItems AS VoucherDetailReceipt 
		,@voucherOtherCharges AS VoucherDetailReceiptCharge 
		,@voucherDetailClaim AS VoucherDetailClaim

		,@intShipFrom AS INT
		,@intShipTo AS INT 
		,@strVendorRefNo NVARCHAR(50)
		,@intCurrencyId AS INT 
		,@intShipFromEntity AS INT

		,@intShipFrom_DebitMemo AS INT
		,@intReturnValue AS INT = 0


DECLARE @ReceiptType INT = 4;

DECLARE @SourceType_NONE AS INT = 0
		,@SourceType_SCALE AS INT = 1
		,@SourceType_INBOUND_SHIPMENT AS INT = 2
		,@SourceType_TRANSPORT AS INT = 3
		,@SourceType_SETTLE_STORAGE AS INT = 4
		,@SourceType_DELIVERY_SHEET AS INT = 5
		,@SourceType_PURCHASE_ORDER AS INT = 6
		,@SourceType_STORE AS INT = 7

DECLARE @ItemType_OtherCharge AS NVARCHAR(50) = 'Other Charge';

DECLARE @Own AS INT = 1
		,@Storage AS INT = 2
		,@ConsignedPurchase AS INT = 3

DECLARE @intScreenId_InventoryReceipt AS INT = 1

SELECT	@intEntityVendorId = intEntityVendorId
		,@billTypeToUse = 
				CASE 
					WHEN dbo.fnICGetReceiptTotals(r.intInventoryReceiptId, 6) < 0 AND r.intSourceType = @SourceType_STORE THEN 
						@type_DebitMemo
					ELSE 
						@type_Voucher
				END 

		,@intShipFrom = r.intShipFromId
		,@intShipTo = r.intLocationId
		,@strVendorRefNo = ISNULL(NULLIF(LTRIM(RTRIM(r.strBillOfLading)), ''), r.strVendorRefNo)
		,@intCurrencyId = r.intCurrencyId
		,@intSourceType = r.intSourceType
		,@strReceiptNumber = r.strReceiptNumber
		,@dtmReceiptDate = r.dtmReceiptDate
		,@intShipFromEntity = r.intShipFromEntityId
FROM	tblICInventoryReceipt r
WHERE	r.ysnPosted = 1
		AND r.intInventoryReceiptId = @intReceiptId

BEGIN 
	-- Assemble the voucher items 
	BEGIN 		
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
		,GP.[intContractHeaderId]				
		,GP.[intContractDetailId]				
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
		, GP.[dblQuantityToBill] --CASE WHEN @billTypeToUse = @type_DebitMemo THEN -GP.[dblQuantityToBill]	ELSE GP.[dblQuantityToBill] END	
		,GP.[dblQtyToBillUnitQty]				
		,GP.[intQtyToBillUOMId]				
		,[dblCost] = GP.dblUnitCost							
		,ISNULL(GP.[dblCostUnitQty], 1) 
		,GP.[intCostUOMId]						
		,GP.[dblNetWeight]						
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
	FROM dbo.fnICGeneratePayables (@intReceiptId, 1, 1, @strType) GP

	END 

	-- Assemble Item Taxes
	BEGIN
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
				,@intReceiptId
				,DEFAULT 
			)
	END

	-- Call the AP sp to convert the IR to Voucher. 
	BEGIN 
		DECLARE @throwedError AS NVARCHAR(1000);

		IF @strType = 'provisional voucher'
		BEGIN 
			EXEC uspAPCreateProvisional
				@voucherPayables = @voucherItems
				,@voucherPayableTax = @voucherItemsTax
				,@userId = @intEntityUserSecurityId
				,@throwError = 0
				,@error = @throwedError OUTPUT
				,@createdVouchersId = @strBillIds OUTPUT
		END 
		ELSE 
		BEGIN 
			--EXEC [dbo].[uspAPCreateVoucher]
			EXEC uspCTCreateVoucher
				@voucherPayables = @voucherItems
				,@voucherPayableTax = @voucherItemsTax
				,@userId = @intEntityUserSecurityId
				,@throwError = 0
				,@error = @throwedError OUTPUT
				,@createdVouchersId = @strBillIds OUTPUT
		END 

		--THIS ASSUMES THAT THE VOUCHER CREATED IS ONLY ONE
		SET @intBillId = CAST(@strBillIds AS INT)

		-- Handle errors thrown by AP
		IF NULLIF(@throwedError, '') IS NOT NULL
		BEGIN
			RAISERROR(@throwedError, 11, 1)
			RETURN -11
			GOTO Post_Exit;
		END
		
		IF @intBillId IS NULL AND @intScreenId = @intScreenId_InventoryReceipt
		BEGIN
			-- Check if one of the items is a Contract Basis or DP. 
			IF EXISTS (
				SELECT TOP 1
					A.strReceiptNumber
				FROM tblICInventoryReceipt A INNER JOIN tblICInventoryReceiptItem B
						ON A.intInventoryReceiptId = B.intInventoryReceiptId
					OUTER APPLY (
						SELECT 
							CH.intContractHeaderId
							,CD.intContractDetailId			
							,CD.intContractSeq
							,CD.dblCashPrice
							,CD.intPricingTypeId
							,CD.dblFutures
							,CD.dblQuantity
							,CH.strContractNumber
							,CD.intItemUOMId
							,ctUOM.strUnitMeasure
							,J.dblFranchise
						FROM 
							tblCTContractHeader CH INNER JOIN tblCTContractDetail CD 
								ON CH.intContractHeaderId = CD.intContractHeaderId
							LEFT JOIN dbo.tblCTWeightGrade J 
								ON J.intWeightGradeId = CH.intWeightId
							LEFT JOIN tblICItemUOM ctOrderUOM 
								ON ctOrderUOM.intItemUOMId = CD.intItemUOMId
							LEFT JOIN tblICUnitMeasure ctUOM 
								ON ctUOM.intUnitMeasureId  = ctOrderUOM.intUnitMeasureId
						WHERE			
							A.strReceiptType = 'Purchase Contract'			
							AND CH.intContractHeaderId = ISNULL(B.intContractHeaderId, B.intOrderId)
							AND CD.intContractDetailId = ISNULL(B.intContractDetailId, B.intLineNo) 
					) Contracts	
				WHERE
					A.strReceiptNumber = @strReceiptNumber
					AND A.strReceiptType = 'Purchase Contract'
					AND ISNULL(Contracts.intPricingTypeId, 0) = 2 -- 2 is Basis. 
					AND ISNULL(Contracts.dblFutures, 0) = 0
			)				
			BEGIN
				-- 'Unable to process. Use Price Contract screen to process Basis Contract vouchers.''
				EXEC uspICRaiseError 80218, @strReceiptNumber;
				RETURN -80218; 	
			END

			-- Check if contract already has a payable in Inbound Shipment
			DECLARE @strSourceNumber AS NVARCHAR(50)  
			SELECT TOP 1
				@strSourceNumber = ap.strSourceNumber 
			FROM
				tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
					ON r.intInventoryReceiptId = ri.intInventoryReceiptId

				OUTER APPLY (
					SELECT	dblQtyReturned = rtnItems.dblOpenReceive - ISNULL(rtnItems.dblQtyReturned, 0) 
							,rtn.strReceiptType
							,rtn.strReceiptNumber
							,rtnItems.intOrderId 
							,rtnItems.intLineNo 
					FROM	tblICInventoryReceipt rtn INNER JOIN tblICInventoryReceiptItem rtnItems
								ON rtn.intInventoryReceiptId = rtnItems.intInventoryReceiptId				
					WHERE	rtn.strReceiptType = 'Inventory Return'		
							AND rtnItems.intInventoryReceiptId = r.intSourceInventoryReceiptId
							AND rtnItems.intInventoryReceiptItemId = ri.intSourceInventoryReceiptItemId				
				) rtn

				OUTER APPLY (
					SELECT	
							LogisticsView.strLoadNumber
							,LogisticsView.dblNetWt
					FROM	vyuICLoadContainersSearch LogisticsView 
					WHERE	
							(
								r.strReceiptType = 'Purchase Contract'
								OR (
									r.strReceiptType = 'Inventory Return'
									AND rtn.strReceiptType = 'Purchase Contract'
								)
							)		
							AND r.intSourceType = 2
							AND LogisticsView.intLoadDetailId = ri.intSourceId 
							AND LogisticsView.intLoadContainerId = ri.intContainerId				
				) LogisticsView

				OUTER APPLY (
					SELECT	TOP 1 
							LogisticsView.strLoadNumber
					FROM	vyuICLoadContainersSearch LogisticsView 
					WHERE	
						r.intSourceType = 2
						AND LogisticsView.intLoadDetailId = ri.intLoadShipmentDetailId
				) LogisticsView2

				LEFT JOIN tblAPVoucherPayable ap
					ON ap.intEntityVendorId = r.intEntityVendorId
					AND ap.intContractDetailId = ri.intContractDetailId
					--AND ap.strSourceNumber <> r.strReceiptNumber
					AND strSourceNumber IN (LogisticsView2.strLoadNumber, LogisticsView.strLoadNumber)
					AND ap.intInventoryReceiptItemId IS NULL
					AND ap.intInventoryReceiptChargeId IS NULL 
					AND ap.intInventoryShipmentItemId IS NULL 
			WHERE
				r.intInventoryReceiptId = @intReceiptId
				AND ap.strSourceNumber IS NOT NULL 

			IF @strSourceNumber IS NOT NULL 
			BEGIN 
				-- 'Cannot process [ir-#] because it already included in the Add Payables by [source #].'
				EXEC uspICRaiseError 80243, @strReceiptNumber, @strSourceNumber
				RETURN -80243;
			END 

			-- Check if IR details
			IF EXISTS(
				SELECT TOP 1 1
				FROM 
					vyuICGetInventoryReceiptVoucher
				WHERE 
					intInventoryReceiptId = @intReceiptId
					AND dblQtyToReceive = dblQtyVouchered
			)
			BEGIN
				IF @billTypeToUse = @type_Voucher
				BEGIN
					-- Voucher is no longer needed. All items have Voucher. 
					EXEC uspICRaiseError 80111; 
					RETURN -80111;
				END
				ELSE
				BEGIN
					-- Debit Memo is no longer needed. All items have Debit Memo. 
					EXEC uspICRaiseError 80110; 
					SET @intReturnValue = -80110;
				END
			END
			ELSE
			BEGIN
				IF @billTypeToUse = @type_Voucher
				BEGIN
					RAISERROR('There are no items to voucher.', 11, 1)
					RETURN -11
				END
				ELSE
				BEGIN
					RAISERROR('You cannot convert this to debit memo.', 11, 1)
					RETURN -11
				END
			END
			GOTO Post_Exit;
		END
	END 

	SELECT @strBillIds = 
		LTRIM(
			STUFF(
					' ' + (
						SELECT  CONVERT(NVARCHAR(50), @intBillId) + '|^|'
						FOR xml path('')
					)
				, 1
				, 1
				, ''
			)
		)
END 

Post_Exit:
RETURN @intReturnValue;