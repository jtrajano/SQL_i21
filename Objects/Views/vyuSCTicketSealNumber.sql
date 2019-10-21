CREATE VIEW [dbo].[vyuSCTicketSealNumber]
AS
SELECT TSN.intTicketSealNumberId,TSN.intTicketId,TSN.intSealNumberId, SN.strSealNumber, TDR.strData,SN.dtmCreateDate,EM.strName, ysnScanned FROM tblSCTicketSealNumber TSN
INNER JOIN tblSCSealNumber SN
	ON SN.intSealNumberId = TSN.intSealNumberId
LEFT JOIN tblSCTruckDriverReference TDR
	ON TDR.intTruckDriverReferenceId = TSN.intTruckDriverReferenceId
LEFT JOIN tblEMEntity EM
	ON EM.intEntityId = SN.intUserId
GO