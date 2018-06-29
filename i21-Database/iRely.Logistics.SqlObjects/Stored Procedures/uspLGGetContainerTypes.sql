CREATE PROCEDURE uspLGGetContainerTypes
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
		SELECT *
		FROM vyuLGContainerTypeNotMapped
	END
END
