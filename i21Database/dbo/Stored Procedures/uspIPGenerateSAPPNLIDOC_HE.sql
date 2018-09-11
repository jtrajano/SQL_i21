CREATE PROCEDURE uspIPGenerateSAPPNLIDOC_HE (@ysnUpdateFeedStatusOnRead BIT = 0)
AS
DECLARE @intStgMatchPnSId INT
	,@intMatchNo INT
	,@dtmMatchDate DATETIME
	,@strCurrency NVARCHAR(50)
	,@dblMatchQty NUMERIC(18, 6)
	,@dblGrossPnL NUMERIC(18, 6)
	,@dtmPostingDate DATETIME
	,@strUserName NVARCHAR(50)
	,@strStatus NVARCHAR(50)
	,@strMessage NVARCHAR(max)
	,@intMinStageId INT
	,@strXml NVARCHAR(MAX)
	,@strIDOCHeader NVARCHAR(MAX)
	,@strCompCode NVARCHAR(100)
	,@strCostCenter NVARCHAR(100)
	,@strGLAccount NVARCHAR(100)
	,@strLocationName NVARCHAR(50)
	,@strSAPLocation NVARCHAR(50)
	,@strFutMarketName NVARCHAR(30)
	,@intRecordId INT
	,@ysnFuture BIT
	,@strReferenceNo NVARCHAR(MAX)
	,@strText nvarchar(MAX)
	,@strMessageCode nvarchar(50)
DECLARE @tblOutput AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,strStgMatchPnSId NVARCHAR(MAX)
	,strRowState NVARCHAR(50)
	,strXml NVARCHAR(MAX)
	,strMatchNo NVARCHAR(100)
	)

SELECT @strIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PROFIT AND LOSS')

SELECT @strCompCode = dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL', 'COMP_CODE')

SELECT @strCostCenter = dbo.[fnIPGetSAPIDOCTagValue]('PROFIT AND LOSS', 'COSTCENTER')

SELECT @strGLAccount = dbo.[fnIPGetSAPIDOCTagValue]('PROFIT AND LOSS', 'GL_ACCOUNT')

Select @strMessageCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL', 'MESCOD')

DECLARE @tblRKStgMatchPnS TABLE (
	intRecordId INT Identity(1, 1)
	,intStgMatchPnSId INT
	,intMatchNo INT
	,dtmMatchDate DATETIME
	,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblGrossPnL NUMERIC(18, 6)
	,dtmPostingDate DATETIME
	,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strReferenceNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnFuture BIT
	,strText nvarchar(MAX)
	)
DECLARE @intToCurrencyId INT

SELECT @intToCurrencyId = intCurrencyID
FROM tblSMCurrency
WHERE strCurrency = 'USD'

Update tblRKStgMatchPnS Set strStatus='IGNORE' Where IsNULL(ysnPost,0)=0 AND IsNULL(strStatus,'')=''
Update tblRKStgOptionMatchPnS Set strStatus='IGNORE' Where IsNULL(ysnPost,0)=0 AND IsNULL(strStatus,'')=''

INSERT INTO @tblRKStgMatchPnS (
	intStgMatchPnSId
	,intMatchNo
	,dtmMatchDate
	,strCurrency
	,dblGrossPnL
	,dtmPostingDate
	,strLocationName
	,strReferenceNo
	,ysnFuture
	,strText
	)
SELECT S.intStgMatchPnSId
	,S.intMatchNo
	,S.dtmMatchDate
	,S.strCurrency
	,[dbo].[fnCTCalculateAmountBetweenCurrency](C.intCurrencyID, @intToCurrencyId, S.dblNetPnL, 0)
	,S.dtmPostingDate
	,L.strLocationName
	,Left('F-'+ISNULL(CONVERT(VARCHAR, S.intMatchNo), '') + ISNULL('-' + strBook, '') + '-' + ISNULL(FM.strFutMarketName, ''),16) AS strReference
	,1
	,ISNULL(S.strBook+' - ', '')+ISNULL(CONVERT(VARCHAR, S.intMatchNo), '')  
FROM tblRKStgMatchPnS S
JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = S.intFutureMarketId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = S.intCompanyLocationId
JOIN tblSMCurrency C ON C.strCurrency = S.strCurrency
WHERE ISNULL(S.strStatus, '') = '' AND IsNULL(S.ysnPost,0)=1

INSERT INTO @tblRKStgMatchPnS (
	intStgMatchPnSId
	,intMatchNo
	,dtmMatchDate
	,strCurrency
	,dblGrossPnL
	,dtmPostingDate
	,strLocationName
	,strReferenceNo
	,ysnFuture
	,strText
	)
SELECT intStgOptionMatchPnSId
	,intMatchNo
	,dtmMatchDate
	,PS.strCurrency
	,[dbo].[fnCTCalculateAmountBetweenCurrency](C.intCurrencyID, @intToCurrencyId, PS.dblGrossPnL, 0)
	,dtmPostingDate
	,strLocationName
	,Left('O-'+ISNULL(CONVERT(VARCHAR, intMatchNo), '') + ISNULL('-' + strBook, '') + '-' + ISNULL(strFutMarketName, ''),16) AS strReference
	,0
	,ISNULL(PS.strBook+' - ', '')+ISNULL(CONVERT(VARCHAR, PS.intMatchNo), '') 
