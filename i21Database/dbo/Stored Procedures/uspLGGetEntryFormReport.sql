CREATE PROCEDURE [dbo].[uspLGGetEntryFormReport]
	@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intLoadWarehouseId	INT
			,@xmlDocumentId		INT
			,@strUserName		NVARCHAR(500)

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intLoadWarehouseId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLoadWarehouseId' 
    
	SELECT	@strUserName = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strUserName' 

	SELECT
		intLoadWarehouseId = LW.intLoadWarehouseId
		,dtmCustomsSent = LW.dtmCustomsEntrySent
		,strLoadNumber = L.strLoadNumber
		,strPONumber = PCH.strContractNumber
		,strCustomsBroker = CB.strName
		,strWarehouse = WH.strSubLocationName
		,strShipper = V.strName
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,dblQuantity = LDT.dblQuantity
		,strShippingLine = SL.strName
		,strVessel = L.strMVessel
		,strVesselIMO = L.strIMONumber
		,strLoadingPort = L.strOriginPort
		,strDestinationPort = L.strDestinationPort
		,dtmETAPOD = L.dtmETAPOD
		,strDrayageBy = DR.strName
		,strWeighing = WG.strWeightGradeDesc
		,strBLNumber = L.strBLNumber
		,dtmBLDate = L.dtmBLDate
		,dtmLastFreeDate = LW.dtmLastFreeDate
		,dtmEmptyContainerReturn = LW.dtmEmptyContainerReturn
		,dblValue = VAL.dblAmount
		,dblHarborFee = ROUND(CASE WHEN (VAL.dblAmount * (CF.dblHarborFee / 100)) > CF.dblHarborFeeCap 
							THEN CF.dblHarborFeeCap ELSE (VAL.dblAmount * (CF.dblHarborFee / 100)) END, 2)
		,dblProcessingFee = ROUND(CASE WHEN (VAL.dblAmount * (CF.dblProcessingFee / 100)) > CF.dblProcessingFeeCap 
							THEN CF.dblProcessingFeeCap ELSE (VAL.dblAmount * (CF.dblProcessingFee / 100)) END, 2)
		,strComments = L.strComments

		,strCompanyName = CS.strCompanyName
		,strCompanyAddress = CS.strAddress
		,strContactName = CS.strContactName
		,strCounty = CS.strCounty
		,strCity = CS.strCity
		,strState = CS.strState
		,strZip = CS.strZip
		,strCountry = CS.strCountry
		,strPhone = CS.strPhone
		,strFax = CS.strFax
		,strWeb = CS.strWebSite 
		,blbHeaderLogo = LOGO.blbHeaderLogo
		,blbFooterLogo = LOGO.blbFooterLogo
		,strHeaderLogoType = LOGO.strHeaderLogoType
		,strFooterLogoType = LOGO.strFooterLogoType
		,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
		,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
		,ysnFullHeaderLogo = ISNULL(CP.ysnFullHeaderLogo, 0)
		,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
		,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)
		,U.strFullName
		,U.strUserPhoneNo
		,U.strUserEmailId
	FROM tblLGLoadWarehouse LW
		LEFT JOIN tblEMEntity CB ON CB.intEntityId = LW.intBrokerEntityId
		LEFT JOIN tblEMEntity DR ON DR.intEntityId = LW.intHaulerEntityId
		LEFT JOIN tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = LW.intWeightGradeId
		LEFT JOIN tblLGLoad L ON L.intLoadId = LW.intLoadId
		LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		OUTER APPLY (SELECT dblQuantity = SUM(dblQuantity) FROM tblLGLoadDetail WHERE intLoadId = L.intLoadId) LDT
		OUTER APPLY (SELECT dblAmount = SUM(dblTotal) FROM tblAPBillDetail 
						WHERE strBillOfLading = L.strBLNumber
							AND intLoadDetailId = LD.intLoadDetailId) VAL
		LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblEMEntity V ON V.intEntityId = PCH.intEntityId
		LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
		OUTER APPLY (SELECT TOP 1 * FROM tblLGCustomsFee WHERE strOrigin = L.strOriginPort) CF
		OUTER APPLY (SELECT TOP 1 * FROM tblLGCompanyPreference) CP
		OUTER APPLY (SELECT TOP 1 * FROM tblSMCompanySetup) CS
		OUTER APPLY (
			SELECT 
				strFullName = E.strName
			   ,strUserEmailId = ETC.strEmail
			   ,strUserPhoneNo = EPN.strPhone  
			FROM tblSMUserSecurity S
			JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
			JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId
			JOIN tblEMEntity ETC ON ETC.intEntityId = EC.intEntityContactId
			JOIN tblEMEntityPhoneNumber EPN ON EPN.intEntityId = ETC.intEntityId
			WHERE S.strUserName = @strUserName) U
		OUTER APPLY (
			SELECT TOP 1
				[blbLogo] = imgLogo
				,[strLogoType] = 'Logo'
			FROM tblSMLogoPreference
			WHERE (ysnAllOtherReports = 1 OR ysnDefault = 1)
				AND intCompanyLocationId = PCD.intCompanyLocationId
			ORDER BY (CASE WHEN ysnDefault = 1 THEN 1 ELSE 0 END) DESC) CLLH
		OUTER APPLY (
			SELECT TOP 1
				[blbLogo] = imgLogo
				,[strLogoType] = 'Logo'
			FROM tblSMLogoPreferenceFooter
			WHERE (ysnAllOtherReports = 1 OR ysnDefault = 1)
				AND intCompanyLocationId = PCD.intCompanyLocationId
			ORDER BY (CASE WHEN ysnDefault = 1 THEN 1 ELSE 0 END) DESC) CLLF
		OUTER APPLY (
			SELECT
				blbHeaderLogo = ISNULL(CLLH.blbLogo, dbo.fnSMGetCompanyLogo('Header'))
				,blbFooterLogo = ISNULL(CLLF.blbLogo, dbo.fnSMGetCompanyLogo('Footer'))
				,strHeaderLogoType = CASE WHEN CLLH.blbLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
				,strFooterLogoType = CASE WHEN CLLF.blbLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END) LOGO

	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId

END

GO