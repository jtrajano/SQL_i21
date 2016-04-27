CREATE VIEW [dbo].[vyuPRForm941BReport]
AS
SELECT 
	[Quarters].[intYear]
	,[Quarters].[intQuarter]
	,[dblMonth1Total] = CONVERT(NUMERIC(18, 2), ISNULL([Month1].[1], 0) + ISNULL([Month1].[2], 0) + ISNULL([Month1].[3], 0) 
				+ ISNULL([Month1].[4], 0) + ISNULL([Month1].[5], 0) + ISNULL([Month1].[6], 0) + ISNULL([Month1].[7], 0) 
				+ ISNULL([Month1].[8], 0) + ISNULL([Month1].[9], 0) + ISNULL([Month1].[10], 0) + ISNULL([Month1].[11], 0) 
				+ ISNULL([Month1].[12], 0) + ISNULL([Month1].[13], 0) + ISNULL([Month1].[14], 0) + ISNULL([Month1].[15], 0) 
				+ ISNULL([Month1].[16], 0) + ISNULL([Month1].[17], 0) + ISNULL([Month1].[18], 0) + ISNULL([Month1].[19], 0) 
				+ ISNULL([Month1].[20], 0) + ISNULL([Month1].[21], 0) + ISNULL([Month1].[22], 0) + ISNULL([Month1].[23], 0) 
				+ ISNULL([Month1].[24], 0) + ISNULL([Month1].[25], 0) + ISNULL([Month1].[26], 0) + ISNULL([Month1].[27], 0) 
				+ ISNULL([Month1].[28], 0) + ISNULL([Month1].[29], 0) + ISNULL([Month1].[30], 0) + ISNULL([Month1].[31], 0))
	,[dblMonth2Total] = CONVERT(NUMERIC(18, 2), ISNULL([Month2].[1], 0) + ISNULL([Month2].[2], 0) + ISNULL([Month2].[3], 0) 
				+ ISNULL([Month2].[4], 0) + ISNULL([Month2].[5], 0) + ISNULL([Month2].[6], 0) + ISNULL([Month2].[7], 0) 
				+ ISNULL([Month2].[8], 0) + ISNULL([Month2].[9], 0) + ISNULL([Month2].[10], 0) + ISNULL([Month2].[11], 0) 
				+ ISNULL([Month2].[12], 0) + ISNULL([Month2].[13], 0) + ISNULL([Month2].[14], 0) + ISNULL([Month2].[15], 0) 
				+ ISNULL([Month2].[16], 0) + ISNULL([Month2].[17], 0) + ISNULL([Month2].[18], 0) + ISNULL([Month2].[19], 0) 
				+ ISNULL([Month2].[20], 0) + ISNULL([Month2].[21], 0) + ISNULL([Month2].[22], 0) + ISNULL([Month2].[23], 0) 
				+ ISNULL([Month2].[24], 0) + ISNULL([Month2].[25], 0) + ISNULL([Month2].[26], 0) + ISNULL([Month2].[27], 0) 
				+ ISNULL([Month2].[28], 0) + ISNULL([Month2].[29], 0) + ISNULL([Month2].[30], 0) + ISNULL([Month2].[31], 0))
	,[dblMonth3Total] = CONVERT(NUMERIC(18, 2), ISNULL([Month3].[1], 0) + ISNULL([Month3].[2], 0) + ISNULL([Month3].[3], 0) 
				+ ISNULL([Month3].[4], 0) + ISNULL([Month3].[5], 0) + ISNULL([Month3].[6], 0) + ISNULL([Month3].[7], 0) 
				+ ISNULL([Month3].[8], 0) + ISNULL([Month3].[9], 0) + ISNULL([Month3].[10], 0) + ISNULL([Month3].[11], 0) 
				+ ISNULL([Month3].[12], 0) + ISNULL([Month3].[13], 0) + ISNULL([Month3].[14], 0) + ISNULL([Month3].[15], 0) 
				+ ISNULL([Month3].[16], 0) + ISNULL([Month3].[17], 0) + ISNULL([Month3].[18], 0) + ISNULL([Month3].[19], 0) 
				+ ISNULL([Month3].[20], 0) + ISNULL([Month3].[21], 0) + ISNULL([Month3].[22], 0) + ISNULL([Month3].[23], 0) 
				+ ISNULL([Month3].[24], 0) + ISNULL([Month3].[25], 0) + ISNULL([Month3].[26], 0) + ISNULL([Month3].[27], 0) 
				+ ISNULL([Month3].[28], 0) + ISNULL([Month3].[29], 0) + ISNULL([Month3].[30], 0) + ISNULL([Month3].[31], 0))
	,[dblQuarterTotal] = CONVERT(NUMERIC(18, 2), ISNULL([Month1].[1], 0) + ISNULL([Month1].[2], 0) + ISNULL([Month1].[3], 0) 
				+ ISNULL([Month1].[4], 0) + ISNULL([Month1].[5], 0) + ISNULL([Month1].[6], 0) + ISNULL([Month1].[7], 0) 
				+ ISNULL([Month1].[8], 0) + ISNULL([Month1].[9], 0) + ISNULL([Month1].[10], 0) + ISNULL([Month1].[11], 0) 
				+ ISNULL([Month1].[12], 0) + ISNULL([Month1].[13], 0) + ISNULL([Month1].[14], 0) + ISNULL([Month1].[15], 0) 
				+ ISNULL([Month1].[16], 0) + ISNULL([Month1].[17], 0) + ISNULL([Month1].[18], 0) + ISNULL([Month1].[19], 0) 
				+ ISNULL([Month1].[20], 0) + ISNULL([Month1].[21], 0) + ISNULL([Month1].[22], 0) + ISNULL([Month1].[23], 0) 
				+ ISNULL([Month1].[24], 0) + ISNULL([Month1].[25], 0) + ISNULL([Month1].[26], 0) + ISNULL([Month1].[27], 0) 
				+ ISNULL([Month1].[28], 0) + ISNULL([Month1].[29], 0) + ISNULL([Month1].[30], 0) + ISNULL([Month1].[31], 0))
				+ CONVERT(NUMERIC(18, 2), ISNULL([Month2].[1], 0) + ISNULL([Month2].[2], 0) + ISNULL([Month2].[3], 0) 
				+ ISNULL([Month2].[4], 0) + ISNULL([Month2].[5], 0) + ISNULL([Month2].[6], 0) + ISNULL([Month2].[7], 0) 
				+ ISNULL([Month2].[8], 0) + ISNULL([Month2].[9], 0) + ISNULL([Month2].[10], 0) + ISNULL([Month2].[11], 0) 
				+ ISNULL([Month2].[12], 0) + ISNULL([Month2].[13], 0) + ISNULL([Month2].[14], 0) + ISNULL([Month2].[15], 0) 
				+ ISNULL([Month2].[16], 0) + ISNULL([Month2].[17], 0) + ISNULL([Month2].[18], 0) + ISNULL([Month2].[19], 0) 
				+ ISNULL([Month2].[20], 0) + ISNULL([Month2].[21], 0) + ISNULL([Month2].[22], 0) + ISNULL([Month2].[23], 0) 
				+ ISNULL([Month2].[24], 0) + ISNULL([Month2].[25], 0) + ISNULL([Month2].[26], 0) + ISNULL([Month2].[27], 0) 
				+ ISNULL([Month2].[28], 0) + ISNULL([Month2].[29], 0) + ISNULL([Month2].[30], 0) + ISNULL([Month2].[31], 0))
				+ CONVERT(NUMERIC(18, 2), ISNULL([Month3].[1], 0) + ISNULL([Month3].[2], 0) + ISNULL([Month3].[3], 0) 
				+ ISNULL([Month3].[4], 0) + ISNULL([Month3].[5], 0) + ISNULL([Month3].[6], 0) + ISNULL([Month3].[7], 0) 
				+ ISNULL([Month3].[8], 0) + ISNULL([Month3].[9], 0) + ISNULL([Month3].[10], 0) + ISNULL([Month3].[11], 0) 
				+ ISNULL([Month3].[12], 0) + ISNULL([Month3].[13], 0) + ISNULL([Month3].[14], 0) + ISNULL([Month3].[15], 0) 
				+ ISNULL([Month3].[16], 0) + ISNULL([Month3].[17], 0) + ISNULL([Month3].[18], 0) + ISNULL([Month3].[19], 0) 
				+ ISNULL([Month3].[20], 0) + ISNULL([Month3].[21], 0) + ISNULL([Month3].[22], 0) + ISNULL([Month3].[23], 0) 
				+ ISNULL([Month3].[24], 0) + ISNULL([Month3].[25], 0) + ISNULL([Month3].[26], 0) + ISNULL([Month3].[27], 0) 
				+ ISNULL([Month3].[28], 0) + ISNULL([Month3].[29], 0) + ISNULL([Month3].[30], 0) + ISNULL([Month3].[31], 0))
	,[Month1].[1] AS [dblMonth1Day01]
	,[Month1].[2] AS [dblMonth1Day02]
	,[Month1].[3] AS [dblMonth1Day03]
	,[Month1].[4] AS [dblMonth1Day04]
	,[Month1].[5] AS [dblMonth1Day05]
	,[Month1].[6] AS [dblMonth1Day06]
	,[Month1].[7] AS [dblMonth1Day07]
	,[Month1].[8] AS [dblMonth1Day08]
	,[Month1].[9] AS [dblMonth1Day09]
	,[Month1].[10] AS [dblMonth1Day10]
	,[Month1].[11] AS [dblMonth1Day11]
	,[Month1].[12] AS [dblMonth1Day12]
	,[Month1].[13] AS [dblMonth1Day13]
	,[Month1].[14] AS [dblMonth1Day14]
	,[Month1].[15] AS [dblMonth1Day15]
	,[Month1].[16] AS [dblMonth1Day16]
	,[Month1].[17] AS [dblMonth1Day17]
	,[Month1].[18] AS [dblMonth1Day18]
	,[Month1].[19] AS [dblMonth1Day19]
	,[Month1].[20] AS [dblMonth1Day20]
	,[Month1].[21] AS [dblMonth1Day21]
	,[Month1].[22] AS [dblMonth1Day22]
	,[Month1].[23] AS [dblMonth1Day23]
	,[Month1].[24] AS [dblMonth1Day24]
	,[Month1].[25] AS [dblMonth1Day25]
	,[Month1].[26] AS [dblMonth1Day26]
	,[Month1].[27] AS [dblMonth1Day27]
	,[Month1].[28] AS [dblMonth1Day28]
	,[Month1].[29] AS [dblMonth1Day29]
	,[Month1].[30] AS [dblMonth1Day30]
	,[Month1].[31] AS [dblMonth1Day31]
	,[Month2].[1] AS [dblMonth2Day01]
	,[Month2].[2] AS [dblMonth2Day02]
	,[Month2].[3] AS [dblMonth2Day03]
	,[Month2].[4] AS [dblMonth2Day04]
	,[Month2].[5] AS [dblMonth2Day05]
	,[Month2].[6] AS [dblMonth2Day06]
	,[Month2].[7] AS [dblMonth2Day07]
	,[Month2].[8] AS [dblMonth2Day08]
	,[Month2].[9] AS [dblMonth2Day09]
	,[Month2].[10] AS [dblMonth2Day10]
	,[Month2].[11] AS [dblMonth2Day11]
	,[Month2].[12] AS [dblMonth2Day12]
	,[Month2].[13] AS [dblMonth2Day13]
	,[Month2].[14] AS [dblMonth2Day14]
	,[Month2].[15] AS [dblMonth2Day15]
	,[Month2].[16] AS [dblMonth2Day16]
	,[Month2].[17] AS [dblMonth2Day17]
	,[Month2].[18] AS [dblMonth2Day18]
	,[Month2].[19] AS [dblMonth2Day19]
	,[Month2].[20] AS [dblMonth2Day20]
	,[Month2].[21] AS [dblMonth2Day21]
	,[Month2].[22] AS [dblMonth2Day22]
	,[Month2].[23] AS [dblMonth2Day23]
	,[Month2].[24] AS [dblMonth2Day24]
	,[Month2].[25] AS [dblMonth2Day25]
	,[Month2].[26] AS [dblMonth2Day26]
	,[Month2].[27] AS [dblMonth2Day27]
	,[Month2].[28] AS [dblMonth2Day28]
	,[Month2].[29] AS [dblMonth2Day29]
	,[Month2].[30] AS [dblMonth2Day30]
	,[Month2].[31] AS [dblMonth2Day31]
	,[Month3].[1] AS [dblMonth3Day01]
	,[Month3].[2] AS [dblMonth3Day02]
	,[Month3].[3] AS [dblMonth3Day03]
	,[Month3].[4] AS [dblMonth3Day04]
	,[Month3].[5] AS [dblMonth3Day05]
	,[Month3].[6] AS [dblMonth3Day06]
	,[Month3].[7] AS [dblMonth3Day07]
	,[Month3].[8] AS [dblMonth3Day08]
	,[Month3].[9] AS [dblMonth3Day09]
	,[Month3].[10] AS [dblMonth3Day10]
	,[Month3].[11] AS [dblMonth3Day11]
	,[Month3].[12] AS [dblMonth3Day12]
	,[Month3].[13] AS [dblMonth3Day13]
	,[Month3].[14] AS [dblMonth3Day14]
	,[Month3].[15] AS [dblMonth3Day15]
	,[Month3].[16] AS [dblMonth3Day16]
	,[Month3].[17] AS [dblMonth3Day17]
	,[Month3].[18] AS [dblMonth3Day18]
	,[Month3].[19] AS [dblMonth3Day19]
	,[Month3].[20] AS [dblMonth3Day20]
	,[Month3].[21] AS [dblMonth3Day21]
	,[Month3].[22] AS [dblMonth3Day22]
	,[Month3].[23] AS [dblMonth3Day23]
	,[Month3].[24] AS [dblMonth3Day24]
	,[Month3].[25] AS [dblMonth3Day25]
	,[Month3].[26] AS [dblMonth3Day26]
	,[Month3].[27] AS [dblMonth3Day27]
	,[Month3].[28] AS [dblMonth3Day28]
	,[Month3].[29] AS [dblMonth3Day29]
	,[Month3].[30] AS [dblMonth3Day30]
	,[Month3].[31] AS [dblMonth3Day31]
