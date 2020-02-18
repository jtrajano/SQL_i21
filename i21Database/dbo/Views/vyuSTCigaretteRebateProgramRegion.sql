﻿CREATE VIEW [dbo].[vyuSTCigaretteRebateProgramRegion]
AS
SELECT CRP.intCigaretteRebateProgramId,
	LTRIM(STUFF(
		(SELECT CONVERT(NVARCHAR(50), CRPR.strRegion) + ','
		FROM tblSTCigaretteRebateProgramRegion CRPR
		WHERE CRPR.intCigaretteRebateProgramId = CRP.intCigaretteRebateProgramId
		GROUP BY CRPR.strRegion
		FOR xml path(''))
 		, 1
 		, 0
 		, '')
	) strRegionList
FROM tblSTCigaretteRebatePrograms CRP
GO

