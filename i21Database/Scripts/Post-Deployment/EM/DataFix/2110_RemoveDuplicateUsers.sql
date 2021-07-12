PRINT N'Start removing user entity to contact with duplicates'

GO

DECLARE @tblEMEntityWithDuplicate TABLE (
	intEntityId INT
)

DECLARE @tblEMEntityContactDuplicateToDelete TABLE (
	intEntityId INT
)

/* Get user entities to contact with duplicates */

INSERT INTO @tblEMEntityWithDuplicate
SELECT A.intEntityId FROM tblEMEntityToContact A
	INNER JOIN tblSMUserSecurity B ON A.intEntityId = B.intEntityId
	GROUP BY A.intEntityId
	HAVING COUNT(*) > 1

IF (SELECT COUNT(*) FROM @tblEMEntityWithDuplicate) > 0
BEGIN
	INSERT INTO @tblEMEntityContactDuplicateToDelete
	SELECT intEntityContactId FROM tblEMEntityToContact A
		INNER JOIN tblEMEntity B ON A.intEntityContactId = B.intEntityId
		WHERE A.intEntityId IN (SELECT intEntityId FROM @tblEMEntityWithDuplicate) AND (ISNULL(strEmail, '') = '')
	
	/* delete duplicates with entity's contact email is null or empty string, since creating a user requires email */

	DELETE FROM tblEMEntityToContact WHERE intEntityContactId IN (SELECT * FROM @tblEMEntityContactDuplicateToDelete)
END

GO

PRINT N'End removing user entity to contact with duplicates'