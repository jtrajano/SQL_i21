CREATE PROCEDURE uspLGPopulateLoadUpdateXML -- uspLGPopulateLoadXML 48, 'Inbound Shipment', 1
	@intLoadId INT,
	@strToTransactionType NVARCHAR(100),
	@intToCompanyId INT,
	@strRowState NVARCHAR(100)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(100) = NULL
	DECLARE @intScopeIdentityId INT = NULL
	DECLARE @strLoadXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadDetailId INT = NULL
	DECLARE @strLoadDetailXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadDetailCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadDetailLotId INT = NULL
	DECLARE @strLoadDetailLotXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadDetailLotCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadNotifyPartyId INT = NULL
	DECLARE @strLoadNotifyPartyXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadNotifyPartyCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadDocumentId INT = NULL
	DECLARE @strLoadDocumentXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadDocumentCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadContainerId INT = NULL
	DECLARE @strLoadContainerXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadContainerCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadDetailContainerLinkId INT = NULL
	DECLARE @strLoadDetailContainerLinkXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadDetailContainerLinkCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadWarehouseId INT = NULL
	DECLARE @strLoadWarehouseXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadWarehouseCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadWarehouseContainerId INT = NULL
	DECLARE @strLoadWarehouseContainerXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadWarehouseContainerCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadWarehouseServicesId INT = NULL
	DECLARE @strLoadWarehouseServicesXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadWarehouseServicesCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadCostId INT = NULL
	DECLARE @strLoadCostXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadCostCondition NVARCHAR(1024) = NULL
	DECLARE @intLoadStorageCostId INT = NULL
	DECLARE @strLoadStorageCostXML NVARCHAR(MAX) = NULL
	DECLARE @strLoadStorageCostCondition NVARCHAR(1024) = NULL
	DECLARE @strLoadDetailId NVARCHAR(100)
	DECLARE @strLoadContainerId NVARCHAR(100)
	DECLARE @strLoadWarehouseId NVARCHAR(100)

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	---HEADER
	SELECT @strLoadCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoad'
		,@strLoadCondition
		,@strLoadXML OUTPUT
		,NULL
		,NULL

	-- LOAD HEADER TABLE
	INSERT INTO tblLGIntrCompLogisticsStg (
		intLoadId
		,strLoadNumber
		,strLoad
		,strRowState
		)
	SELECT @intLoadId
		,@strLoadNumber
		,@strLoadXML
		,@strRowState

	SET @intScopeIdentityId = SCOPE_IDENTITY()

	-- LOAD DETAIL AND LOAD DETAIL LOT TABLE
	SET @strLoadDetailCondition = NULL
	SET @strLoadDetailXML = NULL

	SELECT @strLoadDetailCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadDetail'
		,@strLoadDetailCondition
		,@strLoadDetailXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadDetail = ISNULL(strLoadDetail, '') + @strLoadDetailXML
	WHERE intId = @intScopeIdentityId

	SET @strLoadDetailLotCondition = NULL
	SET @strLoadDetailLotXML = NULL

	SELECT @strLoadDetailId = COALESCE(@strLoadDetailId + ',', '') + CAST(intLoadDetailId AS VARCHAR(1000))
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId

	SELECT @strLoadDetailLotCondition = 'intLoadDetailId IN (' + LTRIM(@strLoadDetailId) + ')'

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadDetailLot'
		,@strLoadDetailLotCondition
		,@strLoadDetailLotXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadDetailLot = ISNULL(strLoadDetailLot, '') + @strLoadDetailLotXML
	WHERE intId = @intScopeIdentityId

	-- LOAD DOCUMENT TABLE
	SET @strLoadDocumentCondition = NULL
	SET @strLoadDocumentXML = NULL

	SELECT @strLoadDocumentCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadDocuments'
		,@strLoadDocumentCondition
		,@strLoadDocumentXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadDocument = ISNULL(strLoadDocument, '') + @strLoadDocumentXML
	WHERE intId = @intScopeIdentityId

	-- LOAD NOTIFY PARTY TABLE
	SET @strLoadNotifyPartyCondition = NULL
	SET @strLoadNotifyPartyXML = NULL

	SELECT @strLoadNotifyPartyCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadNotifyParties'
		,@strLoadNotifyPartyCondition
		,@strLoadNotifyPartyXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadNotifyParty = ISNULL(strLoadNotifyParty, '') + @strLoadNotifyPartyXML
	WHERE intId = @intScopeIdentityId

	-- LOAD CONTAINER
	SET @strLoadContainerCondition = NULL
	SET @strLoadContainerXML = NULL

	SELECT @strLoadContainerCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadContainer'
		,@strLoadContainerCondition
		,@strLoadContainerXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadContainer = ISNULL(strLoadContainer, '') + @strLoadContainerXML
	WHERE intId = @intScopeIdentityId

	SELECT @intLoadContainerId = MIN(intLoadContainerId)
	FROM tblLGLoadContainer
	WHERE intLoadId = @intLoadId
		AND intLoadContainerId > @intLoadContainerId

	--  LOAD DETAIL CONTAINER LINK
	SELECT @strLoadContainerId = COALESCE(@strLoadContainerId + ',', '') + CAST(intLoadContainerId AS VARCHAR(1000))
	FROM tblLGLoadContainer
	WHERE intLoadId = @intLoadId

	SET @strLoadDetailContainerLinkCondition = NULL
	SET @strLoadDetailContainerLinkXML = NULL

	IF (ISNULL(@strLoadContainerId,'') <> '')
	BEGIN
		SELECT @strLoadDetailContainerLinkCondition = 'intLoadContainerId IN (' + LTRIM(@strLoadContainerId) + ')'

		EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadDetailContainerLink'
			,@strLoadDetailContainerLinkCondition
			,@strLoadDetailContainerLinkXML OUTPUT
			,NULL
			,NULL

		UPDATE tblLGIntrCompLogisticsStg
		SET strLoadDetailContainerLink = ISNULL(strLoadDetailContainerLink, '') + @strLoadDetailContainerLinkXML
		WHERE intId = @intScopeIdentityId
	END
	-- LOAD WAREHOUSE
	SET @strLoadWarehouseCondition = NULL
	SET @strLoadWarehouseXML = NULL

	SELECT @strLoadWarehouseCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadWarehouse'
		,@strLoadWarehouseCondition
		,@strLoadWarehouseXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadWarehouse = ISNULL(strLoadWarehouse, '') + @strLoadWarehouseXML
	WHERE intId = @intScopeIdentityId

	SELECT @strLoadWarehouseId = COALESCE(@strLoadWarehouseId + ',', '') + CAST(intLoadWarehouseId AS VARCHAR(1000))
	FROM tblLGLoadWarehouse
	WHERE intLoadId = @intLoadId

	-- WAREHOUSE SERVICES TABLE
	SET @strLoadWarehouseServicesCondition = NULL
	SET @strLoadWarehouseServicesXML = NULL

	IF EXISTS(SELECT TOP 1 1 FROM tblLGLoadWarehouseServices WHERE intLoadWarehouseId IN (@strLoadWarehouseId))
	BEGIN
		SELECT @strLoadWarehouseServicesCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'

		EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadWarehouseServices'
			,@strLoadWarehouseServicesCondition
			,@strLoadWarehouseServicesXML OUTPUT
			,NULL
			,NULL

		UPDATE tblLGIntrCompLogisticsStg
		SET strLoadWarehouseServices = ISNULL(strLoadWarehouseServices, '') + @strLoadWarehouseServicesXML
		WHERE intId = @intScopeIdentityId
	END

	-- WAREHOUSE CONTAINER TABLE
	SET @strLoadWarehouseContainerCondition = NULL
	SET @strLoadWarehouseContainerXML = NULL

	IF EXISTS(SELECT TOP 1 1 FROM tblLGLoadWarehouseContainer WHERE intLoadWarehouseId IN (@strLoadWarehouseId))
	BEGIN
		SELECT @strLoadWarehouseContainerCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'

		EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadWarehouseContainer'
			,@strLoadWarehouseContainerCondition
			,@strLoadWarehouseContainerXML OUTPUT
			,NULL
			,NULL

		UPDATE tblLGIntrCompLogisticsStg
		SET strLoadWarehouseContainer = ISNULL(strLoadWarehouseContainer, '') + @strLoadWarehouseContainerXML
		WHERE intId = @intScopeIdentityId
	END

	-- LOAD COST TABLE
	SET @strLoadCostCondition = NULL
	SET @strLoadCostXML = NULL

	SELECT @strLoadCostCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadCost'
		,@strLoadCostCondition
		,@strLoadCostXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadCost = ISNULL(strLoadCost, '') + @strLoadCostXML
	WHERE intId = @intScopeIdentityId

	-- LOAD STORAGE COST TABLE
	SET @strLoadStorageCostCondition = NULL
	SET @strLoadStorageCostXML = NULL

	SELECT @strLoadStorageCostCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadStorageCost'
		,@strLoadStorageCostCondition
		,@strLoadStorageCostXML OUTPUT
		,NULL
		,NULL

	UPDATE tblLGIntrCompLogisticsStg
	SET strLoadStorageCost = ISNULL(strLoadStorageCost, '') + @strLoadStorageCostXML
	WHERE intId = @intScopeIdentityId


	UPDATE tblLGIntrCompLogisticsStg
	SET strTransactionType = @strToTransactionType,
		intMultiCompanyId = @intToCompanyId
	WHERE intId = @intScopeIdentityId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