FROM 
	(SELECT DISTINCT intYear, intQuarter
		FROM vyuPRDailyTaxTotal
	) AS Quarters
	LEFT JOIN
	(SELECT * FROM
		(SELECT intYear, 
				intQuarter, 
				intDay, 
				dblTotal = ((dblLiabilitySS + dblTaxTotalSS) * 0.124) + ((dblLiabilityMed + dblTaxTotalMed) * 0.029) + dblFIT
			FROM vyuPRDailyTaxTotal
			WHERE intMonth IN (1, 4, 7, 10)
		) AS Month1
		PIVOT (SUM(dblTotal) 
			FOR intDay IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
							[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
							[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
		) Month1
	) Month1
	ON Quarters.intYear = Month1.intYear
	AND Quarters.intQuarter = Month1.intQuarter
	LEFT JOIN
	(SELECT * FROM
		(SELECT intYear, 
				intQuarter, 
				intDay, 
				dblTotal = ((dblLiabilitySS + dblTaxTotalSS) * 0.124) + ((dblLiabilityMed + dblTaxTotalMed) * 0.029) + dblFIT
			FROM vyuPRDailyTaxTotal
			WHERE intMonth IN (2, 5, 8, 11)
		) AS Month2
		PIVOT (SUM(dblTotal) 
			FOR intDay IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
							[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
							[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
		) Month2
	) Month2
	ON Quarters.intYear = Month2.intYear
	AND Quarters.intQuarter = Month2.intQuarter
	LEFT JOIN
	(SELECT * FROM
		(SELECT intYear, 
				intQuarter, 
				intDay, 
				dblTotal = ((dblLiabilitySS + dblTaxTotalSS) * 0.124) + ((dblLiabilityMed + dblTaxTotalMed) * 0.029) + dblFIT
			FROM vyuPRDailyTaxTotal
			WHERE intMonth IN (3, 6, 9, 12)
		) AS Month3
		PIVOT (SUM(dblTotal) 
			FOR intDay IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
							[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
							[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
		) Month3
	) Month3
	ON Quarters.intYear = Month3.intYear
	AND Quarters.intQuarter = Month3.intQuarter

GO