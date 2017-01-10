﻿CREATE PROCEDURE [dbo].[uspIPGenerateSAPPNLIDOC]

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
	   @strCostCenter	NVARCHAR(100)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @strIDOCHeader=dbo.fnIPGetSAPIDOCHeader('PO')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')
Select @strCostCenter=dbo.[fnIPGetSAPIDOCTagValue]('PNL','COSTCENTER')

Select @intMinStageId=Min(intStgMatchPnSId) From tblRKStgMatchPnS Where ISNULL(strStatus,'')=''

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
	   @strMessage					=	strMessage
	From tblRKStgMatchPnS Where intStgMatchPnSId>@intMinStageId

	Begin
		Set @strXml =  '<ACC_DOCUMENT03>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	@strIDOCHeader
		Set @strXml +=	'</EDI_DC40>'
		
		Set @strXml +=	'<ACC_DOCUMENT SEGMENT="1">'

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
		Set @strXml += '<GL_ACCOUNT>'	+ ISNULL(@strBrokerAccount,'')				+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')	+ '</ITEM_TEXT>'
		Set @strXml += '<COSTCENTER>'	+ ISNULL(@strCostCenter,'')	+ '</COSTCENTER>'
		Set @strXml +=	'</E1BPACGL09>'

		--GL account details (TM account)
		Set @strXml += '<E1BPACGL09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001001'		+ '</ITEMNO_ACC>'
		Set @strXml += '<GL_ACCOUNT>'	+ '0945102550'				+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@intMatchNo),'')	+ '</ITEM_TEXT>'
		Set @strXml += '<COSTCENTER>'	+ ISNULL(@strCostCenter,'')	+ '</COSTCENTER>'
		Set @strXml +=	'</E1BPACGL09>'

		--Currency items (Broker account)
		Set @strXml += '<E1BPACCR09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001000'		+ '</ITEMNO_ACC>'
		Set @strXml += '<CURRENCY>'	+ ISNULL(@strCurrency,'')				+ '</CURRENCY>'
		Set @strXml += '<AMT_DOCCUR>'	+ ISNULL(CONVERT(VARCHAR,@dblGrossPnL),'')	+ '</AMT_DOCCUR>'
		Set @strXml +=	'</E1BPACCR09>'

		--Currency items (TM account)
		Set @strXml += '<E1BPACCR09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001001'		+ '</ITEMNO_ACC>'
		Set @strXml += '<CURRENCY>'	+ ISNULL(@strCurrency,'')				+ '</CURRENCY>'
		Set @strXml += '<AMT_DOCCUR>'	+ ISNULL(CONVERT(VARCHAR,@dblGrossPnL),'')	+ '</AMT_DOCCUR>'
		Set @strXml +=	'</E1BPACCR09>'

		Set @strXml +=	'</ACC_DOCUMENT>'

		Set @strXml += '</IDOC>'
		Set @strXml +=  '</ACC_DOCUMENT03>'

		INSERT INTO @tblOutput(strRowState,strXml)
		VALUES('CREATE',@strXml)
	End
	Select @intMinStageId=Min(intStgMatchPnSId) From tblRKStgMatchPnS Where intStgMatchPnSId>@intMinStageId
End

Select * From @tblOutput ORDER BY intRowNo