﻿CREATE PROCEDURE [dbo].[uspRKInsertToElectronicPricing]
	 @high DECIMAL(24, 10)
	,@open DECIMAL(24, 10)
	,@low DECIMAL(24, 10)
	,@last DECIMAL(24, 10)
	,@url Nvarchar(Max)
	,@msg Nvarchar(Max)
	,@FutureMarketId INT
AS
BEGIN
	INSERT INTO tblRKElectronicPricingValue 
	  (
		 dblHigh
		,dblLow
		,dblOpen
		,dblLast
		,strURL
		,strMessage
		,intFutureMarketId
	  )
	SELECT 
		 @high
		,@low		
		,@open
		,@last
		,@url
		,@msg
		,@FutureMarketId
END