CREATE PROCEDURE [dbo].[uspLGGetLoadMailMessage]
		@intLoadNumber INT,
		@strMailMessage NVARCHAR(MAX) OUTPUT
AS
--DECLARE @intLoadNumber INT = 1381
--DECLARE @strMailMessage NVARCHAR(MAX)

DECLARE @intPLoadId INT
DECLARE @intPEntityId INT
DECLARE @intPEntityLocationId INT
DECLARE @intSLoadId INT
DECLARE @intSEntityId INT
DECLARE @intSEntityLocationId INT
DECLARE @intPCompanyLocationId INT
DECLARE @intSCompanyLocationId INT
DECLARE @ysnDirectShip BIT
DECLARE @strCompanyName NVARCHAR(MAX), @strCompanyAddress NVARCHAR(MAX), @strCompanyCountry NVARCHAR(MAX), @strCompanyCity NVARCHAR(MAX), @strCompanyState NVARCHAR(MAX), @strCompanyZip NVARCHAR(MAX)
DECLARE @strPLocationName NVARCHAR(MAX), @strPLocationAddress NVARCHAR(MAX), @strPLocationCity NVARCHAR(MAX), @strPLocationCountry NVARCHAR(MAX), @strPLocationState NVARCHAR(MAX), @strPLocationZipCode NVARCHAR(MAX), @strPLocationPhone NVARCHAR(MAX), @strPLocationFax NVARCHAR(MAX), @strPLocationMail NVARCHAR(MAX), @strPLocationFirstLineAddress NVARCHAR(MAX), @strPLocationMapLink NVARCHAR(MAX) 
DECLARE @strSLocationName NVARCHAR(MAX), @strSLocationAddress NVARCHAR(MAX), @strSLocationCity NVARCHAR(MAX), @strSLocationCountry NVARCHAR(MAX), @strSLocationState NVARCHAR(MAX), @strSLocationZipCode NVARCHAR(MAX), @strSLocationPhone NVARCHAR(MAX), @strSLocationFax NVARCHAR(MAX), @strSLocationMail NVARCHAR(MAX), @strSLocationFirstLineAddress NVARCHAR(MAX), @strSLocationMapLink NVARCHAR(MAX) 
DECLARE @strItemNo NVARCHAR(MAX), @strUnitMeasure NVARCHAR(MAX), @strEquipmentType NVARCHAR(MAX)
DECLARE @strVendorReference NVARCHAR(MAX), @strCustomerReference NVARCHAR(MAX), @strInboundComments NVARCHAR(MAX), @strOutboundComments NVARCHAR(MAX), @strPCustomerContract NVARCHAR(MAX), @strSCustomerContract NVARCHAR(MAX)
DECLARE @strSupplierLoadNumber NVARCHAR(MAX), @strVendorName NVARCHAR(MAX), @strVendorNo NVARCHAR(MAX), @strVendorEmail NVARCHAR(MAX), @strVendorFax NVARCHAR(MAX), @strVendorMobile NVARCHAR(MAX), @strVendorPhone NVARCHAR(MAX)
DECLARE @strVendorLocationName NVARCHAR(MAX), @strVendorAddress NVARCHAR(MAX), @strVendorFirstLineAddress NVARCHAR(MAX), @strVendorMapLink NVARCHAR(MAX), @strVendorCity NVARCHAR(MAX), @strVendorCountry NVARCHAR(MAX), @strVendorState NVARCHAR(MAX), @strVendorZipCode NVARCHAR(MAX)
DECLARE @strCustomerName NVARCHAR(MAX), @strCustomerNo NVARCHAR(MAX), @strCustomerEmail NVARCHAR(MAX), @strCustomerFax NVARCHAR(MAX), @strCustomerMobile NVARCHAR(MAX), @strCustomerPhone NVARCHAR(MAX)
DECLARE @strCustomerLocationName NVARCHAR(MAX), @strCustomerAddress NVARCHAR(MAX), @strCustomerFirstLineAddress NVARCHAR(MAX), @strCustomerMapLink NVARCHAR(MAX), @strCustomerCity NVARCHAR(MAX), @strCustomerCountry NVARCHAR(MAX), @strCustomerState NVARCHAR(MAX), @strCustomerZipCode NVARCHAR(MAX)
DECLARE @strHauler NVARCHAR(MAX), @strHaulerAddress NVARCHAR(MAX), @strHaulerCity NVARCHAR(MAX), @strHaulerCountry NVARCHAR(MAX), @strHaulerState NVARCHAR(MAX), @strHaulerZip NVARCHAR(MAX), @strHaulerPhone NVARCHAR(MAX)
DECLARE @strDriver NVARCHAR(MAX), @strDispatcher NVARCHAR(MAX), @strTrailerNo1 NVARCHAR(MAX), @strTrailerNo2 NVARCHAR(MAX), @strTrailerNo3 NVARCHAR(MAX), @strTruckNo NVARCHAR(MAX)
DECLARE @dblQuantity NUMERIC(18, 6)
DECLARE @dtmPickupDate DATETIME, @dtmDeliveryDate DATETIME, @dtmDispatchedDate DATETIME
BEGIN

	SELECT TOP(1) @intPLoadId = LP.intLoadId, @intPEntityId = LP.intEntityId, @intPEntityLocationId = LP.intEntityLocationId, @intPCompanyLocationId = LP.intCompanyLocationId FROM tblLGLoad LP where LP.intLoadNumber=@intLoadNumber and intPurchaseSale=1
	SELECT TOP(1) @intSLoadId = LS.intLoadId, @intSEntityId = LS.intEntityId, @intSEntityLocationId = LS.intEntityLocationId, @intSCompanyLocationId = LS.intCompanyLocationId FROM tblLGLoad LS where LS.intLoadNumber=@intLoadNumber and intPurchaseSale=2	

	SELECT DISTINCT
		@strCompanyName = (SELECT TOP(1) C.strCompanyName FROM tblSMCompanySetup C),
		@strCompanyAddress = (SELECT TOP(1) C.strAddress FROM tblSMCompanySetup C),
		@strCompanyCountry = (SELECT TOP(1) C.strCountry FROM tblSMCompanySetup C),
		@strCompanyCity = (SELECT TOP(1) C.strCity FROM tblSMCompanySetup C),
		@strCompanyState = (SELECT TOP(1) C.strState FROM tblSMCompanySetup C),
		@strCompanyZip = (SELECT TOP(1) C.strZip FROM tblSMCompanySetup C),

		@strPLocationName = (SELECT CL.strLocationName FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationAddress = (SELECT CL.strAddress FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationCity = (SELECT CL.strCity  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationCountry = (SELECT CL.strCountry  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationState = (SELECT CL.strStateProvince  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationZipCode = (SELECT CL.strZipPostalCode  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationMail = (SELECT CL.strEmail FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationFax = (SELECT CL.strFax FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),
		@strPLocationPhone = (SELECT CL.strPhone FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intPCompanyLocationId),

		@strSLocationName = (SELECT CL.strLocationName FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationAddress = (SELECT CL.strAddress FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationCity = (SELECT CL.strCity  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationCountry = (SELECT CL.strCountry  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationState = (SELECT CL.strStateProvince  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationZipCode = (SELECT CL.strZipPostalCode  FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationMail = (SELECT CL.strEmail FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationFax = (SELECT CL.strFax FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),
		@strSLocationPhone = (SELECT CL.strPhone FROM tblSMCompanyLocation CL WHERE CL.intCompanyLocationId = @intSCompanyLocationId),		

		@ysnDirectShip = L.ysnDirectShip,
		@strItemNo = Item.strDescription,
		@dblQuantity = L.dblQuantity,
		@strUnitMeasure = UOM.strUnitMeasure,
		@strEquipmentType = L.strEquipmentType,

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

	FROM		vyuLGLoadView L
	LEFT JOIN		tblICItem				Item ON				Item.intItemId = L.intItemId
	LEFT JOIN		tblICUnitMeasure		UOM	On				UOM.intUnitMeasureId = L.intUnitMeasureId
	LEFT JOIN		tblEntity				Hauler	On			Hauler.intEntityId = L.intHaulerEntityId
	LEFT JOIN		tblEntity				Driver	On			Driver.intEntityId = L.intDriverEntityId
	LEFT JOIN	tblSMUserSecurity	Dispatcher On				Dispatcher.[intEntityUserSecurityId] = L.intDispatcherId
	WHERE L.intLoadNumber = @intLoadNumber

--	Inbound Load Company Location Map Link
	SET @strPLocationMapLink = 'http://maps.google.com/maps?q='
	IF IsNull(@strPLocationAddress, '') <> ''
	BEGIN
		SET @strPLocationMapLink =	@strPLocationMapLink + REPLACE(REPLACE(@strPLocationAddress, ' ', '+'), Char(10), '+')
	END
	IF IsNull(@strPLocationCity, '') <> ''
	BEGIN
		SET @strPLocationMapLink =	@strPLocationMapLink + '+' + @strPLocationCity
	END
	IF IsNull(@strPLocationState, '') <> ''
	BEGIN
		SET @strPLocationMapLink =	@strPLocationMapLink + '+' + @strPLocationState
	END
	IF IsNull(@strPLocationZipCode, '') <> ''
	BEGIN
		SET @strPLocationMapLink =	@strPLocationMapLink + '+' + @strPLocationZipCode
	END
	IF IsNull(@strPLocationCountry, '') <> ''
	BEGIN
		SET @strPLocationMapLink =	@strPLocationMapLink + '+' + @strPLocationCountry
	END
	
	SET @strPLocationFirstLineAddress = @strPLocationAddress
	IF CHARINDEX(Char(10), @strPLocationAddress) > 0
	BEGIN
		SET @strPLocationFirstLineAddress = SUBSTRING(@strPLocationAddress, 1, CHARINDEX(Char(10), @strPLocationAddress))
	END

--	Outbound Load Company Location Map Link
	SET @strSLocationMapLink = 'http://maps.google.com/maps?q='
	IF IsNull(@strSLocationAddress, '') <> ''
	BEGIN
		SET @strSLocationMapLink =	@strSLocationMapLink + REPLACE(REPLACE(@strSLocationAddress, ' ', '+'), Char(10), '+')
	END
	IF IsNull(@strSLocationCity, '') <> ''
	BEGIN
		SET @strSLocationMapLink =	@strSLocationMapLink + '+' + @strSLocationCity
	END
	IF IsNull(@strSLocationState, '') <> ''
	BEGIN
		SET @strSLocationMapLink =	@strSLocationMapLink + '+' + @strSLocationState
	END
	IF IsNull(@strSLocationZipCode, '') <> ''
	BEGIN
		SET @strSLocationMapLink =	@strSLocationMapLink + '+' + @strSLocationZipCode
	END
	IF IsNull(@strSLocationCountry, '') <> ''
	BEGIN
		SET @strSLocationMapLink =	@strSLocationMapLink + '+' + @strSLocationCountry
	END
	
	SET @strSLocationFirstLineAddress = @strSLocationAddress
	IF CHARINDEX(Char(10), @strSLocationAddress) > 0
	BEGIN
		SET @strSLocationFirstLineAddress = SUBSTRING(@strSLocationAddress, 1, CHARINDEX(Char(10), @strSLocationAddress))
	END

--	Vendor Location Map Link
	SET @strVendorMapLink = 'http://maps.google.com/maps?q='
	IF IsNull(@strVendorAddress, '') <> ''
	BEGIN
		SET @strVendorMapLink =	@strVendorMapLink + REPLACE(REPLACE(@strVendorAddress, ' ', '+'), Char(10), '+')
	END
	IF IsNull(@strVendorCity, '') <> ''
	BEGIN
		SET @strVendorMapLink =	@strVendorMapLink + '+' + @strVendorCity
	END
	IF IsNull(@strVendorState, '') <> ''
	BEGIN
		SET @strVendorMapLink =	@strVendorMapLink + '+' + @strVendorState
	END
	IF IsNull(@strVendorZipCode, '') <> ''
	BEGIN
		SET @strVendorMapLink =	@strVendorMapLink + '+' + @strVendorZipCode
	END
	IF IsNull(@strVendorCountry, '') <> ''
	BEGIN
		SET @strVendorMapLink =	@strVendorMapLink + '+' + @strVendorCountry
	END

	SET @strVendorFirstLineAddress = @strVendorAddress
	IF CHARINDEX(Char(10), @strVendorAddress) > 0
	BEGIN
		SET @strVendorFirstLineAddress = SUBSTRING(@strVendorAddress, 1, CHARINDEX(Char(10), @strVendorAddress))
	END

--	Customer Location Map Link
	SET @strCustomerMapLink = 'http://maps.google.com/maps?q='
	IF IsNull(@strCustomerAddress, '') <> ''
	BEGIN
		SET @strCustomerMapLink =	@strCustomerMapLink + REPLACE(REPLACE(@strCustomerAddress, ' ', '+'), Char(10), '+')
	END
	IF IsNull(@strCustomerCity, '') <> ''
	BEGIN
		SET @strCustomerMapLink =	@strCustomerMapLink + '+' + @strCustomerCity
	END
	IF IsNull(@strCustomerState, '') <> ''
	BEGIN
		SET @strCustomerMapLink =	@strCustomerMapLink + '+' + @strCustomerState
	END
	IF IsNull(@strCustomerZipCode, '') <> ''
	BEGIN
		SET @strCustomerMapLink =	@strCustomerMapLink + '+' + @strCustomerZipCode
	END
	IF IsNull(@strCustomerCountry, '') <> ''
	BEGIN
		SET @strCustomerMapLink =	@strCustomerMapLink + '+' + @strCustomerCountry
	END

	SET @strCustomerFirstLineAddress = @strCustomerAddress
	IF CHARINDEX(Char(10), @strCustomerAddress) > 0
	BEGIN
		SET @strCustomerFirstLineAddress = SUBSTRING(@strCustomerAddress, 1, CHARINDEX(Char(10), @strCustomerAddress))
	END

	SET @strMailMessage =	N'<HTML> <BODY> <TABLE cellpadding=2 border=1 >' + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Load #: </B> </TD>' +
									'<TD>' +  LTRIM(@intLoadNumber) + '</TD>' +
								'</FONT></TR>'
--SELECT '1', @strMailMessage
								IF IsNull(@strSupplierLoadNumber, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Supplier Load#: </B> </TD>' +
									'<TD>' + IsNull(@strSupplierLoadNumber, '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '2', @strMailMessage
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Company: </B> </TD>' +
									'<TD>' + IsNull(@strCompanyName, '') + '<BR>' + IsNull(@strCompanyAddress, '') + '<BR>' + IsNull(@strCompanyCity, '') + ', ' + IsNull(@strCompanyState, '') + ' ' + IsNull(@strCompanyZip, '') + '</TD>' +
								'</FONT></TR>'
--SELECT '3', @strMailMessage
								IF IsNull(@strVendorName, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin: </B> </TD>' +
									'<TD>' + IsNull(@strVendorName, '') + '<BR>' + IsNull(@strVendorLocationName, '') + '<BR>' + IsNull(@strVendorAddress, '') + '<BR>' + IsNull(@strVendorCity, '') + ', ' + IsNull(@strVendorState, '') + ' ' + IsNull(@strVendorZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin Map Link: </B> </TD>' +
									'<TD><a href="' + @strVendorMapLink + '">' + @strVendorFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '4', @strMailMessage
								IF (IsNull(@strVendorName, '') = '') AND (@ysnDirectShip = 1) AND IsNull(@strPLocationName, '') <> '' AND IsNull(@strPLocationAddress, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin: </B> </TD>' +
									'<TD>' + IsNull(@strPLocationName, '') + '<BR>' + IsNull(@strPLocationAddress, '') + '<BR>' + IsNull(@strPLocationCity, '') + ', ' + IsNull(@strPLocationState, '') + ' ' + IsNull(@strPLocationZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin Map Link: </B> </TD>' +
									'<TD><a href="' + @strPLocationMapLink + '">' + @strPLocationFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '5', @strMailMessage
								IF (IsNull(@strVendorName, '') <> '') AND (@ysnDirectShip = 0) AND IsNull(@strPLocationName, '') <> '' AND IsNull(@strPLocationAddress, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination: </B> </TD>' +
									'<TD>' + IsNull(@strPLocationName, '') + '<BR>' + IsNull(@strPLocationAddress, '') + '<BR>' + IsNull(@strPLocationCity, '') + ', ' + IsNull(@strPLocationState, '') + ' ' + IsNull(@strPLocationZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination Map Link: </B> </TD>' +
									'<TD><a href="' + @strPLocationMapLink + '">' + @strPLocationFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '6', @strMailMessage
								IF (IsNull(@strCustomerName, '') <> '') AND (@ysnDirectShip = 0) AND IsNull(@strSLocationName, '') <> '' AND IsNull(@strSLocationAddress, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin: </B> </TD>' +
									'<TD>' + IsNull(@strSLocationName, '') + '<BR>' + IsNull(@strSLocationAddress, '') + '<BR>' + IsNull(@strSLocationCity, '') + ', ' + IsNull(@strSLocationState, '') + ' ' + IsNull(@strSLocationZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin Map Link: </B> </TD>' +
									'<TD><a href="' + @strSLocationMapLink + '">' + @strSLocationFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '7', @strMailMessage
								IF IsNull(@strCustomerName, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination: </B> </TD>' +
									'<TD>' + IsNull(@strCustomerName, '') + '<BR>' + IsNull(@strCustomerLocationName, '') + '<BR>' + IsNull(@strCustomerAddress, '') + '<BR>' + IsNull(@strCustomerCity, '') + ', ' + IsNull(@strCustomerState, '') + ' ' + IsNull(@strCustomerZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination Map Link: </B> </TD>' +
									'<TD><a href="' + @strCustomerMapLink + '">' + @strCustomerFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '8', @strMailMessage, @strCustomerName, @ysnDirectShip
								IF (IsNull(@strCustomerName, '') = '') AND (@ysnDirectShip = 1) AND IsNull(@strSLocationName, '') <> '' AND IsNull(@strSLocationAddress, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination: </B> </TD>' +
									'<TD>' + IsNull(@strSLocationName, '') + '<BR>' + IsNull(@strSLocationAddress, '') + '<BR>' + IsNull(@strSLocationCity, '') + ', ' + IsNull(@strSLocationState, '') + ' ' + IsNull(@strSLocationZipCode, '') + '</TD>' +
								'</FONT></TR>' +

									'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Destination Map Link: </B> </TD>' +
									'<TD><a href="' + @strSLocationMapLink + '">' + @strSLocationFirstLineAddress + '</a></TD>' +
								'</FONT></TR>'
								END
--SELECT '9', @strMailMessage
								IF IsNull(@dtmPickupDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Pickup Date: </B> </TD>' +
									'<TD>' +  IsNull(CONVERT(NVARCHAR(20), @dtmPickupDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '10', @strMailMessage
								IF IsNull(@dtmDeliveryDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Delivery Date: </B> </TD>' +
									'<TD>' + IsNull(CONVERT(NVARCHAR(20), @dtmDeliveryDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '11', @strMailMessage
								IF IsNull(@dtmDispatchedDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' + 
									'<TD size=210> <B> Dispatch Date: </B> </TD>' +
									'<TD>' + IsNull(CONVERT(NVARCHAR(20), @dtmDispatchedDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '12', @strMailMessage

								IF IsNull(@strDispatcher, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Dispatcher: </B> </TD>' +
									'<TD>' + IsNull(@strDispatcher, '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '13', @strMailMessage
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Units: </B> </TD>' +
									'<TD>' + IsNull(LTRIM(@dblQuantity), '') + ' ' +IsNull(@strUnitMeasure, '') + '</TD>' +
								'</FONT></TR>' +
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Commodity: </B> </TD>' +
									'<TD>' + IsNull(@strItemNo, '') + '</TD>' +
								'</FONT></TR>' +
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Driver: </B> </TD>' +
									'<TD>' + IsNull(@strDriver, '') + '</TD>' +
								'</FONT></TR>'
--SELECT '14', @strMailMessage
								IF IsNull(@strHauler, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Hauler: </B> </TD>' +
									'<TD>' + IsNull(@strHauler, '') + '<BR>' + IsNull(@strHaulerAddress, '') + '<BR>' + IsNull(@strHaulerCity, '') + ', ' + IsNull(@strHaulerState, '') + ' ' + IsNull(@strHaulerZip, '') + '</TD>' +
								'</FONT></TR>'
								END
--SELECT '15', @strMailMessage

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

--SELECT '16', @strMailMessage
END
