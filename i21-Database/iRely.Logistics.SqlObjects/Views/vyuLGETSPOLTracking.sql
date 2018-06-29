CREATE VIEW vyuLGETSPOLTracking
AS
	SELECT DISTINCT L.strLoadNumber
		,ETA.strTrackingType
		,(
			SELECT TOP 1 dtmETSPOL
			FROM tblLGETATracking ETA
			WHERE ETA.intLoadId = L.intLoadId
				AND ETA.strTrackingType = 'ETS POL'
			ORDER BY intETATrackingId
			) AS dtmFirstETSPOL
		,(
			SELECT TOP 1 dtmETSPOL
			FROM tblLGETATracking ETA
			WHERE ETA.intLoadId = L.intLoadId
				AND ETA.strTrackingType = 'ETS POL'
			ORDER BY intETATrackingId DESC
			) AS dtmFinalETSPOL
		,COUNT(*) - 1 intNoOfTimesETSPOLModified
		,L.strBLNumber
		,L.dtmBLDate
		,ShippingLine.strName AS strShippingLine
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
		,L.strOriginPort
		,L.strDestinationPort
	FROM tblLGETATracking ETA
	JOIN tblLGLoad L ON L.intLoadId = ETA.intLoadId
	LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
	WHERE ETA.strTrackingType = 'ETS POL'
	GROUP BY L.strLoadNumber
		,L.strBLNumber
		,L.intShippingLineEntityId
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
		,L.strDestinationPort
		,L.strOriginPort
		,L.dtmBLDate
		,ShippingLine.strName
		,L.intLoadId
		,ETA.strTrackingType