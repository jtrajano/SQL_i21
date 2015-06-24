CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingValue]

AS
BEGIN
	SELECT TOP 1 
		 intElectronicPricingValueId
		,dblHigh AS High
		,dblLow AS  Low
		,dblOpen AS [Open]
		,dblLast AS [Last]
	FROM tblRKElectronicPricingValue
	ORDER BY intElectronicPricingValueId DESC
END