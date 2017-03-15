CREATE PROCEDURE [dbo].[uspLGCreateLoadIntegrationLSPLog]
	 @intLoadId INT
	,@strRowState NVARCHAR(100)
	,@intShipmentType INT = 1
AS
BEGIN TRY
	DECLARE @intLoadStgId INT
	DECLARE @intLoadLogId INT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intLoadDetailWarehouseId INT
	DECLARE @strWarehouseVendorNo NVARCHAR(100)
	DECLARE @strWarehouseVendorName NVARCHAR(100)
	DECLARE @strWarehouseVendorAddress NVARCHAR(100)
	DECLARE @strWarehouseVendorPostalCode NVARCHAR(100)
	DECLARE @strWarehouseVendorCity NVARCHAR(100)
	DECLARE @strWarehouseVendorCountry NVARCHAR(100)
	DECLARE @strWarehouseVendorAccNo NVARCHAR(100)

	SELECT TOP 1 @strWarehouseVendorNo = WE.strEntityNo
			  ,  @strWarehouseVendorName = WE.strName
			  ,  @strWarehouseVendorAddress = EL.strAddress
			  ,  @strWarehouseVendorPostalCode = EL.strZipCode
			  ,  @strWarehouseVendorCity = EL.strCity
			  ,  @strWarehouseVendorCountry = (SELECT TOP 1 SM.strISOCode
												FROM tblSMCountry SM
												WHERE SM.strCountry = EL.strCountry)
			  ,  @strWarehouseVendorAccNo = A.strVendorAccountNum
	FROM tblLGLoadDetail LD
	JOIN tblCTContractDetail CD ON LD.intPContractDetailId = CD.intContractDetailId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
	LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
	LEFT JOIN tblAPVendor A ON A.intEntityVendorId = WE.intEntityId
	WHERE LD.intLoadId = @intLoadId

	IF EXISTS (
			SELECT 1
			FROM tblLGLoadLSPStg
			WHERE ISNULL(strFeedStatus, '') = ''
				AND intLoadId = @intLoadId
				AND strRowState = 'Added'
			)
	BEGIN
		DELETE
		FROM tblLGLoadLSPStg
		WHERE intLoadId = @intLoadId
			AND strRowState = 'Added'

		SET @strRowState = 'Added'
	END

	INSERT INTO tblLGLoadLSPStg (
		intLoadId
		,strTransactionType
		,strLoadNumber
		,strCompanyLocation
		,strSubLocation
		,strLanguage
		,strWarehouseVendorNo
		,strWarehouseVendorName
		,strWarehouseVendorAddress
		,strWarehouseVendorPostalCode
		,strWarehouseVendorCity
		,strWarehouseVendorCountry
		,strWarehouseVendorAccNo
		,strVendorName
		,strVendorAddress
		,strVendorPostalCode
		,strVendorCity
		,strVendorTelePhoneNo
		,strVendorTeleFaxNo
		,strVendorCountry
		,strVendorAccNo
		,strOriginName
		,strOriginAddress
		,strOriginPostalCode
		,strOriginCity
		,strOriginTelePhoneNo
		,strOriginTeleFaxNo
		,strOriginCountry
		,strOriginRegion
		,strDestinationName
		,strDestinationAddress
		,strDestinationPostalCode
		,strDestinationCity
		,strDestinationTelePhoneNo
		,strDestinationTeleFaxNo
		,strDestinationCountry
		,strDestinationRegion
		,strForwardingAgent
		,strForwardingAgentAddress
		,strForwardingAgentPostalCode
		,strForwardingAgentCity
		,strForwardingAgentTelePhoneNo
		,strForwardingAgentTeleFaxNo
		,strForwardingAgentCountry
		,strForwardingAgentAccNo
		,strContractBasis
		,strContractBasisDesc
		,strBillOfLading
		,strShippingLine
		,strShippingLineAddress
		,strShippingLinePostalCode
		,strShippingLineCity
		,strShippingLineTelePhoneNo
		,strShippingLineTeleFaxNo
		,strShippingLineCountry
		,strShippingLineAccountNo
		,strExternalShipmentNumber
		,strDateQualifier
		,dtmScheduledDate
		,dtmETAPOD
		,dtmETAPOL
		,dtmETSPOL
		,dtmBLDate
		,strRowState
		,dtmFeedCreated
		,dblTotalGross
		,dblTotalNet
		,strWeightUOM
		,strMVessel
		,strMVoyageNumber
		,strFVessel
		,strFVoyageNumber
		)
	SELECT L.intLoadId
		,strShipmentType = CASE L.intShipmentType
			WHEN 1
				THEN 'Shipment'
			WHEN 2
				THEN 'Shipping Instructions'
			WHEN 3
				THEN 'Vessel Nomination'
			ELSE ''
			END COLLATE Latin1_General_CI_AS
		,L.strLoadNumber
		,(
			SELECT TOP 1 CL.strLocationName
			FROM tblLGLoadDetail LD
			JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
			WHERE LD.intLoadId = L.intLoadId
			) strCompanyLocationName
		,(
			SELECT TOP 1 CLSL.strSubLocationName
			FROM tblLGLoadDetail LD
			JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
			WHERE LD.intLoadId = L.intLoadId
			) strSubLocationName
		,'EN' strLanguage
		,strWarehouseVendorNo = CASE WHEN ISNULL(WE.strEntityNo,'') = '' THEN @strWarehouseVendorNo ELSE WE.strEntityNo END
		,strWarehouseVendorName = CASE WHEN ISNULL(WE.strName,'') = '' THEN @strWarehouseVendorName ELSE WE.strName END
		,strWarehouseVendorAddress = CASE WHEN ISNULL(EL.strAddress,'') = '' THEN @strWarehouseVendorAddress ELSE EL.strAddress END
		,strWarehouseVendorPostalCode = CASE WHEN ISNULL( EL.strZipCode,'') = '' THEN @strWarehouseVendorPostalCode ELSE  EL.strZipCode END
		,strWarehouseVendorCity = CASE WHEN ISNULL( EL.strCity,'') = '' THEN @strWarehouseVendorCity ELSE  EL.strCity END
		,strWarehouseVendorCountry = CASE WHEN ISNULL((SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry),'') = '' THEN @strWarehouseVendorCountry ELSE  (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry) END
		,strWarehouseVendorAccNo = CASE WHEN ISNULL( A.strVendorAccountNum,'') = '' THEN @strWarehouseVendorAccNo ELSE  A.strVendorAccountNum END
		,(
			SELECT TOP 1 E.strEntityName
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorName
		,(
			SELECT TOP 1 E.strEntityAddress
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorAddress
		,(
			SELECT TOP 1 E.strEntityZipCode
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorPostalCode
		,(
			SELECT TOP 1 E.strEntityCity
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorCity
		,(
			SELECT TOP 1 E.strEntityPhone
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorTelePhoneNo
		,(
			SELECT TOP 1 E.strFax
			FROM tblLGLoadDetail LD
			JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorTeleFaxNo
		,(
			SELECT TOP 1 SM.strISOCode
			FROM tblLGLoadDetail LD
			JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
			JOIN tblSMCountry SM ON SM.strCountry = E.strEntityCountry
			WHERE LD.intLoadId = L.intLoadId
			) strVendorCountry
		,(
			SELECT TOP 1 A.strVendorAccountNum
			FROM tblLGLoadDetail LD
			JOIN tblAPVendor A ON A.intEntityVendorId = LD.intVendorEntityId
			WHERE LD.intLoadId = L.intLoadId
			) strVendorAccountNo
		,L.strOriginPort
		,'' strOriginAddress
		,'' strOriginPostalCode
		,'' strOriginCity
		,'' strOriginTelePhoneNo
		,'' strOriginTeleFaxNo
		,OCountry.strISOCode strOriginCountry
		,'' strOriginRegion
		,L.strDestinationPort
		,'' strDestinationAddress
		,'' strDestinationPostalCode
		,'' strDestinationCity
		,'' strDestinationTelePhoneNo
		,'' strDestinationTeleFaxNo
		,DCountry.strISOCode strDestinationCountry
		,'' strDestinationRegion
		,L.strForwardingAgent
		,FAEL.strAddress
		,FAEL.strZipCode
		,FAEL.strCity
		,FAEL.strPhone
		,FAEL.strFax
		,FACountry.strISOCode
		,FAV.strVendorAccountNum
		,strContractBasis = (
			SELECT TOP 1 CB.strContractBasis
			FROM tblCTContractHeader CH
			JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
			JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
			JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
			WHERE LD.intLoadId = L.intLoadId
			)
		,strContractBasisDesc = (
			SELECT TOP 1 CB.strDescription
			FROM tblCTContractHeader CH
			JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
			JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
			JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
			WHERE LD.intLoadId = L.intLoadId
			)
		,L.strBLNumber
		,L.strShippingLine
		,SLEL.strAddress
		,SLEL.strZipCode
		,SLEL.strCity
		,SLEL.strPhone
		,SLEL.strFax
		,SLCountry.strISOCode
		,V.strVendorAccountNum strShippingLineAccountNo
		,L.strExternalShipmentNumber
		,'015' AS strDateQualifier
		,L.dtmScheduledDate
		,L.dtmETAPOD
		,L.dtmETAPOL
		,L.dtmETSPOL
		,L.dtmBLDate
		,'Added'
		,GETDATE()
		,(
			SELECT SUM(dblGross)
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId
			) dblTotalGross
		,(
			SELECT SUM(dblNet)
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId
			) dblTotalNet
		,(
			SELECT TOP 1 UM.strUnitMeasure
			FROM tblLGLoadDetail LD
			JOIN tblICItemUOM IUM ON IUM.intItemUOMId = LD.intWeightItemUOMId
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
			WHERE LD.intLoadId = L.intLoadId
			) strWeightUnitMeasure
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
	FROM vyuLGLoadView L
	LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = E.intEntityId
	LEFT JOIN tblSMCountry SLCountry ON SLCountry.strCountry = SLEL.strCountry
	LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
	LEFT JOIN tblAPVendor A ON A.intEntityVendorId = WE.intEntityId
	LEFT JOIN tblSMCity OCity ON OCity.strCity = L.strOriginPort
	LEFT JOIN tblSMCountry OCountry ON OCountry.intCountryID = OCity.intCountryId
	LEFT JOIN tblSMCity DCity ON DCity.strCity = L.strDestinationPort
	LEFT JOIN tblSMCountry DCountry ON DCountry .intCountryID = DCity.intCountryId
	LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
	LEFT JOIN tblEMEntityLocation FAEL ON FAEL.intEntityId = FA.intEntityId
	LEFT JOIN tblSMCountry FACountry ON FACountry.strCountry = FAEL.strCountry
	LEFT JOIN tblAPVendor FAV ON FAV.intEntityVendorId = FA.intEntityId
	WHERE L.intLoadId = @intLoadId



	IF(@strRowState = 'Delete')
	BEGIN
		IF EXISTS(SELECT 1 FROM tblLGLoadLSPStg WHERE intLoadId = @intLoadId)
		BEGIN
			INSERT INTO tblLGLoadLSPStg (
				intLoadId
				,strTransactionType
				,strLoadNumber
				,strCompanyLocation
				,strSubLocation
				,strLanguage
				,strWarehouseVendorNo
				,strWarehouseVendorName
				,strWarehouseVendorAddress
				,strWarehouseVendorPostalCode
				,strWarehouseVendorCity
				,strWarehouseVendorCountry
				,strWarehouseVendorAccNo
				,strVendorName
				,strVendorAddress
				,strVendorPostalCode
				,strVendorCity
				,strVendorTelePhoneNo
				,strVendorTeleFaxNo
				,strVendorCountry
				,strVendorAccNo
				,strOriginName
				,strOriginAddress
				,strOriginPostalCode
				,strOriginCity
				,strOriginTelePhoneNo
				,strOriginTeleFaxNo
				,strOriginCountry
				,strOriginRegion
				,strDestinationName
				,strDestinationAddress
				,strDestinationPostalCode
				,strDestinationCity
				,strDestinationTelePhoneNo
				,strDestinationTeleFaxNo
				,strDestinationCountry
				,strDestinationRegion
				,strForwardingAgent
				,strForwardingAgentAddress
				,strForwardingAgentPostalCode
				,strForwardingAgentCity
				,strForwardingAgentTelePhoneNo
				,strForwardingAgentTeleFaxNo
				,strForwardingAgentCountry
				,strForwardingAgentAccNo
				,strContractBasis
				,strContractBasisDesc
				,strBillOfLading
				,strShippingLine
				,strShippingLineAddress
				,strShippingLinePostalCode
				,strShippingLineCity
				,strShippingLineTelePhoneNo
				,strShippingLineTeleFaxNo
				,strShippingLineCountry
				,strShippingLineAccountNo
				,strExternalShipmentNumber
				,strDateQualifier
				,dtmScheduledDate
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmBLDate
				,strRowState
				,dtmFeedCreated
				,dblTotalGross
				,dblTotalNet
				,strWeightUOM
				,strMVessel
				,strMVoyageNumber
				,strFVessel
				,strFVoyageNumber
				)
			SELECT TOP 1 L.intLoadId
				,strShipmentType = CASE L.intShipmentType
					WHEN 1
						THEN 'Shipment'
					WHEN 2
						THEN 'Shipping Instructions'
					WHEN 3
						THEN 'Vessel Nomination'
					ELSE ''
					END COLLATE Latin1_General_CI_AS
				,L.strLoadNumber
				,(
					SELECT TOP 1 CL.strLocationName
					FROM tblLGLoadDetail LD
					JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
					WHERE LD.intLoadId = L.intLoadId
					) strCompanyLocationName
				,(
					SELECT TOP 1 CLSL.strSubLocationName
					FROM tblLGLoadDetail LD
					JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
					WHERE LD.intLoadId = L.intLoadId
					) strSubLocationName
				,'EN' strLanguage
				,strWarehouseVendorNo = CASE WHEN ISNULL(WE.strEntityNo,'') = '' THEN @strWarehouseVendorNo ELSE WE.strEntityNo END
				,strWarehouseVendorName = CASE WHEN ISNULL(WE.strName,'') = '' THEN @strWarehouseVendorName ELSE WE.strName END
				,strWarehouseVendorAddress = CASE WHEN ISNULL(EL.strAddress,'') = '' THEN @strWarehouseVendorAddress ELSE EL.strAddress END
				,strWarehouseVendorPostalCode = CASE WHEN ISNULL( EL.strZipCode,'') = '' THEN @strWarehouseVendorPostalCode ELSE  EL.strZipCode END
				,strWarehouseVendorCity = CASE WHEN ISNULL( EL.strCity,'') = '' THEN @strWarehouseVendorCity ELSE  EL.strCity END
				,strWarehouseVendorCountry = CASE WHEN ISNULL((SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry),'') = '' THEN @strWarehouseVendorCountry ELSE  (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry) END
				,strWarehouseVendorAccNo = CASE WHEN ISNULL( A.strVendorAccountNum,'') = '' THEN @strWarehouseVendorAccNo ELSE  A.strVendorAccountNum END
				,(
					SELECT TOP 1 E.strEntityName
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorName
				,(
					SELECT TOP 1 E.strEntityAddress
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorAddress
				,(
					SELECT TOP 1 E.strEntityZipCode
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorPostalCode
				,(
					SELECT TOP 1 E.strEntityCity
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorCity
				,(
					SELECT TOP 1 E.strEntityPhone
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorTelePhoneNo
				,(
					SELECT TOP 1 E.strFax
					FROM tblLGLoadDetail LD
					JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorTeleFaxNo
				,(
					SELECT TOP 1 SM.strISOCode
					FROM tblLGLoadDetail LD
					JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
					JOIN tblSMCountry SM ON SM.strCountry = E.strEntityCountry
					WHERE LD.intLoadId = L.intLoadId
					) strVendorCountry
				,(
					SELECT TOP 1 A.strVendorAccountNum
					FROM tblLGLoadDetail LD
					JOIN tblAPVendor A ON A.intEntityVendorId = LD.intVendorEntityId
					WHERE LD.intLoadId = L.intLoadId
					) strVendorAccountNo
				,L.strOriginPort
				,'' strOriginAddress
				,'' strOriginPostalCode
				,'' strOriginCity
				,'' strOriginTelePhoneNo
				,'' strOriginTeleFaxNo
				,OCountry.strISOCode strOriginCountry
				,'' strOriginRegion
				,L.strDestinationPort
				,'' strDestinationAddress
				,'' strDestinationPostalCode
				,'' strDestinationCity
				,'' strDestinationTelePhoneNo
				,'' strDestinationTeleFaxNo
				,DCountry.strISOCode strDestinationCountry
				,'' strDestinationRegion
				,L.strForwardingAgent
				,FAEL.strAddress
				,FAEL.strZipCode
				,FAEL.strCity
				,FAEL.strPhone
				,FAEL.strFax
				,FACountry.strISOCode
				,FAV.strVendorAccountNum
				,strContractBasis = (
					SELECT TOP 1 CB.strContractBasis
					FROM tblCTContractHeader CH
					JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
					WHERE LD.intLoadId = L.intLoadId
					)
				,strContractBasisDesc = (
					SELECT TOP 1 CB.strDescription
					FROM tblCTContractHeader CH
					JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
					JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
					JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
					WHERE LD.intLoadId = L.intLoadId
					)
				,L.strBLNumber
				,L.strShippingLine
				,SLEL.strAddress
				,SLEL.strZipCode
				,SLEL.strCity
				,SLEL.strPhone
				,SLEL.strFax
				,SLCountry.strISOCode
				,V.strVendorAccountNum strShippingLineAccountNo
				,L.strExternalShipmentNumber
				,'015' AS strDateQualifier
				,L.dtmScheduledDate
				,L.dtmETAPOD
				,L.dtmETAPOL
				,L.dtmETSPOL
				,L.dtmBLDate
				,'Delete'
				,GETDATE()
				,(
					SELECT SUM(dblGross)
					FROM tblLGLoadDetail LD
					WHERE LD.intLoadId = L.intLoadId
					) dblTotalGross
				,(
					SELECT SUM(dblNet)
					FROM tblLGLoadDetail LD
					WHERE LD.intLoadId = L.intLoadId
					) dblTotalNet
				,(
					SELECT TOP 1 UM.strUnitMeasure
					FROM tblLGLoadDetail LD
					JOIN tblICItemUOM IUM ON IUM.intItemUOMId = LD.intWeightItemUOMId
					JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
					WHERE LD.intLoadId = L.intLoadId
					) strWeightUnitMeasure
				,L.strMVessel
				,L.strMVoyageNumber
				,L.strFVessel
				,L.strFVoyageNumber
			FROM vyuLGLoadView L
			LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = E.intEntityId
			LEFT JOIN tblSMCountry SLCountry ON SLCountry.strCountry = SLEL.strCountry
			LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
			LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
			LEFT JOIN tblAPVendor A ON A.intEntityVendorId = WE.intEntityId
			LEFT JOIN tblSMCity OCity ON OCity.strCity = L.strOriginPort
			LEFT JOIN tblSMCountry OCountry ON OCountry.intCountryID = OCity.intCountryId
			LEFT JOIN tblSMCity DCity ON DCity.strCity = L.strDestinationPort
			LEFT JOIN tblSMCountry DCountry ON DCountry .intCountryID = DCity.intCountryId
			LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
			LEFT JOIN tblEMEntityLocation FAEL ON FAEL.intEntityId = FA.intEntityId
			LEFT JOIN tblSMCountry FACountry ON FACountry.strCountry = FAEL.strCountry
			LEFT JOIN tblAPVendor FAV ON FAV.intEntityVendorId = FA.intEntityId
			WHERE L.intLoadId = @intLoadId

			SELECT @intLoadStgId = SCOPE_IDENTITY()

			INSERT INTO tblLGLoadDetailLSPStg (
				intLoadStgId
				,intLoadId
				,intSIDetailId
				,intLoadDetailId
				,intRowNumber
				,strItemNo
				,strItemDesc
				,strItemShortDesc
				,strSubLocationName
				,strStorageLocationName
				,strBatchNumber
				,dblDeliveredQty
				,strUnitOfMeasure
				,dblNetWt
				,dblGrossWt
				,strWeightUOM
				,intHigherPositionRef
				,strDocumentCategory
				,strReferenceDataInfo
				,strSeq
				,strLoadNumber
				,strExternalPONumber
				,strExternalPOItemNumber
				,strExternalPOBatchNumber
				,strExternalShipmentItemNumber
				,strExternalBatchNo
				,strChangeType
				,strRowState
				,dtmFeedCreated
				,strCommodityCode
				)
			SELECT @intLoadStgId
				,@intLoadId
				,CASE 
					WHEN ISNULL(LSID.intLoadDetailId, 0) = 0
						THEN LD.intLoadDetailId
					ELSE LSID.intLoadDetailId
					END AS intSIDetailId
				,LD.intLoadDetailId
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					) AS intRowNumber
				,LD.strItemNo
				,I.strDescription
				,I.strShortName
				,strSubLocationName = (
					SELECT CLSL.strSubLocationName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,strStorageLocationName = (
					SELECT SL.strName AS strStorageLocationName
					FROM tblCTContractDetail CD
					JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
					WHERE CD.intContractDetailId = CASE 
							WHEN LD.intPurchaseSale = 1
								THEN LD.intPContractDetailId
							ELSE LD.intSContractDetailId
							END
					)
				,LD.strLoadNumber
				,LD.dblQuantity
				,LD.strItemUOM
				,LD.dblGross
				,LD.dblNet
				,LD.strWeightItemUOM
				,Row_NUMBER() OVER (
					PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
					)
				,'C' AS strDocumentCategory
				,'001' AS strRefDataInfo
				,0 AS strSeq
				,LD.strLoadNumber
				,CD.strERPPONumber
				,CD.strERPItemNumber
				,CD.strERPBatchNumber
				,D.strExternalShipmentItemNumber
				,D.strExternalBatchNo
				,'QUA' AS strChangeType
				,@strRowState AS strRowState
				,GETDATE()
				,C.strCommodityCode
			FROM vyuLGLoadDetailView LD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPContractDetailId
					ELSE LD.intSContractDetailId
					END
			JOIN tblLGLoadDetail D ON D.intLoadDetailId = LD.intLoadDetailId
			JOIN tblICItem I ON I.intItemId = D.intItemId
			JOIN tblICCommodity C ON C.intCommodityId = CASE 
					WHEN LD.intPurchaseSale = 1
						THEN LD.intPCommodityId
					ELSE LD.intSCommodityId
					END
			LEFT JOIN tblLGLoad L ON L.intLoadId = D.intLoadId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId
				AND D.intPContractDetailId = LSID.intPContractDetailId
			WHERE LD.intLoadId = @intLoadId

			INSERT INTO tblLGLoadContainerLSPStg
			SELECT @intLoadStgId
				,@intLoadId
				,LC.intLoadContainerId
				,LC.strContainerNumber
				,CASE 
					WHEN CT.strContainerType LIKE '%20%'
						THEN '000000000010003243'
					WHEN CT.strContainerType LIKE '%40%'
						THEN '000000000010003244'
					ELSE CT.strContainerType
					END
				,'0002'
				,L.strExternalShipmentNumber
				,ROW_NUMBER() OVER (
					PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
					) AS Seq
				,LC.dblQuantity
				,LC.strItemUOM
				,LC.dblNetWt
				,LC.dblGrossWt
				,LC.strWeightUnitMeasure
				,LC.strExternalContainerId
				,@strRowState
				,GETDATE()
			FROM vyuLGLoadContainerView LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
			ORDER BY LC.intLoadContainerId
		END
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblLGLoadLSPStg
				WHERE ISNULL(strFeedStatus, '') = ''
					AND intLoadId = @intLoadId
					AND strRowState = 'Added'
				)
		BEGIN
			DELETE
			FROM tblLGLoadLSPStg
			WHERE intLoadId = @intLoadId
				AND strRowState = 'Added'

			SET @strRowState = 'Added'
		END


		INSERT INTO tblLGLoadLSPStg (
			intLoadId
			,strTransactionType
			,strLoadNumber
			,strCompanyLocation
			,strSubLocation
			,strLanguage
			,strWarehouseVendorNo
			,strWarehouseVendorName
			,strWarehouseVendorAddress
			,strWarehouseVendorPostalCode
			,strWarehouseVendorCity
			,strWarehouseVendorCountry
			,strWarehouseVendorAccNo
			,strVendorName
			,strVendorAddress
			,strVendorPostalCode
			,strVendorCity
			,strVendorTelePhoneNo
			,strVendorTeleFaxNo
			,strVendorCountry
			,strVendorAccNo
			,strOriginName
			,strOriginAddress
			,strOriginPostalCode
			,strOriginCity
			,strOriginTelePhoneNo
			,strOriginTeleFaxNo
			,strOriginCountry
			,strOriginRegion
			,strDestinationName
			,strDestinationAddress
			,strDestinationPostalCode
			,strDestinationCity
			,strDestinationTelePhoneNo
			,strDestinationTeleFaxNo
			,strDestinationCountry
			,strDestinationRegion
			,strForwardingAgent
			,strForwardingAgentAddress
			,strForwardingAgentPostalCode
			,strForwardingAgentCity
			,strForwardingAgentTelePhoneNo
			,strForwardingAgentTeleFaxNo
			,strForwardingAgentCountry
			,strForwardingAgentAccNo
			,strContractBasis
			,strContractBasisDesc
			,strBillOfLading
			,strShippingLine
			,strShippingLineAddress
			,strShippingLinePostalCode
			,strShippingLineCity
			,strShippingLineTelePhoneNo
			,strShippingLineTeleFaxNo
			,strShippingLineCountry
			,strShippingLineAccountNo
			,strExternalShipmentNumber
			,strDateQualifier
			,dtmScheduledDate
			,dtmETAPOD
			,dtmETAPOL
			,dtmETSPOL
			,dtmBLDate
			,strRowState
			,dtmFeedCreated
			,dblTotalGross
			,dblTotalNet
			,strWeightUOM
			,strMVessel
			,strMVoyageNumber
			,strFVessel
			,strFVoyageNumber
			)
		SELECT TOP 1 L.intLoadId
			,strShipmentType = CASE L.intShipmentType
				WHEN 1
					THEN 'Shipment'
				WHEN 2
					THEN 'Shipping Instructions'
				WHEN 3
					THEN 'Vessel Nomination'
				ELSE ''
				END COLLATE Latin1_General_CI_AS
			,L.strLoadNumber
			,(
				SELECT TOP 1 CL.strLocationName
				FROM tblLGLoadDetail LD
				JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
				WHERE LD.intLoadId = L.intLoadId
				) strCompanyLocationName
			,(
				SELECT TOP 1 CLSL.strSubLocationName
				FROM tblLGLoadDetail LD
				JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
				WHERE LD.intLoadId = L.intLoadId
				) strSubLocationName
			,'EN' strLanguage
			,strWarehouseVendorNo = CASE WHEN ISNULL(WE.strEntityNo,'') = '' THEN @strWarehouseVendorNo ELSE WE.strEntityNo END
			,strWarehouseVendorName = CASE WHEN ISNULL(WE.strName,'') = '' THEN @strWarehouseVendorName ELSE WE.strName END
			,strWarehouseVendorAddress = CASE WHEN ISNULL(EL.strAddress,'') = '' THEN @strWarehouseVendorAddress ELSE EL.strAddress END
			,strWarehouseVendorPostalCode = CASE WHEN ISNULL( EL.strZipCode,'') = '' THEN @strWarehouseVendorPostalCode ELSE  EL.strZipCode END
			,strWarehouseVendorCity = CASE WHEN ISNULL( EL.strCity,'') = '' THEN @strWarehouseVendorCity ELSE  EL.strCity END
			,strWarehouseVendorCountry = CASE WHEN ISNULL((SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry),'') = '' THEN @strWarehouseVendorCountry ELSE  (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry) END
			,strWarehouseVendorAccNo = CASE WHEN ISNULL( A.strVendorAccountNum,'') = '' THEN @strWarehouseVendorAccNo ELSE  A.strVendorAccountNum END
			,(
				SELECT TOP 1 E.strEntityName
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorName
			,(
				SELECT TOP 1 E.strEntityAddress
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorAddress
			,(
				SELECT TOP 1 E.strEntityZipCode
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorPostalCode
			,(
				SELECT TOP 1 E.strEntityCity
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorCity
			,(
				SELECT TOP 1 E.strEntityPhone
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorTelePhoneNo
			,(
				SELECT TOP 1 E.strFax
				FROM tblLGLoadDetail LD
				JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorTeleFaxNo
			,(
				SELECT TOP 1 SM.strISOCode
				FROM tblLGLoadDetail LD
				JOIN vyuCTEntity E ON E.intEntityId = LD.intVendorEntityId
				JOIN tblSMCountry SM ON SM.strCountry = E.strEntityCountry
				WHERE LD.intLoadId = L.intLoadId
				) strVendorCountry
			,(
				SELECT TOP 1 A.strVendorAccountNum
				FROM tblLGLoadDetail LD
				JOIN tblAPVendor A ON A.intEntityVendorId = LD.intVendorEntityId
				WHERE LD.intLoadId = L.intLoadId
				) strVendorAccountNo
			,L.strOriginPort
			,'' strOriginAddress
			,'' strOriginPostalCode
			,'' strOriginCity
			,'' strOriginTelePhoneNo
			,'' strOriginTeleFaxNo
			,OCountry.strISOCode strOriginCountry
			,'' strOriginRegion
			,L.strDestinationPort
			,'' strDestinationAddress
			,'' strDestinationPostalCode
			,'' strDestinationCity
			,'' strDestinationTelePhoneNo
			,'' strDestinationTeleFaxNo
			,DCountry.strISOCode strDestinationCountry
			,'' strDestinationRegion
			,L.strForwardingAgent
			,FAEL.strAddress
			,FAEL.strZipCode
			,FAEL.strCity
			,FAEL.strPhone
			,FAEL.strFax
			,FACountry.strISOCode
			,FAV.strVendorAccountNum
			,strContractBasis = (
				SELECT TOP 1 CB.strContractBasis
				FROM tblCTContractHeader CH
				JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
				JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
				JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
				WHERE LD.intLoadId = L.intLoadId
				)
			,strContractBasisDesc = (
				SELECT TOP 1 CB.strDescription
				FROM tblCTContractHeader CH
				JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
				JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
				JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
				WHERE LD.intLoadId = L.intLoadId
				)
			,L.strBLNumber
			,L.strShippingLine
			,SLEL.strAddress
			,SLEL.strZipCode
			,SLEL.strCity
			,SLEL.strPhone
			,SLEL.strFax
			,SLCountry.strISOCode
			,V.strVendorAccountNum strShippingLineAccountNo
			,L.strExternalShipmentNumber
			,'015' AS strDateQualifier
			,L.dtmScheduledDate
			,L.dtmETAPOD
			,L.dtmETAPOL
			,L.dtmETSPOL
			,L.dtmBLDate
			,'Added'
			,GETDATE()
			,(
				SELECT SUM(dblGross)
				FROM tblLGLoadDetail LD
				WHERE LD.intLoadId = L.intLoadId
				) dblTotalGross
			,(
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail LD
				WHERE LD.intLoadId = L.intLoadId
				) dblTotalNet
			,(
				SELECT TOP 1 UM.strUnitMeasure
				FROM tblLGLoadDetail LD
				JOIN tblICItemUOM IUM ON IUM.intItemUOMId = LD.intWeightItemUOMId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
				WHERE LD.intLoadId = L.intLoadId
				) strWeightUnitMeasure
			,L.strMVessel
			,L.strMVoyageNumber
			,L.strFVessel
			,L.strFVoyageNumber
		FROM vyuLGLoadView L
		LEFT JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = E.intEntityId
		LEFT JOIN tblSMCountry SLCountry ON SLCountry.strCountry = SLEL.strCountry
		LEFT JOIN tblAPVendor V ON V.intEntityVendorId = E.intEntityId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
		LEFT JOIN tblAPVendor A ON A.intEntityVendorId = WE.intEntityId
		LEFT JOIN tblSMCity OCity ON OCity.strCity = L.strOriginPort
		LEFT JOIN tblSMCountry OCountry ON OCountry.intCountryID = OCity.intCountryId
		LEFT JOIN tblSMCity DCity ON DCity.strCity = L.strDestinationPort
		LEFT JOIN tblSMCountry DCountry ON DCountry .intCountryID = DCity.intCountryId
		LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
		LEFT JOIN tblEMEntityLocation FAEL ON FAEL.intEntityId = FA.intEntityId
		LEFT JOIN tblSMCountry FACountry ON FACountry.strCountry = FAEL.strCountry
		LEFT JOIN tblAPVendor FAV ON FAV.intEntityVendorId = FA.intEntityId
		WHERE L.intLoadId = @intLoadId

		SELECT @intLoadStgId = SCOPE_IDENTITY()

		INSERT INTO tblLGLoadDetailLSPStg (
			intLoadStgId
			,intLoadId
			,intSIDetailId
			,intLoadDetailId
			,intRowNumber
			,strItemNo
			,strItemDesc
			,strItemShortDesc
			,strSubLocationName
			,strStorageLocationName
			,strBatchNumber
			,dblDeliveredQty
			,strUnitOfMeasure
			,dblNetWt
			,dblGrossWt
			,strWeightUOM
			,intHigherPositionRef
			,strDocumentCategory
			,strReferenceDataInfo
			,strSeq
			,strLoadNumber
			,strExternalPONumber
			,strExternalPOItemNumber
			,strExternalPOBatchNumber
			,strExternalShipmentItemNumber
			,strExternalBatchNo
			,strChangeType
			,strRowState
			,dtmFeedCreated
			,strCommodityCode
			)
		SELECT @intLoadStgId
			,@intLoadId
			,CASE 
				WHEN ISNULL(LSID.intLoadDetailId, 0) = 0
					THEN LD.intLoadDetailId
				ELSE LSID.intLoadDetailId
				END AS intSIDetailId
			,LD.intLoadDetailId
			,Row_NUMBER() OVER (
				PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
				) AS intRowNumber
			,LD.strItemNo
			,I.strDescription
			,I.strShortName
			,strSubLocationName = (
				SELECT CLSL.strSubLocationName AS strStorageLocationName
				FROM tblCTContractDetail CD
				JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
				WHERE CD.intContractDetailId = CASE 
						WHEN LD.intPurchaseSale = 1
							THEN LD.intPContractDetailId
						ELSE LD.intSContractDetailId
						END
				)
			,strStorageLocationName = (
				SELECT SL.strName AS strStorageLocationName
				FROM tblCTContractDetail CD
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
				WHERE CD.intContractDetailId = CASE 
						WHEN LD.intPurchaseSale = 1
							THEN LD.intPContractDetailId
						ELSE LD.intSContractDetailId
						END
				)
			,LD.strLoadNumber
			,LD.dblQuantity
			,LD.strItemUOM
			,LD.dblGross
			,LD.dblNet
			,LD.strWeightItemUOM
			,Row_NUMBER() OVER (
				PARTITION BY LD.intLoadId ORDER BY LD.intLoadId
				)
			,'C' AS strDocumentCategory
			,'001' AS strRefDataInfo
			,0 AS strSeq
			,LD.strLoadNumber
			,CD.strERPPONumber
			,CD.strERPItemNumber
			,CD.strERPBatchNumber
			,D.strExternalShipmentItemNumber
			,D.strExternalBatchNo
			,'QUA' AS strChangeType
			,@strRowState AS strRowState
			,GETDATE()
			,C.strCommodityCode
		FROM vyuLGLoadDetailView LD
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN LD.intPurchaseSale = 1
					THEN LD.intPContractDetailId
				ELSE LD.intSContractDetailId
				END
		JOIN tblLGLoadDetail D ON D.intLoadDetailId = LD.intLoadDetailId
		JOIN tblICItem I ON I.intItemId = D.intItemId
		JOIN tblICCommodity C ON C.intCommodityId = CASE 
				WHEN LD.intPurchaseSale = 1
					THEN LD.intPCommodityId
				ELSE LD.intSCommodityId
				END
		LEFT JOIN tblLGLoad L ON L.intLoadId = D.intLoadId
		LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
		LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId
			AND D.intPContractDetailId = LSID.intPContractDetailId
		WHERE LD.intLoadId = @intLoadId

	INSERT INTO tblLGLoadContainerLSPStg
	SELECT @intLoadStgId
		,@intLoadId
		,LC.intLoadContainerId
		,LC.strContainerNumber
		,CASE 
			WHEN CT.strContainerType LIKE '%20%'
				THEN '000000000010003243'
			WHEN CT.strContainerType LIKE '%40%'
				THEN '000000000010003244'
			ELSE CT.strContainerType
			END
		,'0002'
		,L.strExternalShipmentNumber
		,ROW_NUMBER() OVER (
			PARTITION BY LC.intLoadId ORDER BY LC.intLoadId
			) AS Seq
		,LC.dblQuantity
		,LC.strItemUOM
		,LC.dblNetWt
		,LC.dblGrossWt
		,LC.strWeightUnitMeasure
		,LC.strExternalContainerId
		,@strRowState
		,GETDATE()
	FROM vyuLGLoadContainerView LC
	JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
	WHERE LC.intLoadId = @intLoadId
	ORDER BY LC.intLoadContainerId
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH