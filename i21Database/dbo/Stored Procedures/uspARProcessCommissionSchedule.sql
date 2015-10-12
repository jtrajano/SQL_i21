CREATE PROCEDURE [dbo].[uspARProcessCommissionSchedule]
	@commissionIds	NVARCHAR(MAX) = ''
AS
	CREATE TABLE #tmpCommissionSchedule (intCommissionScheduleId INT)

	IF (@commissionIds <> '' AND @commissionIds IS NOT NULL)
		BEGIN
			DECLARE @commSchedId INT,
					@pos INT
			
			WHILE CHARINDEX(',', @commissionIds) > 0
			BEGIN
				SELECT @pos  = CHARINDEX(',', @commissionIds)  				
				SELECT @commSchedId = CONVERT(INT, SUBSTRING(@commissionIds, 1, @pos-1))

				INSERT INTO #tmpCommissionSchedule VALUES (@commSchedId)				

				SELECT @commissionIds = SUBSTRING(@commissionIds, @pos + 1, LEN(@commissionIds) - @pos)
			END
		END

	IF EXISTS(SELECT NULL FROM #tmpCommissionSchedule)
		BEGIN
			WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCommissionSchedule)
			BEGIN
				DECLARE @commissionScheduleId INT

				SELECT TOP 1 @commissionScheduleId = intCommissionScheduleId FROM #tmpCommissionSchedule

				DELETE FROM #tmpCommissionSchedule WHERE intCommissionScheduleId = @commissionScheduleId
			END
		END

	DROP TABLE #tmpCommissionSchedule