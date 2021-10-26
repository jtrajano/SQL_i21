CREATE VIEW [dbo].[vyuFABookDepreciationReport]
AS 

SELECT      
    FA.intAssetId,   
    FA.strAssetId,   
    FA.strAssetDescription,  
    FA.strSerialNumber,  
    FA.strNotes,  
    FA.dtmDateAcquired,  
    FA.intAssetAccountId,  
    FA.intDepreciationAccountId,  
    AssetGroup.intAssetGroupId,
    AssetGroup.strGroupCode,
    AssetGroup.strGroupDescription,
    GLAsset.strAccountId strAssetAccountId,        
    GLDepreciation.strAccountId strDepreciationAccountId,        
    Company.strLocationName strCompanyLocation,
    intTotalDepreciated = BookDepCnt.intDepreciationCount,
    intTotalDepreciation = (DM.intServiceYear * 12 + DM.intMonth),
    dblBookDepreciationCurrentMonth = ISNULL(GAAPDepreciationCurrentMonth.dblDepreciationToDate, 0),
    dblBookDepreciationYTD = ISNULL(GAAPDepreciationYTD.dblDepreciationYTD, 0),
    dblBookDepreciationLTD = ISNULL(GAAPDepreciationLTD.dblDepreciationLTD, 0),
    dblTaxDepreciationCurrentMonth = ISNULL(TaxDepreciationCurrentMonth.dblDepreciationToDate, 0),
    dblTaxDepreciationYTD = ISNULL(TaxDepreciationYTD.dblDepreciationYTD, 0),
    dblTaxDepreciationLTD = ISNULL(TaxDepreciationLTD.dblDepreciationLTD, 0),
	dblDifferenceMTD = (ISNULL(TaxDepreciationCurrentMonth.dblDepreciationToDate, 0) - ISNULL(GAAPDepreciationCurrentMonth.dblDepreciationToDate, 0)),
	dblDifferenceYTD = (ISNULL(TaxDepreciationYTD.dblDepreciationYTD, 0) - ISNULL(GAAPDepreciationYTD.dblDepreciationYTD, 0)),
	dblDifferenceLTD = (ISNULL(TaxDepreciationLTD.dblDepreciationLTD, 0) - ISNULL(GAAPDepreciationLTD.dblDepreciationLTD, 0)),
    strBookDepreciationMethod = ISNULL(GAAPBookDepreciation.strDepreciationMethodId, ''),
    dblBookCost = ISNULL(GAAPBookDepreciation.dblCost, 0),
    dblBookSalvageValue = ISNULL(GAAPBookDepreciation.dblSalvageValue, 0),
    strTaxDepreciationMethod = ISNULL(TaxBookDepreciation.strDepreciationMethodId, ''),
    dblTaxCost = ISNULL(TaxBookDepreciation.dblCost, 0),
    dblTaxSalvageValue = ISNULL(TaxBookDepreciation.dblSalvageValue, 0),
    FiscalYear.intGLFiscalYearPeriodId intFiscalPeriodId,
    FA.intConcurrencyId  
FROM 
    tblFAFixedAsset FA
	JOIN tblFAFixedAssetDepreciation FAD ON FA.intAssetId = FAD.intAssetId
    LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId        
    LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId        
    LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId        
    LEFT JOIN tblFADepreciationMethod DM on DM.intDepreciationMethodId = FA.intDepreciationMethodId
    LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = FA.intAssetGroupId
    CROSS JOIN tblGLFiscalYearPeriod FiscalYear

    OUTER APPLY (
	    SELECT intDepreciationCount = ISNULL(COUNT(1), 0) FROM tblFAFixedAssetDepreciation 
	    WHERE intAssetId = FA.intAssetId AND intBookId = 1 AND strTransaction IN ('Depreciation', 'Imported')
    ) BookDepCnt
     OUTER APPLY(  
        SELECT BD.dblCost, BD.dblSalvageValue, DM.strDepreciationMethodId FROM tblFABookDepreciation BD
		 JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
	     WHERE BD.intAssetId = FA.intAssetId AND intBookId = 1
    ) GAAPBookDepreciation
    OUTER APPLY(  
         SELECT BD.dblCost, BD.dblSalvageValue, DM.strDepreciationMethodId FROM tblFABookDepreciation BD
		 JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
	     WHERE BD.intAssetId = FA.intAssetId AND intBookId = 2
    ) TaxBookDepreciation
    OUTER APPLY (
        SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, 1, FY.dtmStartDate, FY.dtmEndDate, 0) dblDepreciationToDate
        FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYearPeriod FY
        WHERE 
		    FAD.intAssetId = FA.intAssetId AND FAD.intBookId = 1 AND 
		    FY.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId AND 
		    FAD.dtmDepreciationToDate BETWEEN FY.dtmStartDate AND FY.dtmEndDate
    ) GAAPDepreciationCurrentMonth
    OUTER APPLY (
        SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, 2, FY.dtmStartDate, FY.dtmEndDate, 0) dblDepreciationToDate
        FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYearPeriod FY
        WHERE 
		    FAD.intAssetId = FA.intAssetId AND FAD.intBookId = 2 AND 
		    FY.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId AND 
		    FAD.dtmDepreciationToDate BETWEEN FY.dtmStartDate AND FY.dtmEndDate
    ) TaxDepreciationCurrentMonth
    OUTER APPLY (
        SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, 1, FY.dtmDateFrom, FYP.dtmEndDate, 1) dblDepreciationYTD
	    FROM tblFAFixedAssetDepreciation FAD
		LEFT JOIN tblGLFiscalYearPeriod FYP ON FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId
		JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = FYP.intFiscalYearId AND FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId
	    WHERE FAD.intAssetId = FA.intAssetId AND FAD.intBookId = 1 AND FiscalYear.intGLFiscalYearPeriodId = FYP.intGLFiscalYearPeriodId
	    AND FAD.dtmDepreciationToDate BETWEEN FY.dtmDateFrom AND FYP.dtmEndDate
    ) GAAPDepreciationYTD
    OUTER APPLY (
        SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, 2, FY.dtmDateFrom, FYP.dtmEndDate, 1) dblDepreciationYTD
	    FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYearPeriod FYP
		JOIN tblGLFiscalYear FY ON FY.intFiscalYearId = FYP.intFiscalYearId AND FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId
	    WHERE FAD.intAssetId = FA.intAssetId AND FAD.intBookId = 2 AND FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId
	    AND FAD.dtmDepreciationToDate BETWEEN FY.dtmDateFrom AND FYP.dtmEndDate
    ) TaxDepreciationYTD
    OUTER APPLY (
        SELECT MAX(FAD.dblDepreciationToDate) dblDepreciationLTD
	    FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYearPeriod FYP
	    WHERE 
			FAD.intAssetId = FA.intAssetId AND 
			FAD.intBookId = 1 AND 
			FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId AND
			FAD.dtmDepreciationToDate BETWEEN FAD.dtmDateInService AND FYP.dtmEndDate 
    ) GAAPDepreciationLTD
    OUTER APPLY (
        SELECT MAX(FAD.dblDepreciationToDate) dblDepreciationLTD
	    FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYearPeriod FYP
	    WHERE 
			FAD.intAssetId = FA.intAssetId AND 
			FAD.intBookId = 2 AND 
			FYP.intGLFiscalYearPeriodId = FiscalYear.intGLFiscalYearPeriodId AND
			FAD.dtmDepreciationToDate BETWEEN FAD.dtmDateInService AND FYP.dtmEndDate 
    ) TaxDepreciationLTD

WHERE
	FAD.strTransaction IN ('Depreciation', 'Imported')

GROUP BY 
    FiscalYear.intGLFiscalYearPeriodId, 
    FA.intAssetId, 
    FA.strAssetId,   
    FA.strAssetDescription,  
    FA.strSerialNumber,  
    FA.strNotes,  
    FA.dtmDateAcquired,  
    FA.intAssetAccountId,  
    FA.intDepreciationAccountId,  
    AssetGroup.intAssetGroupId,
    AssetGroup.strGroupCode,
    AssetGroup.strGroupDescription,
    GLAsset.strAccountId,        
    GLDepreciation.strAccountId,        
    Company.strLocationName,
    BookDepCnt.intDepreciationCount,
    DM.intServiceYear,DM.intMonth,
    GAAPDepreciationCurrentMonth.dblDepreciationToDate,
    GAAPDepreciationYTD.dblDepreciationYTD,
    GAAPDepreciationLTD.dblDepreciationLTD,
    TaxDepreciationCurrentMonth.dblDepreciationToDate,
    TaxDepreciationYTD.dblDepreciationYTD,
    TaxDepreciationLTD.dblDepreciationLTD,
    GAAPBookDepreciation.strDepreciationMethodId,
    GAAPBookDepreciation.dblCost,
    GAAPBookDepreciation.dblSalvageValue,
    TaxBookDepreciation.strDepreciationMethodId,
    TaxBookDepreciation.dblCost,
    TaxBookDepreciation.dblSalvageValue,
    FA.intConcurrencyId
