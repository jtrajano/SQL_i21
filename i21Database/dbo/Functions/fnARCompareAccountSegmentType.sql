CREATE FUNCTION [dbo].[fnARCompareAccountSegmentType]
(
	  @AccountId1		INT
	 ,@AccountId2		INT
	 ,@intSegmentTypeId	INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @SameSegmentType BIT = 0

	SELECT @SameLocation = CASE WHEN COUNT(intSegmentTypeId) > 1 THEN 0 ELSE 1 END
	FROM (
		SELECT intSegmentTypeId
		FROM vyuGLSegmentMapping
		WHERE intAccountId IN (@AccountId1, @AccountId2)
		AND	intSegmentTypeId = @intSegmentTypeId
		GROUP BY intSegmentTypeId
	) GLLAI

	RETURN @SameSegmentType
END