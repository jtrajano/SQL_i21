CREATE PROCEDURE [dbo].[uspARGetDefaultAccount]
	 @strTransactionType	NVARCHAR(25)
	, @intCompanyLocationId	INT
	, @intAccountId	INT				= NULL OUTPUT
	, @strAccountId	NVARCHAR(250)	= NULL OUTPUT
AS	

DECLARE @ARAccountId INT 
, @tmpTransactionType   NVARCHAR(100)
, @tmpCompanyLocationId INT
, @tmpintSalesAccountId	INT				= NULL 
, @tmpstrSalesAccountId	NVARCHAR(250)	= NULL 


SET @tmpTransactionType = @strTransactionType

SET @tmpCompanyLocationId = @intCompanyLocationId 

SET @ARAccountId = [dbo].[fnARGetInvoiceTypeAccount](@tmpTransactionType, @tmpCompanyLocationId)

SELECT 
	@intAccountId		=	intAccountId
	, @strAccountId	=	strAccountId 
FROM 
	tblGLAccount WITH(NOLOCK) 
WHERE 
	intAccountId  = @ARAccountId