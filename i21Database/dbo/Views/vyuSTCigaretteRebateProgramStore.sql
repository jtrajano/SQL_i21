CREATE VIEW [dbo].[vyuSTCigaretteRebateProgramStore]
	AS 
SELECT CRP.intCigaretteRebateProgramId,
	LTRIM(STUFF(
		(SELECT CONVERT(NVARCHAR(50), S.intStoreId) + ','
		FROM tblSTCigaretteRebateProgramStore CRPS INNER JOIN tblSTStore S ON S.intStoreId = CRPS.intStoreId
		WHERE CRPS.intCigaretteRebateProgramId = CRP.intCigaretteRebateProgramId
		GROUP BY S.intStoreId
		FOR xml path(''))
 		, 1
 		, 0
 		, '')
	) COLLATE Latin1_General_CI_AS strStoreList 
FROM tblSTCigaretteRebatePrograms CRP