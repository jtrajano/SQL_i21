CREATE VIEW [dbo].[vyuSTCigaretteRebateProgramSearch]
AS
SELECT CRP.intCigaretteRebateProgramId
       , CRP.strStoreIdList
	   , CRP.intEntityVendorId
       , Entity.strName
	   , CRP.dtmStartDate
	   , CRP.dtmEndDate
	   , CRP.strProgramName
	   , CRP.dblManufacturerBuyDownAmount
	   , CRP.strPromotionType
	   , CRP.ysnMultipackFGI
	   , CASE
			WHEN CRP.strPromotionType = 'Buy Down'
				THEN CRP.strProgramName
			WHEN CRP.strPromotionType = 'VAPS' OR CRP.strPromotionType = 'B2S$'
				THEN CRP.strManufacturerPromotionDescription 
			ELSE ''
		END AS strDiscountDescription
		, CASE
			WHEN CRP.strPromotionType = 'Buy Down'
				THEN CRP.dblManufacturerBuyDownAmount
			WHEN CRP.strPromotionType = 'VAPS' OR CRP.strPromotionType = 'B2S$'
				THEN CRP.dblManufacturerDiscountAmount 
			ELSE 0
		END AS dblDiscountAmount
		, CRP.intConcurrencyId
FROM tblSTCigaretteRebatePrograms CRP
INNER JOIN tblEMEntity Entity
	ON CRP.intEntityVendorId = Entity.intEntityId
