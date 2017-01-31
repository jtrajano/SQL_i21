CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC]
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
		@strOrigin					NVARCHAR(100)

Declare @tblOutput AS Table
(
	intRowNo INT IDENTITY(1,1),
	strContractFeedIds NVARCHAR(MAX),
	strRowState NVARCHAR(50),
	strXml NVARCHAR(MAX)
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
			@strEntityNo				= strEntityNo , --VENDOR 
			@strTerm					= strTerm  , --PMNTTRMS / VEND_PART 
			@strPurchasingGroup			= strPurchasingGroup, 
			@strContractNumber			= strContractNumber  ,
			@strERPPONumber				= strERPPONumber  ,
			@intContractSeq				= intContractSeq, --PO_ITEM 
			@strItemNo					= strItemNo  ,
			@strStorageLocation			= strStorageLocation , --STGE_LOC 
			@dblQuantity				= dblQuantity,
			@strQuantityUOM				= strQuantityUOM , --PO_UNIT
			@dblCashPrice				= dblCashPrice, --NET_PRICE
			@dblUnitCashPrice			= dblUnitCashPrice, --PRICE_UNIT 
			@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate, --DELIVERY_DATE 
			@dtmContractDate			= dtmContractDate, 
			@dtmStartDate				= dtmStartDate, --VPER_START
			@dtmEndDate					= dtmEndDate, --VPER_END
			@dblBasis					= dblBasis, --COND_VALUE,
			@strCurrency				= strCurrency ,--CURRENCY 
			@strPriceUOM				= strPriceUOM , --COND_UNIT 
			@strRowState				= strRowState ,
			@strFeedStatus				= strFeedStatus
		From tblCTContractFeed Where intContractFeedId=@intMinSeq

		--Find Doc Type
		If @strContractBasis IN ('FCA','EXW')
			Set @strDocType='ZHDE'

		If @strContractBasis IN ('FOB','CFR')
			Set @strDocType='ZHUB'

		If @strSubLocation IN ('L953','L954')
			Set @strDocType='ZB2B'
		
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
				Set @strXmlHeaderStart += '<INCOTERMS1>'	+ ISNULL(@strContractBasis,'')		+ '</INCOTERMS1>'
				Set @strXmlHeaderStart += '<INCOTERMS2>'	+ ISNULL(@strContractBasisDesc,'')	+ '</INCOTERMS2>'
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
		If UPPER(@strRowState)='ADDED' OR UPPER(@strRowState)='MODIFIED'
			Begin
				--Item
				Set @strXml += '<E1BPMEPOITEM SEGMENT="1">'
				Set @strXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strXml += '<MATERIAL>'		+ ISNULL(@strItemNo,'')				+ '</MATERIAL>'
				Set @strXml += '<PLANT>'		+ ISNULL(@strSubLocation,'')		+ '</PLANT>'
				Set @strXml += '<STGE_LOC>'		+ ISNULL(@strStorageLocation,'')	+ '</STGE_LOC>'
				Set @strXml += '<TRACKINGNO>'	+ ISNULL(CONVERT(VARCHAR,@intContractDetailId),'')	+ '</TRACKINGNO>'
				Set @strXml += '<QUANTITY>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'')		+ '</QUANTITY>'
				Set @strXml += '<PO_UNIT>'		+ ISNULL(@strQuantityUOM,'')		+ '</PO_UNIT>'
				Set @strXml += '<ORDERPR_UN>'	+ ISNULL(@strPriceUOM,'')			+ '</ORDERPR_UN>'
				Set @strXml += '<NET_PRICE>'	+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblUnitCashPrice * 1000)),'0.00')	+ '</NET_PRICE>'
				Set @strXml += '<PRICE_UNIT>'	+ '1000'	+ '</PRICE_UNIT>'
				If ISNULL(@dblCashPrice,0)=0
					Set @strXml += '<FREE_ITEM>'	+ 'X'	+ '</FREE_ITEM>'
				Else
					Set @strXml += '<FREE_ITEM>'	+ ' '	+ '</FREE_ITEM>'
				Set @strXml += '<CONF_CTRL>'	+ 'SL08'							+ '</CONF_CTRL>'
				Set @strXml += '<VEND_PART>'	+ ISNULL(CONVERT(VARCHAR,@strTerm),'')			+ '</VEND_PART>'
				Set @strXml += '<PO_PRICE>'		+ '1'	+ '</PO_PRICE>'
				Set @strXml +=	'</E1BPMEPOITEM>'

				--ItemX
				Set @strXml += '<E1BPMEPOITEMX SEGMENT="1">'
				Set @strXml += '<PO_ITEM>'			+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strXml += '<PO_ITEMX>'		+ 'X'	+ '</PO_ITEMX>'
				If @strItemNo IS NOT NULL
					Set @strXml += '<MATERIAL>'		+ 'X'		+ '</MATERIAL>'
				If @strSubLocation IS NOT NULL
					Set @strXml += '<PLANT>'		+ 'X'		+ '</PLANT>'
				If @strStorageLocation IS NOT NULL
					Set @strXml += '<STGE_LOC>'		+ 'X'		+ '</STGE_LOC>'
				Set @strXml += '<TRACKINGNO>'		+ 'X'	+ '</TRACKINGNO>'
				If @dblQuantity IS NOT NULL
					Set @strXml += '<QUANTITY>'		+ 'X'		+ '</QUANTITY>'
				If @strQuantityUOM IS NOT NULL
					Set @strXml += '<PO_UNIT>'		+ 'X'		+ '</PO_UNIT>'
				If @strPriceUOM IS NOT NULL
					Set @strXml += '<ORDERPR_UN>'	+ 'X'		+ '</ORDERPR_UN>'
				If @dblCashPrice IS NOT NULL
					Set @strXml += '<NET_PRICE>'	+ 'X'		+ '</NET_PRICE>'
				If @dblUnitCashPrice IS NOT NULL
					Set @strXml += '<PRICE_UNIT>'	+ 'X'		+ '</PRICE_UNIT>'
				--If ISNULL(@dblCashPrice,0)=0
					Set @strXml += '<FREE_ITEM>'	+ 'X'	+ '</FREE_ITEM>'
				Set @strXml += '<CONF_CTRL>'		+ 'X'	+ '</CONF_CTRL>'
				If @strTerm IS NOT NULL
					Set @strXml += '<VEND_PART>'	+ 'X'		+ '</VEND_PART>'
				Set @strXml += '<PO_PRICE>'			+ 'X'		+ '</PO_PRICE>'
				Set @strXml +=	'</E1BPMEPOITEMX>'

				--Schedule
				Set @strXml += '<E1BPMEPOSCHEDULE SEGMENT="1">'
				Set @strXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strXml += '<SCHED_LINE>'	+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</SCHED_LINE>'
				Set @strXml += '<DELIVERY_DATE>'+ ISNULL(CONVERT(VARCHAR(10),@dtmPlannedAvailabilityDate,112),'')	+ '</DELIVERY_DATE>'
				Set @strXml += '<QUANTITY>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblQuantity)),'')	+ '</QUANTITY>'
				Set @strXml += '</E1BPMEPOSCHEDULE>'

				--ScheduleX
				Set @strXml += '<E1BPMEPOSCHEDULX SEGMENT="1">'
				Set @strXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
				Set @strXml += '<SCHED_LINE>'	+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</SCHED_LINE>'
				Set @strXml += '<PO_ITEMX>'		+ 'X'	+ '</PO_ITEMX>'
				Set @strXml += '<SCHED_LINEX>'		+ 'X'	+ '</SCHED_LINEX>'
				If @dtmPlannedAvailabilityDate IS NOT NULL
					Set @strXml += '<DELIVERY_DATE>'+ 'X'	+ '</DELIVERY_DATE>'
				If @dblQuantity IS NOT NULL
					Set @strXml += '<QUANTITY>'		+ 'X'	+ '</QUANTITY>'
				Set @strXml += '</E1BPMEPOSCHEDULX>'

				--Basis Information
				Set @strXml += '<E1BPMEPOCOND SEGMENT="1">'
				Set @strXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
				Set @strXml += '<COND_TYPE>'		+ 'ZDIF'		+ '</COND_TYPE>'
				Set @strXml += '<COND_VALUE>'		+ ISNULL(LTRIM(CONVERT(NUMERIC(38,2),@dblBasis * 100)),'')	+ '</COND_VALUE>'
				Set @strXml += '<CURRENCY>'			+ ISNULL(@strCurrency,'')		+ '</CURRENCY>'
				Set @strXml += '<COND_UNIT>'		+ ISNULL(@strPriceUOM,'')		+ '</COND_UNIT>'
				Set @strXml += '<COND_P_UNT>'		+ '100'	+ '</COND_P_UNT>'
				Set @strXml += '<CHANGE_ID>'		+ 'U' + '</CHANGE_ID>'
				Set @strXml += '</E1BPMEPOCOND>'

				--Basis InformationX
				Set @strXml += '<E1BPMEPOCONDX SEGMENT="1">'
				Set @strXml += '<ITM_NUMBER>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</ITM_NUMBER>'
				Set @strXml += '<ITM_NUMBERX>'		+ 'X'		+ '</ITM_NUMBERX>'
				Set @strXml += '<COND_TYPE>'		+ 'X'		+ '</COND_TYPE>'
				If @dblBasis IS NOT NULL
					Set @strXml += '<COND_VALUE>'	+ 'X'	+ '</COND_VALUE>'
				If @strCurrency IS NOT NULL
					Set @strXml += '<CURRENCY>'		+ 'X'		+ '</CURRENCY>'
				If @strPriceUOM IS NOT NULL
					Set @strXml += '<COND_UNIT>'	+ 'X'		+ '</COND_UNIT>'
				If @dblUnitCashPrice IS NOT NULL
					Set @strXml += '<COND_P_UNT>'	+ 'X'	+ '</COND_P_UNT>'
				Set @strXml += '<CHANGE_ID>'		+ 'X'	+ '</CHANGE_ID>'
				Set @strXml += '</E1BPMEPOCONDX>'

				If UPPER(@strCommodityCode)='COFFEE'
				Begin
					--Origin (L16)
					If ISNULL(@strOrigin,'')<>''
					Begin
						Set @strXml += '<E1BPMEPOTEXTHEADER>'
						Set @strXml += '<TEXT_ID>' + 'L16' + '</TEXT_ID>' 
						Set @strXml += '<TEXT_LINE>'  +  ISNULL(@strOrigin,'') + '</TEXT_LINE>' 
						Set @strXml += '</E1BPMEPOTEXTHEADER>'
					End

					--Certificate (L15)
					Select @strCertificates=COALESCE(@strCertificates, '') 
						+ '<E1BPMEPOTEXTHEADER>'
						+ '<TEXT_ID>' + 'L15' + '</TEXT_ID>' 
						+ '<TEXT_LINE>'  +  ISNULL(strCertificationName,'') + '</TEXT_LINE>' 
						+ '</E1BPMEPOTEXTHEADER>'
					From tblCTContractCertification cc Join tblICCertification c on cc.intCertificationId=c.intCertificationId
					Where cc.intContractDetailId=@intContractDetailId

					Set @strCertificates=LTRIM(RTRIM(ISNULL(@strCertificates,'')))

					If @strCertificates<>''
						Set @strXml += ISNULL(@strCertificates,'')
					Else
					Begin --Set 0 (For No Certificate)
						Set @strXml += '<E1BPMEPOTEXTHEADER>'
						Set @strXml += '<TEXT_ID>'		+ 'L15' + '</TEXT_ID>' 
						Set @strXml += '<TEXT_LINE>'	+  '0' + '</TEXT_LINE>' 
						Set @strXml += '</E1BPMEPOTEXTHEADER>'
					End
				End
			End

		If UPPER(@strRowState)='DELETE'
		Begin
			--Item
			Set @strXml += '<E1BPMEPOITEM SEGMENT="1">'
			Set @strXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
			Set @strXml += '<TRACKINGNO>'	+ ISNULL(CONVERT(VARCHAR,@intContractDetailId),'')	+ '</TRACKINGNO>'
			Set @strXml += '<DELETE_IND>'	+ 'X'	+ '</DELETE_IND>'
			Set @strXml +=	'</E1BPMEPOITEM>'

			--ItemX
			Set @strXml += '<E1BPMEPOITEMX SEGMENT="1">'
			Set @strXml += '<PO_ITEM>'		+ ISNULL(RIGHT('0000' + CONVERT(VARCHAR,@intContractSeq),4),'')		+ '</PO_ITEM>'
			Set @strXml += '<PO_ITEMX>'		+ 'X'		+ '</PO_ITEMX>'
			Set @strXml += '<TRACKINGNO>'	+ 'X'	+ '</TRACKINGNO>'
			Set @strXml += '<DELETE_IND>'	+ 'X'	+ '</DELETE_IND>'
			Set @strXml +=	'</E1BPMEPOITEMX>'

			--Schedule
			Set @strXml += '<E1BPMEPOSCHEDULE SEGMENT="1">'
			Set @strXml += '</E1BPMEPOSCHEDULE>'

			--Basis Information
			Set @strXml += '<E1BPMEPOCOND SEGMENT="1">'
			Set @strXml += '</E1BPMEPOCOND>'
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
	Set @strXml = @strXmlHeaderStart + @strXml+ @strXmlHeaderEnd

	INSERT INTO @tblOutput(strContractFeedIds,strRowState,strXml)
	VALUES(@strContractFeedIds,CASE WHEN UPPER(@strHeaderState)='ADDED' THEN 'CREATE' ELSE 'UPDATE' END,@strXml)

	Select @intMinRowNo=Min(intRowNo) From @tblHeader Where intRowNo>@intMinRowNo
End --End Header Loop

Select * From @tblOutput ORDER BY intRowNo