CREATE VIEW [dbo].[vyuCTItemContractView]
	
AS 
	
	SELECT	IC.intItemContractId,
			IM.intCommodityId,
			IC.intItemId,
			IC.intItemLocationId,
			IC.strContractItemName,
			IC.intCountryId,
			IC.strGrade,
			IC.strGradeType,
			IC.strGarden,
			IC.dblYieldPercent,
			IC.dblTolerancePercent,
			IC.dblFranchisePercent,
			IM.strItemNo,
			IM.strDescription strItemDescription,
			RY.strCountry strOrigin,
			CL.strLocationName,
			CL.intCompanyLocationId AS	intLocationId

	FROM	tblICItemContract		IC
	JOIN	tblICItem				IM	ON	IM.intItemId			=	IC.intItemId
	JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	IC.intItemLocationId
	JOIN	tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId =	IL.intLocationId		LEFT
	JOIN	tblSMCountry			RY	ON	RY.intCountryID			=	IC.intCountryId 
	

