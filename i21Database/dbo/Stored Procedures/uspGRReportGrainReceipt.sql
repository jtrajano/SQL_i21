CREATE PROCEDURE [dbo].[uspGRReportGrainReceipt]
 @xmlParam NVARCHAR(MAX) = NULL  
 
 AS
 BEGIN TRY
  
DECLARE @ErrMsg NVARCHAR(MAX)  

DECLARE  @strCompanyName NVARCHAR(500)  
	    ,@strAddress NVARCHAR(500)  
	    ,@strCounty NVARCHAR(500)  
	    ,@strCity NVARCHAR(500)  
	    ,@strState NVARCHAR(500)  
	    ,@strZip NVARCHAR(500)  
	    ,@strCountry NVARCHAR(500)
		,@xmlDocumentId INT    
		,@strReceiptNumber NVARCHAR(20)
		,@intScaleTicketId INT
		,@strItemStockUOM NVARCHAR(30)
		,@dblGrossWeight DECIMAL(24,10)
		,@dblTareWeight DECIMAL(24,10)
		,@dblUnloadedGrain DECIMAL(24,10) 
		,@dblDockage DECIMAL(24,10) 
		,@dblDockagePercent DECIMAL(24,10) 
		,@dblNetWeight DECIMAL(24,10)
		,@GrainUnloadedDecimal DECIMAL(24,10)  
		,@NetWeightDecimal DECIMAL(24,10)
		,@strScaleTicketNo NVARCHAR(50)
		,@strDeliveryLocation NVARCHAR(MAX)  
		,@dblCheckOff DECIMAL(24,2)
		,@dblNetAmtPayable DECIMAL(24,2)
		,@intCommodityId int	
	  
	
  

  IF LTRIM(RTRIM(@xmlParam)) = ''  
  SET @xmlParam = NULL  

  DECLARE @temp_xml_table TABLE   
 (  
  [fieldname] NVARCHAR(50)  
  ,condition NVARCHAR(20)  
  ,[from] NVARCHAR(50)  
  ,[to] NVARCHAR(50)  
  ,[join] NVARCHAR(10)  
  ,[begingroup] NVARCHAR(50)  
  ,[endgroup] NVARCHAR(50)  
  ,[datatype] NVARCHAR(50)  
 )  
  
   EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam  

 INSERT INTO @temp_xml_table  
 SELECT *  
 FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH   
 (  
   [fieldname] NVARCHAR(50)  
   ,condition NVARCHAR(20)  
   ,[from] NVARCHAR(50)  
   ,[to] NVARCHAR(50)  
   ,[join] NVARCHAR(10)  
   ,[begingroup] NVARCHAR(50)  
   ,[endgroup] NVARCHAR(50)  
   ,[datatype] NVARCHAR(50)  
 )  
 SELECT @intScaleTicketId = [from]  
 FROM @temp_xml_table  
 WHERE [fieldname] = 'intTicketId'  


 IF EXISTS (SELECT 1 FROM tblSCTicket WHERE intTicketId = @intScaleTicketId  AND strGrainReceiptNumber IS NOT NULL)  
	 BEGIN  
	
		  SELECT @strReceiptNumber = strGrainReceiptNumber  
		  FROM tblSCTicket  
		  WHERE intTicketId = @intScaleTicketId  
	 END
 ELSE
	BEGIN
		  SELECT @strReceiptNumber = (strPrefix + [dbo].[fnAddZeroPrefixes](intNumber, 5))  
		  FROM tblSMStartingNumber  
		  WHERE [strTransactionType] = N'Grain Receipt'  
  
		  UPDATE tblSMStartingNumber  
		  SET intNumber = intNumber + 1  
		  WHERE [strTransactionType] = N'Grain Receipt'  
  
		  UPDATE tblSCTicket  
		  SET strGrainReceiptNumber = @strReceiptNumber, dtmDateModifiedUtc = GETUTCDATE()
		  WHERE intTicketId = @intScaleTicketId  
	END  
  
   SELECT   
 @strItemStockUOM = UnitMeasure.strUnitMeasure,  
 @dblGrossWeight  =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,SC.dblGrossWeight),3),  
 @dblTareWeight =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,SC.dblTareWeight),3),  
 @dblUnloadedGrain =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)),3),  
 @dblDockage = ROUND(SC.dblShrink,3),  
 @dblDockagePercent = ROUND((SC.dblShrink*100.0/(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)))),2),  
 @dblNetWeight=ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight))-SC.dblShrink,3),
 @strScaleTicketNo = SC.strTicketNumber  

 ,@intCommodityId = SC.intCommodityId
 ,@strDeliveryLocation = COMPANY_LOCATION.strLocationName
 ,@strReceiptNumber = CASE WHEN SS.ysnUseTicketNoInGrainReceipt = 1 THEN SC.strTicketNumber ELSE @strReceiptNumber END
 FROM   tblICUnitMeasure UnitMeasure  
 JOIN   tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=UnitMeasure.intUnitMeasureId  
 JOIN   tblSCTicket SC ON SC.intItemUOMIdTo=ItemUOM.intItemUOMId  
 JOIN   tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId  
 JOIN   tblSMCompanyLocation COMPANY_LOCATION ON SS.intLocationId = COMPANY_LOCATION.intCompanyLocationId
 JOIN   tblICItemUOM ItemUOM1 ON ItemUOM1.intUnitMeasureId=SS.intUnitMeasureId AND  ItemUOM1.intItemId=SC.intItemId  
 WHERE  SC.intTicketId= @intScaleTicketId  

 SET @GrainUnloadedDecimal=ROUND(@dblUnloadedGrain-FLOOR(@dblUnloadedGrain),3)  
 SET @NetWeightDecimal=ROUND(@dblNetWeight-FLOOR(@dblNetWeight),3)  

 
