CREATE PROCEDURE [dbo].[uspLGGetLoadMailMessage]
		@intLoadNumber INT,
		@strMailMessage NVARCHAR(MAX) OUTPUT
AS
--DECLARE @intLoadNumber INT = 1354
--DECLARE @strMailMessage NVARCHAR(MAX)
DECLARE @intPLoadId INT
DECLARE @intPEntityId INT
DECLARE @intPEntityLocationId INT
DECLARE @intSLoadId INT
DECLARE @intSEntityId INT
DECLARE @intSEntityLocationId INT
DECLARE @strCompanyName NVARCHAR(MAX), @strCompanyAddress NVARCHAR(MAX), @strCompanyCountry NVARCHAR(MAX), @strCompanyCity NVARCHAR(MAX), @strCompanyState NVARCHAR(MAX), @strCompanyZip NVARCHAR(MAX)
DECLARE @strLocationName NVARCHAR(MAX), @strLocationAddress NVARCHAR(MAX), @strLocationCity NVARCHAR(MAX), @strLocationCountry NVARCHAR(MAX), @strLocationZipCode NVARCHAR(MAX), @strLocationPhone NVARCHAR(MAX)
DECLARE @strLocationFax NVARCHAR(MAX), @strLocationMail NVARCHAR(MAX), @strItemNo NVARCHAR(MAX), @strDescription NVARCHAR(MAX), @strUnitMeasure NVARCHAR(MAX), @strEquipmentType NVARCHAR(MAX)
DECLARE @strVendorReference NVARCHAR(MAX), @strCustomerReference NVARCHAR(MAX), @strInboundComments NVARCHAR(MAX), @strOutboundComments NVARCHAR(MAX), @strPCustomerContract NVARCHAR(MAX), @strSCustomerContract NVARCHAR(MAX)
DECLARE @strSupplierLoadNumber NVARCHAR(MAX), @strVendorName NVARCHAR(MAX), @strVendorNo NVARCHAR(MAX), @strVendorEmail NVARCHAR(MAX), @strVendorFax NVARCHAR(MAX), @strVendorMobile NVARCHAR(MAX), @strVendorPhone NVARCHAR(MAX)
DECLARE @strVendorLocationName NVARCHAR(MAX), @strVendorAddress NVARCHAR(MAX), @strVendorCity NVARCHAR(MAX), @strVendorCountry NVARCHAR(MAX), @strVendorState NVARCHAR(MAX), @strVendorZipCode NVARCHAR(MAX)
DECLARE @strCustomerName NVARCHAR(MAX), @strCustomerNo NVARCHAR(MAX), @strCustomerEmail NVARCHAR(MAX), @strCustomerFax NVARCHAR(MAX), @strCustomerMobile NVARCHAR(MAX), @strCustomerPhone NVARCHAR(MAX)
DECLARE @strCustomerLocationName NVARCHAR(MAX), @strCustomerAddress NVARCHAR(MAX), @strCustomerCity NVARCHAR(MAX), @strCustomerCountry NVARCHAR(MAX), @strCustomerState NVARCHAR(MAX), @strCustomerZipCode NVARCHAR(MAX)
DECLARE @strHauler NVARCHAR(MAX), @strHaulerAddress NVARCHAR(MAX), @strHaulerCity NVARCHAR(MAX), @strHaulerCountry NVARCHAR(MAX), @strHaulerState NVARCHAR(MAX), @strHaulerZip NVARCHAR(MAX), @strHaulerPhone NVARCHAR(MAX)
DECLARE @strDriver NVARCHAR(MAX), @strDispatcher NVARCHAR(MAX), @strTrailerNo1 NVARCHAR(MAX), @strTrailerNo2 NVARCHAR(MAX), @strTrailerNo3 NVARCHAR(MAX), @strTruckNo NVARCHAR(MAX)
DECLARE @dblQuantity NUMERIC(18, 6)
DECLARE @dtmPickupDate DATETIME, @dtmDeliveryDate DATETIME, @dtmDispatchedDate DATETIME
BEGIN

	SELECT TOP(1) @intPLoadId = LP.intLoadId, @intPEntityId = LP.intEntityId, @intPEntityLocationId = LP.intEntityLocationId FROM tblLGLoad LP where LP.intLoadNumber=@intLoadNumber and intPurchaseSale=1
	SELECT TOP(1) @intSLoadId = LS.intLoadId, @intSEntityId = LS.intEntityId, @intSEntityLocationId = LS.intEntityLocationId FROM tblLGLoad LS where LS.intLoadNumber=@intLoadNumber and intPurchaseSale=2	

	SELECT DISTINCT
		@strCompanyName = (SELECT TOP(1) C.strCompanyName FROM tblSMCompanySetup C),
		@strCompanyAddress = (SELECT TOP(1) C.strAddress FROM tblSMCompanySetup C),
		@strCompanyCountry = (SELECT TOP(1) C.strCountry FROM tblSMCompanySetup C),
		@strCompanyCity = (SELECT TOP(1) C.strCity FROM tblSMCompanySetup C),
		@strCompanyState = (SELECT TOP(1) C.strState FROM tblSMCompanySetup C),
		@strCompanyZip = (SELECT TOP(1) C.strZip FROM tblSMCompanySetup C),
		@strLocationName = CL.strLocationName,
		@strLocationAddress = CL.strAddress,
		@strLocationCity = CL.strCity,
		@strLocationCountry = CL.strCountry,
		@strLocationZipCode = CL.strZipPostalCode,
		@strLocationPhone = CL.strPhone,
		@strLocationFax = CL.strFax,
		@strLocationMail = CL.strEmail,
		@strItemNo = Item.strItemNo,
		@strDescription = Item.strDescription,
		@dblQuantity = L.dblQuantity,
		@strUnitMeasure = UOM.strUnitMeasure,
		@strEquipmentType = Equipment.strEquipmentType,

		@dtmPickupDate = (SELECT L1.dtmScheduledDate FROM tblLGLoad L1 where L1.intLoadId = @intPLoadId),
		@dtmDeliveryDate = (SELECT L1.dtmScheduledDate FROM tblLGLoad L1 where L1.intLoadId = @intSLoadId),
		@strVendorReference = (SELECT L1.strCustomerReference FROM tblLGLoad L1 where L1.intLoadId = @intPLoadId),
		@strCustomerReference = (SELECT L1.strCustomerReference FROM tblLGLoad L1 where L1.intLoadId = @intSLoadId),
		@strInboundComments = (SELECT L1.strComments FROM vyuLGLoadView L1 where L1.intLoadId = @intPLoadId),
		@strOutboundComments = (SELECT L1.strComments FROM vyuLGLoadView L1 where L1.intLoadId = @intSLoadId),

		@strPCustomerContract = (SELECT L1.strCustomerContract FROM vyuLGLoadView L1 where L1.intLoadId = @intPLoadId),
		@strSCustomerContract = (SELECT L1.strCustomerContract FROM vyuLGLoadView L1 where L1.intLoadId = @intSLoadId),

		@strSupplierLoadNumber = (SELECT L1.strExternalLoadNumber FROM vyuLGLoadView L1 where L1.intLoadId = @intPLoadId),

		@strVendorName = (SELECT E.strName FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		@strVendorNo = (SELECT E.strEntityNo FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		@strVendorEmail = (SELECT E.strEmail FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		@strVendorFax = (SELECT E.strFax FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		@strVendorMobile = (SELECT E.strMobile FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		@strVendorPhone = (SELECT E.strPhone FROM tblEntity E WHERE E.intEntityId = @intPEntityId),
		
		@strVendorLocationName = (SELECT EL.strLocationName FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),
		@strVendorAddress = (SELECT EL.strAddress FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),
		@strVendorCity = (SELECT EL.strCity  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),
		@strVendorCountry = (SELECT EL.strCountry  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),
		@strVendorState = (SELECT EL.strState  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),
		@strVendorZipCode = (SELECT EL.strZipCode  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId),

		@strCustomerName = (SELECT E.strName FROM tblEntity E WHERE E.intEntityId = @intSEntityId),
		@strCustomerNo = (SELECT E.strEntityNo FROM tblEntity E WHERE E.intEntityId = @intSEntityId),
		@strCustomerEmail = (SELECT E.strEmail FROM tblEntity E WHERE E.intEntityId = @intSEntityId),
		@strCustomerFax = (SELECT E.strFax FROM tblEntity E WHERE E.intEntityId = @intSEntityId),
		@strCustomerMobile = (SELECT E.strMobile FROM tblEntity E WHERE E.intEntityId = @intSEntityId),
		@strCustomerPhone = (SELECT E.strPhone FROM tblEntity E WHERE E.intEntityId = @intSEntityId),

		@strCustomerLocationName = (SELECT EL.strLocationName FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		@strCustomerAddress = (SELECT EL.strAddress FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		@strCustomerCity = (SELECT EL.strCity FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		@strCustomerCountry = (SELECT EL.strCountry FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		@strCustomerState = (SELECT EL.strState FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		@strCustomerZipCode = (SELECT EL.strZipCode FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId),
		
		@strHauler = Hauler.strName,
		@strHaulerAddress = (SELECT EL.strAddress from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCity = (SELECT EL.strCity from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCountry = (SELECT EL.strCountry from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerState = (SELECT EL.strState from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerZip = (SELECT EL.strZipCode from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerPhone = (SELECT EL.strPhone from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),

		@strDriver = Driver.strName,
		@dtmDispatchedDate = L.dtmDispatchedDate,
		@strDispatcher = Dispatcher.strFullName,
		@strTrailerNo1 = L.strTrailerNo1,
		@strTrailerNo2 = L.strTrailerNo2,
		@strTrailerNo3 = L.strTrailerNo3,
		@strTruckNo = L.strTruckNo

	FROM		tblLGLoad L
	JOIN		tblSMCompanyLocation	CL ON				CL.intCompanyLocationId = L.intCompanyLocationId AND L.intLoadNumber = @intLoadNumber
	LEFT JOIN		tblICItem				Item ON				Item.intItemId = L.intItemId
	LEFT JOIN		tblICUnitMeasure		UOM	ON				UOM.intUnitMeasureId = L.intUnitMeasureId
	LEFT JOIN		tblEntity				E	On				E.intEntityId = L.intEntityId
	LEFT JOIN		tblEntityLocation		EL	On				EL.intEntityLocationId = L.intEntityLocationId
	LEFT JOIN		tblEntity				Hauler	On			Hauler.intEntityId = L.intHaulerEntityId
	LEFT JOIN		tblEntity				Driver	On			Driver.intEntityId = L.intDriverEntityId
	LEFT JOIN	tblLGEquipmentType		Equipment On		Equipment.intEquipmentTypeId = L.intEquipmentTypeId
	LEFT JOIN	tblSMUserSecurity	Dispatcher On					Dispatcher.[intEntityUserSecurityId] = L.intDispatcherId

	SET @strMailMessage =	N'<HTML> <BODY> <TABLE cellpadding=2 border=1 >' + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Load #: </B> </TD>' +
									'<TD>' +  LTRIM(@intLoadNumber) + '</TD>' +
								'</FONT></TR>'
								IF IsNull(@strSupplierLoadNumber, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Supplier Load#: </B> </TD>' +
									'<TD>' + IsNull(@strSupplierLoadNumber, '') + '</TD>' +
								'</FONT></TR>'
								END
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Company: </B> </TD>' +
									'<TD>' + IsNull(@strCompanyName, '') + '<BR>' + IsNull(@strCompanyAddress, '') + '<BR>' + IsNull(@strCompanyCity, '') + ', ' + IsNull(@strCompanyState, '') + ' ' + IsNull(@strCompanyZip, '') + '</TD>' +
								'</FONT></TR>'

								IF IsNull(@strVendorName, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Vendor: </B> </TD>' +
									'<TD>' + IsNull(@strVendorName, '') + '<BR>' + IsNull(@strVendorLocationName, '') + '<BR>' + IsNull(@strVendorAddress, '') + '<BR>' + IsNull(@strVendorCity, '') + ', ' + IsNull(@strVendorState, '') + ' ' + IsNull(@strVendorZipCode, '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@strCustomerName, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Customer: </B> </TD>' +
									'<TD>' + IsNull(@strCustomerName, '') + '<BR>' + IsNull(@strCustomerLocationName, '') + '<BR>' + IsNull(@strCustomerAddress, '') + '<BR>' + IsNull(@strCustomerCity, '') + ', ' + IsNull(@strCustomerState, '') + ' ' + IsNull(@strCustomerZipCode, '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@dtmPickupDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Pickup Date: </B> </TD>' +
									'<TD>' +  IsNull(CONVERT(NVARCHAR(20), @dtmPickupDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@dtmDeliveryDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Delivery Date: </B> </TD>' +
									'<TD>' + IsNull(CONVERT(NVARCHAR(20), @dtmDeliveryDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@dtmDispatchedDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' + 
									'<TD size=210> <B> Dispatch Date: </B> </TD>' +
									'<TD>' + IsNull(CONVERT(NVARCHAR(20), @dtmDispatchedDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@strDispatcher, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Dispatcher: </B> </TD>' +
									'<TD>' + IsNull(@strDispatcher, '') + '</TD>' +
								'</FONT></TR>'
								END
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Units: </B> </TD>' +
									'<TD>' + IsNull(LTRIM(@dblQuantity), '') + ' ' +IsNull(@strUnitMeasure, '') + '</TD>' +
								'</FONT></TR>' +
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Commodity: </B> </TD>' +
									'<TD>' + IsNull(@strDescription, '') + '</TD>' +
								'</FONT></TR>' +
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Driver: </B> </TD>' +
									'<TD>' + IsNull(@strDriver, '') + '</TD>' +
								'</FONT></TR>'

								IF IsNull(@strHauler, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Hauler: </B> </TD>' +
									'<TD>' + IsNull(@strHauler, '') + '<BR>' + IsNull(@strHaulerAddress, '') + '<BR>' + IsNull(@strHaulerCity, '') + ', ' + IsNull(@strHaulerState, '') + ' ' + IsNull(@strHaulerZip, '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@strEquipmentType, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Equipment: </B> </TD>' +
									'<TD>' + IsNull(@strEquipmentType, '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@strInboundComments, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Inbound Comments: </B> </TD>' +
									'<TD>' + IsNull(@strInboundComments, '') + '</TD>' +
								'</FONT></TR>'
								END

								IF IsNull(@strOutboundComments, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Outbound Comments: </B> </TD>' +
									'<TD>' + IsNull(@strOutboundComments, '') + '</TD>' +
								'</FONT></TR>'
								END

	SET @strMailMessage =	@strMailMessage + 
							'</TABLE> </BODY> </HTML>'
END
