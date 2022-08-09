CREATE VIEW [dbo].[vyuRKGetPaymentCondition]
	AS 
	SELECT	TM.intTermID,
			TM.strTerm,
			TM.dblRemainingRisk,
			TM.strRemarks
	FROM tblSMTerm TM
