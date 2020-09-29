CREATE VIEW [dbo].[vyuAPVoucherPayableTaxStaging]
AS
SELECT          TS.intVoucherPayableId,
				TS.intTaxGroupId,
				TS.intTaxCodeId,
				TS.intTaxClassId,
				TS.strTaxableByOtherTaxes,
				TS.strCalculationMethod,
				TS.dblRate,
				TS.intAccountId,
				TS.dblTax,
				TS.dblAdjustedTax,
				TS.ysnTaxAdjusted,
				TS.ysnSeparateOnBill,
				TS.ysnCheckOffTax,
				TS.ysnTaxOnly,
				TS.ysnTaxExempt,
				TS.dtmDateEntered,
				TC.strTaxCode
FROM tblAPVoucherPayableTaxStaging TS
INNER JOIN tblSMTaxCode TC ON  TC.intTaxCodeId  = TS.intTaxCodeId
GO