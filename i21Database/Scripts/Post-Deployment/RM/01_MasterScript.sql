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
	IF NOT EXISTS(SELECT 1 FROM tblRKDateFilterFor360)
		INSERT INTO tblRKDateFilterFor360 (intConcurrencyId) VALUES(1)


GO
PRINT ('/*******************  START Syncing Commodity Attributes to RM *******************/')
GO
EXEC uspRKSyncCommodityMarketAttribute -- saving to an RM table with constraint to disallow deletion of commodity attributes in IC
GO
PRINT('/*******************  END Syncing Commodity Attributes to RM *******************/')
GO

