/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Smith de Jesus	DATE CREATED: October 29, 2015
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :	fnCMGetBankAccountMICR

   Description		   :	This will generate the MICR of the bank account specified
							
*/


CREATE FUNCTION [dbo].[fnCMGetBankAccountMICR]
(
	@intBankAccountId INT = NULL,
	@strCheckNumber NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(100)
AS
BEGIN 

IF NOT EXISTS(SELECT TOP 1 1 from tblCMBankAccount WHERE intBankAccountId = @intBankAccountId and ysnCheckEnableMICRPrint = 1)
BEGIN
RETURN NULL
END

		
DECLARE @strMICRPreview						AS NVARCHAR(100),
		@strRoutingNumber					AS NVARCHAR(50),
		@strAccountNumber					AS NVARCHAR(50),
		@intMICRBankAccountSpacesCount		AS INT,
		@intMICRBankAccountSpacesPosition	AS INT,
		@intMICRCheckNoSpacesCount			AS INT,
		@intMICRCheckNoSpacesPosition		AS INT,
		@intMICRCheckNoLength				AS INT,
		@intMICRCheckNoPosition				AS INT,
		@strMICRLeftSymbol					AS NVARCHAR(1),
		@strMICRRightSymbol					AS NVARCHAR(1)


SELECT					
 @strRoutingNumber					= [dbo].fnAESDecryptASym(strMICRRoutingNo)					
,@strAccountNumber					= [dbo].fnAESDecryptASym(strMICRBankAccountNo)		
,@intMICRBankAccountSpacesCount		= intMICRBankAccountSpacesCount		
,@intMICRBankAccountSpacesPosition	= intMICRBankAccountSpacesPosition	
,@intMICRCheckNoSpacesCount			= intMICRCheckNoSpacesCount
,@intMICRCheckNoSpacesPosition		= intMICRCheckNoSpacesPosition
,@intMICRCheckNoLength				= intMICRCheckNoLength
,@intMICRCheckNoPosition			= intMICRCheckNoPosition	
,@strMICRLeftSymbol					= LTRIM(RTRIM(strMICRLeftSymbol))
,@strMICRRightSymbol				= LTRIM(RTRIM(strMICRRightSymbol))	
FROM tblCMBankAccount				
WHERE intBankAccountId = @intBankAccountId

SET @strCheckNumber = LTRIM(RTRIM(@strCheckNumber))

--add space character padding to the bank account numbers
IF @intMICRBankAccountSpacesCount > 0
BEGIN
	WHILE @intMICRBankAccountSpacesCount > 0
	BEGIN
			IF @intMICRBankAccountSpacesPosition = 1 BEGIN 
				--padding is to the leading
				SET @strAccountNumber = ' ' + @strAccountNumber
				END
			ELSE IF @intMICRBankAccountSpacesPosition = 2 BEGIN
				--padding is to the trailing
				SET @strAccountNumber = @strAccountNumber + ' '
				END
			ELSE
				--default padding is to the leading
				SET @strAccountNumber = ' ' + @strAccountNumber

		SET @intMICRBankAccountSpacesCount = @intMICRBankAccountSpacesCount - 1
	END
	
END 

--add zeros if the check length is greater than the actual check number length
IF @intMICRCheckNoLength > LEN(@strCheckNumber)
BEGIN
	DECLARE @micrCheckNoLength AS INT

	SET @micrCheckNoLength = @intMICRCheckNoLength - LEN(@strCheckNumber)
	WHILE @micrCheckNoLength > 0
	BEGIN
		SET @strCheckNumber = '0' + @strCheckNumber

		SET @micrCheckNoLength = @micrCheckNoLength -1
	END
END
--if actual check number length is greater than acceptable check number length, trim the excess
ELSE IF @intMICRCheckNoLength < LEN(@strCheckNumber)
BEGIN
	SET @strCheckNumber = SUBSTRING(@strCheckNumber, LEN(@strCheckNumber) -  @intMICRCheckNoLength + 1, @intMICRCheckNoLength)
END

--add the left and right symbols to the check number
SET @strCheckNumber = @strMICRLeftSymbol + @strCheckNumber
SET @strCheckNumber = @strCheckNumber + @strMICRRightSymbol

--add space character padding to the check numbers
IF @intMICRCheckNoSpacesCount > 0
BEGIN
	WHILE @intMICRCheckNoSpacesCount > 0
	BEGIN
			IF @intMICRCheckNoSpacesPosition = 1 BEGIN 
				--padding is to the leading
				SET @strCheckNumber = ' ' + @strCheckNumber
				END
			ELSE IF @intMICRCheckNoSpacesPosition = 2 BEGIN
				--padding is to the trailing
				SET @strCheckNumber = @strCheckNumber + ' '
				END
			ELSE
				--default padding is to the leading
				SET @strCheckNumber = ' ' + @strCheckNumber

		SET @intMICRCheckNoSpacesCount = @intMICRCheckNoSpacesCount - 1
	END
	
END 


--assemble the MICR preview
IF @intMICRCheckNoPosition = 1 BEGIN
	--check number is to the left
	SET @strMICRPreview = @strCheckNumber + @strRoutingNumber + @strAccountNumber
	END
ELSE IF @intMICRCheckNoPosition = 2 BEGIN
	--check number is to the middle
	SET @strMICRPreview = @strRoutingNumber + @strCheckNumber + @strAccountNumber
	END
ELSE IF @intMICRCheckNoPosition = 3 BEGIN
	--check number is to the right
	SET @strMICRPreview =  @strRoutingNumber + @strAccountNumber + @strCheckNumber
	END
ELSE
	--default is to the left
	SET @strMICRPreview = @strCheckNumber + @strRoutingNumber + @strAccountNumber


RETURN @strMICRPreview

END 

