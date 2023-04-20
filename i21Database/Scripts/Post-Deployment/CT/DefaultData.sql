UPDATE tblCTCompanyPreference
SET ysnFreightTermCost = ISNULL(ysnFreightTermCost, 0)
	, ysnAutoCalculateFreightTermCost = ISNULL(ysnAutoCalculateFreightTermCost, 0)

UPDATE tblCTContractCondition
SET ysnPrimeCustomer = 0
WHERE ISNULL(ysnPrimeCustomer, 0) = 0

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

--INSERT NEW Item in Ammendment and Approval
BEGIN
MERGE INTO tblCTAmendmentApproval AS destination
		USING
		(		SELECT
				 'intINCOLocationTypeId' AS strDataIndex
				,'Port/City' AS strDataField
				,1 AS ysnAmendment
				,1 AS ysnApproval
				,NULL AS ysnBulkChange
				,NULL AS ysnBulkChangeReadOnly
				,7 AS intConcurrencyId
				,'1.Header' AS strType
		)
		AS SourceData
		ON destination.strDataIndex = SourceData.strDataIndex
		WHEN NOT MATCHED THEN
		INSERT
		(
				 strDataIndex
				,strDataField
				,ysnAmendment
				,ysnApproval
				,ysnBulkChange
				,ysnBulkChangeReadOnly
				,intConcurrencyId
				,strType
		)
		VALUES
		(
				 SourceData.strDataIndex
				,SourceData.strDataField
				,SourceData.ysnAmendment
				,SourceData.ysnApproval
				,SourceData.ysnBulkChange
				,SourceData.ysnBulkChangeReadOnly
				,SourceData.intConcurrencyId
				,SourceData.strType
		);	
END	

--UPDATE CT REFERENCE AMENDFIELDS INCLUDE INCOLOCATION PORT 
BEGIN 
	IF NOT EXISTS (SELECT 1  FROM tblCTCompanyPreference where strAmendmentFields LIKE '%INCO%' ) 
	AND EXISTS (SELECT 1 FROM tblCTAmendmentApproval where strDataIndex = 'intINCOLocationTypeId' and ysnApproval = 1)
	BEGIN 
		UPDATE tblCTCompanyPreference
		SET strAmendmentFields = strAmendmentFields+',intINCOLocationTypeId'
	END
END
