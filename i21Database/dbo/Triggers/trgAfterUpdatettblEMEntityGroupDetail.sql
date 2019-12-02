CREATE TRIGGER [dbo].[trgAfterUpdatettblEMEntityGroupDetail]
	 ON [dbo].[tblEMEntityGroupDetail] 
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	DECLARE @table TABLE
	(
		 [intEntityGroupDetailId] INT primary key,
		 [intEntityGroupId] INT,
		 [intEntityId] INT
	)
DECLARE @type NVARCHAR(1) = N'';

IF EXISTS(SELECT TOP 1 1 FROM INSERTED)
BEGIN
	IF EXISTS(SELECT 1 FROM DELETED)
		BEGIN
			INSERT INTO @table(intEntityGroupDetailId, intEntityGroupId, intEntityId) 
			SELECT intEntityGroupDetailId, intEntityGroupId,intEntityId FROM DELETED

			PRINT 'i am updated'
			SET @type = 'U'
		END
	ELSE
		BEGIN
			INSERT INTO @table(intEntityGroupDetailId, intEntityGroupId, intEntityId) 
			SELECT intEntityGroupDetailId,intEntityGroupId,intEntityId  FROM INSERTED

			SET @type = 'I'
			print 'i am inserted'
		END
END
ELSE
	BEGIN

		INSERT INTO @table(intEntityGroupDetailId, intEntityGroupId, intEntityId) 
		SELECT intEntityGroupDetailId, intEntityGroupId,intEntityId FROM deleted

		SET @type = 'D'
		PRINT 'i am deleted'
	END

	WHILE EXISTS(SELECT TOP 1 1 FROM @table)
		BEGIN
			DECLARE @groupDetailId INT = (SELECT TOP 1 intEntityGroupDetailId FROM @table)
			DECLARE @groupId INT = (SELECT TOP 1 intEntityGroupId FROM @table WHERE intEntityGroupDetailId = @groupDetailId)
			DECLARE @entityId INT = (SELECT TOP 1 intEntityId FROM @table)

			PRINT 'while loop'
	
			EXEC uspEMUpdateEntityGroup 
						@action = @type,
						@entityGroupDetailId = @groupDetailId,
						@entityGroupId = @groupId,
						@entityId = @entityId

			DELETE FROM @table WHERE intEntityGroupDetailId = @groupDetailId
		END
END
