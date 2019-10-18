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
		SELECT ROW_NUMBER() OVER(PARTITION BY intLoadDetailId ORDER BY dtmScheduledDate) AS intNumberId, strShipmentStatus, intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM vyuCTShipmentStatus
		WHERE (intPContractDetailId = @intContractDetailId or intSContractDetailId = @intContractDetailId)
		AND ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
	) tbl
	WHERE intNumberId = 1
	ORDER BY intPriorityId ASC
	RETURN;
END