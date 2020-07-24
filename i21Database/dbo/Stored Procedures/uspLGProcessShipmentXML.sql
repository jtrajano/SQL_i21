CREATE PROCEDURE dbo.uspLGProcessShipmentXML (
	@strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@ysnDropShip BIT = 0
	,@intMultiCompanyId INT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intId INT
		,@intLoadId INT
		,@strLoadNumber NVARCHAR(MAX)
		,@strLoad NVARCHAR(MAX)
		,@strLoadDetail NVARCHAR(MAX)
		,@strLoadDetailLot NVARCHAR(MAX)
		,@strLoadDocument NVARCHAR(MAX)
		,@strLoadNotifyParty NVARCHAR(MAX)
		,@strLoadContainer NVARCHAR(MAX)
		,@strLoadDetailContainerLink NVARCHAR(MAX)
		,@strLoadWarehouse NVARCHAR(MAX)
		,@strLoadWarehouseServices NVARCHAR(MAX)
		,@strLoadWarehouseContainer NVARCHAR(MAX)
		,@strLoadCost NVARCHAR(MAX)
		,@strLoadStorageCost NVARCHAR(MAX)
		,@strReference NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@strFeedStatus NVARCHAR(MAX)
		,@dtmFeedDate DATETIME
		,@strMessage NVARCHAR(MAX)
		--,@intMultiCompanyId INT
		,@intReferenceId INT
		,@intEntityId INT
		,@strTransactionType NVARCHAR(MAX)
		,@strTagRelaceXML NVARCHAR(MAX)
		,@NewLoadId INT
		,@NewLoadDetailId INT
		,@NewLoadDocumentId INT
		,@NewLoadNotifyPartyId INT
		,@NewLoadContainerId INT
		,@NewLoadDetailContainerLinkId INT
		,@NewLoadWarehouseId INT
		,@NewLoadWarehouseContainerId INT
		,@NewLoadWarehouseServicesId INT
		,@NewLoadCostId INT
		,@NewLoadStorageCostId INT
		,@intPurchaseSale INT
		,@strDetailReplaceXml NVARCHAR(max) = ''
		,@strDetailReplaceXmlForContainers NVARCHAR(max) = ''
		,@intStartingNumberType INT
		,@intLogisticsAcknowledgementStageId INT
		,@strHeaderCondition NVARCHAR(MAX)
		,@strContractDetailAllId NVARCHAR(MAX)
		,@strAckLoadXML NVARCHAR(MAX)
		,@strAckLoadDetailXML NVARCHAR(MAX)
		,@strAckLoadNotifyPartyXML NVARCHAR(MAX)
		,@strAckLoadDocumentXML NVARCHAR(MAX)
		,@strAckLoadContainerXML NVARCHAR(MAX)
		,@strAckLoadDetailContainerLinkXML NVARCHAR(MAX)
		,@strAckLoadWarehouseXML NVARCHAR(MAX)
		,@strAckLoadWarehouseContainerXML NVARCHAR(MAX)
		,@strAckLoadWarehouseServicesXML NVARCHAR(MAX)
		,@strAckLoadCostXML NVARCHAR(MAX)
		,@strAckLoadStorageCostXML NVARCHAR(MAX)
		,@strLoadContainerId NVARCHAR(500)
		,@strLoadWarehouseId NVARCHAR(500)
		,@strLoadDetailContainerLinkCondition NVARCHAR(MAX)
		,@strLoadWarehouseCondition NVARCHAR(MAX)
		,@intToBookId INT
		,@intTransactionCount INT
		,@intLoadRefId INT
		,@intCompanyLocationId INT
		,@strNewLoadNumber NVARCHAR(50)
		,@intNewLoadId INT
		,@strFreightTerm NVARCHAR(50)
		,@strBook NVARCHAR(50)
		,@strSubBook NVARCHAR(50)
		,@intInsuranceCurrencyId INT
		,@intUserId INT
		,@strUserName NVARCHAR(50)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strDescription NVARCHAR(MAX)
		,@intSContractDetailId INT
		,@intPContractDetailId INT
		,@intPACompanyLocationId INT
		,@intVendorEntityId INT
		,@intPContractHeaderId INT
		,@strCustomerContract NVARCHAR(50)
		,@intSACompanyLocationId INT
		,@intSContractHeaderId INT
		,@intCustomerEntityId INT
	DECLARE @tblLGLoadDetail TABLE (intLoadDetailId INT)
	DECLARE @strItemNo NVARCHAR(50)
		,@strItemUOM NVARCHAR(50)
		,@strPSubLocationName NVARCHAR(50)
		,@strSSubLocationName NVARCHAR(50)
		,@strWeightItemUOM NVARCHAR(50)
		,@strVendor NVARCHAR(100)
		,@strShipFrom NVARCHAR(50)
		,@strPLocationName NVARCHAR(50)
		,@strSLocationName NVARCHAR(50)
		,@strCustomer NVARCHAR(100)
		,@strShipTo NVARCHAR(50)
		,@strInboundTaxGroup NVARCHAR(50)
		,@strOutboundTaxGroup NVARCHAR(50)
		,@intLoadDetailId INT
		,@strCurrency NVARCHAR(50)
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intPCompanyLocationSubLocationId INT
		,@intSCompanyLocationSubLocationId INT
		,@intWeightUnitMeasureId INT
		,@intWeightItemUOMId INT
		,@intVendorId INT
		,@intVendorLocationId INT
		,@intPCompanyLocationId INT
		,@intSCompanyLocationId INT
		,@intCustomerId INT
		,@intCustomerLocationId INT
		,@idoc INT
		,@strHauler NVARCHAR(100)
		,@strDriver NVARCHAR(100)
		,@strTerminal NVARCHAR(100)
		,@strShippingLine NVARCHAR(100)
		,@strForwardingAgent NVARCHAR(100)
		,@strInsurer NVARCHAR(100)
		,@strBLDraftToBeSent NVARCHAR(100)
		,@strDocPresentationVal NVARCHAR(100)
		,@strInsuranceCurrency NVARCHAR(40)
		,@strContainerType NVARCHAR(50)
		,@strEquipmentType NVARCHAR(100)
		,@strDispatcher NVARCHAR(50)
		,@strPosition NVARCHAR(100)
		,@strShippingInstructionNumber NVARCHAR(100)
		,@strErrorMessage NVARCHAR(MAX)
		,@intHaulerId INT
		,@intDriverId INT
		,@intTerminalId INT
		,@intShippingLineId INT
		,@intForwardingAgentId INT
		,@intInsurerId INT
		,@intBLDraftToBeSentId INT
		,@intDocPresentationValId INT
		,@intCurrencyId INT
		,@intContainerTypeId INT
		,@intEquipmentTypeId INT
		,@intDispatcherId INT
		,@intPositionId INT
		,@strSourceType NVARCHAR(50)
		,@intSourceType INT
		,@intFreightTermId INT
		,@intBookId INT
		,@intSubBookId INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intLoadScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblLGLoadDetailLot TABLE (intLoadDetailLotId INT)
	DECLARE @strLotNumber NVARCHAR(50)
		,@strItemUnitMeasure NVARCHAR(50)
		,@strWeightUnitMeasure NVARCHAR(50)
		,@intLotId INT
		,@strHBook NVARCHAR(50)
		,@strHSubBook NVARCHAR(50)
		,@intHBookId INT
		,@intHSubBookId INT
	DECLARE @tempLoadDetail TABLE (
		intLoadDetailId INT NOT NULL
		,intConcurrencyId INT NOT NULL
		,intLoadId INT NOT NULL
		,intVendorEntityId INT NULL
		,intVendorEntityLocationId INT NULL
		,intCustomerEntityId INT NULL
		,intCustomerEntityLocationId INT NULL
		,intItemId INT NULL
		,intPContractDetailId INT NULL
		,intSContractDetailId INT NULL
		,intPCompanyLocationId INT NULL
		,intSCompanyLocationId INT NULL
		,dblQuantity NUMERIC(18, 6) NULL
		,intItemUOMId INT NULL
		,dblGross NUMERIC(18, 6) NULL
		,dblTare NUMERIC(18, 6) NULL
		,dblNet NUMERIC(18, 6) NULL
		,intWeightItemUOMId INT NULL
		,dblDeliveredQuantity NUMERIC(18, 6) NULL
		,dblDeliveredGross NUMERIC(18, 6) NULL
		,dblDeliveredTare NUMERIC(18, 6) NULL
		,dblDeliveredNet NUMERIC(18, 6) NULL
		,strLotAlias NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strSupplierLotNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,dtmProductionDate DATETIME NULL
		,strScheduleInfoMsg NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,ysnUpdateScheduleInfo BIT NULL
		,ysnPrintScheduleInfo BIT NULL
		,strLoadDirectionMsg NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,ysnUpdateLoadDirections BIT NULL
		,ysnPrintLoadDirections BIT NULL
		,strVendorReference NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,strCustomerReference NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,intAllocationDetailId INT NULL
		,intPickLotDetailId INT NULL
		,intPSubLocationId INT NULL
		,intSSubLocationId INT NULL
		,intNumberOfContainers INT NULL
		,strExternalShipmentItemNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,strExternalBatchNo NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,ysnNoClaim BIT
		)

	SELECT @intCompanyRefId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	DECLARE @tblLGIntrCompLogisticsStg TABLE (intId INT)

	INSERT INTO @tblLGIntrCompLogisticsStg (intId)
	SELECT intId
	FROM tblLGIntrCompLogisticsStg
	WHERE strFeedStatus IS NULL
		AND intMultiCompanyId = @intMultiCompanyId

	SELECT @intId = MIN(intId)
	FROM @tblLGIntrCompLogisticsStg

	if @intId is null
	Begin
		Return
	End

	UPDATE S
	SET strFeedStatus = 'In-Progress'
	From tblLGIntrCompLogisticsStg S
	JOIN @tblLGIntrCompLogisticsStg PS on PS.intId=S.intId

	WHILE @intId > 0
	BEGIN
		BEGIN TRY
			SELECT @intLoadId = NULL
				,@strLoadNumber = NULL
				,@strLoad = NULL
				,@strLoadDetail = NULL
				,@strLoadDocument = NULL
				,@strLoadNotifyParty = NULL
				,@strLoadContainer = NULL
				,@strLoadDetailContainerLink = NULL
				,@strLoadWarehouse = NULL
				,@strLoadWarehouseContainer = NULL
				,@strLoadWarehouseServices = NULL
				,@strLoadCost = NULL
				,@strLoadStorageCost = NULL
				,@strReference = NULL
				,@strRowState = NULL
				,@strFeedStatus = NULL
				,@dtmFeedDate = NULL
				,@strMessage = NULL
				--,@intMultiCompanyId = NULL
				,@intReferenceId = NULL
				,@intEntityId = NULL
				,@strTransactionType = NULL
				,@intToBookId = NULL
				,@intCompanyLocationId = NULL
				,@strLoadDetailLot = NULL
				,@intInsuranceCurrencyId = NULL
				,@strHauler = NULL
				,@strDriver = NULL
				,@strTerminal = NULL
				,@strShippingLine = NULL
				,@strForwardingAgent = NULL
				,@strInsurer = NULL
				,@strBLDraftToBeSent = NULL
				,@strDocPresentationVal = NULL
				,@strInsuranceCurrency = NULL
				,@strContainerType = NULL
				,@strEquipmentType = NULL
				,@strDispatcher = NULL
				,@strPosition = NULL
				,@strSourceType = NULL
				,@strCurrency = NULL
				,@strFreightTerm = NULL
				,@strBook = NULL
				,@strSubBook = NULL
				,@intHaulerId = NULL
				,@intDriverId = NULL
				,@intTerminalId = NULL
				,@intShippingLineId = NULL
				,@intForwardingAgentId = NULL
				,@intInsurerId = NULL
				,@intBLDraftToBeSentId = NULL
				,@intDocPresentationValId = NULL
				,@intCurrencyId = NULL
				,@intContainerTypeId = NULL
				,@intEquipmentTypeId = NULL
				,@intDispatcherId = NULL
				,@intPositionId = NULL
				,@intFreightTermId = NULL
				,@intBookId = NULL
				,@intSubBookId = NULL
				,@strUserName = NULL
				,@intTransactionId = NULL
				,@intCompanyId = NULL
				,@strHBook = NULL
				,@strHSubBook = NULL
				,@intHBookId = NULL
				,@intHSubBookId = NULL

			SELECT @intLoadId = intLoadId
				,@strLoadNumber = strLoadNumber
				,@strLoad = strLoad
				,@strLoadDetail = strLoadDetail
				,@strLoadDetailLot = strLoadDetailLot
				,@strLoadDocument = strLoadDocument
				,@strLoadNotifyParty = strLoadNotifyParty
				,@strLoadContainer = strLoadContainer
				,@strLoadDetailContainerLink = strLoadDetailContainerLink
				,@strLoadWarehouse = strLoadWarehouse
				,@strLoadWarehouseContainer = strLoadWarehouseContainer
				,@strLoadWarehouseServices = strLoadWarehouseServices
				,@strLoadCost = strLoadCost
				,@strLoadStorageCost = strLoadStorageCost
				,@strReference = strReference
				,@strRowState = strRowState
				,@strFeedStatus = strFeedStatus
				,@dtmFeedDate = dtmFeedDate
				,@strMessage = strMessage
				--,@intMultiCompanyId = intMultiCompanyId
				,@intReferenceId = intReferenceId
				,@intEntityId = intEntityId
				,@strTransactionType = strTransactionType
				,@intToBookId = intToBookId
				,@intCompanyLocationId = intToCompanyLocationId
				,@intTransactionId = intTransactionId
				,@intCompanyId = intCompanyId
				,@strHBook = strBook
				,@strHSubBook = strSubBook
			FROM tblLGIntrCompLogisticsStg
			WHERE intId = @intId

			SELECT @strInfo1 = @strInfo1 + @strLoadNumber + ','

			IF (@strTransactionType LIKE '%Instruction%')
			BEGIN
				SET @intStartingNumberType = 106
			END
			ELSE
			BEGIN
				SET @intStartingNumberType = 39
			END

			IF (@strTransactionType LIKE '%Inbound%')
			BEGIN
				SET @intPurchaseSale = 1
			END
			ELSE IF (@strTransactionType LIKE '%Outbound%')
			BEGIN
				SET @intPurchaseSale = 2
			END
			ELSE
			BEGIN
				SET @intPurchaseSale = 3
			END

			SELECT @intLoadRefId = @intLoadId

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoad

			SELECT @strHauler = strHauler
				,@strDriver = strDriver
				,@strTerminal = strTerminal
				,@strShippingLine = strShippingLine
				,@strForwardingAgent = strForwardingAgent
				,@strInsurer = strInsurer
				,@strBLDraftToBeSent = strBLDraftToBeSent
				,@strDocPresentationVal = strDocPresentationVal
				,@strInsuranceCurrency = strInsuranceCurrency
				,@strContainerType = strContainerType
				,@strEquipmentType = strEquipmentType
				,@strDispatcher = strDispatcher
				,@strPosition = strPosition
				,@strSourceType = strSourceType
				,@strCurrency = strCurrency
				,@strFreightTerm = strFreightTerm
				,@strBook = strBook
				,@strSubBook = strSubBook
				,@strUserName = strUserName
			FROM OPENXML(@idoc, 'vyuIPLoadViews/vyuIPLoadView', 2) WITH (
					strHauler NVARCHAR(100) Collate Latin1_General_CI_AS
					,strDriver NVARCHAR(100) Collate Latin1_General_CI_AS
					,strTerminal NVARCHAR(100) Collate Latin1_General_CI_AS
					,strShippingLine NVARCHAR(100) Collate Latin1_General_CI_AS
					,strForwardingAgent NVARCHAR(100) Collate Latin1_General_CI_AS
					,strInsurer NVARCHAR(100) Collate Latin1_General_CI_AS
					,strBLDraftToBeSent NVARCHAR(100) Collate Latin1_General_CI_AS
					,strDocPresentationVal NVARCHAR(100) Collate Latin1_General_CI_AS
					,strInsuranceCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
					,strContainerType NVARCHAR(50) Collate Latin1_General_CI_AS
					,strEquipmentType NVARCHAR(100) Collate Latin1_General_CI_AS
					,strDispatcher NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSourceType NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) Collate Latin1_General_CI_AS
					,strFreightTerm NVARCHAR(50) Collate Latin1_General_CI_AS
					,strBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(50) Collate Latin1_General_CI_AS
					,strUserName NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			SELECT @intSourceType = CASE @strSourceType
					WHEN 'None'
						THEN 1
					WHEN 'Contracts'
						THEN 2
					WHEN 'Orders'
						THEN 3
					WHEN 'Allocations'
						THEN 4
					WHEN 'Picked Lots'
						THEN 5
					WHEN 'Pick Lots'
						THEN 6
					WHEN 'Pick Lots w/o Contract'
						THEN 7
					END

			SELECT @strErrorMessage = ''

			IF @strHauler IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity Hauler
					WHERE Hauler.strName = @strHauler
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Hauler ' + @strHauler + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Hauler ' + @strHauler + ' is not available.'
				END
			END

			IF @strDriver IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity Driver
					WHERE Driver.strName = @strDriver
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Driver ' + @strDriver + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Driver ' + @strDriver + ' is not available.'
				END
			END

			IF @strTerminal IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity Terminal
					WHERE Terminal.strName = @strTerminal
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Terminal ' + @strTerminal + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Terminal ' + @strTerminal + ' is not available.'
				END
			END

			IF @strShippingLine IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity ShippingLine
					WHERE ShippingLine.strName = @strShippingLine
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'ShippingLine ' + @strShippingLine + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'ShippingLine ' + @strShippingLine + ' is not available.'
				END
			END

			IF @strForwardingAgent IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity ForwardingAgent
					WHERE ForwardingAgent.strName = @strForwardingAgent
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'ForwardingAgent ' + @strForwardingAgent + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'ForwardingAgent ' + @strForwardingAgent + ' is not available.'
				END
			END

			IF @strInsurer IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity Insurer
					WHERE Insurer.strName = @strInsurer
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Insurer ' + @strInsurer + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Insurer ' + @strInsurer + ' is not available.'
				END
			END

			IF @strBLDraftToBeSent IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity BLDraftToBeSent
					WHERE BLDraftToBeSent.strName = @strBLDraftToBeSent
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'BLDraftToBeSent ' + @strBLDraftToBeSent + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'BLDraftToBeSent ' + @strBLDraftToBeSent + ' is not available.'
				END
			END

			IF @strDocPresentationVal IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM vyuLGNotifyParties DocPresentationVal
					WHERE DocPresentationVal.strName = @strDocPresentationVal
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'DocPresentationVal ' + @strDocPresentationVal + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'DocPresentationVal ' + @strDocPresentationVal + ' is not available.'
				END
			END

			IF @strInsuranceCurrency IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCurrency InsuranceCurrency
					WHERE InsuranceCurrency.strCurrency = @strInsuranceCurrency
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Insurance Currency ' + @strInsuranceCurrency + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Insurance Currency ' + @strInsuranceCurrency + ' is not available.'
				END
			END

			IF @strContainerType IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblLGContainerType ContainerType
					WHERE ContainerType.strContainerType = @strContainerType
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'ContainerType ' + @strContainerType + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'ContainerType ' + @strContainerType + ' is not available.'
				END
			END

			IF @strEquipmentType IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblLGEquipmentType EquipmentType
					WHERE EquipmentType.strEquipmentType = @strEquipmentType
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Equipment Type ' + @strEquipmentType + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Equipment Type ' + @strEquipmentType + ' is not available.'
				END
			END

			IF @strDispatcher IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMUserSecurity Dispatcher
					WHERE Dispatcher.strUserName = @strDispatcher
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Dispatcher ' + @strDispatcher + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Dispatcher ' + @strDispatcher + ' is not available.'
				END
			END

			IF @strPosition IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTPosition Position
					WHERE Position.strPosition = @strPosition
					)
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Position ' + @strPosition + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Position ' + @strPosition + ' is not available.'
				END
			END

			SELECT @intHaulerId = intEntityId
			FROM tblEMEntity Hauler
			WHERE Hauler.strName = @strHauler

			SELECT @intDriverId = intEntityId
			FROM tblEMEntity Driver
			WHERE Driver.strName = @strDriver

			SELECT @intTerminalId = intEntityId
			FROM tblEMEntity Terminal
			WHERE Terminal.strName = @strTerminal

			SELECT @intShippingLineId = intEntityId
			FROM tblEMEntity ShippingLine
			WHERE ShippingLine.strName = @strShippingLine

			SELECT @intForwardingAgentId = intEntityId
			FROM tblEMEntity ForwardingAgent
			WHERE ForwardingAgent.strName = @strForwardingAgent

			SELECT @intInsurerId = intEntityId
			FROM tblEMEntity Insurer
			WHERE Insurer.strName = @strInsurer

			SELECT @intBLDraftToBeSentId = intEntityId
			FROM tblEMEntity BLDraftToBeSent
			WHERE BLDraftToBeSent.strName = @strBLDraftToBeSent

			SELECT @intDocPresentationValId = intEntityId
			FROM vyuLGNotifyParties DocPresentationVal
			WHERE DocPresentationVal.strName = @strDocPresentationVal

			SELECT @intInsuranceCurrencyId = intCurrencyID
			FROM tblSMCurrency InsuranceCurrency
			WHERE InsuranceCurrency.strCurrency = @strInsuranceCurrency

			SELECT @intContainerTypeId = intContainerTypeId
			FROM tblLGContainerType ContainerType
			WHERE ContainerType.strContainerType = @strContainerType

			SELECT @intEquipmentTypeId = intEquipmentTypeId
			FROM tblLGEquipmentType EquipmentType
			WHERE EquipmentType.strEquipmentType = @strEquipmentType

			SELECT @intDispatcherId = intEntityId
			FROM tblSMUserSecurity Dispatcher
			WHERE Dispatcher.strUserName = @strDispatcher

			SELECT @intPositionId = intPositionId
			FROM tblCTPosition Position
			WHERE Position.strPosition = @strPosition

			SELECT @intFreightTermId = intFreightTermId
			FROM tblSMFreightTerms
			WHERE strFreightTerm = @strFreightTerm

			IF @intFreightTermId IS NULL
				AND @strFreightTerm IS NOT NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Freight Term ' + @strFreightTerm + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Freight Term ' + @strFreightTerm + ' is not available.'
				END
			END

			SELECT @intBookId = intBookId
			FROM tblCTBook
			WHERE strBook = @strBook

			IF @intBookId IS NULL
				AND @strBook IS NOT NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Book ' + @strBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'
				END
			END

			SELECT @intSubBookId = intSubBookId
			FROM tblCTSubBook
			WHERE strSubBook = @strSubBook
				AND intBookId = @intBookId

			IF @intSubBookId IS NULL
				AND @strSubBook IS NOT NULL
			BEGIN
				IF @strErrorMessage <> ''
				BEGIN
					SELECT @strErrorMessage = @strErrorMessage + CHAR(13) + CHAR(10) + 'Sub Book ' + @strSubBook + ' is not available.'
				END
				ELSE
				BEGIN
					SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'
				END
			END

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency Currency
			WHERE Currency.strCurrency = @strCurrency

			IF @intCurrencyId IS NULL
				AND @strCurrency IS NOT NULL
			BEGIN
				SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intUserId = CE.intEntityId
			FROM tblEMEntity CE
			JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
			WHERE ET1.strType = 'User'
				AND CE.strName = @strUserName
				AND CE.strEntityNo <> ''

			IF @intUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intUserId = intEntityId
					FROM tblSMUserSecurity
			END

			SELECT @intNewLoadId = intLoadId
				,@strNewLoadNumber = strLoadNumber
			--,@intCompanyRefId = intCompanyId
			FROM tblLGLoad
			WHERE intLoadRefId = @intLoadRefId
				AND intBookId = @intBookId
				AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intHBookId = intBookId
				FROM tblCTBook
				WHERE strBook = @strHBook

				SELECT @intHSubBookId = intSubBookId
				FROM tblCTSubBook
				WHERE strSubBook = @strHSubBook
					AND intBookId = @intHBookId

				DELETE
				FROM tblLGLoad
				WHERE intLoadRefId = @intLoadRefId
					AND intBookId = @intHBookId
					AND IsNULL(intSubBookId, 0) = IsNULL(@intHSubBookId, 0)

				GOTO NextTransaction
			END

			IF @intNewLoadId IS NULL
			BEGIN
				EXEC uspSMGetStartingNumber @intStartingNumberType
					,@strNewLoadNumber OUTPUT

				INSERT INTO tblLGLoad (
					intConcurrencyId
					,strLoadNumber
					,intCompanyLocationId
					,intPurchaseSale
					--,intItemId
					--,dblQuantity
					--,intUnitMeasureId
					,dtmScheduledDate
					,strCustomerReference
					,strBookingReference
					,intEquipmentTypeId
					,intEntityId
					,intEntityLocationId
					,intContractDetailId
					,strComments
					,intHaulerEntityId
					,intTicketId
					,ysnInProgress
					,dblDeliveredQuantity
					,dtmDeliveredDate
					,intGenerateLoadId
					,intGenerateSequence
					,strTruckNo
					,strTrailerNo1
					,strTrailerNo2
					,strTrailerNo3
					,strCarNumber
					,strEmbargoNo
					,strEmbargoPermitNo
					,intUserSecurityId
					,strExternalLoadNumber
					,intTransportLoadId
					,intDriverEntityId
					,ysnDispatched
					,dtmDispatchedDate
					,intDispatcherId
					,ysnDispatchMailSent
					,dtmDispatchMailSent
					,dtmCancelDispatchMailSent
					,intLoadHeaderId
					,intSourceType
					,intPositionId
					,intWeightUnitMeasureId
					,strBLNumber
					,dtmBLDate
					,strOriginPort
					,strDestinationPort
					,strDestinationCity
					,intTerminalEntityId
					,intShippingLineEntityId
					,strServiceContractNumber
					,strPackingDescription
					,strMVessel
					,strMVoyageNumber
					,strFVessel
					,strFVoyageNumber
					,intForwardingAgentEntityId
					,strForwardingAgentRef
					,intInsurerEntityId
					,strInsurancePolicyRefNo
					,dblInsuranceValue
					,dblInsurancePremiumPercentage
					,intInsuranceCurrencyId
					,dtmDocsToBroker
					,strMarks
					,strMarkingInstructions
					,strShippingMode
					,intNumberOfContainers
					,intContainerTypeId
					,intBLDraftToBeSentId
					,strBLDraftToBeSentType
					,strDocPresentationType
					,intDocPresentationId
					,dtmDocsReceivedDate
					,dtmETAPOL
					,dtmETSPOL
					,dtmETAPOD
					,dtmDeadlineCargo
					,dtmDeadlineBL
					,dtmISFReceivedDate
					,dtmISFFiledDate
					,dtmStuffingDate
					,dtmStartDate
					,dtmEndDate
					,dtmPlannedAvailabilityDate
					,dblDemurrage
					,intDemurrageCurrencyId
					,dblDespatch
					,intDespatchCurrencyId
					,dblLoadingRate
					,intLoadingUnitMeasureId
					,strLoadingPerUnit
					,dblDischargeRate
					,intDischargeUnitMeasureId
					,strDischargePerUnit
					,intTransportationMode
					,intShipmentStatus
					,ysnPosted
					--,dtmPostedDate
					,intTransUsedBy
					,intShipmentType
					,intLoadShippingInstructionId
					,strExternalShipmentNumber
					,ysn4cRegistration
					,ysnInvoice
					,ysnProvisionalInvoice
					,ysnQuantityFinal
					,ysnCancelled
					,intShippingModeId
					,intETAPOLReasonCodeId
					,intETSPOLReasonCodeId
					,intETAPODReasonCodeId
					,intFreightTermId
					,intCurrencyId
					,intCreatedById
					,dtmCreatedOn
					,intLastUpdateById
					,dtmLastUpdateOn
					,strBatchId
					,strGenerateLoadEquipmentType
					,strGenerateLoadHauler
					,ysnDocumentsReceived
					,ysnSubCurrency
					--,intCompanyId
					,intBookId
					,intSubBookId
					,intLoadRefId
					,ysnLoadBased
					,[strVessel1]
					,[strOriginPort1]
					,[strDestinationPort1]
					,[dtmETSPOL1]
					,[dtmETAPOD1]
					,[strVessel2]
					,[strOriginPort2]
					,[strDestinationPort2]
					,[dtmETSPOL2]
					,[dtmETAPOD2]
					,[strVessel3]
					,[strOriginPort3]
					,[strDestinationPort3]
					,[dtmETSPOL3]
					,[dtmETAPOD3]
					,[strVessel4]
					,[strOriginPort4]
					,[strDestinationPort4]
					,[dtmETSPOL4]
					,[dtmETAPOD4]
					,intCompanyId
					)
				SELECT 1 AS intConcurrencyId
					,@strNewLoadNumber
					,@intCompanyLocationId
					,@intPurchaseSale
					--,intItemId
					--,dblQuantity
					--,intUnitMeasureId
					,x.dtmScheduledDate
					,x.strCustomerReference
					,x.strBookingReference
					,@intEquipmentTypeId
					,NULL intEntityId
					,NULL intEntityLocationId
					,(
						SELECT TOP 1 intContractDetailId
						FROM tblCTContractDetail CD
						WHERE intContractDetailRefId = x.intContractDetailId
							AND intBookId = @intBookId
							AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						) AS intContractDetailId
					,strComments
					,@intHaulerId
					,NULL intTicketId
					,ysnInProgress
					,dblDeliveredQuantity
					,dtmDeliveredDate
					,NULL intGenerateLoadId
					,NULL intGenerateSequence
					,strTruckNo
					,strTrailerNo1
					,strTrailerNo2
					,strTrailerNo3
					,strCarNumber
					,strEmbargoNo
					,strEmbargoPermitNo
					,@intUserId
					,strExternalLoadNumber
					,NULL intTransportLoadId
					,@intDriverId
					,ysnDispatched
					,dtmDispatchedDate
					,@intDispatcherId
					,ysnDispatchMailSent
					,dtmDispatchMailSent
					,dtmCancelDispatchMailSent
					,intLoadHeaderId
					,CASE 
						WHEN @strTransactionType = 'Drop Shipment'
							THEN 4
						ELSE @intSourceType
						END
					,@intPositionId
					,intWeightUnitMeasureId
					,strBLNumber
					,dtmBLDate
					,strOriginPort
					,strDestinationPort
					,strDestinationCity
					,@intTerminalId
					,@intShippingLineId
					,strServiceContractNumber
					,strPackingDescription
					,strMVessel
					,strMVoyageNumber
					,strFVessel
					,strFVoyageNumber
					,@intForwardingAgentId
					,strForwardingAgentRef
					,@intInsurerId
					,strInsurancePolicyRefNo
					,dblInsuranceValue
					,dblInsurancePremiumPercentage
					,@intInsuranceCurrencyId
					,dtmDocsToBroker
					,strMarks
					,strMarkingInstructions
					,strShippingMode
					,intNumberOfContainers
					,@intContainerTypeId
					,@intBLDraftToBeSentId
					,strBLDraftToBeSentType
					,strDocPresentationType
					,@intDocPresentationValId
					,dtmDocsReceivedDate
					,dtmETAPOL
					,dtmETSPOL
					,dtmETAPOD
					,dtmDeadlineCargo
					,dtmDeadlineBL
					,dtmISFReceivedDate
					,dtmISFFiledDate
					,dtmStuffingDate
					,dtmStartDate
					,dtmEndDate
					,dtmPlannedAvailabilityDate
					,dblDemurrage
					,intDemurrageCurrencyId
					,dblDespatch
					,intDespatchCurrencyId
					,dblLoadingRate
					,intLoadingUnitMeasureId
					,strLoadingPerUnit
					,dblDischargeRate
					,intDischargeUnitMeasureId
					,strDischargePerUnit
					,intTransportationMode
					,CASE 
						WHEN intShipmentType = 1
							THEN 1
						ELSE intShipmentStatus
						END
					,0 AS ysnPosted
					--,dtmPostedDate
					,intTransUsedBy
					,intShipmentType
					,intLoadShippingInstructionId
					,strExternalShipmentNumber
					,ysn4cRegistration
					,ysnInvoice
					,ysnProvisionalInvoice
					,ysnQuantityFinal
					,ysnCancelled
					,intShippingModeId
					,intETAPOLReasonCodeId
					,intETSPOLReasonCodeId
					,intETAPODReasonCodeId
					,@intFreightTermId
					,@intCurrencyId
					,intCreatedById
					,dtmCreatedOn
					,intLastUpdateById
					,dtmLastUpdateOn
					,strBatchId
					,strGenerateLoadEquipmentType
					,strGenerateLoadHauler
					,ysnDocumentsReceived
					,ysnSubCurrency
					--,intCompanyId
					,@intBookId
					,@intSubBookId
					,@intLoadRefId
					,ysnLoadBased
					,[strVessel1]
					,[strOriginPort1]
					,[strDestinationPort1]
					,[dtmETSPOL1]
					,[dtmETAPOD1]
					,[strVessel2]
					,[strOriginPort2]
					,[strDestinationPort2]
					,[dtmETSPOL2]
					,[dtmETAPOD2]
					,[strVessel3]
					,[strOriginPort3]
					,[strDestinationPort3]
					,[dtmETSPOL3]
					,[dtmETAPOD3]
					,[strVessel4]
					,[strOriginPort4]
					,[strDestinationPort4]
					,[dtmETSPOL4]
					,[dtmETAPOD4]
					,@intCompanyRefId
				FROM OPENXML(@idoc, 'vyuIPLoadViews/vyuIPLoadView', 2) WITH (
						strHauler NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDriver NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTerminal NVARCHAR(100) Collate Latin1_General_CI_AS
						,strShippingLine NVARCHAR(100) Collate Latin1_General_CI_AS
						,strForwardingAgent NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsurer NVARCHAR(100) Collate Latin1_General_CI_AS
						,strBLDraftToBeSent NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDocPresentationVal NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsuranceCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
						,strContainerType NVARCHAR(50) Collate Latin1_General_CI_AS
						,strEquipmentType NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDispatcher NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
						,dtmScheduledDate DATETIME
						,strCustomerReference NVARCHAR(100) Collate Latin1_General_CI_AS
						,strBookingReference NVARCHAR(100) Collate Latin1_General_CI_AS
						,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
						,ysnInProgress BIT
						,dblDeliveredQuantity NUMERIC(18, 6)
						,dtmDeliveredDate DATETIME
						,strTruckNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo1 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo2 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo3 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strCarNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strEmbargoNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strEmbargoPermitNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intUserSecurityId INT
						,strExternalLoadNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intTransportLoadId INT
						,intDriverEntityId INT
						,ysnDispatched BIT
						,dtmDispatchedDate DATETIME
						,intDispatcherId INT
						,ysnDispatchMailSent BIT
						,dtmDispatchMailSent DATETIME
						,dtmCancelDispatchMailSent DATETIME
						,intLoadHeaderId INT
						,intSourceType INT
						,intPositionId INT
						,intWeightUnitMeasureId INT
						,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dtmBLDate DATETIME
						,strOriginPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationCity NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,intTerminalEntityId INT
						,intShippingLineEntityId INT
						,strServiceContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strPackingDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strMVessel NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strMVoyageNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strFVessel NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strFVoyageNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intForwardingAgentEntityId INT
						,strForwardingAgentRef NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intInsurerEntityId INT
						,strInsurancePolicyRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dblInsuranceValue NUMERIC(18, 6)
						,dblInsurancePremiumPercentage NUMERIC(18, 6)
						,intInsuranceCurrencyId INT
						,dtmDocsToBroker DATETIME
						,strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strMarkingInstructions NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strShippingMode NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intNumberOfContainers INT
						,intContainerTypeId INT
						,intBLDraftToBeSentId INT
						,strBLDraftToBeSentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strDocPresentationType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intDocPresentationId INT
						,dtmDocsReceivedDate DATETIME
						,dtmETAPOL DATETIME
						,dtmETSPOL DATETIME
						,dtmETAPOD DATETIME
						,dtmDeadlineCargo DATETIME
						,dtmDeadlineBL DATETIME
						,dtmISFReceivedDate DATETIME
						,dtmISFFiledDate DATETIME
						,dtmStuffingDate DATETIME
						,dtmStartDate DATETIME
						,dtmEndDate DATETIME
						,dtmPlannedAvailabilityDate DATETIME
						,ysnArrivedInPort BIT
						,ysnDocumentsApproved BIT
						,ysnCustomsReleased BIT
						,dtmArrivedInPort DATETIME
						,dtmDocumentsApproved DATETIME
						,dtmCustomsReleased DATETIME
						,strVessel1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL1 DATETIME
						,dtmETAPOD1 DATETIME
						,strVessel2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL2 DATETIME
						,dtmETAPOD2 DATETIME
						,strVessel3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL3 DATETIME
						,dtmETAPOD3 DATETIME
						,strVessel4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL4 DATETIME
						,dtmETAPOD4 DATETIME
						,dblDemurrage NUMERIC(18, 6)
						,intDemurrageCurrencyId INT
						,dblDespatch NUMERIC(18, 6)
						,intDespatchCurrencyId INT
						,dblLoadingRate NUMERIC(18, 6)
						,intLoadingUnitMeasureId INT
						,strLoadingPerUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dblDischargeRate NUMERIC(18, 6)
						,intDischargeUnitMeasureId INT
						,strDischargePerUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intTransportationMode INT
						,intShipmentStatus INT
						,ysnPosted BIT
						,dtmPostedDate DATETIME
						,intTransUsedBy INT
						,intShipmentType INT
						,intLoadShippingInstructionId INT
						,strExternalShipmentNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
						,ysn4cRegistration BIT
						,ysnInvoice BIT
						,ysnProvisionalInvoice BIT
						,ysnQuantityFinal BIT
						,ysnCancelled BIT
						,intShippingModeId INT
						,intETAPOLReasonCodeId INT
						,intETSPOLReasonCodeId INT
						,intETAPODReasonCodeId INT
						,intFreightTermId INT
						,intCurrencyId INT
						,intCreatedById INT
						,dtmCreatedOn DATETIME
						,intLastUpdateById INT
						,dtmLastUpdateOn DATETIME
						,strBatchId NVARCHAR(20) COLLATE Latin1_General_CI_AS
						,strGenerateLoadEquipmentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strGenerateLoadHauler NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,ysnDocumentsReceived BIT
						,ysnSubCurrency BIT
						,intCompanyId INT
						,intBookId INT
						,intSubBookId INT
						,intLoadRefId INT
						,ysnLoadBased BIT
						,intContractDetailId INT
						) x

				SELECT @intNewLoadId = SCOPE_IDENTITY()

				SELECT @strDescription = 'Created from inter-company : ' + @strNewLoadNumber

				EXEC uspSMAuditLog @keyValue = @intNewLoadId
					,@screenName = 'Logistics.view.ShipmentSchedule'
					,@entityId = @intUserId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@changeDescription = @strDescription
					,@fromValue = ''
					,@toValue = @strNewLoadNumber
			END
			ELSE
			BEGIN
				UPDATE L
				SET intConcurrencyId = intConcurrencyId + 1
					,intCompanyLocationId = @intCompanyLocationId
					,intPurchaseSale = @intPurchaseSale
					,dtmScheduledDate = x.dtmScheduledDate
					,strCustomerReference = x.strCustomerReference
					,strBookingReference = x.strBookingReference
					,intEquipmentTypeId = @intEquipmentTypeId
					,intEntityId = NULL
					,intEntityLocationId = NULL
					,intContractDetailId = (
						SELECT TOP 1 intContractDetailId
						FROM tblCTContractDetail CD
						WHERE intContractDetailRefId = x.intContractDetailId
							AND intBookId = @intBookId
							AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						)
					,strComments = x.strComments
					,intHaulerEntityId = @intHaulerId
					,intTicketId = NULL
					,ysnInProgress = x.ysnInProgress
					,dblDeliveredQuantity = x.dblDeliveredQuantity
					,dtmDeliveredDate = x.dtmDeliveredDate
					,intGenerateLoadId = NULL
					,intGenerateSequence = NULL
					,strTruckNo = x.strTruckNo
					,strTrailerNo1 = x.strTrailerNo1
					,strTrailerNo2 = x.strTrailerNo2
					,strTrailerNo3 = x.strTrailerNo3
					,strCarNumber = x.strCarNumber
					,strEmbargoNo = x.strEmbargoNo
					,strEmbargoPermitNo = x.strEmbargoPermitNo
					,intUserSecurityId = @intUserId
					,strExternalLoadNumber = x.strExternalLoadNumber
					,intTransportLoadId = NULL
					,intDriverEntityId = @intDriverId
					,ysnDispatched = x.ysnDispatched
					,dtmDispatchedDate = x.dtmDispatchedDate
					,intDispatcherId = @intDispatcherId
					,ysnDispatchMailSent = x.ysnDispatchMailSent
					,dtmDispatchMailSent = x.dtmDispatchMailSent
					,dtmCancelDispatchMailSent = x.dtmCancelDispatchMailSent
					,intLoadHeaderId = x.intLoadHeaderId
					,intSourceType = (
						CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN 4
							ELSE x.intSourceType
							END
						)
					,intPositionId = @intPositionId
					,intWeightUnitMeasureId = x.intWeightUnitMeasureId
					,strBLNumber = x.strBLNumber
					,dtmBLDate = x.dtmBLDate
					,strOriginPort = x.strOriginPort
					,strDestinationPort = x.strDestinationPort
					,strDestinationCity = x.strDestinationCity
					,intTerminalEntityId = @intTerminalId
					,intShippingLineEntityId = @intShippingLineId
					,strServiceContractNumber = x.strServiceContractNumber
					,strPackingDescription = x.strPackingDescription
					,strMVessel = x.strMVessel
					,strMVoyageNumber = x.strMVoyageNumber
					,strFVessel = x.strFVessel
					,strFVoyageNumber = x.strFVoyageNumber
					,intForwardingAgentEntityId = @intForwardingAgentId
					,strForwardingAgentRef = x.strForwardingAgentRef
					,intInsurerEntityId = @intInsurerId
					,strInsurancePolicyRefNo = x.strInsurancePolicyRefNo
					,dblInsuranceValue = x.dblInsuranceValue
					,dblInsurancePremiumPercentage = x.dblInsurancePremiumPercentage
					,intInsuranceCurrencyId = x.intInsuranceCurrencyId
					,dtmDocsToBroker = x.dtmDocsToBroker
					,strMarks = x.strMarks
					,strMarkingInstructions = x.strMarkingInstructions
					,strShippingMode = x.strShippingMode
					,intNumberOfContainers = x.intNumberOfContainers
					,intContainerTypeId = @intContainerTypeId
					,intBLDraftToBeSentId = @intBLDraftToBeSentId
					,strBLDraftToBeSentType = x.strBLDraftToBeSentType
					,strDocPresentationType = x.strDocPresentationType
					,intDocPresentationId = @intDocPresentationValId
					,dtmDocsReceivedDate = x.dtmDocsReceivedDate
					,dtmETAPOL = x.dtmETAPOL
					,dtmETSPOL = x.dtmETSPOL
					,dtmETAPOD = x.dtmETAPOD
					,dtmDeadlineCargo = x.dtmDeadlineCargo
					,dtmDeadlineBL = x.dtmDeadlineBL
					,dtmISFReceivedDate = x.dtmISFReceivedDate
					,dtmISFFiledDate = x.dtmISFFiledDate
					,dtmStuffingDate = x.dtmStuffingDate
					,dtmStartDate = x.dtmStartDate
					,dtmEndDate = x.dtmEndDate
					,dtmPlannedAvailabilityDate = x.dtmPlannedAvailabilityDate
					,dblDemurrage = x.dblDemurrage
					,intDemurrageCurrencyId = x.intDemurrageCurrencyId
					,dblDespatch = x.dblDespatch
					,intDespatchCurrencyId = x.intDespatchCurrencyId
					,dblLoadingRate = x.dblLoadingRate
					,intLoadingUnitMeasureId = x.intLoadingUnitMeasureId
					,strLoadingPerUnit = x.strLoadingPerUnit
					,dblDischargeRate = x.dblDischargeRate
					,intDischargeUnitMeasureId = x.intDischargeUnitMeasureId
					,strDischargePerUnit = x.strDischargePerUnit
					,intTransportationMode = x.intTransportationMode
					,intShipmentStatus = CASE 
						WHEN x.intShipmentType = 1
							THEN L.intShipmentStatus
						ELSE x.intShipmentStatus
						END
					--,ysnPosted = x.ysnPosted
					--,dtmPostedDate = x.dtmPostedDate
					,intTransUsedBy = x.intTransUsedBy
					,intShipmentType = x.intShipmentType
					,intLoadShippingInstructionId = x.intLoadShippingInstructionId
					,strExternalShipmentNumber = x.strExternalShipmentNumber
					,ysn4cRegistration = x.ysn4cRegistration
					,ysnInvoice = x.ysnInvoice
					,ysnProvisionalInvoice = x.ysnProvisionalInvoice
					,ysnQuantityFinal = x.ysnQuantityFinal
					,ysnCancelled = x.ysnCancelled
					,intShippingModeId = x.intShippingModeId
					,intETAPOLReasonCodeId = x.intETAPOLReasonCodeId
					,intETSPOLReasonCodeId = x.intETSPOLReasonCodeId
					,intETAPODReasonCodeId = x.intETAPODReasonCodeId
					,intFreightTermId = @intFreightTermId
					,intCurrencyId = @intCurrencyId
					,intCreatedById = x.intCreatedById
					,dtmCreatedOn = x.dtmCreatedOn
					,intLastUpdateById = x.intLastUpdateById
					,dtmLastUpdateOn = x.dtmLastUpdateOn
					,strBatchId = x.strBatchId
					,strGenerateLoadEquipmentType = x.strGenerateLoadEquipmentType
					,strGenerateLoadHauler = x.strGenerateLoadHauler
					,ysnDocumentsReceived = x.ysnDocumentsReceived
					,ysnSubCurrency = x.ysnSubCurrency
					,intCompanyId = x.intCompanyId
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,ysnLoadBased = x.ysnLoadBased
					,[strVessel1] = x.[strVessel1]
					,[strOriginPort1] = x.[strOriginPort1]
					,[strDestinationPort1] = x.[strDestinationPort1]
					,[dtmETSPOL1] = x.[dtmETSPOL1]
					,[dtmETAPOD1] = x.[dtmETAPOD1]
					,[strVessel2] = x.[strVessel2]
					,[strOriginPort2] = x.[strOriginPort2]
					,[strDestinationPort2] = x.[strDestinationPort2]
					,[dtmETSPOL2] = x.[dtmETSPOL2]
					,[dtmETAPOD2] = x.[dtmETAPOD2]
					,[strVessel3] = x.[strVessel3]
					,[strOriginPort3] = x.[strOriginPort3]
					,[strDestinationPort3] = x.[strDestinationPort3]
					,[dtmETSPOL3] = x.[dtmETSPOL3]
					,[dtmETAPOD3] = x.[dtmETAPOD3]
					,[strVessel4] = x.[strVessel4]
					,[strOriginPort4] = x.[strOriginPort4]
					,[strDestinationPort4] = x.[strDestinationPort4]
					,[dtmETSPOL4] = x.[dtmETSPOL4]
					,[dtmETAPOD4] = x.[dtmETAPOD4]
				FROM OPENXML(@idoc, 'vyuIPLoadViews/vyuIPLoadView', 2) WITH (
						strHauler NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDriver NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTerminal NVARCHAR(100) Collate Latin1_General_CI_AS
						,strShippingLine NVARCHAR(100) Collate Latin1_General_CI_AS
						,strForwardingAgent NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsurer NVARCHAR(100) Collate Latin1_General_CI_AS
						,strBLDraftToBeSent NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDocPresentationVal NVARCHAR(100) Collate Latin1_General_CI_AS
						,strInsuranceCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
						,strContainerType NVARCHAR(50) Collate Latin1_General_CI_AS
						,strEquipmentType NVARCHAR(100) Collate Latin1_General_CI_AS
						,strDispatcher NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPosition NVARCHAR(100) Collate Latin1_General_CI_AS
						,dtmScheduledDate DATETIME
						,strCustomerReference NVARCHAR(100) Collate Latin1_General_CI_AS
						,strBookingReference NVARCHAR(100) Collate Latin1_General_CI_AS
						,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
						,ysnInProgress BIT
						,dblDeliveredQuantity NUMERIC(18, 6)
						,dtmDeliveredDate DATETIME
						,strTruckNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo1 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo2 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strTrailerNo3 NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strCarNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strEmbargoNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strEmbargoPermitNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intUserSecurityId INT
						,strExternalLoadNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intTransportLoadId INT
						,intDriverEntityId INT
						,ysnDispatched BIT
						,dtmDispatchedDate DATETIME
						,intDispatcherId INT
						,ysnDispatchMailSent BIT
						,dtmDispatchMailSent DATETIME
						,dtmCancelDispatchMailSent DATETIME
						,intLoadHeaderId INT
						,intSourceType INT
						,intPositionId INT
						,intWeightUnitMeasureId INT
						,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dtmBLDate DATETIME
						,strOriginPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationCity NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,intTerminalEntityId INT
						,intShippingLineEntityId INT
						,strServiceContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strPackingDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strMVessel NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strMVoyageNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strFVessel NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strFVoyageNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intForwardingAgentEntityId INT
						,strForwardingAgentRef NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intInsurerEntityId INT
						,strInsurancePolicyRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dblInsuranceValue NUMERIC(18, 6)
						,dblInsurancePremiumPercentage NUMERIC(18, 6)
						,intInsuranceCurrencyId INT
						,dtmDocsToBroker DATETIME
						,strMarks NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strMarkingInstructions NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strShippingMode NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intNumberOfContainers INT
						,intContainerTypeId INT
						,intBLDraftToBeSentId INT
						,strBLDraftToBeSentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strDocPresentationType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intDocPresentationId INT
						,dtmDocsReceivedDate DATETIME
						,dtmETAPOL DATETIME
						,dtmETSPOL DATETIME
						,dtmETAPOD DATETIME
						,dtmDeadlineCargo DATETIME
						,dtmDeadlineBL DATETIME
						,dtmISFReceivedDate DATETIME
						,dtmISFFiledDate DATETIME
						,dtmStuffingDate DATETIME
						,dtmStartDate DATETIME
						,dtmEndDate DATETIME
						,dtmPlannedAvailabilityDate DATETIME
						,ysnArrivedInPort BIT
						,ysnDocumentsApproved BIT
						,ysnCustomsReleased BIT
						,dtmArrivedInPort DATETIME
						,dtmDocumentsApproved DATETIME
						,dtmCustomsReleased DATETIME
						,strVessel1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort1 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL1 DATETIME
						,dtmETAPOD1 DATETIME
						,strVessel2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort2 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL2 DATETIME
						,dtmETAPOD2 DATETIME
						,strVessel3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort3 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL3 DATETIME
						,dtmETAPOD3 DATETIME
						,strVessel4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strOriginPort4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,strDestinationPort4 NVARCHAR(200) COLLATE Latin1_General_CI_AS
						,dtmETSPOL4 DATETIME
						,dtmETAPOD4 DATETIME
						,dblDemurrage NUMERIC(18, 6)
						,intDemurrageCurrencyId INT
						,dblDespatch NUMERIC(18, 6)
						,intDespatchCurrencyId INT
						,dblLoadingRate NUMERIC(18, 6)
						,intLoadingUnitMeasureId INT
						,strLoadingPerUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,dblDischargeRate NUMERIC(18, 6)
						,intDischargeUnitMeasureId INT
						,strDischargePerUnit NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,intTransportationMode INT
						,intShipmentStatus INT
						,ysnPosted BIT
						,dtmPostedDate DATETIME
						,intTransUsedBy INT
						,intShipmentType INT
						,intLoadShippingInstructionId INT
						,strExternalShipmentNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
						,ysn4cRegistration BIT
						,ysnInvoice BIT
						,ysnProvisionalInvoice BIT
						,ysnQuantityFinal BIT
						,ysnCancelled BIT
						,intShippingModeId INT
						,intETAPOLReasonCodeId INT
						,intETSPOLReasonCodeId INT
						,intETAPODReasonCodeId INT
						,intFreightTermId INT
						,intCurrencyId INT
						,intCreatedById INT
						,dtmCreatedOn DATETIME
						,intLastUpdateById INT
						,dtmLastUpdateOn DATETIME
						,strBatchId NVARCHAR(20) COLLATE Latin1_General_CI_AS
						,strGenerateLoadEquipmentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strGenerateLoadHauler NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,ysnDocumentsReceived BIT
						,ysnSubCurrency BIT
						,intCompanyId INT
						,intBookId INT
						,intSubBookId INT
						,intLoadRefId INT
						,ysnLoadBased BIT
						,intContractDetailId INT
						,intLoadId INT
						) x
				JOIN tblLGLoad L ON L.intLoadRefId = x.intLoadId
				WHERE L.intLoadRefId = @intLoadRefId
					AND L.intBookId = @intBookId
					AND IsNULL(L.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
			END

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadDetail

			DELETE
			FROM @tblLGLoadDetail

			INSERT INTO @tblLGLoadDetail (intLoadDetailId)
			SELECT intLoadDetailId
			FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (intLoadDetailId INT)

			SELECT @intLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLGLoadDetail

			WHILE @intLoadDetailId IS NOT NULL
			BEGIN
				SELECT @strItemNo = NULL
					,@strItemUOM = NULL
					,@strPSubLocationName = NULL
					,@strSSubLocationName = NULL
					,@strWeightItemUOM = NULL
					,@strVendor = NULL
					,@strShipFrom = NULL
					,@strPLocationName = NULL
					,@strSLocationName = NULL
					,@strCustomer = NULL
					,@strShipTo = NULL
					,@strInboundTaxGroup = NULL
					,@strOutboundTaxGroup = NULL

				SELECT @strItemNo = strItemNo
					,@strItemUOM = strItemUOM
					,@strPSubLocationName = strPSubLocationName
					,@strSSubLocationName = strSSubLocationName
					,@strWeightItemUOM = strWeightItemUOM
					,@strVendor = strVendor
					,@strShipFrom = strShipFrom
					,@strPLocationName = strPLocationName
					,@strSLocationName = strSLocationName
					,@strCustomer = strCustomer
					,@strShipTo = strShipTo
					,@strInboundTaxGroup = strInboundTaxGroup
					,@strOutboundTaxGroup = strOutboundTaxGroup
				FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
						intLoadDetailId INT
						,[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strPSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strSSubLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strWeightItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strVendor NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strShipFrom NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strPLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strSLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strCustomer NVARCHAR(100) COLLATE Latin1_General_CI_AS
						,strShipTo NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strInboundTaxGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strOutboundTaxGroup NVARCHAR(50) COLLATE Latin1_General_CI_AS
						)
				WHERE intLoadDetailId = @intLoadDetailId

				IF @strItemNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICItem I
						WHERE I.strItemNo = @strItemNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Item ' + @strItemNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strItemUOM IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure U1
						WHERE U1.strUnitMeasure = @strItemUOM
						)
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strItemUOM + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPSubLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocationSubLocation SSubL
						WHERE SSubL.strSubLocationName = @strPSubLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Sub Location Name ' + @strPSubLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strSSubLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocationSubLocation SSubL
						WHERE SSubL.strSubLocationName = @strSSubLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Sub Location Name ' + @strSSubLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strWeightItemUOM IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure U1
						WHERE U1.strUnitMeasure = @strWeightItemUOM
						)
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strWeightItemUOM + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocation CL
						WHERE CL.strLocationName = @strPLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Location Name ' + @strPLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strSLocationName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCompanyLocation CL
						WHERE CL.strLocationName = @strSLocationName
						)
				BEGIN
					SELECT @strErrorMessage = 'Location Name ' + @strSLocationName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strCurrency IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMCurrency CU
						WHERE CU.strCurrency = @strCurrency
						)
				BEGIN
					SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strInboundTaxGroup IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMTaxGroup TG
						WHERE TG.strTaxGroup = @strInboundTaxGroup
						)
				BEGIN
					SELECT @strErrorMessage = 'Tax Group ' + @strInboundTaxGroup + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strOutboundTaxGroup IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblSMTaxGroup TG
						WHERE TG.strTaxGroup = @strOutboundTaxGroup
						)
				BEGIN
					SELECT @strErrorMessage = 'Tax Group ' + @strOutboundTaxGroup + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemId = NULL

				SELECT @intUnitMeasureId = NULL

				SELECT @intItemUOMId = NULL

				SELECT @intPCompanyLocationSubLocationId = NULL

				SELECT @intSCompanyLocationSubLocationId = NULL

				SELECT @intWeightUnitMeasureId = NULL

				SELECT @intWeightItemUOMId = NULL

				SELECT @intVendorId = NULL

				SELECT @intVendorLocationId = NULL

				SELECT @intPCompanyLocationId = NULL

				SELECT @intSCompanyLocationId = NULL

				SELECT @intCustomerId = NULL

				SELECT @intCustomerLocationId = NULL

				SELECT @intItemId = intItemId
				FROM tblICItem I
				WHERE I.strItemNo = @strItemNo

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure U1
				WHERE U1.strUnitMeasure = @strItemUOM

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = @intItemId
					AND IU.intUnitMeasureId = @intUnitMeasureId

				SELECT @intPCompanyLocationSubLocationId = intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation SubL
				WHERE SubL.strSubLocationName = @strPSubLocationName

				SELECT @intSCompanyLocationSubLocationId = intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation SubL
				WHERE SubL.strSubLocationName = @strSSubLocationName

				SELECT @intWeightUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure U1
				WHERE U1.strUnitMeasure = @strWeightItemUOM

				SELECT @intWeightItemUOMId = intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = @intItemId
					AND IU.intUnitMeasureId = @intWeightUnitMeasureId

				--SELECT @intVendorId = EY.intEntityId
				--FROM tblEMEntity EY
				--JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
				--	AND ET.strType = 'Vendor'
				--WHERE EY.strName = @strVendor
				--	AND EY.strEntityNo <> ''
				--SELECT @intVendorLocationId = EL.intEntityLocationId
				--FROM tblEMEntityLocation EL
				--WHERE EL.intEntityId = @intVendorId
				--	AND EL.strLocationName = @strShipFrom
				SELECT @intPCompanyLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation SubL
				WHERE SubL.strLocationName = @strPLocationName

				SELECT @intSCompanyLocationId = intCompanyLocationId
				FROM tblSMCompanyLocation SubL
				WHERE SubL.strLocationName = @strSLocationName

				SELECT @intCustomerId = EY.intEntityId
				FROM tblEMEntity EY
				JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
					AND ET.strType = 'Customer'
				WHERE EY.strName = @strCustomer
					AND EY.strEntityNo <> ''

				SELECT @intCustomerLocationId = EL.intEntityLocationId
				FROM tblEMEntityLocation EL
				WHERE EL.intEntityId = @intCustomerId
					AND EL.strLocationName = @strShipTo

				IF EXISTS (
						SELECT *
						FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
								[intSContractDetailId] INT
								,intLoadDetailId INT
								) x
						LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailRefId = x.intSContractDetailId
							AND intBookId = @intBookId
							AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						WHERE x.intLoadDetailId = @intLoadDetailId
							AND PCD.intContractDetailRefId IS NULL
						)
					AND @strTransactionType <> 'Drop Shipment'
				BEGIN
					SELECT @strErrorMessage = 'Contract is not created for the load.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strTransactionType = 'Drop Shipment'
				BEGIN
					SELECT @intSContractDetailId = NULL

					SELECT @intSContractDetailId = SCD.intContractDetailId
					FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
							[intPContractDetailId] INT
							,intLoadDetailId INT
							) x
					LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailRefId = x.intPContractDetailId
						AND intBookId = @intBookId
						AND IsNULL(intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					WHERE x.intLoadDetailId = @intLoadDetailId

					SELECT @intPContractDetailId = NULL

					SELECT @intPContractDetailId = AD.intPContractDetailId
					FROM tblLGAllocationDetail AD
					WHERE AD.intSContractDetailId = @intSContractDetailId

					SELECT @intPACompanyLocationId = NULL
						,@intPContractHeaderId = NULL

					SELECT @intPACompanyLocationId = intCompanyLocationId
						,@intPContractHeaderId = intContractHeaderId
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intPContractDetailId

					SELECT @intVendorEntityId = NULL
						,@strCustomerContract = NULL

					SELECT @intVendorEntityId = intEntityId
						,@strCustomerContract = strCustomerContract
					FROM tblCTContractHeader
					WHERE intContractHeaderId = @intPContractHeaderId

					---************
					SELECT @intSACompanyLocationId = NULL
						,@intSContractHeaderId = NULL

					SELECT @intSACompanyLocationId = intCompanyLocationId
						,@intSContractHeaderId = intContractHeaderId
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intSContractDetailId

					SELECT @intCustomerEntityId = NULL
						,@strCustomerContract = NULL

					SELECT @intCustomerEntityId = intEntityId
					FROM tblCTContractHeader
					WHERE intContractHeaderId = @intSContractHeaderId
				END

				IF NOT EXISTS (
						SELECT *
						FROM tblLGLoadDetail LD
						JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
						WHERE intLoadDetailRefId = @intLoadDetailId
							AND L.intBookId = @intBookId
							AND IsNULL(L.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
						)
				BEGIN
					INSERT INTO tblLGLoadDetail (
						[intConcurrencyId]
						,[intLoadId]
						,[intVendorEntityId]
						,[intVendorEntityLocationId]
						,[intCustomerEntityId]
						,[intCustomerEntityLocationId]
						,[intItemId]
						,[intPContractDetailId]
						,[intSContractDetailId]
						,[intPCompanyLocationId]
						,[intSCompanyLocationId]
						,[dblQuantity]
						,[intItemUOMId]
						,[dblGross]
						,[dblTare]
						,[dblNet]
						,[intWeightItemUOMId]
						,[strPriceStatus]
						,[dblUnitPrice]
						,[intPriceCurrencyId]
						,[intPriceUOMId]
						,[dblAmount]
						,[intForexRateTypeId]
						,[dblForexRate]
						,[intForexCurrencyId]
						,[dblForexAmount]
						,[dblDeliveredQuantity]
						,[dblDeliveredGross]
						,[dblDeliveredTare]
						,[dblDeliveredNet]
						,[strLotAlias]
						,[strSupplierLotNumber]
						,[dtmProductionDate]
						,[strScheduleInfoMsg]
						,[ysnUpdateScheduleInfo]
						,[ysnPrintScheduleInfo]
						,[strLoadDirectionMsg]
						,[ysnUpdateLoadDirections]
						,[ysnPrintLoadDirections]
						,[strVendorReference]
						,[strCustomerReference]
						--,[intAllocationDetailId]
						--,[intPickLotDetailId]
						,[intPSubLocationId]
						,[intSSubLocationId]
						,[intNumberOfContainers]
						,[strContainerNumbers]
						,[strExternalShipmentItemNumber]
						,[strExternalBatchNo]
						,[ysnNoClaim]
						,[intLoadDetailRefId]
						)
					SELECT 1 AS [intConcurrencyId]
						,@intNewLoadId
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intVendorEntityId
							ELSE PCH.intEntityId
							END
						,@intVendorLocationId
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intCustomerEntityId
							ELSE @intCustomerId
							END
						,@intCustomerLocationId
						,@intItemId
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intPContractDetailId
							ELSE PCD.intContractDetailId
							END AS intPContractDetailId
						,SCD.intContractDetailId
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intPACompanyLocationId
							ELSE PCD.intCompanyLocationId
							END
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intSACompanyLocationId
							ELSE @intSCompanyLocationId
							END
						,x.[dblQuantity]
						,@intItemUOMId
						,x.[dblGross]
						,x.[dblTare]
						,x.[dblNet]
						,@intWeightItemUOMId
						,x.[strPriceStatus]
						,x.[dblUnitPrice]
						,NULL [intPriceCurrencyId]
						,NULL [intPriceUOMId]
						,x.[dblAmount]
						,NULL [intForexRateTypeId]
						,x.[dblForexRate]
						,NULL [intForexCurrencyId]
						,x.[dblForexAmount]
						,x.[dblDeliveredQuantity]
						,x.[dblDeliveredGross]
						,x.[dblDeliveredTare]
						,x.[dblDeliveredNet]
						,x.[strLotAlias]
						,x.[strSupplierLotNumber]
						,x.[dtmProductionDate]
						,x.[strScheduleInfoMsg]
						,x.[ysnUpdateScheduleInfo]
						,x.[ysnPrintScheduleInfo]
						,x.[strLoadDirectionMsg]
						,x.[ysnUpdateLoadDirections]
						,x.[ysnPrintLoadDirections]
						,CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @strCustomerContract
							ELSE PCH.strCustomerContract
							END
						,x.[strCustomerReference]
						--,[intAllocationDetailId]
						--,[intPickLotDetailId]
						,@intPCompanyLocationSubLocationId
						,@intSCompanyLocationSubLocationId
						,x.[intNumberOfContainers]
						,x.[strContainerNumbers]
						,x.[strExternalShipmentItemNumber]
						,x.[strExternalBatchNo]
						,x.[ysnNoClaim]
						,x.[intLoadDetailId]
					FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
							[intVendorEntityId] INT
							,[intVendorEntityLocationId] INT
							,[intCustomerEntityId] INT
							,[intCustomerEntityLocationId] INT
							,[intItemId] INT
							,[intPContractDetailId] INT
							,[intSContractDetailId] INT
							,[intPCompanyLocationId] INT
							,[intSCompanyLocationId] INT
							,[dblQuantity] NUMERIC(18, 6)
							,[intItemUOMId] INT
							,[dblGross] NUMERIC(18, 6)
							,[dblTare] NUMERIC(18, 6)
							,[dblNet] NUMERIC(18, 6)
							,[intWeightItemUOMId] INT
							,[strPriceStatus] NVARCHAR(100)
							,[dblUnitPrice] NUMERIC(18, 6)
							,[intPriceCurrencyId] INT
							,[intPriceUOMId] INT
							,[dblAmount] NUMERIC(18, 6)
							,[intForexRateTypeId] INT
							,[dblForexRate] NUMERIC(18, 6)
							,[intForexCurrencyId] INT
							,[dblForexAmount] NUMERIC(18, 6)
							,[dblDeliveredQuantity] NUMERIC(18, 6)
							,[dblDeliveredGross] NUMERIC(18, 6)
							,[dblDeliveredTare] NUMERIC(18, 6)
							,[dblDeliveredNet] NUMERIC(18, 6)
							,[strLotAlias] NVARCHAR(100)
							,[strSupplierLotNumber] NVARCHAR(100)
							,[dtmProductionDate] DATETIME
							,[strScheduleInfoMsg] NVARCHAR(MAX)
							,[ysnUpdateScheduleInfo] [bit]
							,[ysnPrintScheduleInfo] [bit]
							,[strLoadDirectionMsg] NVARCHAR(MAX)
							,[ysnUpdateLoadDirections] [bit]
							,[ysnPrintLoadDirections] [bit]
							,[strVendorReference] NVARCHAR(200)
							,[strCustomerReference] NVARCHAR(200)
							,[intAllocationDetailId] INT
							,[intPickLotDetailId] INT
							,[intPSubLocationId] INT
							,[intSSubLocationId] INT
							,[intNumberOfContainers] INT
							,[strContainerNumbers] NVARCHAR(MAX)
							,[strExternalShipmentItemNumber] NVARCHAR(200)
							,[strExternalBatchNo] NVARCHAR(200)
							,[ysnNoClaim] BIT
							,[intLoadDetailRefId] INT
							,intLoadDetailId INT
							) x
					LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailRefId = x.intSContractDetailId
						AND PCD.intBookId = @intBookId
						AND IsNULL(PCD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailRefId = x.intPContractDetailId
						AND SCD.intBookId = @intBookId
						AND IsNULL(SCD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = IsNULL(PCD.intContractHeaderId, SCD.intContractHeaderId)
					WHERE x.intLoadDetailId = @intLoadDetailId
				END
				ELSE
				BEGIN
					UPDATE LD
					SET [intConcurrencyId] = LD.[intConcurrencyId] + 1
						,[intVendorEntityId] = CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intVendorEntityId
							ELSE PCH.intEntityId
							END
						,[intVendorEntityLocationId] = @intVendorLocationId
						,[intCustomerEntityId] = CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intCustomerEntityId
							ELSE @intCustomerId
							END
						,[intCustomerEntityLocationId] = @intCustomerLocationId
						,[intItemId] = @intItemId
						,[intPContractDetailId] = (
							CASE 
								WHEN @strTransactionType = 'Drop Shipment'
									THEN @intPContractDetailId
								ELSE PCD.intContractDetailId
								END
							)
						,[intSContractDetailId] = SCD.intContractDetailId
						,[intPCompanyLocationId] = CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intPACompanyLocationId
							ELSE PCD.intCompanyLocationId
							END
						,[intSCompanyLocationId] = CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @intSACompanyLocationId
							ELSE @intSCompanyLocationId
							END
						,[dblQuantity] = x.[dblQuantity]
						,[intItemUOMId] = @intItemUOMId
						,[dblGross] = x.[dblGross]
						,[dblTare] = x.[dblTare]
						,[dblNet] = x.[dblNet]
						,[intWeightItemUOMId] = @intWeightItemUOMId
						,[strPriceStatus] = x.[strPriceStatus]
						,[dblUnitPrice] = x.[dblUnitPrice]
						,[intPriceCurrencyId] = NULL -- [intPriceCurrencyId]
						,[intPriceUOMId] = NULL --[intPriceUOMId]
						,[dblAmount] = x.[dblAmount]
						,[intForexRateTypeId] = NULL --[intForexRateTypeId]
						,[dblForexRate] = x.[dblForexRate]
						,[intForexCurrencyId] = NULL -- [intForexCurrencyId]
						,[dblForexAmount] = x.[dblForexAmount]
						,[dblDeliveredQuantity] = x.[dblDeliveredQuantity]
						,[dblDeliveredGross] = x.[dblDeliveredGross]
						,[dblDeliveredTare] = x.[dblDeliveredTare]
						,[dblDeliveredNet] = x.[dblDeliveredNet]
						,[strLotAlias] = x.[strLotAlias]
						,[strSupplierLotNumber] = x.[strSupplierLotNumber]
						,[dtmProductionDate] = x.[dtmProductionDate]
						,[strScheduleInfoMsg] = x.[strScheduleInfoMsg]
						,[ysnUpdateScheduleInfo] = x.[ysnUpdateScheduleInfo]
						,[ysnPrintScheduleInfo] = x.[ysnPrintScheduleInfo]
						,[strLoadDirectionMsg] = x.[strLoadDirectionMsg]
						,[ysnUpdateLoadDirections] = x.[ysnUpdateLoadDirections]
						,[ysnPrintLoadDirections] = x.[ysnPrintLoadDirections]
						,[strVendorReference] = CASE 
							WHEN @strTransactionType = 'Drop Shipment'
								THEN @strCustomerContract
							ELSE PCH.strCustomerContract
							END
						,[strCustomerReference] = x.[strCustomerReference]
						--,[intAllocationDetailId]
						--,[intPickLotDetailId]
						,[intPSubLocationId] = @intPCompanyLocationSubLocationId
						,[intSSubLocationId] = @intSCompanyLocationSubLocationId
						,[intNumberOfContainers] = x.[intNumberOfContainers]
						,[strContainerNumbers] = x.[strContainerNumbers]
						,[strExternalShipmentItemNumber] = x.[strExternalShipmentItemNumber]
						,[strExternalBatchNo] = x.[strExternalBatchNo]
						,[ysnNoClaim] = x.[ysnNoClaim]
					FROM tblLGLoadDetail LD
					JOIN OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
							[intVendorEntityId] INT
							,[intVendorEntityLocationId] INT
							,[intCustomerEntityId] INT
							,[intCustomerEntityLocationId] INT
							,[intItemId] INT
							,[intPContractDetailId] INT
							,[intSContractDetailId] INT
							,[intPCompanyLocationId] INT
							,[intSCompanyLocationId] INT
							,[dblQuantity] NUMERIC(18, 6)
							,[intItemUOMId] INT
							,[dblGross] NUMERIC(18, 6)
							,[dblTare] NUMERIC(18, 6)
							,[dblNet] NUMERIC(18, 6)
							,[intWeightItemUOMId] INT
							,[strPriceStatus] NVARCHAR(100)
							,[dblUnitPrice] NUMERIC(18, 6)
							,[intPriceCurrencyId] INT
							,[intPriceUOMId] INT
							,[dblAmount] NUMERIC(18, 6)
							,[intForexRateTypeId] INT
							,[dblForexRate] NUMERIC(18, 6)
							,[intForexCurrencyId] INT
							,[dblForexAmount] NUMERIC(18, 6)
							,[dblDeliveredQuantity] NUMERIC(18, 6)
							,[dblDeliveredGross] NUMERIC(18, 6)
							,[dblDeliveredTare] NUMERIC(18, 6)
							,[dblDeliveredNet] NUMERIC(18, 6)
							,[strLotAlias] NVARCHAR(100)
							,[strSupplierLotNumber] NVARCHAR(100)
							,[dtmProductionDate] DATETIME
							,[strScheduleInfoMsg] NVARCHAR(MAX)
							,[ysnUpdateScheduleInfo] [bit]
							,[ysnPrintScheduleInfo] [bit]
							,[strLoadDirectionMsg] NVARCHAR(MAX)
							,[ysnUpdateLoadDirections] [bit]
							,[ysnPrintLoadDirections] [bit]
							,[strVendorReference] NVARCHAR(200)
							,[strCustomerReference] NVARCHAR(200)
							,[intAllocationDetailId] INT
							,[intPickLotDetailId] INT
							,[intPSubLocationId] INT
							,[intSSubLocationId] INT
							,[intNumberOfContainers] INT
							,[strContainerNumbers] NVARCHAR(MAX)
							,[strExternalShipmentItemNumber] NVARCHAR(200)
							,[strExternalBatchNo] NVARCHAR(200)
							,[ysnNoClaim] BIT
							,[intLoadDetailRefId] INT
							,intLoadDetailId INT
							) x ON x.intLoadDetailId = LD.intLoadDetailRefId
					LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailRefId = x.intSContractDetailId
						AND PCD.intBookId = @intBookId
						AND IsNULL(PCD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailRefId = x.intPContractDetailId
						AND SCD.intBookId = @intBookId
						AND IsNULL(SCD.intSubBookId, 0) = IsNULL(@intSubBookId, 0)
					LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = IsNULL(PCD.intContractHeaderId, SCD.intContractHeaderId)
					WHERE x.intLoadDetailId = @intLoadDetailId
				END

				SELECT @intLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLGLoadDetail
				WHERE intLoadDetailId > @intLoadDetailId
			END

			DELETE LD
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM @tblLGLoadDetail x
					WHERE LD.intLoadDetailRefId = x.intLoadDetailId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadDetailLot

			DECLARE @intLoadDetailLotId INT

			DELETE
			FROM @tblLGLoadDetailLot

			INSERT INTO @tblLGLoadDetailLot (intLoadDetailLotId)
			SELECT intLoadDetailLotId
			FROM OPENXML(@idoc, 'vyuLGLoadDetailLotsViews/vyuLGLoadDetailLotsView', 2) WITH (intLoadDetailLotId INT)

			SELECT @intLoadDetailLotId = MIN(intLoadDetailLotId)
			FROM @tblLGLoadDetailLot

			WHILE @intLoadDetailLotId IS NOT NULL
			BEGIN
				SELECT @strLotNumber = NULL
					,@strItemUnitMeasure = NULL
					,@strWeightUnitMeasure = NULL
					,@strItemNo = NULL

				SELECT @strLotNumber = strLotNumber
					,@strItemUnitMeasure = strItemUnitMeasure
					,@strWeightUnitMeasure = strWeightUnitMeasure
					,@strItemNo = strItemNo
				FROM OPENXML(@idoc, 'vyuLGLoadDetailLotsViews/vyuLGLoadDetailLotsView', 2) WITH (
						intLoadDetailId INT
						,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strItemUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
						,intLoadDetailLotId INT
						)
				WHERE intLoadDetailLotId = @intLoadDetailLotId

				IF @strItemUnitMeasure IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure U1
						WHERE U1.strUnitMeasure = @strItemUnitMeasure
						)
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strItemUnitMeasure + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strWeightUnitMeasure IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure U1
						WHERE U1.strUnitMeasure = @strWeightUnitMeasure
						)
				BEGIN
					SELECT @strErrorMessage = 'Unit Measure ' + @strWeightUnitMeasure + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strLotNumber IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICLot L
						WHERE L.strLotNumber = @strLotNumber
						)
				BEGIN
					SELECT @strErrorMessage = 'Lot ' + @strLotNumber + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intItemId = NULL

				SELECT @intUnitMeasureId = NULL

				SELECT @intItemUOMId = NULL

				SELECT @intWeightUnitMeasureId = NULL

				SELECT @intWeightItemUOMId = NULL

				SELECT @intLotId = NULL

				SELECT @intItemId = intItemId
				FROM tblICItem I
				WHERE I.strItemNo = @strItemNo

				SELECT @intUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure U1
				WHERE U1.strUnitMeasure = @strItemUnitMeasure

				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = @intItemId
					AND IU.intUnitMeasureId = @intUnitMeasureId

				SELECT @intWeightUnitMeasureId = intUnitMeasureId
				FROM tblICUnitMeasure U1
				WHERE U1.strUnitMeasure = @strWeightUnitMeasure

				SELECT @intWeightItemUOMId = intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = @intItemId
					AND IU.intUnitMeasureId = @intWeightUnitMeasureId

				SELECT @intLotId = intLotId
				FROM tblICLot L
				WHERE L.strLotNumber = @strLotNumber

				IF NOT EXISTS (
						SELECT *
						FROM tblLGLoadDetailLot LDL
						JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
						WHERE intLoadDetailLotRefId = @intLoadDetailLotId
							AND LD.intLoadId = @intNewLoadId
						)
				BEGIN
					INSERT INTO tblLGLoadDetailLot (
						[intLoadDetailId]
						,[intLotId]
						,[dblLotQuantity]
						,[intItemUOMId]
						,[dblGross]
						,[dblTare]
						,[dblNet]
						,[intWeightUOMId]
						,[strWarehouseCargoNumber]
						,[intSort]
						,[intConcurrencyId]
						,[intLoadDetailLotRefId]
						)
					SELECT (
							SELECT TOP 1 LD.intLoadDetailId
							FROM tblLGLoadDetail LD
							JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
							WHERE LD.intLoadDetailRefId = x.intLoadDetailId
								AND L.intLoadId = @intNewLoadId
							)
						,@intLotId
						,[dblLotQuantity]
						,@intItemUOMId
						,[dblGross]
						,[dblTare]
						,[dblNet]
						,@intWeightItemUOMId
						,[strWarehouseCargoNumber]
						,[intSort]
						,1 [intConcurrencyId]
						,[intLoadDetailLotId]
					FROM OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
							[intLoadDetailId] INT
							,[intLotId] INT
							,[dblLotQuantity] NUMERIC(38, 20)
							,[intItemUOMId] INT
							,[dblGross] NUMERIC(38, 20)
							,[dblTare] NUMERIC(38, 20)
							,[dblNet] NUMERIC(38, 20)
							,[intWeightUOMId] INT
							,[strWarehouseCargoNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,[intSort] INT
							,[intConcurrencyId] INT
							,[intLoadDetailLotRefId] INT
							,intLoadDetailLotId INT
							) x
					WHERE x.intLoadDetailLotId = @intLoadDetailLotId
				END
				ELSE
				BEGIN
					UPDATE LD
					SET [intLotId] = @intLotId
						,[dblLotQuantity] = x.[dblLotQuantity]
						,[intItemUOMId] = @intItemUOMId
						,[dblGross] = x.[dblGross]
						,[dblTare] = x.[dblTare]
						,[dblNet] = x.[dblNet]
						,[intWeightUOMId] = @intWeightItemUOMId
						,[strWarehouseCargoNumber] = x.[strWarehouseCargoNumber]
						,[intConcurrencyId] = LD.[intConcurrencyId] + 1
					FROM tblLGLoadDetailLot LD
					JOIN OPENXML(@idoc, 'vyuLGLoadDetailViews/vyuLGLoadDetailView', 2) WITH (
							[intLoadDetailId] INT
							,[intLotId] INT
							,[dblLotQuantity] NUMERIC(38, 20)
							,[intItemUOMId] INT
							,[dblGross] NUMERIC(38, 20)
							,[dblTare] NUMERIC(38, 20)
							,[dblNet] NUMERIC(38, 20)
							,[intWeightUOMId] INT
							,[strWarehouseCargoNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS
							,[intSort] INT
							,[intConcurrencyId] INT
							,[intLoadDetailLotRefId] INT
							,intLoadDetailLotId INT
							) x ON x.intLoadDetailLotId = LD.intLoadDetailLotRefId
					WHERE x.intLoadDetailLotId = @intLoadDetailLotId
				END

				SELECT @intLoadDetailLotId = MIN(intLoadDetailLotId)
				FROM @tblLGLoadDetailLot
				WHERE intLoadDetailLotId > @intLoadDetailLotId
			END

			DELETE LDL
			FROM tblLGLoadDetailLot LDL
			JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
			WHERE LD.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM @tblLGLoadDetailLot x
					WHERE LDL.intLoadDetailLotRefId = x.intLoadDetailLotId
					)

			---***** Code for Notification party
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadNotifyParty

			INSERT INTO tblLGLoadNotifyParties (
				[intConcurrencyId]
				,[intLoadId]
				,[strNotifyOrConsignee]
				,[strType]
				,[intEntityId]
				,[intCompanySetupID]
				,[intBankId]
				,[intEntityLocationId]
				,[intCompanyLocationId]
				,[strText]
				,intLoadNotifyPartyRefId
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,x.[strNotifyOrConsignee]
				,CASE 
					WHEN x.[strType] = 'Customer'
						THEN 'Company'
					ELSE x.[strType]
					END
				,NULL
				,C.[intCompanySetupID]
				,B.[intBankId]
				,NULL [intEntityLocationId]
				,CL.[intCompanyLocationId]
				,x.[strText]
				,x.intLoadNotifyPartyId
			FROM OPENXML(@idoc, 'vyuLGLoadNotifyPartiesNotMappeds/vyuLGLoadNotifyPartiesNotMapped', 2) WITH (
					[intLoadNotifyPartyId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[strNotifyOrConsignee] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[intEntityId] INT
					,[intCompanySetupID] INT
					,[intBankId] INT
					,[intEntityLocationId] INT
					,[intCompanyLocationId] INT
					,[strText] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,strParty NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strPartyLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMCompanySetup C ON C.strCompanyName = x.strParty
				AND x.strType = 'Customer'
			LEFT JOIN tblCMBank B ON B.strBankName = x.strParty
				AND x.strType = 'Bank'
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strPartyLocation
				AND x.strType = 'Customer'
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadNotifyParties NP
					WHERE NP.intLoadId = @intNewLoadId
						AND NP.intLoadNotifyPartyRefId = x.intLoadNotifyPartyId
					)

			UPDATE NP
			SET [intConcurrencyId] = NP.[intConcurrencyId] + 1
				,[strNotifyOrConsignee] = NP.[strNotifyOrConsignee]
				,[strType] = CASE 
					WHEN x.[strType] = 'Customer'
						THEN 'Company'
					ELSE x.[strType]
					END
				--,[intEntityId] = E.[intEntityId]
				,[intCompanySetupID] = C.[intCompanySetupID]
				,[intBankId] = B.[intBankId]
				,[intEntityLocationId] = NULL
				,[intCompanyLocationId] = CL.[intCompanyLocationId]
				,[strText] = x.[strText]
			FROM OPENXML(@idoc, 'vyuLGLoadNotifyPartiesNotMappeds/vyuLGLoadNotifyPartiesNotMapped', 2) WITH (
					[intLoadNotifyPartyId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[strNotifyOrConsignee] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[intEntityId] INT
					,[intCompanySetupID] INT
					,[intBankId] INT
					,[intEntityLocationId] INT
					,[intCompanyLocationId] INT
					,[strText] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,strParty NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strPartyLocation NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			LEFT JOIN tblSMCompanySetup C ON C.strCompanyName = x.strParty
				AND x.strType = 'Customer'
			LEFT JOIN tblCMBank B ON B.strBankName = x.strParty
				AND x.strType = 'Bank'
			LEFT JOIN tblSMCompanyLocation CL ON CL.strLocationName = x.strPartyLocation
				AND x.strType = 'Customer'
			JOIN tblLGLoadNotifyParties NP ON NP.intLoadId = @intNewLoadId
				AND NP.intLoadNotifyPartyRefId = x.intLoadNotifyPartyId

			DELETE NP
			FROM tblLGLoadNotifyParties NP
			WHERE NP.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadNotifyPartiesNotMappeds/vyuLGLoadNotifyPartiesNotMapped', 2) WITH (intLoadNotifyPartyId INT) x
					WHERE NP.intLoadNotifyPartyRefId = x.intLoadNotifyPartyId
					)

			--Process Document
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadDocument

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadDocumentViews/vyuLGLoadDocumentView', 2) WITH (
							intLoadDocumentId INT
							,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
					WHERE D.strDocumentName IS NULL
					)
			BEGIN
				SELECT @strErrorMessage = 'Document Name ' + x.strDocumentName + ' is not available.'
				FROM OPENXML(@idoc, 'vyuLGLoadDocumentViews/vyuLGLoadDocumentView', 2) WITH (
						intLoadDocumentId INT
						,strDocumentName NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				LEFT JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
				WHERE D.strDocumentName IS NULL

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			INSERT INTO tblLGLoadDocuments (
				intConcurrencyId
				,intLoadId
				,intDocumentId
				,strDocumentType
				,strDocumentNo
				,intOriginal
				,intCopies
				,ysnSent
				,dtmSentDate
				,ysnReceived
				,dtmReceivedDate
				,intLoadDocumentRefId
				,[ysnReceivedCopy]
				,[dtmCopyReceivedDate]
				)
			SELECT 1 AS intConcurrencyId
				,@intNewLoadId
				,D.intDocumentId
				,x.strDocumentType
				,x.strDocumentNo
				,x.intOriginal
				,x.intCopies
				,x.ysnSent
				,x.dtmSentDate
				,x.ysnReceived
				,x.dtmReceivedDate
				,x.intLoadDocumentId
				,x.[ysnReceivedCopy]
				,x.[dtmCopyReceivedDate]
			FROM OPENXML(@idoc, 'vyuLGLoadDocumentViews/vyuLGLoadDocumentView', 2) WITH (
					[intConcurrencyId] INT
					,[intLoadId] INT
					,[intDocumentId] INT
					,[strDocumentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[intOriginal] INT
					,[intCopies] INT
					,[ysnSent] BIT
					,[dtmSentDate] DATETIME
					,[ysnReceived] BIT
					,[dtmReceivedDate] DATETIME
					,[ysnReceivedCopy] BIT
					,[dtmCopyReceivedDate] DATETIME
					,[intLoadDocumentId] INT
					,strDocumentName NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadDocuments LD
					WHERE LD.intLoadId = @intNewLoadId
						AND LD.intLoadDocumentRefId = x.intLoadDocumentId
					)

			UPDATE LD
			SET intDocumentId = D.intDocumentId
				,strDocumentType = x.strDocumentType
				,strDocumentNo = x.strDocumentNo
				,intOriginal = x.intOriginal
				,intCopies = x.intCopies
				,ysnSent = x.ysnSent
				,dtmSentDate = x.dtmSentDate
				,ysnReceived = x.ysnReceived
				,dtmReceivedDate = x.dtmReceivedDate
				,[ysnReceivedCopy] = x.[ysnReceivedCopy]
				,[dtmCopyReceivedDate] = x.[dtmCopyReceivedDate]
			FROM OPENXML(@idoc, 'vyuLGLoadDocumentViews/vyuLGLoadDocumentView', 2) WITH (
					intLoadDocumentId INT
					,[strDocumentType] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strDocumentNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[intOriginal] INT
					,[intCopies] INT
					,[ysnSent] BIT
					,[dtmSentDate] DATETIME
					,[ysnReceived] BIT
					,[dtmReceivedDate] DATETIME
					,[ysnReceivedCopy] BIT
					,[dtmCopyReceivedDate] DATETIME
					,strDocumentName NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblICDocument D ON D.strDocumentName = x.strDocumentName
			JOIN tblLGLoadDocuments LD ON LD.intLoadId = @intNewLoadId
				AND LD.intLoadDocumentRefId = x.intLoadDocumentId

			DELETE LD
			FROM tblLGLoadDocuments LD
			WHERE LD.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadDocumentViews/vyuLGLoadDocumentView', 2) WITH (intLoadDocumentId INT) x
					WHERE LD.intLoadDocumentRefId = x.intLoadDocumentId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadContainer

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadContainerViews/vyuLGLoadContainerView', 2) WITH (
							intLoadContainerId INT
							,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
							,strWeightUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
							) x
					LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
					LEFT JOIN tblICUnitMeasure WUM ON WUM.strUnitMeasure = x.strWeightUnitMeasure
					WHERE UM.strUnitMeasure IS NULL
						OR WUM.strUnitMeasure IS NULL
					)
			BEGIN
				SELECT @strErrorMessage = 'Unit Measure ' + x.strUnitMeasure + ' is not available.'
				FROM OPENXML(@idoc, 'vyuLGLoadContainerViews/vyuLGLoadContainerView', 2) WITH (
						intLoadContainerId INT
						,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strWeightUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						) x
				LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
				LEFT JOIN tblICUnitMeasure WUM ON WUM.strUnitMeasure = x.strWeightUnitMeasure
				WHERE UM.strUnitMeasure IS NULL
					OR WUM.strUnitMeasure IS NULL

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			INSERT INTO tblLGLoadContainer (
				[intConcurrencyId]
				,[intLoadId]
				,[strContainerNumber]
				,[dblQuantity]
				,[intUnitMeasureId]
				,[dblGrossWt]
				,[dblTareWt]
				,[dblNetWt]
				,[intWeightUnitMeasureId]
				,[strComments]
				,[strSealNumber]
				,[strLotNumber]
				,[strMarks]
				,[strOtherMarks]
				,[ysnRejected]
				,[dtmUnloading]
				,[dtmCustoms]
				,[ysnCustomsHold]
				,[strCustomsComments]
				,[dtmFDA]
				,[ysnFDAHold]
				,[strFDAComments]
				,[dtmFreight]
				,[ysnDutyPaid]
				,[strFreightComments]
				,[dtmUSDA]
				,[ysnUSDAHold]
				,[strUSDAComments]
				,[dblUnitCost]
				,[intCostUOMId]
				,[intCurrencyId]
				,[dblTotalCost]
				,[ysnNewContainer]
				,[dblCustomsClearedQty]
				,[dblIntransitQty]
				,[strDocumentNumber]
				,[dtmClearanceDate]
				,[strClearanceMonth]
				,[dblDeclaredWeight]
				,[dblStaticValue]
				,[intStaticValueCurrencyId]
				,[dblAmount]
				,[intAmountCurrencyId]
				,[strRemarks]
				,[intLoadContainerRefId]
				,intSort
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,x.[strContainerNumber]
				,x.[dblQuantity]
				,UM.intUnitMeasureId
				,x.[dblGrossWt]
				,x.[dblTareWt]
				,x.[dblNetWt]
				,WUM.intUnitMeasureId
				,x.[strComments]
				,x.[strSealNumber]
				,x.[strLotNumber]
				,x.[strMarks]
				,x.[strOtherMarks]
				,x.[ysnRejected]
				,x.[dtmUnloading]
				,x.[dtmCustoms]
				,x.[ysnCustomsHold]
				,x.[strCustomsComments]
				,x.[dtmFDA]
				,x.[ysnFDAHold]
				,x.[strFDAComments]
				,x.[dtmFreight]
				,x.[ysnDutyPaid]
				,x.[strFreightComments]
				,x.[dtmUSDA]
				,x.[ysnUSDAHold]
				,x.[strUSDAComments]
				,x.[dblUnitCost]
				,NULL [intCostUOMId]
				,NULL [intCurrencyId]
				,x.[dblTotalCost]
				,x.[ysnNewContainer]
				,x.[dblCustomsClearedQty]
				,x.[dblIntransitQty]
				,x.[strDocumentNumber]
				,x.[dtmClearanceDate]
				,x.[strClearanceMonth]
				,x.[dblDeclaredWeight]
				,x.[dblStaticValue]
				,CU.intCurrencyID
				,x.[dblAmount]
				,ACU.intCurrencyID
				,x.[strRemarks]
				,x.[intLoadContainerId]
				,x.intSort
			FROM OPENXML(@idoc, 'vyuLGLoadContainerViews/vyuLGLoadContainerView', 2) WITH (
					[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dblQuantity] NUMERIC(18, 6)
					,[intUnitMeasureId] INT
					,[dblGrossWt] NUMERIC(18, 6)
					,[dblTareWt] NUMERIC(18, 6)
					,[dblNetWt] NUMERIC(18, 6)
					,[intWeightUnitMeasureId] INT
					,[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strSealNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strOtherMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[ysnRejected] [bit]
					,[dtmUnloading] DATETIME
					,[dtmCustoms] DATETIME
					,[ysnCustomsHold] [bit]
					,[strCustomsComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmFDA] DATETIME
					,[ysnFDAHold] [bit]
					,[strFDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmFreight] DATETIME
					,[ysnDutyPaid] [bit]
					,[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmUSDA] DATETIME
					,[ysnUSDAHold] [bit]
					,[strUSDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dblUnitCost] NUMERIC(18, 6)
					,[intCostUOMId] [int]
					,[intCurrencyId] [int]
					,[dblTotalCost] NUMERIC(18, 6)
					,[ysnNewContainer] BIT
					,[dblCustomsClearedQty] NUMERIC(18, 6)
					,[dblIntransitQty] NUMERIC(18, 6)
					,[strDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dtmClearanceDate] DATETIME
					,[strClearanceMonth] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dblDeclaredWeight] NUMERIC(18, 6)
					,[dblStaticValue] NUMERIC(18, 6)
					,[intStaticValueCurrencyId] INT
					,[dblAmount] NUMERIC(18, 6)
					,[intAmountCurrencyId] INT
					,[strRemarks] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intLoadContainerRefId] INT
					,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strStaticValueCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strAmountCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,intLoadContainerId INT
					,intSort INT
					) x
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICUnitMeasure WUM ON WUM.strUnitMeasure = x.strWeightUnitMeasure
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strStaticValueCurrency
			LEFT JOIN tblSMCurrency ACU ON ACU.strCurrency = x.strAmountCurrency
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadContainer LD
					WHERE LD.intLoadId = @intNewLoadId
						AND LD.intLoadContainerRefId = x.intLoadContainerId
					)
			ORDER BY x.intSort

			UPDATE LD
			SET [intConcurrencyId] = LD.[intConcurrencyId] + 1
				,[strContainerNumber] = x.[strContainerNumber]
				,[dblQuantity] = x.[dblQuantity]
				,[intUnitMeasureId] = UM.[intUnitMeasureId]
				,[dblGrossWt] = x.[dblGrossWt]
				,[dblTareWt] = x.[dblTareWt]
				,[dblNetWt] = x.[dblNetWt]
				,[intWeightUnitMeasureId] = WUM.[intUnitMeasureId]
				,[strComments] = x.[strComments]
				,[strSealNumber] = x.[strSealNumber]
				,[strLotNumber] = x.[strLotNumber]
				,[strMarks] = x.[strMarks]
				,[strOtherMarks] = x.[strOtherMarks]
				,[ysnRejected] = x.[ysnRejected]
				,[dtmUnloading] = x.[dtmUnloading]
				,[dtmCustoms] = x.[dtmCustoms]
				,[ysnCustomsHold] = x.[ysnCustomsHold]
				,[strCustomsComments] = x.[strCustomsComments]
				,[dtmFDA] = x.[dtmFDA]
				,[ysnFDAHold] = x.[ysnFDAHold]
				,[strFDAComments] = x.[strFDAComments]
				,[dtmFreight] = x.[dtmFreight]
				,[ysnDutyPaid] = x.[ysnDutyPaid]
				,[strFreightComments] = x.[strFreightComments]
				,[dtmUSDA] = x.[dtmUSDA]
				,[ysnUSDAHold] = x.[ysnUSDAHold]
				,[strUSDAComments] = x.[strUSDAComments]
				,[dblUnitCost] = x.[dblUnitCost]
				--,[intCostUOMId]=x.[intCostUOMId]
				--,[intCurrencyId]=x.[intCurrencyId]
				,[dblTotalCost] = x.[dblTotalCost]
				,[ysnNewContainer] = x.[ysnNewContainer]
				,[dblCustomsClearedQty] = x.[dblCustomsClearedQty]
				,[dblIntransitQty] = x.[dblIntransitQty]
				,[strDocumentNumber] = x.[strDocumentNumber]
				,[dtmClearanceDate] = x.[dtmClearanceDate]
				,[strClearanceMonth] = x.[strClearanceMonth]
				,[dblDeclaredWeight] = x.[dblDeclaredWeight]
				,[dblStaticValue] = x.[dblStaticValue]
				,[intStaticValueCurrencyId] = CU.[intCurrencyID]
				,[dblAmount] = x.[dblAmount]
				,[intAmountCurrencyId] = ACU.[intCurrencyID]
				,[strRemarks] = x.[strRemarks]
				,intSort = x.intSort
			FROM OPENXML(@idoc, 'vyuLGLoadContainerViews/vyuLGLoadContainerView', 2) WITH (
					[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dblQuantity] NUMERIC(18, 6)
					,[intUnitMeasureId] INT
					,[dblGrossWt] NUMERIC(18, 6)
					,[dblTareWt] NUMERIC(18, 6)
					,[dblNetWt] NUMERIC(18, 6)
					,[intWeightUnitMeasureId] INT
					,[strComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strSealNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[strOtherMarks] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[ysnRejected] [bit]
					,[dtmUnloading] DATETIME
					,[dtmCustoms] DATETIME
					,[ysnCustomsHold] [bit]
					,[strCustomsComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmFDA] DATETIME
					,[ysnFDAHold] [bit]
					,[strFDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmFreight] DATETIME
					,[ysnDutyPaid] [bit]
					,[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dtmUSDA] DATETIME
					,[ysnUSDAHold] [bit]
					,[strUSDAComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[dblUnitCost] NUMERIC(18, 6)
					,[intCostUOMId] [int]
					,[intCurrencyId] [int]
					,[dblTotalCost] NUMERIC(18, 6)
					,[ysnNewContainer] BIT
					,[dblCustomsClearedQty] NUMERIC(18, 6)
					,[dblIntransitQty] NUMERIC(18, 6)
					,[strDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dtmClearanceDate] DATETIME
					,[strClearanceMonth] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dblDeclaredWeight] NUMERIC(18, 6)
					,[dblStaticValue] NUMERIC(18, 6)
					,[intStaticValueCurrencyId] INT
					,[dblAmount] NUMERIC(18, 6)
					,[intAmountCurrencyId] INT
					,[strRemarks] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intLoadContainerRefId] INT
					,intLoadContainerId INT
					,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strWeightUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strStaticValueCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strAmountCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,intSort INT
					) x
			JOIN tblLGLoadContainer LD ON LD.intLoadId = @intNewLoadId
				AND LD.intLoadContainerRefId = x.intLoadContainerId
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICUnitMeasure WUM ON WUM.strUnitMeasure = x.strWeightUnitMeasure
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strStaticValueCurrency
			LEFT JOIN tblSMCurrency ACU ON ACU.strCurrency = x.strAmountCurrency

			DELETE LC
			FROM tblLGLoadContainer LC
			WHERE LC.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadContainerViews/vyuLGLoadContainerView', 2) WITH (intLoadContainerId INT) x
					WHERE LC.intLoadContainerRefId = x.intLoadContainerId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadDetailContainerLink

			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadDetailContainerLinkViews/vyuLGLoadDetailContainerLinkView', 2) WITH (strItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
					WHERE UM.strUnitMeasure IS NULL
					)
			BEGIN
				SELECT @strErrorMessage = 'Unit Measure ' + x.strItemUOM + ' is not available.'
				FROM OPENXML(@idoc, 'vyuLGLoadDetailContainerLinkViews/vyuLGLoadDetailContainerLinkView', 2) WITH (strItemUOM NVARCHAR(50) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
				WHERE UM.strUnitMeasure IS NULL

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			INSERT INTO tblLGLoadDetailContainerLink (
				[intConcurrencyId]
				,[intLoadId]
				,[intLoadContainerId]
				,[intLoadDetailId]
				,[dblQuantity]
				,[intItemUOMId]
				,[dblReceivedQty]
				,[dblLinkGrossWt]
				,[dblLinkTareWt]
				,[dblLinkNetWt]
				,[dblUnitCost]
				,[strIntegrationOrderNumber]
				,[dblIntegrationOrderPrice]
				,[strExternalContainerId]
				,[ysnExported]
				,[dtmExportedDate]
				,[dtmIntegrationOrderDate]
				,[intLoadDetailContainerLinkRefId]
				,strIntegrationNumber
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,(
					SELECT TOP 1 [intLoadContainerId]
					FROM tblLGLoadContainer
					WHERE intLoadContainerRefId = x.intLoadContainerId
						AND intLoadId = @intNewLoadId
					)
				,(
					SELECT TOP 1 [intLoadDetailId]
					FROM tblLGLoadDetail
					WHERE intLoadDetailRefId = x.intLoadDetailId
						AND intLoadId = @intNewLoadId
					)
				,x.[dblQuantity]
				,IU.[intItemUOMId]
				,x.[dblReceivedQty]
				,x.[dblLinkGrossWt]
				,x.[dblLinkTareWt]
				,x.[dblLinkNetWt]
				,x.[dblUnitCost]
				,x.[strIntegrationOrderNumber]
				,x.[dblIntegrationOrderPrice]
				,x.[strExternalContainerId]
				,x.[ysnExported]
				,x.[dtmExportedDate]
				,x.[dtmIntegrationOrderDate]
				,x.[intLoadDetailContainerLinkId]
				,x.strIntegrationNumber
			FROM OPENXML(@idoc, 'vyuLGLoadDetailContainerLinkViews/vyuLGLoadDetailContainerLinkView', 2) WITH (
					[intLoadContainerId] INT
					,[intLoadDetailId] INT
					,[dblQuantity] NUMERIC(18, 6)
					,[intItemUOMId] INT
					,[dblReceivedQty] NUMERIC(18, 6)
					,[dblLinkGrossWt] NUMERIC(38, 20)
					,[dblLinkTareWt] NUMERIC(38, 20)
					,[dblLinkNetWt] NUMERIC(38, 20)
					,[dblUnitCost] NUMERIC(18, 6)
					,[strIntegrationOrderNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[dblIntegrationOrderPrice] NUMERIC(18, 6)
					,[strExternalContainerId] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[ysnExported] [bit]
					,[dtmExportedDate] DATETIME
					,[dtmIntegrationOrderDate] DATETIME
					,[intLoadDetailContainerLinkRefId] INT
					,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,intLoadDetailContainerLinkId INT
					--,intLoadDetailId INT
					,[strIntegrationNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					) x
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadDetailContainerLink LDCL
					WHERE LDCL.intLoadId = @intNewLoadId
						AND LDCL.intLoadDetailContainerLinkRefId = x.intLoadDetailContainerLinkId
					)

			UPDATE tblLGLoadDetailContainerLink
			SET [intConcurrencyId] = LDCL.intConcurrencyId + 1
				,[intLoadContainerId] = (
					SELECT TOP 1 [intLoadContainerId]
					FROM tblLGLoadContainer
					WHERE intLoadContainerRefId = x.intLoadContainerId
						AND intLoadId = @intNewLoadId
					)
				,[intLoadDetailId] = (
					SELECT TOP 1 [intLoadDetailId]
					FROM tblLGLoadDetail
					WHERE intLoadDetailRefId = x.intLoadDetailId
						AND intLoadId = @intNewLoadId
					)
				,[dblQuantity] = x.[dblQuantity]
				,[intItemUOMId] = IU.[intItemUOMId]
				,[dblReceivedQty] = x.[dblReceivedQty]
				,[dblLinkGrossWt] = x.[dblLinkGrossWt]
				,[dblLinkTareWt] = x.[dblLinkTareWt]
				,[dblLinkNetWt] = x.[dblLinkNetWt]
				,[dblUnitCost] = x.[dblUnitCost]
				,[strIntegrationOrderNumber] = x.[strIntegrationOrderNumber]
				,[dblIntegrationOrderPrice] = x.[dblIntegrationOrderPrice]
				,[strExternalContainerId] = x.[strExternalContainerId]
				,[ysnExported] = x.[ysnExported]
				,[dtmExportedDate] = x.[dtmExportedDate]
				,[dtmIntegrationOrderDate] = x.[dtmIntegrationOrderDate]
				,strIntegrationNumber = x.strIntegrationNumber
			FROM OPENXML(@idoc, 'vyuLGLoadDetailContainerLinkViews/vyuLGLoadDetailContainerLinkView', 2) WITH (
					[intLoadContainerId] INT
					,[intLoadDetailId] INT
					,[dblQuantity] NUMERIC(18, 6)
					,[intItemUOMId] INT
					,[dblReceivedQty] NUMERIC(18, 6)
					,[dblLinkGrossWt] NUMERIC(38, 20)
					,[dblLinkTareWt] NUMERIC(38, 20)
					,[dblLinkNetWt] NUMERIC(38, 20)
					,[dblUnitCost] NUMERIC(18, 6)
					,[strIntegrationOrderNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[dblIntegrationOrderPrice] NUMERIC(18, 6)
					,[strExternalContainerId] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[ysnExported] [bit]
					,[dtmExportedDate] DATETIME
					,[dtmIntegrationOrderDate] DATETIME
					,[intLoadDetailContainerLinkRefId] INT
					,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,[intLoadDetailContainerLinkId] INT
					,[strIntegrationNumber] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					) x
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadId = @intNewLoadId
				AND LDCL.intLoadDetailContainerLinkRefId = x.intLoadDetailContainerLinkId
			WHERE EXISTS (
					SELECT *
					FROM tblLGLoadDetailContainerLink LDCL
					WHERE LDCL.intLoadId = @intNewLoadId
						AND LDCL.intLoadDetailContainerLinkRefId = x.intLoadDetailContainerLinkId
					)

			DELETE LDCL
			FROM tblLGLoadDetailContainerLink LDCL
			WHERE LDCL.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadDetailContainerLinkViews/vyuLGLoadDetailContainerLinkView', 2) WITH ([intLoadDetailContainerLinkId] INT) x
					WHERE LDCL.intLoadDetailContainerLinkRefId = x.intLoadDetailContainerLinkId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadCost

			--Load cost
			INSERT INTO tblLGLoadCost (
				[intConcurrencyId]
				,[intLoadId]
				,[intItemId]
				,[intVendorId]
				,[strEntityType]
				,[strCostMethod]
				,[intCurrencyId]
				,[dblRate]
				,[dblAmount]
				,[dblFX]
				,[intItemUOMId]
				,[ysnAccrue]
				,[ysnMTM]
				,[ysnPrice]
				,[intBillId]
				,[intLoadCostRefId]
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,I.intItemId
				,E.intEntityId [intVendorId]
				,ET.strType
				,x.[strCostMethod]
				,CU.[intCurrencyID]
				,x.[dblRate]
				,x.[dblAmount]
				,x.[dblFX]
				,IU.[intItemUOMId]
				,x.[ysnAccrue]
				,x.[ysnMTM]
				,x.[ysnPrice]
				,NULL [intBillId]
				,[intLoadCostId]
			FROM OPENXML(@idoc, 'vyuLGLoadCostViews/vyuLGLoadCostView', 2) WITH (
					[intLoadCostId] [int]
					,[intConcurrencyId] [int]
					,[intLoadId] [int]
					,[intItemId] [int]
					,[intVendorId] [int]
					,[strEntityType] [nvarchar](100) COLLATE Latin1_General_CI_AS
					,[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS
					,[intCurrencyId] INT
					,[dblRate] [numeric](18, 6)
					,[dblAmount] [numeric](18, 6)
					,[dblFX] [numeric](18, 6)
					,[intItemUOMId] [int]
					,[ysnAccrue] [bit]
					,[ysnMTM] [bit]
					,[ysnPrice] [bit]
					,[intBillId] [int]
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblEMEntity E ON E.strName = x.strEntityName
				AND E.strEntityNo <> ''
			LEFT JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				AND ET.strType = 'Vendor'
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strCurrency
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadCost LC
					WHERE LC.intLoadId = @intNewLoadId
						AND LC.intLoadCostRefId = x.intLoadCostId
					)

			UPDATE LC
			SET [intConcurrencyId] = LC.[intConcurrencyId] + 1
				,[intItemId] = I.[intItemId]
				,[intVendorId] = E.intEntityId
				,[strEntityType] = ET.[strType]
				,[strCostMethod] = x.[strCostMethod]
				,[intCurrencyId] = LC.[intCurrencyId] + 1
				,[dblRate] = x.[dblRate]
				,[dblAmount] = x.[dblAmount]
				,[dblFX] = x.[dblFX]
				,[intItemUOMId] = IU.[intItemUOMId]
				,[ysnAccrue] = x.[ysnAccrue]
				,[ysnMTM] = x.[ysnMTM]
				,[ysnPrice] = x.[ysnPrice]
			FROM OPENXML(@idoc, 'vyuLGLoadCostViews/vyuLGLoadCostView', 2) WITH (
					[intLoadCostId] [int]
					,[intConcurrencyId] [int]
					,[intLoadId] [int]
					,[intItemId] [int]
					,[intVendorId] [int]
					,[strEntityType] [nvarchar](100) COLLATE Latin1_General_CI_AS
					,[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS
					,[intCurrencyId] INT
					,[dblRate] [numeric](18, 6)
					,[dblAmount] [numeric](18, 6)
					,[dblFX] [numeric](18, 6)
					,[intItemUOMId] [int]
					,[ysnAccrue] [bit]
					,[ysnMTM] [bit]
					,[ysnPrice] [bit]
					,[intBillId] [int]
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,strItemUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblLGLoadCost LC ON LC.intLoadId = @intNewLoadId
				AND LC.intLoadCostRefId = x.intLoadCostId
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strItemUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblEMEntity E ON E.strName = x.strEntityName
				AND E.strEntityNo <> ''
			LEFT JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId
				AND ET.strType = 'Vendor'
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strCurrency

			DELETE LC
			FROM tblLGLoadCost LC
			WHERE LC.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadCostViews/vyuLGLoadCostView', 2) WITH (intLoadCostId INT) x
					WHERE LC.intLoadCostRefId = x.intLoadCostId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadStorageCost

			--Load Storage cost
			INSERT INTO tblLGLoadStorageCost (
				[intConcurrencyId]
				,[intLoadId]
				,[intLoadDetailLotId]
				,[dblPrice]
				,[intPriceCurrencyId]
				,[intPriceUOMId]
				,[dblAmount]
				,[intCurrency]
				,[intCostType]
				,[ysnSubCurrency]
				,[intLoadStorageCostRefId]
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,(
					SELECT TOP 1 [intLoadDetailLotId]
					FROM tblLGLoadDetailLot LDL
					JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
					WHERE LDL.intLoadDetailLotRefId = x.intLoadDetailLotId
						AND LD.intLoadId = @intNewLoadId
					)
				,[dblPrice]
				,CU.[intCurrencyID]
				,IU.[intItemUOMId]
				,x.[dblAmount]
				,CU2.[intCurrencyID]
				,I2.intItemId [intCostType]
				,x.[ysnSubCurrency]
				,[intLoadStorageCostId]
			FROM OPENXML(@idoc, 'vyuLGLoadStorageCostViews/vyuLGLoadStorageCostView', 2) WITH (
					[intLoadStorageCostId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[intLoadDetailLotId] INT
					,[dblPrice] NUMERIC(18, 6)
					,[intPriceCurrencyId] INT
					,[intPriceUOMId] INT
					,[dblAmount] NUMERIC(18, 6)
					,[intCurrency] INT
					,[intCostType] INT
					,[ysnSubCurrency] BIT
					,strPriceCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCostType NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					--,intLoadDetailLotId int
					) x
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strPriceCurrency
			LEFT JOIN tblSMCurrency CU2 ON CU.strCurrency = x.strCurrency
			LEFT JOIN tblICItem I2 ON I2.strItemNo = x.strCostType
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadStorageCost LSC
					WHERE LSC.intLoadId = @intNewLoadId
						AND LSC.intLoadStorageCostRefId = x.intLoadStorageCostId
					)

			UPDATE LSC
			SET [intConcurrencyId] = LSC.[intConcurrencyId] + 1
				,[intLoadDetailLotId] = (
					SELECT TOP 1 [intLoadDetailLotId]
					FROM tblLGLoadDetailLot LDL
					JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
					WHERE LDL.intLoadDetailLotRefId = x.intLoadDetailLotId
						AND LD.intLoadId = @intNewLoadId
					)
				,[dblPrice] = x.[dblPrice]
				,[intPriceCurrencyId] = CU.[intCurrencyID]
				,[intPriceUOMId] = IU.[intItemUOMId]
				,[dblAmount] = x.[dblAmount]
				,[intCurrency] = CU2.[intCurrencyID]
				,[intCostType] = I2.intItemId
				,[ysnSubCurrency] = x.[ysnSubCurrency]
				,[intLoadStorageCostRefId] = x.[intLoadStorageCostId]
			FROM OPENXML(@idoc, 'vyuLGLoadStorageCostViews/vyuLGLoadStorageCostView', 2) WITH (
					[intLoadStorageCostId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[intLoadDetailLotId] INT
					,[dblPrice] NUMERIC(18, 6)
					,[intPriceCurrencyId] INT
					,[intPriceUOMId] INT
					,[dblAmount] NUMERIC(18, 6)
					,[intCurrency] INT
					,[intCostType] INT
					,[ysnSubCurrency] BIT
					,strPriceCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strCostType NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblLGLoadStorageCost LSC ON LSC.intLoadId = @intNewLoadId
				AND LSC.intLoadStorageCostRefId = x.intLoadStorageCostId
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUOM
			LEFT JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			LEFT JOIN tblSMCurrency CU ON CU.strCurrency = x.strPriceCurrency
			LEFT JOIN tblSMCurrency CU2 ON CU.strCurrency = x.strCurrency
			LEFT JOIN tblICItem I2 ON I2.strItemNo = x.strCostType

			DELETE LSC
			FROM tblLGLoadStorageCost LSC
			WHERE LSC.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadStorageCostViews/vyuLGLoadStorageCostView', 2) WITH (intLoadStorageCostId INT) x
					WHERE LSC.intLoadStorageCostRefId = x.intLoadStorageCostId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadWarehouse

			--Load warehouse
			INSERT INTO tblLGLoadWarehouse (
				[intConcurrencyId]
				,[intLoadId]
				,[strDeliveryNoticeNumber]
				,[dtmDeliveryNoticeDate]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[intHaulerEntityId]
				,[dtmPickupDate]
				,[dtmDeliveryDate]
				,[dtmLastFreeDate]
				,[dtmStrippingReportReceivedDate]
				,[dtmSampleAuthorizedDate]
				,[strStrippingReportComments]
				,[strFreightComments]
				,[strSampleComments]
				,[strOtherComments]
				,[intWarehouseRateMatrixHeaderId]
				,[intLoadWarehouseRefId]
				)
			SELECT 1 AS [intConcurrencyId]
				,@intNewLoadId
				,[strDeliveryNoticeNumber]
				,[dtmDeliveryNoticeDate]
				,CLSL.[intCompanyLocationSubLocationId]
				,SL.[intStorageLocationId]
				,Hauler.[intEntityId]
				,x.[dtmPickupDate]
				,x.[dtmDeliveryDate]
				,x.[dtmLastFreeDate]
				,x.[dtmStrippingReportReceivedDate]
				,x.[dtmSampleAuthorizedDate]
				,x.[strStrippingReportComments]
				,x.[strFreightComments]
				,x.[strSampleComments]
				,x.[strOtherComments]
				,NULL [intWarehouseRateMatrixHeaderId]
				,[intLoadWarehouseId]
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseViews/vyuLGLoadWarehouseView', 2) WITH (
					[intLoadWarehouseId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[strDeliveryNoticeNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dtmDeliveryNoticeDate] DATETIME
					,[intSubLocationId] INT
					,[intStorageLocationId] INT
					,[intHaulerEntityId] INT
					,[dtmPickupDate] DATETIME
					,[dtmDeliveryDate] DATETIME
					,[dtmLastFreeDate] DATETIME
					,[dtmStrippingReportReceivedDate] DATETIME
					,[dtmSampleAuthorizedDate] DATETIME
					,[strStrippingReportComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strSampleComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strOtherComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intWarehouseRateMatrixHeaderId] INT
					,[intLoadWarehouseRefId] INT
					,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strWarehouse NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strShipVia NVARCHAR(100) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.strSubLocationName = x.strWarehouse
			LEFT JOIN tblICStorageLocation SL ON SL.strName = x.strStorageLocationName
			LEFT JOIN tblEMEntity Hauler ON Hauler.strName = x.strShipVia
				AND Hauler.strEntityNo <> '' --???
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadWarehouse LW
					WHERE LW.intLoadId = @intNewLoadId
						AND LW.intLoadWarehouseRefId = x.intLoadWarehouseId
					)

			UPDATE LW
			SET [intConcurrencyId] = LW.[intConcurrencyId] + 1
				,[strDeliveryNoticeNumber] = x.[strDeliveryNoticeNumber]
				,[dtmDeliveryNoticeDate] = x.[dtmDeliveryNoticeDate]
				,[intSubLocationId] = CLSL.[intCompanyLocationSubLocationId]
				,[intStorageLocationId] = SL.[intStorageLocationId]
				,[intHaulerEntityId] = Hauler.[intEntityId]
				,[dtmPickupDate] = x.[dtmPickupDate]
				,[dtmDeliveryDate] = x.[dtmDeliveryDate]
				,[dtmLastFreeDate] = x.[dtmLastFreeDate]
				,[dtmStrippingReportReceivedDate] = x.[dtmStrippingReportReceivedDate]
				,[dtmSampleAuthorizedDate] = x.[dtmSampleAuthorizedDate]
				,[strStrippingReportComments] = x.[strStrippingReportComments]
				,[strFreightComments] = x.[strFreightComments]
				,[strSampleComments] = x.[strSampleComments]
				,[strOtherComments] = x.[strOtherComments]
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseViews/vyuLGLoadWarehouseView', 2) WITH (
					[intLoadWarehouseId] INT
					,[intConcurrencyId] INT
					,[intLoadId] INT
					,[strDeliveryNoticeNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS
					,[dtmDeliveryNoticeDate] DATETIME
					,[intSubLocationId] INT
					,[intStorageLocationId] INT
					,[intHaulerEntityId] INT
					,[dtmPickupDate] DATETIME
					,[dtmDeliveryDate] DATETIME
					,[dtmLastFreeDate] DATETIME
					,[dtmStrippingReportReceivedDate] DATETIME
					,[dtmSampleAuthorizedDate] DATETIME
					,[strStrippingReportComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strFreightComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strSampleComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[strOtherComments] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intWarehouseRateMatrixHeaderId] INT
					,[intLoadWarehouseRefId] INT
					,strStorageLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strWarehouse NVARCHAR(50) COLLATE Latin1_General_CI_AS
					,strShipVia NVARCHAR(50) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblLGLoadWarehouse LW ON LW.intLoadId = @intNewLoadId
				AND LW.intLoadWarehouseRefId = x.intLoadWarehouseId
			JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.strSubLocationName = x.strWarehouse
			LEFT JOIN tblICStorageLocation SL ON SL.strName = x.strStorageLocationName
			LEFT JOIN tblEMEntity Hauler ON Hauler.strName = x.strShipVia
				AND Hauler.strEntityNo <> '' --???

			DELETE LW
			FROM tblLGLoadWarehouse LW
			WHERE LW.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadWarehouseViews/vyuLGLoadWarehouseView', 2) WITH (intLoadWarehouseId INT) x
					WHERE LW.intLoadWarehouseRefId = x.intLoadWarehouseId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadWarehouseServices

			--Load warehouse Services
			INSERT INTO tblLGLoadWarehouseServices (
				[intConcurrencyId]
				,[intLoadWarehouseId]
				,[strCategory]
				,[strActivity]
				,[intType]
				,[intItemId]
				,[dblUnitRate]
				,[intItemUOMId]
				,[dblQuantity]
				,[dblCalculatedAmount]
				,[dblActualAmount]
				,[ysnChargeCustomer]
				,[dblBillAmount]
				,[ysnPrint]
				,[intSort]
				,[strComments]
				,[intLoadWarehouseServicesRefId]
				)
			SELECT 1 AS [intConcurrencyId]
				,(
					SELECT TOP 1 [intLoadWarehouseId]
					FROM tblLGLoadWarehouse LW
					WHERE LW.[intLoadWarehouseRefId] = x.[intLoadWarehouseId]
						AND intLoadId = @intNewLoadId
					)
				,x.[strCategory]
				,x.[strActivity]
				,NULL [intType]
				,I.[intItemId]
				,x.[dblUnitRate]
				,IU.[intItemUOMId]
				,x.[dblQuantity]
				,x.[dblCalculatedAmount]
				,x.[dblActualAmount]
				,x.[ysnChargeCustomer]
				,x.[dblBillAmount]
				,x.[ysnPrint]
				,x.[intSort]
				,x.[strComments]
				,[intLoadWarehouseServicesId]
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseServicesViews/vyuLGLoadWarehouseServicesView', 2) WITH (
					[intLoadWarehouseServicesId] INT
					,[intConcurrencyId] INT
					,[intLoadWarehouseId] INT
					,[strCategory] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[strActivity] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intType] INT
					,[intItemId] [int]
					,[dblUnitRate] NUMERIC(18, 6)
					,[intItemUOMId] INT
					,[dblQuantity] NUMERIC(18, 6)
					,[dblCalculatedAmount] NUMERIC(18, 6)
					,[dblActualAmount] NUMERIC(18, 6)
					,[ysnChargeCustomer] [bit]
					,[dblBillAmount] NUMERIC(18, 6)
					,[ysnPrint] [bit]
					,[intSort] INT
					,[strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[intBillId] [int]
					,[intWarehouseRateMatrixDetailId] [int]
					,strItemNo NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,strUnitMeasure NVARCHAR(300) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadWarehouseServices LWS
					JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWS.intLoadWarehouseId
					WHERE W.intLoadId = @intNewLoadId
						AND LWS.intLoadWarehouseServicesRefId = x.intLoadWarehouseServicesId
					)

			UPDATE LWS
			SET [intConcurrencyId] = LWS.[intConcurrencyId] + 1
				,[strCategory] = x.[strCategory]
				,[strActivity] = x.[strActivity]
				,[intItemId] = I.[intItemId]
				,[dblUnitRate] = x.[dblUnitRate]
				,[intItemUOMId] = IU.[intItemUOMId]
				,[dblQuantity] = x.[dblQuantity]
				,[dblCalculatedAmount] = x.[dblCalculatedAmount]
				,[dblActualAmount] = x.[dblActualAmount]
				,[ysnChargeCustomer] = x.[ysnChargeCustomer]
				,[dblBillAmount] = x.[dblBillAmount]
				,[ysnPrint] = x.[ysnPrint]
				,[intSort] = x.[intSort]
				,[strComments] = x.[strComments]
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseServicesViews/vyuLGLoadWarehouseServicesView', 2) WITH (
					[intLoadWarehouseServicesId] INT
					,[intConcurrencyId] INT
					,[intLoadWarehouseId] INT
					,[strCategory] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[strActivity] NVARCHAR(1024) COLLATE Latin1_General_CI_AS
					,[intType] INT
					,[intItemId] [int]
					,[dblUnitRate] NUMERIC(18, 6)
					,[intItemUOMId] INT
					,[dblQuantity] NUMERIC(18, 6)
					,[dblCalculatedAmount] NUMERIC(18, 6)
					,[dblActualAmount] NUMERIC(18, 6)
					,[ysnChargeCustomer] [bit]
					,[dblBillAmount] NUMERIC(18, 6)
					,[ysnPrint] [bit]
					,[intSort] INT
					,[strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,[intBillId] [int]
					,[intWarehouseRateMatrixDetailId] [int]
					,strItemNo NVARCHAR(300) COLLATE Latin1_General_CI_AS
					,strUnitMeasure NVARCHAR(300) COLLATE Latin1_General_CI_AS
					) x
			JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseServicesRefId = x.intLoadWarehouseServicesId
			JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWS.intLoadWarehouseId
				AND W.intLoadId = @intNewLoadId
			JOIN tblICItem I ON I.strItemNo = x.strItemNo
			LEFT JOIN tblICUnitMeasure UM ON UM.strUnitMeasure = x.strUnitMeasure
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				AND IU.intUnitMeasureId = UM.intUnitMeasureId

			DELETE LWS
			FROM tblLGLoadWarehouseServices LWS
			JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWS.intLoadWarehouseId
			WHERE W.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadWarehouseServicesViews/vyuLGLoadWarehouseServicesView', 2) WITH (intLoadWarehouseServicesId INT) x
					WHERE LWS.intLoadWarehouseServicesRefId = x.intLoadWarehouseServicesId
					)

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadWarehouseContainer

			--Load warehouse Containers
			INSERT INTO tblLGLoadWarehouseContainer (
				[intConcurrencyId]
				,[intLoadWarehouseId]
				,[intLoadContainerId]
				,[intLoadWarehouseContainerRefId]
				)
			SELECT 1 AS [intConcurrencyId]
				,(
					SELECT TOP 1 [intLoadWarehouseId]
					FROM tblLGLoadWarehouse LW
					WHERE LW.intLoadWarehouseRefId = x.intLoadWarehouseId
						AND intLoadId = @intNewLoadId
					)
				,(
					SELECT TOP 1 [intLoadContainerId]
					FROM tblLGLoadContainer LC
					WHERE LC.intLoadContainerRefId = x.intLoadContainerId
						AND intLoadId = @intNewLoadId
					)
				,[intLoadWarehouseContainerId]
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseContainerViews/vyuLGLoadWarehouseServicesContainer', 2) WITH (
					[intLoadWarehouseId] INT
					,[intLoadContainerId] INT
					,[intLoadWarehouseContainerId] INT
					) x
			WHERE NOT EXISTS (
					SELECT *
					FROM tblLGLoadWarehouseContainer LWC
					JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWC.intLoadWarehouseId
					WHERE W.intLoadId = @intNewLoadId
						AND LWC.[intLoadWarehouseContainerRefId] = x.[intLoadWarehouseContainerId]
					)

			UPDATE LWC
			SET [intConcurrencyId] = LWC.[intConcurrencyId] + 1
				,[intLoadWarehouseId] = (
					SELECT TOP 1 [intLoadWarehouseId]
					FROM tblLGLoadWarehouse LW
					WHERE LW.intLoadWarehouseRefId = x.intLoadWarehouseId
						AND intLoadId = @intNewLoadId
					)
				,[intLoadContainerId] = (
					SELECT TOP 1 [intLoadContainerId]
					FROM tblLGLoadContainer LC
					WHERE LC.intLoadContainerRefId = x.intLoadContainerId
						AND intLoadId = @intNewLoadId
					)
			FROM OPENXML(@idoc, 'vyuLGLoadWarehouseContainerViews/vyuLGLoadWarehouseServicesContainer', 2) WITH (
					[intLoadWarehouseId] INT
					,[intLoadContainerId] INT
					,[intLoadWarehouseContainerId] INT
					) x
			JOIN tblLGLoadWarehouseContainer LWC ON LWC.[intLoadWarehouseContainerRefId] = x.[intLoadWarehouseContainerId]
			JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWC.intLoadWarehouseId
				AND W.intLoadId = @intNewLoadId

			DELETE LWC
			FROM tblLGLoadWarehouseContainer LWC
			JOIN tblLGLoadWarehouse W ON W.intLoadWarehouseId = LWC.intLoadWarehouseId
			WHERE W.intLoadId = @intNewLoadId
				AND NOT EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuLGLoadWarehouseContainerViews/vyuLGLoadWarehouseServicesContainer', 2) WITH ([intLoadWarehouseContainerId] INT) x
					WHERE LWC.[intLoadWarehouseContainerRefId] = x.[intLoadWarehouseContainerId]
					)

			SELECT @strHeaderCondition = 'intLoadId = ' + LTRIM(@intNewLoadId)

			EXEC uspCTGetTableDataInXML 'tblLGLoad'
				,@strHeaderCondition
				,@strAckLoadXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadDetail'
				,@strHeaderCondition
				,@strAckLoadDetailXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadNotifyParties'
				,@strHeaderCondition
				,@strAckLoadNotifyPartyXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadDocuments'
				,@strHeaderCondition
				,@strAckLoadDocumentXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadContainer'
				,@strHeaderCondition
				,@strAckLoadContainerXML OUTPUT

			SELECT @strLoadContainerId = COALESCE(@strLoadContainerId + ',', '') + CAST(intLoadContainerId AS VARCHAR(5))
			FROM tblLGLoadContainer
			WHERE intLoadId = @intNewLoadId

			SELECT @strLoadDetailContainerLinkCondition = 'intLoadContainerId IN (' + LTRIM(@strLoadContainerId) + ')'

			EXEC dbo.uspCTGetTableDataInXML 'tblLGLoadDetailContainerLink'
				,@strLoadDetailContainerLinkCondition
				,@strAckLoadDetailContainerLinkXML OUTPUT
				,NULL
				,NULL

			EXEC uspCTGetTableDataInXML 'tblLGLoadCost'
				,@strHeaderCondition
				,@strAckLoadCostXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadStorageCost'
				,@strHeaderCondition
				,@strAckLoadStorageCostXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblLGLoadWarehouse'
				,@strHeaderCondition
				,@strAckLoadWarehouseXML OUTPUT

			SELECT @strLoadWarehouseId = COALESCE(@strLoadWarehouseId + ',', '') + CAST(intLoadWarehouseId AS VARCHAR(5))
			FROM tblLGLoadWarehouse
			WHERE intLoadId = @intNewLoadId

			SELECT @strLoadWarehouseCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'

			EXEC dbo.uspCTGetTableDataInXML 'tblLGLoadWarehouseServices'
				,@strLoadWarehouseCondition
				,@strAckLoadWarehouseServicesXML OUTPUT
				,NULL
				,NULL

			EXEC dbo.uspCTGetTableDataInXML 'tblLGLoadWarehouseContainer'
				,@strLoadWarehouseCondition
				,@strAckLoadWarehouseContainerXML OUTPUT
				,NULL
				,NULL

			SELECT @intLoadScreenId = intScreenId
			FROM tblSMScreen
			WHERE strNamespace = 'Logistics.view.ShipmentSchedule'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction
			WHERE intRecordId = @intNewLoadId
				AND intScreenId = @intLoadScreenId

			EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
				,@referenceTransactionId = @intTransactionId
				,@referenceCompanyId = @intCompanyId

			DECLARE @strSQL NVARCHAR(MAX)
				,@strServerName NVARCHAR(50)
				,@strDatabaseName NVARCHAR(50)

			SELECT @strServerName = strServerName
				,@strDatabaseName = strDatabaseName
			FROM tblIPMultiCompany
			WHERE intCompanyId = @intCompanyId

			IF EXISTS (
					SELECT 1
					FROM master.dbo.sysdatabases
					WHERE name = @strDatabaseName
					)
			BEGIN
				SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + 
					'.dbo.tblLGIntrCompLogisticsAck (
				intLoadId
				,strLoadNumber
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
				,strLoad
				,strLoadDetail
				,strLoadNotifyParty
				,strLoadDocument
				,strLoadContainer
				,strLoadDetailContainerLink
				,strLoadCost
				,strLoadStorageCost
				,strLoadWarehouse
				,strLoadWarehouseServices
				,strLoadWarehouseContainer
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewLoadId
				,@strNewLoadNumber
				,GETDATE()
				,''Success''
				,@strTransactionType
				,@intMultiCompanyId
				,@strAckLoadXML
				,@strAckLoadDetailXML
				,@strAckLoadNotifyPartyXML
				,@strAckLoadDocumentXML
				,@strAckLoadContainerXML
				,@strAckLoadDetailContainerLinkXML
				,@strAckLoadCostXML
				,@strAckLoadStorageCostXML
				,@strAckLoadWarehouseXML
				,@strAckLoadWarehouseServicesXML
				,@strAckLoadWarehouseContainerXML
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId'

				EXEC sp_executesql @strSQL
					,N'@intNewLoadId int
				,@strNewLoadNumber nvarchar(50)
				,@strTransactionType nvarchar(50)
				,@intMultiCompanyId int
				,@strAckLoadXML nvarchar(MAX)
				,@strAckLoadDetailXML nvarchar(MAX)
				,@strAckLoadNotifyPartyXML nvarchar(MAX)
				,@strAckLoadDocumentXML nvarchar(MAX)
				,@strAckLoadContainerXML nvarchar(MAX)
				,@strAckLoadDetailContainerLinkXML nvarchar(MAX)
				,@strAckLoadCostXML nvarchar(MAX)
				,@strAckLoadStorageCostXML nvarchar(MAX)
				,@strAckLoadWarehouseXML nvarchar(MAX)
				,@strAckLoadWarehouseServicesXML nvarchar(MAX)
				,@strAckLoadWarehouseContainerXML nvarchar(MAX)
				,@intTransactionId int
				,@intCompanyId int
				,@intTransactionRefId int
				,@intCompanyRefId int'
					,@intNewLoadId
					,@strNewLoadNumber
					,@strTransactionType
					,@intMultiCompanyId
					,@strAckLoadXML
					,@strAckLoadDetailXML
					,@strAckLoadNotifyPartyXML
					,@strAckLoadDocumentXML
					,@strAckLoadContainerXML
					,@strAckLoadDetailContainerLinkXML
					,@strAckLoadCostXML
					,@strAckLoadStorageCostXML
					,@strAckLoadWarehouseXML
					,@strAckLoadWarehouseServicesXML
					,@strAckLoadWarehouseContainerXML
					,@intTransactionId
					,@intCompanyId
					,@intTransactionRefId
					,@intCompanyRefId
			END

			NextTransaction:

			UPDATE tblLGIntrCompLogisticsStg
			SET strFeedStatus = 'Processed'
			WHERE intId = @intId

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblLGIntrCompLogisticsStg
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
			WHERE intId = @intId

			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg
		END CATCH

		SELECT @intId = MIN(intId)
		FROM @tblLGIntrCompLogisticsStg
		WHERE intId > @intId
	END

	UPDATE S
	SET strFeedStatus = NULL
	From tblLGIntrCompLogisticsStg S
	JOIN @tblLGIntrCompLogisticsStg PS on PS.intId=S.intId
	Where S.strFeedStatus = 'In-Progress'

	IF @strTransactionType IN (
			'Outbound Shipment'
			,'Outbound Shipping Instruction'
			)
	BEGIN
		UPDATE tblLGLoad
		SET intPurchaseSale = 2
		WHERE intLoadId = @intNewLoadId

		UPDATE LD
		SET intCustomerEntityId = CH.intEntityId
			,intSCompanyLocationId = CD.intCompanyLocationId
			,intPCompanyLocationId = NULL
			,intVendorEntityId = NULL
			,intVendorEntityLocationId = NULL
		FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE LD.intLoadId = @intNewLoadId
	END

	IF @strTransactionType IN (
			'Inbound Shipment'
			,'Inbound Shipping Instruction'
			)
	BEGIN
		--DECLARE @intFreightTermId INT
		SELECT @intFreightTermId = intFreightTermId
		FROM tblSMFreightTerms
		WHERE strFreightTerm = 'Pickup'

		UPDATE tblLGLoad
		SET intPurchaseSale = 1
			,intSourceType = 2
			,intFreightTermId = @intFreightTermId
		WHERE intLoadId = @intNewLoadId

		IF EXISTS (
				SELECT TOP 1 1
				FROM tblLGLoad
				WHERE intLoadId = @intNewLoadId
					AND ISNULL(intBookId, '') = ''
				)
		BEGIN
			UPDATE tblLGLoad
			SET intBookId = @intToBookId
			WHERE intLoadId = @intNewLoadId
		END

		UPDATE LD
		SET intVendorEntityId = CH.intEntityId
			,intPCompanyLocationId = CD.intCompanyLocationId
			,intSCompanyLocationId = NULL
			,intCustomerEntityId = NULL
			,intCustomerEntityLocationId = NULL
		FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE LD.intLoadId = @intNewLoadId
	END

	EXEC uspLGUpdateContractQty @intLoadId = @intNewLoadId

	IF ISNULL(@strInfo1, '') <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
