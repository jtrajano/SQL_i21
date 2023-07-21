CREATE VIEW [dbo].[vyuRKGetSequenceMonth]
AS
SELECT *
FROM (
	SELECT intDeliveryMonthId = n.intDeliveryMonthId
		, strDeliveryMonth = RIGHT(CONVERT(VARCHAR(11),DATEADD(dd, -1, DATEADD(MONTH, n.intDeliveryMonthId + DATEDIFF(MONTH, 0, GETDATE()), 0)), 6), 6) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT intDeliveryMonthId FROM (VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) t (intDeliveryMonthId)
	) n
)t