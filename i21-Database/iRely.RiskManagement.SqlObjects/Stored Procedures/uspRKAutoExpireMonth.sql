CREATE PROCEDURE uspRKAutoExpireMonth
AS

DECLARE @ysnAutoExpire bit

SELECT @ysnAutoExpire = isnull(ysnAutoExpire,0) FROM tblRKCompanyPreference
IF @ysnAutoExpire=1
BEGIN
	UPDATE tblRKFuturesMonth set ysnExpired = 1 where dtmLastTradingDate < getdate() and ysnExpired <> 1
	UPDATE tblRKOptionsMonth set ysnMonthExpired = 1 where dtmExpirationDate < getdate() and ysnMonthExpired <> 1
END