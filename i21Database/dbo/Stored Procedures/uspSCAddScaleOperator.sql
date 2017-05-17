CREATE PROCEDURE [dbo].[uspSCAddScaleOperator]
	@strName NVARCHAR (100)
	,@intEntityId AS INT OUTPUT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	insert into tblEMEntity(strName, strContactNumber)
	select @strName, @strName

	set @intEntityId = @@IDENTITY

	insert into tblEMEntityType(strType, intEntityId, intConcurrencyId)
	select 'Operator', @intEntityId, 1

	RETURN @intEntityId
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

