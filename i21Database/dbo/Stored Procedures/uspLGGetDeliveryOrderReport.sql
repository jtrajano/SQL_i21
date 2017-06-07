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
		  ,CLSL.strSubLocationName
		  ,CLSL.strAddress AS strSubLocationAddress
		  ,CLSL.strCity AS strSubLocationCity
		  ,CLSL.strState AS strSubLocationState
		  ,CLSL.strZipCode AS strSubLocationZip
		  ,CLSL.strCity + ', ' + CLSL.strState + ', ' + CLSL.strZipCode AS strSubLocationCityStateZip
		  ,EM.strName AS strCustomer
		  ,CASE 
			WHEN ISNULL(EL.strAddress, '') = ''
				THEN (
						SELECT EL1.strAddress
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strAddress
			END AS strCustomerLocationAddress
		  ,CASE 
			WHEN ISNULL(EL.strCity, '') = ''
				THEN (
						SELECT EL1.strCity
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strCity
			END AS strCustomerLocationCity
		  ,CASE 
			WHEN ISNULL(EL.strState, '') = ''
				THEN (
						SELECT EL1.strState
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strState
			END AS strCustomerLocationState
		  ,CASE 
			WHEN ISNULL(EL.strZipCode, '') = ''
				THEN (
						SELECT EL1.strZipCode
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strZipCode
			END AS strCustomerLocationZipCode
		  ,CASE 
			WHEN ISNULL(EL.strCity, '') = ''
				THEN (
						SELECT EL1.strCity
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strCity
			END + ', ' + CASE 
			WHEN ISNULL(EL.strState, '') = ''
				THEN (
						SELECT EL1.strState
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strState
			END + ', ' + CASE 
			WHEN ISNULL(EL.strZipCode, '') = ''
				THEN (
						SELECT EL1.strZipCode
						FROM tblEMEntityLocation EL1
						JOIN tblEMEntity EM1 ON EL1.intEntityId = EM.intEntityId
						WHERE EL1.ysnDefaultLocation = 1
							AND EM.intEntityId = EM1.intEntityId
						)
			ELSE EL.strZipCode
			END AS strCustomerLocationCityStateZip
		  ,(SELECT AC.strFLOId
			FROM tblARCustomer AC
			WHERE AC.[intEntityId]= EM.intEntityId
			) strFLOId		  
		  ,(SELECT ETCN.strName
			FROM tblEMEntity EM1 
			JOIN tblEMEntityToContact ETC ON ETC.intEntityId = EM1.intEntityId
			JOIN tblEMEntity ETCN ON ETCN.intEntityId = ETC.intEntityContactId
			WHERE EM.intEntityId = EM1.intEntityId
			)strContactName
		  ,L.dtmScheduledDate
		  ,LW.dtmPickupDate
		  ,LW.dtmLastFreeDate
		  ,LW.dtmDeliveryDate AS dtmDODate
		  ,(SELECT TOP 1 CH.strCustomerContract
			FROM tblCTContractDetail CD
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			WHERE CD.intContractDetailId = LD.intSContractDetailId
			) AS strBuyersPONo
		  ,(SELECT E1.strPhone
			FROM tblEMEntity E
			JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId
			JOIN tblEMEntity E1 ON E1.intEntityId = EC.intEntityContactId
			WHERE E.intEntityId = EM.intEntityId
			) strCustomerContactNumber
		  ,@strCompanyName AS strCompanyName
		  ,@strCompanyAddress AS strCompanyAddress
		  ,@strContactName AS strCompanyContactName 
		  ,@strCounty AS strCompanyCounty 
		  ,@strCity AS strCompanyCity 
		  ,@strState AS strCompanyState 
		  ,@strZip AS strCompanyZip 
		  ,@strCountry AS strCompanyCountry 
		  ,@strPhone AS strCompanyPhone
		  ,@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
		  ,HEM.strName AS strShipVia
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = LD.intCustomerEntityId
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = LD.intCustomerEntityLocationId
	LEFT JOIN tblEMEntity HEM ON HEM.intEntityId = LW.intHaulerEntityId
	WHERE strLoadNumber = @strLoadNumber
END