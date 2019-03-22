/*
* Set invalid Shipment type to 1 (Shipment)
*/
IF EXISTS(SELECT 1 FROM tblLGLoad WHERE ISNULL(intShipmentType,0) = 0)
BEGIN
	UPDATE tblLGLoad SET intShipmentType = 1 WHERE ISNULL(intShipmentType,0) = 0
END
GO

/*
* Create record on tblLGCompanyPreference if empty
*/
IF NOT EXISTS(SELECT 1 FROM tblLGCompanyPreference)
BEGIN
	INSERT INTO tblLGCompanyPreference(intConcurrencyId)
	SELECT 1
END
GO

/*
* Set Document Received value 
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoad') AND name = 'ysnDocumentsReceived')
BEGIN
	EXEC ('UPDATE tblLGLoad
			SET ysnDocumentsReceived = CASE WHEN NOT EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId) THEN NULL
											WHEN EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId AND ISNULL(ysnReceived, 0) = 0) THEN 0 
										ELSE 1 END
			WHERE ysnDocumentsReceived IS NULL AND EXISTS(SELECT TOP 1 1 FROM tblLGLoadDocuments WHERE intLoadId = tblLGLoad.intLoadId)
	')
END
GO

/*
* Set Container Numbers value 
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoadDetail') AND name = 'strContainerNumbers')
BEGIN
	EXEC ('UPDATE LD
			SET strContainerNumbers = STUFF(
										(SELECT '', '' + CAST(strContainerNumber AS VARCHAR(MAX)) [text()]
										FROM tblLGLoadContainer LC 
										INNER JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
										WHERE LDCL.intLoadDetailId = LD.intLoadDetailId
										FOR XML PATH (''''), TYPE).value(''.'',''NVARCHAR(MAX)''),1,2,'' '')
			FROM tblLGLoadDetail LD
			WHERE strContainerNumbers IS NULL AND EXISTS(SELECT TOP 1 1 FROM tblLGLoadContainer LC 
													INNER JOIN tblLGLoadDetailContainerLink LDCL ON LC.intLoadContainerId = LDCL.intLoadContainerId
													 WHERE LDCL.intLoadDetailId = LD.intLoadDetailId)
	')
END

/* 
* Generate Load - Data Migration to New Fields 
*/

--Transport Mode
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intTransportationMode')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intTransportationMode = ISNULL((SELECT TOP 1 intTransportationMode FROM tblLGLoad WHERE intGenerateLoadId = tblLGGenerateLoad.intGenerateLoadId),
										   (SELECT TOP 1 intDefaultTransportationMode FROM tblLGCompanyPreference))
		WHERE intTransportationMode IS NULL
	')
END
GO

--Hauler
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intHaulerEntityId')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intHaulerEntityId = CASE WHEN (intType IN (1, 3)) THEN intPHaulerEntityId ELSE intSHaulerEntityId END
		WHERE intHaulerEntityId IS NULL
	')
END
GO

--Equipment Type
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intEquipmentTypeId')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET intEquipmentTypeId = CASE WHEN (intType IN (1, 3)) THEN intPHaulerEntityId ELSE intSHaulerEntityId END
		WHERE intEquipmentTypeId IS NULL
	')
END
GO

--Item Id
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'intItemId')
BEGIN
	EXEC('UPDATE GL
		SET intItemId = CASE WHEN (GL.intType IN (1, 3)) THEN VGL.intPItemId ELSE VGL.intSItemId END
		FROM tblLGGenerateLoad GL
		INNER JOIN vyuLGGenerateLoad VGL ON GL.intGenerateLoadId = VGL.intGenerateLoadId
		WHERE GL.intItemId IS NULL
	')
END
GO

--Ship Date
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'dtmShipDate')
BEGIN
	EXEC('UPDATE tblLGGenerateLoad
		SET dtmShipDate = CASE WHEN (intType IN (1, 3)) THEN dtmPArrivalDate ELSE dtmSShipToDate END
		WHERE intEquipmentTypeId IS NULL
	')
END
GO

--End Date
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'dtmEndDate')
BEGIN
	EXEC('UPDATE GL
		SET dtmEndDate = CASE WHEN (intType IN (1, 3)) THEN PCD.dtmEndDate ELSE SCD.dtmEndDate END
		FROM tblLGGenerateLoad GL
		LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = GL.intPContractDetailId
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = GL.intSContractDetailId
		WHERE GL.dtmEndDate IS NULL
	')
END
GO

