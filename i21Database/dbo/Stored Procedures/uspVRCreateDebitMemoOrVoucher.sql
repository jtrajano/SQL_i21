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
        -- INSERT INTO tblVRRebate (
        --       intInvoiceDetailId
        --     , strSubmitted
        --     , dblQuantity
        --     , dblRebateAmount
        --     , dblRebateRate
        --     , intProgramId
        --     , dtmDate
        -- )
        -- SELECT
        --       invd.intInvoiceDetailId
        --     , 'Y'
        --     , vr.dblRebateQuantity
        --     , ISNULL(vr.dblRebateAmount, 0)
        --     , vr.dblRebateRate
        --     , vr.intProgramId
        --     , vr.dtmDate
        -- FROM vyuVROpenRebate vr
        --     JOIN tblARInvoice inv ON inv.intInvoiceId = vr.intInvoiceId
        -- JOIN tblARInvoiceDetail invd ON invd.intInvoiceId = inv.intInvoiceId
        -- LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
        --     AND il.intLocationId = inv.intCompanyLocationId
        -- WHERE vr.intInvoiceId = @InvoiceId

        IF @Type = 'Debit Memo' BEGIN
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
                , intEntityVendorId = inv.intEntityCustomerId
                , intTransactionType = @DebitMemo
                , dtmDate = inv.dtmDate
                , dtmVoucherDate = inv.dtmDate
                , dblOrderQty = vr.dblRebateQuantity
                , dblQuantityToBill = vr.dblRebateQuantity
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
            JOIN tblARInvoiceDetail invd ON invd.intInvoiceId = inv.intInvoiceId
            LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
                AND il.intLocationId = inv.intCompanyLocationId
            WHERE vr.intInvoiceId = @InvoiceId

            EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayables, @userId = @intUserId, @throwError = 0, @error = @ErrorMessage OUT, @createdVouchersId = @createVoucherIds OUT

            DECLARE @IsSuccess BIT
            -- Step 7: Auto-post the Voucher. 
            IF @createVoucherIds IS NOT NULL 
                EXEC [dbo].[uspAPPostBill] @post = 1, @recap = 0, @isBatch = 0, @param = @createVoucherIds, @userId = @UserId, @success = @IsSuccess OUTPUT
        END
        ELSE
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
                , intEntityVendorId = inv.intEntityCustomerId
                , intTransactionType = @Voucher
                , dtmDate = inv.dtmDate
                , dtmVoucherDate = inv.dtmDate
                , dblOrderQty = vr.dblRebateQuantity
                , dblQuantityToBill = vr.dblRebateQuantity
                , dblCost = vr.dblRebateRate
                , intCostUOMId = invd.intItemUOMId
                , intAccountId = invd.intAccountId
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
            JOIN tblARInvoice inv ON inv.intOriginalInvoiceId = vr.intInvoiceId
            JOIN tblARInvoiceDetail invd ON invd.intInvoiceId = inv.intInvoiceId
            LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
                AND il.intLocationId = inv.intCompanyLocationId
            WHERE inv.intInvoiceId = @InvoiceId

           EXEC [dbo].[uspAPCreateVoucher] @voucherPayables = @voucherPayables, @userId = @intUserId, @throwError = 0, @error = @ErrorMessage OUT, @createdVouchersId = @createVoucherIds OUT
        END
    END
    ELSE
    BEGIN
        DECLARE @intBillId INT
        SELECT TOP 1 @intBillId = b.intBillId
        FROM tblAPBill b
        JOIN tblARInvoice i ON b.strVendorOrderNumber = i.strInvoiceNumber
        WHERE i.intInvoiceId = @InvoiceId

        IF @intBillId IS NOT NULL
            EXEC dbo.uspAPDeleteVoucher @intBillId, @UserId, 11
    END
END