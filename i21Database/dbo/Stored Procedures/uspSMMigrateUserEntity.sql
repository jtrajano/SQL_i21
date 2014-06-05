CREATE PROCEDURE [dbo].[uspSMMigrateUserEntity]

AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	INSERT INTO tblEntity(strName, strEmail)
	SELECT strUserName, strEmail FROM tblSMUserSecurity
	WHERE ysnDisabled = 0
	AND strUserName NOT IN (SELECT strName FROM tblEntity)

	UPDATE tblSMUserSecurity
	SET intEntityId = tblPatch.intEntityId
	FROM (
		SELECT Entity.intEntityId, Entity.strName
		FROM tblEntity Entity
		INNER JOIN tblSMUserSecurity [User] ON [User].strUserName = Entity.strName
	) tblPatch
	WHERE tblPatch.strName = tblSMUserSecurity.strUserName

	INSERT INTO tblEntityCredential(intEntityId, strUserName, strPassword)
	SELECT intEntityId, strUserName, strPassword FROM tblSMUserSecurity
	WHERE intEntityId NOT IN (SELECT intEntityId FROM tblEntityCredential)

END