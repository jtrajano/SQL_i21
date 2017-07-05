CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC]
	@ysnUpdateFeedStatusOnRead bit=0
AS

Declare @intMinSeq					INT,
		@intContractFeedId			INT ,
		@intContractHeaderId		INT,
		@intContractDetailId		INT,
		@strCommodityCode			NVARCHAR(100) ,
		@strCommodityDesc			NVARCHAR(100) ,
		@strContractBasis			NVARCHAR(100) ,--INCOTERMS1
		@strContractBasisDesc		NVARCHAR(500) ,--INCOTERMS2
		@strSubLocation				NVARCHAR(50) , --L-Plant / PLANT 
		@strCreatedBy				NVARCHAR(50) , 
		@strCreatedByNo				NVARCHAR(50) , 
		@strEntityNo				NVARCHAR (100) , --VENDOR 
		@strTerm					NVARCHAR (100)  , --PMNTTRMS / VEND_PART 
		@strPurchasingGroup			NVARCHAR(150), 
		@strContractNumber			NVARCHAR (100)  ,
		@strERPPONumber				NVARCHAR (100)  ,
		@intContractSeq				INT, --PO_ITEM 
		@strItemNo					NVARCHAR (100)  ,
		@strStorageLocation			NVARCHAR(50) , --STGE_LOC 
		@dblQuantity				NUMERIC(18,6),
		@strQuantityUOM				NVARCHAR(50) , --PO_UNIT
		@dblCashPrice				NUMERIC(18,6), --NET_PRICE
		@dblUnitCashPrice			NUMERIC(18,6), --PRICE_UNIT 
		@dtmPlannedAvailabilityDate DATETIME, --DELIVERY_DATE 
		@dtmContractDate			DATETIME, 
		@dtmStartDate				DATETIME, 
		@dtmEndDate					DATETIME, 
		@dblBasis					NUMERIC(18,6), --COND_VALUE,
		@strCurrency				NVARCHAR(50) ,--CURRENCY 
		@strPriceUOM				NVARCHAR(50) , --COND_UNIT 
		@strRowState				NVARCHAR(50) ,
		@strFeedStatus				NVARCHAR(50) ,
		@strXml						NVARCHAR(MAX),
		@strDocType					NVARCHAR(50),
		@strPOCreateIDOCHeader		NVARCHAR(MAX),
		@strPOUpdateIDOCHeader		NVARCHAR(MAX),
		@strCompCode				NVARCHAR(100),
		@intMinRowNo				INT,
		@strXmlHeaderStart			NVARCHAR(MAX),
		@strXmlHeaderEnd			NVARCHAR(MAX),
		@strHeaderState				NVARCHAR(50),
		@strContractFeedIds			NVARCHAR(MAX),
		@strERPPONumber1			NVARCHAR (100),
		@strCertificates			NVARCHAR(MAX),
		@strOrigin					NVARCHAR(100),
		@strContractItemNo			NVARCHAR(500),
		@strItemXml					NVARCHAR(MAX),
		@strItemXXml				NVARCHAR(MAX),
		@strScheduleXml				NVARCHAR(MAX),
		@strScheduleXXml			NVARCHAR(MAX),
		@strCondXml					NVARCHAR(MAX),
		@strCondXXml				NVARCHAR(MAX),
		@strTextXml					NVARCHAR(MAX),
		@strSeq						NVARCHAR(MAX),
		@strProductType				NVARCHAR(100),
		@strVendorBatch				NVARCHAR(100),
		@str10Zeros					NVARCHAR(50)='0000000000',
		@strLoadingPoint			NVARCHAR(200)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strContractFeedIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX),
	strContractNo NVARCHAR(100),
	strPONo NVARCHAR(100)
)

Declare @tblHeader AS Table
(
	intRowNo INT IDENTITY(1,1),
	intContractHeaderId int,
	strCommodityCode NVARCHAR(50),
	intContractFeedId INT,
	strSubLocation NVARCHAR(50)
)

Select @strPOCreateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('PO CREATE')
Select @strPOUpdateIDOCHeader=dbo.fnIPGetSAPIDOCHeader('PO UPDATE')
Select @strCompCode=dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL','COMP_CODE')

--Get the Headers
Insert Into @tblHeader(intContractHeaderId,strCommodityCode,intContractFeedId,strSubLocation)
Select intContractHeaderId,'COFFEE' AS strCommodityCode,intContractFeedId,'' AS strSubLocation 
From tblCTContractFeed 
Where ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='COFFEE'
UNION ALL
Select DISTINCT intContractHeaderId,'TEA' AS strCommodityCode,MAX(intContractFeedId) AS intContractFeedId,strSubLocation 
From tblCTContractFeed 
Where ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'
Group By intContractHeaderId,strSubLocation
Order By intContractHeaderId

Select @intMinRowNo=Min(intRowNo) From @tblHeader

