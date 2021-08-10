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
	, Items.dblFuelGallonsDelievered
	, Items.dblFuelSales
	, Shift.intConcurrencyId
FROM tblMBILShift Shift
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = Shift.intDriverId
LEFT JOIN tblSMTruck Truck ON Truck.intTruckId = Shift.intTruckId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Shift.intLocationId
LEFT JOIN (
			SELECT 
				intShiftId, SUM(dblFuelGallonsDelievered) as dblFuelGallonsDelievered, SUM(dblFuelSales) as dblFuelSales
			FROM (
					SELECT 
						InvoiceItem.intShiftId, SUM(dblQuantity) as dblFuelGallonsDelievered,  (ISNULL(dblItemTotal,0) + ISNULL(dblTaxTotal,0)) as dblFuelSales
					FROM 
						vyuMBILInvoiceItem InvoiceItem
						INNER JOIN tblICItem Item ON Item.intItemId = InvoiceItem.intItemId
						INNER JOIN vyuMBILInvoice Invoice ON Invoice.intInvoiceId = InvoiceItem.intInvoiceId
						WHERE Item.strType = 'Inventory' and Item.ysnAvailableTM = 1 and Invoice.ysnVoided IS NULL
						GROUP BY InvoiceItem.intShiftId, dblQuantity, dblItemTotal, dblTaxTotal
				) tblTotalItem
				GROUP BY intShiftId
		) Items ON Items.intShiftId = Shift.intShiftId

