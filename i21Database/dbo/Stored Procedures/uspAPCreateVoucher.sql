CREATE PROCEDURE [dbo].[uspAPCreateVoucher]
	@voucherPayables AS VoucherPayable READONLY
	,@voucherPayableTax AS VoucherDetailTax READONLY
	,@userId INT
	,@throwError BIT = 1
	,@error NVARCHAR(1000) = NULL OUTPUT
	,@createdVouchersId NVARCHAR(MAX) OUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @startingRecordId INT;
	DECLARE @voucherPayablesData AS VoucherPayable;
	DECLARE @voucherDetailTaxData AS VoucherDetailTax;
	DECLARE @APAccount INT;
	DECLARE @deleted TABLE(intVoucherPayableId INT);
	DECLARE @voucherIds AS Id;
	DECLARE @createdVouchers TABLE(
		intBillId				INT,
		intPartitionId			INT
		-- intTransactionType		INT,
		-- intLocationId			INT,
		-- intShipToId				INT,
		-- intShipFromId			INT,
		-- intShipFromEntityId		INT,
		-- intPayToAddressId		INT,
		-- intCurrencyId			INT
	);
	DECLARE @voucherHeader AS VoucherPayable;
	DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateVoucher';

	DECLARE @voucherStartNum INT = 0;
	DECLARE @voucherPref NVARCHAR(50);
	DECLARE @debitMemoStartNum INT = 0;
	DECLARE @debitMemoPref NVARCHAR(50);
	DECLARE @claimStartNum INT = 0;
	DECLARE @claimPref NVARCHAR(50);
	DECLARE @baStartNum INT = 0;
	DECLARE @baPref NVARCHAR(50);

	--Voucher Type
	IF EXISTS(SELECT TOP 1 1
		FROM tblSMCompanyLocation A
		INNER JOIN @voucherPayables B ON B.intShipToId = A.intCompanyLocationId
		AND A.intAPAccount IS NULL AND B.intAPAccount IS NULL AND B.intTransactionType IN (1,14)) 
	BEGIN
		SET @error =  'Please setup default AP Account.';
		IF @throwError = 1
		BEGIN
			RAISERROR(@error, 16, 1);
		END
		RETURN;
	END

	--Prepaid Type
	IF EXISTS(SELECT TOP 1 1
		FROM tblSMCompanyLocation A
		INNER JOIN @voucherPayables B ON B.intShipToId = A.intCompanyLocationId
		AND A.intPurchaseAdvAccount IS NULL AND B.intAPAccount IS NULL AND B.intTransactionType IN  (2, 13)) 
	BEGIN
		SET @error =  'Please setup default Prepaid Account.';
		IF @throwError = 1
		BEGIN
			RAISERROR(@error, 16, 1);
		END
		RETURN;
	END

	-- IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherHeader')) DROP TABLE #tmpVoucherHeader
	-- --FILTER VoucherPayables BASE ON THE # OF HEADER TO CREATE
	-- --WILL USE THE FILTERED DATA TO CREATE HEADER
	-- SELECT
	-- 	*
	-- INTO #tmpVoucherHeader
	-- FROM @voucherPayables A
	-- WHERE EXISTS (
	-- 	SELECT * FROM (
	-- 		SELECT
	-- 			MIN(header.intVoucherPayableId) intVoucherPayableId,
	-- 			MIN(header.intEntityVendorId) intEntityVendorId,
	-- 			header.strVendorOrderNumber strVendorOrderNumber,
	-- 			MIN(header.intTransactionType) intTransactionType,
	-- 			MIN(header.intLocationId) intLocationId,
	-- 			MIN(header.intShipToId) intShipToId,
	-- 			MIN(header.intShipFromId) intShipFromId,
	-- 			MIN(header.intShipFromEntityId) intShipFromEntityId,
	-- 			MIN(header.intPayToAddressId) intPayToAddressId,
	-- 			MIN(header.intCurrencyId) intCurrencyId
	-- 		FROM @voucherPayables header
	-- 		GROUP BY 
	-- 			header.intEntityVendorId,
	-- 			header.strVendorOrderNumber,
	-- 			header.intTransactionType,
	-- 			header.intLocationId,
	-- 			header.intShipToId,
	-- 			header.intShipFromId,
	-- 			header.intShipFromEntityId,
	-- 			header.intPayToAddressId,
	-- 			header.intCurrencyId
	-- 	) filteredPayables
	-- 	WHERE filteredPayables.intVoucherPayableId = A.intVoucherPayableId
	-- )

	SELECT
		@error = strError
	FROM dbo.fnAPValidateVoucherPayable(@voucherPayables, @voucherPayableTax)

	IF @error IS NOT NULL
	BEGIN
		IF @throwError = 1 RAISERROR(@error, 16, 1);
		RETURN;
	END
	
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpVoucherPayables')) DROP TABLE #tmpVoucherPayables
	--reinsert voucher payables to new VoucherPayable so that we could update the data of intBillId	
	SELECT 
		DENSE_RANK() OVER(ORDER BY intEntityVendorId,
									intTransactionType,
									intLocationId,
									intShipToId,
									intShipFromId,
									intShipFromEntityId,
									intPayToAddressId,
									intCurrencyId,
									strVendorOrderNumber) intPartitionId
		/*Header info*/
		,[intBillId]						
		,[intEntityVendorId]				
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
		,[intSubCurrencyCents]			
		,[intShipViaId]					
		,[intTermId]						
		,[strBillOfLading]				
		,[intAPAccount]					
		/*Detail info*/
		,[strMiscDescription]			
		,[intItemId]						
		,[ysnSubCurrency]				
		,[intAccountId]					
		,[ysnReturn]						
		,[intLineNo]						
		,[intStorageLocationId]			
		,[dblBasis]						
		,[dblFutures]					
		/*Integration fields*/
		,[intPurchaseDetailId]			
		,[intContractHeaderId]			
		,[intContractCostId]				
		,[intContractSeqId]				
		,[intContractDetailId]			
		,[intScaleTicketId]				
		,[intInventoryReceiptItemId]		
		,[intInventoryReceiptChargeId]	
		,[intInventoryShipmentItemId]	
		,[intInventoryShipmentChargeId]
		,[intLoadShipmentId]				
		,[intLoadShipmentDetailId]		
		,[intPaycheckHeaderId]			
		,[intCustomerStorageId]			
		,[intCCSiteDetailId]				
		,[intInvoiceId]					
		,[intBuybackChargeId]			
		/*Quantity info*/
		,[dblOrderQty]					
		,[dblOrderUnitQty]				
		,[intOrderUOMId]					
		,[dblQuantityToBill]				
		,[dblQtyToBillUnitQty]			
		,[intQtyToBillUOMId]				
		/*Cost info*/
		,[dblCost]						
		,[dblOldCost]					
		,[dblCostUnitQty]				
		,[intCostUOMId]					
		,[intCostCurrencyId]				
		/*Weight info*/
		,[dblWeight]						
		,[dblNetWeight]					
		,[dblWeightUnitQty]				
		,[intWeightUOMId]				
		/*Exchange Rate info*/
		,[intCurrencyExchangeRateTypeId]
		,[dblExchangeRate]				
		/*Tax info*/
		,[intPurchaseTaxGroupId]			
		,[dblTax]						
		/*Discount Info*/
		,[dblDiscount]					
		,[dblDetailDiscountPercent]		
		,[ysnDiscountOverride]			
		/*Deferred Voucher*/
		,[intDeferredVoucherId]			
		/*Prepaid Info*/
		,[dblPrepayPercentage]			
		,[intPrepayTypeId]				
		/*Claim info*/
		,[dblNetShippedWeight]			
		,[dblWeightLoss]					
		,[dblFranchiseWeight]			
		,[dblFranchiseAmount]			
		,[dblActual]						
		,[dblDifference]					
	INTO #tmpVoucherPayables
	FROM @voucherPayables A

	--THERE SHOULD BE NO CHANGES ON PRIMARY KEY (intVoucherPayableId)
	INSERT INTO @voucherPayablesData
	SELECT 
		A.* 
	FROM #tmpVoucherPayables A

	--CREATE HEADER DATA
	IF OBJECT_ID(N'tempdb..#tmpVoucherHeaderData') IS NOT NULL DROP TABLE #tmpVoucherHeaderData
	
	SELECT DISTINCT
		[intPartitionId]		=	A.intPartitionId,
		[strBillId]				=	CAST('' AS NVARCHAR(50)),
		[intTermsId]			=	A.[intTermsId],
		[dtmDueDate]			=	A.[dtmDueDate],
		[dtmDate]				=	A.[dtmDate],
		[dtmBillDate]			=	A.[dtmDate],
		[intAccountId]			=	A.[intAccountId],
		[intEntityId]			=	A.[intEntityId],
		[intEntityVendorId]		=	A.[intEntityVendorId],
		[intTransactionType]	=	A.[intTransactionType],
		[strVendorOrderNumber]	=	A.[strVendorOrderNumber],
		[strShipToAttention]	=	A.[strShipToAttention],
		[strShipToAddress]		=	A.[strShipToAddress],
		[strShipToCity]			=	A.[strShipToCity],
		[strShipToState]		=	A.[strShipToState],
		[strShipToZipCode]		=	A.[strShipToZipCode],
		[strShipToCountry]		=	A.[strShipToCountry],
		[strShipToPhone]		=	A.[strShipToPhone],
		[strShipFromAttention]	=	A.[strShipFromAttention],
		[strShipFromAddress]	=	A.[strShipFromAddress],
		[strShipFromCity]		=	A.[strShipFromCity],
		[strShipFromState]		=	A.[strShipFromState],
		[strShipFromZipCode]	=	A.[strShipFromZipCode],
		[strShipFromCountry]	=	A.[strShipFromCountry],
		[strShipFromPhone]		=	A.[strShipFromPhone],
		[intShipFromId]			=	A.[intShipFromId],
		[intShipFromEntityId]	=	A.[intShipFromEntityId],
		[intPayToAddressId]		=	A.[intPayToAddressId],
		[intShipToId]			=	A.[intShipToId],
		[intShipViaId]			=	A.[intShipViaId],
		[intStoreLocationId]	=	A.[intStoreLocationId],
		[intContactId]			=	A.[intContactId],
		[intOrderById]			=	A.[intOrderById],
		[intCurrencyId]			=	A.[intCurrencyId],
		[intSubCurrencyCents]	=	A.[intSubCurrencyCents]
	INTO #tmpVoucherHeaderData
	FROM dbo.fnAPCreateVoucherData(@userId, @voucherPayablesData) A

	--UPDATE VOUCHER PAYABLES TO MATCH WITH THE VOUCHER HEADER
 	UPDATE A
	SET
		A.intLocationId			= B.intStoreLocationId
		,A.intShipToId			= B.intShipToId
		,A.intShipFromEntityId	= B.intShipFromEntityId
		,A.intPayToAddressId	= B.intPayToAddressId
		,intCurrencyId			= B.intCurrencyId
	FROM @voucherPayablesData A
	INNER JOIN #tmpVoucherHeaderData B
		ON A.intPartitionId = B.intPartitionId

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
	ELSE SAVE TRAN @SavePoint

	--Voucher Type
	UPDATE A
		SET A.intConcurrencyId = A.intConcurrencyId + 1
		,@voucherStartNum = A.intNumber
		,@voucherPref = A.strPrefix
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 9

	UPDATE A
		SET A.strBillId = @voucherPref + CAST(@voucherStartNum - 1 AS NVARCHAR)
		,@voucherStartNum = @voucherStartNum + 1
	FROM #tmpVoucherHeaderData A
	WHERE A.intTransactionType = 1

	--DEBIT MEMO Type
	UPDATE A
		SET A.intConcurrencyId = A.intConcurrencyId + 1
		,@debitMemoStartNum = A.intNumber
		,@debitMemoPref = A.strPrefix
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 18

	UPDATE A
		SET A.strBillId = @debitMemoPref + CAST(@debitMemoStartNum - 1 AS NVARCHAR)
		,@debitMemoStartNum = @debitMemoStartNum + 1
	FROM #tmpVoucherHeaderData A
	WHERE A.intTransactionType = 3

	--WEIGHT CLAIM Type
	UPDATE A
		SET A.intConcurrencyId = A.intConcurrencyId + 1
		,@claimStartNum = A.intNumber
		,@claimPref = A.strPrefix
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 101

	UPDATE A
		SET A.strBillId = @claimPref + CAST(@claimStartNum - 1 AS NVARCHAR)
		,@claimStartNum = @claimStartNum + 1
	FROM #tmpVoucherHeaderData A
	WHERE A.intTransactionType = 11

	--BASIS ADVANCE Type
	UPDATE A
		SET A.intConcurrencyId = A.intConcurrencyId + 1
		,@baStartNum = A.intNumber
		,@baPref = A.strPrefix
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 124

	UPDATE A
		SET A.strBillId = @baPref + CAST(@baStartNum - 1 AS NVARCHAR)
		,@baStartNum = @baStartNum + 1
	FROM #tmpVoucherHeaderData A
	WHERE A.intTransactionType = 13

	MERGE INTO tblAPBill AS destination
	USING
	(
		SELECT * FROM #tmpVoucherHeaderData
	) AS SourceData
	ON (1=0)
	WHEN NOT MATCHED THEN
	INSERT 
	(
		[intTermsId]			,
		[dtmDueDate]			,
		[dtmDate]				,
		[dtmBillDate]			,
		[intAccountId]			,
		[intEntityId]			,
		[intEntityVendorId]		,
		[intTransactionType]	,
		[strVendorOrderNumber]	,
		[strBillId]				,
		[strShipToAttention]	,
		[strShipToAddress]		,
		[strShipToCity]			,
		[strShipToState]		,
		[strShipToZipCode]		,
		[strShipToCountry]		,
		[strShipToPhone]		,
		[strShipFromAttention]	,
		[strShipFromAddress]	,
		[strShipFromCity]		,
		[strShipFromState]		,
		[strShipFromZipCode]	,
		[strShipFromCountry]	,
		[strShipFromPhone]		,
		[intShipFromId]			,
		[intShipFromEntityId]	,
		[intPayToAddressId]		, 
		[intShipToId]			,
		[intStoreLocationId]	,
		[intShipViaId]			,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]
	)
	VALUES (
		[intTermsId]			,
		[dtmDueDate]			,
		[dtmDate]				,
		[dtmBillDate]			,
		[intAccountId]			,
		[intEntityId]			,
		[intEntityVendorId]		,
		[intTransactionType]	,
		[strVendorOrderNumber]	,
		[strBillId]				,
		[strShipToAttention]	,
		[strShipToAddress]		,
		[strShipToCity]			,
		[strShipToState]		,
		[strShipToZipCode]		,
		[strShipToCountry]		,
		[strShipToPhone]		,
		[strShipFromAttention]	,
		[strShipFromAddress]	,
		[strShipFromCity]		,
		[strShipFromState]		,
		[strShipFromZipCode]	,
		[strShipFromCountry]	,
		[strShipFromPhone]		,
		[intShipFromId]			,
		[intShipFromEntityId]	,
		[intPayToAddressId]		, 
		[intShipToId]			,
		[intStoreLocationId]	,
		[intShipViaId]			,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]
	)
	OUTPUT 
		inserted.intBillId 
		,SourceData.intPartitionId
	INTO @createdVouchers;

	--UPDATING STARTING NUMBER
	--Voucher Type
	UPDATE A
		SET A.intNumber = @voucherStartNum
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 9

	--DEBIT MEMO Type
	UPDATE A
		SET A.intNumber = @debitMemoStartNum
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 18

	--WEIGHT CLAIM Type
	UPDATE A
		SET A.intNumber = @claimStartNum
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 101

	--BASIS ADVANCE Type
	UPDATE A
		SET A.intNumber = @baStartNum
	FROM tblSMStartingNumber A
	WHERE A.intStartingNumberId = 124

	UPDATE A
		SET A.intBillId = B.intBillId
	FROM @voucherPayablesData A
	INNER JOIN @createdVouchers B
		ON A.intPartitionId = B.intPartitionId
			-- AND A.intTransactionType = B.intTransactionType
			-- AND A.intLocationId = B.intLocationId
			-- AND A.strVendorOrderNumber = B.strVendorOrderNumber
			-- AND ISNULL(A.intShipToId,0) = ISNULL(B.intShipToId,0)
			-- AND ISNULL(A.intShipFromId,0) = ISNULL(B.intShipFromId,0)
			-- AND ISNULL(A.intShipFromEntityId,0) = ISNULL(B.intShipFromEntityId,0)
			-- AND ISNULL(A.intPayToAddressId,0) = ISNULL(B.intPayToAddressId,0)
			-- AND ISNULL(A.intCurrencyId,0) = ISNULL(B.intCurrencyId,0)
	WHERE A.intBillId IS NULL

	INSERT INTO @voucherIds
	SELECT intBillId FROM @createdVouchers

	EXEC uspAPAddVoucherDetail @voucherDetails = @voucherPayablesData, @voucherPayableTax = @voucherPayableTax, @throwError = 1
	EXEC uspAPUpdateVoucherTotal @voucherIds

	SELECT @createdVouchersId = COALESCE(@createdVouchersId + ',', '') +  CONVERT(VARCHAR(12),intBillId)
	FROM @createdVouchers
	
	IF @transCount = 0 COMMIT TRANSACTION;

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1 AND @transCount > 0
	BEGIN
		ROLLBACK TRANSACTION  @SavePoint
	END

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END