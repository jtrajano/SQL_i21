CREATE FUNCTION [dbo].[fnCTGetShipmentStatus]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	strShipmentStatus	NVARCHAR(100)  COLLATE Latin1_General_CI_AS
)
AS
BEGIN
	INSERT INTO @returntable	
	SELECT TOP 1 strShipmentStatus
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY intPContractDetailId ORDER BY dtmScheduledDate desc) AS intNumberId
			,intContractDetailId = intPContractDetailId
			,strShipmentStatus
			,intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM
			vyuCTShipmentStatus
		WHERE
			isnull(intPContractDetailId,0) = @intContractDetailId
			AND ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)

		union all

		SELECT
			ROW_NUMBER() OVER(PARTITION BY intSContractDetailId ORDER BY dtmScheduledDate desc) AS intNumberId
			,intContractDetailId = intPContractDetailId
			,strShipmentStatus
			,intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM
			vyuCTShipmentStatus
		WHERE
			isnull(intSContractDetailId,0) = @intContractDetailId
			AND ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
	) tbl
	WHERE intNumberId = 1
	ORDER BY intPriorityId ASC
	RETURN;
END