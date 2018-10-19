CREATE VIEW [dbo].[vyuSMETExportFullTax]
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
, ISNULL(MAX(Locale7Description), 'Locale 7 Tax') AS Locale7Description
, CASE WHEN ISNULL(MAX(Locale7Method), 'U') = 'U' THEN ISNULL(MAX(Locale7Rate), 0.000000) ELSE ISNULL(MAX(Locale7Rate), 0.000000) / 100 END AS Locale7Rate
, Locale7GLAccount
, ISNULL(MAX(Locale7Method), 'U') AS Locale7Method
, Locale7EFT
, ISNULL(MAX(Locale7SSTOnLC7), 'N') AS Locale7SSTOnLC7
, Locale7LC7OnFET
, ISNULL(MAX(Locale8Description), 'Locale 8 Tax') AS Locale8Description
, CASE WHEN ISNULL(MAX(Locale8Method), 'U') = 'U' THEN ISNULL(MAX(Locale8Rate), 0.000000) ELSE ISNULL(MAX(Locale8Rate), 0.000000) / 100 END AS Locale8Rate
, Locale8GLAccount
, ISNULL(MAX(Locale8Method), 'U') AS Locale8Method
, Locale8EFT
, ISNULL(MAX(Locale8SSTOnLC8), 'N') AS Locale8SSTOnLC8
, Locale8LC8OnFET
, ISNULL(MAX(Locale9Description), 'Locale 9 Tax') AS Locale9Description
, CASE WHEN ISNULL(MAX(Locale9Method), 'U') = 'U' THEN ISNULL(MAX(Locale9Rate), 0.000000) ELSE ISNULL(MAX(Locale9Rate), 0.000000) / 100 END AS Locale9Rate
, Locale9GLAccount
, ISNULL(MAX(Locale9Method), 'U') AS Locale9Method
, Locale9EFT
, ISNULL(MAX(Locale9SSTOnLC9), 'N') AS Locale9SSTOnLC9
, Locale9LC9OnFET
, ISNULL(MAX(Locale10Description), 'Locale 10 Tax') AS Locale10Description
, CASE WHEN ISNULL(MAX(Locale10Method), 'U') = 'U' THEN ISNULL(MAX(Locale10Rate), 0.000000) ELSE ISNULL(MAX(Locale10Rate), 0.000000) / 100 END AS Locale10Rate
, Locale10GLAccount
, ISNULL(MAX(Locale10Method), 'U') AS Locale10Method
, Locale10EFT
, ISNULL(MAX(Locale10SSTOnLC10), 'N') AS Locale10SSTOnLC10
, Locale10LC10OnFET
, ISNULL(MAX(Locale11Description), 'Locale 11 Tax') AS Locale11Description
, CASE WHEN ISNULL(MAX(Locale11Method), 'U') = 'U' THEN ISNULL(MAX(Locale11Rate), 0.000000) ELSE ISNULL(MAX(Locale11Rate), 0.000000) / 110 END AS Locale11Rate
, Locale11GLAccount
, ISNULL(MAX(Locale11Method), 'U') AS Locale11Method
, Locale11EFT
, ISNULL(MAX(Locale11SSTOnLC11), 'N') AS Locale11SSTOnLC11
, Locale11LC11OnFET
, ISNULL(MAX(Locale12Description), 'Locale 12 Tax') AS Locale12Description
, CASE WHEN ISNULL(MAX(Locale12Method), 'U') = 'U' THEN ISNULL(MAX(Locale12Rate), 0.000000) ELSE ISNULL(MAX(Locale12Rate), 0.000000) / 120 END AS Locale12Rate
, Locale12GLAccount
, ISNULL(MAX(Locale12Method), 'U') AS Locale12Method
, Locale12EFT
, ISNULL(MAX(Locale12SSTOnLC12), 'N') AS Locale12SSTOnLC12
, Locale12LC12OnFET
,MAX(FETTaxCodeId) FETTaxCodeId
,MAX(SETTaxCodeId) SETTaxCodeId
,MAX(SSTTaxCodeId) SSTTaxCodeId
,MAX(PSTTaxCodeId) PSTTaxCodeId
,MAX(Locale1TaxCodeId) Locale1TaxCodeId
,MAX(Locale2TaxCodeId) Locale2TaxCodeId
,MAX(Locale3TaxCodeId) Locale3TaxCodeId
,MAX(Locale4TaxCodeId) Locale4TaxCodeId
,MAX(Locale5TaxCodeId) Locale5TaxCodeId
,MAX(Locale6TaxCodeId) Locale6TaxCodeId
,MAX(Locale7TaxCodeId) Locale7TaxCodeId
,MAX(Locale8TaxCodeId) Locale8TaxCodeId
,MAX(Locale9TaxCodeId) Locale9TaxCodeId
,MAX(Locale10TaxCodeId) Locale10TaxCodeId
,MAX(Locale11TaxCodeId) Locale11TaxCodeId
,MAX(Locale12TaxCodeId) Locale12TaxCodeId
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
	, FETTaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'FET')
	, FETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'FET' 
								AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
								ORDER BY dtmEffectiveDate DESC)
	, FETGLAccount			= '00000000'
	, EFTonFET				= 'N'
	, SETTaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SET')
	, SETRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SET' 
							AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, SETGLAccount			= '00000000'--tblGLAccount.strAccountId
	, EFTonSET				= 'N'
	, SSTTaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST')
	, SSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'SST' 
						AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, SSTGLAccount			= '00000000'
	, SSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
								FROM tblSMTaxCodeRate a 
								WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
								AND ExportTaxCodeMapping.strTaxCodeReference = 'SST'
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
	, PSTTaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST')
	, PSTRatePerUnit		= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a 
								WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' 
								AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
								ORDER BY dtmEffectiveDate DESC )
	, PSTGLAccount			= '00000000'
	, PSTMethod				= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'PST' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale1TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC1')
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
	, Locale2TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC2')
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
	, Locale3TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC3')
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
	, Locale4TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC4')
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
	, Locale5TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC5')
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
	, Locale6TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC6')
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
	, Locale7TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC7')
	, Locale7Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC7')
    , Locale7Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC7' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale7GLAccount		= '00000000'	
	, Locale7Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC7' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale7EFT			= 'N'	
	, Locale7SSTOnLC7		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC7'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale7LC7OnFET		= 'N'
	, Locale8TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC8')
	, Locale8Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC8')
    , Locale8Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC8' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale8GLAccount		= '00000000'	
	, Locale8Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC8' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale8EFT			= 'N'	
	, Locale8SSTOnLC8		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC8'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale8LC8OnFET		= 'N'
	, Locale9TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC9')
	, Locale9Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC9')
    , Locale9Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC9' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale9GLAccount		= '00000000'	
	, Locale9Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC9' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale9EFT			= 'N'	
	, Locale9SSTOnLC9		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC9'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale9LC9OnFET		= 'N'
	, Locale10TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC10')
	, Locale10Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC10')
    , Locale10Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC10' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale10GLAccount		= '00000000'	
	, Locale10Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC10' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale10EFT			= 'N'	
	, Locale10SSTOnLC10		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC10'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale10LC10OnFET		= 'N'
	, Locale11TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC11')
	, Locale11Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC11')
    , Locale11Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC11' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale11GLAccount		= '00000000'	
	, Locale11Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC11' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale11EFT			= 'N'	
	, Locale11SSTOnLC11		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC11'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale11LC11OnFET		= 'N'
	, Locale12TaxCodeId	= (SELECT intTaxCodeId FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC12')
	, Locale12Description	= (SELECT strDescription FROM tblSMTaxCode WHERE intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC12')
    , Locale12Rate			= (SELECT TOP 1 dblRate FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC12' 
	AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) ORDER BY dtmEffectiveDate DESC)
	, Locale12GLAccount		= '00000000'	
	, Locale12Method			= (SELECT TOP 1 CASE ISNULL(strCalculationMethod, 'Percentage') WHEN 'Percentage' THEN 'P' ELSE 'U' END 
	                           FROM tblSMTaxCodeRate a WHERE a.intTaxCodeId = TaxCode.intTaxCodeId AND ExportTaxCodeMapping.strTaxCodeReference = 'LC12' 
							   AND  CAST(dtmEffectiveDate  AS DATE) <= CAST(GETDATE() AS DATE) 
							   ORDER BY dtmEffectiveDate DESC)
	, Locale12EFT			= 'N'	
	, Locale12SSTOnLC12		= 
	(
		SELECT TOP 1 'Y'
		FROM tblSMTaxCode a 
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblETExportTaxCodeMapping c ON b.intID = c.intTaxCodeId AND c.strTaxCodeReference = 'SST' 
		INNER JOIN tblETExportTaxCodeMapping d ON a.intTaxCodeId = d.intTaxCodeId AND d.strTaxCodeReference = 'LC12'
		INNER JOIN tblSMTaxGroupCode aG ON b.intID = aG.intTaxCodeId
		WHERE a.intTaxCodeId = TaxCode.intTaxCodeId 
		AND aG.intTaxGroupId = TaxGroup.intTaxGroupId
	)
	, Locale12LC12OnFET		= 'N'
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
Locale3EFT, Locale3LC3OnFET, Locale4GLAccount, Locale4EFT, Locale4LC4OnFET, Locale5GLAccount, Locale5EFT, Locale5LC5OnFET, Locale6GLAccount, Locale6EFT, Locale6LC6OnFET,
Locale7GLAccount, Locale7EFT, Locale7LC7OnFET, Locale8GLAccount, Locale8EFT, Locale8LC8OnFET, Locale9GLAccount, Locale9EFT, Locale9LC9OnFET, Locale10GLAccount, Locale10EFT, Locale10LC10OnFET,
Locale11GLAccount, Locale11EFT, Locale11LC11OnFET, Locale12GLAccount, Locale12EFT, Locale12LC12OnFET