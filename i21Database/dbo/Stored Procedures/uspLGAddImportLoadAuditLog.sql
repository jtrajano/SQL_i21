CREATE PROCEDURE [dbo].[uspLGAddImportLoadAuditLog] (
	@intLoadId INT
	,@intUserId INT
	,@strAction NVARCHAR(20)
	,@strBLNumber NVARCHAR(100) = NULL
	,@strMVessel NVARCHAR(200) = NULL
	,@strMVoyageNumber NVARCHAR(100) = NULL
	,@strServiceContractNumber NVARCHAR(100) = NULL
	,@strOriginPort NVARCHAR(200) = NULL
	,@strDestinationPort NVARCHAR(200) = NULL
	,@strDestinationCity NVARCHAR(200) = NULL
	,@strComments NVARCHAR(MAX) = NULL
	,@dtmBLDate DATETIME = NULL
	,@dtmETAPOL DATETIME = NULL
	,@dtmETSPOL DATETIME = NULL
	,@dtmETAPOD DATETIME = NULL
	,@intNumberOfContainers INT = NULL
	,@intShippingLineEntityId INT = NULL
	,@intShippingModeId INT = NULL
	,@intForwardingAgentEntityId INT = NULL
	,@intContainerTypeId INT = NULL
	,@intLoadContainerId INT = NULL
	,@strMarks NVARCHAR(100) = NULL
	,@strLotNumber NVARCHAR(100) = NULL
	,@strSealNumber NVARCHAR(100) = NULL
	,@strContainerComments NVARCHAR(1024) = NULL
)
AS

IF (@strAction = 'Created')
BEGIN
	EXEC [dbo].[uspSMAuditLog]
		@screenName = 'Logistics.view.ShipmentSchedule'
		,@keyValue = @intLoadId
		,@entityId = @intUserId
		,@actionType = 'Created'
		,@actionIcon = 'small-new-plus'
		,@fromValue = ''
		,@toValue = ''
		,@changeDescription = 'Created (from Import Load)'
		,@details = ''
