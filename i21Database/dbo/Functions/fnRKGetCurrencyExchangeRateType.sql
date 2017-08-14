CREATE FUNCTION [dbo].[fnRKGetCurrencyExchangeRateType]
(
	@intContractDetailId	INT
)
RETURNS NVARCHAR(50)

AS 
BEGIN 	

	DECLARE @strCurrencyExchangeRateType nvarchar(50)

	SELECT TOP 1 @strCurrencyExchangeRateType=strCurrencyExchangeRateType
	FROM tblCTContractDetail cd1
	JOIN tblSMCurrencyExchangeRate et on cd1.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId and cd1.intContractStatusId <> 3
	JOIN tblSMCurrencyExchangeRateDetail rd on rd.intCurrencyExchangeRateId=et.intCurrencyExchangeRateId
	JOIN tblSMCurrencyExchangeRateType et1 on et1.intCurrencyExchangeRateTypeId=rd.intRateTypeId
	WHERE cd1.intContractDetailId =@intContractDetailId
	ORDER BY rd.dtmValidFromDate DESC

	RETURN @strCurrencyExchangeRateType
	
END


