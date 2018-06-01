/*
	VoucherPODetail - Use this to create bill from miscellaneous item ordered in PO
	VoucherDetailNonInventory - Use this to create bill and directly adding miscellaneous items.
	VoucherDetailReceipt - use this to create bill with item from Inventory Receipt.
	VoucherDetailNonInvContract - Use this to create bill with non inventory item associated to contract

	@type - The transaction type to create
	1 - Bill
	2 - Prepayment
	3 - Debit Memo
	9 - 1099 Adjustment
	10 - Patronage
*/
CREATE PROCEDURE [dbo].[uspAPCreateBillData]
	@userId INT,
	@vendorId INT,
	@type INT = 1,
	@voucherPODetails AS VoucherPODetail READONLY,
	@voucherNonInvDetails AS VoucherDetailNonInventory READONLY,
	@voucherDetailReceipt AS VoucherDetailReceipt READONLY,
	@voucherDetailReceiptCharge AS VoucherDetailReceiptCharge READONLY,
	@voucherDetailNonInvContract AS VoucherDetailNonInvContract READONLY,
	@voucherDetailStorage AS VoucherDetailStorage READONLY,
	@voucherDetailCC AS VoucherDetailCC READONLY,
	@voucherDetailClaim AS VoucherDetailClaim READONLY,
	@voucherDetailLoadNonInv AS VoucherDetailLoadNonInv READONLY,
	@shipTo INT= NULL,
	@shipFrom INT = NULL,
	@vendorOrderNumber NVARCHAR(50) = NULL,
	@voucherDate DATETIME = NULL,
	@currencyId INT = NULL,
	@throwError BIT = 1,
	@billId INT OUTPUT,
	@error NVARCHAR(1000) = NULL OUTPUT 
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @startingRecordId INT;
DECLARE @APAccount INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	IF NOT EXISTS(SELECT 1 FROM tblAPVendor WHERE [intEntityId] = @vendorId)
	BEGIN
		SET @error =  'Vendor does not exists.';
		IF @throwError = 1
		BEGIN
			RAISERROR(@error, 16, 1);
		END
		RETURN;
	END

	IF ISNULL(@userId, 0) > 0 AND @shipTo IS NULL
	BEGIN
		SELECT TOP 1 
			@shipTo = intCompanyLocationId
		FROM tblSMUserSecurity WHERE [intEntityId] = @userId
	END

	SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @shipTo)  
	IF @APAccount IS NULL OR @APAccount <= 0
	BEGIN
		SET @error =  'Please setup default AP Account.';
		IF @throwError = 1
		BEGIN
			RAISERROR(@error, 16, 1);
		END
		RETURN;
	END

	SET @APAccount = (SELECT intAPAccount FROM tblSMCompanyLocation WHERE intCompanyLocationId = @shipTo)  
	IF @APAccount IS NULL OR @APAccount <= 0
	BEGIN
		RAISERROR('Please setup default AP Account.', 16, 1);
	END
	
	DECLARE @billRecordNumber NVARCHAR(50);
	IF @type = 1
	BEGIN
		SET @startingRecordId = 9;
	END
	ELSE IF @type = 2
	BEGIN
		SET @startingRecordId = 20;
	END
	ELSE IF @type = 3
	BEGIN
		SET @startingRecordId = 18;
	END
	ELSE IF @type = 8
	BEGIN
		SET @startingRecordId = 66;
	END
	ELSE IF @type = 9
	BEGIN
		SET @startingRecordId = 77;
	END
	ELSE IF @type = 11
	BEGIN
		SET @startingRecordId = 101;
	END
	ELSE IF @type = 13
	BEGIN
		SET @startingRecordId = 124;
	END
	ELSE IF @type = 14
	BEGIN
		SET @startingRecordId = 132;
	END

	EXEC uspSMGetStartingNumber @startingRecordId, @billRecordNumber OUTPUT

	
	SELECT 
		[intTermsId]			=	A.[intTermsId],
		[dtmDueDate]			=	A.[dtmDueDate],
		[dtmDate]				=	ISNULL(@voucherDate,A.[dtmDate]),
		[dtmBillDate]			=	ISNULL(@voucherDate,A.[dtmDate]),
		[intAccountId]			=	A.[intAccountId],
		[intEntityId]			=	A.[intEntityId],
		[intEntityVendorId]		=	A.[intEntityVendorId],
		[intTransactionType]	=	A.[intTransactionType],
		[strVendorOrderNumber]	=	@vendorOrderNumber,
		[strBillId]				=	@billRecordNumber,
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
		[intPayToAddressId]		=	A.[intShipFromId],
		[intShipToId]			=	A.[intShipToId],
		[intStoreLocationId]	=	A.[intShipToId],
		[intShipViaId]			=	A.[intShipViaId],
		[intContactId]			=	A.[intContactId],
		[intOrderById]			=	A.[intOrderById],
		[intCurrencyId]			=	A.[intCurrencyId],
		[intSubCurrencyCents]	=	A.[intSubCurrencyCents]
	INTO #tmpBillData
	FROM dbo.fnAPCreateBillData(@vendorId, @userId, @type, DEFAULT, @currencyId, DEFAULT, @shipFrom, @shipTo) A

	INSERT INTO tblAPBill
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
		[intPayToAddressId]		, 
		[intShipToId]			,
		[intStoreLocationId]	,
		[intShipViaId]			,
		[intContactId]			,
		[intOrderById]			,
		[intCurrencyId]			,
		[intSubCurrencyCents]
	)
	SELECT * FROM #tmpBillData

	SET @billId = SCOPE_IDENTITY()

	--Add details
	EXEC uspAPCreateVoucherDetail @billId,
								 @voucherPODetails,
								 @voucherNonInvDetails,
								 @voucherDetailReceipt,
								 @voucherDetailReceiptCharge,
								 @voucherDetailNonInvContract,
								 @voucherDetailCC,
								 @voucherDetailStorage,
								 @voucherDetailLoadNonInv,
								 @voucherDetailClaim
	--EXEC uspAPUpdateVoucherTax @billId
	--EXEC uspAPUpdateVoucherContract @billId


	--UPDATE the term if detail has contract
	DECLARE @contractTermId INT;
	SELECT TOP 1 @contractTermId = ContractHeader.intTermId
	FROM tblAPBillDetail VoucherDetail
	--INNER JOIN tblCTContractDetail ContractDetail ON VoucherDetail.intContractDetailId = VoucherDetail.intContractDetailId
	INNER JOIN tblCTContractHeader ContractHeader ON VoucherDetail.intContractHeaderId = ContractHeader.intContractHeaderId
	WHERE VoucherDetail.intBillId = @billId AND VoucherDetail.intContractDetailId > 0

	UPDATE Voucher
		SET Voucher.intTermsId = (CASE WHEN @contractTermId > 0 THEN @contractTermId ELSE Voucher.intTermsId END),
		 Voucher.dtmDueDate = CASE WHEN @contractTermId > 0
									THEN ISNULL(dbo.fnGetDueDateBasedOnTerm(Voucher.dtmDate, @contractTermId), Voucher.dtmDueDate)
									ELSE ISNULL(dbo.fnGetDueDateBasedOnTerm(Voucher.dtmDate, Voucher.intTermsId), Voucher.dtmDueDate)
								END,
		Voucher.dblDiscount = dbo.fnGetDiscountBasedOnTerm(GETDATE(), Voucher.dtmDate, (CASE WHEN @contractTermId > 0 THEN @contractTermId ELSE Voucher.intTermsId END), Voucher.dblTotal),
		Voucher.dtmDeferredInterestDate = (CASE WHEN (
											SELECT TOP 1 ysnDeferredPay FROM tblSMTerm smterm WHERE smterm.intTermID = (CASE WHEN @contractTermId > 0 THEN @contractTermId ELSE Voucher.intTermsId END)
										) = 1 THEN Voucher.dtmBillDate ELSE NULL END)
	FROM tblAPBill Voucher
	WHERE Voucher.intBillId = @billId

	IF @transCount = 0 COMMIT TRANSACTION


BEGIN
	EXEC dbo.uspSMAuditLog 
	   @screenName = 'AccountsPayable.view.Voucher'		-- Screen Namespace
	  ,@keyValue = @billId								-- Primary Key Value of the Voucher. 
	  ,@entityId = @userId									-- Entity Id.
	  ,@actionType = 'Created'                        -- Action Type
	  ,@changeDescription = 'Integration'				-- Description
	  ,@fromValue = ''									-- Previous Value
	  ,@toValue = ''									-- New Value
END


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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	SET @error = @ErrorMessage;
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH
END
