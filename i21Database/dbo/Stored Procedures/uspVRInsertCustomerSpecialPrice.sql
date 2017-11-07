CREATE PROCEDURE uspVRInsertCustomerSpecialPrice 
	@intProgramId INT
AS
BEGIN

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
		intCustomerEntityId = B.intEntityId
		,intCategoryId = NULL
		,C.intItemId
		,strPriceBasis =  CASE WHEN C.strRebateBy = 'Amount' THEN 'Fixed' ELSE 'Sell-Pct' END
		,dblDeviation = C.dblRebateRate
		,C.dtmBeginDate 
		,C.dtmEndDate
		,A.intProgramId
		,intEntityVendorId = F.intEntityId
		,intConcurrencyId = 0
		,strProgramType = 'Vendor Rebate'
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
	WHERE C.intItemId IS NOT NULL
		AND A.intProgramId = @intProgramId

	UNION ALL

	SELECT 
		intCustomerEntityId = B.intEntityId
		,C.intCategoryId
		,intItemId = NULL
		,strPriceBasis =  CASE WHEN C.strRebateBy = 'Amount' THEN 'Fixed' ELSE 'Sell-Pct' END
		,dblDeviation = C.dblRebateRate
		,C.dtmBeginDate 
		,C.dtmEndDate
		,A.intProgramId
		,intEntityVendorId = F.intEntityId
		,intConcurrencyId = 0
		,strProgramType = 'Vendor Rebate'
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
	WHERE C.intCategoryId IS NOT NULL
		AND A.intProgramId = @intProgramId
	
END
GO
