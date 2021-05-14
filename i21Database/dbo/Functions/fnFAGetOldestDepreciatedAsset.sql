CREATE FUNCTION fnFAGetOldestDepreciatedAsset()
RETURNS @tbl TABLE(
	intAssetId INT
)
AS
BEGIN
	;WITH GetLatestDepDate AS(
	SELECT A.intAssetId, MAX( dtmDepreciationToDate )dtmDepreciationToDate
        FROM tblFAFixedAssetDepreciation A JOIN
		tblFAFixedAsset B ON A.intAssetId = B.intAssetId
		JOIN  tblFABookDepreciation BD ON BD.intAssetId = B.intAssetId
		WHERE B.ysnDisposed = 0
        AND BD.ysnFullyDepreciated = 0
        AND B.ysnAcquired = 1
	    GROUP BY A.intAssetId
	)
	,Ranking AS(
		SELECT intAssetId,  RANK() OVER(ORDER BY dtmDepreciationToDate) rnk FROM GetLatestDepDate
	)
	INSERT INTO @tbl
		SELECT intAssetId FROM Ranking WHERE rnk = 1
    RETURN 
END
