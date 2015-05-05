GO
MERGE INTO tblPOPurchase AS PO
USING tblEntityLocation AS Loc
ON (PO.intShipFromId = Loc.intEntityLocationId AND (PO.strShipFromState != Loc.strState OR PO.strShipFromZipCode != Loc.strZipCode))
WHEN MATCHED THEN
	UPDATE SET PO.strShipFromState = Loc.strState, PO.strShipFromZipCode = Loc.strZipCode;

MERGE INTO tblPOPurchase AS PO
USING tblSMCompanyLocation AS Loc
ON (PO.intShipToId = Loc.intCompanyLocationId AND (PO.strShipToState != Loc.strStateProvince OR PO.strShipToZipCode != Loc.strZipPostalCode))
WHEN MATCHED THEN
	UPDATE SET PO.strShipToState = Loc.strStateProvince, PO.strShipToZipCode = Loc.strZipPostalCode;
GO