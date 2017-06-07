CREATE PROCEDURE [dbo].[uspLGGetLoadMailMessage]
		@strLoadNumber NVARCHAR(MAX),
		@strMailMessage NVARCHAR(MAX) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE @strLoadNumber NVARCHAR(MAX) = '1433'
--DECLARE @strMailMessage NVARCHAR(MAX)

DECLARE @strCompanyName NVARCHAR(MAX), @strCompanyAddress NVARCHAR(MAX), @strCompanyCountry NVARCHAR(MAX), @strCompanyCity NVARCHAR(MAX), @strCompanyState NVARCHAR(MAX), @strCompanyZip NVARCHAR(MAX)
DECLARE @intPurchaseSale INT
DECLARE @strEquipmentType NVARCHAR(MAX), @strComments NVARCHAR(MAX), @strSupplierLoadNo NVARCHAR(MAX), @strCustomerReferenceNo NVARCHAR(MAX) 
DECLARE @strHauler NVARCHAR(MAX), @strHaulerAddress NVARCHAR(MAX), @strHaulerCity NVARCHAR(MAX), @strHaulerCountry NVARCHAR(MAX), @strHaulerState NVARCHAR(MAX), @strHaulerZip NVARCHAR(MAX), @strHaulerPhone NVARCHAR(MAX)
DECLARE @strDriver NVARCHAR(MAX), @strDispatcher NVARCHAR(MAX), @strTrailerNo1 NVARCHAR(MAX), @strTrailerNo2 NVARCHAR(MAX), @strTrailerNo3 NVARCHAR(MAX), @strTruckNo NVARCHAR(MAX)
DECLARE @dtmScheduledDate DATETIME, @dtmDispatchedDate DATETIME

DECLARE @incval INT, @total INT
DECLARE @LoadDetailTable TABLE
    (
		intId INT IDENTITY PRIMARY KEY CLUSTERED,
		strVendor NVARCHAR(MAX),
		strShipFrom NVARCHAR(MAX),
		strShipFromAddress NVARCHAR(MAX),
		strShipFromCity NVARCHAR(MAX),
		strShipFromCountry NVARCHAR(MAX),
		strShipFromState NVARCHAR(MAX),
		strShipFromZipCode NVARCHAR(MAX),
		strPLocationName NVARCHAR(MAX),
		strPLocationAddress NVARCHAR(MAX),
		strPLocationCity NVARCHAR(MAX),
		strPLocationCountry NVARCHAR(MAX),
		strPLocationState NVARCHAR(MAX),
		strPLocationZipCode NVARCHAR(MAX),
		strCustomer NVARCHAR(MAX),
		strShipTo NVARCHAR(MAX),
		strShipToAddress NVARCHAR(MAX),
		strShipToCity NVARCHAR(MAX),
		strShipToCountry NVARCHAR(MAX),
		strShipToState NVARCHAR(MAX),
		strShipToZipCode NVARCHAR(MAX),
		strSLocationName NVARCHAR(MAX),
		strSLocationAddress NVARCHAR(MAX),
		strSLocationCity NVARCHAR(MAX),
		strSLocationCountry NVARCHAR(MAX),
		strSLocationState NVARCHAR(MAX),
		strSLocationZipCode NVARCHAR(MAX),
		strScheduleInfoMsg NVARCHAR(MAX),
		ysnPrintScheduleInfo BIT,
		strLoadDirectionMsg NVARCHAR(MAX),
		ysnPrintLoadDirections BIT,
		strQuantity NVARCHAR(MAX),
		strItemNo NVARCHAR(MAX),
		strItemUOM NVARCHAR(MAX)
	)

DECLARE @strOriginName NVARCHAR(MAX), @strOriginLocationName NVARCHAR(MAX), @strOriginAddress NVARCHAR(MAX), @strOriginCity NVARCHAR(MAX), @strOriginCountry NVARCHAR(MAX), @strOriginState NVARCHAR(MAX), @strOriginZipCode NVARCHAR(MAX), @strOriginMapLink NVARCHAR(MAX) 
DECLARE @strDestinationName NVARCHAR(MAX), @strDestinationLocationName NVARCHAR(MAX), @strDestinationAddress NVARCHAR(MAX), @strDestinationCity NVARCHAR(MAX), @strDestinationCountry NVARCHAR(MAX), @strDestinationState NVARCHAR(MAX), @strDestinationZipCode NVARCHAR(MAX), @strDestinationMapLink NVARCHAR(MAX) 
DECLARE @strItemNo NVARCHAR(MAX), @strItemUOM NVARCHAR(MAX), @strQuantity NVARCHAR(MAX), @strVendor NVARCHAR(MAX), @strCustomer NVARCHAR(MAX), @strScheduleInfo NVARCHAR(MAX), @strLoadDirections NVARCHAR(MAX)