--Grain Receipt item Mapping
declare 
	@GRRGrade DECIMAL(24,10)
	
;with TicketDiscountInfo as (
select 
		DiscountCode.intItemId
		, Discount.intTicketId
		, Discount.dblGradeReading
	from tblQMTicketDiscount Discount
		join tblGRDiscountScheduleCode DiscountCode
			on Discount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId

		where intTicketId = @intScaleTicketId

)
select 
	@GRRGrade = Grade.dblGradeReading
	
from tblSCGrainReceiptDiscountMapping200 Preference	
	left join TicketDiscountInfo Grade
		on Preference.[intGradeId] = Grade.intItemId
	
where Preference.intCommodityId = @intCommodityId

 SELECT @strCompanyName =   
   CASE   
    WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL  
    ELSE LTRIM(RTRIM(strCompanyName))  
   END  
  ,@strAddress =   
   CASE   
   WHEN LTRIM(RTRIM(strAddress)) = ''THEN NULL  
   ELSE LTRIM(RTRIM(strAddress))  
   END  
  ,@strCounty =   
   CASE   
   WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL  
   ELSE LTRIM(RTRIM(strCounty))  
   END  
  ,@strCity =       CASE   
   WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL  
   ELSE LTRIM(RTRIM(strCity))  
    END  
  ,@strState =   
   CASE   
   WHEN LTRIM(RTRIM(strState)) = '' THEN NULL  
   ELSE LTRIM(RTRIM(strState))  
   END  
  ,@strZip =   
   CASE   
   WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL  
   ELSE LTRIM(RTRIM(strZip))  
   END  
 FROM tblSMCompanySetup  

  SELECT TOP 1
	  @dblCheckOff = CAST(RI.dblTax AS DECIMAL(18,2)) 
   ,@dblNetAmtPayable = CAST((RI.dblLineTotal + RI.dblTax) AS DECIMAL(18,2))
 FROM tblICInventoryReceipt IR
 INNER JOIN tblICInventoryReceiptItem RI on IR.intInventoryReceiptId = RI.intInventoryReceiptId
 INNER JOIN tblSCTicket c on c.intTicketId = RI.intSourceId AND c.intTicketId = @intScaleTicketId AND IR.intSourceType = 1 --SCALE


  SELECT DISTINCT  
     @strCompanyName +   
    + CHAR(13) + CHAR(10)   
    + ISNULL(@strAddress, '') +   
    + CHAR(13) + CHAR(10)   
    + ISNULL(@strCity, '') + ISNULL(', ' + @strState, '') +' '+ISNULL(@strZip, '')  
    AS strCompanyAddress  
  ,LTRIM(RTRIM(EY.strEntityName)) +   
  + CHAR(13) + CHAR(10)   
  + ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') +  
  + CHAR(13) + CHAR(10)   
  + ISNULL(LTRIM(RTRIM(EY.strEntityCity)), '')   
  + ISNULL(', '   
     + CASE   
       WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL  
       ELSE LTRIM(RTRIM(EY.strEntityState))  
       END,   
        '')   
    + ISNULL(' '   
       + CASE   
       WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL  
       ELSE LTRIM(RTRIM(EY.strEntityZipCode))  
      END,   
       '')      
    AS strEntityAddress
   ,@strReceiptNumber AS strReceiptNumer   
   ,LTRIM(Year(SC.dtmTicketDateTime)) AS strYear  
  ,LTRIM(Month(SC.dtmTicketDateTime)) AS strMonth  
  ,LTRIM(Day(SC.dtmTicketDateTime)) AS strDay  
  ,[dbo].[fnRemoveTrailingZeroes](@dblGrossWeight) AS dblGrossWeight  
  ,[dbo].[fnRemoveTrailingZeroes](@dblTareWeight) AS dblTareWeight  
  ,[dbo].[fnRemoveTrailingZeroes](@dblUnloadedGrain) AS strUnloadedGrain  
  ,[dbo].[fnRemoveTrailingZeroes](@dblDockage) AS dblDockage  
  ,[dbo].[fnRemoveTrailingZeroes](@dblDockagePercent) AS dblDockagePercent  
  ,[dbo].[fnRemoveTrailingZeroes](@dblNetWeight) AS dblNetWeight   
  ,Item.strItemNo  
  ,Attribute.strDescription AS strGrade  
  ,EY.strVendorAccountNum    
  ,SS.strStationShortDescription  
  ,SS.strStationDescription  
  ,SS.strPhone  
  ,ICStorageLocation.strName AS strBinNumber  
  ,NULL AS strBoxNoOfSample  
  ,' Scale record in '+ @strItemStockUOM AS ScaleLabel  
  ,[dbo].[fnGRConvertNumberToWords](@dblUnloadedGrain)   
  + CASE   
   WHEN @GrainUnloadedDecimal >0 THEN ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@dblUnloadedGrain)  
   ELSE ''  
    END     
  + ' '+@strItemStockUOM AS strGrainUnloadedInWords  
  ,[dbo].[fnGRConvertNumberToWords](@dblNetWeight)   
  +CASE   
    WHEN @NetWeightDecimal >0 THEN + ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@dblNetWeight)  
    ELSE ''  
   END      
  + ' '+@strItemStockUOM AS strNetWeightInWords
  
  ,@strScaleTicketNo AS  strScaleTicketNo
  ,strShipToLocationAddress = @strDeliveryLocation
	   ,strContractNumber =  ISNULL(CT.strContractNumber,'')

     ,dblPricePerNetTonne = CAST(SC.dblUnitPrice AS DECIMAL(18,2))
     ,dblTotaPurchasePrice = CAST((SC.dblUnitPrice * SC.dblNetUnits) AS DECIMAL(18,2))
     ,@dblCheckOff AS dblCheckOff
     ,@dblNetAmtPayable AS dblNetAmtPayable
     ,SC.dtmTicketDateTime AS dtmTicketDateTime
  ,ctGrade.strWeightGradeDesc    
  ,@GRRGrade as dblGrade
  ,SC.strTicketStatus
 FROM tblSCTicket SC  
 JOIN vyuCTEntity EY ON EY.intEntityId = SC.intEntityId  
 JOIN tblICItem Item ON Item.intItemId = SC.intItemId  
 JOIN tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId  
 LEFT JOIN tblICStorageLocation ICStorageLocation on ICStorageLocation.intStorageLocationId = SC.intStorageLocationId  
 LEFT JOIN tblICCommodityAttribute Attribute ON Attribute.intCommodityAttributeId=SC.intCommodityAttributeId
 LEFT JOIN tblCTWeightGrade ctGrade ON ctGrade.intWeightGradeId = SC.intGradeId
 LEFT JOIN tblGLAccount  glAccount ON glAccount.intAccountId = ctGrade.intAccountId
 LEFT JOIN tblEMEntityLocation ShipToLocation ON ShipToLocation.intEntityId = SC.intEntityId
 LEFT JOIN tblCTContractDetail CTD ON CTD.intContractDetailId = SC.intContractId  
 LEFT JOIN tblCTContractHeader CT ON CT.intContractHeaderId = CTD.intContractHeaderId
 WHERE SC.intTicketId = @intScaleTicketId   


 END TRY

BEGIN CATCH
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
END CATCH
