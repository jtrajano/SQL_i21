CREATE PROCEDURE uspLGGetDeliveryOrderReport
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strLoadNumber			NVARCHAR(MAX),
			@xmlDocumentId			INT,
			@strCompanyName			NVARCHAR(100),
			@strCompanyAddress		NVARCHAR(100),
			@strContactName			NVARCHAR(50),
			@strCounty				NVARCHAR(25),
			@strCity				NVARCHAR(25),
			@strState				NVARCHAR(50),
			@strZip					NVARCHAR(12),
			@strCountry				NVARCHAR(25),
			@strPhone				NVARCHAR(50),
			@strFax					NVARCHAR(50),
			@strWeb					NVARCHAR(200),
			@strHaulerAddress		NVARCHAR(MAX), 
			@strHaulerCity			NVARCHAR(MAX), 
			@strHaulerCountry		NVARCHAR(MAX), 
			@strHaulerState			NVARCHAR(MAX), 
			@strHaulerZip			NVARCHAR(MAX)

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
    
	SELECT	@strLoadNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strLoadNumber' 

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strContactName = strContactName
		,@strCounty = strCounty
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
		,@strPhone = strPhone
		,@strFax = strFax
		,@strWeb = strWebSite
	FROM tblSMCompanySetup

	SELECT
		@strHaulerAddress = (SELECT EL.strAddress from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCity = (SELECT EL.strCity from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCountry = (SELECT EL.strCountry from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerState = (SELECT EL.strState from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerZip = (SELECT EL.strZipCode from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId)
	FROM vyuLGLoadDetailView L WHERE L.[strLoadNumber] = @strLoadNumber

	SELECT DISTINCT L.strLoadNumber
		  ,L.intLoadId
		  ,LW.strDeliveryNoticeNumber
		  ,strSubLocationName = ISNULL(WHVendor.strName,CLSL.strSubLocationName)
		  ,ContactEntity.strEmail
		  ,ContactEntity.strPhone
		  ,ContactEntity.strInternalNotes
		  ,strSubLocationAddress = CLSL.strAddress
		  ,strSubLocationCity = CLSL.strCity
		  ,strSubLocationState = CLSL.strState
		  ,strSubLocationZip = CLSL.strZipCode
		  ,strSubLocationCityStateZip = CLSL.strCity + ', ' + CLSL.strState + ', ' + CLSL.strZipCode
		  ,strCustomer = EM.strName
		  ,strCustomerLocationAddress = ISNULL(EL.strAddress, EDL.strAddress)
		  ,strCustomerLocationCity = ISNULL(EL.strCity, EDL.strCity)
		  ,strCustomerLocationState = ISNULL(EL.strState, EDL.strState) 
		  ,strCustomerLocationZipCode = ISNULL(EL.strZipCode, EDL.strZipCode)
		  ,strCustomerLocationCityStateZip = COALESCE(EL.strCity, EDL.strCity, '') + ', ' + COALESCE(EL.strState, EDL.strState, '') + ', ' + COALESCE(EL.strZipCode, EDL.strZipCode, '') 
		  ,strFLOId = (SELECT AC.strFLOId FROM tblARCustomer AC WHERE AC.[intEntityId]= EM.intEntityId) 		  
		  ,strContactName = EDC.strName
		  ,L.dtmScheduledDate
		  ,LW.dtmPickupDate
		  ,LW.dtmLastFreeDate
		  ,LW.dtmCustomsEntrySent
		  ,LW.dtmSampleAuthorizedDate
		  ,dtmApprovalDate = SMPL.dtmTestingEndDate
		  ,dtmFreeTimeExpires = DATEADD(DD, ISNULL(SCH.intClaimValidTill, 0), LW.dtmDeliveryDate)
		  ,dtmDODate = LW.dtmDeliveryDate
		  ,strBuyersPONo = SCH.strCustomerContract
		  ,strSalesContractNo = SCH.strContractNumber + ' / ' + LTRIM(SCH.intContractSeq)
		  ,strSalesContractNoDashSeq = SCH.strContractNumber + '-' + LTRIM(SCH.intContractSeq)
		  ,strSalesContractIncoTerm = SCH.strContractBasis
		  ,strSalesContractWeightTerms = SCH.strWeightGradeDesc
		  ,strCustomerContactNumber = EDC.strPhone
		  ,strCompanyName = @strCompanyName
		  ,strCompanyAddress = @strCompanyAddress
		  ,strCompanyContactName = @strContactName 
		  ,strCompanyCounty = @strCounty 
		  ,strCompanyCity = @strCity 
		  ,strCompanyState = @strState 
		  ,strCompanyZip = @strZip 
		  ,strCompanyCountry = @strCountry 
		  ,strCompanyPhone = @strPhone
		  ,strCompanyFax = @strFax
		  ,strCompanyWebSite = @strWeb
		  ,strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ','
		  ,strShipVia = HEM.strName 
		  ,L.strComments
		  ,strOutboundInstructions = SCH.strInstructions
		  ,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
		  ,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
		  ,ysnFullHeaderLogo = CASE WHEN ISNULL(CP.ysnFullHeaderLogo,0) = 1 THEN 'true' ELSE 'false' END
		  ,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
		  ,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0) 
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblEMEntity WHVendor ON WHVendor.intEntityId = CLSL.intVendorId
	LEFT JOIN tblEMEntityToContact WHVendorContact ON WHVendorContact.intEntityId = WHVendor.intEntityId
	LEFT JOIN tblEMEntity ContactEntity ON ContactEntity.intEntityId = WHVendorContact.intEntityContactId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = LD.intCustomerEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LD.intCustomerEntityLocationId
	LEFT JOIN tblEMEntity HEM ON HEM.intEntityId = LW.intHaulerEntityId
	OUTER APPLY (SELECT TOP 1 
						CH.strCustomerContract
						,CH.strContractNumber
						,CD.intContractSeq
						,CD.intContractDetailId
						,CB.strContractBasis
						,CB.strInstructions
						,strAssociation = ASN.strName
						,ASN.intClaimValidTill 
						,WG.strWeightGradeDesc
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
					LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
					LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					WHERE CD.intContractDetailId = LD.intSContractDetailId) SCH
	OUTER APPLY (SELECT TOP 1 EL1.strAddress, EL1.strCity, EL1.strState, EL1.strZipCode
					FROM tblEMEntityLocation EL1
					JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
					WHERE EL1.ysnDefaultLocation = 1 AND EM.intEntityId = EM1.intEntityId) EDL
	OUTER APPLY (SELECT ETCN.strName, ETCN.strPhone
					FROM tblEMEntity EM1 
					JOIN tblEMEntityToContact ETC ON ETC.intEntityId = EM1.intEntityId
					JOIN tblEMEntity ETCN ON ETCN.intEntityId = ETC.intEntityContactId
					WHERE EM.intEntityId = EM1.intEntityId AND ETC.ysnDefaultContact = 1) EDC
	OUTER APPLY (SELECT TOP 1 SMP.strSampleNumber, SMP.intSampleStatusId, SMP.dtmTestingEndDate
					FROM tblQMSample SMP 
					INNER JOIN tblQMSampleType SMPT ON SMPT.intSampleTypeId = SMP.intSampleTypeId
					LEFT JOIN tblQMSampleStatus SMPS ON SMPS.intSampleStatusId = SMP.intSampleStatusId 
					WHERE SMP.intContractDetailId = SCH.intContractDetailId 
						AND SMPS.strStatus = 'Approved'
						AND ISNULL(SMPT.ysnFinalApproval, 0) = 1) SMPL
	CROSS APPLY tblLGCompanyPreference CP
	WHERE strLoadNumber = @strLoadNumber
END