FROM tblRKStgOptionMatchPnS PS
JOIN tblSMCurrency C ON C.strCurrency = PS.strCurrency
WHERE ISNULL(strStatus, '') = ''AND IsNULL(PS.ysnPost,0)=1

SELECT @intRecordId = Min(intRecordId)
FROM @tblRKStgMatchPnS

WHILE (@intRecordId IS NOT NULL)
BEGIN
	SELECT @intStgMatchPnSId = intStgMatchPnSId
		,@intMatchNo = intMatchNo
		,@dtmMatchDate = dtmMatchDate
		,@strCurrency = strCurrency
		,@dblGrossPnL = dblGrossPnL
		,@dtmPostingDate = dtmPostingDate
		,@strLocationName = strLocationName
		,@strReferenceNo = strReferenceNo
		,@ysnFuture=ysnFuture
		,@strText=strText
	FROM @tblRKStgMatchPnS
	WHERE intRecordId = @intRecordId

	SELECT @strSAPLocation = strSAPLocation
	FROM tblIPSAPLocation
	WHERE stri21Location = @strLocationName

	BEGIN
		SET @strXml = '<FIDCCP02>'
		SET @strXml += '<IDOC>'
		--IDOC Header
		SET @strXml += '<EDI_DC40>'
		SET @strXml += @strIDOCHeader
		SET @strXml += '<MESCOD>' + ISNULL(@strMessageCode, '') + '</MESCOD>'
		SET @strXml += '</EDI_DC40>'
		--Header
		SET @strXml += '<E1FIKPF>'
		SET @strXml += '<BUKRS>' + ISNULL(@strSAPLocation, '') + '</BUKRS>'
		SET @strXml += '<BLART>' + 'ZA' + '</BLART>'
		SET @strXml += '<BLDAT>' + ISNULL(CONVERT(VARCHAR(10), @dtmMatchDate, 112), '') + '</BLDAT>'
		SET @strXml += '<XBLNR>' + ISNULL(@strReferenceNo, '') + '</XBLNR>'
		SET @strXml += '<BKTXT>' + '' + '</BKTXT>'
		SET @strXml += '<WAERS>' + ISNULL('USD', '') + '</WAERS>'
		--GL account details (Broker account)
		SET @strXml += '<E1FISEG>'
		SET @strXml += '<BUZEI>' + '001' + '</BUZEI>'
		SET @strXml += '<BSCHL>' + Case When @dblGrossPnL>0 then '40' Else '50' End + '</BSCHL>'
		SET @strXml += '<GSBER>' + '800' + '</GSBER>'
		SET @strXml += '<MWSKZ>' + '' + '</MWSKZ>'
		SET @strXml += '<WRBTR>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), ABS(@dblGrossPnL))), '') + '</WRBTR>'
		SET @strXml += '<SGTXT>' + ISNULL(@strText,'') + '</SGTXT>'
		SET @strXml += '<KOSTL>' + '' + '</KOSTL>'
		SET @strXml += '<HKONT>' + '115501' + '</HKONT>'
		SET @strXml += '<PRCTR>' + '1134' + '</PRCTR>'
		SET @strXml += '</E1FISEG>'
		--GL account details (TM account)
		SET @strXml += '<E1FISEG>'
		SET @strXml += '<BUZEI>' + '002' + '</BUZEI>'
		SET @strXml += '<BSCHL>' + Case When @dblGrossPnL>0 then '50' Else '40' End + '</BSCHL>'
		SET @strXml += '<GSBER>' + '899' + '</GSBER>'
		SET @strXml += '<MWSKZ>' + '' + '</MWSKZ>'
		SET @strXml += '<WRBTR>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), ABS(@dblGrossPnL))), '') + '</WRBTR>'
		SET @strXml += '<SGTXT>' + ISNULL(@strText,'') + '</SGTXT>'
		SET @strXml += '<KOSTL>' + '9012' + '</KOSTL>'
		SET @strXml += '<HKONT>' + '439282' + '</HKONT>'
		SET @strXml += '<PRCTR>' + '1162' + '</PRCTR>'
		SET @strXml += '</E1FISEG>'
		SET @strXml += '</E1FIKPF>'
		SET @strXml += '</IDOC>'
		SET @strXml += '</FIDCCP02>'

		INSERT INTO @tblOutput (
			strStgMatchPnSId
			,strRowState
			,strXml
			,strMatchNo
			)
		VALUES (
			@intStgMatchPnSId
			,'CREATE'
			,@strXml
			,@intMatchNo
			)
	END

	IF @ysnUpdateFeedStatusOnRead = 1
	BEGIN
		IF @ysnFuture = 1
		BEGIN
			UPDATE tblRKStgMatchPnS
			SET strStatus = 'Awt Ack'
				,strReferenceNo = @strReferenceNo
			WHERE intStgMatchPnSId = @intStgMatchPnSId
		END
		ELSE
		BEGIN
			UPDATE tblRKStgOptionMatchPnS
			SET strStatus = 'Awt Ack'
				,strReferenceNo = @strReferenceNo
			WHERE intStgOptionMatchPnSId = @intStgMatchPnSId
		END
	END

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblRKStgMatchPnS
	WHERE intRecordId > @intRecordId
END

SELECT IsNULL(strStgMatchPnSId, '0') AS id
	,IsNULL(strXml, '') AS strXml
	,IsNULL(strMatchNo, '') AS strInfo1
	,'' AS strInfo2
	,'' AS strOnFailureCallbackSql
FROM @tblOutput
ORDER BY intRowNo
