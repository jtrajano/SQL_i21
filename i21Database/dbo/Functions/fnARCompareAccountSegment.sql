CREATE FUNCTION [dbo].[fnARCompareAccountSegment]
(
	  @AccountId1		INT
	 ,@AccountId2		INT
	 ,@intSegmentTypeId	INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @SameAccountSegment BIT = 0

	SELECT @SameAccountSegment = CASE WHEN COUNT(intAccountSegmentId) > 1 THEN 0 ELSE 1 END
	FROM (
		SELECT intAccountSegmentId
		FROM vyuGLSegmentMapping
		WHERE intAccountId IN (@AccountId1, @AccountId2)
		AND	intSegmentTypeId = @intSegmentTypeId
		GROUP BY intAccountSegmentId
	) GLLAI

	RETURN @SameAccountSegment
END