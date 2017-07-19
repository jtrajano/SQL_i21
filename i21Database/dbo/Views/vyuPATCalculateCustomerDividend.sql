﻿CREATE VIEW [dbo].[vyuPATCalculateCustomerDividend]
	AS
SELECT CS.intCustomerStockId,
	CS.intCustomerPatronId AS intCustomerId,
	NEWID() as id,
	CS.intStockId,
	SC.strStockName,
	CS.strCertificateNo,
	CS.dtmIssueDate,
	SC.dblParValue,
	CS.dblSharesNo,
	CS.ysnPosted,
	SC.dblDividendsPerShare
	FROM tblPATStockClassification SC
INNER JOIN tblPATCustomerStock CS
	ON CS.intStockId = SC.intStockId
INNER JOIN tblEMEntity ENT
	ON ENT.intEntityId = CS.intCustomerPatronId
INNER JOIN tblARCustomer ARC
	ON ARC.intEntityCustomerId = ENT.intEntityId
WHERE CS.strActivityStatus = 'Open'