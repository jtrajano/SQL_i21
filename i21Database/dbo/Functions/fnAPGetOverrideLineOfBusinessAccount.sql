CREATE FUNCTION [dbo].[fnAPGetOverrideLineOfBusinessAccount]
(
	@intAccountId INT,
	@intItemId INT
	
)
RETURNS @returntable TABLE
(
	[intOverrideAccount]	INT,
	[strOverrideAccount]	NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[bitOverriden]			BIT
)
AS
BEGIN
	DECLARE @intSegmentCodeId INT
	DECLARE @intTemplateAccountId INT

	SELECT @intSegmentCodeId = LOB.intSegmentCodeId
	FROM tblICItem I
	INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	INNER JOIN tblSMLineOfBusiness LOB ON LOB.intLineOfBusinessId = C.intLineOfBusinessId
	WHERE I.intItemId = @intItemId

	SELECT TOP 1 @intTemplateAccountId = intAccountId
	FROM vyuGLLineOfBusinessAccountId 
	WHERE intAccountSegmentId = @intSegmentCodeId

	INSERT @returntable
	SELECT intOverrideAccount, strOverrideAccount, bitOverriden
	FROM dbo.fnARGetOverrideAccount(ISNULL(@intTemplateAccountId, @intAccountId), @intAccountId, 0, 0, 1)

	RETURN
END