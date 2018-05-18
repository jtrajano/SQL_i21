CREATE PROCEDURE [dbo].[uspLGProcessInterCompanyLogisticsXML]
AS
BEGIN TRY
	SET NOCOUNT ON

BEGIN TRANSACTION

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intId INT
	DECLARE @intLoadId INT
	DECLARE @strLoadNumber NVARCHAR(MAX)
	DECLARE @strLoad NVARCHAR(MAX)
	DECLARE @strLoadDetail NVARCHAR(MAX)
	DECLARE @strLoadDetailLot NVARCHAR(MAX)
	DECLARE @strLoadDocument NVARCHAR(MAX)
	DECLARE @strLoadNotifyParty NVARCHAR(MAX)
	DECLARE @strLoadContainer NVARCHAR(MAX)
	DECLARE @strLoadDetailContainerLink NVARCHAR(MAX)
	DECLARE @strLoadWarehouse NVARCHAR(MAX)
	DECLARE @strLoadWarehouseServices NVARCHAR(MAX)
	DECLARE @strLoadWarehouseContainer NVARCHAR(MAX)
	DECLARE @strLoadCost NVARCHAR(MAX)
	DECLARE @strLoadStorageCost NVARCHAR(MAX)
	DECLARE @strReference NVARCHAR(MAX)
	DECLARE @strRowState NVARCHAR(MAX)
	DECLARE @strFeedStatus NVARCHAR(MAX)
	DECLARE @dtmFeedDate DATETIME
	DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @intMultiCompanyId INT
	DECLARE @intReferenceId INT
	DECLARE @intEntityId INT
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @strTagRelaceXML NVARCHAR(MAX)
	DECLARE @NewLoadId INT
	DECLARE @NewLoadDetailId INT
	DECLARE @NewLoadDocumentId INT
	DECLARE @NewLoadNotifyPartyId INT
	DECLARE @NewLoadContainerId INT
	DECLARE @NewLoadDetailContainerLinkId INT
	DECLARE @NewLoadWarehouseId INT
	DECLARE @NewLoadWarehouseContainerId INT
	DECLARE @NewLoadWarehouseServicesId INT
	DECLARE @NewLoadCostId INT
	DECLARE @NewLoadStorageCostId INT
	DECLARE @intPurchaseSale INT
	DECLARE @strDetailReplaceXml NVARCHAR(max) = ''
	DECLARE @strDetailReplaceXmlForContainers NVARCHAR(max) = ''
	DECLARE @intStartingNumberType INT
	DECLARE @intLogisticsAcknowledgementStageId INT

	DECLARE @strHeaderCondition NVARCHAR(MAX)
	
	DECLARE @strContractDetailAllId NVARCHAR(MAX)
	DECLARE @strAckLoadXML NVARCHAR(MAX)
	DECLARE @strAckLoadDetailXML NVARCHAR(MAX)
	DECLARE @strAckLoadNotifyPartyXML NVARCHAR(MAX)
	DECLARE @strAckLoadDocumentXML NVARCHAR(MAX)
	DECLARE @strAckLoadContainerXML NVARCHAR(MAX)
	DECLARE @strAckLoadDetailContainerLinkXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseContainerXML NVARCHAR(MAX)
	DECLARE @strAckLoadWarehouseServicesXML NVARCHAR(MAX)
	DECLARE @strAckLoadCostXML NVARCHAR(MAX)
	DECLARE @strAckLoadStorageCostXML NVARCHAR(MAX)
	DECLARE @strLoadContainerId NVARCHAR(500)
	DECLARE @strLoadWarehouseId NVARCHAR(500)
	DECLARE @strLoadDetailContainerLinkCondition NVARCHAR(MAX)
	DECLARE @strLoadWarehouseCondition NVARCHAR(MAX)
	DECLARE @intToBookId INT

	--DECLARE @strAckCostXML		NVARCHAR(MAX)
	--DECLARE @strAckDocumentXML NVARCHAR(MAX)
	
	DECLARE @tempLoadDetail TABLE (
		[intLoadDetailId] INT NOT NULL
		,[intConcurrencyId] INT NOT NULL
		,[intLoadId] INT NOT NULL
		,[intVendorEntityId] INT NULL
		,[intVendorEntityLocationId] INT NULL
		,[intCustomerEntityId] INT NULL
		,[intCustomerEntityLocationId] INT NULL
		,[intItemId] INT NULL
		,[intPContractDetailId] INT NULL
		,[intSContractDetailId] INT NULL
		,[intPCompanyLocationId] INT NULL
		,[intSCompanyLocationId] INT NULL
		,[dblQuantity] NUMERIC(18, 6) NULL
		,[intItemUOMId] INT NULL
		,[dblGross] NUMERIC(18, 6) NULL
		,[dblTare] NUMERIC(18, 6) NULL
		,[dblNet] NUMERIC(18, 6) NULL
		,[intWeightItemUOMId] INT NULL
		,[dblDeliveredQuantity] NUMERIC(18, 6) NULL
		,[dblDeliveredGross] NUMERIC(18, 6) NULL
		,[dblDeliveredTare] NUMERIC(18, 6) NULL
		,[dblDeliveredNet] NUMERIC(18, 6) NULL
		,[strLotAlias] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[strSupplierLotNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[dtmProductionDate] DATETIME NULL
		,[strScheduleInfoMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[ysnUpdateScheduleInfo] [bit] NULL
		,[ysnPrintScheduleInfo] [bit] NULL
		,[strLoadDirectionMsg] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,[ysnUpdateLoadDirections] [bit] NULL
		,[ysnPrintLoadDirections] [bit] NULL
		,[strVendorReference] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[strCustomerReference] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[intAllocationDetailId] INT NULL
		,[intPickLotDetailId] INT NULL
		,[intPSubLocationId] INT NULL
		,[intSSubLocationId] INT NULL
		,[intNumberOfContainers] INT NULL
		,[strExternalShipmentItemNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[strExternalBatchNo] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		,[ysnNoClaim] BIT
		)

	SELECT @intId = MIN(intId)
	FROM tblLGIntrCompLogisticsStg
	WHERE strFeedStatus IS NULL
		AND strRowState = 'Added'

	WHILE @intId > 0
	BEGIN
		SET @intLoadId = NULL
		SET @strLoadNumber = NULL
		SET @strLoad = NULL
		SET @strLoadDetail = NULL
		SET @strLoadDocument = NULL
		SET @strLoadNotifyParty = NULL
		SET @strLoadContainer = NULL
		SET @strLoadDetailContainerLink = NULL
		SET @strLoadWarehouse = NULL
		SET @strLoadWarehouseContainer = NULL
		SET @strLoadWarehouseServices = NULL
		SET @strLoadCost = NULL
		SET @strLoadStorageCost = NULL
		SET @strReference = NULL
		SET @strRowState = NULL
		SET @strFeedStatus = NULL
		SET @dtmFeedDate = NULL
		SET @strMessage = NULL
		SET @intMultiCompanyId = NULL
		SET @intReferenceId = NULL
		SET @intEntityId = NULL
		SET @strTransactionType = NULL
		SET @intToBookId = NULL

		SELECT @intLoadId = intLoadId
			,@strLoadNumber = strLoadNumber
			,@strLoad = strLoad
			,@strLoadDetail = strLoadDetail
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
			,@intMultiCompanyId = intMultiCompanyId
			,@intReferenceId = intReferenceId
			,@intEntityId = intEntityId
			,@strTransactionType = strTransactionType
			,@intToBookId = intToBookId
		FROM tblLGIntrCompLogisticsStg
		WHERE intId = @intId
		
		IF( @strTransactionType LIKE '%Instruction%')
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
		ELSE 
		BEGIN
			SET @intPurchaseSale = 2
		END

		BEGIN
			DECLARE @newLoadNumber NVARCHAR(100)

			EXEC uspSMGetStartingNumber @intStartingNumberType
				,@newLoadNumber OUTPUT

			SET @strTagRelaceXML = NULL
			SET @strLoad = REPLACE(@strLoad, 'intLoadId>', 'intLoadRefId>')
			SET @strLoad = REPLACE(@strLoad, 'intCompanyId>', 'CompanyId>')
			SET @strTagRelaceXML = '<root>
											<tags>
												<toFind>&lt;strLoadNumber&gt;' + LTRIM(@strLoadNumber) + '&lt;/strLoadNumber&gt;</toFind>
												<toReplace>&lt;strLoadNumber&gt;' + LTRIM(@newLoadNumber) + '&lt;/strLoadNumber&gt;</toReplace>
											</tags>
										</root>'

			EXEC uspCTInsertINTOTableFromXML 'tblLGLoad'
				,@strLoad
				,@NewLoadId OUTPUT
				,@strTagRelaceXML

			INSERT INTO tblLGIntrCompLogisticsAck 
			(
				 intLoadId
				,strLoadNumber
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
			)
			SELECT 
				 @NewLoadId
				,@newLoadNumber
				,GETDATE()
				,'Success'
				,@strTransactionType
				,@intMultiCompanyId

			SELECT @intLogisticsAcknowledgementStageId = SCOPE_IDENTITY();

			SELECT @strHeaderCondition = 'intLoadId = ' + LTRIM(@NewLoadId)
						
			EXEC uspCTGetTableDataInXML 'tblLGLoad',@strHeaderCondition,@strAckLoadXML  OUTPUT

			UPDATE  tblLGIntrCompLogisticsAck 
			SET		strLoad =@strAckLoadXML 
			WHERE   intAcknowledgementId =@intLogisticsAcknowledgementStageId

			IF OBJECT_ID('tempdb..#tempLoadDetail') IS NOT NULL
				DROP TABLE #tempLoadDetail

			EXEC uspCTInsertINTOTableFromXML '@tempLoadDetail'
				,@strLoadDetail
				,@NewLoadDetailId OUTPUT
				,@strTagRelaceXML

			DECLARE @idoc INT

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strLoadDetail

			DECLARE @intMinXMLLoadDetailId INT
			DECLARE @tempXMLLoadDetail TABLE (
				intId INT IDENTITY(1, 1)
				,intLoadDetailId INT
				,intLoadId INT
				,intVendorEntityId INT
				,intVendorEntityLocationId INT
				,intCustomerEntityId INT
				,intCustomerEntityLocationId INT
				,intItemId INT
				,intPContractDetailId INT
				,intSContractDetailId INT
				,intPCompanyLocationId INT
				,intSCompanyLocationId INT
				,dblQuantity NUMERIC
				,intItemUOMId INT
				,dblGross NUMERIC
				,dblTare NUMERIC
				,dblNet NUMERIC
				,intWeightItemUOMId INT
				,dblDeliveredQuantity NUMERIC
				,dblDeliveredGross NUMERIC
				,dblDeliveredTare NUMERIC
				,dblDeliveredNet NUMERIC
				,strLotAlias NVARCHAR
				,strScheduleInfoMsg NVARCHAR
				,ysnUpdateScheduleInfo BIT
				,ysnPrintScheduleInfo BIT
				,strLoadDirectionMsg NVARCHAR
				,ysnUpdateLoadDirections BIT
				,ysnPrintLoadDirections BIT
				,strVendorReference NVARCHAR
				,strCustomerReference NVARCHAR
				,intPSubLocationId INT
				,intSSubLocationId INT
				,intNumberOfContainers INT
				,intLoadDetailRefId INT
				)
			DECLARE @intLoadDetailId INT
				,@intPContractDetailId INT
				,@intSContractDetailId INT

			INSERT INTO @tempXMLLoadDetail
			SELECT DISTINCT intLoadDetailId
				,intLoadId
				,intVendorEntityId
				,intVendorEntityLocationId
				,intCustomerEntityId
				,intCustomerEntityLocationId
				,intItemId
				,intPContractDetailId
				,intSContractDetailId
				,intPCompanyLocationId
				,intSCompanyLocationId
				,dblQuantity
				,intItemUOMId
				,dblGross
				,dblTare
				,dblNet
				,intWeightItemUOMId
				,dblDeliveredQuantity
				,dblDeliveredGross
				,dblDeliveredTare
				,dblDeliveredNet
				,strLotAlias
				,strScheduleInfoMsg
				,ysnUpdateScheduleInfo
				,ysnPrintScheduleInfo
				,strLoadDirectionMsg
				,ysnUpdateLoadDirections
				,ysnPrintLoadDirections
				,strVendorReference
				,strCustomerReference
				,intPSubLocationId
				,intSSubLocationId
				,intNumberOfContainers
				,intLoadDetailRefId
			FROM OPENXML(@idoc, 'tblLGLoadDetails/tblLGLoadDetail', 2) WITH (
					intLoadDetailId INT
					,intLoadId INT
					,intVendorEntityId INT
					,intVendorEntityLocationId INT
					,intCustomerEntityId INT
					,intCustomerEntityLocationId INT
					,intItemId INT
					,intPContractDetailId INT
					,intSContractDetailId INT
					,intPCompanyLocationId INT
					,intSCompanyLocationId INT
					,dblQuantity NUMERIC
					,intItemUOMId INT
					,dblGross NUMERIC
					,dblTare NUMERIC
					,dblNet NUMERIC
					,intWeightItemUOMId INT
					,dblDeliveredQuantity NUMERIC
					,dblDeliveredGross NUMERIC
					,dblDeliveredTare NUMERIC
					,dblDeliveredNet NUMERIC
					,strLotAlias NVARCHAR
					,strScheduleInfoMsg NVARCHAR
					,ysnUpdateScheduleInfo BIT
					,ysnPrintScheduleInfo BIT
					,strLoadDirectionMsg NVARCHAR
					,ysnUpdateLoadDirections BIT
					,ysnPrintLoadDirections BIT
					,strVendorReference NVARCHAR
					,strCustomerReference NVARCHAR
					,intPSubLocationId INT
					,intSSubLocationId INT
					,intNumberOfContainers INT
					,intLoadDetailRefId INT
					)

			SELECT @intMinXMLLoadDetailId = MIN(intId)
			FROM @tempXMLLoadDetail

			WHILE ISNULL(@intMinXMLLoadDetailId, 0) > 0
			BEGIN
				SET @intLoadDetailId = NULL
				SET @intPContractDetailId = NULL
				SET @intSContractDetailId = NULL
				SET @NewLoadDetailId = NULL

				IF (@intPurchaseSale = 1)
				BEGIN
					SELECT @intSContractDetailId = intSContractDetailId
						,@intLoadDetailId = intLoadDetailId
					FROM @tempXMLLoadDetail
					WHERE intId = @intMinXMLLoadDetailId

					SELECT @intPContractDetailId = intContractDetailId
					FROM tblCTContractDetail
					WHERE intContractDetailRefId = @intSContractDetailId

					UPDATE @tempXMLLoadDetail
					SET intSContractDetailId = NULL
						,intPContractDetailId = @intPContractDetailId
						,intLoadId = @NewLoadId
						,intLoadDetailRefId = intLoadDetailId
					WHERE intLoadDetailId = @intLoadDetailId

					INSERT INTO tblLGLoadDetail (
						intLoadId
						,intVendorEntityId
						,intVendorEntityLocationId
						,intCustomerEntityId
						,intCustomerEntityLocationId
						,intItemId
						,intPContractDetailId
						,intSContractDetailId
						,intPCompanyLocationId
						,intSCompanyLocationId
						,dblQuantity
						,intItemUOMId
						,dblGross
						,dblTare
						,dblNet
						,intWeightItemUOMId
						,dblDeliveredQuantity
						,dblDeliveredGross
						,dblDeliveredTare
						,dblDeliveredNet
						,strLotAlias
						,strScheduleInfoMsg
						,ysnUpdateScheduleInfo
						,ysnPrintScheduleInfo
						,strLoadDirectionMsg
						,ysnUpdateLoadDirections
						,ysnPrintLoadDirections
						,strVendorReference
						,strCustomerReference
						,intPSubLocationId
						,intSSubLocationId
						,intNumberOfContainers
						,intLoadDetailRefId
						,intConcurrencyId
						)
					SELECT @NewLoadId
						,intVendorEntityId
						,intVendorEntityLocationId
						,intCustomerEntityId
						,intCustomerEntityLocationId
						,intItemId
						,intPContractDetailId
						,intSContractDetailId
						,intPCompanyLocationId
						,intSCompanyLocationId
						,dblQuantity
						,intItemUOMId
						,dblGross
						,dblTare
						,dblNet
						,intWeightItemUOMId
						,dblDeliveredQuantity
						,dblDeliveredGross
						,dblDeliveredTare
						,dblDeliveredNet
						,strLotAlias
						,strScheduleInfoMsg
						,ysnUpdateScheduleInfo
						,ysnPrintScheduleInfo
						,strLoadDirectionMsg
						,ysnUpdateLoadDirections
						,ysnPrintLoadDirections
						,strVendorReference
						,strCustomerReference
						,intPSubLocationId
						,intSSubLocationId
						,intNumberOfContainers
						,intLoadDetailRefId
						,1
					FROM @tempXMLLoadDetail
					WHERE intPContractDetailId = @intPContractDetailId

				END
				ELSE
				BEGIN
					SELECT @intPContractDetailId = intPContractDetailId
						,@intLoadDetailId = intLoadDetailId
					FROM @tempXMLLoadDetail
					WHERE intId = @intMinXMLLoadDetailId

					SELECT @intSContractDetailId = intContractDetailId
					FROM tblCTContractDetail
					WHERE intContractDetailRefId = @intPContractDetailId

					UPDATE @tempXMLLoadDetail
					SET intSContractDetailId = @intSContractDetailId
						,intPContractDetailId = NULL
						,intLoadId = @NewLoadId
						,intLoadDetailRefId = intLoadDetailId
					WHERE intLoadDetailId = @intLoadDetailId
					
					INSERT INTO tblLGLoadDetail (
						intLoadId
						,intVendorEntityId
						,intVendorEntityLocationId
						,intCustomerEntityId
						,intCustomerEntityLocationId
						,intItemId
						,intPContractDetailId
						,intSContractDetailId
						,intPCompanyLocationId
						,intSCompanyLocationId
						,dblQuantity
						,intItemUOMId
						,dblGross
						,dblTare
						,dblNet
						,intWeightItemUOMId
						,dblDeliveredQuantity
						,dblDeliveredGross
						,dblDeliveredTare
						,dblDeliveredNet
						,strLotAlias
						,strScheduleInfoMsg
						,ysnUpdateScheduleInfo
						,ysnPrintScheduleInfo
						,strLoadDirectionMsg
						,ysnUpdateLoadDirections
						,ysnPrintLoadDirections
						,strVendorReference
						,strCustomerReference
						,intPSubLocationId
						,intSSubLocationId
						,intNumberOfContainers
						,intLoadDetailRefId
						,intConcurrencyId
						)
					SELECT @NewLoadId
						,intVendorEntityId
						,intVendorEntityLocationId
						,intCustomerEntityId
						,intCustomerEntityLocationId
						,intItemId
						,intPContractDetailId
						,intSContractDetailId
						,intPCompanyLocationId
						,intSCompanyLocationId
						,dblQuantity
						,intItemUOMId
						,dblGross
						,dblTare
						,dblNet
						,intWeightItemUOMId
						,dblDeliveredQuantity
						,dblDeliveredGross
						,dblDeliveredTare
						,dblDeliveredNet
						,strLotAlias
						,strScheduleInfoMsg
						,ysnUpdateScheduleInfo
						,ysnPrintScheduleInfo
						,strLoadDirectionMsg
						,ysnUpdateLoadDirections
						,ysnPrintLoadDirections
						,strVendorReference
						,strCustomerReference
						,intPSubLocationId
						,intSSubLocationId
						,intNumberOfContainers
						,intLoadDetailRefId
						,1
					FROM @tempXMLLoadDetail
					WHERE intSContractDetailId = @intSContractDetailId

				END

				SET @NewLoadDetailId = SCOPE_IDENTITY()

				SELECT @strDetailReplaceXml = @strDetailReplaceXml + '<tags>' + '<toFind>&lt;intLoadDetailId&gt;' + LTRIM(@intLoadDetailId) + '&lt;/intLoadDetailId&gt;</toFind>' + '<toReplace>&lt;intLoadDetailId&gt;' + LTRIM(@NewLoadDetailId) + '&lt;/intLoadDetailId&gt;</toReplace>' + '</tags>'

				SELECT @intMinXMLLoadDetailId = MIN(intId)
				FROM @tempXMLLoadDetail
				WHERE intId > @intMinXMLLoadDetailId
			END
						
			EXEC uspCTGetTableDataInXML 'tblLGLoadDetail',@strHeaderCondition,@strAckLoadDetailXML  OUTPUT

			UPDATE  tblLGIntrCompLogisticsAck 
			SET		strLoadDetail = @strAckLoadDetailXML 
			WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId

			SET @strDetailReplaceXmlForContainers = @strDetailReplaceXml
			SET @strDetailReplaceXml = '<root>' + @strDetailReplaceXml + '</root>'

			IF (@strLoadDetailLot IS NOT NULL)
			BEGIN
				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadDetailLot'
					,@strLoadDetailLot
					,@NewLoadDetailId OUTPUT
					,@strDetailReplaceXml
			END

			DECLARE @strHeaderReplaceXmlForContainers NVARCHAR(MAX) = '<tags>
												<toFind>&lt;intLoadId&gt;' + LTRIM(@intLoadId) + '&lt;/intLoadId&gt;</toFind>
												<toReplace>&lt;intLoadId&gt;' + LTRIM(@NewLoadId) + '&lt;/intLoadId&gt;</toReplace>
											</tags>'
			DECLARE @strHeaderReplaceXml NVARCHAR(MAX) = '<root>' + @strHeaderReplaceXmlForContainers + '</root>'

			IF (@strLoadNotifyParty IS NOT NULL)
			BEGIN
				SET @strLoadNotifyParty = REPLACE(@strLoadNotifyParty, 'intLoadNotifyPartyId>', 'intLoadNotifyPartyRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadNotifyParties'
					,@strLoadNotifyParty
					,@NewLoadNotifyPartyId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadNotifyParties',@strHeaderCondition,@strAckLoadNotifyPartyXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadNotifyParty = @strAckLoadNotifyPartyXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId

			END

			IF (@strLoadDocument IS NOT NULL)
			BEGIN
				SET @strLoadDocument = REPLACE(@strLoadDocument, 'intLoadDocumentId>', 'intLoadDocumentRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadDocuments'
					,@strLoadDocument
					,@NewLoadDocumentId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadDocuments',@strHeaderCondition,@strAckLoadDocumentXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadDocument = @strAckLoadDocumentXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadContainer IS NOT NULL)
			BEGIN
				SET @strLoadContainer = REPLACE(@strLoadContainer, 'intLoadContainerId>', 'intLoadContainerRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadContainer'
					,@strLoadContainer
					,@NewLoadContainerId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadContainer',@strHeaderCondition,@strAckLoadContainerXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadContainer = @strAckLoadContainerXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadDetailContainerLink IS NOT NULL)
			BEGIN
				DECLARE @idoc2 INT
				DECLARE @tblContainerId AS TABLE (
					intRowNo INT identity
					,intLoadContainerId INT
					)

				EXEC sp_xml_preparedocument @idoc2 OUTPUT
					,@strLoadDetailContainerLink

				INSERT INTO @tblContainerId (intLoadContainerId)
				SELECT DISTINCT intLoadContainerId
				FROM OPENXML(@idoc2, 'tblLGLoadDetailContainerLinks/tblLGLoadDetailContainerLink', 2) WITH (intLoadContainerId INT)

				DECLARE @strContainerReplaceXml NVARCHAR(max) = ''
				DECLARE @strContainerReplaceXmlForWarehouse NVARCHAR(max) = ''

				SELECT @strContainerReplaceXmlForWarehouse = @strContainerReplaceXmlForWarehouse + '<tags>' + '<toFind>&lt;intLoadContainerId&gt;' + LTRIM(t1.intLoadContainerId) + '&lt;/intLoadContainerId&gt;</toFind>' + '<toReplace>&lt;intLoadContainerId&gt;' + LTRIM(t1.intNewLoadContainerId) + '&lt;/intLoadContainerId&gt;</toReplace>' + '</tags>'
				FROM (
					SELECT t.intLoadContainerId intNewLoadContainerId
						,td.intLoadContainerId
					FROM (
						SELECT ROW_NUMBER() OVER (
								ORDER BY intLoadContainerId
								) intRowNo
							,*
						FROM tblLGLoadContainer cd
						WHERE cd.intLoadId = @NewLoadId
						) t
					JOIN @tblContainerId td ON t.intRowNo = td.intRowNo
					) t1

				SET @strContainerReplaceXml = '<root>' + @strContainerReplaceXmlForWarehouse + @strDetailReplaceXmlForContainers + @strHeaderReplaceXmlForContainers + '</root>'
				SET @strLoadDetailContainerLink = REPLACE(@strLoadDetailContainerLink, 'intLoadDetailContainerLinkId>', 'intLoadDetailContainerLinkRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadDetailContainerLink'
					,@strLoadDetailContainerLink
					,@NewLoadContainerId OUTPUT
					,@strContainerReplaceXml

				SELECT @strLoadContainerId = COALESCE(@strLoadContainerId + ',', '') + CAST(intLoadContainerId AS VARCHAR(5))
				FROM tblLGLoadContainer
				WHERE intLoadId = @NewLoadId

				SELECT @strLoadDetailContainerLinkCondition = 'intLoadContainerId IN (' + LTRIM(@strLoadContainerId) + ')'

				EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadDetailContainerLink'
					,@strLoadDetailContainerLinkCondition
					,@strAckLoadDetailContainerLinkXML OUTPUT
					,NULL
					,NULL

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadDetailContainerLink = @strAckLoadDetailContainerLinkXML
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadCost IS NOT NULL)
			BEGIN
				SET @strLoadCost = REPLACE(@strLoadCost, 'intLoadCostId>', 'intLoadCostRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadCost'
					,@strLoadCost
					,@NewLoadCostId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadCost',@strHeaderCondition,@strAckLoadCostXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadCost = @strAckLoadCostXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadStorageCost IS NOT NULL)
			BEGIN
				SET @strLoadStorageCost = REPLACE(@strLoadStorageCost, 'intLoadStorageCostId>', 'intLoadStorageCostRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadStorageCost'
					,@strLoadStorageCost
					,@NewLoadStorageCostId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadStorageCost',@strHeaderCondition,@strAckLoadStorageCostXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadStorageCost = @strAckLoadStorageCostXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadWarehouse IS NOT NULL)
			BEGIN
				SET @strLoadWarehouse = REPLACE(@strLoadWarehouse, 'intLoadWarehouseId>', 'intLoadWarehouseRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadWarehouse'
					,@strLoadWarehouse
					,@NewLoadWarehouseId OUTPUT
					,@strHeaderReplaceXml

				EXEC uspCTGetTableDataInXML 'tblLGLoadWarehouse',@strHeaderCondition,@strAckLoadWarehouseXML  OUTPUT

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadWarehouse = @strAckLoadWarehouseXML 
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId

				SELECT @strLoadWarehouseId = COALESCE(@strLoadWarehouseId + ',', '') + CAST(intLoadWarehouseId AS VARCHAR(5))
				FROM tblLGLoadWarehouse
				WHERE intLoadId = @NewLoadId

				SELECT @strLoadWarehouseCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'
			END

			IF (@strLoadWarehouseServices IS NOT NULL)
			BEGIN
				DECLARE @idoc3 INT
				DECLARE @tblWarehouseId AS TABLE (
					intRowNo INT identity
					,intLoadWarehouseId INT
					)

				EXEC sp_xml_preparedocument @idoc3 OUTPUT
					,@strLoadWarehouseServices

				INSERT INTO @tblWarehouseId (intLoadWarehouseId)
				SELECT DISTINCT intLoadWarehouseId
				FROM OPENXML(@idoc3, 'tblLGLoadWarehouseServicess/tblLGLoadWarehouseServices', 2) WITH (intLoadWarehouseId INT)

				DECLARE @strWarehouseReplaceXml NVARCHAR(max) = ''
				DECLARE @strWarehouseReplaceXmlForOthers NVARCHAR(max) = ''

				SELECT @strWarehouseReplaceXmlForOthers = @strWarehouseReplaceXmlForOthers + '<tags>' + '<toFind>&lt;intLoadWarehouseId&gt;' + LTRIM(t1.intLoadWarehouseId) + '&lt;/intLoadWarehouseId&gt;</toFind>' + '<toReplace>&lt;intLoadWarehouseId&gt;' + LTRIM(t1.intNewLoadWarehouseId) + '&lt;/intLoadWarehouseId&gt;</toReplace>' + '</tags>'
				FROM (
					SELECT t.intLoadWarehouseId intNewLoadWarehouseId
						,td.intLoadWarehouseId
					FROM (
						SELECT ROW_NUMBER() OVER (
								ORDER BY intLoadWarehouseId
								) intRowNo
							,*
						FROM tblLGLoadWarehouse cd
						WHERE cd.intLoadId = @NewLoadId
						) t
					JOIN @tblWarehouseId td ON t.intRowNo = td.intRowNo
					) t1

				SET @strWarehouseReplaceXml = '<root>' + @strWarehouseReplaceXmlForOthers + '</root>'
				SET @strLoadWarehouseServices = REPLACE(@strLoadWarehouseServices, 'intLoadWarehouseServicesId>', 'intLoadWarehouseServicesRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadWarehouseServices'
					,@strLoadWarehouseServices
					,@NewLoadWarehouseId OUTPUT
					,@strWarehouseReplaceXml

				EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadWarehouseServices'
					,@strLoadWarehouseCondition
					,@strAckLoadWarehouseServicesXML OUTPUT
					,NULL
					,NULL

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadWarehouseServices = @strAckLoadWarehouseServicesXML
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END

			IF (@strLoadWarehouseContainer IS NOT NULL)
			BEGIN
				DECLARE @idoc4 INT
				DECLARE @tblContainerWarehouseId AS TABLE (
					intRowNo INT identity
					,intLoadWarehouseId INT
					)

				EXEC sp_xml_preparedocument @idoc4 OUTPUT
					,@strLoadWarehouseContainer

				INSERT INTO @tblContainerWarehouseId (intLoadWarehouseId)
				SELECT DISTINCT intLoadWarehouseId
				FROM OPENXML(@idoc4, 'tblLGLoadWarehouseContainers/tblLGLoadWarehouseContainer', 2) WITH (intLoadWarehouseId INT)

				DECLARE @strWarehouseContainerReplaceXml NVARCHAR(max) = ''
				DECLARE @strWarehouseContainerReplaceXmlForOthers NVARCHAR(max) = ''

				SELECT @strWarehouseContainerReplaceXmlForOthers = @strWarehouseContainerReplaceXmlForOthers + '<tags>' + '<toFind>&lt;intLoadWarehouseId&gt;' + LTRIM(t1.intLoadWarehouseId) + '&lt;/intLoadWarehouseId&gt;</toFind>' + '<toReplace>&lt;intLoadWarehouseId&gt;' + LTRIM(t1.intNewLoadWarehouseId) + '&lt;/intLoadWarehouseId&gt;</toReplace>' + '</tags>'
				FROM (
					SELECT t.intLoadWarehouseId intNewLoadWarehouseId
						,td.intLoadWarehouseId
					FROM (
						SELECT ROW_NUMBER() OVER (
								ORDER BY intLoadWarehouseId
								) intRowNo
							,*
						FROM tblLGLoadWarehouse cd
						WHERE cd.intLoadId = @NewLoadId
						) t
					JOIN @tblContainerWarehouseId td ON t.intRowNo = td.intRowNo
					) t1

				SET @strWarehouseReplaceXml = NULL
				SET @strWarehouseReplaceXml = '<root>' + @strWarehouseContainerReplaceXmlForOthers + @strContainerReplaceXmlForWarehouse + '</root>'
				SET @strLoadWarehouseContainer = REPLACE(@strLoadWarehouseContainer, 'intLoadWarehouseContainerId>', 'intLoadWarehouseContainerRefId>')

				EXEC uspCTInsertINTOTableFromXML 'tblLGLoadWarehouseContainer'
					,@strLoadWarehouseContainer
					,@NewLoadWarehouseContainerId OUTPUT
					,@strWarehouseReplaceXml

				EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadWarehouseContainer'
					,@strLoadWarehouseCondition
					,@strAckLoadContainerXML OUTPUT
					,NULL
					,NULL

				UPDATE  tblLGIntrCompLogisticsAck 
				SET		strLoadWarehouseContainer = @strAckLoadContainerXML
				WHERE   intAcknowledgementId = @intLogisticsAcknowledgementStageId
			END
		END

		UPDATE tblLGIntrCompLogisticsStg 
		SET strFeedStatus = 'Processed' 
		WHERE intId = @intId

		SELECT @intId = MIN(intId)
		FROM tblLGIntrCompLogisticsStg
		WHERE intId > @intId
			AND strRowState = 'Added'
			AND strFeedStatus IS NULL
	END

	IF @strTransactionType IN (
			'Outbound Shipment'
			,'Outbound Shipping Instruction'
			)
	BEGIN
		UPDATE tblLGLoad
		SET intPurchaseSale = 2
		WHERE intLoadId = @NewLoadId

		UPDATE LD	
			SET intCustomerEntityId = CH.intEntityId,
				intSCompanyLocationId = CD.intCompanyLocationId,
				intPCompanyLocationId = NULL,
				intVendorEntityId = NULL,
				intVendorEntityLocationId = NULL
		FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE LD.intLoadId = @NewLoadId		
	END

	IF @strTransactionType IN (
			'Inbound Shipment'
			,'Inbound Shipping Instruction'
			)
	BEGIN
		DECLARE @intFreightTermId INT

		SELECT @intFreightTermId = intFreightTermId 
		FROM tblSMFreightTerms 
		WHERE strFreightTerm = 'Pickup'

		UPDATE tblLGLoad
		SET intPurchaseSale = 1,
			intSourceType = 2,
			intFreightTermId = @intFreightTermId
		WHERE intLoadId = @NewLoadId


		IF EXISTS(SELECT TOP 1 1 FROM tblLGLoad WHERE intLoadId = @NewLoadId AND ISNULL(intBookId,'') = '')
		BEGIN
			UPDATE tblLGLoad
			SET intBookId = @intToBookId
			WHERE intLoadId = @NewLoadId
		END

		UPDATE LD	
			SET intVendorEntityId = CH.intEntityId,
				intPCompanyLocationId = CD.intCompanyLocationId,
				intSCompanyLocationId = NULL,
				intCustomerEntityId = NULL,
				intCustomerEntityLocationId = NULL
		FROM tblLGLoadDetail LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE LD.intLoadId = @NewLoadId		
	END

	EXEC uspLGUpdateContractQty @intLoadId = @NewLoadId

	--SELECT *
	--FROM tblLGLoad

	--SELECT *
	--FROM tblLGLoadDetail

	--SELECT *
	--FROM tblLGLoadNotifyParties

	--SELECT *
	--FROM tblLGLoadDocuments

	--SELECT *
	--FROM tblLGLoadContainer

	--SELECT *
	--FROM tblLGLoadDetailContainerLink

	--SELECT *
	--FROM tblLGLoadWarehouse

	--SELECT *
	--FROM tblLGLoadWarehouseContainer

	--SELECT *
	--FROM tblLGLoadWarehouseServices

COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH