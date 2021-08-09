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
	DECLARE @intMaxLoadStgId INT

	SELECT TOP 1 @strWarehouseVendorNo = WE.strEntityNo
			  ,@strWarehouseVendorName = WE.strName
			  ,@strWarehouseVendorAddress = EL.strAddress
			  ,@strWarehouseVendorPostalCode = EL.strZipCode
			  ,@strWarehouseVendorCity = EL.strCity
			  ,@strWarehouseVendorCountry = (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry)
			  ,@strWarehouseVendorAccNo = A.strVendorAccountNum
	FROM tblLGLoadDetail LD
	JOIN tblCTContractDetail CD ON LD.intPContractDetailId = CD.intContractDetailId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
	LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
	LEFT JOIN tblAPVendor A ON A.[intEntityId] = WE.intEntityId
	WHERE LD.intLoadId = @intLoadId

	SELECT @intMaxLoadStgId = intLoadStgId FROM tblLGLoadStg WHERE intLoadId = @intLoadId

	IF EXISTS (SELECT TOP 1 1 FROM tblLGLoadStg WHERE strFeedStatus = 'Ack Rcvd' AND intLoadStgId = @intMaxLoadStgId AND strMessage <> 'Success')
	BEGIN
		UPDATE tblLGLoadStg SET strFeedStatus='',strMessage = NULL WHERE intLoadStgId = @intMaxLoadStgId
	END

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
					WHEN 1 THEN 'Shipment'
					WHEN 2 THEN 'Shipping Instructions'
					WHEN 3 THEN 'Vessel Nomination'
					ELSE '' END COLLATE Latin1_General_CI_AS
				,L.strLoadNumber
				,strCompanyLocationName = LD.strLocationName
				,strSubLocationName = LD.strSubLocationName
				,strLanguage = 'EN'
				,strWarehouseVendorNo = CASE WHEN ISNULL(WE.strEntityNo,'') = '' THEN @strWarehouseVendorNo ELSE WE.strEntityNo END
				,strWarehouseVendorName = CASE WHEN ISNULL(WE.strName,'') = '' THEN @strWarehouseVendorName ELSE WE.strName END
				,strWarehouseVendorAddress = CASE WHEN ISNULL(EL.strAddress,'') = '' THEN @strWarehouseVendorAddress ELSE EL.strAddress END
				,strWarehouseVendorPostalCode = CASE WHEN ISNULL( EL.strZipCode,'') = '' THEN @strWarehouseVendorPostalCode ELSE  EL.strZipCode END
				,strWarehouseVendorCity = CASE WHEN ISNULL( EL.strCity,'') = '' THEN @strWarehouseVendorCity ELSE  EL.strCity END
				,strWarehouseVendorCountry = CASE WHEN ISNULL((SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry),'') = '' THEN @strWarehouseVendorCountry ELSE  (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry) END
				,strWarehouseVendorAccNo = CASE WHEN ISNULL( A.strVendorAccountNum,'') = '' THEN @strWarehouseVendorAccNo ELSE  A.strVendorAccountNum END
				,strVendorName = LD.strVendorName
				,strVendorAddress = LD.strVendorAddress
				,strVendorPostalCode = LD.strVendorZipCode
				,strVendorCity = LD.strVendorCity
				,strVendorTelePhoneNo = LD.strVendorPhone
				,strVendorTeleFaxNo = LD.strVendorFax
				,strVendorCountry = LD.strVendorCountry
				,strVendorAccountNo = LD.strVendorAccountNum
				,L.strOriginPort
				,strOriginAddress = '' 
				,strOriginPostalCode = '' 
				,strOriginCity = ''
				,strOriginTelePhoneNo = ''
				,strOriginTeleFaxNo = '' 
				,strOriginCountry = LD.strOriginCountry
				,strOriginRegion = '' 
				,L.strDestinationPort
				,strDestinationAddress = '' 
				,strDestinationPostalCode = '' 
				,strDestinationCity = '' 
				,strDestinationTelePhoneNo = '' 
				,strDestinationTeleFaxNo = '' 
				,strDestinationCountry = DCountry.strISOCode 
				,strDestinationRegion = '' 
				,strForwardingAgent = FA.strName
				,FAEL.strAddress
				,FAEL.strZipCode
				,FAEL.strCity
				,FAEL.strPhone
				,FAEL.strFax
				,FACountry.strISOCode
				,FAV.strVendorAccountNum
				,strContractBasis = LD.strContractBasis
				,strContractBasisDesc = LD.strContractBasisDesc
				,L.strBLNumber
				,strShippingLine = SL.strName
				,SLEL.strAddress
				,SLEL.strZipCode
				,SLEL.strCity
				,SLEL.strPhone
				,SLEL.strFax
				,SLCountry.strISOCode
				,strShippingLineAccountNo = SLV.strVendorAccountNum 
				,L.strExternalShipmentNumber
				,strDateQualifier = '015' 
				,L.dtmScheduledDate
				,L.dtmETAPOD
				,L.dtmETAPOL
				,L.dtmETSPOL
				,L.dtmBLDate
				,strRowState = 'Delete'
				,dtmFeedCreated = GETDATE()
				,dblTotalGross = LDT.dblTotalGross
				,dblTotalNet = LDT.dblTotalNet
				,strWeightUnitMeasure = LD.strWeightUnitMeasure
				,L.strMVessel
				,L.strMVoyageNumber
				,L.strFVessel
				,L.strFVoyageNumber
			FROM tblLGLoad L
			LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
			LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = SL.intEntityId
			LEFT JOIN tblSMCountry SLCountry ON SLCountry.strCountry = SLEL.strCountry
			LEFT JOIN tblAPVendor SLV ON SLV.intEntityId = SL.intEntityId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
			LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
			LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
			LEFT JOIN tblAPVendor A ON A.[intEntityId] = WE.intEntityId
			LEFT JOIN tblSMCity OCity ON OCity.strCity = L.strOriginPort
			LEFT JOIN tblSMCountry OCountry ON OCountry.intCountryID = OCity.intCountryId
			LEFT JOIN tblSMCity DCity ON DCity.strCity = L.strDestinationPort
			LEFT JOIN tblSMCountry DCountry ON DCountry .intCountryID = DCity.intCountryId
			LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
			LEFT JOIN tblEMEntityLocation FAEL ON FAEL.intEntityId = FA.intEntityId
			LEFT JOIN tblSMCountry FACountry ON FACountry.strCountry = FAEL.strCountry
			LEFT JOIN tblAPVendor FAV ON FAV.intEntityId = FA.intEntityId
			OUTER APPLY (
				SELECT TOP 1 
					CL.strLocationName 
					,CLSL.strSubLocationName
					,strVendorName = E.strName
					,strVendorAddress = EL.strAddress
					,strVendorZipCode = EL.strZipCode
					,strVendorCity = EL.strCity
					,strVendorState = EL.strState
					,strVendorPhone = EC.strPhone
					,strVendorFax = EC.strFax
					,strVendorCountry = SM.strISOCode
					,strVendorAccountNum = V.strVendorAccountNum
					,strContractBasis = CB.strContractBasis
					,strContractBasisDesc = CB.strDescription
					,strWeightUnitMeasure = UM.strUnitMeasure
					,strOriginCountry = ISNULL(ICC.strISOCode, CAC.strISOCode)
				FROM tblLGLoadDetail LD
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					LEFT JOIN tblICItemUOM IUM ON IUM.intItemUOMId = LD.intWeightItemUOMId
					LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
					LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					LEFT JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
					LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
					LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = EL.intEntityId AND EL.ysnDefaultLocation = 1
					LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId
					LEFT JOIN tblEMEntity EC ON EC.intEntityId = ETC.intEntityContactId
					LEFT JOIN tblSMCountry SM ON SM.strCountry = EL.strCountry
					LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
					LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
					LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId 
					LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
					LEFT JOIN tblSMCountry CAC ON CAC.intCountryID = CA.intCountryID
					LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
					LEFT JOIN tblSMCountry ICC ON ICC.intCountryID = IC.intCountryId
				WHERE LD.intLoadId = L.intLoadId
				) LD
			OUTER APPLY (
				SELECT 
					dblTotalGross = SUM(dblGross)
					,dblTotalNet = SUM(dblNet)
				FROM tblLGLoadDetail LD
				WHERE LD.intLoadId = L.intLoadId) LDT
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
				,intSIDetailId = CASE WHEN ISNULL(LSID.intLoadDetailId, 0) = 0 THEN LD.intLoadDetailId ELSE LSID.intLoadDetailId END
				,LD.intLoadDetailId
				,intRowNumber = Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId)
				,I.strItemNo
				,I.strDescription
				,I.strShortName
				,strSubLocationName = CLSL.strSubLocationName
				,strStorageLocationName = SL.strName
				,L.strLoadNumber
				,LD.dblQuantity
				,strItemUOM = IUM.strUnitMeasure
				,LD.dblGross
				,LD.dblNet
				,strWeightItemUOM = WUM.strUnitMeasure
				,intHigherPositionRef = Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId)
				,strDocumentCategory = 'C'
				,strRefDataInfo = '001'
				,strSeq = 0
				,L.strLoadNumber
				,CD.strERPPONumber
				,CD.strERPItemNumber
				,CD.strERPBatchNumber
				,LD.strExternalShipmentItemNumber
				,LD.strExternalBatchNo
				,strChangeType = 'QUA'
				,strRowState = @strRowState 
				,dtmFeedCreated = GETDATE()
				,C.strCommodityCode
			FROM tblLGLoadDetail LD
			JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
			JOIN tblICItem I ON I.intItemId = LD.intItemId
			JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
			LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
			LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = LD.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WUOM.intUnitMeasureId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
			LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
			LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId
				AND LD.intPContractDetailId = LSID.intPContractDetailId
			WHERE LD.intLoadId = @intLoadId

			INSERT INTO tblLGLoadContainerLSPStg
			SELECT @intLoadStgId
				,@intLoadId
				,LC.intLoadContainerId
				,LC.strContainerNumber
				,strContainerSizeCode = CASE 
					WHEN CT.strContainerType LIKE '%20%'
						THEN '000000000010003243'
					WHEN CT.strContainerType LIKE '%40%'
						THEN '000000000010003244'
					ELSE CT.strContainerType
					END
				,strPackagingMaterialType = '0002'
				,strExternalPONumber = L.strExternalShipmentNumber
				,strSeq = ROW_NUMBER() OVER (PARTITION BY LC.intLoadId ORDER BY LC.intLoadId)
				,dblContainerQty = LC.dblQuantity
				,strContainerUOM = UOM.strUnitMeasure
				,LC.dblNetWt
				,LC.dblGrossWt
				,strWeightUOM = LCWU.strUnitMeasure
				,strExternalContainerId = LDCL.strExternalContainerId
				,strRowState = @strRowState
				,dtmFeedCreated = GETDATE()
			FROM tblLGLoadContainer LC
			JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
			JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
			LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
			LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
			WHERE LC.intLoadId = @intLoadId
			ORDER BY LC.intSort
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
				WHEN 1 THEN 'Shipment'
				WHEN 2 THEN 'Shipping Instructions'
				WHEN 3 THEN 'Vessel Nomination'
				ELSE '' END COLLATE Latin1_General_CI_AS
			,L.strLoadNumber
			,strCompanyLocationName = LD.strLocationName
			,strSubLocationName = LD.strSubLocationName
			,strLanguage = 'EN'
			,strWarehouseVendorNo = CASE WHEN ISNULL(WE.strEntityNo,'') = '' THEN @strWarehouseVendorNo ELSE WE.strEntityNo END
			,strWarehouseVendorName = CASE WHEN ISNULL(WE.strName,'') = '' THEN @strWarehouseVendorName ELSE WE.strName END
			,strWarehouseVendorAddress = CASE WHEN ISNULL(EL.strAddress,'') = '' THEN @strWarehouseVendorAddress ELSE EL.strAddress END
			,strWarehouseVendorPostalCode = CASE WHEN ISNULL( EL.strZipCode,'') = '' THEN @strWarehouseVendorPostalCode ELSE  EL.strZipCode END
			,strWarehouseVendorCity = CASE WHEN ISNULL( EL.strCity,'') = '' THEN @strWarehouseVendorCity ELSE  EL.strCity END
			,strWarehouseVendorCountry = CASE WHEN ISNULL((SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry),'') = '' THEN @strWarehouseVendorCountry ELSE  (SELECT TOP 1 SM.strISOCode FROM tblSMCountry SM WHERE SM.strCountry = EL.strCountry) END
			,strWarehouseVendorAccNo = CASE WHEN ISNULL( A.strVendorAccountNum,'') = '' THEN @strWarehouseVendorAccNo ELSE  A.strVendorAccountNum END
			,strVendorName = LD.strVendorName
			,strVendorAddress = LD.strVendorAddress
			,strVendorPostalCode = LD.strVendorZipCode
			,strVendorCity = LD.strVendorCity
			,strVendorTelePhoneNo = LD.strVendorPhone
			,strVendorTeleFaxNo = LD.strVendorFax
			,strVendorCountry = LD.strVendorCountry
			,strVendorAccountNo = LD.strVendorAccountNum
			,L.strOriginPort
			,strOriginAddress = '' 
			,strOriginPostalCode = '' 
			,strOriginCity = ''
			,strOriginTelePhoneNo = ''
			,strOriginTeleFaxNo = '' 
			,strOriginCountry = LD.strOriginCountry
			,strOriginRegion = '' 
			,L.strDestinationPort
			,strDestinationAddress = '' 
			,strDestinationPostalCode = '' 
			,strDestinationCity = '' 
			,strDestinationTelePhoneNo = '' 
			,strDestinationTeleFaxNo = '' 
			,strDestinationCountry = DCountry.strISOCode 
			,strDestinationRegion = '' 
			,strForwardingAgent = FA.strName
			,FAEL.strAddress
			,FAEL.strZipCode
			,FAEL.strCity
			,FAEL.strPhone
			,FAEL.strFax
			,FACountry.strISOCode
			,FAV.strVendorAccountNum
			,strContractBasis = LD.strContractBasis
			,strContractBasisDesc = LD.strContractBasisDesc
			,L.strBLNumber
			,strShippingLine = SL.strName
			,SLEL.strAddress
			,SLEL.strZipCode
			,SLEL.strCity
			,SLEL.strPhone
			,SLEL.strFax
			,SLCountry.strISOCode
			,strShippingLineAccountNo = SLV.strVendorAccountNum 
			,L.strExternalShipmentNumber
			,strDateQualifier = '015' 
			,L.dtmScheduledDate
			,L.dtmETAPOD
			,L.dtmETAPOL
			,L.dtmETSPOL
			,L.dtmBLDate
			,strRowState = 'Added'
			,dtmFeedCreated = GETDATE()
			,dblTotalGross = LDT.dblTotalGross
			,dblTotalNet = LDT.dblTotalNet
			,strWeightUnitMeasure = LD.strWeightUnitMeasure
			,L.strMVessel
			,L.strMVoyageNumber
			,L.strFVessel
			,L.strFVoyageNumber
		FROM tblLGLoad L
		LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = SL.intEntityId
		LEFT JOIN tblSMCountry SLCountry ON SLCountry.strCountry = SLEL.strCountry
		LEFT JOIN tblAPVendor SLV ON SLV.intEntityId = SL.intEntityId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblEMEntity WE ON WE.intEntityId = CLSL.intVendorId
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = WE.intEntityId
		LEFT JOIN tblAPVendor A ON A.[intEntityId] = WE.intEntityId
		LEFT JOIN tblSMCity OCity ON OCity.strCity = L.strOriginPort
		LEFT JOIN tblSMCountry OCountry ON OCountry.intCountryID = OCity.intCountryId
		LEFT JOIN tblSMCity DCity ON DCity.strCity = L.strDestinationPort
		LEFT JOIN tblSMCountry DCountry ON DCountry .intCountryID = DCity.intCountryId
		LEFT JOIN tblEMEntity FA ON FA.intEntityId = L.intForwardingAgentEntityId
		LEFT JOIN tblEMEntityLocation FAEL ON FAEL.intEntityId = FA.intEntityId
		LEFT JOIN tblSMCountry FACountry ON FACountry.strCountry = FAEL.strCountry
		LEFT JOIN tblAPVendor FAV ON FAV.intEntityId = FA.intEntityId
		OUTER APPLY (
			SELECT TOP 1 
				CL.strLocationName 
				,CLSL.strSubLocationName
				,strVendorName = E.strName
				,strVendorAddress = EL.strAddress
				,strVendorZipCode = EL.strZipCode
				,strVendorCity = EL.strCity
				,strVendorState = EL.strState
				,strVendorPhone = EC.strPhone
				,strVendorFax = EC.strFax
				,strVendorCountry = SM.strISOCode
				,strVendorAccountNum = V.strVendorAccountNum
				,strContractBasis = CB.strContractBasis
				,strContractBasisDesc = CB.strDescription
				,strWeightUnitMeasure = UM.strUnitMeasure
				,strOriginCountry = ISNULL(ICC.strISOCode, CAC.strISOCode)
			FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				LEFT JOIN tblICItemUOM IUM ON IUM.intItemUOMId = LD.intWeightItemUOMId
				LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUM.intUnitMeasureId
				LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
				LEFT JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
				LEFT JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
				LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = EL.intEntityId AND EL.ysnDefaultLocation = 1
				LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId
				LEFT JOIN tblEMEntity EC ON EC.intEntityId = ETC.intEntityContactId
				LEFT JOIN tblSMCountry SM ON SM.strCountry = EL.strCountry
				LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
				LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
				LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId 
				LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
				LEFT JOIN tblSMCountry CAC ON CAC.intCountryID = CA.intCountryID
				LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
				LEFT JOIN tblSMCountry ICC ON ICC.intCountryID = IC.intCountryId
			WHERE LD.intLoadId = L.intLoadId
			) LD
		OUTER APPLY (
			SELECT 
				dblTotalGross = SUM(dblGross)
				,dblTotalNet = SUM(dblNet)
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId) LDT
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
			,intSIDetailId = CASE WHEN ISNULL(LSID.intLoadDetailId, 0) = 0 THEN LD.intLoadDetailId ELSE LSID.intLoadDetailId END
			,LD.intLoadDetailId
			,intRowNumber = Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId)
			,I.strItemNo
			,I.strDescription
			,I.strShortName
			,strSubLocationName = CLSL.strSubLocationName
			,strStorageLocationName = SL.strName
			,L.strLoadNumber
			,LD.dblQuantity
			,strItemUOM = IUM.strUnitMeasure
			,LD.dblGross
			,LD.dblNet
			,strWeightItemUOM = WUM.strUnitMeasure
			,intHigherPositionRef = Row_NUMBER() OVER (PARTITION BY LD.intLoadId ORDER BY LD.intLoadId)
			,strDocumentCategory = 'C'
			,strRefDataInfo = '001'
			,strSeq = 0
			,L.strLoadNumber
			,CD.strERPPONumber
			,CD.strERPItemNumber
			,CD.strERPBatchNumber
			,LD.strExternalShipmentItemNumber
			,LD.strExternalBatchNo
			,strChangeType = 'QUA'
			,strRowState = @strRowState 
			,dtmFeedCreated = GETDATE()
			,C.strCommodityCode
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
		JOIN tblICItem I ON I.intItemId = LD.intItemId
		JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
		LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WUOM.intUnitMeasureId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
		LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
		LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
		LEFT JOIN tblLGLoadDetail LSID ON LSID.intLoadId = LSI.intLoadId
			AND LD.intPContractDetailId = LSID.intPContractDetailId
		WHERE LD.intLoadId = @intLoadId

		INSERT INTO tblLGLoadContainerLSPStg
		SELECT @intLoadStgId
			,@intLoadId
			,LC.intLoadContainerId
			,LC.strContainerNumber
			,strContainerSizeCode = CASE 
				WHEN CT.strContainerType LIKE '%20%'
					THEN '000000000010003243'
				WHEN CT.strContainerType LIKE '%40%'
					THEN '000000000010003244'
				ELSE CT.strContainerType
				END
			,strPackagingMaterialType = '0002'
			,strExternalPONumber = L.strExternalShipmentNumber
			,strSeq = ROW_NUMBER() OVER (PARTITION BY LC.intLoadId ORDER BY LC.intLoadId)
			,dblContainerQty = LC.dblQuantity
			,strContainerUOM = UOM.strUnitMeasure
			,LC.dblNetWt
			,LC.dblGrossWt
			,strWeightUOM = LCWU.strUnitMeasure
			,strExternalContainerId = LDCL.strExternalContainerId
			,strRowState = @strRowState
			,dtmFeedCreated = GETDATE()
		FROM tblLGLoadContainer LC
		JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
		LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
		WHERE LC.intLoadId = @intLoadId
		ORDER BY LC.intSort
	END

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH