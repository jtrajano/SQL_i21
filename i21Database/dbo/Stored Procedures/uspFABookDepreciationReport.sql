CREATE PROCEDURE [dbo].[uspFABookDepreciationReport]
	@intFiscalPeriodId INT,
	@intBookIdLeft INT,
	@intBookIdRight INT,
    @intEntityId INT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRANSACTION;
DECLARE @strErrorMessage NVARCHAR(MAX)

BEGIN TRY
    -- Remove existing records
    DELETE tblFABookDepreciationReport WHERE intEntityId = @intEntityId
    
    INSERT INTO tblFABookDepreciationReport (
         [intAssetId]
       , [intEntityId]
       , [intFiscalPeriodId]
       , [intLedgerIdLeft]
       , [intTotalDepreciatedLeft]
       , [intTotalDepreciationLeft]
       , [intDepreciationMethodIdLeft]
       , [dblCostLeft]
       , [dblSalvageValueLeft]
       , [dblBonusDepreciationLeft]
       , [dblSection179Left]
       , [dblDepreciationCurrentMonthLeft]
       , [dblDepreciationYTDLeft]
       , [dblDepreciationLTDLeft]
       , [intLedgerIdRight]
       , [intTotalDepreciatedRight]
       , [intTotalDepreciationRight]
       , [intDepreciationMethodIdRight]
       , [dblCostRight]
       , [dblSalvageValueRight]
       , [dblBonusDepreciationRight]
       , [dblSection179Right]
       , [dblDepreciationCurrentMonthRight]
       , [dblDepreciationYTDRight]
       , [dblDepreciationLTDRight]
       , [dblDifferenceMTD]
       , [dblDifferenceYTD]
       , [dblDifferenceLTD]
    )
	SELECT      
          intAssetId = FA.intAssetId
        , intEntityId = @intEntityId
        , intFiscalPeriodId = FYP.intGLFiscalYearPeriodId

        -- Left Book
        , intLedgerIdLeft = LeftBookDepreciation.intLedgerId
        , intTotalDepreciatedLeft = ISNULL(LeftBookDepCnt.intDepreciationCount, 0)
        , intTotalDepreciationLeft = ISNULL((LeftBookDepreciation.intServiceYear * 12 + LeftBookDepreciation.intMonth), 0)
        , intDepreciationMethodIdLeft = LeftBookDepreciation.intDepreciationMethodId
        , dblCostLeft = ISNULL(LeftBookDepreciation.dblCost, 0)
        , dblSalvageValueLeft = ISNULL(LeftBookDepreciation.dblSalvageValue, 0)
        , dblBonusDepreciationLeft = ISNULL(LeftBookDepreciation.dblBonusDepreciation, 0)
        , dblSection179Left = ISNULL(LeftBookDepreciation.dblSection179, 0)
        , dblDepreciationCurrentMonthLeft = ISNULL(LeftBookDepreciationCurrentMonth.dblDepreciationToDate, 0)
        , dblDepreciationYTDLeft = ISNULL(LeftBookDepreciationYTD.dblDepreciationYTD, 0)
        , dblDepreciationLTDLeft = ISNULL(LeftBookDepreciationLTD.dblDepreciationLTD, 0)

        -- Right Book
        , intLedgerRightId = RightBookDepreciation.intLedgerId
        , intTotalDepreciatedRight = ISNULL(RightBookDepCnt.intDepreciationCount, 0)
        , intTotalDepreciationRight = ISNULL((RightBookDepreciation.intServiceYear * 12 + RightBookDepreciation.intMonth), 0)
        , intDepreciationMethodIdRight = RightBookDepreciation.intDepreciationMethodId
        , dblCostRight = ISNULL(RightBookDepreciation.dblCost, 0)
        , dblSalvageValueRight = ISNULL(RightBookDepreciation.dblSalvageValue, 0)
        , dblBonusDepreciationRight = ISNULL(RightBookDepreciation.dblBonusDepreciation, 0)
        , dblSection179Right = ISNULL(RightBookDepreciation.dblSection179, 0)
        , dblDepreciationCurrentMonthRight = ISNULL(RightBookDepreciationCurrentMonth.dblDepreciationToDate, 0)
        , dblDepreciationYTDRight = ISNULL(RightBookDepreciationYTD.dblDepreciationYTD, 0)
        , dblDepreciationLTDRight = ISNULL(RightBookDepreciationLTD.dblDepreciationLTD, 0)

        -- MTD, LTD AND YTD
	    , dblDifferenceMTD = (ISNULL(RightBookDepreciationCurrentMonth.dblDepreciationToDate, 0) - ISNULL(LeftBookDepreciationCurrentMonth.dblDepreciationToDate, 0))
	    , dblDifferenceYTD = (ISNULL(RightBookDepreciationYTD.dblDepreciationYTD, 0) - ISNULL(LeftBookDepreciationYTD.dblDepreciationYTD, 0))
	    , dblDifferenceLTD = (ISNULL(RightBookDepreciationLTD.dblDepreciationLTD, 0) - ISNULL(LeftBookDepreciationLTD.dblDepreciationLTD, 0))

    FROM tblFAFixedAsset FA
	    JOIN tblFAFixedAssetDepreciation FAD ON FA.intAssetId = FAD.intAssetId
        LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId        
        LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId        
        LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId        
        LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = FA.intAssetGroupId
        CROSS JOIN tblGLFiscalYearPeriod FYP
        OUTER APPLY (
	        SELECT intDepreciationCount = ISNULL(COUNT(1), 0)
            FROM tblFAFixedAssetDepreciation 
	        WHERE intAssetId = FA.intAssetId AND intBookId = @intBookIdLeft AND strTransaction IN ('Depreciation', 'Imported')
        ) LeftBookDepCnt
        OUTER APPLY (
	        SELECT intDepreciationCount = ISNULL(COUNT(1), 0)
            FROM tblFAFixedAssetDepreciation 
	        WHERE intAssetId = FA.intAssetId AND intBookId = @intBookIdRight AND strTransaction IN ('Depreciation', 'Imported')
        ) RightBookDepCnt
         OUTER APPLY(  
            SELECT BD.dblCost, BD.dblSalvageValue, DM.strDepreciationMethodId, DM.intServiceYear, DM.intMonth, DM.intDepreciationMethodId, BD.dblBonusDepreciation, BD.dblSection179, BD.intLedgerId
            FROM tblFABookDepreciation BD
		    JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
	        WHERE BD.intAssetId = FA.intAssetId AND BD.intBookId = @intBookIdLeft
        ) LeftBookDepreciation
        OUTER APPLY(  
            SELECT BD.dblCost, BD.dblSalvageValue, DM.strDepreciationMethodId, DM.intServiceYear, DM.intMonth, DM.intDepreciationMethodId, BD.dblBonusDepreciation, BD.dblSection179, BD.intLedgerId
            FROM tblFABookDepreciation BD
		    JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
	        WHERE BD.intAssetId = FA.intAssetId AND BD.intBookId = @intBookIdRight
        ) RightBookDepreciation
        OUTER APPLY (
            SELECT ISNULL(FAD.dblDepreciation, 0) dblDepreciationToDate
            FROM tblFAFixedAssetDepreciation FAD
            WHERE 
		        FAD.intAssetId = FA.intAssetId 
                AND FAD.intBookId = @intBookIdLeft
                AND FAD.dtmDepreciationToDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
        ) LeftBookDepreciationCurrentMonth
        OUTER APPLY (
            SELECT ISNULL(FAD.dblDepreciation, 0) dblDepreciationToDate
            FROM tblFAFixedAssetDepreciation FAD
            WHERE 
		        FAD.intAssetId = FA.intAssetId 
                AND FAD.intBookId = @intBookIdRight
                AND FAD.dtmDepreciationToDate BETWEEN FYP.dtmStartDate AND FYP.dtmEndDate
        ) RightBookDepreciationCurrentMonth
        OUTER APPLY (
            --SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, @intBookIdLeft, FY.dtmDateFrom, FYP.dtmEndDate, 1) dblDepreciationYTD
            SELECT SUM(ISNULL(FAD.dblDepreciation, 0)) dblDepreciationYTD
	        FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYear FY
	        WHERE FAD.intAssetId = FA.intAssetId 
            AND FAD.intBookId = @intBookIdLeft
            AND FY.intFiscalYearId = FYP.intFiscalYearId
	        AND FAD.dtmDepreciationToDate BETWEEN FY.dtmDateFrom AND FYP.dtmEndDate
        ) LeftBookDepreciationYTD
        OUTER APPLY (
            --SELECT dbo.fnFAGetSumDepreciationCMAndYTD(FAD.intAssetId, @intBookIdRight, FY.dtmDateFrom, FYP.dtmEndDate, 1) dblDepreciationYTD
            SELECT SUM(ISNULL(FAD.dblDepreciation, 0)) dblDepreciationYTD
	        FROM tblFAFixedAssetDepreciation FAD, tblGLFiscalYear FY
	        WHERE FAD.intAssetId = FA.intAssetId 
            AND FAD.intBookId = @intBookIdRight
            AND FY.intFiscalYearId = FYP.intFiscalYearId
	        AND FAD.dtmDepreciationToDate BETWEEN FY.dtmDateFrom AND FYP.dtmEndDate
        ) RightBookDepreciationYTD
        OUTER APPLY (
            SELECT SUM(ISNULL(FAD.dblDepreciation, 0)) dblDepreciationLTD
	        FROM tblFAFixedAssetDepreciation FAD
	        WHERE FAD.intAssetId = FA.intAssetId
			    AND FAD.intBookId = @intBookIdLeft 
			    AND FAD.dtmDepreciationToDate BETWEEN FAD.dtmDateInService AND FYP.dtmEndDate 
        ) LeftBookDepreciationLTD
        OUTER APPLY (
            SELECT SUM(ISNULL(FAD.dblDepreciation, 0)) dblDepreciationLTD
	        FROM tblFAFixedAssetDepreciation FAD
	        WHERE FAD.intAssetId = FA.intAssetId 
			    AND FAD.intBookId = @intBookIdRight 
			    AND FAD.dtmDepreciationToDate BETWEEN FAD.dtmDateInService AND FYP.dtmEndDate 
        ) RightBookDepreciationLTD

    WHERE
	    FAD.strTransaction IN ('Depreciation', 'Imported')
        AND FYP.intGLFiscalYearPeriodId = @intFiscalPeriodId
        AND FAD.intBookId IN (@intBookIdLeft, @intBookIdRight)

    GROUP BY 
          FYP.intGLFiscalYearPeriodId
        , FA.intAssetId
        , FA.strAssetId
        , FA.strAssetDescription
        , FA.strSerialNumber
        , FA.strNotes
        , FA.dtmDateAcquired
        , FA.intAssetAccountId
        , FA.intDepreciationAccountId
        , FA.dtmDateInService
        , AssetGroup.intAssetGroupId
        , AssetGroup.strGroupCode
        , AssetGroup.strGroupDescription
        , GLAsset.strAccountId
        , GLDepreciation.strAccountId
        , Company.strLocationName
        , LeftBookDepCnt.intDepreciationCount
        , RightBookDepCnt.intDepreciationCount
        , LeftBookDepreciation.intLedgerId
        , RightBookDepreciation.intLedgerId
        , LeftBookDepreciationCurrentMonth.dblDepreciationToDate
        , LeftBookDepreciationYTD.dblDepreciationYTD
        , LeftBookDepreciationLTD.dblDepreciationLTD
        , RightBookDepreciationCurrentMonth.dblDepreciationToDate
        , RightBookDepreciationYTD.dblDepreciationYTD
        , RightBookDepreciationLTD.dblDepreciationLTD
        , LeftBookDepreciation.intDepreciationMethodId
        , LeftBookDepreciation.intServiceYear
        , LeftBookDepreciation.intMonth
        , LeftBookDepreciation.dblCost
        , LeftBookDepreciation.dblSalvageValue
        , LeftBookDepreciation.dblBonusDepreciation
        , LeftBookDepreciation.dblSection179
        , RightBookDepreciation.intDepreciationMethodId
        , RightBookDepreciation.intServiceYear
        , RightBookDepreciation.intMonth
        , RightBookDepreciation.dblCost
        , RightBookDepreciation.dblSalvageValue
        , RightBookDepreciation.dblBonusDepreciation
        , RightBookDepreciation.dblSection179
    ORDER BY
        FA.intAssetId DESC

END TRY
BEGIN CATCH
    SET @strErrorMessage = @@ERROR
    GOTO Post_Rollback;
END CATCH


Post_Commit:
	COMMIT TRANSACTION;
	GOTO Post_Exit

Post_Rollback:
    RAISERROR(@strErrorMessage, 16, 1);
	ROLLBACK TRANSACTION;
	GOTO Post_Exit

Post_Exit:

