
CREATE VIEW vyuFALastDepDate
AS
WITH GetLatestDepDate AS(
SELECT A.intAssetId,  dtmDepreciationToDate , ROW_NUMBER() OVER (PARTITION BY A.intAssetId ORDER BY dtmDepreciationToDate DESC ) rowId
    FROM tblFAFixedAssetDepreciation A JOIN
    tblFAFixedAsset B ON A.intAssetId = B.intAssetId
)
SELECT intAssetId,dtmDepreciationToDate FROM GetLatestDepDate WHERE rowId = 1

