CREATE FUNCTION [dbo].[fnCTGetShipmentStatus]
(
	@intContractDetailId	INT
)
RETURNS table as return
	SELECT TOP 1 strShipmentStatus = strShipmentStatus COLLATE Latin1_General_CI_AS
	FROM
	(
		SELECT ROW_NUMBER() OVER(PARTITION BY intLoadDetailId ORDER BY dtmScheduledDate) AS intNumberId, strShipmentStatus, intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM vyuCTShipmentStatus
		WHERE (intPContractDetailId = @intContractDetailId or intSContractDetailId = @intContractDetailId)
		AND ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
	) tbl
	WHERE intNumberId = 1
	ORDER BY intPriorityId ASC