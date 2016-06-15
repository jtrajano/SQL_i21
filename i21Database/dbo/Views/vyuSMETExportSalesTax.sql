CREATE VIEW [dbo].[vyuSMETExportSalesTax]
AS 

SELECT 
	[state] = LEFT(strTaxCode, CASE WHEN charindex(' ', strTaxCode) = 0 THEN LEN(strTaxCode) ELSE charindex(' ', strTaxCode) - 1 END)
	,county = ltrim(substring(strTaxCode,charindex(' ',strTaxCode), CHARINDEX(' ',ltrim(SUBSTRING(strTaxCode,charindex(' ',strTaxCode),LEN(strTaxCode)-charindex(' ',strTaxCode)))) ))
	,city = strCity
	,sales_tax = dblRate
	,st_acct = ''
	,use_tax = 0.00
	,ut_acct = '00000000'
	,chrTaxCode = REPLACE(tblSMTaxCode.strTaxCode, ' ', '')

from tblSMTaxCode
inner join 
(
	select 
		 tblSMTaxCodeRate.intTaxCodeId
		 , tblSMTaxCodeRate. dblRate
	from 
		tblSMTaxCodeRate inner join
		(
			select intTaxCodeId, dtmEffectiveDate = max(dtmEffectiveDate) from tblSMTaxCodeRate
			group by intTaxCodeId
		)tblSMTaxCodeEffectivity
		on tblSMTaxCodeRate.intTaxCodeId = tblSMTaxCodeEffectivity.intTaxCodeId
		and tblSMTaxCodeRate.dtmEffectiveDate = tblSMTaxCodeEffectivity.dtmEffectiveDate
)tblTaxEffect
on tblSMTaxCode.intTaxCodeId = tblTaxEffect.intTaxCodeId
