
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
		from tblCTCropYear a
		INNER JOIN tblICCommodity b on a.intCommodityId = b.intCommodityId

		UNION ALL

		SELECT intCityId
		      ,intCountryId
			  ,strCity,
			  'citycombo' strControlName
			  ,strCountry
		from tblSMCity a
		Inner join tblSMCountry b on a.intCountryId = b.intCountryID
		
	) a
Inner join tblCTOption b on a.strControlName = b.strControlName
GROUP BY  intOptionId, intValueId, intFilterId, strValue, strDescription
