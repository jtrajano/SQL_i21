CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingValue]
	@StrURL Nvarchar(Max)
AS
BEGIN
	SELECT TOP 1 
		 intElectronicPricingValueId
		,dblHigh AS High  
	    ,dblLow AS  Low  
	    ,dblOpen AS [Open]  
	    ,dblLast AS [Last] 
	FROM tblRKElectronicPricingValue Where strURL=@StrURL
	ORDER BY intElectronicPricingValueId DESC
END