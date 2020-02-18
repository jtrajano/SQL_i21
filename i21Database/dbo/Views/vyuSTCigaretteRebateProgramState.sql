CREATE VIEW [dbo].[vyuSTCigaretteRebateProgramState]
AS
SELECT CRP.intCigaretteRebateProgramId,
	LTRIM(STUFF(
		(SELECT CONVERT(NVARCHAR(50), CRPS.strState) + ','
		FROM tblSTCigaretteRebateProgramState CRPS
		WHERE CRPS.intCigaretteRebateProgramId = CRP.intCigaretteRebateProgramId
		GROUP BY CRPS.strState
		FOR xml path(''))
 		, 1
 		, 0
 		, '')
	) strStateList
FROM tblSTCigaretteRebatePrograms CRP
GO

