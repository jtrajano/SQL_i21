CREATE PROCEDURE [dbo].[uspUBSCreateDriverEntity]
	@strDriverName NVARCHAR(200),
	@strPhoneNum NVARCHAR(50),
	@intShipViaId INT,
	@strI21UserName NVARCHAR(50)
AS
BEGIN
	DECLARE @Id NVARCHAR(100)
	DECLARE @UserId INT
	DECLARE @EntityId INT
	DECLARE @Message NVARCHAR(100)

	SELECT TOP 1 @Id = ISNULL(strEntityNo + 1, 1)
	FROM tblEMEntity 
	WHERE strEntityNo IS NOT NULL AND strEntityNo <> ''
	ORDER BY intEntityId DESC

	SELECT @UserId = intEntityId
	FROM tblSMUserSecurity
	WHERE strUserName = @strI21UserName

	EXEC uspEMCreateEntityById
	@Id = @Id,
	@Type = 'Salesperson',
	@UserId = @UserId,
	@Message = @Message OUTPUT,
	@EntityId = @EntityId OUTPUT

	IF (@EntityId IS NULL)
	BEGIN
		RAISERROR(@Message, 16, 1)
		RETURN 0
	END
	ELSE
	BEGIN
		UPDATE tblEMEntity SET
		strName = @strDriverName, strPhone = @strPhoneNum
		WHERE strName = CONVERT(nvarchar(50), @Id)

		INSERT INTO tblARSalesperson (intEntityId, strType, intShipViaId)
		VALUES (@EntityId, 'Driver', @intShipViaId)
	END
END