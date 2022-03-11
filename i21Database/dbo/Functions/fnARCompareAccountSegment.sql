CREATE FUNCTION [dbo].[fnARCompareAccountSegment]
(
	  @AccountId1 INT
	 ,@AccountId2 INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @SameLocation BIT = 0

	SELECT @SameLocation = CASE WHEN COUNT(intAccountSegmentId) > 1 THEN 0 ELSE 1 END
	FROM (
		SELECT intAccountSegmentId
		FROM vyuGLLocationAccountId
		WHERE intAccountId IN (47, 38734)
		GROUP BY intAccountSegmentId
	) GLLAI

	RETURN @SameLocation
END