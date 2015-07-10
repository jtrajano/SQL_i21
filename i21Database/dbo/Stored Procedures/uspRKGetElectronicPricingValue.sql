CREATE PROCEDURE [dbo].[uspRKGetElectronicPricingValue]
	@StrURL Nvarchar(Max)
AS
BEGIN
	SELECT TOP 1 
		 intElectronicPricingValueId
		,CONVERT(DOUBLE PRECISION,dblHigh) AS High  
	    ,CONVERT(DOUBLE PRECISION,dblLow) AS  Low  
	    ,CONVERT(DOUBLE PRECISION,dblOpen) AS [Open]  
	    ,CONVERT(DOUBLE PRECISION,dblLast) AS [Last] 
	FROM tblRKElectronicPricingValue Where strURL=@StrURL
	ORDER BY intElectronicPricingValueId DESC
END