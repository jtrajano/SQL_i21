IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKCompanyPreference')
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKCompanyPreference)
	BEGIN
		INSERT INTO tblRKCompanyPreference(intConcurrencyId, dblDecimals, dblRefreshRate, strM2MView, strDateTimeFormat, strEvaluationBy, strEvaluationByZone)
		SELECT 1, 2, 60, 'Processor', 'MM DD YYYY HH:MI', 'Item', 'Location'
	END
END
GO

IF EXISTS (SELECT 1 FROM dbo.tblRKFutOptTransactionHeader WHERE dtmTransactionDate is null)
BEGIN
	UPDATE tblRKFutOptTransactionHeader
	SET dtmTransactionDate = B.dtmTransactionDate,intSelectedInstrumentTypeId = B.intSelectedInstrumentTypeId,
		strSelectedInstrumentType = case when isnull(B.intSelectedInstrumentTypeId,1) = 1 then 'Exchange Traded' 
		WHEN B.intSelectedInstrumentTypeId = 2 THEN 'OTC'
										ELSE 'OTC - Others' END
	FROM tblRKFutOptTransactionHeader A
	JOIN tblRKFutOptTransaction B
		ON A.intFutOptTransactionHeaderId = B.intFutOptTransactionHeaderId
	where A.dtmTransactionDate is null
END

GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKDateFilterFor360')
BEGIN
	IF NOT EXISTS(SELECT 1 FROM tblRKDateFilterFor360)
BEGIN
	INSERT INTO tblRKDateFilterFor360 (intConcurrencyId) VALUES(1)
END
END
GO
IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(strM2MView, '') = '')
BEGIN
	UPDATE tblRKCompanyPreference SET strM2MView = 'View 1 - Standard' WHERE ISNULL(strM2MView, '') = ''
END
GO

GO
IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(dblRefreshRate, 0) = 0)
BEGIN
	UPDATE tblRKCompanyPreference SET dblRefreshRate = 5 WHERE ISNULL(dblRefreshRate, 0) = 0
END
GO

IF EXISTS ( SELECT 1 FROM tblRKCompanyPreference WHERE ISNULL(strDateTimeFormat, '') = '')
BEGIN
	UPDATE tblRKCompanyPreference SET strDateTimeFormat = 'MM DD YYYY HH:MI' WHERE ISNULL(strDateTimeFormat, '') = ''
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKDPRHedgeDailyPositionDetail')
BEGIN
	EXEC ('DROP VIEW vyuRKDPRHedgeDailyPositionDetail')
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKDPRInvDailyPositionDetail')
BEGIN
	EXEC ('DROP VIEW vyuRKDPRInvDailyPositionDetail')
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = N'vyuRKGetSequenceMonth')
BEGIN
	EXEC ('DROP VIEW vyuRKGetSequenceMonth')
END
GO

PRINT ('/*******************  START Syncing Commodity Attributes to RM *******************/')
GO
EXEC uspRKSyncCommodityMarketAttribute -- saving to an RM table with constraint to disallow deletion of commodity attributes in IC
GO
PRINT('/*******************  END Syncing Commodity Attributes to RM *******************/')
GO
IF NOT EXISTS (SELECT 1 FROM tblSMStartingNumber WHERE ISNULL(strTransactionType, '') = 'Currency Exposure' and strModule='Risk Management')
BEGIN
	INSERT INTO tblSMStartingNumber (strTransactionType,intNumber,strPrefix,strModule,ysnUseLocation,ysnResetNumber,dtmResetDate,ysnEnable,intConcurrencyId) 
	VALUES('Currency Exposure',1,'','Risk Management',0,0,getdate(),1,1)
END
GO


IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKRiskView')
BEGIN
	SET IDENTITY_INSERT tblRKRiskView ON
    
	INSERT INTO tblRKRiskView(intRiskViewId
		, strRiskView
		, ysnCustomWork
		, strCustomer)
	SELECT * FROM (
		SELECT intRiskViewId = 1
			, strRiskView = 'Trader/Elevator'
			, ysnCustomWork = CAST(0 AS BIT)
			, strCustomer = NULL

		UNION ALL SELECT 2
			, 'Processor'
			, 0
			, NULL

		UNION ALL SELECT 3
			, 'Trader 2'
			, 0
			, NULL

		UNION ALL SELECT 4
			, 'Strauss View'
			, 1
			, 'Strauss'
	) t
	WHERE intRiskViewId NOT IN (SELECT intRiskViewId FROM tblRKRiskView)

	SET IDENTITY_INSERT tblRKRiskView OFF
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKDPIHeader')
BEGIN
	DELETE FROM tblRKDPIHeader
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKDPRHeader')
BEGIN
	DELETE FROM tblRKDPRHeader
END
GO

IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblRKM2MType')
BEGIN
	SET IDENTITY_INSERT tblRKM2MType ON
    
	INSERT INTO tblRKM2MType(intM2MTypeId
		, strType)
	SELECT * FROM (
		SELECT intM2MTypeId = 1
			, strType = 'Mark to Market'
		UNION ALL SELECT 2
			, 'Stress Test'
	) t
	WHERE intM2MTypeId NOT IN (SELECT intM2MTypeId FROM tblRKM2MType)

	SET IDENTITY_INSERT tblRKM2MType OFF
END
GO