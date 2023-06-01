CREATE PROCEDURE [dbo].[uspVRCreateDebitMemoOrVoucher] (
	  @InvoiceId INT
    , @IsPost BIT
    , @UserId INT
    , @Type NVARCHAR(50) -- Valid Values: Debit Memo, Voucher
	, @ErrorMessage NVARCHAR(250) = NULL OUTPUT
) AS
BEGIN
    DECLARE @TransactionType INT
    DECLARE @Voucher INT = 1
    DECLARE @DebitMemo INT = 3
    DECLARE @voucherPayables AS VoucherPayable
    DECLARE @createVoucherIds NVARCHAR(MAX)
    DECLARE @intUserId INT = CASE WHEN @UserId IS NULL THEN (SELECT TOP 1 intEntityId FROM tblSMUserSecurity) ELSE @UserId END
    SET @TransactionType = CASE @Type WHEN 'Voucher' THEN 1 ELSE 3 END
    
    IF ISNULL(@IsPost, 0) = 1
    BEGIN
       INSERT INTO @voucherPayables (
            intPartitionId
            , intEntityVendorId
            , intTransactionType
            , dtmDate
            , dtmVoucherDate
            , dblOrderQty
            , dblQuantityToBill
            , dblCost
            , intCostUOMId
            , intAccountId
            , strVendorOrderNumber
            , ysnStage
            , intItemId
            , intCurrencyId
            , ysnSubCurrency
            , intSubCurrencyCents
            , strMiscDescription
            , intLocationId
            , intSubLocationId
            , strSourceNumber
            , intOrderUOMId
            , intQtyToBillUOMId
            , intCostCurrencyId
            , dblWeight
            , dblNetWeight
            , intWeightUOMId
            , strReference
            , intBookId
            , intInvoiceId
            , intShipViaId
            , intFreightTermId
        )
        SELECT
            intPartitionId = 1
            , intEntityVendorId =  vs.intEntityId
            , intTransactionType = CASE @Type WHEN 'Debit Memo' THEN @DebitMemo ELSE @Voucher END
            , dtmDate = inv.dtmDate
            , dtmVoucherDate = inv.dtmDate
            , dblOrderQty = CASE @Type WHEN 'Debit Memo' THEN vr.dblRebateQuantity ELSE -vr.dblRebateQuantity END
            , dblQuantityToBill = CASE @Type WHEN 'Debit Memo' THEN vr.dblRebateQuantity ELSE -vr.dblRebateQuantity END
            , dblCost = vr.dblRebateRate
            , intCostUOMId = invd.intItemUOMId
            , intAccountId = dbo.fnGetItemGLAccount(invd.intItemId, il.intItemLocationId, 'Cost of Goods') 
            , strVendorOrderNumber = inv.strInvoiceNumber
            , ysnStage = CAST(0 AS BIT)
            , intItemId = invd.intItemId
            , intCurrencyId = inv.intCurrencyId
            , ysnSubCurrency = CAST(0 AS BIT)
            , intSubCurrencyCents = NULL
            , strMiscDescription = invd.strItemDescription
            , intLocationId = inv.intCompanyLocationId
            , intSubLocationId = invd.intSubLocationId
            , strSourceNumber = NULL
            , intOrderUOMId = invd.intOrderUOMId
            , intQtyToBillUOMId = invd.intItemUOMId
            , intCostCurrencyId = inv.intCurrencyId
            , dblWeight = invd.dblItemWeight
            , dblNetWeight = invd.dblItemWeight
            , intWeightUOMId = invd.intItemWeightUOMId
            , strReference = NULL
            , intBookId = inv.intBookId
            , intInvoiceId = inv.intInvoiceId
            , intShipViaId = inv.intShipViaId
            , intFreightTermId = inv.intFreightTermId
        FROM vyuVROpenRebate vr
        JOIN tblARInvoice inv ON inv.intInvoiceId = vr.intInvoiceId
        JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = vr.intVendorSetupId
        JOIN tblARInvoiceDetail invd ON invd.intInvoiceId = inv.intInvoiceId
            AND invd.intInvoiceDetailId = vr.intInvoiceDetailId
        LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
            AND il.intLocationId = inv.intCompanyLocationId
        WHERE vr.intInvoiceId = @InvoiceId

        EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayables, @userId = @intUserId, @throwError = 0, @error = @ErrorMessage OUT, @createdVouchersId = @createVoucherIds OUT
        
        DECLARE @IsSuccess BIT
        -- Step 7: Auto-post the Voucher. 
        IF @createVoucherIds IS NOT NULL
        BEGIN
            EXEC [dbo].[uspAPPostBill] @post = 1, @recap = 0, @isBatch = 0, @param = @createVoucherIds, @userId = @UserId, @success = @IsSuccess OUTPUT
        END
    END
    ELSE
    BEGIN
        DECLARE @intBillId INT
        SELECT TOP 1 @intBillId = b.intBillId
        FROM tblAPBill b
        JOIN tblARInvoice i ON b.strVendorOrderNumber = i.strInvoiceNumber
        JOIN tblARInvoiceDetail id ON id.intInvoiceId = i.intInvoiceId
        JOIN tblVRRebate vr ON vr.intInvoiceDetailId = id.intInvoiceDetailId
        WHERE i.intInvoiceId = @InvoiceId

        IF @intBillId IS NOT NULL
            EXEC dbo.uspAPDeleteVoucher @intBillId, @UserId, 11

        UPDATE invd
        SET invd.dblRebateAmount = 0
        FROM tblARInvoiceDetail invd
        JOIN vyuVROpenRebate vr ON invd.intInvoiceId = vr.intInvoiceId AND vr.intInvoiceDetailId = invd.intInvoiceDetailId
        JOIN tblARInvoice inv ON inv.intInvoiceId = vr.intInvoiceId
        JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = vr.intVendorSetupId
        LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
            AND il.intLocationId = inv.intCompanyLocationId
        WHERE vr.intInvoiceId = @InvoiceId

        UPDATE sar
        SET sar.dblRebateAmount = invd.dblRebateAmount
        FROM tblARSalesAnalysisStagingReport sar
        JOIN tblARInvoiceDetail invd ON invd.intInvoiceDetailId = sar.intInvoiceDetailId
        WHERE invd.intInvoiceId = @InvoiceId
    END
END