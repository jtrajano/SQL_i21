CREATE VIEW [dbo].[vyuAPRptTaxRemittance]
	AS 
	 SELECT 
		APV.strVendorId,
		APV.intEntityVendorId,
		'' as strTaxCode, -- no tax code field
		dblComputedAmount = SUM(APP.dblWithheld),
		Cast(APP.dtmDatePaid as Date )as dtmDate
	FROM dbo.tblAPVendor APV
	INNER JOIN 
		tblAPPayment APP
	ON APP.intEntityVendorId = APV.intEntityVendorId
	WHERE 
		APV.ysnWithholding = 1
	GROUP BY 
		APV.strVendorId,
		APV.intEntityVendorId,
		APP.dtmDatePaid