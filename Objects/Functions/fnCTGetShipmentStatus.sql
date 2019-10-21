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
    FROM vyuCTShipmentStatus
    WHERE (intPContractDetailId = @intContractDetailId or intSContractDetailId = @intContractDetailId)
    AND ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
    ORDER BY dtmScheduledDate, intLoadDetailId DESC
	RETURN;
END