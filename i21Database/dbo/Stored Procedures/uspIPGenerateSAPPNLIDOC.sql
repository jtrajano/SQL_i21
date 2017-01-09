CREATE PROCEDURE [dbo].[uspIPGenerateSAPPNLIDOC]

AS

Declare @tblRKMatchPnSStage AS TABLE
(
       [intMatchPnSStageId] INT IDENTITY(1,1) NOT NULL,
	   [intConcurrencyId] INT NOT NULL, 
       [strObjType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [intMatchHeaderKey] INT NOT NULL, 
       [strUserName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strHeaderText] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
       [strCompanyCode] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
       [dtmDocDate] datetime,
       [dtmPostingDate] datetime,
       [strDocType] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strRefDocNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strBrokerName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,      
       [intMatchNo] INT NOT NULL,
       [strCostCenter] nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
       [strBrokerAccountNumber] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [dblGrossPnL] NUMERIC(18, 6) NULL,
       [strCurrency] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
       [strStatus] nvarchar(50) COLLATE Latin1_General_CI_AS NULL
)

Declare
       @intMatchPnSStageId INT,
	   @intConcurrencyId INT , 
       @strObjType nvarchar(50)  ,
       @intMatchHeaderKey INT , 
       @strUserName nvarchar(50)  ,
       @strHeaderText nvarchar(100)  ,
       @strCompanyCode nvarchar(100)  ,
       @dtmDocDate datetime,
       @dtmPostingDate datetime,
       @strDocType nvarchar(50)  ,
       @strRefDocNumber nvarchar(50)  ,
       @strBrokerName nvarchar(50)  ,      
       @intMatchNo INT ,
       @strCostCenter nvarchar(100)  ,
       @strBrokerAccountNumber nvarchar(50)  ,
       @dblGrossPnL NUMERIC(18, 6) ,
       @strCurrency nvarchar(50)  ,
       @strStatus nvarchar(50) ,
	   @intMinStageId INT, 
	   @strXml NVARCHAR(MAX)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
)

Select @intMinStageId=Min(intMatchPnSStageId) From @tblRKMatchPnSStage Where ISNULL(strStatus,'')=''

While(@intMinStageId is not null)
Begin
	Select 
       @intMatchPnSStageId		=	intMatchPnSStageId,
	   @intConcurrencyId		=	intConcurrencyId , 
       @strObjType				=	strObjType  ,
       @intMatchHeaderKey		=	intMatchHeaderKey , 
       @strUserName				=	strUserName  ,
       @strHeaderText			=	strHeaderText  ,
       @strCompanyCode			=	strCompanyCode  ,
       @dtmDocDate				=	dtmDocDate,
       @dtmPostingDate			=	dtmPostingDate,
       @strDocType				=	strDocType  ,
       @strRefDocNumber			=	strRefDocNumber  ,
       @strBrokerName			=	strBrokerName  ,      
       @intMatchNo				=	intMatchNo,
       @strCostCenter			=	strCostCenter  ,
       @strBrokerAccountNumber	=	strBrokerAccountNumber  ,
       @dblGrossPnL				=	dblGrossPnL ,
       @strCurrency				=	strCurrency  ,
       @strStatus				=	strStatus
	From @tblRKMatchPnSStage Where intMatchPnSStageId>@intMinStageId

	Begin
		Set @strXml =  '<ACC_DOCUMENT03>'
		Set @strXml += '<IDOC BEGIN="1">'

		--IDOC Header
		Set @strXml +=	'<EDI_DC40 SEGMENT="1">'
		Set @strXml +=	'</EDI_DC40>'
		
		Set @strXml +=	'<ACC_DOCUMENT SEGMENT="1">'

		--Header
		Set @strXml += '<E1BPACHE09 SEGMENT="1">'
		Set @strXml += '<OBJ_TYPE>'		+ 'BKPFF'							+ '</OBJ_TYPE>'
		Set @strXml += '<OBJ_KEY>'		+ ISNULL(CONVERT(VARCHAR,@intMatchHeaderKey),'')			+ '</OBJ_KEY>'
		Set @strXml += '<USERNAME>'		+ ISNULL(@strUserName,'')	+ '</USERNAME>'
		Set @strXml += '<HEADER_TXT>'	+ ISNULL(@strHeaderText,'')	+ '</HEADER_TXT>'
		Set @strXml += '<COMP_CODE>'	+ '0440'					+ '</COMP_CODE>'
		Set @strXml += '<DOC_DATE>'		+ ISNULL(CONVERT(VARCHAR(10),@dtmDocDate,112),'')	+ '</DOC_DATE>'
		Set @strXml += '<PSTNG_DATE>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmPostingDate,112),'')	+ '</PSTNG_DATE>'
		Set @strXml += '<DOC_TYPE>'		+ 'SA'	+ '</DOC_TYPE>'
		Set @strXml += '<REF_DOC_NO>'	+ ISNULL(CONVERT(VARCHAR,@strRefDocNumber),'')			+ '</REF_DOC_NO>'
		Set @strXml +=	'</E1BPACHE09>'

		--GL account details (Broker account)
		Set @strXml += '<E1BPACGL09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001000'		+ '</ITEMNO_ACC>'
		Set @strXml += '<GL_ACCOUNT>'	+ ISNULL(@strBrokerAccountNumber,'')				+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@strRefDocNumber),'')	+ '</ITEM_TEXT>'
		Set @strXml += '<COSTCENTER>'	+ ISNULL(@strCostCenter,'')	+ '</COSTCENTER>'
		Set @strXml +=	'</E1BPACGL09>'

		--GL account details (TM account)
		Set @strXml += '<E1BPACGL09 SEGMENT="1">'
		Set @strXml += '<ITEMNO_ACC>'	+ '0000001001'		+ '</ITEMNO_ACC>'
		Set @strXml += '<GL_ACCOUNT>'	+ '0945102550'				+ '</GL_ACCOUNT>'
		Set @strXml += '<ITEM_TEXT>'	+ ISNULL(CONVERT(VARCHAR,@strRefDocNumber),'')	+ '</ITEM_TEXT>'
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
	Select @intMinStageId=Min(intMatchPnSStageId) From @tblRKMatchPnSStage Where intMatchPnSStageId>@intMinStageId
End

Select * From @tblOutput ORDER BY intRowNo