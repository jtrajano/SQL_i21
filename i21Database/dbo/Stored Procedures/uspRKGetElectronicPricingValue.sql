CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingValue]
(
	@ConversionRate NUMERIC(18, 6)
)
AS
BEGIN
	SELECT TOP 1 
		 intElectronicPricingValueId
		,dblHigh * @ConversionRate AS High
		,dblLow * @ConversionRate AS Low
		,dblOpen * @ConversionRate AS [Open]
		,dblLast * @ConversionRate AS [Last]
	FROM tblRKElectronicPricingValue
	ORDER BY intElectronicPricingValueId DESC
END