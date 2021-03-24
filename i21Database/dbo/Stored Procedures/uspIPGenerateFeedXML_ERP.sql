CREATE PROCEDURE uspIPGenerateFeedXML_ERP @strCompanyLocation NVARCHAR(6)
	,@strType NVARCHAR(50)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF @strType = 'Production Order'
	BEGIN
		EXEC dbo.uspMFGenerateERPProductionOrder @strCompanyLocation = @strCompanyLocation
	END
	ELSE IF @strType = 'Quantity Adj Ack'
	BEGIN
		EXEC dbo.uspMFGenerateERPInventoryAdjustAck @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
			,@intTransactionTypeId = 10
	END
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
