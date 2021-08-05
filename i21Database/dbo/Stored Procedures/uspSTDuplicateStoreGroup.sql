CREATE PROCEDURE [dbo].[uspSTDuplicateStoreGroup]
	@intStoreGroupId	NVARCHAR(MAX)
AS
BEGIN


BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @strDuplicateStoreGroupName VARCHAR(250) 
	SELECT TOP 1 @strDuplicateStoreGroupName = strStoreGroupName + '-copy' FROM tblSTStoreGroup WHERE intStoreGroupId = @intStoreGroupId

	WHILE EXISTS (SELECT intStoreGroupId FROM tblSTStoreGroup WHERE strStoreGroupName = @strDuplicateStoreGroupName)
	BEGIN
		SELECT TOP 1 @strDuplicateStoreGroupName = @strDuplicateStoreGroupName + '-copy' FROM tblSTStoreGroup WHERE strStoreGroupName = @strDuplicateStoreGroupName
	END

	DECLARE @NewStoreGroupId INT
	
	---------Header Store Group---------
	INSERT INTO tblSTStoreGroup
	(
		 strStoreGroupName
		,strStoreGroupDescription
		,intConcurrencyId
	)
	SELECT TOP 1
		@strDuplicateStoreGroupName
		,strStoreGroupDescription
		,intConcurrencyId
	FROM tblSTStoreGroup
	WHERE ISNULL(intStoreGroupId,0) = ISNULL(@intStoreGroupId,0)

	SET @NewStoreGroupId = SCOPE_IDENTITY()
	
	---------Detail Store Group---------
	INSERT INTO tblSTStoreGroupDetail
	(
		 intStoreGroupId
		,intStoreId
		,intConcurrencyId
	)
	SELECT 
		@NewStoreGroupId
		,intStoreId
		,intConcurrencyId
	FROM tblSTStoreGroupDetail
	WHERE ISNULL(intStoreGroupId,0) = ISNULL(@intStoreGroupId,0)

	COMMIT TRANSACTION	

	SELECT @NewStoreGroupId AS intStoreGroupId, CAST(1 AS BIT) AS ysnResult

	END TRY
	BEGIN CATCH
	
	SELECT 0 AS intStoreGroupId, CAST(0 AS BIT) AS ysnResult

	SELECT ERROR_MESSAGE()

	ROLLBACK TRANSACTION

	END CATCH
	
END