CREATE PROCEDURE [dbo].[uspEMUpdateEntityType]
	@intEntityId AS INT
AS

	DECLARE @entityId AS INT
	SET @entityId = (SELECT intEntityId FROM tblEMEntity WHERE intEntityId = @intEntityId)

	IF (@entityId IS NOT NULL)
	BEGIN
		UPDATE tblEMEntityType
		SET strType = 'Customer'
		WHERE intEntityId = @intEntityId
	END

RETURN 0