While(@intMinRowNo is not null) --Header Loop
Begin
	Set @strXml=''
	Set @strXmlHeaderStart=''
	Set @strXmlHeaderEnd=''
	Set @strHeaderState=''
	Set @strContractFeedIds=NULL

	Select @intContractHeaderId=intContractHeaderId,@strSubLocation=strSubLocation,@intContractFeedId=intContractFeedId,@strCommodityCode=strCommodityCode 
	From @tblHeader Where intRowNo=@intMinRowNo

	If UPPER(@strCommodityCode)='COFFEE'
	Begin	
		Select @intMinSeq=@intContractFeedId

		Select @strContractFeedIds=@intContractFeedId

		Select @strHeaderState=CASE WHEN UPPER(strRowState)='DELETE' THEN 'MODIFIED' ELSE UPPER(strRowState) END 
		From tblCTContractFeed Where intContractFeedId=@intContractFeedId
	End

	If UPPER(@strCommodityCode)='TEA'
	Begin
		Select @intMinSeq=Min(intContractFeedId) From tblCTContractFeed Where intContractHeaderId=@intContractHeaderId AND ISNULL(strSubLocation,'')=ISNULL(@strSubLocation,'') 
				AND ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'

		Select @strContractFeedIds=COALESCE(CONVERT(VARCHAR,@strContractFeedIds) + ',', '') + CONVERT(VARCHAR,intContractFeedId) 
		From tblCTContractFeed Where intContractHeaderId=@intContractHeaderId AND ISNULL(strSubLocation,'')=ISNULL(@strSubLocation,'')
			AND ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'

		If ISNULL(@strSubLocation,'')=''
		Begin
			Select TOP 1 @strERPPONumber1=strERPPONumber From tblCTContractDetail Where intContractHeaderId=@intContractHeaderId

			If ISNULL(@strERPPONumber1,'')<>''
				Begin
					Set @strHeaderState='MODIFIED'

					Update tblCTContractFeed Set strERPPONumber=@strERPPONumber1
					Where intContractHeaderId=@intContractHeaderId AND ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'
				End
			Else
				Set @strHeaderState='ADDED'
		End
		Else
		Begin
			Select TOP 1 @strERPPONumber1=strERPPONumber From tblCTContractDetail Where intContractHeaderId=@intContractHeaderId 
					AND intSubLocationId=(Select TOP 1 intCompanyLocationSubLocationId from tblSMCompanyLocationSubLocation Where strSubLocationName=ISNULL(@strSubLocation,'')
					AND intCompanyLocationId=(Select TOP 1 intCompanyLocationId From tblCTContractDetail Where intContractHeaderId=@intContractHeaderId))

			If ISNULL(@strERPPONumber1,'')<>''
				Begin
					Set @strHeaderState='MODIFIED'

					Update tblCTContractFeed Set strERPPONumber=@strERPPONumber1
					Where intContractHeaderId=@intContractHeaderId AND ISNULL(strSubLocation,'')=ISNULL(@strSubLocation,'')
					AND ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'		
				End
			Else
				Set @strHeaderState='ADDED'
		End
	End

	--Donot generate Modified Idoc if PO No is not there
	If @strHeaderState='MODIFIED' AND (Select ISNULL(strERPPONumber,'') From tblCTContractFeed Where intContractFeedId=@intMinSeq)=''
		GOTO NEXT_PO

	Set @strItemXml=''
	Set @strItemXXml=''
	Set @strScheduleXml=''
	Set @strScheduleXXml=''
	Set @strCondXml=''
	Set @strCondXXml=''
	Set @strTextXml=''
	Set @strSeq=''

	While(@intMinSeq is not null) --Sequence Loop
	Begin
		Select 
			@intContractFeedId			= intContractFeedId ,
			@intContractHeaderId		= intContractHeaderId,
			@intContractDetailId		= intContractDetailId,
			@strCommodityCode			= strCommodityCode ,
			@strCommodityDesc			= strCommodityDesc ,
			@strContractBasis			= strContractBasis ,--INCOTERMS1
			@strContractBasisDesc		= strContractBasisDesc ,--INCOTERMS2
			@strSubLocation				= strSubLocation , --L-Plant / PLANT 
			@strCreatedBy				= strCreatedBy , 
			@strCreatedByNo				= strSubmittedByNo , 
			@strEntityNo				= strVendorAccountNum , --VENDOR 
			@strTerm					= strTermCode  , --PMNTTRMS / VEND_PART 
			@strPurchasingGroup			= strPurchasingGroup, 
			@strContractNumber			= strContractNumber  ,
			@strERPPONumber				= strERPPONumber  ,
			@intContractSeq				= intContractSeq, --PO_ITEM 
			@strItemNo					= strItemNo  ,
			@strStorageLocation			= strStorageLocation , --STGE_LOC 
			@dblQuantity				= dblNetWeight,
			@strQuantityUOM				= (Select TOP 1 ISNULL(strSymbol,strUnitMeasure) From tblICUnitMeasure Where strUnitMeasure = strNetWeightUOM) , --PO_UNIT
			@dblCashPrice				= dblCashPrice, --NET_PRICE
			@dblUnitCashPrice			= dblUnitCashPrice, --PRICE_UNIT 
			@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate, --DELIVERY_DATE 
			@dtmContractDate			= dtmContractDate, 
			@dtmStartDate				= dtmStartDate, --VPER_START
			@dtmEndDate					= dtmEndDate, --VPER_END
			@dblBasis					= dblBasis, --COND_VALUE,
			@strCurrency				= strCurrency ,--CURRENCY 
			@strPriceUOM				= (Select TOP 1 ISNULL(strSymbol,strUnitMeasure) From tblICUnitMeasure Where strUnitMeasure = strPriceUOM) , --COND_UNIT 
			@strRowState				= strRowState ,
			@strFeedStatus				= strFeedStatus,
			@strContractItemNo			= strContractItemNo,
			@strOrigin					= strOrigin,
			@strLoadingPoint			= strLoadingPoint	
		From tblCTContractFeed Where intContractFeedId=@intMinSeq

		Set @strSeq=ISNULL(@strSeq,'') + CONVERT(VARCHAR,@intContractSeq) + ','

		--Convert price USC to USD
		If UPPER(@strCurrency)='USC'
		Begin
			Set @strCurrency='USD'
			Set @dblBasis=ISNULL(@dblBasis,0)/100
			Set @dblCashPrice=ISNULL(@dblCashPrice,0)/100
		End

		Set @strProductType=''
		Select TOP 1 @strProductType=ca.strDescription from tblICItem i Join tblICCommodityAttribute ca on i.intProductTypeId=ca.intCommodityAttributeId 
		Where ca.strType='ProductType' And i.strItemNo=@strItemNo

		Set @strVendorBatch=''
		Select @strVendorBatch=strVendorLotID From tblCTContractDetail Where intContractDetailId=@intContractDetailId

		--Find Doc Type
		If @strContractBasis IN ('FCA','EXW','DDP','DAP','DDU')
			Set @strDocType='ZHDE'

		If @strContractBasis IN ('FOB','CFR')
			Set @strDocType='ZHUB'

		If @strSubLocation IN ('L953')
			Set @strDocType='ZB2B'
		
		If ISNULL(@strDocType,'')='' Set @strDocType='ZHUB'

		If UPPER(@strHeaderState)='MODIFIED'	
		Begin
			--update first entry in feed table if empty
			Update tblCTContractFeed Set strDocType=@strDocType Where intContractFeedId=
			(Select TOP 1 intContractFeedId From tblCTContractFeed Where intContractDetailId=@intContractDetailId)
			AND ISNULL(strDocType,'')=''

			Select TOP 1 @strDocType=strDocType From tblCTContractFeed Where intContractDetailId=@intContractDetailId
		End

		--update in feed table
		Update tblCTContractFeed Set strDocType=@strDocType Where intContractFeedId=@intContractFeedId

		--Header Start Xml
		If ISNULL(@strXmlHeaderStart,'')=''
		Begin
			If UPPER(@strHeaderState)='ADDED'
			Begin
				Set @strXmlHeaderStart =  '<PORDCR103>'
				Set @strXmlHeaderStart += '<IDOC BEGIN="1">'

				--IDOC Header
				Set @strXmlHeaderStart +=	'<EDI_DC40 SEGMENT="1">'
				Set @strXmlHeaderStart +=	@strPOCreateIDOCHeader
				Set @strXmlHeaderStart +=	'</EDI_DC40>'
		
				Set @strXmlHeaderStart +=	'<E1PORDCR1 SEGMENT="1">'
			End

			If UPPER(@strHeaderState)='MODIFIED'
			Begin
				Set @strXmlHeaderStart =  '<PORDCH03>'
				Set @strXmlHeaderStart += '<IDOC BEGIN="1">'

				--IDOC Header
				Set @strXmlHeaderStart +=	'<EDI_DC40 SEGMENT="1">'
				Set @strXmlHeaderStart +=	@strPOUpdateIDOCHeader
				Set @strXmlHeaderStart +=	'</EDI_DC40>'
		
				Set @strXmlHeaderStart +=	'<E1PORDCH SEGMENT="1">'
				Set @strXmlHeaderStart +=	'<PURCHASEORDER>'		+ ISNULL(@strERPPONumber,'')			+ '</PURCHASEORDER>'
			End

			If UPPER(@strHeaderState)='ADDED' OR UPPER(@strHeaderState)='MODIFIED'
			Begin
				--Header
				Set @strXmlHeaderStart += '<E1BPMEPOHEADER SEGMENT="1">'
				If UPPER(@strHeaderState)='MODIFIED'
					Set @strXmlHeaderStart += '<PO_NUMBER>'	+ ISNULL(@strERPPONumber,'')	+ '</PO_NUMBER>'
				Set @strXmlHeaderStart += '<COMP_CODE>'		+ ISNULL(@strCompCode,'')			+ '</COMP_CODE>'
				Set @strXmlHeaderStart += '<DOC_TYPE>'		+ ISNULL(@strDocType,'')			+ '</DOC_TYPE>'
				Set @strXmlHeaderStart += '<CREAT_DATE>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmContractDate,112),'')	+ '</CREAT_DATE>'
				Set @strXmlHeaderStart += '<CREATED_BY>'	+ ISNULL(@strCreatedByNo,'')		+ '</CREATED_BY>'
				Set @strXmlHeaderStart += '<VENDOR>'		+ ISNULL(@strEntityNo,'')			+ '</VENDOR>'
				Set @strXmlHeaderStart += '<PMNTTRMS>'		+ ISNULL(@strTerm,'')				+ '</PMNTTRMS>'
				Set @strXmlHeaderStart += '<PURCH_ORG>'		+ '0380'							+ '</PURCH_ORG>'
				Set @strXmlHeaderStart += '<PUR_GROUP>'		+ ISNULL(@strPurchasingGroup,'')	+ '</PUR_GROUP>'
				Set @strXmlHeaderStart += '<DOC_DATE>'		+ ISNULL(CONVERT(VARCHAR(10),@dtmContractDate,112),'')	+ '</DOC_DATE>'
				Set @strXmlHeaderStart += '<VPER_START>'	+ ISNULL(CONVERT(VARCHAR(10),@dtmStartDate,112),'')	+ '</VPER_START>'
				Set @strXmlHeaderStart += '<VPER_END>'		+ ISNULL(CONVERT(VARCHAR(10),@dtmEndDate,112),'')	+ '</VPER_END>'
				Set @strXmlHeaderStart += '<REF_1>'			+ ISNULL(@strContractNumber,'')		+ '</REF_1>'
				Set @strXmlHeaderStart += '<INCOTERMS1>'	+ dbo.fnEscapeXML(ISNULL(@strContractBasis,''))		+ '</INCOTERMS1>'
				Set @strXmlHeaderStart += '<INCOTERMS2>'	+ dbo.fnEscapeXML(ISNULL(@strLoadingPoint,''))	+ '</INCOTERMS2>'
				Set @strXmlHeaderStart +=	'</E1BPMEPOHEADER>'

				--HeaderX
				Set @strXmlHeaderStart += '<E1BPMEPOHEADERX SEGMENT="1">'
				If UPPER(@strHeaderState)='MODIFIED'
					Set @strXmlHeaderStart += '<PO_NUMBER>'	+ 'X'	+ '</PO_NUMBER>'
				If @strCompCode IS NOT NULL
					Set @strXmlHeaderStart += '<COMP_CODE>'	+ 'X'	+ '</COMP_CODE>'			
				If UPPER(@strHeaderState)='ADDED' AND @strDocType IS NOT NULL
					Set @strXmlHeaderStart += '<DOC_TYPE>'		+ 'X'	+ '</DOC_TYPE>' 
				If UPPER(@strHeaderState)='MODIFIED' AND (@strContractBasis IS NOT NULL OR @strSubLocation IS NOT NULL)
					Set @strXmlHeaderStart += '<DOC_TYPE>'		+ 'X'	+ '</DOC_TYPE>'
				If @dtmContractDate IS NOT NULL
					Set @strXmlHeaderStart += '<CREAT_DATE>'	+ 'X'	+ '</CREAT_DATE>'
				If @strCreatedByNo IS NOT NULL
					Set @strXmlHeaderStart += '<CREATED_BY>'	+ 'X'	+ '</CREATED_BY>'
				If @strEntityNo IS NOT NULL
					Set @strXmlHeaderStart += '<VENDOR>'		+ 'X'	+ '</VENDOR>'
				If @strTerm IS NOT NULL
					Set @strXmlHeaderStart += '<PMNTTRMS>'		+ 'X'	+ '</PMNTTRMS>'
				Set @strXmlHeaderStart += '<PURCH_ORG>'		+ 'X'+ '</PURCH_ORG>'
				If @strPurchasingGroup IS NOT NULL
					Set @strXmlHeaderStart += '<PUR_GROUP>'	+ 'X'	+ '</PUR_GROUP>'
				If @dtmContractDate IS NOT NULL
					Set @strXmlHeaderStart += '<DOC_DATE>'		+ 'X'	+ '</DOC_DATE>'
				If @dtmStartDate IS NOT NULL
					Set @strXmlHeaderStart += '<VPER_START>'	+ 'X'	+ '</VPER_START>'
				If @dtmEndDate IS NOT NULL
					Set @strXmlHeaderStart += '<VPER_END>'		+ 'X'	+ '</VPER_END>'
				If @strContractNumber IS NOT NULL
					Set @strXmlHeaderStart += '<REF_1>'		+ 'X'	+ '</REF_1>'
				If @strContractBasis IS NOT NULL
					Set @strXmlHeaderStart += '<INCOTERMS1>'	+ 'X'	+ '</INCOTERMS1>'
				If @strContractBasisDesc IS NOT NULL
					Set @strXmlHeaderStart += '<INCOTERMS2>'	+ 'X'	+ '</INCOTERMS2>'
				Set @strXmlHeaderStart +=	'</E1BPMEPOHEADERX>'
		End
		End

		--Repeat Details
			Begin
				--Item
				Set @strItemXml += '<E1BPMEPOITEM SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strItemXml += '<PO_ITEM>'		+ '0001'		+ '</PO_ITEM>'
				Else
					Set @strItemXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				If UPPER(@strRowState)='DELETE'
					Set @strItemXml += '<DELETE_IND>'	+ 'X'	+ '</DELETE_IND>'
				If UPPER(@strCommodityCode)='TEA'
					Set @strItemXml += '<MATERIAL>'		+ dbo.fnEscapeXML(ISNULL(ISNULL(@str10Zeros + @strContractItemNo,@str10Zeros + @strItemNo),''))				+ '</MATERIAL>'
				ELSE
					Set @strItemXml += '<MATERIAL>'		+ dbo.fnEscapeXML(ISNULL(@str10Zeros + @strItemNo,''))				+ '</MATERIAL>'
				Set @strItemXml += '<PLANT>'		+ ISNULL(@strSubLocation,'')		+ '</PLANT>'
				Set @strItemXml += '<STGE_LOC>'		+ ISNULL(@strStorageLocation,'')	+ '</STGE_LOC>'
				Set @strItemXml += '<TRACKINGNO>'	+ ISNULL(CONVERT(VARCHAR,@intContractDetailId),'')	+ '</TRACKINGNO>'
				Set @strItemXml += '<QUANTITY>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'')		+ '</QUANTITY>'
				Set @strItemXml += '<PO_UNIT>'		+ ISNULL(@strQuantityUOM,'')		+ '</PO_UNIT>'
				Set @strItemXml += '<ORDERPR_UN>'	+ ISNULL(@strPriceUOM,'')			+ '</ORDERPR_UN>'
				Set @strItemXml += '<NET_PRICE>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblCashPrice)),'0.00')	+ '</NET_PRICE>'
				If UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Washed Arabica','Unwashed Arabica')
					Set @strItemXml += '<PRICE_UNIT>'	+ '100'	+ '</PRICE_UNIT>'
				Else if UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Robusta')
					Set @strItemXml += '<PRICE_UNIT>'	+ '1000'	+ '</PRICE_UNIT>'
				Else
					Set @strItemXml += '<PRICE_UNIT>'	+ '1'	+ '</PRICE_UNIT>'
				If ISNULL(@dblCashPrice,0)=0
					Set @strItemXml += '<FREE_ITEM>'	+ 'X'	+ '</FREE_ITEM>'
				Else
					Set @strItemXml += '<FREE_ITEM>'	+ ' '	+ '</FREE_ITEM>'
				Set @strItemXml += '<CONF_CTRL>'	+ 'SL08'							+ '</CONF_CTRL>'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strItemXml += '<VEND_PART>'	+ ISNULL(@strTerm,'')			+ '</VEND_PART>'
				Else
					Set @strItemXml += '<VEND_PART>'	+ ''			+ '</VEND_PART>'
				If UPPER(@strCommodityCode)='TEA'
					Set @strItemXml += '<VENDRBATCH>'	+ ISNULL(@strVendorBatch,'')			+ '</VENDRBATCH>'
				Set @strItemXml += '<PO_PRICE>'		+ '1'	+ '</PO_PRICE>'
				Set @strItemXml +=	'</E1BPMEPOITEM>'

				--ItemX
				Set @strItemXXml += '<E1BPMEPOITEMX SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strItemXXml += '<PO_ITEM>'		+ '0001'		+ '</PO_ITEM>'
				Else
					Set @strItemXXml += '<PO_ITEM>'			+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strItemXXml += '<PO_ITEMX>'		+ 'X'	+ '</PO_ITEMX>'
				If UPPER(@strRowState)='DELETE'
					Set @strItemXXml += '<DELETE_IND>'	+ 'X'	+ '</DELETE_IND>'
				If @strItemNo IS NOT NULL
					Set @strItemXXml += '<MATERIAL>'		+ 'X'		+ '</MATERIAL>'
				If @strSubLocation IS NOT NULL
					Set @strItemXXml += '<PLANT>'		+ 'X'		+ '</PLANT>'
				If @strStorageLocation IS NOT NULL
					Set @strItemXXml += '<STGE_LOC>'		+ 'X'		+ '</STGE_LOC>'
				Set @strItemXXml += '<TRACKINGNO>'		+ 'X'	+ '</TRACKINGNO>'
				If @dblQuantity IS NOT NULL
					Set @strItemXXml += '<QUANTITY>'		+ 'X'		+ '</QUANTITY>'
				If @strQuantityUOM IS NOT NULL
					Set @strItemXXml += '<PO_UNIT>'		+ 'X'		+ '</PO_UNIT>'
				If @strPriceUOM IS NOT NULL
					Set @strItemXXml += '<ORDERPR_UN>'	+ 'X'		+ '</ORDERPR_UN>'
				If @dblCashPrice IS NOT NULL
					Set @strItemXXml += '<NET_PRICE>'	+ 'X'		+ '</NET_PRICE>'
				Set @strItemXXml += '<PRICE_UNIT>'	+ 'X'		+ '</PRICE_UNIT>'
				Set @strItemXXml += '<FREE_ITEM>'	+ 'X'	+ '</FREE_ITEM>'
				If @strDocType='ZHUB'
					Set @strItemXXml += '<GR_BASEDIV>'	+ 'X'	+ '</GR_BASEDIV>'	
				Set @strItemXXml += '<CONF_CTRL>'		+ 'X'	+ '</CONF_CTRL>'
				If @strTerm IS NOT NULL AND UPPER(@strCommodityCode)='COFFEE'
					Set @strItemXXml += '<VEND_PART>'	+ 'X'		+ '</VEND_PART>'
				Else
					Set @strItemXXml += '<VEND_PART>'	+ ' '		+ '</VEND_PART>'
				If UPPER(@strCommodityCode)='TEA' 
				Begin
					If ISNULL(@strVendorBatch,'')<>''
						Set @strItemXXml += '<VENDRBATCH>'	+ 'X'		+ '</VENDRBATCH>'
					Else
						Set @strItemXXml += '<VENDRBATCH>'	+ ' '		+ '</VENDRBATCH>'
				End
				Set @strItemXXml += '<PO_PRICE>'			+ 'X'		+ '</PO_PRICE>'
				Set @strItemXXml +=	'</E1BPMEPOITEMX>'

				--Schedule
				Set @strScheduleXml += '<E1BPMEPOSCHEDULE SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strScheduleXml += '<PO_ITEM>'		+ '0001'		+ '</PO_ITEM>'
				Else
					Set @strScheduleXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strScheduleXml += '<SCHED_LINE>'	+ '0001'		+ '</SCHED_LINE>'
				Set @strScheduleXml += '<DEL_DATCAT_EXT>'	+ '1'		+ '</DEL_DATCAT_EXT>'
				Set @strScheduleXml += '<DELIVERY_DATE>'+ ISNULL(CONVERT(VARCHAR(10),@dtmPlannedAvailabilityDate,104),'')	+ '</DELIVERY_DATE>'
				Set @strScheduleXml += '<QUANTITY>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'')	+ '</QUANTITY>'
				Set @strScheduleXml += '</E1BPMEPOSCHEDULE>'

				--ScheduleX
				Set @strScheduleXXml += '<E1BPMEPOSCHEDULX SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strScheduleXXml += '<PO_ITEM>'		+ '0001'		+ '</PO_ITEM>'
				Else
					Set @strScheduleXXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strScheduleXXml += '<SCHED_LINE>'	+ '0001'		+ '</SCHED_LINE>'
				Set @strScheduleXXml += '<PO_ITEMX>'		+ 'X'	+ '</PO_ITEMX>'
				Set @strScheduleXXml += '<SCHED_LINEX>'		+ 'X'	+ '</SCHED_LINEX>'
				Set @strScheduleXXml += '<DEL_DATCAT_EXT>'	+ 'X'		+ '</DEL_DATCAT_EXT>'
				If @dtmPlannedAvailabilityDate IS NOT NULL
					Set @strScheduleXXml += '<DELIVERY_DATE>'+ 'X'	+ '</DELIVERY_DATE>'
				If @dblQuantity IS NOT NULL
					Set @strScheduleXXml += '<QUANTITY>'		+ 'X'	+ '</QUANTITY>'
				Set @strScheduleXXml += '</E1BPMEPOSCHEDULX>'

				--Basis Information
				Set @strCondXml += '<E1BPMEPOCOND SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strCondXml += '<ITM_NUMBER>'		+ '0001'		+ '</ITM_NUMBER>'
				Else
					Set @strCondXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
				Set @strCondXml += '<COND_TYPE>'		+ 'ZDIF'		+ '</COND_TYPE>'
				Set @strCondXml += '<COND_VALUE>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblBasis)),'')	+ '</COND_VALUE>'
				Set @strCondXml += '<CURRENCY>'			+ ISNULL(@strCurrency,'')		+ '</CURRENCY>'
				Set @strCondXml += '<COND_UNIT>'		+ ISNULL(@strPriceUOM,'')		+ '</COND_UNIT>'
				If UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Washed Arabica','Unwashed Arabica')
					Set @strCondXml += '<COND_P_UNT>'		+ '100'	+ '</COND_P_UNT>'
				Else if UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Robusta')
					Set @strCondXml += '<COND_P_UNT>'		+ '1000'	+ '</COND_P_UNT>'
				Else
					Set @strCondXml += '<COND_P_UNT>'		+ '1'	+ '</COND_P_UNT>'
				Set @strCondXml += '<CHANGE_ID>'		+ 'U' + '</CHANGE_ID>'
				Set @strCondXml += '</E1BPMEPOCOND>'

				--ZPBX Information
				If UPPER(@strHeaderState)='MODIFIED' AND ISNULL(@dblCashPrice,0)>0
				Begin
					Set @strCondXml += '<E1BPMEPOCOND SEGMENT="1">'
					If UPPER(@strCommodityCode)='COFFEE'
						Set @strCondXml += '<ITM_NUMBER>'		+ '0001'		+ '</ITM_NUMBER>'
					Else
						Set @strCondXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
					Set @strCondXml += '<COND_TYPE>'		+ 'ZPBX'		+ '</COND_TYPE>'
					Set @strCondXml += '<COND_VALUE>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblCashPrice)),'0.00')	+ '</COND_VALUE>'
					Set @strCondXml += '<CURRENCY>'			+ ISNULL(@strCurrency,'')		+ '</CURRENCY>'
					Set @strCondXml += '<COND_UNIT>'		+ ISNULL(@strPriceUOM,'')		+ '</COND_UNIT>'
					If UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Washed Arabica','Unwashed Arabica')
						Set @strCondXml += '<COND_P_UNT>'		+ '100'	+ '</COND_P_UNT>'
					Else if UPPER(@strCommodityCode)='COFFEE' AND @strProductType IN ('Robusta')
						Set @strCondXml += '<COND_P_UNT>'		+ '1000'	+ '</COND_P_UNT>'
					Else
						Set @strCondXml += '<COND_P_UNT>'		+ '1'	+ '</COND_P_UNT>'
					Set @strCondXml += '<CHANGE_ID>'		+ 'I' + '</CHANGE_ID>'
					Set @strCondXml += '</E1BPMEPOCOND>'
				End

				--Basis InformationX
				Set @strCondXXml += '<E1BPMEPOCONDX SEGMENT="1">'
				If UPPER(@strCommodityCode)='COFFEE'
					Set @strCondXXml += '<ITM_NUMBER>'		+ '0001'		+ '</ITM_NUMBER>'
				Else
					Set @strCondXXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
				Set @strCondXXml += '<ITM_NUMBERX>'		+ 'X'		+ '</ITM_NUMBERX>'
				Set @strCondXXml += '<COND_TYPE>'		+ 'X'		+ '</COND_TYPE>'
				If @dblBasis IS NOT NULL
					Set @strCondXXml += '<COND_VALUE>'	+ 'X'	+ '</COND_VALUE>'
				If @strCurrency IS NOT NULL
					Set @strCondXXml += '<CURRENCY>'		+ 'X'		+ '</CURRENCY>'
				If @strPriceUOM IS NOT NULL
					Set @strCondXXml += '<COND_UNIT>'	+ 'X'		+ '</COND_UNIT>'
				Set @strCondXXml += '<COND_P_UNT>'	+ 'X'	+ '</COND_P_UNT>'
				Set @strCondXXml += '<CHANGE_ID>'		+ 'X'	+ '</CHANGE_ID>'
				Set @strCondXXml += '</E1BPMEPOCONDX>'

				--ZPBX InformationX
				If UPPER(@strHeaderState)='MODIFIED' AND ISNULL(@dblCashPrice,0)>0
				Begin
					Set @strCondXXml += '<E1BPMEPOCONDX SEGMENT="1">'
					If UPPER(@strCommodityCode)='COFFEE'
						Set @strCondXXml += '<ITM_NUMBER>'		+ '0001'		+ '</ITM_NUMBER>'
					Else
						Set @strCondXXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
					Set @strCondXXml += '<ITM_NUMBERX>'		+ 'X'		+ '</ITM_NUMBERX>'
					Set @strCondXXml += '<COND_TYPE>'		+ 'X'		+ '</COND_TYPE>'
					Set @strCondXXml += '<COND_VALUE>'	+ 'X'	+ '</COND_VALUE>'
					If @strCurrency IS NOT NULL
						Set @strCondXXml += '<CURRENCY>'		+ 'X'		+ '</CURRENCY>'
					If @strPriceUOM IS NOT NULL
						Set @strCondXXml += '<COND_UNIT>'	+ 'X'		+ '</COND_UNIT>'
					Set @strCondXXml += '<COND_P_UNT>'	+ 'X'	+ '</COND_P_UNT>'
					Set @strCondXXml += '<CHANGE_ID>'		+ 'X'	+ '</CHANGE_ID>'
					Set @strCondXXml += '</E1BPMEPOCONDX>'
				End

				If UPPER(@strCommodityCode)='COFFEE'
				Begin
					--Origin (L16)
					If ISNULL(@strContractItemNo,'')<>''
					Begin
						Set @strTextXml += '<E1BPMEPOTEXTHEADER>'
						Set @strTextXml += '<TEXT_ID>' + 'L16' + '</TEXT_ID>' 
						Set @strTextXml += '<TEXT_LINE>'  +  dbo.fnEscapeXML(ISNULL(@strContractItemNo,'')) + '</TEXT_LINE>' 
						Set @strTextXml += '</E1BPMEPOTEXTHEADER>'
					End

					--Certificate (L15)
					Select @strCertificates=COALESCE(@strCertificates, '') 
						+ '<E1BPMEPOTEXTHEADER>'
						+ '<TEXT_ID>' + 'L15' + '</TEXT_ID>' 
						+ '<TEXT_LINE>'  +  dbo.fnEscapeXML(ISNULL(strCertificationCode,'')) + '</TEXT_LINE>' 
						+ '</E1BPMEPOTEXTHEADER>'
					From tblCTContractCertification cc Join tblICCertification c on cc.intCertificationId=c.intCertificationId
					Where cc.intContractDetailId=@intContractDetailId

					Set @strCertificates=LTRIM(RTRIM(ISNULL(@strCertificates,'')))

					If @strCertificates<>''
						Set @strTextXml += ISNULL(@strCertificates,'')
					Else
					Begin --Set 0 (For No Certificate)
						Set @strTextXml += '<E1BPMEPOTEXTHEADER>'
						Set @strTextXml += '<TEXT_ID>'		+ 'L15' + '</TEXT_ID>' 
						Set @strTextXml += '<TEXT_LINE>'	+  '0' + '</TEXT_LINE>' 
						Set @strTextXml += '</E1BPMEPOTEXTHEADER>'
					End
				End

				If UPPER(@strCommodityCode)='TEA'
				Begin
						Set @strTextXml += '<E1BPMEPOTEXTHEADER>'
						Set @strTextXml += '<TEXT_ID>'		+ 'L15' + '</TEXT_ID>' 
						Set @strTextXml += '<TEXT_LINE>'	+  'N' + '</TEXT_LINE>' 
						Set @strTextXml += '</E1BPMEPOTEXTHEADER>'
				End
			End

		--Header End Xml
		If ISNULL(@strXmlHeaderEnd,'')=''
		Begin
			If UPPER(@strHeaderState)='ADDED'
			Begin
				Set @strXmlHeaderEnd +=	'</E1PORDCR1>'

				Set @strXmlHeaderEnd += '</IDOC>'
				Set @strXmlHeaderEnd +=  '</PORDCR103>'
			End

			If UPPER(@strHeaderState)='MODIFIED'
			Begin
				Set @strXmlHeaderEnd +=	'</E1PORDCH>'

				Set @strXmlHeaderEnd += '</IDOC>'
				Set @strXmlHeaderEnd +=  '</PORDCH03>'
			End
		End

		If UPPER(@strCommodityCode)='COFFEE'
			Set @intMinSeq=NULL
		ELSE
			Select @intMinSeq=Min(intContractFeedId) From tblCTContractFeed Where intContractFeedId>@intMinSeq AND intContractHeaderId=@intContractHeaderId AND ISNULL(strSubLocation,'')=ISNULL(@strSubLocation,'')
						AND ISNULL(strFeedStatus,'')='' AND UPPER(strCommodityCode)='TEA'
	End

	--Final Xml
	Set @strXml = @strXmlHeaderStart + @strItemXml + @strItemXXml + @strScheduleXml + @strScheduleXXml + @strCondXml + @strCondXXml + @strTextXml + @strXmlHeaderEnd

	If @ysnUpdateFeedStatusOnRead=1
	Begin
		Declare @strSql nvarchar(max)='Update tblCTContractFeed Set strFeedStatus=''Awt Ack'' Where intContractFeedId IN (' + @strContractFeedIds + ')'
	
		Exec sp_executesql @strSql
	End

	Set @strSeq=LTRIM(RTRIM(LEFT(@strSeq,LEN(@strSeq)-1)))

	INSERT INTO @tblOutput(strContractFeedIds,strRowState,strXml,strContractNo,strPONo)
	VALUES(@strContractFeedIds,CASE WHEN UPPER(@strHeaderState)='ADDED' THEN 'CREATE' ELSE 'UPDATE' END,@strXml,ISNULL(@strContractNumber,'') + ' / ' + ISNULL(@strSeq,''),ISNULL(@strERPPONumber,''))
	
	NEXT_PO:
	Select @intMinRowNo=Min(intRowNo) From @tblHeader Where intRowNo>@intMinRowNo
End --End Header Loop

Select * From @tblOutput ORDER BY intRowNo