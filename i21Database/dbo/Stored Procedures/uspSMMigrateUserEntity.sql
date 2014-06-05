CREATE PROCEDURE [dbo].[uspSMMigrateUserEntity]

AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @UserName NVARCHAR(100)
	DECLARE @FullName NVARCHAR(100)
	DECLARE @Email NVARCHAR(100)
	DECLARE @Password NVARCHAR(100)
	DECLARE @NewId INT

	SELECT strUserName, strFullName, strEmail, strPassword
	INTO #tmpUsers
	FROM tblSMUserSecurity
	WHERE ysnDisabled = 0
	AND ISNULL(intEntityId, 0) <= 0

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpUsers)
	BEGIN
		
		SELECT TOP 1 @UserName = strUserName, 
			@FullName = strFullName,
			@Email = strEmail,
			@Password = strPassword
		FROM #tmpUsers
		
		INSERT INTO tblEntity(strName, strEmail)
		VALUES (@FullName, @Email)
		
		SELECT @NewId = SCOPE_IDENTITY()
		
		UPDATE tblSMUserSecurity
		SET intEntityId = @NewId
		WHERE strUserName = @UserName
		AND ISNULL(intEntityId, 0) = 0
		
		INSERT INTO tblEntityCredential(intEntityId, strUserName, strPassword)
		VALUES (@NewId, @UserName, @Password)
		
		DELETE FROM #tmpUsers WHERE strUserName = @UserName
	END

	DROP TABLE #tmpUsers

END