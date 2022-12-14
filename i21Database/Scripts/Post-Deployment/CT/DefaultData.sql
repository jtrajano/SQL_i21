UPDATE tblCTCompanyPreference
SET ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
	, ysnAutoCalculateFreightTermCost = ISNULL(ysnAutoCalculateFreightTermCost, 0)


	TRUNCATE TABLE tblCTBasisCost
--INSERT BASIS COST DEFAULTS IF NO ROWS
IF NOT EXISTS(SELECT 1 FROM  tblCTBasisCost)
BEGIN
MERGE INTO tblCTBasisCost AS destination
		USING
		(
			 SELECT 
				 ICI.strItemNo ,
				 ICI.intItemId,
				 CASE WHEN ICI.strCostMethod = '' THEN 'Amount' ELSE ICI.strCostMethod END strCostMethod,
				 ROW_NUMBER() OVER (ORDER BY CC.intPriority DESC) as [intPriority] ,
				 ROW_NUMBER() OVER (ORDER BY CC.intPriority DESC) as [intSort],
				 ISNULL(CC.[intConcurrencyId],1) as [intConcurrencyId]
			FROM [dbo].[vyuICGetCompactItem]  ICI
			LEFT JOIN tblCTBasisCost CC ON CC.intItemId = ICI.intItemId
			WHERE 1 = ICI.[ysnBasisContract]
		)
		AS SourceData
		ON destination.intItemId = SourceData.intItemId
		WHEN NOT MATCHED THEN
		INSERT
		(
				[strItemNo]
				,[intItemId]
				,[strCostMethod]
				,[intPriority]
				,[intSort]
				,[intConcurrencyId]
		)
		VALUES
		(
			SourceData.strItemNo
			,SourceData.intItemId
			,SourceData.strCostMethod
			,SourceData.[intPriority]
			,SourceData.[intSort]
			,SourceData.[intConcurrencyId]
		);	
END		