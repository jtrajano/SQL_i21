CREATE PROCEDURE [dbo].[uspICPostUnpostStorageCharge]
	@intStorageChargeId INT
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
DECLARE @strBillIds NVARCHAR(MAX)
DECLARE @strVoucherNumbers NVARCHAR(MAX)

BEGIN TRY
	IF ISNULL(@intStorageChargeId,0) = 0
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
					,intStorageChargeId
					,intLotId
					)
			SELECT
					[intTransactionType]			=	1,
					[intAccountId]					=	dbo.[fnGetItemGLAccount](B.intItemChargeId, C.intItemLocationId, 'Other Charge Expense'),
					[intItemId]						=	B.intItemChargeId,					
					[strMiscDescription]			=	B.strTransactionId,
					[intQtyToBillUOMId]				=	B.intItemChargeUOMId
					,[dblQuantityToBill]			=	1
					,[dblQtyToBillUnitQty]			=	E.dblUnitQty
					,[dblOrderQty]					=	1
					,[dblDiscount]					=	0
					,[intCostUOMId]					=	B.intItemChargeUOMId
					,[dblCost]						=	B.dblStorageCharge
					,[dblCostUnitQty]				=	E.dblUnitQty
					,[int1099Form]					=	(CASE WHEN G.intEntityId IS NOT NULL 
																	AND C.intItemId > 0
																	AND D.ysn1099Box3 = 1
																	AND G.ysnStockStatusQualified = 1 
																	THEN 4
																WHEN J.str1099Form = '1099-MISC' THEN 1
																WHEN J.str1099Form = '1099-INT' THEN 2
																WHEN J.str1099Form = '1099-B' THEN 3
															ELSE 0 END)
					,[int1099Category]				=	CASE 	WHEN G.intEntityId IS NOT NULL 
																	AND D.intItemId > 0
																	AND D.ysn1099Box3 = 1
																	AND G.ysnStockStatusQualified = 1 
																	THEN 3
														ELSE ISNULL(int1099CategoryId, 0) END
					,[intLineNo]					=	ROW_NUMBER() OVER(ORDER BY (SELECT 1))
					,[intContractDetailId]			=	NULL
					,[intContractHeaderId]			=	NULL
					,[intLoadDetailId]				=	NULL
					,[intLoadId]					=	NULL
					,[intScaleTicketId]				=	NULL
					,[intPurchaseTaxGroupId]		=	NULL
					,[intEntityVendorId]			=	F.intVendorId
					,[strVendorOrderNumber]			=	'Storage Charge-' + A.strStorageChargeNumber
					,strReference					=	'Storage Charge-' + A.strStorageChargeNumber
					,strSourceNumber				=	A.strStorageChargeNumber
					,intLocationId					=	A.intCompanyLocationId
					,intSubLocationId				=	A.intStorageLocationId
					,intStorageLocationId  			= 	Q.intStorageLocationId
					,intItemLocationId				=	C.intItemLocationId
					,ysnSubCurrency					=	0
					,intCurrencyId					=	A.intCurrencyId
					,ysnStage 						=	0
					,intStorageChargeId				=	B.intStorageChargeDetailId
					,intLotId						= 	B.intLotId
			FROM tblICStorageCharge A
			INNER JOIN tblICStorageChargeDetail B
				ON A.intStorageChargeId = B.intStorageChargeId
			INNER JOIN tblICItemLocation C
				ON A.intCompanyLocationId = C.intLocationId
					AND C.intItemId = B.intItemChargeId
			INNER JOIN tblICItem D
				ON D.intItemId = B.intItemChargeId
			LEFT JOIN tblICItemUOM E
				ON E.intItemUOMId = B.intItemChargeUOMId
			---------------Vendor Info-----------------
			-------------------------------------------
			LEFT JOIN tblICStorageRate F
				ON A.intStorageRateId = F.intStorageRateId
			LEFT JOIN vyuPATEntityPatron G
			 	ON F.intVendorId = G.intEntityId
			 LEFT JOIN vyuICGetItemStock H 
			 	ON H.intItemId = D.intItemId 
			 		AND H.intLocationId = A.intCompanyLocationId
			 LEFT JOIN tblEMEntity J
			 	ON J.intEntityId = F.intVendorId
			 LEFT JOIN tblAP1099Category I 
			 	ON I.strCategory = J.str1099Type
			-------------------------------------------
			-------------------------------------------
			LEFT JOIN tblICLot Q
				ON B.intLotId = Q.intLotId
			WHERE B.dblStorageCharge <> 0
				AND A.intStorageChargeId = @intStorageChargeId

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
					,@createdVouchersId = @strBillIds OUT

				
			END
		END

		---Update Storage Charge
		IF(ISNULL(@strBillIds,'') <> '')
		BEGIN
			SELECT @strVoucherNumbers = STUFF((
				SELECT 
					',' + strBillId
				FROM tblAPBill
				WHERE intBillId IN (	SELECT											
											A.Item
										FROM dbo.fnSplitString (@strBillIds,',') A																							
									)
				FOR XML PATH('')),1,1,'')				
			
			UPDATE tblICStorageCharge 
			SET ysnPosted = 1
			WHERE intStorageChargeId = @intStorageChargeId

			SET @logDescriotion = 'Posted with Voucher ' + @strVoucherNumbers
			
			EXEC dbo.uspSMAuditLog 
				@keyValue			= @intStorageChargeId					-- Primary Key Value of the Ticket. 
				,@screenName		= 'Inventory.view.StorageCharge'		-- Screen Namespace
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
		WHERE A.intStorageChargeId IN (SELECT  
											intStorageChargeDetailId 
										FROM tblICStorageChargeDetail
										WHERE intStorageChargeId = @intStorageChargeId
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



		---Update Storage Charge
		UPDATE tblICStorageCharge 
		SET ysnPosted = 0
		WHERE intStorageChargeId = @intStorageChargeId

		
		EXEC dbo.uspSMAuditLog 
			@keyValue			= @intStorageChargeId					-- Primary Key Value of the Ticket. 
			,@screenName		= 'Inventory.view.StorageCharge'		-- Screen Namespace
			,@entityId			= @intUserId				-- Entity Id.
			,@actionType		= 'Unposted'					-- Action Type
			,@changeDescription	= 'Unposted Storage Charge.'	-- Description
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