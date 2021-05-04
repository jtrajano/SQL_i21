﻿CREATE PROCEDURE uspIPGenerateFeedXML_ERP @strCompanyLocation NVARCHAR(6)
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
	ELSE IF @strType = 'PO'
	BEGIN
		EXEC dbo.uspIPGenerateERPPO @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'CO'
	BEGIN
		EXEC dbo.uspIPGenerateERPCO @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Goods Receipt'
	BEGIN
		EXEC dbo.uspIPGenerateERPGoodsReceipt @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Service Order'
	BEGIN
		EXEC dbo.uspMFGenerateERPServiceOrder @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Production'
	BEGIN
		EXEC dbo.uspMFGenerateERPProduction @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Lot Merge'
	BEGIN
		EXEC dbo.uspIPGenerateERPLotMerge @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Lot Property Adj'
	BEGIN
		EXEC dbo.uspIPGenerateERPLotProperty @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
	END
	ELSE IF @strType = 'Lot Split'
	BEGIN
		EXEC dbo.uspIPGenerateERPLotSplit @strCompanyLocation = @strCompanyLocation
			,@ysnUpdateFeedStatus = 1
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
