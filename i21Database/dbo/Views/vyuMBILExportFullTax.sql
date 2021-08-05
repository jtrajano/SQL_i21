CREATE VIEW [dbo].[vyuMBILExportFullTax]
AS 

SELECT
		  ROW_NUMBER() OVER(ORDER BY TG.intTaxGroupId) AS intFulltaxId
		, TG.intTaxGroupId
		, TG.strTaxGroup
		, TC.intTaxCodeId
		, TC.strTaxCode
		, TCL.intTaxClassId
		, TCL.strTaxClass
		, strCalculationMethod = (SELECT TOP 1 strCalculationMethod from tblSMTaxCodeRate where intTaxCodeId = TC.intTaxCodeId and CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC) 
		, dblRate = (SELECT TOP 1 dblRate from tblSMTaxCodeRate where intTaxCodeId = TC.intTaxCodeId and CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC) 
		, dblQuantity = 0.00
		, dblPrice = 0.00
		, dblTotal = 0.00
		, ysnCheckoffTax
		, ysnTaxOnly
		, strTaxableByOtherTaxes
		, TRT.strType
		from tblSMTaxGroup TG
	inner join tblSMTaxGroupCode TGC on TGC.intTaxGroupId = TG.intTaxGroupId
	inner join tblSMTaxCode TC on TC.intTaxCodeId = TGC.intTaxCodeId
	inner join tblSMTaxClass TCL on TCL.intTaxClassId = TC.intTaxClassId
	inner join tblSMTaxReportType TRT on TRT.intTaxReportTypeId = TCL.intTaxReportTypeId
	

