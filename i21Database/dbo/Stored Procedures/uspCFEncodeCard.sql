CREATE PROCEDURE [dbo].[uspCFEncodeCard]
	 @userId INT
AS
BEGIN

	 DELETE FROM tblCFEncodingPrinterSoftware
	 DECLARE @EncodeCardStagingTable	TABLE
	 (
		intId							INT				IDENTITY(1,1)
		,strISO							NVARCHAR(MAX)
		,intAccountLength				INT
		,intCardLength					INT
		,strNetworkISO					NVARCHAR(MAX)
		,intNetworkAccountLength		INT
		,intNetworkCardLength			INT
		,strCardTypeISO					NVARCHAR(MAX)
		,intCardTypeAccountLength		INT
		,intCardTypeCardLength			INT
		,intEntryCode					INT
		,strNetworkType					NVARCHAR(MAX)
		,strCustomerNumber				NVARCHAR(MAX)
		,strCustomerName				NVARCHAR(MAX)
		,strCardNumber					NVARCHAR(MAX)
		,strCardDescription				NVARCHAR(MAX)
		,strCardNotation				NVARCHAR(MAX)
		,strCardType					NVARCHAR(MAX)
		,strCardPinNumber				NVARCHAR(MAX)
		,intCustomerId					INT
		,intCardId						INT
		,intCardTypeId					INT
		,intNetworkId					INT
		,intEncodeCardId				INT
		,intConcurrencyId				INT
		,dtmCardExpiratioYearMonth		DATETIME
		,dtmGlobalCardExpirationDate	DATETIME
		,strCompanyName					NVARCHAR(MAX)
		,strCompanyAddress				NVARCHAR(MAX)
		,strCompanyPhone				NVARCHAR(MAX)
		,strCompanyEmail				NVARCHAR(MAX)
		,strBillTo						NVARCHAR(MAX)
	 )

	 INSERT INTO @EncodeCardStagingTable
	 (
		 strISO						
		,intAccountLength			
		,intCardLength				
		,strNetworkISO				
		,intNetworkAccountLength	
		,intNetworkCardLength		
		,strCardTypeISO				
		,intCardTypeAccountLength	
		,intCardTypeCardLength		
		,intEntryCode				
		,strNetworkType				
		,strCustomerNumber			
		,strCustomerName			
		,strCardNumber				
		,strCardDescription			
		,strCardNotation			
		,strCardType				
		,strCardPinNumber			
		,intCustomerId				
		,intCardId					
		,intCardTypeId				
		,intNetworkId				
		,intEncodeCardId			
		,intConcurrencyId			
		,dtmCardExpiratioYearMonth	
		,dtmGlobalCardExpirationDate
		,strCompanyName				
		,strCompanyAddress			
		,strCompanyPhone			
		,strCompanyEmail			
		,strBillTo					
	 )
	 SELECT
		 strISO						
		,intAccountLength			
		,intCardLength				
		,strNetworkISO				
		,intNetworkAccountLength	
		,intNetworkCardLength		
		,strCardTypeISO				
		,intCardTypeAccountLength	
		,intCardTypeCardLength		
		,intEntryCode				
		,strNetworkType				
		,strCustomerNumber			
		,strCustomerName			
		,strCardNumber				
		,strCardDescription			
		,strCardNotation			
		,strCardType				
		,strCardPinNumber			
		,intCustomerId				
		,intCardId					
		,intCardTypeId				
		,intNetworkId				
		,intEncodeCardId			
		,intConcurrencyId			
		,dtmCardExpiratioYearMonth	
		,dtmGlobalCardExpirationDate
		,strCompanyName				
		,strCompanyAddress			
		,strCompanyPhone			
		,strCompanyEmail			
		,strBillTo
	FROM vyuCFEncodeCard
	WHERE intEncodeCardId IN (SELECT intEncodeCardId FROM tblCFEncodeCardStagingTable)

	DECLARE @loopId INT
	DECLARE @minDate DATETIME

	SET @minDate = cast('1900-1-1' as DATETIME)

	WHILE (EXISTS(SELECT 1 FROM @EncodeCardStagingTable))
	BEGIN
		DECLARE @dtmGlobalCardExpirationDate	DATETIME
		DECLARE @dtmCardExpiratioYearMonth		DATETIME
		DECLARE @intEntryCode					INT
		DECLARE @intAccountLength				INT
		DECLARE @intCardLength					INT

		--PRINTER FIELD--
		DECLARE @strExpirationDate	NVARCHAR(MAX)
		DECLARE @strISO				NVARCHAR(MAX)
		DECLARE @strEntryCode		NVARCHAR(MAX)
		DECLARE @strCustomerNumber	NVARCHAR(MAX)
		DECLARE @strCustomerName	NVARCHAR(MAX)
		DECLARE @strCardNumber		NVARCHAR(MAX)
		DECLARE @strAccountLength	NVARCHAR(MAX)
		DECLARE @strCardLength		NVARCHAR(MAX)
		DECLARE @strFullCardNumber  NVARCHAR(MAX)
		DECLARE @strFullDisplayCard NVARCHAR(MAX)
		DECLARE @strDisplayCard		NVARCHAR(MAX)
		DECLARE @strDateMMYY		NVARCHAR(MAX)
		DECLARE @strDateYYMM		NVARCHAR(MAX)
		DECLARE @strEncode1			NVARCHAR(MAX)
		DECLARE @strEncode2			NVARCHAR(MAX)
		DECLARE @strCardNotation	NVARCHAR(MAX)
		
		
		
		
		--COLLECT DATA--
		SELECT TOP 1 
		 @loopId = intId
		,@dtmCardExpiratioYearMonth		= ISNULL(dtmCardExpiratioYearMonth,@minDate)
		,@dtmGlobalCardExpirationDate	= ISNULL(dtmGlobalCardExpirationDate,@minDate)
		,@strISO						= ISNULL(strISO,'')
		,@intEntryCode					= ISNULL(intEntryCode,0)
		,@strCustomerNumber				= ISNULL(strCustomerNumber,'')
		,@strCustomerName				= ISNULL(strCustomerName,'')
		,@strCardNumber					= ISNULL(strCardNumber,'')
		,@strAccountLength				= CAST(ISNULL(intAccountLength,0) AS NVARCHAR(MAX))	
		,@strCardLength					= CAST(ISNULL(intCardLength,0) AS NVARCHAR(MAX))	
		,@intAccountLength				= ISNULL(intAccountLength,0) 
		,@intCardLength					= ISNULL(intCardLength,0) 
		,@strCardNotation				= ISNULL(strCardNotation,'')
		FROM @EncodeCardStagingTable

		--EXPIRATION DATE--
		IF(@dtmCardExpiratioYearMonth != @minDate)
		BEGIN
			SET @strExpirationDate = CAST(MONTH(@dtmCardExpiratioYearMonth) AS NVARCHAR(2)) + '/' + CAST(RIGHT(YEAR(@dtmCardExpiratioYearMonth),2) AS NVARCHAR(2)) --FORMAT(@dtmCardExpiratioYearMonth,'MM/yy') 
			SET @strDateMMYY =  CAST(MONTH(@dtmCardExpiratioYearMonth) AS NVARCHAR(2)) + CAST(RIGHT(YEAR(@dtmCardExpiratioYearMonth),2) AS NVARCHAR(2)) 
			SET @strDateYYMM = CAST(RIGHT(YEAR(@dtmCardExpiratioYearMonth),2) AS NVARCHAR(2)) + CAST(dbo.fnCFPadString(MONTH(@dtmCardExpiratioYearMonth) , 2, '0', 'left')  AS NVARCHAR(2)) 
	
		END
		ELSE
		BEGIN
			SET @strExpirationDate = CAST(MONTH(@dtmGlobalCardExpirationDate) AS NVARCHAR(2)) + '/' + CAST(RIGHT(YEAR(@dtmGlobalCardExpirationDate),2) AS NVARCHAR(2))
			SET @strDateMMYY =  CAST(MONTH(@dtmGlobalCardExpirationDate) AS NVARCHAR(2)) + '/' + CAST(RIGHT(YEAR(@dtmGlobalCardExpirationDate),2) AS NVARCHAR(2))
			SET @strDateYYMM = CAST(RIGHT(YEAR(@dtmGlobalCardExpirationDate),2) AS NVARCHAR(2)) + CAST(dbo.fnCFPadString(MONTH(@dtmGlobalCardExpirationDate) , 2, '0', 'left')  AS NVARCHAR(2)) 
		END

		--ENTRY CODE--
		SET @strEntryCode = 
		CASE 
			WHEN @intEntryCode = 0 THEN '0'
			WHEN @intEntryCode = 1 THEN '1'
			WHEN @intEntryCode = 2 THEN '2'
			WHEN @intEntryCode = 3 THEN '3'
			WHEN @intEntryCode = 4 THEN '4'
			WHEN @intEntryCode = 5 THEN '5'
			WHEN @intEntryCode = 6 THEN '6'
			WHEN @intEntryCode = 7 THEN '7'
			ELSE '0'
		END

		--FULL CARD NUMBER--
		SET @strFullCardNumber = dbo.fnCFConstructFullCardNumber(@strISO,@intEntryCode,@strCustomerNumber,@strCardNumber,@intAccountLength,@intCardLength)

		--FULL DISPLAY CARD--
		SET @strFullDisplayCard = SUBSTRING(@strFullCardNumber,((ISNULL(LEN(@strFullCardNumber),0) - 19) + 1), 19) 
		SET @strDisplayCard = dbo.fnCFCardNumberToMaximaFormat(@strFullDisplayCard,0)

		--ENCODING--
		DECLARE @strCustomerNameNoSpecialChar NVARCHAR(MAX) 
		SET @strCustomerNameNoSpecialChar = dbo.fnCFRemoveSpecialCharStrict(@strCustomerName,'')

		DECLARE @strCustomerNameNoSpecialCharPadded NVARCHAR(MAX) 
		SET @strCustomerNameNoSpecialCharPadded = dbo.fnCFPadString(@strCustomerNameNoSpecialChar,26,' ','right')

		DECLARE @strCustomerNameNoSpecialCharSubstring NVARCHAR(MAX)
		SET @strCustomerNameNoSpecialCharSubstring = SUBSTRING(@strCustomerNameNoSpecialCharPadded,0,26)

		SET @strEncode2 = @strFullDisplayCard +  '=' +  @strDateYYMM
		SET @strEncode1 = @strFullDisplayCard +  '^' +  @strCustomerNameNoSpecialCharSubstring + '^' +  dbo.fnCFPadString(@strDateYYMM,26,' ', 'right')
		SET @strEncode2 = @strFullDisplayCard +  '=' +  @strDateYYMM

		INSERT INTO tblCFEncodingPrinterSoftware
		(
			 AcctName
			,DispCardId
			,Notation
			,Exp
			,EncodeTrack2
			,EncodeTrack1
		)
		SELECT
			 @strCustomerName
			,@strDisplayCard
			,@strCardNotation
			,'EXP ' + @strExpirationDate
			,@strEncode2
			,@strEncode1

		--LOOP -1-- 
		DELETE FROM @EncodeCardStagingTable WHERE intId = @loopId
	END

	SELECT * FROM tblCFEncodingPrinterSoftware 

END