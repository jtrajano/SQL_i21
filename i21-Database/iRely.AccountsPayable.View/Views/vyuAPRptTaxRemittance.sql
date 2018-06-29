CREATE VIEW [dbo].[vyuAPRptTaxRemittance]
	AS 
	 SELECT 
		APV.strVendorId,
		APV.[intEntityId],
		'' as strTaxCode, -- no tax code field
		dblComputedAmount = SUM(APP.dblWithheld),
		Cast(APP.dtmDatePaid as Date )as dtmDate
	FROM dbo.tblAPVendor APV
	INNER JOIN 
		tblAPPayment APP
	ON APP.intEntityVendorId = APV.[intEntityId]
	WHERE 
		APV.ysnWithholding = 1
	GROUP BY 
		APV.strVendorId,
		APV.[intEntityId],
		APP.dtmDatePaid