BEGIN

	SELECT DISTINCT Top(1)
		@intPurchaseSale = L.intPurchaseSale,
		@strCompanyName = (SELECT TOP(1) C.strCompanyName FROM tblSMCompanySetup C),
		@strCompanyAddress = (SELECT TOP(1) C.strAddress FROM tblSMCompanySetup C),
		@strCompanyCountry = (SELECT TOP(1) C.strCountry FROM tblSMCompanySetup C),
		@strCompanyCity = (SELECT TOP(1) C.strCity FROM tblSMCompanySetup C),
		@strCompanyState = (SELECT TOP(1) C.strState FROM tblSMCompanySetup C),
		@strCompanyZip = (SELECT TOP(1) C.strZip FROM tblSMCompanySetup C),

		@strEquipmentType = L.strEquipmentType,
		@dtmScheduledDate = L.dtmScheduledDate,
		@strComments = L.strComments,
		@strSupplierLoadNo = L.strExternalLoadNumber,
		@strCustomerReferenceNo = L.strCustomerReference,
		
		@strHauler = Hauler.strName,
		@strHaulerAddress = (SELECT EL.strAddress from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCity = (SELECT EL.strCity from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCountry = (SELECT EL.strCountry from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerState = (SELECT EL.strState from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerZip = (SELECT EL.strZipCode from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerPhone = (SELECT EL.strPhone from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),

		@strDriver = Driver.strName,
		@dtmDispatchedDate = L.dtmDispatchedDate,
		@strDispatcher = Dispatcher.strFullName,
		@strTrailerNo1 = L.strTrailerNo1,
		@strTrailerNo2 = L.strTrailerNo2,
		@strTrailerNo3 = L.strTrailerNo3,
		@strTruckNo = L.strTruckNo

	FROM		vyuLGLoadDetailView L
	LEFT JOIN		tblEMEntity				Hauler	On			Hauler.intEntityId = L.intHaulerEntityId
	LEFT JOIN		tblEMEntity				Driver	On			Driver.intEntityId = L.intDriverEntityId
	LEFT JOIN		tblSMUserSecurity	Dispatcher On				Dispatcher.[intEntityId] = L.intDispatcherId
	WHERE L.[strLoadNumber] = @strLoadNumber

	Insert into @LoadDetailTable
		SELECT
			L.strVendor,
			L.strShipFrom,
			L.strShipFromAddress,
			L.strShipFromCity,
			L.strShipFromCountry,
			L.strShipFromState,
			L.strShipFromZipCode,
			L.strPLocationName,
			L.strPLocationAddress,
			L.strPLocationCity,
			L.strPLocationCountry,
			L.strPLocationState,
			L.strPLocationZipCode,
			L.strCustomer,
			L.strShipTo,
			L.strShipToAddress,
			L.strShipToCity,
			L.strShipToCountry,
			L.strShipToState,
			L.strShipToZipCode,
			L.strSLocationName,
			L.strSLocationAddress,
			L.strSLocationCity,
			L.strSLocationCountry,
			L.strSLocationState,
			L.strSLocationZipCode,
			L.strScheduleInfoMsg,
			L.ysnPrintScheduleInfo,
			L.strLoadDirectionMsg,
			L.ysnPrintLoadDirections,
			Convert(NVarchar, Convert(decimal (16, 2), dblQuantity)) as strQuantity,
			L.strItemNo,
			L.strItemUOM	
		FROM vyuLGLoadDetailView L 
		where L.[strLoadNumber] = @strLoadNumber

	SET @strMailMessage =	N'<HTML> <BODY> <TABLE cellpadding=2 cellspacing=1 border=1>' + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Load #: </B> </TD>' +
									'<TD colspan=6>' +  LTRIM(@strLoadNumber) + '</TD>' +
								'</FONT></TR>'

								IF IsNull(@strSupplierLoadNo, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Supplier Load#: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strSupplierLoadNo, '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@strCustomerReferenceNo, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Customer Reference: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strCustomerReferenceNo, '') + '</TD>' +
								'</FONT></TR>'
								END
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Company: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strCompanyName, '') + '<BR>' + IsNull(@strCompanyAddress, '') + '<BR>' + IsNull(@strCompanyCity, '') + ', ' + IsNull(@strCompanyState, '') + ' ' + IsNull(@strCompanyZip, '') + '</TD>' +
								'</FONT></TR>'

								IF IsNull(@dtmScheduledDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Scheduled Date: </B> </TD>' +
									'<TD colspan=6>' +  IsNull(CONVERT(NVARCHAR(20), @dtmScheduledDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@dtmDispatchedDate, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' + 
									'<TD size=210> <B> Dispatch Date: </B> </TD>' +
									'<TD colspan=6>' + IsNull(CONVERT(NVARCHAR(20), @dtmDispatchedDate, 101), '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@strDispatcher, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Dispatcher: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strDispatcher, '') + '</TD>' +
								'</FONT></TR>'
								END
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Driver: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strDriver, '') + '</TD>' +
								'</FONT></TR>'
								IF IsNull(@strHauler, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Hauler: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strHauler, '') + '<BR>' + IsNull(@strHaulerAddress, '') + '<BR>' + IsNull(@strHaulerCity, '') + ', ' + IsNull(@strHaulerState, '') + ' ' + IsNull(@strHaulerZip, '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@strEquipmentType, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Equipment: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strEquipmentType, '') + '</TD>' +
								'</FONT></TR>'
								END
								IF IsNull(@strComments, '') <> ''
								BEGIN
	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Comments: </B> </TD>' +
									'<TD colspan=6>' + IsNull(@strComments, '') + '</TD>' +
								'</FONT></TR>'
								END

	SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD size=210> <B> Origin </B> </TD>' +
									'<TD size=210> <B> Destination </B> </TD>' +
									'<TD size=210> <B> Commodity </B> </TD>' +
									'<TD size=210> <B> Quantity </B> </TD>' +
									'<TD size=210> <B> UOM </B> </TD>' +
									'<TD size=210> <B> Schedule Info </B> </TD>' +
									'<TD size=210> <B> Load Directions </B> </TD>' +
								'</FONT></TR>'

	SELECT @total = count(*) from @LoadDetailTable;
	SET @incval = 1 
	WHILE @incval <= @total 
	BEGIN
		SELECT 
			@strVendor = L1.strVendor
			,@strCustomer = L1.strCustomer
			,@strOriginName = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strVendor
								ELSE
									''
								END
			,@strOriginLocationName = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFrom
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationName
									ELSE
										L1.strSLocationName
									END
								END
			,@strOriginAddress = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFromAddress
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationAddress
									ELSE
										L1.strSLocationAddress
									END
								END
			,@strOriginCity = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFromCity
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationCity
									ELSE
										L1.strSLocationCity
									END
								END
			,@strOriginState = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFromState
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationState
									ELSE
										L1.strSLocationState
									END
								END
			,@strOriginZipCode = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFromZipCode
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationZipCode
									ELSE
										L1.strSLocationZipCode
									END
								END
			,@strDestinationName = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strCustomer
								ELSE
									''
								END
			,@strDestinationLocationName = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipTo
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationName
									ELSE
										L1.strPLocationName
									END
								END
			,@strDestinationAddress = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipToAddress
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationAddress
									ELSE
										L1.strPLocationAddress
									END
								END
			,@strDestinationCity = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipToCity
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationCity
									ELSE
										L1.strPLocationCity
									END
								END
			,@strDestinationState = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipToState
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationState
									ELSE
										L1.strPLocationState
									END
								END
			,@strDestinationZipCode = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipToZipCode
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationZipCode
									ELSE
										L1.strPLocationZipCode
									END
								END
			,@strItemNo = L1.strItemNo
			,@strQuantity = L1.strQuantity
			,@strItemUOM = L1.strItemUOM
			,@strScheduleInfo = CASE WHEN L1.ysnPrintScheduleInfo = 1 THEN
										L1.strScheduleInfoMsg
									ELSE
										''
									END
			,@strLoadDirections = CASE WHEN L1.ysnPrintLoadDirections = 1 THEN
										L1.strLoadDirectionMsg
									ELSE
										''
									END
		FROM @LoadDetailTable L1 where L1.intId = @incval

-- Origin Map Link
		SET @strOriginMapLink = 'http://maps.google.com/maps?q='
		IF IsNull(@strOriginAddress, '') <> ''
		BEGIN
			SET @strOriginMapLink =	@strOriginMapLink + REPLACE(REPLACE(@strOriginAddress, ' ', '+'), Char(10), '+')
		END
		IF IsNull(@strOriginCity, '') <> ''
		BEGIN
			SET @strOriginMapLink =	@strOriginMapLink + '+' + @strOriginCity
		END
		IF IsNull(@strOriginState, '') <> ''
		BEGIN
			SET @strOriginMapLink =	@strOriginMapLink + '+' + @strOriginState
		END
		IF IsNull(@strOriginZipCode, '') <> ''
		BEGIN
			SET @strOriginMapLink =	@strOriginMapLink + '+' + @strOriginZipCode
		END
		IF IsNull(@strOriginCountry, '') <> ''
		BEGIN
			SET @strOriginMapLink =	@strOriginMapLink + '+' + @strOriginCountry
		END

-- Destination Map Link
		SET @strDestinationMapLink = 'http://maps.google.com/maps?q='
		IF IsNull(@strDestinationAddress, '') <> ''
		BEGIN
			SET @strDestinationMapLink =	@strDestinationMapLink + REPLACE(REPLACE(@strDestinationAddress, ' ', '+'), Char(10), '+')
		END
		IF IsNull(@strDestinationCity, '') <> ''
		BEGIN
			SET @strDestinationMapLink =	@strDestinationMapLink + '+' + @strDestinationCity
		END
		IF IsNull(@strDestinationState, '') <> ''
		BEGIN
			SET @strDestinationMapLink =	@strDestinationMapLink + '+' + @strDestinationState
		END
		IF IsNull(@strDestinationZipCode, '') <> ''
		BEGIN
			SET @strDestinationMapLink =	@strDestinationMapLink + '+' + @strDestinationZipCode
		END
		IF IsNull(@strDestinationCountry, '') <> ''
		BEGIN
			SET @strDestinationMapLink =	@strDestinationMapLink + '+' + @strDestinationCountry
		END

		SET @strMailMessage =	@strMailMessage + 
								'<TR><FONT face=tahoma size=2>' +
									'<TD><B>' + IsNull(@strOriginName, '') + '</B><BR>' + IsNull(@strOriginLocationName, '') + '<BR><a href="' + @strOriginMapLink + '">' + IsNull(@strOriginAddress, '') + '</a><BR>' + IsNull(@strOriginCity, '') + ', ' + IsNull(@strOriginState, '') + ' ' + IsNull(@strOriginZipCode, '') + '</TD>' +
									'<TD><B>' + IsNull(@strDestinationName, '') + '</B><BR>' + IsNull(@strDestinationLocationName, '') + '<BR><a href="' + @strDestinationMapLink + '">' + IsNull(@strDestinationAddress, '') + '</a><BR>' + IsNull(@strDestinationCity, '') + ', ' + IsNull(@strDestinationState, '') + ' ' + IsNull(@strDestinationZipCode, '') + '</TD>' +
									'<TD>' + IsNull(@strItemNo, '') + '</TD>' +
									'<TD>' + IsNull(@strQuantity, '') + '</TD>' +
									'<TD>' + IsNull(@strItemUOM, '') + '</TD>' +
									'<TD>' + IsNull(@strScheduleInfo, '') + '</TD>' +
									'<TD>' + IsNull(@strLoadDirections, '') + '</TD>' +
								'</FONT></TR>'
		SET @incval = @incval + 1
	END

	SET @strMailMessage =	@strMailMessage + 
							'</TABLE> </BODY> </HTML>'

--SELECT '16', @strMailMessage
END