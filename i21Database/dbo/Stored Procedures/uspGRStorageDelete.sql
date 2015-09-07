CREATE PROCEDURE [dbo].[uspGRStorageDelete]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @intCustomerStorageId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @intItemId INT
	DECLARE @intItemLocationId INT
	DECLARE @ysnUpdateHouseTotal INT
	DECLARE @dblOpenBalance DECIMAL(24, 10)

	EXEC sp_xml_preparedocument @idoc OUTPUT ,@strXml

	SELECT @intCustomerStorageId = intCustomerStorageId
		,@ysnUpdateHouseTotal = ysnUpdateHouseTotal
	FROM OPENXML(@idoc, 'root', 2) WITH 
	(			
			 intCustomerStorageId INT
			,ysnUpdateHouseTotal INT
	)

	SELECT @dblOpenBalance = dblOpenBalance
		,@intCompanyLocationId = intCompanyLocationId
		,@intItemId = intItemId
	FROM tblGRCustomerStorage
	WHERE intCustomerStorageId = @intCustomerStorageId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId AND intLocationId = @intCompanyLocationId

	IF @ysnUpdateHouseTotal = 1
	BEGIN
		UPDATE tblICItemStock
		SET dblUnitInCustody = dblUnitInCustody - @dblOpenBalance
		WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
	END
	ELSE
	BEGIN
		UPDATE tblICItemStock
		SET dblUnitInCustody = dblUnitInCustody - @dblOpenBalance
			,dblUnitOnHand = dblUnitOnHand - @dblOpenBalance WHERE intItemId = @intItemId AND intItemLocationId = @intItemLocationId
	END

	DELETE tblQMTicketDiscount
	WHERE intTicketFileId = @intCustomerStorageId
		AND strSourceType = 'Storage'

	DELETE tblGRCustomerStorage	WHERE intCustomerStorageId = @intCustomerStorageId

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	
END CATCH