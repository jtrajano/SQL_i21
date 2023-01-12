CREATE FUNCTION [dbo].[fnFAValidateMultipleBooks]
 (
	@Id Id READONLY,
	@ysnPost AS BIT = 0
)
RETURNS @tbl TABLE (
	intAssetId INT,
    intBookDepreciationId INT NULL,
	strError NVARCHAR(MAX) NULL
)
AS
BEGIN
    IF (@ysnPost = 1 )
    BEGIN
        INSERT INTO @tbl
        SELECT A.intId, BD.intBookDepreciationId, 'Missing Depreciation Method'
        FROM @Id A 
        LEFT JOIN tblFABookDepreciation BD on BD.intAssetId = A.intId
        WHERE BD.intAssetId IS NULL

        INSERT INTO @tbl
        SELECT  A.intAssetId, BD.intBookDepreciationId, 'Asset was already disposed.'
        FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId
        WHERE  ISNULL(ysnDisposed, 0) = 1

        INSERT INTO @tbl
        SELECT A.intAssetId, BD.intBookDepreciationId, 'Asset cost should be greater than zero.'
        FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId
        WHERE  ISNULL(BD.dblCost, 0) = 0

        INSERT INTO @tbl
        SELECT A.intAssetId, BD.intBookDepreciationId, 'Salvage value should be less than asset cost.'
        FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId
        WHERE ISNULL(BD.dblSalvageValue, 0) > 0 AND  ISNULL(BD.dblSalvageValue, 0) >= ISNULL(BD.dblCost, 0) 
        
        -- Do no proceed further validations
        IF EXISTS(SELECT TOP 1 1 FROM @tbl)
            RETURN

        INSERT INTO @tbl
        SELECT A.intAssetId, BD.intBookDepreciationId, 'Asset already fully depreciated.'
        FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId
        OUTER APPLY(
            SELECT TOP 1 ROUND(dblDepreciationToDate, 2) dblDepreciationToDate, dtmDepreciationToDate 
            FROM tblFAFixedAssetDepreciation 
            WHERE intAssetId = I.intId AND intBookDepreciationId = BD.intBookDepreciationId
            ORDER BY dtmDepreciationToDate DESC
        ) D
		OUTER APPLY(
			SELECT ISNULL(SUM(BA.dblAdjustment), 0) dblAdjustment
			FROM tblFABasisAdjustment BA
			WHERE BA.intAssetId = A.intAssetId AND BA.intBookId = BD.intBookId AND BA.dtmDate <= D.dtmDepreciationToDate AND BA.strAdjustmentType = 'Basis'
		) Adjustment
        WHERE 
			((CASE WHEN Adjustment.dblAdjustment IS NULL
				THEN CASE WHEN D.dblDepreciationToDate >= ISNULL(BD.dblCost, 0) - ISNULL(BD.dblSalvageValue, 0) THEN 1 ELSE 0 END
				ELSE CASE WHEN (D.dblDepreciationToDate) >= ISNULL(BD.dblCost, 0) - ISNULL(BD.dblSalvageValue, 0) + Adjustment.dblAdjustment THEN 1 ELSE 0 END 
			 END) = 1
        OR ISNULL(BD.ysnFullyDepreciated, 0) = 1 )
        AND ISNULL(A.ysnDisposed, 0) = 0
        
        -- Do no proceed further validations
        IF EXISTS(SELECT TOP 1 1 FROM @tbl)
            RETURN

        INSERT INTO @tbl
        SELECT intId, BD.intBookDepreciationId, 'Next Depreciation Date is on a closed period in this asset.'
        FROM @Id I 
        JOIN tblFABookDepreciation BD ON BD.intAssetId = I.intId
        CROSS APPLY(
            SELECT TOP 1 dbo.fnFAGetNextDepreciationDate(BD.intAssetId, BD.intBookId, BD.intLedgerId) dtmNextDate
        ) Depreciation
        OUTER APPLY(
            SELECT ISNULL([dbo].isOpenAccountingDate(Depreciation.dtmNextDate), 0)  isOpenAccountingDate
        ) FiscalPeriod
        OUTER APPLY(
            SELECT dbo.isOpenAccountingDateByModule(Depreciation.dtmNextDate,'Fixed Assets') isOpenAccountingDate
        ) FixedAssetPeriod
        WHERE ISNULL(FiscalPeriod.isOpenAccountingDate, 0) = 0 OR ISNULL(FixedAssetPeriod.isOpenAccountingDate, 0) = 0
    END
   RETURN
END