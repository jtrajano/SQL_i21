CREATE PROCEDURE [dbo].[uspSMIncreaseECConcurrency]
	@id int,
	@role bit = 0,
	@entity bit = 0
AS
BEGIN
	
	IF @entity = 1
	BEGIN
		UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
		FROM tblEMEntityCredential t
		WHERE intEntityId = @id
	END
	ELSE IF @role = 1
	BEGIN
		DECLARE @roleType NVARCHAR(15)
		SELECT @roleType = strRoleType FROM tblSMUserRole WHERE intUserRoleID = @id

		IF @roleType = 'Contact'
		BEGIN
			UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
			FROM tblEMEntityCredential t
			WHERE intEntityId IN (SELECT intEntityId FROM tblEMEntityToContact WHERE intEntityRoleId = @id)
		END
		ELSE IF @roleType = 'Contact Admin'
		BEGIN
			UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
			FROM tblEMEntityCredential t
			WHERE intEntityId IN 
			(
				SELECT DISTINCT c.intEntityContactId FROM tblSMUserRole a
				INNER JOIN tblEMEntityToRole b ON a.intUserRoleID = b.intEntityRoleId
				INNER JOIN tblEMEntityToContact c ON b.intEntityId = c.intEntityId
				WHERE a.intUserRoleID  = @id
			)
		END
		ELSE IF @roleType = 'Portal Default'
		BEGIN
			UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
			FROM tblEMEntityCredential t
			WHERE intEntityId IN 
			(
				SELECT DISTINCT c.intEntityContactId FROM tblSMUserRole a
				INNER JOIN tblEMEntityToRole b ON a.intUserRoleID = b.intEntityRoleId
				INNER JOIN tblEMEntityToContact c ON b.intEntityId = c.intEntityId
			)
		END
		ELSE
		BEGIN
			UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
			FROM tblEMEntityCredential t
			WHERE intEntityId IN 
			(
				SELECT DISTINCT intEntityId
				FROM
				(
					SELECT intEntityId FROM tblSMUserSecurity WHERE intUserRoleID = @id
					UNION ALL
					SELECT a.intEntityId FROM tblSMUserSecurity a
					INNER JOIN tblSMUserRoleSubRole b ON a.intUserRoleID = b.intUserRoleId
					WHERE b.intSubRoleId = @id
					UNION ALL
					SELECT a.intEntityId FROM tblSMUserSecurity a
					INNER JOIN tblSMUserSecurityCompanyLocationRolePermission b ON a.intUserRoleID = b.intUserRoleId
					WHERE b.intUserRoleId = @id
				) tbl
			)
		END
	END
	ELSE IF @id = 0
	BEGIN
		UPDATE t SET intConcurrencyId = (t.intConcurrencyId + 1)
		FROM tblEMEntityCredential t
	END

END