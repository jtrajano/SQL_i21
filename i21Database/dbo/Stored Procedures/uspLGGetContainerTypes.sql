CREATE PROCEDURE uspLGGetContainerTypes
	@strOrigin NVARCHAR(100) = NULL
	,@intCommodityId INT = NULL
AS
BEGIN
	DECLARE @ysnLoadContainerTypeByOrigin BIT

	SELECT @ysnLoadContainerTypeByOrigin = ysnLoadContainerTypeByOrigin
	FROM tblLGCompanyPreference

	IF (ISNULL(@ysnLoadContainerTypeByOrigin, 0) = 0)
	BEGIN
		SELECT *
		FROM vyuLGContainerType
	END
	ELSE
	BEGIN
		IF (
				ISNULL(@strOrigin, '') <> ''
				AND ISNULL(@intCommodityId, 0) <> 0
				)
		BEGIN
			SELECT *
			FROM vyuLGContainerTypeNotMapped
			WHERE strOrigin = @strOrigin
				AND intCommodityId = @intCommodityId
		END
		ELSE
		BEGIN
			SELECT *
			FROM vyuLGContainerTypeNotMapped 
			WHERE strOrigin = @strOrigin
		END
	END
END