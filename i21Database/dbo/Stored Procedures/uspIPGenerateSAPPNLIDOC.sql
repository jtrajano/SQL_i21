CREATE PROCEDURE [dbo].[uspIPGenerateSAPPNLIDOC]

AS

Declare
       @intStgMatchPnSId INT ,
       @intMatchFuturesPSHeaderId INT , 
       @intMatchNo INT , 
       @dtmMatchDate DATETIME , 
       @strCurrency nvarchar(50)   ,
       @dblMatchQty NUMERIC(18, 6) ,
       @dblCommission NUMERIC(18, 6) ,
       @dblNetPnL NUMERIC(18, 6) ,
       @dblGrossPnL NUMERIC(18, 6) ,        
	   @strBrokerName nvarchar(50)   ,
	   @strBrokerAccount nvarchar(50)   ,
	   @dtmPostingDate datetime ,
	   @strUserName nvarchar(50),
       @strStatus nvarchar(50)   ,
	   @strMessage nvarchar(max),
	   @intMinStageId INT, 
	   @strXml NVARCHAR(MAX),
	   @strIDOCHeader	NVARCHAR(MAX),
	   @strCompCode		NVARCHAR(100),
	   @strCostCenter	NVARCHAR(100),
	   @strGLAccount	NVARCHAR(100)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strStgMatchPnSId NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX),
	strMatchNo NVARCHAR(100)
)

Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('PROFIT AND LOSS')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')
Select @strCostCenter=dbo.[fnIPGetSAPIDOCTagValue]('PROFIT AND LOSS','COSTCENTER')
Select @strGLAccount=dbo.[fnIPGetSAPIDOCTagValue]('PROFIT AND LOSS','GL_ACCOUNT')

Update tblRKStgMatchPnS Set strStatus='IGNORE' Where IsNULL(ysnPost,0)=0 AND IsNULL(strStatus,'')=''

Select @intMinStageId=Min(intStgMatchPnSId) From tblRKStgMatchPnS Where ISNULL(strStatus,'')='' AND IsNULL(ysnPost,0)=1 

