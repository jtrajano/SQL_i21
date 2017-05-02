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
		@strMICRRoutingPrefix				AS NVARCHAR(1),
		@strMICRRoutingSuffix				AS NVARCHAR(1),
		@strAccountNumber					AS NVARCHAR(50),
		@strMICRBankAccountPrefix			AS NVARCHAR(1),
		@strMICRBankAccountSuffix			AS NVARCHAR(1),
		@intMICRBankAccountSpacesCount		AS INT,
		@intMICRBankAccountSpacesPosition	AS INT,
		@intMICRCheckNoSpacesCount			AS INT,
		@intMICRCheckNoSpacesPosition		AS INT,
		@intMICRCheckNoLength				AS INT,
		@intMICRCheckNoPosition				AS INT,
		@strMICRLeftSymbol					AS NVARCHAR(1),
		@strMICRRightSymbol					AS NVARCHAR(1),
		@strMICRFinancialInstitution				AS NVARCHAR(50),
		@strMICRFinancialInstitutionPrefix			AS NVARCHAR(1),
		@strMICRFinancialInstitutionSuffix			AS NVARCHAR(1),
		@intMICRFinancialInstitutionSpacesCount		AS INT,
		@intMICRFinancialInstitutionSpacesPosition	AS INT,
		@strMICRDesignation					AS NVARCHAR(50),
		@strMICRDesignationPrefix			AS NVARCHAR(1),
		@strMICRDesignationSuffix			AS NVARCHAR(1),
		@intMICRDesignationSpacesCount		AS INT,
		@intMICRDesignationSpacesPosition	AS INT,
		@intCurrencyId						AS NVARCHAR(1)


SELECT					
 @strRoutingNumber					= [dbo].fnAESDecryptASym(strRTN)
,@strMICRRoutingPrefix				= ISNULL(strMICRRoutingPrefix,'')
,@strMICRRoutingSuffix				= ISNULL(strMICRRoutingSuffix,'')	
,@strAccountNumber					= [dbo].fnAESDecryptASym(strBankAccountNo)
,@strMICRBankAccountPrefix			= ISNULL(strMICRBankAccountPrefix,'')
,@strMICRBankAccountSuffix			= ISNULL(strMICRBankAccountSuffix,'')
,@intMICRBankAccountSpacesCount		= intMICRBankAccountSpacesCount		
,@intMICRBankAccountSpacesPosition	= intMICRBankAccountSpacesPosition	
,@intMICRCheckNoSpacesCount			= intMICRCheckNoSpacesCount
,@intMICRCheckNoSpacesPosition		= intMICRCheckNoSpacesPosition
,@intMICRCheckNoLength				= intMICRCheckNoLength
,@intMICRCheckNoPosition			= intMICRCheckNoPosition	
,@strMICRLeftSymbol					= LTRIM(RTRIM(strMICRLeftSymbol))
,@strMICRRightSymbol				= LTRIM(RTRIM(strMICRRightSymbol))
,@strMICRFinancialInstitution				= ISNULL(strMICRFinancialInstitution,'')
,@strMICRFinancialInstitutionPrefix			= ISNULL(strMICRFinancialInstitutionPrefix,'')
,@strMICRFinancialInstitutionSuffix			= ISNULL(strMICRFinancialInstitutionSuffix,'')
,@intMICRFinancialInstitutionSpacesCount	= intMICRFinancialInstitutionSpacesCount		
,@intMICRFinancialInstitutionSpacesPosition	= intMICRFinancialInstitutionSpacesPosition	
,@strMICRDesignation				= ISNULL(strMICRDesignation,'')
,@strMICRDesignationPrefix			= ISNULL(strMICRDesignationPrefix,'')
,@strMICRDesignationSuffix			= ISNULL(strMICRDesignationSuffix,'')
,@intMICRDesignationSpacesCount		= intMICRDesignationSpacesCount		
,@intMICRDesignationSpacesPosition	= intMICRDesignationSpacesPosition	
,@intCurrencyId						= intCurrencyId	
FROM tblCMBankAccount				
WHERE intBankAccountId = @intBankAccountId

--Get the Currency used
DECLARE @strCurrency AS NVARCHAR(50)
SELECT @strCurrency = strCurrency FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyId

--Add Routing Prefix and Suffix
SET @strRoutingNumber = @strMICRRoutingPrefix + @strRoutingNumber + @strMICRRoutingSuffix

--Add Bank Account Prefix and Suffix
SET @strAccountNumber = @strMICRBankAccountPrefix + @strAccountNumber + @strMICRBankAccountSuffix

SET @strCheckNumber = LTRIM(RTRIM(@strCheckNumber))

--Include Financial Institution and Designation when Currency is CAD
IF @strCurrency = 'CAD'
BEGIN
	SET @strMICRFinancialInstitution = @strMICRFinancialInstitutionPrefix + @strMICRFinancialInstitution + @strMICRFinancialInstitutionSuffix

	--add space character padding to the financial institution
	IF @intMICRFinancialInstitutionSpacesCount > 0
	BEGIN
		WHILE @intMICRFinancialInstitutionSpacesCount > 0
		BEGIN
				IF @intMICRFinancialInstitutionSpacesPosition = 1 BEGIN 
					--padding is to the leading
					SET @strMICRFinancialInstitution = ' ' + @strMICRFinancialInstitution
					END
				ELSE IF @intMICRFinancialInstitutionSpacesPosition = 2 BEGIN
					--padding is to the trailing
					SET @strMICRFinancialInstitution = @strMICRFinancialInstitution + ' '
					END
				ELSE
					--default padding is to the leading
					SET @strMICRFinancialInstitution = ' ' + @strMICRFinancialInstitution

			SET @intMICRFinancialInstitutionSpacesCount = @intMICRFinancialInstitutionSpacesCount - 1
		END
	END 

	SET @strMICRDesignation = @strMICRDesignationPrefix + @strMICRDesignation + @strMICRDesignationSuffix

	--add space character padding to the financial institution
	IF @intMICRDesignationSpacesCount > 0
	BEGIN
		WHILE @intMICRDesignationSpacesCount > 0
		BEGIN
				IF @intMICRDesignationSpacesPosition = 1 BEGIN 
					--padding is to the leading
					SET @strMICRDesignation = ' ' + @strMICRDesignation
					END
				ELSE IF @intMICRDesignationSpacesPosition = 2 BEGIN
					--padding is to the trailing
					SET @strMICRDesignation = @strMICRDesignation + ' '
					END
				ELSE
					--default padding is to the leading
					SET @strMICRDesignation = ' ' + @strMICRDesignation

			SET @intMICRDesignationSpacesCount = @intMICRDesignationSpacesCount - 1
		END
	END 

	--Append both to routing number
	SET @strRoutingNumber = @strRoutingNumber + @strMICRFinancialInstitution + @strMICRDesignation
END

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

