CREATE PROCEDURE [dbo].[uspICPostUnpostInsuranceCharge]
	@intInsuranceChargeId INT
	,@intUserId INT
	,@ysnPost BIT
	,@intBillId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF



DECLARE @voucherPayable as VoucherPayable
DECLARE @voucherTaxDetail as VoucherDetailTax
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @billList Id
DECLARE @ysnBillPosted BIT
DECLARE @_intBillId INT
DECLARE @strBillNumber NVARCHAR(100)
DECLARE @logDescriotion NVARCHAR(MAX)


BEGIN TRY
	IF ISNULL(@intInsuranceChargeId,0) = 0
	BEGIN
		GOTO COMPLETEPROCESS
	END

	IF (@ysnPost = 1)
	BEGIN
		---------Create Voucher
		BEGIN
			INSERT INTO @voucherPayable(
					[intTransactionType]			,
					[intAccountId]					,
					[intItemId]						,
					[strMiscDescription]			,
					[intQtyToBillUOMId]				,
					[dblQuantityToBill]				,
					[dblQtyToBillUnitQty]			,
					[dblOrderQty]					,
					[dblDiscount]					,
					[intCostUOMId]					,
					[dblCost]						,
					[dblCostUnitQty]				,
					[int1099Form]					,
					[int1099Category]				,
					[intLineNo]						,
					[intContractDetailId]			,
					[intContractHeaderId]			,
					[intLoadShipmentDetailId]		,
					[intLoadShipmentId]				,
					[intScaleTicketId]				,
					[intPurchaseTaxGroupId]			,
					[intEntityVendorId]				,
					strVendorOrderNumber			,
					strReference					,
					strSourceNumber					,
					intLocationId					,
					intSubLocationId				,
					intStorageLocationId			,
					intItemLocationId				,
					ysnSubCurrency					,
					intCurrencyId
					,ysnStage
					,intInsuranceChargeDetailId
					)
			SELECT
					[intTransactionType]			=	1,
					[intAccountId]					=	dbo.[fnGetItemGLAccount](B.intChargeItemId, D.intItemLocationId, 'Other Charge Expense'),
					[intItemId]						=	B.intChargeItemId,					
					[strMiscDescription]			=	D.strDescription,
					[intQtyToBillUOMId]				=	B.intRateUOMId
					,[dblQuantityToBill]			=	B.dblQuantity
					,[dblQtyToBillUnitQty]			=	B.intQuantityUOMId
					,[dblOrderQty]					=	B.dblQuantity
					,[dblDiscount]					=	0
					,[intCostUOMId]					=	B.intRateUOMId
					,[dblCost]						=	B.dblRate
					,[dblCostUnitQty]				=	F.dblUnitQty
					,[int1099Form]					=	(CASE WHEN G.intEntityId IS NOT NULL 
																	AND D.intItemId > 0
																	AND J.ysn1099Box3 = 1
																	AND G.ysnStockStatusQualified = 1 
																	THEN 4
																WHEN H.str1099Form = '1099-MISC' THEN 1
																WHEN H.str1099Form = '1099-INT' THEN 2
																WHEN H.str1099Form = '1099-B' THEN 3
															ELSE 0 END)
					,[int1099Category]				=	CASE 	WHEN G.intEntityId IS NOT NULL 
																	AND D.intItemId > 0
																	AND E.ysn1099Box3 = 1
																	AND G.ysnStockStatusQualified = 1 
																	THEN 3
														ELSE ISNULL(I.int1099CategoryId, 0) END
					,[intLineNo]					=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))
					,[intContractDetailId]			=	NULL
					,[intContractHeaderId]			=	NULL
					,[intLoadDetailId]				=	NULL
					,[intLoadId]					=	NULL
					,[intScaleTicketId]				=	NULL
					,[intPurchaseTaxGroupId]		=	NULL
					,[intEntityVendorId]			=	A.intInsurerId
					,[strVendorOrderNumber]			=	'Insurance Charge-' + A.strChargeNo
					,strReference					=	'Insurance Charge-' + A.strChargeNo
					,strSourceNumber				=	A.strChargeNo
					,intLocationId					=	C.intCompanyLocationId
					,intSubLocationId				=	C.intCompanyLocationSubLocationId
					,intStorageLocationId			=   NULL
					,intItemLocationId				=	D.intItemLocationId
					,ysnSubCurrency					=	0
					,intCurrencyId					=	B.intCurrencyId
					,ysnStage 						=	0
					,intInsuranceChargeDetailId		=	B.intInsuranceChargeDetailId
			FROM tblICInsuranceCharge A
			INNER JOIN tblICInsuranceChargeDetail B
				ON A.intInsuranceChargeId = B.intInsuranceChargeId
			INNER JOIN tblSMCompanyLocationSubLocation C
				ON A.intStorageLocationId = C.intCompanyLocationSubLocationId
			INNER JOIN tblICItemLocation D
				ON C.intCompanyLocationId = D.intLocationId
					AND D.intItemId = B.intChargeItemId
			INNER JOIN tblICItem E
				ON E.intItemId = B.intChargeItemId
			LEFT JOIN tblICItemUOM F
				ON F.intItemUOMId = B.intRateUOMId
			LEFT JOIN vyuPATEntityPatron G
				ON B.intInsurerId = G.intEntityId
			LEFT JOIN tblEMEntity H
				ON H.intEntityId = B.intInsurerId
			LEFT JOIN tblAP1099Category I
				ON I.strCategory = H.str1099Type
			LEFT JOIN vyuICGetItemStock J 
				ON J.intItemId = B.intChargeItemId
					AND J.intLocationId = C.intCompanyLocationId
			WHERE B.dblAmount <> 0
				AND A.intInsuranceChargeId = @intInsuranceChargeId

			IF EXISTS(SELECT TOP 1 NULL FROM @voucherPayable)
			BEGIN
				INSERT INTO @voucherTaxDetail(
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
				SELECT	[intVoucherPayableId]
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
						@voucherPayable
						,1
						,DEFAULT 
					)


				EXEC [dbo].[uspAPCreateVoucher] 
					@voucherPayables = @voucherPayable
					,@voucherPayableTax = @voucherTaxDetail
					,@userId = @intUserId
					,@throwError = 1
					,@error = @ErrorMessage OUT
					,@createdVouchersId = @intBillId OUT

				
			END
		END

		---Update Insurance Charge
		IF(ISNULL(@intBillId,0) > 0)
		BEGIN

			SELECT TOP 1 
				@strBillNumber = strBillId
			FROM tblAPBill
			WHERE intBillId = @intBillId

			UPDATE tblICInsuranceCharge 
			SET ysnPosted = 1
			WHERE intInsuranceChargeId = @intInsuranceChargeId


			SET @logDescriotion = 'Posted with Voucher ''' + @strBillNumber + ''''
			

			---Audit Log
			EXEC dbo.uspSMAuditLog 
				@keyValue			= @intInsuranceChargeId					-- Primary Key Value of the Ticket. 
				,@screenName		= 'Inventory.view.InsuranceCharge'		-- Screen Namespace
				,@entityId			= @intUserId				-- Entity Id.
				,@actionType		= 'Posted'					-- Action Type
				,@changeDescription	= @logDescriotion	-- Description
				,@fromValue			= ''						-- Old Value
				,@toValue			= ''			-- New Value
				,@details			= '';
		END

	END
	ELSE
	BEGIN
		--Get the vouchers and Delete
		INSERT INTO @billList
		SELECT DISTINCT
			A.intBillId
		FROM tblAPBillDetail A
		WHERE A.intInsuranceChargeDetailId IN (SELECT  
													intInsuranceChargeDetailId 
												FROM tblICInsuranceChargeDetail
												WHERE intInsuranceChargeId = @intInsuranceChargeId
												) 
		ORDER BY A.intBillId ASC


		SELECT TOP 1 
			@_intBillId = intId
		FROM @billList
		ORDER BY intId

		WHILE(ISNULL(@_intBillId,0) > 0)
		BEGIN
			SELECT TOP 1 
				@ysnBillPosted = ysnPosted
				,@strBillNumber = strBillId
			FROM tblAPBill
			WHERE intBillId = @_intBillId

			IF(@ysnBillPosted = 1)
			BEGIN
				SET @ErrorMessage = 'Voucher ' + @strBillNumber + 'is already posted. Please unpost the voucher first.'
				
				RAISERROR(@ErrorMessage,11,1)
			END
			ELSE
			BEGIN
				EXEC [dbo].[uspAPDeleteVoucher] @_intBillId, @intUserId
			END

			SET @_intBillId = (SELECT TOP 1 
									intId
								FROM @billList
								WHERE intId > @_intBillId 
								ORDER BY intId)

		END





		---Update Insurance Charge
		UPDATE tblICInsuranceCharge 
			SET ysnPosted = 0
		WHERE intInsuranceChargeId = @intInsuranceChargeId

		---Audit Log
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intInsuranceChargeId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.InsuranceCharge'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Unposted'					-- Action Type
			,@changeDescription	= 'Unposted Insurance Charge.'	-- Description
			,@fromValue			= ''						-- Old Value
			,@toValue			= ''			-- New Value
			,@details			= '';
		
	END
	COMPLETEPROCESS:
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH