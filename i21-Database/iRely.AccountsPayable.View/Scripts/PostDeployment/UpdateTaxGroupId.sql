--THIS WILL UPDATE THE tblAPBillDetail.intTaxGroupId AND tblPOPurchaseDetail.intTaxGroupId
IF EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail A INNER JOIN tblAPBillDetailTax B ON A.intBillDetailId = B.intBillDetailId WHERE A.intTaxGroupId != B.intTaxGroupId)
BEGIN
	UPDATE voucherDetail
		SET voucherDetail.intTaxGroupId = taxDetail.intTaxGroupId
	FROM tblAPBillDetail voucherDetail
	CROSS APPLY (
		SELECT TOP 1 intTaxGroupId 
		FROM tblAPBillDetailTax voucherDetailTax 
		WHERE voucherDetail.intBillDetailId = voucherDetailTax.intBillDetailId
		AND voucherDetail.intTaxGroupId != voucherDetailTax.intTaxGroupId
	) taxDetail
END

IF EXISTS(SELECT TOP 1 1 FROM tblPOPurchaseDetail A INNER JOIN tblPOPurchaseDetailTax B ON A.intPurchaseDetailId = B.intPurchaseDetailId WHERE A.intTaxGroupId != B.intTaxGroupId)
BEGIN
	UPDATE poDetail
		SET poDetail.intTaxGroupId = taxDetail.intTaxGroupId
	FROM tblPOPurchaseDetail poDetail
	CROSS APPLY (
		SELECT TOP 1 intTaxGroupId 
		FROM tblPOPurchaseDetailTax poDetailTax 
		WHERE poDetail.intPurchaseDetailId = poDetailTax.intPurchaseDetailId
		AND poDetail.intTaxGroupId != poDetailTax.intTaxGroupId
	) taxDetail
END