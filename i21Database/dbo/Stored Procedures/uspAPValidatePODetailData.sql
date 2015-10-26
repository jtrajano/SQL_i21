CREATE PROCEDURE [dbo].[uspAPValidatePODetailData]
	@voucherId INT,
	@voucherPODetails AS VoucherPODetail READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @errItem NVARCHAR(50);
DECLARE @error NVARCHAR(500);

--Validate if voucher po detail data only have non-inventory items.
SELECT TOP 1 @errItem = A.strItemNo 
FROM tblICItem A
	INNER JOIN tblPOPurchaseDetail B ON A.intItemId = B.intItemId
	INNER JOIN @voucherPODetails C ON B.intPurchaseDetailId = C.intPurchaseDetailId
WHERE A.strType NOT IN ('Non-Inventory', 'Other Charge', 'Service', 'Software')

IF @errItem IS NOT NULL
BEGIN
	SET @error = 'You cannot directly bill an inventory item (''' + @errItem + '''.'
	RAISERROR(@error, 16, 1);
END

--Validate if purchase detail were fully billed.
SELECT TOP 1 @errItem = A.strItemNo 
FROM tblICItem A
	INNER JOIN tblPOPurchaseDetail B ON A.intItemId = B.intItemId
	INNER JOIN @voucherPODetails C ON B.intPurchaseDetailId = C.intPurchaseDetailId
WHERE B.dblQtyOrdered = B.dblQtyReceived

IF @errItem IS NOT NULL
BEGIN
	SET @error = 'Item ''' + @errItem + ''' was fully billed.'
	RAISERROR(@error, 16, 1);
END

--Validate if Purchase Detail vendor is same the voucher vendor
SELECT 
	TOP 1 @errItem = B2.strItemNo
FROM @voucherPODetails A
INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseDetailId = B.intPurchaseDetailId
INNER JOIN tblICItem B2 ON B.intItemId = B2.intItemId
INNER JOIN tblPOPurchase C ON B.intPurchaseId = C.intPurchaseId
CROSS APPLY tblAPBill D
WHERE D.intBillId = @voucherId AND C.intEntityVendorId <> D.intEntityVendorId
--WHERE C.intEntityVendorId <> (SELECT intEntityVendorId FROM tblAPBill WHERE intBillId = @voucherId)

IF @errItem IS NOT NULL
BEGIN
	SET @error = 'Item ''' + @errItem + ''' was ordered from other vendor.'
	RAISERROR(@error, 16, 1);
END