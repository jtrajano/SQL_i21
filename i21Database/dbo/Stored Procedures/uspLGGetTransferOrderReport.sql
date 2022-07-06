CREATE PROCEDURE [dbo].[uspLGGetTransferOrderReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strLoadNumber			NVARCHAR(MAX),
			@xmlDocumentId			INT,
			@strUserName			NVARCHAR(100),
			@intLoadId				INT

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   

	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
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

	SELECT @intLoadId = intLoadId FROM tblLGLoad WHERE strLoadNumber = @strLoadNumber
	SELECT 
		strFromLocationName = CASE WHEN 
			ISNULL(FromStorageLoc.strSubLocationName, '') = '' THEN FromLoc.strLocationName
			ELSE FromStorageLoc.strSubLocationName END
		,strToLocationName = CASE WHEN 
			ISNULL(ToStorageLoc.strSubLocationName, '') = '' THEN ToLoc.strLocationName
			ELSE ToStorageLoc.strSubLocationName END
		,strTransferFromAddress = 
			CASE WHEN 
				ISNULL(FromStorageLoc.strSubLocationName, '') = ''
			THEN  
				[dbo].[fnARFormatCustomerAddress](
					DEFAULT
					,DEFAULT 
					,DEFAULT 
					,FromLoc.strAddress
					,FromLoc.strCity
					,FromLoc.strStateProvince
					,FromLoc.strZipPostalCode
					,FromLoc.strCountry
					,DEFAULT 
					,DEFAULT 
				) COLLATE Latin1_General_CI_AS
			ELSE
				[dbo].[fnARFormatCustomerAddress](
					DEFAULT
					,DEFAULT 
					,DEFAULT 
					,FromStorageVendor.strAddress
					,FromStorageVendor.strCity
					,DEFAULT
					,FromStorageVendor.strZipCode
					,FromStorageVendor.strCountry
					,DEFAULT 
					,DEFAULT 
				) COLLATE Latin1_General_CI_AS
			END
		,strTransferToAddress = CASE WHEN 
				ISNULL(ToStorageLoc.strSubLocationName, '') = ''
			THEN  
				[dbo].[fnARFormatCustomerAddress](
					DEFAULT
					,DEFAULT 
					,DEFAULT 
					,ToLoc.strAddress
					,ToLoc.strCity
					,ToLoc.strStateProvince
					,ToLoc.strZipPostalCode
					,ToLoc.strCountry
					,DEFAULT 
					,DEFAULT 
				) COLLATE Latin1_General_CI_AS
			ELSE
				[dbo].[fnARFormatCustomerAddress](
					DEFAULT
					,DEFAULT 
					,DEFAULT 
					,ToStorageVendor.strAddress
					,ToStorageVendor.strCity
					,DEFAULT
					,ToStorageVendor.strZipCode
					,ToStorageVendor.strCountry
					,DEFAULT 
					,DEFAULT 
				) COLLATE Latin1_General_CI_AS
			END
		,strPeriodOfDispatch = CONVERT(VARCHAR(20),L.dtmStartDate,101) + ' - ' + CONVERT(VARCHAR(20),L.dtmEndDate,101)
		,CTE.strEntityName AS strShipVia
		,strDescription = L.strComments
		,ICI.strItemNo
		,ICI.strDescription AS strItemDescription
		,LDL.strLotNumber
		,LD.dblQuantity
		,LD.dblNet
		,L.intTransportationMode
		,LDL.strWarehouseRefNo
		,strHaulerShippingLine = (CASE WHEN L.intTransportationMode = 1 THEN LLD.strHauler
										WHEN L.intTransportationMode = 2 THEN LLD.strShippingLine
										ELSE NULL END)
		,strServContTruckNum = (CASE WHEN L.intTransportationMode = 1 THEN LLD.strTruckNo
										WHEN L.intTransportationMode = 2 THEN LLD.strServiceContractNumber
										ELSE NULL END)
		,L.strLoadNumber
		,strQtyUOM = QtyUOM.strUnitMeasure
		,LD.dblGross
		,strWeightUOM = WeightUOM.strUnitMeasure
	FROM tblLGLoadDetail LD 
	LEFT JOIN tblLGLoad L ON L.intLoadId = @intLoadId
	OUTER APPLY
		(SELECT TOP 1 * FROM tblLGLoadWarehouse WHERE intLoadId = @intLoadId) LW
	LEFT JOIN tblSMCompanyLocation FromLoc ON FromLoc.intCompanyLocationId = LD.intPCompanyLocationId
	LEFT JOIN tblSMCompanyLocation ToLoc ON ToLoc.intCompanyLocationId = LD.intSCompanyLocationId
	LEFT JOIN vyuCTEntity CTE ON CTE.intEntityId = LW.intHaulerEntityId AND CTE.strEntityType = 'Ship Via' 
	LEFT JOIN vyuICGetCompactItem ICI ON ICI.intItemId = LD.intItemId
	LEFT JOIN vyuLGLoadDetailLotsView LDL ON LDL.intLoadId = @intLoadId AND LD.intLoadDetailId = LDL.intLoadDetailId
	LEFT JOIN vyuLGGetLoadData LLD ON LLD.intLoadId = @intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation FromStorageLoc ON LD.intPSubLocationId = FromStorageLoc.intCompanyLocationSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation ToStorageLoc ON LD.intSSubLocationId = ToStorageLoc.intCompanyLocationSubLocationId	
	LEFT JOIN tblEMEntityLocation FromStorageVendor ON FromStorageVendor.intEntityId = FromStorageLoc.intVendorId AND FromStorageVendor.ysnDefaultLocation = 1 
	LEFT JOIN tblEMEntityLocation ToStorageVendor ON ToStorageVendor.intEntityId = ToStorageLoc.intVendorId AND ToStorageVendor.ysnDefaultLocation = 1 
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure QtyUOM ON QtyUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	WHERE LD.intLoadId = @intLoadId
END