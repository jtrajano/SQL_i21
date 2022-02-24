CREATE VIEW [dbo].[vyuApiTransportTerminals]
AS
SELECT
	B.intEntityId,
	B.intEntityLocationId AS intVendorLocationId,
    B.strLocationName,
    B.strCheckPayeeName AS strPrintedName,
    C.strShipVia,
    B.intShipViaId,
    E.strTerminalControlNumber AS strTerminalNo,
	strVendorNumber = A.strVendorId,
	strVendorName = entity.strName
FROM tblAPVendor A
INNER JOIN tblEMEntity entity ON entity.intEntityId = A.intEntityId
INNER JOIN tblEMEntityLocation B ON A.intEntityId = B.intEntityId
INNER JOIN tblTRSupplyPoint F ON B.intEntityLocationId = F.intEntityLocationId
LEFT JOIN tblSMShipVia C ON B.intShipViaId = C.intEntityId
LEFT JOIN tblTRSupplyPoint D ON B.intEntityLocationId = D.intEntityLocationId
LEFT JOIN tblTFTerminalControlNumber E ON D.intTerminalControlNumberId = E.intTerminalControlNumberId
WHERE
    A.ysnTransportTerminal = 1
