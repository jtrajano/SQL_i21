CREATE PROCEDURE [dbo].[uspAPDeletePatronageTaxes]
	@voucherIds AS Id READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE taxes
FROM tblAPBillDetailTax taxes
INNER JOIN tblAPBillDetail voucherDetail
	ON voucherDetail.intBillDetailId = taxes.intBillDetailId
INNER JOIN @voucherIds vouchers
	ON vouchers.intId = voucherDetail.intBillId