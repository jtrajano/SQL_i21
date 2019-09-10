﻿CREATE PROCEDURE uspLGPopulateLoadXML @intLoadId INT
	,@strToTransactionType NVARCHAR(100)
	,@intToCompanyId INT
	,@strRowState NVARCHAR(100)
	,@intToCompanyLocationId INT = NULL
	,@intToBookId INT = NULL
	,@ysnReplication BIT = 1
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
	DECLARE @intSourceType INT
		,@strObjectName NVARCHAR(50)

	SELECT @strLoadNumber = strLoadNumber
		,@intSourceType = intSourceType
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF (@intSourceType = 7)
		RETURN;

	---HEADER
	SELECT @strLoadCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoad'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadCondition
		,@strLoadXML OUTPUT
		,NULL
		,NULL

	-- LOAD DETAIL AND LOAD DETAIL LOT TABLE
	SET @strLoadDetailCondition = NULL
	SET @strLoadDetailXML = NULL

	SELECT @strLoadDetailCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadDetail'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadDetailView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadDetailCondition
		,@strLoadDetailXML OUTPUT
		,NULL
		,NULL

	SET @strLoadDetailLotCondition = NULL
	SET @strLoadDetailLotXML = NULL

	SELECT @strLoadDetailId = COALESCE(@strLoadDetailId + ',', '') + CAST(intLoadDetailId AS VARCHAR(1000))
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId

	SELECT @strLoadDetailLotCondition = 'intLoadDetailId IN (' + LTRIM(@strLoadDetailId) + ')'

		IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadDetailLot'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadDetailLotsView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadDetailLotCondition
		,@strLoadDetailLotXML OUTPUT
		,NULL
		,NULL

	-- LOAD DOCUMENT TABLE
	SET @strLoadDocumentCondition = NULL
	SET @strLoadDocumentXML = NULL

	SELECT @strLoadDocumentCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadDocuments'
	ELSE
		SELECT @strObjectName = 'vyuIPLoadDocumentTrackingSummary'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadDocumentCondition
		,@strLoadDocumentXML OUTPUT
		,NULL
		,NULL

	-- LOAD NOTIFY PARTY TABLE
	SET @strLoadNotifyPartyCondition = NULL
	SET @strLoadNotifyPartyXML = NULL

	SELECT @strLoadNotifyPartyCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadNotifyParties'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadNotifyPartiesNotMapped'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadNotifyPartyCondition
		,@strLoadNotifyPartyXML OUTPUT
		,NULL
		,NULL

	-- LOAD CONTAINER
	SET @strLoadContainerCondition = NULL
	SET @strLoadContainerXML = NULL

	SELECT @strLoadContainerCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadContainer'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadContainerView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadContainerCondition
		,@strLoadContainerXML OUTPUT
		,NULL
		,NULL

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

	IF (ISNULL(@strLoadContainerId, '') <> '')
	BEGIN
		SELECT @strLoadDetailContainerLinkCondition = 'intLoadContainerId IN (' + LTRIM(@strLoadContainerId) + ')'

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblLGLoadDetailContainerLink'
		ELSE
			SELECT @strObjectName = 'vyuLGLoadDetailContainerLinkView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strLoadDetailContainerLinkCondition
			,@strLoadDetailContainerLinkXML OUTPUT
			,NULL
			,NULL
	END

	-- LOAD WAREHOUSE
	SET @strLoadWarehouseCondition = NULL
	SET @strLoadWarehouseXML = NULL

	SELECT @strLoadWarehouseCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadWarehouse'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadWarehouseView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadWarehouseCondition
		,@strLoadWarehouseXML OUTPUT
		,NULL
		,NULL

	SELECT @strLoadWarehouseId = COALESCE(@strLoadWarehouseId + ',', '') + CAST(intLoadWarehouseId AS VARCHAR(1000))
	FROM tblLGLoadWarehouse
	WHERE intLoadId = @intLoadId

	-- WAREHOUSE SERVICES TABLE
	SET @strLoadWarehouseServicesCondition = NULL
	SET @strLoadWarehouseServicesXML = NULL

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblLGLoadWarehouseServices
			WHERE intLoadWarehouseId IN (@strLoadWarehouseId)
			)
	BEGIN
		SELECT @strLoadWarehouseServicesCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblLGLoadWarehouseServices'
		ELSE
			SELECT @strObjectName = 'vyuLGLoadWarehouseServices'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strLoadWarehouseServicesCondition
			,@strLoadWarehouseServicesXML OUTPUT
			,NULL
			,NULL
	END

	-- WAREHOUSE CONTAINER TABLE
	SET @strLoadWarehouseContainerCondition = NULL
	SET @strLoadWarehouseContainerXML = NULL

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblLGLoadWarehouseContainer
			WHERE intLoadWarehouseId IN (@strLoadWarehouseId)
			)
	BEGIN
		SELECT @strLoadWarehouseContainerCondition = 'intLoadWarehouseId IN (' + LTRIM(@strLoadWarehouseId) + ')'

		IF @ysnReplication = 1
			SELECT @strObjectName = 'tblLGLoadWarehouseContainer'
		ELSE
			SELECT @strObjectName = 'vyuLGLoadWarehouseContainerView'

		EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
			,@strLoadWarehouseContainerCondition
			,@strLoadWarehouseContainerXML OUTPUT
			,NULL
			,NULL
	END

	-- LOAD COST TABLE
	SET @strLoadCostCondition = NULL
	SET @strLoadCostXML = NULL

	SELECT @strLoadCostCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadCost'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadCostView'

	EXEC [dbo].[uspCTGetTableDataInXML] @strObjectName
		,@strLoadCostCondition
		,@strLoadCostXML OUTPUT
		,NULL
		,NULL

	-- LOAD STORAGE COST TABLE
	SET @strLoadStorageCostCondition = NULL
	SET @strLoadStorageCostXML = NULL

	SELECT @strLoadStorageCostCondition = 'intLoadId = ' + LTRIM(@intLoadId)

	IF @ysnReplication = 1
		SELECT @strObjectName = 'tblLGLoadStorageCost'
	ELSE
		SELECT @strObjectName = 'vyuLGLoadStorageCostView'

	EXEC [dbo].[uspCTGetTableDataInXML] 'tblLGLoadStorageCost'
		,@strLoadStorageCostCondition
		,@strLoadStorageCostXML OUTPUT
		,NULL
		,NULL

	-- LOAD HEADER TABLE
	INSERT INTO tblLGIntrCompLogisticsStg (
		intLoadId
		,strLoadNumber
		,strLoad
		,strRowState
		,strLoadDetail
		,strLoadDetailLot
		,strLoadDocument
		,strLoadNotifyParty
		,strLoadContainer
		,strLoadDetailContainerLink
		,strLoadWarehouse
		,strLoadWarehouseServices
		,strLoadWarehouseContainer
		,strLoadCost
		,strLoadStorageCost
		,strTransactionType
		,intMultiCompanyId
		,intToCompanyLocationId
		,intToBookId
		)
	SELECT @intLoadId
		,@strLoadNumber
		,@strLoadXML
		,@strRowState
		,@strLoadDetailXML
		,@strLoadDetailLotXML
		,@strLoadDocumentXML
		,@strLoadNotifyPartyXML
		,@strLoadContainerXML
		,@strLoadDetailContainerLinkXML
		,@strLoadWarehouseXML
		,@strLoadWarehouseServicesXML
		,@strLoadWarehouseContainerXML
		,@strLoadCostXML
		,@strLoadStorageCostXML
		,@strToTransactionType
		,@intToCompanyId
		,@intToCompanyLocationId
		,@intToBookId
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
