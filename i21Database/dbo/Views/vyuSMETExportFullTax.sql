﻿CREATE VIEW [dbo].[vyuSMETExportFullTax]
AS 

SELECT ItemNumber
, [state]
, Authority1
, Authority1Description
, Authority2
, Authority2Description
, [Description]
, ISNULL(MAX(FETRatePerUnit), 0.000000) AS FETRatePerUnit
, FETGLAccount
, EFTonFET
, ISNULL(MAX(SETRatePerUnit), 0.000000) AS SETRatePerUnit
, SETGLAccount
, EFTonSET
, CASE WHEN ISNULL(MAX(SSTMethod), 'P') = 'U' THEN ISNULL(MAX(SSTRatePerUnit), 0.000000) ELSE ISNULL(MAX(SSTRatePerUnit), 0.000000) / 100 END AS SSTRatePerUnit
, SSTGLAccount
, ISNULL(MAX(SSTMethod), 'P') AS SSTMethod
, ISNULL(MAX(SSTOnFET), 'N') AS SSTOnFET
, ISNULL(MAX(SSTOnSET), 'N') AS SSTOnSET
, EFTOnSST
, CASE WHEN ISNULL(MAX(PSTMethod), 'U') = 'U' THEN ISNULL(MAX(PSTRatePerUnit), 0.000000) ELSE ISNULL(MAX(PSTRatePerUnit), 0.000000) / 100 END AS PSTRatePerUnit
, PSTGLAccount
, ISNULL(MAX(PSTMethod), 'U') AS PSTMethod
, ISNULL(MAX(Locale1Description), 'Locale 1 Tax') AS Locale1Description
, CASE WHEN ISNULL(MAX(Locale1Method), 'U') = 'U' THEN ISNULL(MAX(Locale1Rate), 0.000000) ELSE ISNULL(MAX(Locale1Rate), 0.000000) / 100 END AS Locale1Rate
, Locale1GLAccount
, ISNULL(MAX(Locale1Method), 'U') AS Locale1Method
, Locale1EFT
, ISNULL(MAX(Locale1SSTOnLC1), 'N') AS Locale1SSTOnLC1
, Locale1LC1OnFET
, ISNULL(MAX(Locale2Description), 'Locale 2 Tax') AS Locale2Description
, CASE WHEN ISNULL(MAX(Locale2Method), 'U') = 'U' THEN ISNULL(MAX(Locale2Rate), 0.000000) ELSE ISNULL(MAX(Locale2Rate), 0.000000) / 100 END AS Locale2Rate
, Locale2GLAccount
, ISNULL(MAX(Locale2Method), 'U') AS Locale2Method
, Locale2EFT
, ISNULL(MAX(Locale2SSTOnLC2), 'N') AS Locale2SSTOnLC2
, Locale2LC2OnFET
, ISNULL(MAX(Locale3Description), 'Locale 3 Tax') AS Locale3Description
, CASE WHEN ISNULL(MAX(Locale3Method), 'U') = 'U' THEN ISNULL(MAX(Locale3Rate), 0.000000) ELSE ISNULL(MAX(Locale3Rate), 0.000000) / 100 END AS Locale3Rate
, Locale3GLAccount
, ISNULL(MAX(Locale3Method), 'U') AS Locale3Method
, Locale3EFT
, ISNULL(MAX(Locale3SSTOnLC3), 'N') AS Locale3SSTOnLC3
, Locale3LC3OnFET
, ISNULL(MAX(Locale4Description), 'Locale 4 Tax') AS Locale4Description
, CASE WHEN ISNULL(MAX(Locale4Method), 'U') = 'U' THEN ISNULL(MAX(Locale4Rate), 0.000000) ELSE ISNULL(MAX(Locale4Rate), 0.000000) / 100 END AS Locale4Rate
, Locale4GLAccount
, ISNULL(MAX(Locale4Method), 'U') AS Locale4Method
, Locale4EFT
, ISNULL(MAX(Locale4SSTOnLC4), 'N') AS Locale4SSTOnLC4
, Locale4LC4OnFET
, ISNULL(MAX(Locale5Description), 'Locale 5 Tax') AS Locale5Description
, CASE WHEN ISNULL(MAX(Locale5Method), 'U') = 'U' THEN ISNULL(MAX(Locale5Rate), 0.000000) ELSE ISNULL(MAX(Locale5Rate), 0.000000) / 100 END AS Locale5Rate
, Locale5GLAccount
, ISNULL(MAX(Locale5Method), 'U') AS Locale5Method
, Locale5EFT
, ISNULL(MAX(Locale5SSTOnLC5), 'N') AS Locale5SSTOnLC5
, Locale5LC5OnFET
, ISNULL(MAX(Locale6Description), 'Locale 6 Tax') AS Locale6Description
, CASE WHEN ISNULL(MAX(Locale6Method), 'U') = 'U' THEN ISNULL(MAX(Locale6Rate), 0.000000) ELSE ISNULL(MAX(Locale6Rate), 0.000000) / 100 END AS Locale6Rate
, Locale6GLAccount
, ISNULL(MAX(Locale6Method), 'U') AS Locale6Method
, Locale6EFT
, ISNULL(MAX(Locale6SSTOnLC6), 'N') AS Locale6SSTOnLC6
, Locale6LC6OnFET
FROM
(
	SELECT 
	  ItemNumber			= strItemNo
	, [state]				= LEFT(strTaxGroup, CASE WHEN charindex(' ', strTaxGroup) = 0 THEN LEN(strTaxGroup) ELSE charindex(' ', strTaxGroup) - 1 END)
	, Authority1			= TaxGroup.intTaxGroupId--(substring(strTaxCode,charindex(' ',strTaxCode), CHARINDEX(' ',ltrim(SUBSTRING(strTaxCode,charindex(' ',strTaxCode),LEN(strTaxCode)-charindex(' ',strTaxCode)))) ))
	, Authority1Description	= ''--NULL	
	, Authority2			= ''--NULL--reverse(LEFT(reverse(strTaxCode), CASE WHEN charindex(' ', reverse(strTaxCode)) = 0 THEN LEN(reverse(strTaxCode)) ELSE charindex(' ', reverse(strTaxCode)) - 1 END))
	, Authority2Description	= ''--NULL	
	, [Description]			= TaxGroup.strDescription --tblSMTaxCode.strDescription
	, FETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'FET' 
								AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
								ORDER BY dtmEffectiveDate DESC)
	, FETGLAccount			= '00000000'
	, EFTonFET				= 'N'
	, SETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SET' 
							AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, SETGLAccount			= '00000000'--tblGLAccount.strAccountId
	, EFTonSET				= 'N'
	, SSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' 
						AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, SSTGLAccount			= '00000000'
	, SSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, SSTOnFET				= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'FET'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId		
	)
	, SSTOnSET				= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'SET'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId		
	)
	, EFTOnSST				= 'N'
	, PSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a 
								WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' 
								AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
								ORDER BY dtmEffectiveDate DESC )
	, PSTGLAccount			= '00000000'
	, PSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale1Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1')
	, Locale1Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, Locale1GLAccount		= '00000000'
	, Locale1Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale1EFT			= 'N'
	, Locale1SSTOnLC1		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC1'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale1LC1OnFET		= 'N'
	, Locale2Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2')
	, Locale2Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, Locale2GLAccount		= '00000000'
	, Locale2Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, Locale2EFT			= 'N'
	, Locale2SSTOnLC2		=  
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC2'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale2LC2OnFET		= 'N'	
	, Locale3Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3')
	, Locale3Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale3GLAccount		= '00000000'
	, Locale3Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale3EFT			= 'N'
	, Locale3SSTOnLC3		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC3'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	) 	
	, Locale3LC3OnFET		= 'N'
	, Locale4Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4')
	, Locale4Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale4GLAccount		= '00000000'
	, Locale4Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale4EFT			= 'N'	
	, Locale4SSTOnLC4		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC4'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale4LC4OnFET		= 'N'	
	, Locale5Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5')
	, Locale5Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, Locale5GLAccount		= '00000000'
	, Locale5Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5'
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE)  ORDER BY dtmEffectiveDate DESC)
	, Locale5EFT			= 'N'	
	, Locale5SSTOnLC5		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC5'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale5LC5OnFET		= 'N'	
	, Locale6Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6')
	, Locale6Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale6GLAccount		= '00000000'	
	, Locale6Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale6EFT			= 'N'	
	, Locale6SSTOnLC6		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC6'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale6LC6OnFET		= 'N'
	FROM tblICItem Item 
	INNER JOIN tblICCategory Category ON Item.intCategoryId = Category.intCategoryId AND Item.strStatus = 'Active'
	INNER JOIN tblICCategoryTax CategoryTax ON Category.intCategoryId = CategoryTax.intCategoryId
	INNER JOIN tblSMTaxCode TaxCode ON CategoryTax.intTaxClassId = TaxCode.intTaxClassId
	INNER JOIN tblSMTaxCodeRate TaxCodeRate ON TaxCode.intTaxCodeId = TaxCodeRate.intTaxCodeId
	INNER JOIN tblETExportTaxCodeMapping ExportTaxCodeMapping ON TaxCode.intTaxCodeId = ExportTaxCodeMapping.intTaxCodeId
	INNER JOIN tblSMTaxGroupCode TaxGroupCode ON TaxCode.intTaxCodeId = TaxGroupCode.intTaxCodeId 
	INNER JOIN tblETExportFilterTaxGroup ExportFilterTaxGroup ON TaxGroupCode.intTaxGroupId = ExportFilterTaxGroup.intTaxGroupId
	INNER JOIN tblSMTaxGroup TaxGroup ON ExportFilterTaxGroup.intTaxGroupId = TaxGroup.intTaxGroupId
	WHERE Item.intItemId IN (SELECT intItemId FROM tblETExportFilterItem) OR Category.intCategoryId IN (SELECT intCategoryId FROM tblETExportFilterCategory)
) tbl

GROUP BY ItemNumber, [state], Authority1, Authority1Description, Authority2, Authority2Description, [Description], FETGLAccount, EFTonFET, SETGLAccount, 
EFTonSET, SSTGLAccount, EFTOnSST, PSTGLAccount, Locale1GLAccount, Locale1EFT, Locale1LC1OnFET, Locale2GLAccount, Locale2EFT, Locale2LC2OnFET, Locale3GLAccount, 
Locale3EFT, Locale3LC3OnFET, Locale4GLAccount, Locale4EFT, Locale4LC4OnFET, Locale5GLAccount, Locale5EFT, Locale5LC5OnFET, Locale6GLAccount, Locale6EFT, Locale6LC6OnFET