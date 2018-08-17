CREATE PROCEDURE uspIPGenerateSAPPNLIDOC_HE (@ysnUpdateFeedStatusOnRead BIT = 0)
AS
DECLARE @intStgMatchPnSId INT
	,@intMatchFuturesPSHeaderId INT
	,@intMatchNo INT
	,@dtmMatchDate DATETIME
	,@strCurrency NVARCHAR(50)
	,@dblMatchQty NUMERIC(18, 6)
	,@dblCommission NUMERIC(18, 6)
	,@dblNetPnL NUMERIC(18, 6)
	,@dblGrossPnL NUMERIC(18, 6)
	,@strBrokerName NVARCHAR(50)
	,@strBrokerAccount NVARCHAR(50)
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
	,@intCompanyLocationId INT
	,@strLocationName NVARCHAR(50)
	,@strSAPLocation NVARCHAR(50)
	,@intFutureMarketId INT
	,@strFutMarketName NVARCHAR(30)
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

SELECT @intMinStageId = Min(intStgMatchPnSId)
FROM tblRKStgMatchPnS
WHERE ISNULL(strStatus, '') = ''

WHILE (@intMinStageId IS NOT NULL)
BEGIN
	SELECT @intStgMatchPnSId = intStgMatchPnSId
		,@intMatchFuturesPSHeaderId = intMatchFuturesPSHeaderId
		,@intMatchNo = intMatchNo
		,@dtmMatchDate = dtmMatchDate
		,@strCurrency = strCurrency
		,@dblMatchQty = dblMatchQty
		,@dblCommission = dblCommission
		,@dblNetPnL = dblNetPnL
		,@dblGrossPnL = dblGrossPnL
		,@strBrokerName = strBrokerName
		,@strBrokerAccount = strBrokerAccount
		,@dtmPostingDate = dtmPostingDate
		,@strStatus = strStatus
		,@strMessage = strMessage
		,@strUserName = strUserName
		,@intCompanyLocationId = intCompanyLocationId
		,@intFutureMarketId = intFutureMarketId
	FROM tblRKStgMatchPnS
	WHERE intStgMatchPnSId = @intMinStageId

	SELECT @strLocationName = strLocationName
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = @intCompanyLocationId

	SELECT @strSAPLocation = strSAPLocation
	FROM tblIPSAPLocation
	WHERE stri21Location = @strLocationName

	SELECT @strFutMarketName = strFutMarketName
	FROM tblRKFutureMarket
	WHERE intFutureMarketId = @intFutureMarketId

	BEGIN
		SET @strXml = '<FIDCCP02>'
		SET @strXml += '<IDOC>'
		--IDOC Header
		SET @strXml += '<EDI_DC40>'
		SET @strXml += @strIDOCHeader
		SET @strXml += '</EDI_DC40>'
		--Set @strXml +=	'<ACC_DOCUMENT SEGMENT="1">'
		--Header
		SET @strXml += '<E1FIKPF>'
		SET @strXml += '<BLDAT>' + ISNULL(CONVERT(VARCHAR(10), @dtmMatchDate, 112), '') + '</BLDAT>'
		SET @strXml += '<BLART>' + 'ZA' + '</BLART>'
		SET @strXml += '<BUKRS>' + ISNULL(@strSAPLocation, '') + '</BUKRS>'
		SET @strXml += '<WAERS>' + ISNULL(@strCurrency, '') + '</WAERS>'
		SET @strXml += '<BKTXT>' + '' + '</BKTXT>'
		SET @strXml += '<XBLNR>' + ISNULL(CONVERT(VARCHAR, @intMatchNo), '') + '-' + ISNULL(@strFutMarketName, '') + '</XBLNR>'
		--GL account details (Broker account)
		SET @strXml += '<E1FISEG>'
		SET @strXml += '<BSCHL>' + '40' + '</BSCHL>'
		SET @strXml += '<HKONT>' + '115501' + '</HKONT>'
		SET @strXml += '<GSBER>' + '800' + '</GSBER>'
		SET @strXml += '<KOSTL>' + '' + '</KOSTL>'
		SET @strXml += '<PRCTR>' + '1134' + '</PRCTR>'
		SET @strXml += '<WRBTR>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblGrossPnL)), '') + '</WRBTR>'
		SET @strXml += '<SGTXT>' + '' + '</SGTXT>'
		SET @strXml += '<MWSKZ>' + '' + '</MWSKZ>'
		SET @strXml += '</E1FISEG>'
		--GL account details (TM account)
		SET @strXml += '<E1FISEG>'
		SET @strXml += '<BSCHL>' + '50' + '</BSCHL>'
		SET @strXml += '<HKONT>' + '439282' + '</HKONT>'
		SET @strXml += '<GSBER>' + '899' + '</GSBER>'
		SET @strXml += '<KOSTL>' + '9012' + '</KOSTL>'
		SET @strXml += '<PRCTR>' + '1162' + '</PRCTR>'
		SET @strXml += '<WRBTR>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), - @dblGrossPnL)), '') + '</WRBTR>'
		SET @strXml += '<SGTXT>' + '' + '</SGTXT>'
		SET @strXml += '<MWSKZ>' + '' + '</MWSKZ>'
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
			@intMinStageId
			,'CREATE'
			,@strXml
			,@intMatchNo
			)
	END

	IF @ysnUpdateFeedStatusOnRead = 1
	BEGIN
		UPDATE tblRKStgMatchPnS
		SET strStatus = 'Awt Ack'
		WHERE intStgMatchPnSId = @intMinStageId
	END

	SELECT @intMinStageId = Min(intStgMatchPnSId)
	FROM tblRKStgMatchPnS
	WHERE intStgMatchPnSId > @intMinStageId
END

SELECT IsNULL(strStgMatchPnSId,'0') as id
			,IsNULL(strXml,'') As strXml
			,IsNULL(strMatchNo,'') as strInfo1
		,''	AS strInfo2
		,'' As strOnFailureCallbackSql
FROM @tblOutput
ORDER BY intRowNo

