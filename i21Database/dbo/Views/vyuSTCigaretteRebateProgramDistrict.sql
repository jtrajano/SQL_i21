﻿CREATE VIEW [dbo].[vyuSTCigaretteRebateProgramDistrict]
AS
SELECT CRP.intCigaretteRebateProgramId,
	LTRIM(STUFF(
		(SELECT CONVERT(NVARCHAR(50), CRPD.strDistrict) + ','
		FROM tblSTCigaretteRebateProgramDistrict CRPD
		WHERE CRPD.intCigaretteRebateProgramId = CRP.intCigaretteRebateProgramId
		GROUP BY CRPD.strDistrict
		FOR xml path(''))
 		, 1
 		, 0
 		, '')
	) strDistrictList
FROM tblSTCigaretteRebatePrograms CRP
GO

