CREATE PROCEDURE [dbo].[uspARGetItemAccount]
	@intItemId				INT
	, @intLocationId		INT
	, @intSalesAccountId	INT				= NULL OUTPUT
	, @strSalesAccountId	NVARCHAR(250)	= NULL OUTPUT
AS	

SELECT 
	@intSalesAccountId		=	intAccountId
	, @strSalesAccountId	=	strAccountId 
FROM 
	vyuGLAccountView 
WHERE 
	intAccountId IN (SELECT 
						intSalesAccountId = case when strType = 'Other Charge'  then intOtherChargeIncomeAccountId  
											when strType = 'Non-Inventory' or strType = 'Service' then intGeneralAccountId  											
											else intSalesAccountId end
					   FROM 
						vyuARGetItemAccount
					   WHERE 
						intItemId = @intItemId
						AND intLocationId = @intLocationId) 