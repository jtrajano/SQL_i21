CREATE PROCEDURE [dbo].[uspEMUpdateEntityGroupForVendor]
@entityId INT,
@oldEntityGroupId INT = NULL,
@entityGroupId INT

AS

BEGIN

	IF (ISNULL(@oldEntityGroupId,0) = 0 and
			ISNULL(@entityGroupId,0) = 0)
	BEGIN
		PRINT 'Old Entity Group Id and Group Id cannot be both null'
		RETURN;
	END

	IF (ISNULL(@oldEntityGroupId,0) = 0)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM tblEMEntityGroupDetail WHERE intEntityId = @entityId
			AND intEntityGroupId = @entityGroupId)
		BEGIN
			--insert 
			INSERT INTO tblEMEntityGroupDetail (intEntityGroupId, intEntityId, intConcurrencyId)
			VALUES(@entityGroupId, @entityId, 1)
		END
	END
	ELSE
		BEGIN
		IF(ISNULL(@entityGroupId,0) <> 0)
			BEGIN
			--necessary for multiple link must update only the group where it belong 
				UPDATE tblEMEntityGroupDetail SET intEntityGroupId = @entityGroupId 
						WHERE intEntityId = @entityId AND intEntityGroupId = @oldEntityGroupId
			END
		ELSE
			BEGIN
				DELETE FROM tblEMEntityGroupDetail WHERE intEntityId = @entityId
				AND intEntityGroupId = @oldEntityGroupId
			END

		END

		
END