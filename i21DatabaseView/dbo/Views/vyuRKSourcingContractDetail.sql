CREATE VIEW [dbo].[vyuRKSourcingContractDetail]
AS

	SELECT	CD.intContractDetailId,		 	
			CD.intContractSeq,							
			ISNULL(IG.strCountry,OG.strCountry)	AS	strOrigin,
			CA.strDescription				AS	strProductType	

	FROM	tblCTContractDetail				    CD 	
	JOIN	tblICItem						    IM	ON	IM.intItemId				=	CD.intItemId					
	LEFT JOIN	tblICItemContract				IC	ON	IC.intItemContractId		=	CD.intItemContractId			
	LEFT JOIN	tblICCommodityAttribute			EO	ON	EO.intCommodityAttributeId	=	IM.intOriginId				
	LEFT JOIN	tblSMCountry					OG	ON	OG.intCountryID				=	EO.intCountryID				
	LEFT JOIN	tblSMCountry					IG	ON	IG.intCountryID				=	IC.intCountryId				
	LEFT JOIN	tblSMCompanyLocationSubLocation	SB	ON	SB.intCompanyLocationSubLocationId	= CD.intSubLocationId 	
	LEFT JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intProductTypeId	AND	CA.strType = 'ProductType'		