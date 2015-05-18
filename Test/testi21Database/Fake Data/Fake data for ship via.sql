CREATE PROCEDURE [testi21Database].[Fake data for ship via]
AS
BEGIN	
	EXEC tSQLt.FakeTable 'dbo.tblSMShipVia';

	DECLARE @Ship_Via_Truck AS NVARCHAR(50) = 'Truck'
			,@Ship_Via_Truck_Id AS INT = 1

	INSERT INTO tblSMShipVia (
		intShipViaID
		,strShipViaOriginKey
		,strShipVia
		,strShippingService
		,strName
		,strAddress
		,strCity
		,strState
		,strZipCode
		,strFederalId
		,strTransporterLicense
		,strMotorCarrierIFTA
		,strTransportationMode
		,ysnCompanyOwnedCarrier
		,ysnActive
		,intSort
		,intConcurrencyId	
	)
	SELECT 
		intShipViaID			= @Ship_Via_Truck_Id
		,strShipViaOriginKey	= NULL 
		,strShipVia				= @Ship_Via_Truck
		,strShippingService		= 'None'
		,strName				= NULL 
		,strAddress				= NULL 
		,strCity				= NULL 
		,strState				= NULL 
		,strZipCode				= NULL 
		,strFederalId			= NULL 
		,strTransporterLicense	= NULL 
		,strMotorCarrierIFTA	= NULL 
		,strTransportationMode	= NULL 
		,ysnCompanyOwnedCarrier	=  0
		,ysnActive				= 1
		,intSort				= 1
		,intConcurrencyId		= 1

END