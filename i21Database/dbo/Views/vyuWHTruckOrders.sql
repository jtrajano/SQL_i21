CREATE VIEW vyuWHTruckOrders
AS
SELECT oh.strBOLNo
	,oh.strCustOrderNo
	,oh.intOrderTypeId
	,oh.intOrderDirectionId
	,oh.intOrderStatusId
	,oh.intOrderHeaderId
	,oh.strReferenceNo
	,oh.intOwnerAddressId
	,oh.intStagingLocationId
	,oh.dtmRAD
	,oh.intFreightPaymentAddressId
	,os.strOrderStatus
	,od.strOrderDirection
	,ot.strOrderType
	,ot.strInternalCode
	,t.intTruckId
	,t.strTruckNo
	,t.strProNo
	,t.strSealNo
	,CASE 
		WHEN od.strInternalCode = 'OUTBOUND'
			THEN CASE 
					WHEN ot.strInternalCode = 'SO'
						THEN cu.strCustomerNumber
					WHEN ot.strInternalCode = 'WT'
						THEN cl1.strLocationName
					ELSE NULL
				 END
		ELSE CASE 
				WHEN ot.strInternalCode IN ('SR','PO','WT')
					THEN cl2.strLocationName
				ELSE NULL
				END
		END AS strShipToAddress
	,CASE 
		WHEN od.strInternalCode = 'OUTBOUND'
			THEN CASE 
					WHEN ot.strInternalCode IN ('SO','WT')
						THEN cl.strLocationName
					ELSE NULL
					END
		ELSE CASE 
				WHEN ot.strInternalCode IN ('SR','PO')
					THEN cu1.strCustomerNumber
				WHEN ot.strInternalCode = 'WT'
					THEN cl3.strLocationName
				ELSE NULL
				END
		END AS strShipFromAddress
FROM tblWHOrderHeader oh
JOIN tblWHOrderStatus os ON os.intOrderStatusId = oh.intOrderStatusId
JOIN tblWHOrderDirection od ON od.intOrderDirectionId = oh.intOrderDirectionId
JOIN tblWHOrderType ot ON ot.intOrderTypeId = oh.intOrderTypeId
JOIN tblWHTruck t ON t.intTruckId = oh.intTruckId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = oh.intShipFromAddressId
LEFT JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = oh.intShipToAddressId
LEFT JOIN tblARCustomer cu ON cu.[intEntityId] = oh.intShipToAddressId
LEFT JOIN tblSMCompanyLocation cl2 ON cl2.intCompanyLocationId = oh.intShipToAddressId
LEFT JOIN tblSMCompanyLocation cl3 ON cl3.intCompanyLocationId = oh.intShipFromAddressId
LEFT JOIN tblARCustomer cu1 ON cu1.[intEntityId] = oh.intShipFromAddressId
