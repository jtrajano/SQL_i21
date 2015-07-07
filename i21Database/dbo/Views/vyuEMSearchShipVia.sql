CREATE VIEW [dbo].[vyuEMSearchShipVia]
	AS 

	select 
	A.intEntityShipViaId,
	A.strShipVia,
	A.strShippingService,
	B.strName,
	E.strAddress,
	E.strCity,
	E.strState,
	E.strZipCode,
	A.strFederalId,
	A.strTransporterLicense,
	A.strMotorCarrierIFTA,
	A.strTransportationMode,
	A.ysnCompanyOwnedCarrier,
	A.strFreightBilledBy,
	A.ysnActive,
	A.intSort
	from 
		tblSMShipVia A
			JOIN tblEntity B
				on A.intEntityShipViaId = B.intEntityId
			JOIN tblEntityToContact C
				on C.intEntityId = B.intEntityId and C.ysnDefaultContact = 1
			JOIN tblEntity D
				ON C.intEntityContactId = D.intEntityId
			JOIN tblEntityLocation E	
				ON E.intEntityId = A.intEntityShipViaId
					AND E.ysnDefaultLocation = 1
