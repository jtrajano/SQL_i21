CREATE PROCEDURE uspIPGenerateFeedXML_SAP @strType NVARCHAR(50)
	,@limit INT = 0
	,@offset INT = 0
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF @strType = 'PO'
	BEGIN
		EXEC dbo.uspIPGenerateSAPPO_EK @ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Price Simulation'
	BEGIN
		EXEC dbo.uspIPGenerateSAPPrice_EK @ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Lead Time'
	BEGIN
		EXEC dbo.uspIPGenerateSAPLeadTime_EK @ysnUpdateFeedStatus = 1
			,@limit = @limit
			,@offset = @offset
	END
	ELSE IF @strType = 'Lead Time SAP'
	BEGIN
		EXEC dbo.uspIPGenerateSAPLeadTimeBulk_EK @ysnUpdateFeedStatus = 1
			,@limit = @limit
			,@offset = @offset
	END
	ELSE IF @strType = 'Tea Lingo Item'
	BEGIN
		EXEC dbo.uspIPGenerateSAPItem_EK @ysnUpdateFeedStatus = 1
			,@limit = @limit
			,@offset = @offset
	END
	ELSE IF @strType = 'Contracted Stock'
	BEGIN
		EXEC dbo.uspIPGenerateERPContractedStock @ysnUpdateFeedStatus = 1
			,@limit = @limit
			,@offset = @offset
	END
	ELSE IF @strType = 'Auction Stock'
	BEGIN
		EXEC dbo.uspIPGenerateERPAuctionStock @ysnUpdateFeedStatus = 1
			,@limit = @limit
			,@offset = @offset
	END
	Else if @strType = 'Confirmed Blendsheet'
	Begin
		EXEC dbo.uspMFGenerateERPProductionOrder_EK 
			@limit = @limit
			,@offset = @offset
			,@ysnUpdateFeedStatus = 1
	End
	Else if @strType = 'Recall Blendsheet'
	Begin
		EXEC dbo.uspMFGenerateERPRecallProductionOrder_EK  
			@limit = @limit
			,@offset = @offset
			,@ysnUpdateFeedStatus = 1
	End
	Else if @strType = 'Stock Recategorization'
	Begin
		EXEC dbo.uspIPGenerateERPBatchRecategorization_EK  
			@limit = @limit
			,@offset = @offset
			,@ysnUpdateFeedStatus = 1
	End
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
