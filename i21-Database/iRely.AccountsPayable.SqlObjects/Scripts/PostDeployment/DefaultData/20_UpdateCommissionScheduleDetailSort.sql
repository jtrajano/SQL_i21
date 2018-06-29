print('/*******************  BEGIN Update tblARCommissionScheduleDetail.intSort *******************/')
GO

DECLARE @tblARCommissionSchedule TABLE (intCommissionScheduleId INT)
DECLARE @tblARCommissionScheduleDetail TABLE (intCommissionScheduleDetailId INT)
DECLARE @intCommissionScheduleId INT

INSERT INTO @tblARCommissionSchedule
SELECT intCommissionScheduleId FROM tblARCommissionSchedule

IF EXISTS (SELECT NULL FROM @tblARCommissionSchedule)
	BEGIN
		WHILE EXISTS (SELECT NULL FROM @tblARCommissionSchedule)
			BEGIN
				DECLARE @sortCounter INT = 1
				SELECT TOP 1 @intCommissionScheduleId = ISNULL(intCommissionScheduleId, 0) FROM @tblARCommissionSchedule

				INSERT INTO @tblARCommissionScheduleDetail
				SELECT intCommissionScheduleDetailId 
				FROM tblARCommissionScheduleDetail 
				WHERE intCommissionScheduleId = @intCommissionScheduleId 				  

				WHILE EXISTS (SELECT NULL FROM @tblARCommissionScheduleDetail)
					BEGIN
						DECLARE @intCommissionScheduleDetailId INT 

						SELECT TOP 1 @intCommissionScheduleDetailId = intCommissionScheduleDetailId FROM @tblARCommissionScheduleDetail

						UPDATE tblARCommissionScheduleDetail SET intSort = @sortCounter WHERE intCommissionScheduleDetailId = @intCommissionScheduleDetailId

						DELETE FROM @tblARCommissionScheduleDetail WHERE intCommissionScheduleDetailId = @intCommissionScheduleDetailId

						SET @sortCounter = @sortCounter + 1
					END

				DELETE FROM @tblARCommissionSchedule WHERE intCommissionScheduleId = @intCommissionScheduleId
			END
	END

GO
print('/*******************  END Update tblARCommissionScheduleDetail.intSort  *******************/')