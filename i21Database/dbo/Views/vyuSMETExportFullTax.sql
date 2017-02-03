CREATE VIEW [dbo].[vyuSMETExportFullTax]
AS 

SELECT
ItemNumber				= strItemNo
, [state]				= LEFT(strTaxCode, CASE WHEN charindex(' ', strTaxCode) = 0 THEN LEN(strTaxCode) ELSE charindex(' ', strTaxCode) - 1 END)
, Authority1			= ltrim(substring(strTaxCode,charindex(' ',strTaxCode), CHARINDEX(' ',ltrim(SUBSTRING(strTaxCode,charindex(' ',strTaxCode),LEN(strTaxCode)-charindex(' ',strTaxCode)))) ))
, Authority1Description	= NULL	
, Authority2			= NULL--reverse(LEFT(reverse(strTaxCode), CASE WHEN charindex(' ', reverse(strTaxCode)) = 0 THEN LEN(reverse(strTaxCode)) ELSE charindex(' ', reverse(strTaxCode)) - 1 END))
, Authority2Description	= NULL	
, [Description]			= TaxGroup.strDescription --tblSMTaxCode.strDescription
, FETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'FET' ORDER BY dtmEffectiveDate DESC)
, FETGLAccount			= '00000000'
, EFTonFET				= 'N'
, SETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SET' ORDER BY dtmEffectiveDate DESC) 
, SETGLAccount			= '00000000'--tblGLAccount.strAccountId
, EFTonSET				= 'N'
, SSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' ORDER BY dtmEffectiveDate DESC)	
, SSTGLAccount			= '00000000'
, SSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' ORDER BY dtmEffectiveDate DESC) 
, SSTOnFET				= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'FET'
	), 'N')
) 
, SSTOnSET				= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'SET'
	), 'N')
) 
, EFTOnSST				= 'N'
, PSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' ORDER BY dtmEffectiveDate DESC)	
, PSTGLAccount			= '00000000'
, PSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' ORDER BY dtmEffectiveDate DESC) 
, Locale1Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1') 
, Locale1Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1' ORDER BY dtmEffectiveDate DESC)	
, Locale1GLAccount		= '00000000'
, Locale1Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1' ORDER BY dtmEffectiveDate DESC)
, Locale1EFT			= 'N'
, Locale1SSTOnLC1		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC1'
	), 'N')
) 
, Locale1LC1OnFET		= 'N'
, Locale2Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2') 
, Locale2Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2' ORDER BY dtmEffectiveDate DESC) 
, Locale2GLAccount		= '00000000'
, Locale2Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2' ORDER BY dtmEffectiveDate DESC) 
, Locale2EFT			= 'N'
, Locale2SSTOnLC2		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC2'
	), 'N')
) 
, Locale2LC2OnFET		= 'N'	
, Locale3Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3') 
, Locale3Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3' ORDER BY dtmEffectiveDate DESC)	
, Locale3GLAccount		= '00000000'	
, Locale3Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3' ORDER BY dtmEffectiveDate DESC) 	
, Locale3EFT			= 'N'
, Locale3SSTOnLC3		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC3'
	), 'N')
)  	
, Locale3LC3OnFET		= 'N'
, Locale4Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4') 
, Locale4Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4' ORDER BY dtmEffectiveDate DESC) 
, Locale4GLAccount		= '00000000'
, Locale4Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4' ORDER BY dtmEffectiveDate DESC) 
, Locale4EFT			= 'N'	
, Locale4SSTOnLC4		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC4'
	), 'N')
) 
, Locale4LC4OnFET		= 'N'	
, Locale5Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5') 	
, Locale5Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5' ORDER BY dtmEffectiveDate DESC)	 
, Locale5GLAccount		= '00000000'
, Locale5Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5' ORDER BY dtmEffectiveDate DESC) 
, Locale5EFT			= 'N'	
, Locale5SSTOnLC5		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC5'
	), 'N')
) 	
, Locale5LC5OnFET		= 'N'	
, Locale6Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6') 	
, Locale6Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6' ORDER BY dtmEffectiveDate DESC)	 
, Locale6GLAccount		= '00000000'	
, Locale6Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6' ORDER BY dtmEffectiveDate DESC) 
, Locale6EFT			= 'N'	
, Locale6SSTOnLC6		= 
(
	ISNULL(
	(
		SELECT c.strTaxCodeReference
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId 
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' AND c.strTaxCodeReference = 'LC6'
	), 'N')
) 
, Locale6LC6OnFET		= 'N'
FROM tblICItem Item 
INNER JOIN tblICCategory Category ON Item.intCategoryId = Category.intCategoryId
INNER JOIN tblICCategoryTax CategoryTax ON Category.intCategoryId = CategoryTax.intCategoryId
INNER JOIN tblSMTaxCode TaxCode ON CategoryTax.intTaxClassId = TaxCode.intTaxClassId
INNER JOIN tblSMTaxCodeRate TaxCodeRate ON TaxCode.intTaxCodeId = TaxCodeRate.intTaxCodeId
INNER JOIN tblETExportTaxCodeMapping ExportTaxCodeMapping ON TaxCode.intTaxCodeId = ExportTaxCodeMapping.intTaxCodeId
INNER JOIN tblSMTaxGroupCode TaxGroupCode ON TaxCode.intTaxCodeId = TaxGroupCode.intTaxCodeId 
INNER JOIN tblETExportFilterTaxGroup ExportFilterTaxGroup ON TaxGroupCode.intTaxGroupId = ExportFilterTaxGroup.intTaxGroupId
INNER JOIN tblSMTaxGroup TaxGroup ON ExportFilterTaxGroup.intTaxGroupId = TaxGroup.intTaxGroupId