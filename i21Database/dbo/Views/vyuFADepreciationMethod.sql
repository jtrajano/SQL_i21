CREATE VIEW  vyuFADepreciationMethod
AS
SELECT A.* ,
CAST(ISNULL(U.ysnHasDepreciatedAsset , 0) AS BIT) ysnHasDepreciatedAsset
FROM 
tblFADepreciationMethod A
-- SHOWS IF DM WAS ALREADY USED TO DEPRECIATE ASSET
OUTER APPLY(
    SELECT TOP 1 1 ysnHasDepreciatedAsset FROM 
    tblFAFixedAsset WHERE intDepreciationMethodId = A.intDepreciationMethodId 
    AND (ysnDepreciated = 1 OR ysnTaxDepreciated = 1)
)U