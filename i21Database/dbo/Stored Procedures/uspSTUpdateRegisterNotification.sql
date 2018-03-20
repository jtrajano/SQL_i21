CREATE PROCEDURE [dbo].[uspSTUpdateRegisterNotification]
	@strLocationIds AS NVARCHAR(MAX)
AS
BEGIN
-- Table to handle intEntityId
DECLARE @tblTempEntity TABLE(intId INT NOT NULL IDENTITY, intEntityId INT)

INSERT @tblTempEntity
SELECT DISTINCT
	ITR.intEntityId
FROM vyuSTItemsToRegister ITR
JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = ITR.intEntityId
WHERE SMUS.intCompanyLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strLocationIds))

--TR.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))
--SELECT * FROM @tblTempEntity

DECLARE @Id INT
DECLARE @intEntityId INT

WHILE EXISTS(SELECT * FROM @tblTempEntity)
	BEGIN

		SELECT TOP 1 @Id = intId, @intEntityId = intEntityId From @tblTempEntity

		IF EXISTS(SELECT intEntityId FROM tblSTUpdateRegisterNotification WHERE intEntityId = @intEntityId)
			BEGIN
				UPDATE tblSTUpdateRegisterNotification
				SET ysnClick = 0
				WHERE intEntityId = @intEntityId
				AND ysnClick = 1
			END
		ELSE
			BEGIN
				INSERT INTO tblSTUpdateRegisterNotification(intEntityId)
				VALUES(@intEntityId)
			END

		DELETE @tblTempEntity WHERE intId = @Id

	END

-- TO TEST
--SELECT DISTINCT
--	x.intEntityId
--	, x.intItemId
--	, ICI.strDescription
--FROM vyuSTItemsToRegister x
--JOIN tblEMEntity EM ON EM.intEntityId = x.intEntityId
--JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = EM.intEntityId
--JOIN tblSMCompanyLocation SMCL ON SMCL.intCompanyLocationId = SMUS.intCompanyLocationId
--JOIN tblICItem ICI ON ICI.intItemId = x.intItemId
--WHERE x.intEntityId = 1324
END