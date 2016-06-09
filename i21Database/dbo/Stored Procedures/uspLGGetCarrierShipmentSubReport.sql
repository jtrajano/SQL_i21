CREATE PROCEDURE [dbo].[uspLGGetCarrierShipmentSubReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intPurchaseSale INT

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
		strItemUOM NVARCHAR(MAX),
		strOriginFullAddress NVARCHAR(MAX),
		strDestinationFullAddress NVARCHAR(MAX)
	)

DECLARE @strOriginName NVARCHAR(MAX), @strOriginLocationName NVARCHAR(MAX), @strOriginAddress NVARCHAR(MAX), @strOriginCity NVARCHAR(MAX), @strOriginCountry NVARCHAR(MAX), @strOriginState NVARCHAR(MAX), @strOriginZipCode NVARCHAR(MAX)
DECLARE @strDestinationName NVARCHAR(MAX), @strDestinationLocationName NVARCHAR(MAX), @strDestinationAddress NVARCHAR(MAX), @strDestinationCity NVARCHAR(MAX), @strDestinationCountry NVARCHAR(MAX), @strDestinationState NVARCHAR(MAX), @strDestinationZipCode NVARCHAR(MAX)
DECLARE @strItemNo NVARCHAR(MAX), @strItemUOM NVARCHAR(MAX), @strQuantity NVARCHAR(MAX), @strVendor NVARCHAR(MAX), @strCustomer NVARCHAR(MAX), @strScheduleInfo NVARCHAR(MAX), @strLoadDirections NVARCHAR(MAX)

DECLARE @strOriginFullAddress NVARCHAR(MAX), @strDestinationFullAddress NVARCHAR(MAX)
BEGIN
	SELECT DISTINCT Top(1)
		@intPurchaseSale = L.intPurchaseSale
	FROM		vyuLGLoadDetailView L
	WHERE L.[strLoadNumber] = @xmlParam

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
			Convert(NVarchar, Convert(decimal (16, 2), dblQuantity)) + ' - ' + L.strItemUOM as strQuantity,
			L.strItemNo,
			L.strItemUOM,
			'' as strOrignFullAddress,
			'' as strDestinationFullAddress
		FROM vyuLGLoadDetailView L 
		WHERE L.[strLoadNumber] = @xmlParam

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
			,@strOriginCountry = CASE WHEN IsNull(@strVendor, '') <> '' THEN
									L1.strShipFromCountry
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strPLocationName, '') <> '' THEN
										L1.strPLocationCountry
									ELSE
										L1.strSLocationCountry
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
			,@strDestinationCountry = CASE WHEN IsNull(@strCustomer, '') <> '' THEN
									L1.strShipToCountry
								ELSE
									CASE WHEN @intPurchaseSale = 3 AND IsNull(L1.strSLocationName, '') <> '' THEN
										L1.strSLocationCountry
									ELSE
										L1.strPLocationCountry
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

		SET @strOriginFullAddress = CASE WHEN IsNull(@strOriginName, '') <> '' THEN
										LTRIM(RTRIM(@strOriginName)) + ', ' + CHAR(13)+CHAR(10)
									ELSE
										' ' + CHAR(13)+CHAR(10)
									END
		SET @strOriginFullAddress = @strOriginFullAddress + ISNULL(LTRIM(RTRIM(@strOriginLocationName)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strOriginAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strOriginCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strOriginState)) = '' THEN NULL ELSE LTRIM(RTRIM(@strOriginState)) END,'') + 
									ISNULL(' '+CASE WHEN LTRIM(RTRIM(@strOriginZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(@strOriginZipCode)) END,'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(''+CASE WHEN LTRIM(RTRIM(@strOriginCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(@strOriginCountry)) END,'')

		SET @strDestinationFullAddress = CASE WHEN IsNull(@strDestinationName, '') <> '' THEN
										LTRIM(RTRIM(@strDestinationName)) + ', ' + CHAR(13)+CHAR(10)
									ELSE
										' ' + CHAR(13)+CHAR(10)
									END
		SET @strDestinationFullAddress = @strDestinationFullAddress + ISNULL(LTRIM(RTRIM(@strDestinationLocationName)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strDestinationAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strDestinationCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strDestinationState)) = '' THEN NULL ELSE LTRIM(RTRIM(@strDestinationState)) END,'') + 
									ISNULL(' '+CASE WHEN LTRIM(RTRIM(@strDestinationZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(@strDestinationZipCode)) END,'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(''+CASE WHEN LTRIM(RTRIM(@strDestinationCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(@strDestinationCountry)) END,'')

		UPDATE @LoadDetailTable SET strOriginFullAddress = @strOriginFullAddress, strDestinationFullAddress = @strDestinationFullAddress, 
									strScheduleInfoMsg = @strScheduleInfo, strLoadDirectionMsg = @strLoadDirections WHERE intId=@incval

		SET @incval = @incval + 1
	END

	SELECT strOriginFullAddress, strDestinationFullAddress, strQuantity, strItemNo, strItemUOM, strScheduleInfoMsg, strLoadDirectionMsg FROM @LoadDetailTable
END