CREATE FUNCTION [dbo].[fnCTGetShipmentStatus]
(
	@intContractDetailId	INT
)
RETURNS table as return
	SELECT TOP 1 strShipmentStatus = strShipmentStatus COLLATE Latin1_General_CI_AS
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY intPContractDetailId ORDER BY intShipmentType, dtmScheduledDate desc) AS intNumberId
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
			ROW_NUMBER() OVER(PARTITION BY intSContractDetailId ORDER BY intShipmentType, dtmScheduledDate desc) AS intNumberId
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