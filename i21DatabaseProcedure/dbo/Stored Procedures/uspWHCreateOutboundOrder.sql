CREATE PROCEDURE [dbo].[uspWHCreateOutboundOrder] 
				 @strXML NVARCHAR(MAX)
AS
BEGIN TRY
	DECLARE @idoc INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intOrderHeaderId INT
	DECLARE @strBOLNo NVARCHAR(32)
	DECLARE @strLastUpdateBy NVARCHAR(32)
	DECLARE @intLastUpdateById INT
	DECLARE @intTruckId INT
	DECLARE @intShipToAddressId INT
	DECLARE @intByWorkOrder INT
	DECLARE @intWorkOrderId NVARCHAR(MAX)
	DECLARE @intOrderTypeId INT
	DECLARE @intLocalTran TINYINT

	SET @strErrMsg = ''
	SET NOCOUNT ON

	IF @@TRANCOUNT = 0
		SET @intLocalTran = 1

	IF @intLocalTran = 1
		BEGIN TRANSACTION

	--Create an internal representation of the XML document.                      
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXML

	SELECT @intByWorkOrder = intByWorKOrder
	FROM OPENXML(@idoc, 'root', 2) WITH (intByWorKOrder INT)

	SELECT @intTruckId = ISNULL(intTruckId, 0), 
		   @intShipToAddressId = intShipToAddressId, 
		   @strLastUpdateBy = strLastUpdateBy, 
		   @strBOLNo = strBOLNo, 
		   @intWorkOrderId = intWorkOrderId, 
		   @intOrderTypeId = intOrderTypeId
	FROM OPENXML(@idoc, 'root', 2) WITH 
		   (strLastUpdateBy NVARCHAR(32), 
		   intShipToAddressId INT, 
		   intTruckId INT, 
		   strBOLNo NVARCHAR(32), 
		   intWorkOrderId NVARCHAR(MAX), 
		   intOrderTypeId INT)

	--======================================
	-- NOT SURE ABOUT THIS PART OF THE CODE.
	--======================================

	------IF @intByWorkOrder IS NULL
	------BEGIN
	------	IF @intTruckId = 0
	------	BEGIN
	------		EXECUTE [dbo].[GetErrorMessage] 1000017, NULL, NULL, @strErrMsg OUTPUT
	------		RAISERROR (@strErrMsg, 16, 1)
	------	END
	------END

	--======================================
	-- NOT SURE ABOUT THIS PART OF THE CODE.
	--======================================
	SELECT @intLastUpdateById = [intEntityId] FROM tblSMUserSecurity WHERE strUserName = @strLastUpdateBy

	INSERT INTO tblWHOrderHeader (
		   intOrderStatusId, 
		   intOrderTypeId, 
		   intOrderDirectionId, 
		   strBOLNo, 
		   strCustOrderNo,
		   strReferenceNo, 
		   intOwnerAddressId, 
		   intFreightPaymentAddressId, 
		   intStagingLocationId, 
		   strComment, 
		   dtmRAD, 
		   dtmShipDate, 
		   intFreightTermId,
		   intChep, 
		   intShipFromAddressId, 
		   intShipToAddressId, 
		   intPallets, 
		   intTruckId, 
		   intCreatedById, 
		   dtmCreatedOn, 
		   intLastUpdateById, 
		   dtmLastUpdateOn, 
		   strProNo, 
		   strSpecialInstruction, 
		   dblFreightCharge, 
		   strShipper,
		   intConcurrencyId,
		   intUpdateCounter)
	SELECT intOrderStatusId, 
		   intOrderTypeId, 
		   intOrderDirectionId, 
		   strBOLNo, 
		   strCustOrderNo, 
		   strReferenceNo, 
		   intOwnerAddressId, 
		   intFreightPaymentAddressId, 
		   intStagingLocationId, 
		   strComment, 
		   dtmRAD, 
		   dtmShipDate, 
		   intFreightTermId, 
		   intChep, 
		   intShipFromAddressId, 
		   intShipToAddressId, 
		   intPallets, 
		   intTruckId, 
		   @intLastUpdateById, 
		   GETDATE(), 
		   @intLastUpdateById, 
		   GETDATE(), 
		   strProNo, 
		   strSpecialInstruction, 
		   dblFreightCharge, 
		   strShipper,
		   1,
		   1
	FROM OPENXML(@idoc, 'root', 2) WITH (
		   intOrderStatusId INT, 
		   intOrderTypeId INT, 
		   intOrderDirectionId INT, 
		   strBOLNo NVARCHAR(32), 
		   strCustOrderNo NVARCHAR(32), 
		   strReferenceNo NVARCHAR(32), 
		   intOwnerAddressId INT, 
		   intFreightPaymentAddressId INT, 
		   intStagingLocationId INT, 
		   strComment NVARCHAR(Max), 
		   dtmRAD DATETIME, 
		   dtmShipDate DATETIME, 
		   intFreightTermId INT, 
		   intChep INT, 
		   intShipFromAddressId INT, 
		   intShipToAddressId INT, 
		   intPallets INT, 
		   intTruckId INT, 
		   strProNo NVARCHAR(32), 
		   strSpecialInstruction NVARCHAR(MAX),
		   dblFreightCharge NUMERIC(18,6), 
		   strShipper NVARCHAR(64))

	SELECT @intOrderHeaderId = SCOPE_IDENTITY()

	IF EXISTS (SELECT * FROM dbo.tblWHOrderType WHERE strInternalCode = 'PS' AND intOrderTypeId = @intOrderTypeId)
	BEGIN
		UPDATE dbo.tblMFWorkOrder
		SET intOrderHeaderId = @intOrderHeaderId, strBOLNo = @strBOLNo
		WHERE intWorkOrderId IN (
				SELECT Item
				FROM dbo.fnSplitString(@intWorkOrderId,',')
				)
	END

	--Return the new Order Header Id to the                       
	SELECT @intOrderHeaderId

	--Removes the internal representation of the XML document specified by the document handle and invalidates the document handle.                      
	EXEC sp_xml_removedocument @idoc

	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF @intLocalTran = 1
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = 'uspWHCreateOutboundOrder: ' + @strErrMsg

		RAISERROR (@strErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH