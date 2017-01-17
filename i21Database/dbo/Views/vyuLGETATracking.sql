CREATE VIEW vyuLGETATracking
AS
	SELECT DISTINCT L.strLoadNumber
		,(
			SELECT TOP 1 dtmETAPOD
			FROM tblLGETATracking ETA
			WHERE ETA.intLoadId = L.intLoadId
			ORDER BY intETATrackingId
			) AS dtmFirstETAPOD
		,(
			SELECT TOP 1 dtmETAPOD
			FROM tblLGETATracking ETA
			WHERE ETA.intLoadId = L.intLoadId
			ORDER BY intETATrackingId DESC
			) AS dtmFinalETAPOD
		,COUNT(*) - 1 intNoOfTimesETAPODModified
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