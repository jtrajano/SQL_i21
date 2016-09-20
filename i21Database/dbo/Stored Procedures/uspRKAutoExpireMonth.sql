CREATE PROCEDURE uspRKAutoExpireMonth
AS

DECLARE @ysnAutoExpire bit

SELECT @ysnAutoExpire = isnull(ysnAutoExpire,0) FROM tblRKCompanyPreference
if @ysnAutoExpire=1
BEGIN
update tblRKFuturesMonth set ysnExpired = 1 where dtmLastTradingDate < getdate() and ysnExpired <> 1
update tblRKOptionsMonth set ysnMonthExpired = 1 where dtmExpirationDate < getdate() and ysnMonthExpired <> 1
END
