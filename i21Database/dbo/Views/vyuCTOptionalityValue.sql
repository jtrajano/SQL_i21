﻿
Create VIEW [dbo].[vyuCTOptionalityValue]
AS

SELECT  intOptionId, intValueId, intFilterId, strValue, strDescription
FROM 
	(
		SELECT intCropYearId intValueId
			  ,a.intCommodityId intFilterId
			  ,strCropYear strValue
			  ,'cropyearcombo' strControlName
			  ,b.strCommodityCode strDescription
		FROM tblCTCropYear a
		INNER JOIN tblICCommodity b on a.intCommodityId = b.intCommodityId

		UNION ALL

		SELECT intCityId
		      ,intCountryId
			  ,strCity,
			  'citycombo' strControlName
			  ,strCountry
		FROM tblSMCity a
		Inner join tblSMCountry b on a.intCountryId = b.intCountryID

		UNION ALL 

		SELECT intUnitMeasureId
		      ,intUnitMeasureId
			  ,strUnitMeasure,
			  'packagecombo' strControlName
			  ,strSymbol
		FROM tblICUnitMeasure a

		UNION ALL 

		SELECT intFreightTermId
		      ,intFreightTermId
			  ,strFreightTerm,
			  'incotermcombo' strControlName
			  ,strDescription
		FROM vyuSMFreightTerms a
		WHERE ysnActive = 1

		UNION ALL 

		SELECT intAssociationId
		      ,intAssociationId
			  ,strName,
			  'assoccombo' strControlName
			  ,strComment
		FROM tblCTAssociation a 
		WHERE ysnActive = 1

		UNION ALL 

		SELECT intCityId
		      ,intCountryId
			  ,strCity,
			  'arbitrationcombo' strControlName
			  ,strCountry
		FROM tblSMCity a
		Inner join tblSMCountry b on a.intCountryId = b.intCountryID
		where ysnArbitration = 1
		
	) a
Inner join tblCTOption b on a.strControlName = b.strControlName
GROUP BY  intOptionId, intValueId, intFilterId, strValue, strDescription
