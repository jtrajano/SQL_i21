CREATE VIEW [dbo].[vyuPATChangeStockStatusDetail]
	AS
SELECT	CSD.intChangeStatusDetailId,
		CS.intChangeStatusId,
		CS.strUpdateNo,
		CSD.intCustomerId,
		EM.strEntityNo,
		EM.strName,
		ARC.dtmLastActivityDate,
		CSD.strCurrentStatus,
		CSD.strNewStatus,
		CSD.intConcurrencyId
FROM tblPATChangeStatus CS
INNER JOIN tblPATChangeStatusDetail CSD
	ON CSD.intChangeStatusId = CS.intChangeStatusId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = CSD.intCustomerId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityId = EM.intEntityId