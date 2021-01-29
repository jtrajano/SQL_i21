CREATE VIEW [dbo].[vyuMBILShift]
	AS
	
SELECT Shift.intShiftId
	, Shift.dtmShiftDate
	, Shift.intDriverId
	, Driver.strDriverNo
	, Driver.strDriverName
	, Shift.intLocationId
	, Location.strLocationName
	, Shift.strShiftNo
	, Shift.intShiftNumber
	, Shift.dtmStartTime
	, Shift.dtmEndTime
	, Shift.intTruckId
	, strTruckName = Truck.strTruckNumber
	, Shift.intStartOdometer
	, Shift.intEndOdometer
	, Shift.dblFuelGallonsDelievered
	, Shift.dblFuelSales
	, Shift.intConcurrencyId
FROM tblMBILShift Shift
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Shift.intDriverId
LEFT JOIN tblSMTruck Truck ON Truck.intTruckId = Shift.intTruckId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Shift.intLocationId