CREATE FUNCTION [dbo].[fnFAValidateAssetDepreciation]
 (
	@ysnPost   AS BIT    = 0,
	@BookId INT =1 ,
	@Id Id READONLY

)
RETURNS @tbl TABLE (
	intAssetId INT,
	strError NVARCHAR(400) NULL
)
AS
BEGIN
-- for existing depreciation
    

    IF (@ysnPost = 1 )
    BEGIN
        INSERT INTO @tbl
        SELECT  intAssetId, 'Asset was already disposed.' FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        WHERE  ISNULL(ysnDisposed, 0) = 1

        INSERT INTO @tbl
        SELECT  intAssetId, 'Asset cost should be greater than zero.' FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        WHERE  ISNULL(dblCost, 0) = 0

        INSERT INTO @tbl
        SELECT  intAssetId, 'Salvage value should be less than asset cost.' FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        WHERE  ISNULL(dblSalvageValue, 0) > 0 AND  ISNULL(dblSalvageValue, 0) >= ISNULL(dblCost, 0) 

        IF EXISTS(SELECT TOP 1 1 FROM @tbl)
            RETURN

        INSERT INTO @tbl
        SELECT A.intAssetId, 'Asset already fully depreciated.' FROM tblFAFixedAsset A 
        JOIN @Id I on I.intId =  A.intAssetId
        JOIN tblFABookDepreciation BD ON BD.intAssetId = A.intAssetId AND BD.intBookId = @BookId
        OUTER APPLY(
            SELECT TOP 1 ROUND(dblDepreciationToDate,2) dblDepreciationToDate, dtmDepreciationToDate 
            FROM tblFAFixedAssetDepreciation WHERE intAssetId = I.intId and ISNULL(intBookId,1) = @BookId
            ORDER BY dtmDepreciationToDate DESC
        )D
		OUTER APPLY(
			SELECT ISNULL(SUM(BA.dblAdjustment), 0) dblAdjustment
			FROM tblFABasisAdjustment BA
			WHERE BA.intAssetId = A.intAssetId AND BA.intBookId = @BookId AND BA.dtmDate <= D.dtmDepreciationToDate AND BA.strAdjustmentType = 'Basis'
		) Adjustment
        WHERE 
			((CASE WHEN Adjustment.dblAdjustment IS NULL
				THEN CASE WHEN D.dblDepreciationToDate >= ISNULL(BD.dblCost,0) - ISNULL(BD.dblSalvageValue,0) THEN 1 ELSE 0 END
				ELSE CASE WHEN (D.dblDepreciationToDate) >= ISNULL(BD.dblCost,0) - ISNULL(BD.dblSalvageValue,0) + Adjustment.dblAdjustment THEN 1 ELSE 0 END 
			 END) = 1
        OR  ISNULL(BD.ysnFullyDepreciated,0) = 1 )
        AND ISNULL(A.ysnDisposed, 0) = 0

        IF EXISTS(SELECT TOP 1 1 FROM @tbl)
            RETURN

        INSERT INTO @tbl
        SELECT A.intId, 'Missing Depreciation Method' FROM @Id A 
        LEFT JOIN tblFABookDepreciation BD on BD.intAssetId = A.intId AND BD.intBookId= @BookId
        WHERE BD.intAssetId IS NULL

        INSERT INTO @tbl
        SELECT 
        intId,  'Next Depreciation Date is on a closed period in this asset.'
        FROM @Id I 
            CROSS APPLY(
                SELECT TOP 1 dbo.fnFAGetNextDepreciationDate(intAssetId, intBookId) nextDate
                FROM tblFAFixedAssetDepreciation WHERE [intAssetId] =I.intId AND ISNULL(intBookId,1) = @BookId
                AND strTransaction = 'Depreciation'
                AND dtmDepreciationToDate IS NOT NULL
                ORDER BY intAssetDepreciationId DESC
            )Depreciation
            OUTER APPLY(
                SELECT ISNULL([dbo].isOpenAccountingDate(Depreciation.nextDate), 0)  isOpenAccountingDate
            ) FiscalPeriod
             OUTER APPLY(
                select dbo.isOpenAccountingDateByModule(Depreciation.nextDate,'Fixed Assets') isOpenAccountingDate
            ) FixedAssetPeriod
            WHERE FiscalPeriod.isOpenAccountingDate = 0  OR FixedAssetPeriod.isOpenAccountingDate = 0
    END
   RETURN
END