CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingValue]
	 @FutureMarketId INT
	,@StrURL Nvarchar(Max)
AS
BEGIN
	SELECT TOP 1 
		 intElectronicPricingValueId
		,(dblHigh *(CASE WHEN b.dblConversionRate IS NULL THEN 1 ELSE b.dblConversionRate END))   AS High  
	    ,(dblLow * (CASE WHEN b.dblConversionRate IS NULL THEN 1 ELSE b.dblConversionRate END))   AS  Low  
	    ,(dblOpen * (CASE WHEN b.dblConversionRate IS NULL THEN 1 ELSE b.dblConversionRate END))  AS [Open]  
	    ,(dblLast * (CASE WHEN b.dblConversionRate IS NULL THEN 1 ELSE b.dblConversionRate END)) AS [Last]
		,strMessage 
	FROM tblRKElectronicPricingValue a
	JOIN tblRKFutureMarket b ON b.intFutureMarketId=a.intFutureMarketId Where a.strURL=@StrURL AND b.intFutureMarketId=@FutureMarketId
	ORDER BY a.intElectronicPricingValueId DESC
END