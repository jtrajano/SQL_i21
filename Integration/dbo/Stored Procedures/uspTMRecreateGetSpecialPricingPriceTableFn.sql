﻿GO
	PRINT 'START OF CREATING [uspTMRecreateGetSpecialPricingPriceTableFn] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateGetSpecialPricingPriceTableFn]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateGetSpecialPricingPriceTableFn
GO

CREATE PROCEDURE uspTMRecreateGetSpecialPricingPriceTableFn 
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSpecialPricingPriceTable]') AND type IN (N'TF'))
	DROP FUNCTION [dbo].[fnTMGetSpecialPricingPriceTable]
	

	
	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		EXEC('
			CREATE FUNCTION [dbo].[fnTMGetSpecialPricingPriceTable](
				@strCustomerNumberParam AS NVARCHAR(20)
				,@strItemNumberParam NVARCHAR(20)
				,@strLocationParam NVARCHAR(20)
				,@strItemClassParam NVARCHAR(20)
				,@dtmOrderDateParam DATETIME
				,@dblQuantityParam DECIMAL(18,6)
				,@strContractNumberParam NVARCHAR(20)
				,@intSiteIdParam INT
			)
			RETURNS @tblSpecialPriceTableReturn TABLE(
				dblPrice NUMERIC(18,6),
				strSpecialPricing NVARCHAR(100)
			)
			AS
			BEGIN 
				DECLARE @dblPrice NUMERIC(18,6)
				DECLARE @strSpecialPricing NVARCHAR(50)

				DECLARE @strCustomerNumber AS NVARCHAR(20)
				DECLARE @strItemNumber NVARCHAR(20)
				DECLARE @strLocation NVARCHAR(20)
				DECLARE @strItemClass NVARCHAR(20)
				DECLARE @dtmOrderDate DATETIME
				DECLARE @dblQuantity DECIMAL(18,6)
				DECLARE @strContractNumber NVARCHAR(20)
				DECLARE @intSiteId INT

				SET @dblQuantity = @dblQuantityParam
				SET	@strCustomerNumber = @strCustomerNumberParam
				SET	@strItemNumber = @strItemNumberParam
				SET	@strLocation = @strLocationParam
				SET	@strItemClass = @strItemClassParam
				SET	@dtmOrderDate = @dtmOrderDateParam
				SET	@strContractNumber =  @strContractNumberParam
				SET	@intSiteId = @intSiteIdParam


		
				SET @strSpecialPricing = dbo.fnTMGetSpecialPricing(
								@strCustomerNumber
								,@strItemNumber
								,@strLocation
								,@strItemClass
								,@dtmOrderDate
								,@dblQuantity
								,@strContractNumber)
				SET @dblPrice = CAST(LEFT(@strSpecialPricing,CHARINDEX('':'',@strSpecialPricing)- 1) AS DECIMAL(18,6))
				
		
		
				INSERT INTO @tblSpecialPriceTableReturn (dblPrice)
				SELECT ISNULL(@dblPrice,0.0)

				RETURN 
		
			END	
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE FUNCTION [dbo].[fnTMGetSpecialPricingPriceTable](
				@strCustomerNumberParam AS NVARCHAR(20)
				,@strItemNumberParam NVARCHAR(20)
				,@strLocationParam NVARCHAR(20)
				,@strItemClassParam NVARCHAR(20)
				,@dtmOrderDateParam DATETIME
				,@dblQuantityParam DECIMAL(18,6)
				,@strContractNumberParam NVARCHAR(20)
				,@intSiteIdParam INT
			)
			RETURNS @tblSpecialPriceTableReturn TABLE(
				dblPrice NUMERIC(18,6),
				strSpecialPricing NVARCHAR(100)
			)
			AS
			BEGIN 
				DECLARE @dblPrice NUMERIC(18,6)
				DECLARE @strSpecialPricing NVARCHAR(50)
				DECLARE @intProductId INT
				DECLARE @intLocationId INT
				DECLARE @intEntityCustomerId INT

				DECLARE @strCustomerNumber AS NVARCHAR(20)
				DECLARE @strItemNumber NVARCHAR(20)
				DECLARE @strLocation NVARCHAR(20)
				DECLARE @strItemClass NVARCHAR(20)
				DECLARE @dtmOrderDate DATETIME
				DECLARE @dblQuantity DECIMAL(18,6)
				DECLARE @strContractNumber NVARCHAR(20)
				DECLARE @intSiteId INT

				SET @dblQuantity = @dblQuantityParam
				SET	@strCustomerNumber = @strCustomerNumberParam
				SET	@strItemNumber = @strItemNumberParam
				SET	@strLocation = @strLocationParam
				SET	@strItemClass = @strItemClassParam
				SET	@dtmOrderDate = @dtmOrderDateParam
				SET	@strContractNumber =  @strContractNumberParam
				SET	@intSiteId = @intSiteIdParam
				
		
				SELECT 
					@intProductId = A.intProduct
					,@intLocationId = A.intLocationId
					,@intEntityCustomerId = B.intCustomerNumber
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				WHERE intSiteID = @intSiteId

				SET @strSpecialPricing = dbo.fnGetItemPricing(@intProductId,@intEntityCustomerId,@intLocationId,NULL,GETDATE(),@dblQuantity,'':'')
				SET @dblPrice = CAST(LEFT(@strSpecialPricing,CHARINDEX('':'',@strSpecialPricing)- 1) AS DECIMAL(18,6))
				
		
		
				INSERT INTO @tblSpecialPriceTableReturn (dblPrice,strSpecialPricing)
				SELECT ISNULL(@dblPrice,0.0), @strSpecialPricing 

				RETURN 
		
			END	
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateGetSpecialPricingPriceTableFn] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateGetSpecialPricingPriceTableFn] SP'
GO
	EXEC ('uspTMRecreateGetSpecialPricingPriceTableFn')
GO
	PRINT 'END OF Execute [uspTMRecreateGetSpecialPricingPriceTableFn] SP'
GO