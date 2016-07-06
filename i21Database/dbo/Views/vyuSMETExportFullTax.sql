CREATE VIEW [dbo].[vyuSMETExportFullTax]
AS 

select 
 ItemNumber				= strItemNo
, [state]				= LEFT(strTaxCode, CASE WHEN charindex(' ', strTaxCode) = 0 THEN LEN(strTaxCode) ELSE charindex(' ', strTaxCode) - 1 END)
, Authority1			= ltrim(substring(strTaxCode,charindex(' ',strTaxCode), CHARINDEX(' ',ltrim(SUBSTRING(strTaxCode,charindex(' ',strTaxCode),LEN(strTaxCode)-charindex(' ',strTaxCode)))) ))
, Authority1Description	= 'NULL'	
, Authority2			= reverse(LEFT(reverse(strTaxCode), CASE WHEN charindex(' ', reverse(strTaxCode)) = 0 THEN LEN(reverse(strTaxCode)) ELSE charindex(' ', reverse(strTaxCode)) - 1 END))
, Authority2Description	= 'NULL'	
, [Description]			= tblSMTaxCode.strDescription
, FETGLAccount			= ''
, EFTonFET				= 'N'
, SETRatePerUnit		= dblRate
, SETGLAccount			= tblGLAccount.strAccountId
, EFTonSET				= ''
, SSTRatePerUnit		= 0	
, SSTGLAccount			= ''
, SSTMethod				= 'N'
, SSTOnFET				= ''	
, SSTOnSET				= ''	
, EFTOnSST				= 'N'	
, PSTRatePerUnit		= 0	
, PSTGLAccount			= ''	
, PSTMethod				= ''	
, Locale1Description	= ''
, Locale1Rate			= 0	
, Locale1GLAccount		= ''
, Locale1Method			= ''
, Locale1EFT			= 'N'
, Locale1SSTOnLC1		= ''
, Locale1LC1OnFET		= ''
, Locale2Description	= ''
, Locale2Rate			= 0
, Locale2GLAccount		= ''	
, Locale2Method			= ''
, Locale2EFT			= 'N'
, Locale2SSTOnLC2		= ''	
, Locale2LC2OnFET		= ''	
, Locale3Description	= ''	
, Locale3Rate			= 0	
, Locale3GLAccount		= ''	
, Locale3Method			= ''	
, Locale3EFT			= 'N'	
, Locale3SSTOnLC3		= ''	
, Locale3LC3OnFET		= ''	
, Locale4Description	= ''	
, Locale4Rate			= 0	
, Locale4GLAccount		= ''	
, Locale4Method			= ''
, Locale4EFT			= 'N'	
, Locale4SSTOnLC4		= ''	
, Locale4LC4OnFET		= ''	
, Locale5Description	= ''	
, Locale5Rate			= 0	
, Locale5GLAccount		= ''
, Locale5Method			= ''
, Locale5EFT			= 'N'	
, Locale5SSTOnLC5		= ''	
, Locale5LC5OnFET		= ''	
, Locale6Description	= ''	
, Locale6Rate			= 0	
, Locale6GLAccount		= ''	
, Locale6Method			= ''
, Locale6EFT			= 'N'	
, Locale6SSTOnLC6		= ''
, Locale6LC6OnFET		= ''
, Locale7Description	= ''
, Locale7Rate			= 0
, Locale7GLAccount		= ''
, Locale7Method			= ''
, Locale7EFT			= 'N'
, Locale7SSTOnLC7		= ''	
, Locale7LC7OnFET		= ''
, Locale8Description	= ''
, Locale8Rate			= 0	
, Locale8GLAccount		= ''	
, Locale8Method			= ''	
, Locale8EFT			= 'N'	
, Locale8SSTOnLC8		= ''	
, Locale8LC8OnFET		= ''	
, Locale9Description	= ''	
, Locale9Rate			= 0	
, Locale9GLAccount		= ''	
, Locale9Method			= ''	
, Locale9EFT			= 'N'	
, Locale9SSTOnLC9		= ''	
, Locale9LC9OnFET		= ''
, Locale10Description	= ''	
, Locale10Rate			= 0	
, Locale10GLAccount		= ''	
, Locale10Method		= ''	
, Locale10EFT			= 'N'	
, Locale10SSTOnLC10		= ''
, Locale10LC10OnFET		= ''
, Locale11Description	= ''	
, Locale11Rate			= 0	
, Locale11GLAccount		= ''	
, Locale11Method		= ''	
, Locale11EFT			= 'N'	
, Locale11SSTOnLC11		= ''	
, Locale11LC11OnFET		= ''
, Locale12Description	= ''	
, Locale12Rate			= 0
, Locale12GLAccount		= ''
, Locale12Method		= ''
, Locale12EFT			= 'N'
, Locale12SSTOnLC12		= ''
, Locale12LC12OnFET		= ''
from
tblSMTaxCode 
inner join 
(
	select tblSMTaxGroup.intTaxGroupId, intTaxCodeId 
	from tblSMTaxGroup 
	inner join tblSMTaxGroupCode on tblSMTaxGroup.intTaxGroupId = tblSMTaxGroupCode.intTaxGroupId
	inner join tblETExportFilterTaxGroup on tblETExportFilterTaxGroup.intTaxGroupId = tblSMTaxGroup.intTaxGroupId
)tblETExportFilterTaxGroup on tblSMTaxCode.intTaxCodeId = tblETExportFilterTaxGroup.intTaxCodeId
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
left join vyuICGetCategoryTax on tblSMTaxCode.intTaxClassId = vyuICGetCategoryTax.intTaxClassId
inner join tblICItem on vyuICGetCategoryTax.intCategoryId = tblICItem.intCategoryId
inner join tblGLAccount on tblGLAccount.intAccountId = tblSMTaxCode.intSalesTaxAccountId


