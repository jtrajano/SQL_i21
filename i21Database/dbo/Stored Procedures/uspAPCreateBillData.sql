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
	@voucherDetailReceiptPO AS VoucherDetailReceipt READONLY,
	@voucherDetailNonInvContract AS VoucherDetailNonInvContract READONLY,
	@voucherDetailStorage AS VoucherDetailStorage READONLY,
	@voucherDetailCC AS VoucherDetailCC READONLY,
	@voucherDetailClaim AS VoucherDetailClaim READONLY,
	@voucherDetailLoadNonInv AS VoucherDetailLoadNonInv READONLY,
	@shipTo INT= NULL,
	@vendorOrderNumber NVARCHAR(50) = NULL,
	@voucherDate DATETIME = NULL,
	@billId INT OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @startingRecordId INT;
DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

	IF NOT EXISTS(SELECT 1 FROM tblAPVendor WHERE [intEntityId] = @vendorId)
	BEGIN
		RAISERROR('Vendor does not exists.', 16, 1);
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
		[intCurrencyId]			=	A.[intCurrencyId]
	INTO #tmpBillData
	FROM dbo.fnAPCreateBillData(@vendorId, @userId, @type, DEFAULT, DEFAULT, DEFAULT, DEFAULT, @shipTo) A

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
		[intCurrencyId]			
	)
	SELECT * FROM #tmpBillData

	SET @billId = SCOPE_IDENTITY()

	--Add details
	EXEC uspAPCreateVoucherDetail @billId,
								 @voucherPODetails,
								 @voucherNonInvDetails,
								 @voucherDetailReceiptPO,
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
	INNER JOIN tblCTContractDetail ContractDetail ON VoucherDetail.intContractDetailId = VoucherDetail.intContractDetailId
	INNER JOIN tblCTContractHeader ContractHeader ON ContractDetail.intContractHeaderId = ContractHeader.intContractHeaderId
	WHERE VoucherDetail.intBillId = @billId AND VoucherDetail.intContractDetailId > 0

	IF @contractTermId > 0
	BEGIN
		UPDATE Voucher
			SET Voucher.intTermsId = @contractTermId, Voucher.dtmDueDate = ISNULL(dbo.fnGetDueDateBasedOnTerm(Voucher.dtmDate, @contractTermId), Voucher.dtmDueDate)
		FROM tblAPBill Voucher
		WHERE Voucher.intBillId = @billId
	END

	IF @transCount = 0 COMMIT TRANSACTION

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
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
END
