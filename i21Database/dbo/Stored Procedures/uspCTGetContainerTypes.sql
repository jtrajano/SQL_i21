CREATE PROCEDURE [dbo].[uspCTGetContainerTypes]
		@strOrigin NVARCHAR(100) = NULL
	,@intCommodityId INT = NULL
AS
BEGIN
	DECLARE @ysnLoadContainerTypeByOrigin BIT

	SELECT @ysnLoadContainerTypeByOrigin = ysnLoadContainerTypeByOrigin
	FROM tblLGCompanyPreference

	IF (ISNULL(@ysnLoadContainerTypeByOrigin, 0) = 0 or isnull(@strOrigin,'') = '')
	BEGIN
		SELECT *
		FROM vyuLGContainerType
	END
	ELSE
	BEGIN
		SELECT distinct b.*
		FROM
			vyuLGContainerTypeNotMapped a
			join vyuLGContainerType b on b.intContainerTypeId = a.intContainerTypeId
		WHERE
			a.strOrigin = @strOrigin
	END
END