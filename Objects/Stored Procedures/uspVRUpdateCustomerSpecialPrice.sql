CREATE PROCEDURE uspVRUpdateCustomerSpecialPrice 
	@intProgramId INT
AS
BEGIN

	IF OBJECT_ID('tempdb..#tmpProgramItem') IS NOT NULL  
	BEGIN					
		DROP TABLE #tmpProgramItem
	END
	SELECT 
		intCustomerEntityId = B.intEntityId
		,C.intCategoryId
		,C.intItemId
		,strPriceBasis =  CASE WHEN C.strRebateBy = 'Amount' THEN 'Fixed' ELSE 'Sell-Pct' END
		,dblDeviation = C.dblRebateRate
		,C.dtmBeginDate 
		,C.dtmEndDate
		,A.intProgramId
		,intEntityVendorId = F.intEntityId
		,intConcurrencyId = 0
		,strProgramType = 'Vendor Rebate'
		,C.strRebateBy
	INTO #tmpProgramItem
	FROM tblVRProgramCustomer B
	INNER JOIN tblVRProgram A
		ON A.intProgramId = B.intProgramId
	INNER JOIN tblVRProgramItem C
		ON A.intProgramId = C.intProgramId
	INNER JOIN tblVRCustomerXref D
		ON B.intEntityId = D.intEntityId
	INNER JOIN tblICItemVendorXref E
		ON C.intItemId = E.intItemId
	INNER JOIN tblVRVendorSetup F
		ON A.intVendorSetupId = F.intVendorSetupId
	WHERE A.intProgramId = @intProgramId
		

	-----Insert new Items/Categories
	----------

	INSERT INTO tblARCustomerSpecialPrice
	(
		intEntityCustomerId
		,intCategoryId
		,intItemId
		,strPriceBasis
		,dblDeviation
		,dtmBeginDate
		,dtmEndDate
		,intProgramId
		,intEntityVendorId 
		,intConcurrencyId 
		,strProgramType
	)

	SELECT 
		intCustomerEntityId
		,intCategoryId = NULL
		,intItemId
		,strPriceBasis =  CASE WHEN strRebateBy = 'Amount' THEN 'Fixed' ELSE 'Sell-Pct' END
		,dblDeviation
		,dtmBeginDate 
		,dtmEndDate
		,intProgramId
		,intEntityVendorId
		,intConcurrencyId
		,strProgramType
	FROM #tmpProgramItem A
	WHERE intItemId IS NOT NULL
		AND NOT EXISTS(SELECT TOP 1 1 
						FROM tblARCustomerSpecialPrice
						WHERE intProgramId = @intProgramId
							AND intItemId = A.intItemId
							AND intEntityCustomerId = A.intCustomerEntityId)

	UNION ALL

	SELECT 
		intCustomerEntityId
		,intCategoryId 
		,intItemId = NULL
		,strPriceBasis =  CASE WHEN strRebateBy = 'Amount' THEN 'Fixed' ELSE 'Sell-Pct' END
		,dblDeviation
		,dtmBeginDate 
		,dtmEndDate
		,intProgramId
		,intEntityVendorId
		,intConcurrencyId
		,strProgramType
	FROM #tmpProgramItem A
	WHERE intCategoryId IS NOT NULL
		AND NOT EXISTS(SELECT TOP 1 1 
					FROM tblARCustomerSpecialPrice
					WHERE intProgramId = @intProgramId
						AND intCategoryId = intCategoryId
						AND intEntityCustomerId = A.intCustomerEntityId)
	---------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------

	---Delete Customer SpecialPrice that are not in the program anymore
	----

	--Item
	DELETE FROM tblARCustomerSpecialPrice
	WHERE intProgramId = @intProgramId
		AND intItemId IS NOT NULL
		AND NOT EXISTS (SELECT TOP 1 1 
						FROM #tmpProgramItem B
						WHERE B.intCustomerEntityId = tblARCustomerSpecialPrice.intEntityCustomerId
							AND B.intEntityVendorId = tblARCustomerSpecialPrice.intEntityVendorId
							AND B.intItemId = tblARCustomerSpecialPrice.intItemId)
	---Category
	DELETE FROM tblARCustomerSpecialPrice
	WHERE intProgramId = @intProgramId
		AND intCategoryId IS NOT NULL
		AND NOT EXISTS (SELECT TOP 1 1 
						FROM #tmpProgramItem B
						WHERE B.intCustomerEntityId = tblARCustomerSpecialPrice.intEntityCustomerId
							AND B.intEntityVendorId = tblARCustomerSpecialPrice.intEntityVendorId
							AND B.intCategoryId = tblARCustomerSpecialPrice.intCategoryId)
	---------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------

	---Update Details
	---ITEM
	UPDATE tblARCustomerSpecialPrice
	SET	intCategoryId = B.intCategoryId
		,intItemId = B.intItemId
		,strPriceBasis =  B.strPriceBasis
		,dblDeviation = B.dblDeviation
		,dtmBeginDate = B.dtmBeginDate
		,dtmEndDate = B.dtmEndDate
	FROM #tmpProgramItem B
	WHERE B.intCustomerEntityId = tblARCustomerSpecialPrice.intEntityCustomerId
		AND B.intEntityVendorId = tblARCustomerSpecialPrice.intEntityVendorId
		AND B.intItemId = tblARCustomerSpecialPrice.intItemId
		AND tblARCustomerSpecialPrice.intProgramId = @intProgramId
		AND tblARCustomerSpecialPrice.intItemId IS NOT NULL

	---Category
	UPDATE tblARCustomerSpecialPrice
	SET	intCategoryId = B.intCategoryId
		,intItemId = B.intItemId
		,strPriceBasis =  B.strPriceBasis
		,dblDeviation = B.dblDeviation
		,dtmBeginDate = B.dtmBeginDate
		,dtmEndDate = B.dtmEndDate
	FROM #tmpProgramItem B
	WHERE B.intCustomerEntityId = tblARCustomerSpecialPrice.intEntityCustomerId
		AND B.intEntityVendorId = tblARCustomerSpecialPrice.intEntityVendorId
		AND B.intCategoryId = tblARCustomerSpecialPrice.intCategoryId
		AND tblARCustomerSpecialPrice.intProgramId = @intProgramId
		AND tblARCustomerSpecialPrice.intCategoryId IS NOT NULL
	
END
GO
