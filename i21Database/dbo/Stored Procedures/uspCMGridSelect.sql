CREATE PROCEDURE uspCMGridSelect
(
	@guidId UNIQUEIDENTIFIER,
	@strType NVARCHAR(40),
	@intRelatedId INT = NULL

)
AS
BEGIN
	IF @intRelatedId IS NULL
	BEGIN
		DELETE FROM tblCMGridSelectedRow WHERE strType = @strType
		INSERT INTO tblCMGridSelectedRow (guidId, strType, intRelatedId)
		SELECT @guidId, @strType, intEntityEFTInfoId FROM vyuEntityEFTInformation
		WHERE
		(ISNULL(dtmEffectiveDate, '2030-01-01') <= GETUTCDATE())
		AND ISNULL(ysnActive,0) = 1
		AND ISNULL(ysnPrenoteSent,0) = 0
		AND ISNULL(Vendor, 0) = 1
	END
	ELSE
	BEGIN
		INSERT INTO tblCMGridSelectedRow (guidId, strType, intRelatedId)
		SELECT @guidId, @strType, @intRelatedId
	END

END