CREATE PROCEDURE [uspLGProcessLogisticsAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intAcknowledgementStageId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
	DECLARE @strCostCondition NVARCHAR(MAX)
	DECLARE @strContractDetailAllId NVARCHAR(MAX)
	DECLARE @strAckLoadXML NVARCHAR(MAX)
	DECLARE @strAckLoadDetailXML NVARCHAR(MAX)
	DECLARE @strAckLoadNotifyPartyXML NVARCHAR(MAX)
	DECLARE @strAckLoadDocumentXML NVARCHAR(MAX)
	DECLARE @strAckLoadContainerXML NVARCHAR(MAX)
	DECLARE @strAckLoadDetailContainerLinkXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseServicesXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseContainerXML NVARCHAR(MAX)
	DECLARE @strAckLoadCostXML NVARCHAR(MAX)
	DECLARE @strAckLoadStorageCostXML NVARCHAR(MAX)
	DECLARE @intLoadId INT
	DECLARE @intLoadRefId INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @strContractNumber NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intContractHeaderId INT
	DECLARE @intContractHeaderRefId INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
		,@intBookId INT
		,@intSubBookId INT

	Declare @tblLGIntrCompLogisticsAck table(intAcknowledgementId int)
	Insert into @tblLGIntrCompLogisticsAck(intAcknowledgementId)
	SELECT intAcknowledgementId
	FROM tblLGIntrCompLogisticsAck
	WHERE strFeedStatus IS NULL

	SELECT @intAcknowledgementStageId = MIN(intAcknowledgementId)
	FROM @tblLGIntrCompLogisticsAck

	if @intAcknowledgementStageId is null
	Begin
		Return
	End
		UPDATE S
	SET strFeedStatus = 'In-Progress'
	From tblLGIntrCompLogisticsAck S
	JOIN @tblLGIntrCompLogisticsAck PS on PS.intAcknowledgementId=S.intAcknowledgementId


	WHILE @intAcknowledgementStageId > 0
	BEGIN
		SET @strAckLoadXML = NULL
		SET @strAckLoadDetailXML = NULL
		SET @strAckLoadNotifyPartyXML = NULL
		SET @strAckLoadDocumentXML = NULL
		SET @strAckLoadContainerXML = NULL
		SET @strAckLoadDetailContainerLinkXML = NULL
		SET @strAckLoadWarehouseXML = NULL
		SET @strAckLoadWarehouseServicesXML = NULL
		SET @strAckLoadWarehouseContainerXML = NULL
		SET @strAckLoadCostXML = NULL
		SET @strAckLoadStorageCostXML = NULL
		SET @strTransactionType = NULL

		SELECT @intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckLoadXML = strLoad
			,@strAckLoadDetailXML = strLoadDetail
			,@strAckLoadNotifyPartyXML = strLoadNotifyParty
			,@strAckLoadDocumentXML = strLoadDocument
			,@strAckLoadContainerXML = strLoadContainer
			,@strAckLoadDetailContainerLinkXML = strLoadDetailContainerLink
			,@strAckLoadWarehouseXML = strLoadWarehouse
			,@strAckLoadWarehouseServicesXML = strLoadWarehouseServices
			,@strAckLoadWarehouseContainerXML = strLoadWarehouseContainer
			,@strAckLoadCostXML = strLoadCost
			,@strAckLoadStorageCostXML = strLoadStorageCost
			,@strTransactionType = strTransactionType
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblLGIntrCompLogisticsAck
		WHERE intAcknowledgementId = @intAcknowledgementStageId

		------------------Header------------------------------------------------------
		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadXML

		SELECT @intLoadId = intLoadId
			,@intLoadRefId = intLoadRefId
			,@strLoadNumber = strLoadNumber
			,@intBookId = intBookId
			,@intSubBookId = intSubBookId
		FROM OPENXML(@idoc, 'tblLGLoads/tblLGLoad', 2) WITH (
				intLoadId INT
				,intLoadRefId INT
				,strLoadNumber NVARCHAR(100)
				,intBookId INT
				,intSubBookId INT
				)

		IF NOT EXISTS (
				SELECT *
				FROM tblLGIntrCompLogisticsStg
				WHERE intLoadId = @intLoadRefId
				)
		BEGIN
			GOTO NextTransaction
		END

		UPDATE tblLGLoad
		SET intLoadRefId = @intLoadId
			,strExternalLoadNumber = @strContractNumber
		WHERE intLoadId = @intLoadRefId
			AND intLoadRefId IS NULL

		-----------------------------------Detail-------------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadDetailXML

		UPDATE LD
		SET LD.intLoadDetailRefId = XMLDetail.intLoadDetailId
		FROM OPENXML(@idoc, 'tblLGLoadDetails/tblLGLoadDetail', 2) WITH (
				intLoadDetailId INT
				,intLoadDetailRefId INT
				) XMLDetail
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = XMLDetail.intLoadDetailRefId
		WHERE LD.intLoadId = @intLoadRefId
			AND LD.intLoadDetailRefId IS NULL

		-----------------------------------NotifyParty--------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadNotifyPartyXML

		UPDATE LN
		SET LN.intLoadNotifyPartyRefId = XMLNotifyParty.intLoadNotifyPartyId
		FROM OPENXML(@idoc, 'tblLGLoadNotifyPartiess/tblLGLoadNotifyParties', 2) WITH (
				intLoadNotifyPartyId INT
				,intLoadNotifyPartyRefId INT
				) XMLNotifyParty
		JOIN tblLGLoadNotifyParties LN ON LN.intLoadNotifyPartyId = XMLNotifyParty.intLoadNotifyPartyRefId
		WHERE LN.intLoadId = @intLoadRefId
			AND LN.intLoadNotifyPartyRefId IS NULL

		-----------------------------------Document--------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadDocumentXML

		UPDATE LD
		SET LD.intLoadDocumentRefId = XMLDocument.intLoadDocumentId
		FROM OPENXML(@idoc, 'tblLGLoadDocumentss/tblLGLoadDocuments', 2) WITH (
				intLoadDocumentId INT
				,intLoadDocumentRefId INT
				) XMLDocument
		JOIN tblLGLoadDocuments LD ON LD.intLoadDocumentId = XMLDocument.intLoadDocumentRefId
		WHERE LD.intLoadId = @intLoadRefId
			AND LD.intLoadDocumentRefId IS NULL

		-----------------------------------Container-------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadContainerXML

		UPDATE LC
		SET LC.intLoadContainerRefId = XMLContainer.intLoadContainerId
		FROM OPENXML(@idoc, 'tblLGLoadContainers/tblLGLoadContainer', 2) WITH (
				intLoadContainerId INT
				,intLoadContainerRefId INT
				) XMLContainer
		JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = XMLContainer.intLoadContainerRefId
		WHERE LC.intLoadId = @intLoadRefId
			AND LC.intLoadContainerRefId IS NULL

		--------------------------------ContainerLink------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadDetailContainerLinkXML

		UPDATE LDCL
		SET LDCL.intLoadDetailContainerLinkRefId = XMLContainerLink.intLoadDetailContainerLinkId
		FROM OPENXML(@idoc, 'tblLGLoadDetailContainerLinks/tblLGLoadDetailContainerLink', 2) WITH (
				intLoadDetailContainerLinkId INT
				,intLoadDetailContainerLinkRefId INT
				) XMLContainerLink
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailContainerLinkId = XMLContainerLink.intLoadDetailContainerLinkRefId
		JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		WHERE LC.intLoadId = @intLoadRefId
			AND LDCL.intLoadDetailContainerLinkRefId IS NULL

		--------------------------------Warehouse------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadWarehouseXML

		UPDATE LW
		SET LW.intLoadWarehouseRefId = XMLWarehouse.intLoadWarehouseId
		FROM OPENXML(@idoc, 'tblLGLoadWarehouses/tblLGLoadWarehouse', 2) WITH (
				intLoadWarehouseId INT
				,intLoadWarehouseRefId INT
				) XMLWarehouse
		JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = XMLWarehouse.intLoadWarehouseRefId
		WHERE LW.intLoadId = @intLoadRefId
			AND LW.intLoadWarehouseRefId IS NULL

		--------------------------------Cost------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadCostXML

		UPDATE LCO
		SET LCO.intLoadCostRefId = XMLCost.intLoadCostId
		FROM OPENXML(@idoc, 'tblLGLoadCosts/tblLGLoadCost', 2) WITH (
				intLoadCostId INT
				,intLoadCostRefId INT
				) XMLCost
		JOIN tblLGLoadCost LCO ON LCO.intLoadCostId = XMLCost.intLoadCostRefId
		WHERE LCO.intLoadId = @intLoadRefId
			AND LCO.intLoadCostRefId IS NULL

		--------------------------------StorageCost------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadStorageCostXML

		UPDATE LSC
		SET LSC.intLoadStorageCostRefId = XMLStorageCost.intLoadStorageCostId
		FROM OPENXML(@idoc, 'tblLGLoadStorageCosts/tblLGLoadStorageCost', 2) WITH (
				intLoadStorageCostId INT
				,intLoadStorageCostRefId INT
				) XMLStorageCost
		JOIN tblLGLoadStorageCost LSC ON LSC.intLoadStorageCostId = XMLStorageCost.intLoadStorageCostRefId
		WHERE LSC.intLoadId = @intLoadRefId
			AND LSC.intLoadStorageCostRefId IS NULL

		--------------------------------Warehouse Services------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadWarehouseServicesXML

		UPDATE LWS
		SET LWS.intLoadWarehouseServicesRefId = XMLStorageCost.intLoadWarehouseServicesId
		FROM OPENXML(@idoc, 'tblLGLoadWarehouseServicess/tblLGLoadWarehouseServices', 2) WITH (
				intLoadWarehouseServicesId INT
				,intLoadWarehouseServicesRefId INT
				) XMLStorageCost
		JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseServicesId = XMLStorageCost.intLoadWarehouseServicesRefId
		JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		WHERE LW.intLoadId = @intLoadRefId
			AND LWS.intLoadWarehouseServicesRefId IS NULL

		--------------------------------Warehouse Container------------------------------------
		EXEC sp_xml_removedocument @idoc

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strAckLoadWarehouseContainerXML

		UPDATE LWC
		SET LWC.intLoadWarehouseContainerRefId = XMLStorageCost.intLoadWarehouseContainerId
		FROM OPENXML(@idoc, 'tblLGLoadWarehouseContainers/tblLGLoadWarehouseContainer', 2) WITH (
				intLoadWarehouseContainerId INT
				,intLoadWarehouseContainerRefId INT
				) XMLStorageCost
		JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadWarehouseContainerId = XMLStorageCost.intLoadWarehouseContainerRefId
		JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		WHERE LW.intLoadId = @intLoadRefId
			AND LWC.intLoadWarehouseContainerRefId IS NULL

		---UPDATE Feed Status in Staging
		UPDATE tblLGIntrCompLogisticsStg
		SET strFeedStatus = 'Ack Rcvd'
			,strMessage = 'Success'
		WHERE intLoadId = @intLoadRefId
			AND strFeedStatus = 'Awt Ack'

		---UPDATE Feed Status in Acknowledgement
		UPDATE tblLGIntrCompLogisticsAck
		SET strFeedStatus = 'Ack Processed'
		WHERE intAcknowledgementId = @intAcknowledgementStageId

		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
			,@referenceTransactionId = @intTransactionRefId
			,@referenceCompanyId = @intCompanyRefId

		NextTransaction:

		EXEC sp_xml_removedocument @idoc

		SELECT @intAcknowledgementStageId = MIN(intAcknowledgementId)
		FROM @tblLGIntrCompLogisticsAck
		WHERE intAcknowledgementId > @intAcknowledgementStageId
	END
			UPDATE S
	SET strFeedStatus = NULL
	From tblLGIntrCompLogisticsAck S
	JOIN @tblLGIntrCompLogisticsAck PS on PS.intAcknowledgementId=S.intAcknowledgementId
	Where strFeedStatus = 'In-Progress'
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
