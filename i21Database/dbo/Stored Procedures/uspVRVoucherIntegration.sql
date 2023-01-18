CREATE PROCEDURE [dbo].uspVRVoucherIntegration (@strBillIds NVARCHAR(MAX), @ysnPost BIT, @intUserId INT)
AS
BEGIN
    DECLARE @Ids TABLE (intId INT)

    INSERT INTO @Ids
    SELECT CAST(Item AS INT)
    FROM dbo.fnSplitString(@strBillIds, ',')

    DECLARE @intBillId INT
    DECLARE @intInvoiceId INT

    DECLARE cur CURSOR LOCAL FAST_FORWARD
    FOR SELECT intId FROM @Ids

    OPEN cur

    FETCH NEXT FROM cur INTO @intBillId

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @intInvoiceId = i.intInvoiceId
        FROM tblAPBill b
        JOIN tblARInvoice i ON i.strInvoiceNumber = b.strVendorOrderNumber
        WHERE b.intBillId = @intBillId

        UPDATE invd
        SET invd.dblRebateAmount = CASE @ysnPost WHEN 1 THEN CASE WHEN inv.strTransactionType = 'Credit Memo' THEN vr.dblRebateAmount ELSE ABS(vr.dblRebateAmount) END ELSE 0.0 END
        FROM tblARInvoiceDetail invd
        JOIN vyuVROpenRebate vr ON invd.intInvoiceId = vr.intInvoiceId AND vr.intInvoiceDetailId = invd.intInvoiceDetailId
        JOIN tblARInvoice inv ON inv.intInvoiceId = vr.intInvoiceId
        JOIN tblVRVendorSetup vs ON vs.intVendorSetupId = vr.intVendorSetupId
        LEFT JOIN tblICItemLocation il ON il.intItemId = invd.intItemId
            AND il.intLocationId = inv.intCompanyLocationId
        WHERE vr.intInvoiceId = @intInvoiceId

        UPDATE sar
        SET sar.dblRebateAmount = invd.dblRebateAmount
        FROM tblARSalesAnalysisStagingReport sar
        JOIN tblARInvoiceDetail invd ON invd.intInvoiceDetailId = sar.intInvoiceDetailId
        WHERE invd.intInvoiceId = @intInvoiceId

        FETCH NEXT FROM cur INTO @intBillId
    END

    CLOSE cur
    DEALLOCATE cur
END