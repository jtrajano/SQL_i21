IF EXISTS (SELECT 1 FROM dbo.tblRKFutOptTransactionHeader WHERE dtmTransactionDate is null)
BEGIN
	UPDATE tblRKFutOptTransactionHeader
	SET dtmTransactionDate = B.dtmTransactionDate,intSelectedInstrumentTypeId = B.intSelectedInstrumentTypeId,
		strSelectedInstrumentType = case when isnull(B.intSelectedInstrumentTypeId,1) = 1 then 'Exchange Traded' else 'OTC' end 
	FROM tblRKFutOptTransactionHeader A
	JOIN tblRKFutOptTransaction B
		ON A.intFutOptTransactionHeaderId = B.intFutOptTransactionHeaderId
	where A.dtmTransactionDate is null
END

GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKDateFilterFor360')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tblRKDateFilterFor360)
BEGIN
	INSERT INTO tblRKDateFilterFor360 (intConcurrencyId) VALUES(1)
END
END
GO
IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE strM2MView IS NULL)
BEGIN
	UPDATE tblRKCompanyPreference SET strM2MView = 'View 1' WHERE strM2MView IS NULL
END
GO