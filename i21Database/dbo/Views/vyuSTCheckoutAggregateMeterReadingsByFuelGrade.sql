CREATE VIEW [dbo].[vyuSTCheckoutAggregateMeterReadingsByFuelGrade]
AS
SELECT		a.intFuelTotalSoldId,
			a.intCheckoutId,
			a.intProductNumber,
			CASE 
				WHEN a.intProductNumber = 1
				THEN '87 Unl'
				WHEN a.intProductNumber = 2
				THEN '89 Mid'
				WHEN a.intProductNumber = 3
				THEN '91 Premium'
				WHEN a.intProductNumber = 4
				THEN 'Diesel'
				END as 'strDescription',
			a.dblDollarsSold,
			a.dblGallonsSold
FROM		tblSTCheckoutFuelTotalSold a