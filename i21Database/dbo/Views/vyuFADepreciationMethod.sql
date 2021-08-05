CREATE VIEW  vyuFADepreciationMethod
AS
SELECT A.* ,
CAST(ISNULL(U.ysnHasDepreciatedAsset , 0) AS BIT) ysnHasDepreciatedAsset
FROM 
tblFADepreciationMethod A
-- SHOWS IF DM WAS ALREADY USED TO DEPRECIATE ASSET
OUTER APPLY(
    SELECT TOP 1 1 ysnHasDepreciatedAsset FROM 
    tblFAFixedAsset  FA 
    JOIN tblFABookDepreciation BD ON BD.intAssetId = FA.intAssetId
    JOIN tblFADepreciationMethod DM ON DM.intDepreciationMethodId = BD.intDepreciationMethodId
    WHERE BD.intDepreciationMethodId = A.intDepreciationMethodId 
    AND (ISNULL(FA.ysnDepreciated,0) = 1 OR ISNULL(ysnTaxDepreciated,0) = 1)
)U