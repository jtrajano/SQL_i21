CREATE VIEW [dbo].[vyuMBILShift]
	AS
	
SELECT Shift.intShiftId
	, Shift.dtmShiftDate
	, Shift.intDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, Shift.intLocationId
	, Location.strLocationName
	, Shift.intShiftNumber
	, Shift.dtmStartTime
	, Shift.dtmEndTime
	, strTruckName = Truck.strData
	, Shift.intStartOdometer
	, Shift.intEndOdometer
	, Shift.dblFuelGallonsDelievered
	, Shift.dblFuelSales
	, Shift.intConcurrencyId
FROM tblMBILShift Shift
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Shift.intDriverId
LEFT JOIN tblSCTruckDriverReference Truck ON Truck.intTruckDriverReferenceId = Shift.intTruckId AND Truck.strRecordType = 'T'
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Shift.intLocationId