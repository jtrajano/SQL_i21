CREATE PROCEDURE uspIPGenerateFeedXML_SAP @strType NVARCHAR(50)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF @strType = 'PO'
	BEGIN
		EXEC dbo.uspIPGenerateSAPPO @ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Lead Time'
	BEGIN
		EXEC dbo.uspIPGenerateSAPLeadTime @ysnUpdateFeedStatus = 1
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