While(@intMinStageId is not null)
Begin
	Select 
       @intStgMatchPnSId			=	intStgMatchPnSId ,
       @intMatchFuturesPSHeaderId	=	intMatchFuturesPSHeaderId , 
       @intMatchNo					=	intMatchNo , 
       @dtmMatchDate				=	dtmMatchDate , 
       @strCurrency					=	strCurrency   ,
       @dblMatchQty					=	dblMatchQty ,
       @dblCommission				=	dblCommission ,
       @dblNetPnL					=	dblNetPnL ,
       @dblGrossPnL					=	dblGrossPnL ,        
	   @strBrokerName				=	strBrokerName   ,
	   @strBrokerAccount			=	strBrokerAccount   ,
	   @dtmPostingDate				=	dtmPostingDate ,
       @strStatus					=	strStatus   ,
	   @strMessage					=	strMessage,
	   @strUserName					=	strUserName
	From tblRKStgMatchPnS Where intStgMatchPnSId=@intMinStageId

	IF ISNULL((
			SELECT TOP 1 ISNULL(ysnPost, 0)
			FROM tblRKStgMatchPnS
			WHERE intMatchNo = @intMatchNo
				AND intStgMatchPnSId < @intMinStageId
			ORDER BY intStgMatchPnSId DESC
			), 0) = 1
	BEGIN
		UPDATE tblRKStgMatchPnS
		SET strStatus = 'IGNORE'
		WHERE intStgMatchPnSId = @intMinStageId

		GOTO NEXT_GL
	END

	Begin
		Set @strXml =  '<ACC_DOCUMENT03>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	@strIDOCHeader
		Set @strXml +=	'</EDI_DC40>'
		
		--Set @strXml +=	'<ACC_DOCUMENT SEGMENT="1">'

		--Header
		Set @strXml += '<E1BPACHE09 SEGMENT="1">'
		Set @strXml += '<OBJ_TYPE>'		+ 'BKPFF'							+ '</OBJ_TYPE>'
		Set @strXml += '<OBJ_KEY>'		+ ISNULL(CONVERT(VARCHAR,@intMatchFuturesPSHeaderId),'')			+ '</OBJ_KEY>'
		Set @strXml += '<USERNAME>'		+ ISNULL(@strUserName,'')	+ '</USERNAME>'
		Set @strXml += '<HEADER_TXT>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')	+ '</HEADER_TXT>'
		Set @strXml += '<COMP_CODE>'	+ ISNULL(@strCompCode,'')					+ '</COMP_CODE>'
		Set @strXml += '<DOC_DATE>'		+ ISNULL(CONVERT(VARCHAR(10),@dtmMatchDate,112),'')	+ '</DOC_DATE>'
		Set @strXml += '<PSTNG_DATE>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmPostingDate,112),'')	+ '</PSTNG_DATE>'
		Set @strXml += '<DOC_TYPE>'		+ 'SA'	+ '</DOC_TYPE>'
		Set @strXml += '<REF_DOC_NO>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')			+ '</REF_DOC_NO>'
		Set @strXml +=	'</E1BPACHE09>'

		--GL account details (Broker account)
		Set @strXml += '<E1BPACGL09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001000'		+ '</ITEMNO_ACC>'
		Set @strXml += '<GL_ACCOUNT>'	+ right('0' + ISNULL(@strBrokerAccount,''),10)	+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')	+ '</ITEM_TEXT>'
		Set @strXml += '<COSTCENTER>'	+ ISNULL(@strCostCenter,'')	+ '</COSTCENTER>'
		Set @strXml +=	'</E1BPACGL09>'

		--GL account details (TM account)
		Set @strXml += '<E1BPACGL09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001001'		+ '</ITEMNO_ACC>'
		Set @strXml += '<GL_ACCOUNT>'	+ ISNULL(@strGLAccount,'')	+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')	+ '</ITEM_TEXT>'
		Set @strXml += '<COSTCENTER>'	+ ISNULL(@strCostCenter,'')	+ '</COSTCENTER>'
		Set @strXml +=	'</E1BPACGL09>'

		--Currency items (Broker account)
		Set @strXml += '<E1BPACCR09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001000'		+ '</ITEMNO_ACC>'
		Set @strXml += '<CURRENCY>'	+ ISNULL(@strCurrency,'')				+ '</CURRENCY>'
		Set @strXml += '<AMT_DOCCUR>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblGrossPnL)),'')	+ '</AMT_DOCCUR>'
		Set @strXml +=	'</E1BPACCR09>'

		--Currency items (TM account)
		Set @strXml += '<E1BPACCR09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001001'		+ '</ITEMNO_ACC>'
		Set @strXml += '<CURRENCY>'	+ ISNULL(@strCurrency,'')				+ '</CURRENCY>'
		Set @strXml += '<AMT_DOCCUR>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),-@dblGrossPnL)),'')	+ '</AMT_DOCCUR>'
		Set @strXml +=	'</E1BPACCR09>'

		--Set @strXml +=	'</ACC_DOCUMENT>'

		Set @strXml += '</IDOC>'
		Set @strXml +=  '</ACC_DOCUMENT03>'

		INSERT INTO @tblOutput(strStgMatchPnSId,strRowState,strXml,strMatchNo)
		VALUES(@intMinStageId,'CREATE',@strXml,@intMatchNo)
	End
	
	NEXT_GL:

	Select @intMinStageId=Min(intStgMatchPnSId) From tblRKStgMatchPnS Where intStgMatchPnSId>@intMinStageId and ISNULL(strStatus,'')=''AND IsNULL(ysnPost,0)=1
End

Select * From @tblOutput ORDER BY intRowNo