CREATE PROCEDURE uspFAMergeBookDepreciation
(
	@intAssetId INT NULL = DEFAULT	
)
AS
MERGE INTO tblFABookDepreciation As Destination
USING 
(
	SELECT M.intDepreciationMethodId, A.intAssetId, A.dblCost, A.dblSalvageValue,dtmDateInService, A.intConcurrencyId, D.intBookId  
	FROM tblFAFixedAsset A 
	JOIN tblFADepreciationMethod M ON M.intAssetId = A.intAssetId
	LEFT JOIN tblFABookDepreciation D ON D.intDepreciationMethodId =M.intDepreciationMethodId 
	AND intBookId = 1
	WHERE A.intAssetId = 
		CASE WHEN @intAssetId IS NULL 
		THEN A.intAssetId 
		ELSE @intAssetId 
	END
) As SourceData
ON SourceData.intDepreciationMethodId = Destination.intDepreciationMethodId

WHEN MATCHED THEN 
		UPDATE 
		SET 	Destination.dblCost = SourceData.dblCost,
				Destination.dblSalvageValue = SourceData.dblSalvageValue,
				Destination.dtmPlacedInService = SourceData.dtmDateInService,
				Destination.intDepreciationMethodId = SourceData.intDepreciationMethodId
				
WHEN NOT MATCHED BY TARGET THEN
			INSERT ( 
				intDepreciationMethodId,
				intAssetId,
				dblCost,
				dblSalvageValue,
				dtmPlacedInService,
				intConcurrencyId,
				intBookId
			)
			VALUES
			(
				intDepreciationMethodId,
				intAssetId,
				dblCost,
				dblSalvageValue,
				dtmDateInService,
				1,
				1
			);


