CREATE PROCEDURE [dbo].[uspPOUpdateAddressInfo]
	@poId INT,
	@shipFromId INT,
	@shipToId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--DECLARE @shipFromAddress NVARCHAR(200)
--DECLARE @shipFromCity NVARCHAR(50)
--DECLARE @shipFromState NVARCHAR(50)
--DECLARE @shipFromZipCode NVARCHAR(12)
--DECLARE @shipFromCountry NVARCHAR(25)
--DECLARE @shipFromPhone NVARCHAR(25)
--DECLARE @shipFromAttention NVARCHAR(200)

--DECLARE @shipToAddress NVARCHAR(200)
--DECLARE @shipToCity NVARCHAR(50)
--DECLARE @shipToState NVARCHAR(50)
--DECLARE @shipToZipCode NVARCHAR(12)
--DECLARE @shipToCountry NVARCHAR(25)
--DECLARE @shipToPhone NVARCHAR(25)
--DECLARE @shipToAttention NVARCHAR(200)

IF(@shipFromId > 0)
BEGIN
	UPDATE A
		SET A.strShipFromAddress = B.strAddress
		,A.strShipFromCity = B.strCity
		,A.strShipFromCountry = B.strCountry
		,A.strShipFromPhone = B.strPhone
		,A.strShipFromState = B.strState
		,A.strShipFromZipCode = B.strZipCode
	FROM tblPOPurchase A
	INNER JOIN tblEntityLocation B ON A.intShipFromId = B.intEntityLocationId
	WHERE A.intPurchaseId = @poId AND B.intEntityLocationId = @shipFromId
END

IF(@shipToId > 0)
BEGIN
	UPDATE A
		SET A.strShipToAddress = B.strAddress
		,A.strShipToCity = B.strCity
		,A.strShipToCountry = B.strCountry
		,A.strShipToPhone = B.strPhone
		,A.strShipToState = B.strStateProvince
		,A.strShipToZipCode = B.strZipPostalCode
	FROM tblPOPurchase A
	INNER JOIN tblSMCompanyLocation B ON A.intShipToId = B.intCompanyLocationId
	WHERE A.intPurchaseId = @poId AND B.intCompanyLocationId = @shipToId
END