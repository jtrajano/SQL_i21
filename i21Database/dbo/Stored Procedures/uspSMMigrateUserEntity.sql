﻿CREATE PROCEDURE [dbo].[uspSMMigrateUserEntity]

AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN

	/* Fix user security data that shares one entity */
	UPDATE tblSMUserSecurity SET [intEntityUserSecurityId] = NULL WHERE strUserName NOT IN (SELECT strUserName FROM tblEntityCredential)

	DECLARE @UserName NVARCHAR(100)
	DECLARE @FullName NVARCHAR(100)
	DECLARE @Email NVARCHAR(100)
	DECLARE @Password NVARCHAR(100)
	DECLARE @ContactNumber NVARCHAR(100)
	DECLARE @NewId INT

	SELECT strUserName, strFullName, strEmail, strPassword, strPhone
	INTO #tmpUsers
	FROM tblSMUserSecurity
	WHERE ISNULL([intEntityUserSecurityId], 0) <= 0
	--WHERE ysnDisabled = 0
	--AND ISNULL(intEntityId, 0) <= 0

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpUsers)
	BEGIN
		
		SELECT TOP 1 @UserName = strUserName,
			@FullName = strFullName,
			@Email = strEmail,
			@Password = strPassword,
			@ContactNumber = strPhone
		FROM #tmpUsers
		
		--IF NOT EXISTS(SELECT * FROM tblEntity WHERE strName = @FullName AND strEmail = @Email)
		--BEGIN
			INSERT INTO tblEntity(strName, strEmail, strContactNumber)
			VALUES (@FullName, @Email, @ContactNumber)
			SELECT @NewId = SCOPE_IDENTITY()
		--END
		--ELSE
		--BEGIN
		--	SELECT @NewId = intEntityId FROM tblEntity WHERE strName = @FullName AND strEmail = @Email
		--END
		
		UPDATE tblSMUserSecurity
		SET [intEntityUserSecurityId] = @NewId
		WHERE strUserName = @UserName
		AND ISNULL([intEntityUserSecurityId], 0) = 0
		
		IF NOT EXISTS(SELECT * FROM tblEntityCredential WHERE intEntityId = @NewId)
		BEGIN
			INSERT INTO tblEntityCredential(intEntityId, strUserName, strPassword)
			VALUES (@NewId, @UserName, @Password)
		END
		
		DELETE FROM #tmpUsers WHERE strUserName = @UserName
	END

	DROP TABLE #tmpUsers
	
	EXEC uspSMMigrateTransactionUser 'GL'
	EXEC uspSMMigrateTransactionUser 'AP'
	EXEC uspSMMigrateTransactionUser 'CM'

END