CREATE PROCEDURE [dbo].[uspICGetChargeAddOns]
	@intItemId AS INT,
	@intLocationId AS INT
AS
BEGIN

	SELECT	OtherCharge.intItemId
			, OtherCharge.strItemNo
			, OtherCharge.strDescription
			, OtherCharge.ysnInventoryCost
			, OtherCharge.ysnAccrue
			, OtherCharge.ysnMTM
			, OtherCharge.ysnPrice
			, OtherCharge.strCostMethod
			, OtherCharge.dblAmount
			, OtherCharge.intCostUOMId
			, OtherCharge.strCostUOM 
			, OtherCharge.strUnitType
			, OtherCharge.strCostType
			, OtherCharge.intOnCostTypeId
			, OtherCharge.strOnCostType 
			, OtherCharge.ysnBasisContract
			, OtherCharge.intM2MComputationId
			, OtherCharge.strM2MComputation
	FROM	tblICItemAddOn ItemWithAddOn 
			INNER JOIN vyuICGetOtherCharges OtherCharge 
				ON OtherCharge.intItemId = ItemWithAddOn.intAddOnItemId
			LEFT JOIN (
				tblICItemLocation ItemLocation INNER JOIN tblSMCompanyLocation l 
					ON l.intCompanyLocationId = ItemLocation.intLocationId
			) ON ItemLocation.intItemId = OtherCharge.intItemId
				AND ItemLocation.intLocationId IS NOT NULL
	WHERE	ItemWithAddOn.intItemId = @intItemId
			AND l.intCompanyLocationId = @intLocationId
END