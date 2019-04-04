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

/*
* Set Load-Based value on Load Schedule table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoad') AND name = 'ysnLoadBased')
BEGIN
	EXEC ('UPDATE tblLGLoad
			SET ysnLoadBased = CASE WHEN EXISTS(SELECT TOP 1 1 FROM vyuLGLoadDetailView WHERE intLoadId = tblLGLoad.intLoadId AND (ysnPLoad = 1 OR ysnSLoad = 1)) THEN 1 ELSE 0 END
			WHERE ysnLoadBased IS NULL 
				OR ysnLoadBased <> CASE WHEN EXISTS(SELECT TOP 1 1 FROM vyuLGLoadDetailView WHERE intLoadId = tblLGLoad.intLoadId AND (ysnPLoad = 1 OR ysnSLoad = 1)) THEN 1 ELSE 0 END
	')
END
GO

/*
* Set Load-Based value on Generate Load table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGGenerateLoad') AND name = 'ysnLoadBased')
BEGIN
	EXEC ('UPDATE GL
			SET ysnLoadBased = CASE WHEN (ISNULL(PCH.ysnLoad, 0) = 1 OR ISNULL(SCH.ysnLoad, 0) = 1) THEN 1 ELSE 0 END
			FROM tblLGGenerateLoad GL
				LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = GL.intPContractDetailId
				LEFT JOIN tblCTContractHeader PCH ON PCD.intContractHeaderId = PCH.intContractHeaderId
				LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = GL.intSContractDetailId
				LEFT JOIN tblCTContractHeader SCH ON PCD.intContractHeaderId = SCH.intContractHeaderId
			WHERE 
				GL.ysnLoadBased IS NULL
				OR GL.ysnLoadBased <> CASE WHEN (ISNULL(PCH.ysnLoad, 0) = 1 OR ISNULL(SCH.ysnLoad, 0) = 1) THEN 1 ELSE 0 END
	')
END
GO

/*
* Apply default Sort value on Containers table
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoadContainer') AND name = 'intSort')
BEGIN
	EXEC ('UPDATE LC
				SET intSort = LC_Sorted.intSort
			FROM 
				tblLGLoadContainer LC
				INNER JOIN 
				(SELECT intLoadContainerId
					,intSort = DENSE_RANK() OVER(PARTITION BY intLoadId ORDER BY intLoadContainerId)
				FROM tblLGLoadContainer) LC_Sorted
					ON LC.intLoadContainerId = LC_Sorted.intLoadContainerId
			WHERE LC.intSort IS NULL
	')
END
GO

/*
* Attempt to link Load Costs to corresponding Contract Detail (one-time run)
*/
IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblLGLoadCost') AND name = 'intContractDetailId')
BEGIN
	--Inbound/Drop Ship costs
	EXEC ('
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblLGLoadCost WHERE intContractDetailId IS NOT NULL)

			UPDATE LGC
			SET intContractDetailId = CTC.intContractDetailId
			FROM
				tblLGLoadCost LGC
				INNER JOIN tblLGLoad LG ON LG.intLoadId = LGC.intLoadId
				LEFT JOIN tblLGLoadDetail LGD ON LGD.intLoadId = LG.intLoadId
				OUTER APPLY 
					(SELECT TOP 1 
						CTC.intContractCostId
						,CTC.intItemId
						,CTC.intVendorId
						,CTC.dblRate
						,CTC.strCostMethod
						,CTC.intItemUOMId
						,CTC.dblAccruedAmount
						,CTD.intContractDetailId
						,CTD.dblQuantity
						FROM tblCTContractCost CTC
						INNER JOIN tblCTContractDetail CTD
							ON CTC.intContractDetailId = CTD.intContractDetailId
						WHERE CTC.intItemId = LGC.intItemId
							AND CTC.intVendorId = LGC.intVendorId
							AND CTC.strCostMethod = LGC.strCostMethod
							AND CTC.intContractDetailId = LGD.intPContractDetailId
						) [CTC]
			WHERE LG.intPurchaseSale IN (1 , 3) AND LGC.intContractDetailId IS NULL')

		--Outbound/Drop Ship costs
		EXEC ('
			IF NOT EXISTS (SELECT TOP 1 1 FROM tblLGLoadCost WHERE intContractDetailId IS NOT NULL)

			UPDATE LGC
			SET intContractDetailId = CTC.intContractDetailId
			FROM
				tblLGLoadCost LGC
				INNER JOIN tblLGLoad LG ON LG.intLoadId = LGC.intLoadId
				LEFT JOIN tblLGLoadDetail LGD ON LGD.intLoadId = LG.intLoadId
				OUTER APPLY 
					(SELECT TOP 1 
						CTC.intContractCostId
						,CTC.intItemId
						,CTC.intVendorId
						,CTC.dblRate
						,CTC.strCostMethod
						,CTC.intItemUOMId
						,CTC.dblAccruedAmount
						,CTD.intContractDetailId
						,CTD.dblQuantity
						FROM tblCTContractCost CTC
						INNER JOIN tblCTContractDetail CTD
							ON CTC.intContractDetailId = CTD.intContractDetailId
						WHERE CTC.intItemId = LGC.intItemId
							AND CTC.intVendorId = LGC.intVendorId
							AND CTC.strCostMethod = LGC.strCostMethod
							AND CTC.intContractDetailId = LGD.intSContractDetailId
						) [CTC]
			WHERE LG.intPurchaseSale IN (2, 3) AND LGC.intContractDetailId IS NULL
		')
END
GO


