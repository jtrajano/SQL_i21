CREATE PROCEDURE [dbo].[uspEMUpdateEntityGroup]
@action CHAR(1),
@entityGroupDetailId INT,
@entityGroupId INT,
@entityId INT

AS
BEGIN

IF(ISNULL(@action,'') = '' or ISNULL(@entityGroupDetailId, '') = '' 
OR ISNULL(@entityGroupId,'') = '' OR  ISNULL(@entityId,'') = '')
BEGIN
	PRINT 'Parameters are required!'
	RETURN;
END
 
 IF (@action = 'I')
 BEGIN

	IF EXISTS(SELECT 1  FROM tblAPVendor WHERE intEntityId = @entityId)
	BEGIN
	PRINT 'this is vendor insert ' + CAST(@entityGroupId AS NVARCHAR(MAX))
	--if it exists on other group should not update the vendor setup
	IF NOT EXISTS(SELECT 1  FROM tblEMEntityGroupDetail WHERE intEntityId = @entityId 
	AND intEntityGroupId <> @entityGroupId)
		BEGIN
			UPDATE tblAPVendor SET intEntityGroupId = @entityGroupId WHERE intEntityId = @entityId
		END
	END
END
ELSE IF(@action = 'U')
	BEGIN

	  DECLARE @newId INT = (SELECT intEntityId FROM tblEMEntityGroupDetail WHERE intEntityGroupDetailId = @entityGroupDetailId)
	  DECLARE @groupId INT = (SELECT intEntityGroupId FROM tblEMEntityGroupDetail WHERE intEntityGroupDetailId = @entityGroupDetailId)

	  IF EXISTS (SELECT 1  FROM tblAPVendor WHERE intEntityId = @entityId
				AND intEntityGroupId = @entityGroupId)
				BEGIN

				  UPDATE tblAPVendor SET intEntityGroupId = @groupId WHERE intEntityId = @newId
				  --set null to former
				  UPDATE tblAPVendor SET intEntityGroupId = NULL WHERE intEntityId = @entityId
				END

	END
ELSE IF (@action = 'D')
	BEGIN

		PRINT 'this is vendor DELETE ' + cast(@entityId as nvarchar(max))
		--delete on vendor setup when it entity group is deleted on em same with vendor
		IF EXISTS(SELECT 1 FROM tblAPVendor WHERE intEntityId = @entityId
				AND intEntityGroupId = @entityGroupId)
		BEGIN
			UPDATE tblAPVendor SET intEntityGroupId = NULL WHERE intEntityId = @entityId;
		END
	END

END