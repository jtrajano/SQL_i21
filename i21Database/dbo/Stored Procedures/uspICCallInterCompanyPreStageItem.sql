alter PROCEDURE uspICCallInterCompanyPreStageItem 
	@strItemNo NVARCHAR(50) 
	,@strRowState NVARCHAR(50)
	,@intUserId INT
AS
SET NOCOUNT ON

DECLARE @intItemId AS INT
DECLARE @ErrMsg NVARCHAR(MAX)

SELECT TOP 1 @intItemId = intItemId FROM tblICItem i WHERE i.strItemNo = @strItemNo

IF @intItemId IS NOT NULL 
BEGIN
	BEGIN TRY
		EXEC uspIPInterCompanyPreStageItem	
			@intItemId 
			,@strRowState 
			,@intUserId 
	END TRY
	BEGIN CATCH		
		SET @ErrMsg = ERROR_MESSAGE()

		RAISERROR (
				@ErrMsg
				,16
				,1
				,'WITH NOWAIT'
				)
	END CATCH
END