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