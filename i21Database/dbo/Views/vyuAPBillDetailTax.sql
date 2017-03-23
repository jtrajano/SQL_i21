CREATE VIEW [dbo].[vyuAPBillDetailTax]
AS
SELECT          A.intBillDetailTaxId ,
				A.intBillDetailId ,
				A.intTaxGroupMasterId ,
				A.intTaxGroupId ,
				A.intTaxCodeId ,
				A.intTaxClassId ,
				A.strTaxableByOtherTaxes ,
				A.strCalculationMethod ,
				A.dblRate ,
				A.intAccountId ,
				A.dblTax ,
				A.dblAdjustedTax ,
				A.ysnTaxAdjusted ,
				A.ysnSeparateOnBill ,
				A.ysnCheckOffTax ,
				A.ysnTaxExempt,
				A.intConcurrencyId,
				B.strTaxCode
FROM dbo.tblAPBillDetailTax A
INNER JOIN dbo.tblSMTaxCode B ON  A.intTaxCodeId  = B.intTaxCodeId
GO