END
ELSE IF (@strAction = 'Updated')
BEGIN

	DECLARE @intLogId INT
		,@intTransactionId INT
		,@intLoadAuditParentId INT
		,@intContainerAuditParentId INT
		,@intContainerUpdatedAuditParentId INT

	--Get Transaction Id
	EXEC uspSMInsertTransaction @screenNamespace = 'Logistics.view.ShipmentSchedule', @intKeyValue = @intLoadId, @output = @intTransactionId OUTPUT

	--Insert to SM Log
	INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId) 
	VALUES('Audit', GETUTCDATE(), @intUserId, @intTransactionId, 1)
	SET @intLogId = SCOPE_IDENTITY()

	--Insert Load parent Audit entry
	INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)
	SELECT @intLogId, @intLoadId, 'Updated', ('Updated (from Import Load) - Record: ' + CAST(@intLoadId AS nvarchar(20))), 1
	SET @intLoadAuditParentId = SCOPE_IDENTITY()

	DECLARE @strBLNumber_Cur NVARCHAR(100)
		,@strMVessel_Cur NVARCHAR(200)
		,@strMVoyageNumber_Cur NVARCHAR(100)
		,@strServiceContractNumber_Cur NVARCHAR(100)
		,@strOriginPort_Cur NVARCHAR(200)
		,@strDestinationPort_Cur NVARCHAR(200)
		,@strDestinationCity_Cur NVARCHAR(200)
		,@strComments_Cur NVARCHAR(MAX)
		,@dtmBLDate_Cur DATETIME
		,@dtmETAPOL_Cur DATETIME
		,@dtmETSPOL_Cur DATETIME
		,@dtmETAPOD_Cur DATETIME
		,@intNumberOfContainers_Cur INT
		,@strShippingLine_Cur NVARCHAR(200)
		,@strShippingMode_Cur NVARCHAR(100)
		,@strForwardingAgent_Cur NVARCHAR(200)
		,@strContainerType_Cur NVARCHAR(100)
		,@strMarks_Cur NVARCHAR(100)
		,@strLotNumber_Cur NVARCHAR(100)
		,@strSealNumber_Cur NVARCHAR(100)
		,@strContainerComments_Cur NVARCHAR(1024)

	SELECT 
		@strBLNumber_Cur = strBLNumber
		,@strMVessel_Cur = strMVessel
		,@strMVoyageNumber_Cur = strMVoyageNumber
		,@strServiceContractNumber_Cur = strServiceContractNumber
		,@strOriginPort_Cur = strOriginPort
		,@strDestinationPort_Cur = strDestinationPort
		,@strDestinationCity_Cur = strDestinationCity
		,@strComments_Cur = strComments
		,@dtmBLDate_Cur = dtmBLDate
		,@dtmETAPOL_Cur = dtmETAPOL
		,@dtmETSPOL_Cur = dtmETSPOL
		,@dtmETAPOD_Cur = dtmETAPOD
		,@intNumberOfContainers_Cur = intNumberOfContainers
		,@strShippingLine_Cur = SL.strName
		,@strShippingMode_Cur = SPM.strShippingMode
		,@strForwardingAgent_Cur = FA.strName
		,@strContainerType_Cur = CT.strContainerType
	FROM tblLGLoad L
		LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblLGShippingMode SPM ON SPM.intShippingModeId = L.intShippingModeId
		LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
		LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
	WHERE intLoadId = @intLoadId
	
	--Insert Load child Audit entry
	IF (@strBLNumber IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strBLNumber', @strBLNumber, @strBLNumber_Cur, 'BOL No.', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strMVessel IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strMVessel', @strMVessel, @strMVessel_Cur, 'MV Name', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strMVoyageNumber IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strMVoyageNumber', @strMVoyageNumber, @strMVoyageNumber_Cur, 'MV Voyage No.', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strServiceContractNumber IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strServiceContractNumber', @strServiceContractNumber, @strServiceContractNumber_Cur, 'Service Contract No.', 1, 0, @intLoadAuditParentId, 1

	IF (@strOriginPort IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strOriginPort', @strOriginPort, @strOriginPort_Cur, 'Loading Port', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strDestinationPort IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strDestinationPort', @strDestinationPort, @strDestinationPort_Cur, 'Destination Port', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strDestinationCity IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strDestinationCity', @strDestinationCity, @strDestinationCity_Cur, 'Destination City', 1, 0, @intLoadAuditParentId, 1
	
	IF (@strComments IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strComments', @strComments, @strComments_Cur, 'Comments', 1, 0, @intLoadAuditParentId, 1
	
	IF (@dtmBLDate IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'dtmBLDate', @dtmBLDate, @dtmBLDate_Cur, 'BOL Date', 1, 0, @intLoadAuditParentId, 1

	IF (@dtmETAPOL IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'dtmETAPOL', @dtmETAPOL, @dtmETAPOL_Cur, 'ETA POL', 1, 0, @intLoadAuditParentId, 1

	IF (@dtmETSPOL IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'dtmETSPOL', @dtmETSPOL, @dtmETSPOL_Cur, 'ETS POL', 1, 0, @intLoadAuditParentId, 1

	IF (@dtmETAPOD IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'dtmETAPOD', @dtmETAPOD, @dtmETAPOD_Cur, 'ETA POD', 1, 0, @intLoadAuditParentId, 1

	IF (@intNumberOfContainers IS NOT NULL)
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'intNumberOfContainers', @intNumberOfContainers, @intNumberOfContainers_Cur, 'No. of Containers', 1, 0, @intLoadAuditParentId, 1

	IF (@intShippingLineEntityId IS NOT NULL)
	BEGIN
		DECLARE @strShippingLine NVARCHAR(200)
		SELECT @strShippingLine = ISNULL((SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @intShippingLineEntityId), '')
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strShippingLine', @strShippingLine, @strShippingLine_Cur, 'Shipping Line', 1, 0, @intLoadAuditParentId, 1
	END

	IF (@intShippingModeId IS NOT NULL)
	BEGIN
		DECLARE @strShippingMode NVARCHAR(100)
		SELECT @strShippingMode = ISNULL((SELECT TOP 1 strShippingMode FROM tblLGShippingMode WHERE intShippingModeId = @intShippingModeId), '')
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strShippingMode', @strShippingMode, @strShippingMode_Cur, 'Shipping Mode', 1, 0, @intLoadAuditParentId, 1
	END

	IF (@intForwardingAgentEntityId IS NOT NULL)
	BEGIN
		DECLARE @strForwardingAgent NVARCHAR(200)
		SELECT @strForwardingAgent = ISNULL((SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @intForwardingAgentEntityId), '')
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strForwardingAgent', @strForwardingAgent, @strForwardingAgent_Cur, 'Forwarding Agent', 1, 0, @intLoadAuditParentId, 1
	END

	IF (@intContainerTypeId IS NOT NULL)
	BEGIN
		DECLARE @strContainerType NVARCHAR(100)
		SELECT @strContainerType = ISNULL((SELECT TOP 1 strContainerType FROM tblLGContainerType WHERE intContainerTypeId = @intContainerTypeId), '')
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'strContainerType', @strContainerType, @strContainerType_Cur, 'Container Type', 1, 0, @intLoadAuditParentId, 1
	END
	
	--Insert container information children
	IF (@intLoadContainerId IS NOT NULL)
	BEGIN
		SELECT
			@strMarks_Cur = strMarks
			,@strLotNumber_Cur = strLotNumber
			,@strSealNumber_Cur = strSealNumber
			,@strContainerComments_Cur = strComments
		FROM tblLGLoadContainer 
		WHERE intLoadContainerId = @intLoadContainerId

		INSERT INTO tblSMAudit (intLogId, strChange, strAlias, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, 'tblLGLoadContainers', 'Container Information', @intLoadAuditParentId, 1

		SET @intContainerAuditParentId = SCOPE_IDENTITY()

		INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadContainerId, 'Updated', 'Updated - Record: ' + strContainerNumber, @intContainerAuditParentId, 1 
		FROM tblLGLoadContainer WHERE intLoadContainerId = @intLoadContainerId

		SET @intContainerUpdatedAuditParentId = SCOPE_IDENTITY()

		IF (@strMarks IS NOT NULL)
			INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
			SELECT @intLogId, @intLoadContainerId, 'strMarks', @strMarks, @strMarks_Cur, 'Marks', 1, 0, @intContainerUpdatedAuditParentId, 1

		IF (@strLotNumber IS NOT NULL)
			INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
			SELECT @intLogId, @intLoadContainerId, 'strLotNumber', @strLotNumber, @strLotNumber_Cur, 'Lot No.', 1, 0, @intContainerUpdatedAuditParentId, 1

		IF (@strSealNumber IS NOT NULL)
			INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
			SELECT @intLogId, @intLoadContainerId, 'strSealNumber', @strSealNumber, @strSealNumber_Cur, 'Seal No.', 1, 0, @intContainerUpdatedAuditParentId, 1

		IF (@strContainerComments IS NOT NULL)
			INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
			SELECT @intLogId, @intLoadContainerId, 'strComments', @strContainerComments, @strContainerComments_Cur, 'Comments', 1, 0, @intContainerUpdatedAuditParentId, 1

	END
END

GO