CREATE PROCEDURE [dbo].[uspAPCreateMiscVoucherFromPO]
	@poId AS INT,
	@userId AS INT,
	@voucherCreated AS INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateMiscVoucherFromPO';
DECLARE @createdVouchersId AS NVARCHAR(MAX)
DECLARE @voucherPayables AS VoucherPayable

INSERT INTO @voucherPayables(
	intPartitionId
	,intTransactionType
	,intEntityVendorId
	,intShipToId
	,intShipFromId
	,intCurrencyId
	,intTermId
	,strMiscDescription
	,dblCost
	,dblQuantityToBill
    ,dblOrderQty
    ,intPurchaseDetailId
)
SELECT
	intPartitionId				= ROW_NUMBER() OVER(ORDER BY A.intEntityVendorId) --1 voucher per 1 vendor
	,intTransactionType			= 1
	,intEntityVendorId			= A.intEntityVendorId
	,intShipToId				= A.intShipToId
	,intShipFromId				= A.intShipFromId
	,intCurrencyId				= A.intCurrencyId
	,intTermsId					= A.intTermsId
	,strMiscDescription			= B.strMiscDescription
    ,dblCost					= B.dblCost
	,dblQuantityToBill			= B.dblQtyOrdered - B.dblQtyReceived
    ,dblOrderQty                = B.dblQtyOrdered
    ,intPurchaseDetailId        = B.intPurchaseDetailId
FROM tblPOPurchaseDetail B
INNER JOIN tblPOPurchase A ON A.intPurchaseId = B.intPurchaseId
WHERE A.intPurchaseId = @poId
-- INNER JOIN @poIds C ON B.intPurchaseId = C.intId

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

EXEC uspAPCreateVoucher @voucherPayables = @voucherPayables, @userId = @userId, @throwError = 1, @createdVouchersId = @createdVouchersId OUT

DECLARE @vouchers AS Id
INSERT INTO @vouchers SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@createdVouchersId)

SELECT TOP 1
    @voucherCreated = intID
FROM @vouchers

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
    SET @ErrorProc     = ERROR_PROCEDURE()
    -- SET @ErrorMessage  = 'Problem creating basis advance.' + CHAR(13) + 
	-- 		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
	-- 		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0
    SET @ErrorState = 1

    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
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