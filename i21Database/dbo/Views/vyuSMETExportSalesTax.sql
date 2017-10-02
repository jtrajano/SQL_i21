CREATE VIEW [dbo].[vyuSMETExportSalesTax]
AS 

SELECT 
	[state] = LEFT(tblSMTaxGroup.strTaxGroup, 2) --LEFT(strTaxCode, CASE WHEN charindex(' ', strTaxCode) = 0 THEN LEN(strTaxCode) ELSE charindex(' ', strTaxCode) - 1 END)
	,county = ltrim(substring(strTaxCode,charindex(' ',strTaxCode), CHARINDEX(' ',ltrim(SUBSTRING(strTaxCode,charindex(' ',strTaxCode),LEN(strTaxCode)-charindex(' ',strTaxCode)))) ))
	,city = strCity
	,sales_tax = dblRate
	,st_acct = tblGLAccount.strAccountId
	,use_tax = 0.000000 --0.00
	,ut_acct = '00000000'
	,chrTaxCode = LEFT(tblSMTaxGroup.strTaxGroup, 2) + cast(tblSMTaxGroup.intTaxGroupId as nvarchar) --REPLACE(tblSMTaxCode.strTaxCode, ' ', '')
FROM tblSMTaxCode
INNER JOIN 
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
ON tblSMTaxCode.intTaxCodeId = tblTaxEffect.intTaxCodeId
INNER JOIN tblGLAccount on tblGLAccount.intAccountId = tblSMTaxCode.intSalesTaxAccountId
INNER JOIN (select tblSMTaxGroupCode.intTaxCodeId, tblSMTaxGroup.intTaxGroupId, strTaxGroup
	from tblSMTaxGroup 
	INNER JOIN tblSMTaxGroupCode on tblSMTaxGroup.intTaxGroupId = tblSMTaxGroupCode.intTaxGroupId
	INNER JOIN tblETExportFilterTaxGroup on tblETExportFilterTaxGroup.intTaxGroupId = tblSMTaxGroup.intTaxGroupId
	INNER JOIN tblETExportTaxCodeMapping on tblETExportTaxCodeMapping.intTaxCodeId = tblSMTaxGroupCode.intTaxCodeId and tblETExportTaxCodeMapping.strTaxCodeReference = 'SST'
) tblSMTaxGroup
ON tblSMTaxCode.intTaxCodeId = tblSMTaxGroup.intTaxCodeId