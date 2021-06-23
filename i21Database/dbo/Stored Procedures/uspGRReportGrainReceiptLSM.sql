CREATE PROCEDURE [dbo].[uspGRReportGrainReceiptLSM]    
 @xmlParam NVARCHAR(MAX) = NULL    
AS    
BEGIN TRY
 DECLARE @ErrMsg NVARCHAR(MAX)    
 DECLARE
	  @strAddress NVARCHAR(500)    
     ,@strCounty NVARCHAR(500)    
     ,@strCity NVARCHAR(500)    
     ,@strState NVARCHAR(500)    
     ,@strZip NVARCHAR(500)    
     ,@strCountry NVARCHAR(500)  
     ,@strCompanyName NVARCHAR(500)
	 ,@strPhone NVARCHAR(200)
	 ,@strFax NVARCHAR(200)
	 ,@xmlDocumentId INT    
     ,@intScaleTicketId INT
	 ,@strReceiptNumber NVARCHAR(30)
	 ,@strItemStockUOM NVARCHAR(30) 
	 ,@dblUnloadedGrain DECIMAL(24,10)
	 ,@dblDockage DECIMAL(24,10)
	 ,@dblTotaPurchasePrice DECIMAL(24,10)
	 ,@dblCheckOff DECIMAL(24,2)  
     ,@dblNetAmtPayable DECIMAL(24,2)  
	 ,@dblDockagePercent DECIMAL(24,10)   
	 ,@GrainUnloadedDecimal DECIMAL(24,10)
	 ,@dblNetWeight DECIMAL(24,10) 
	 ,@NetWeightDecimal DECIMAL(24,10)
	 ,@blbCompanyLogo VARBINARY(MAX)

	    
	           


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
 @dblUnloadedGrain =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)),3)
 ,@dblDockage = ROUND(SC.dblShrink,3)
 ,@dblDockagePercent = ROUND((SC.dblShrink*100.0/(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)))),2)  
 ,@dblNetWeight=ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight))-SC.dblShrink,3) 
 FROM   tblICUnitMeasure UnitMeasure    
 JOIN   tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=UnitMeasure.intUnitMeasureId    
 JOIN   tblSCTicket SC ON SC.intItemUOMIdTo=ItemUOM.intItemUOMId    
 JOIN   tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId    
 JOIN   tblICItemUOM ItemUOM1 ON ItemUOM1.intUnitMeasureId=SS.intUnitMeasureId AND  ItemUOM1.intItemId=SC.intItemId    
 WHERE  SC.intTicketId = @intScaleTicketId

  SET @GrainUnloadedDecimal=ROUND(@dblUnloadedGrain-FLOOR(@dblUnloadedGrain),3)    
  SET @NetWeightDecimal=ROUND(@dblNetWeight-FLOOR(@dblNetWeight),3)    
 
   SELECT TOP 1  
    @dblCheckOff = RI.dblTax  
   ,@dblNetAmtPayable = (RI.dblLineTotal + RI.dblTax)  
 FROM tblICInventoryReceipt IR  
 INNER JOIN tblICInventoryReceiptItem RI on IR.intInventoryReceiptId = RI.intInventoryReceiptId  
 INNER JOIN tblSCTicket c on c.intTicketId = RI.intSourceId AND c.intTicketId = @intScaleTicketId AND IR.intSourceType = 1 --SCALE 
 
 
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
  ,@strPhone = 
   CASE
   WHEN LTRIM(RTRIM(strPhone)) = '' THEN NULL    
   ELSE LTRIM(RTRIM(strPhone)) 
   END
  ,@strFax = 
   CASE
   WHEN LTRIM(RTRIM(strFax)) = '' THEN NULL    
   ELSE LTRIM(RTRIM(strFax)) 
   END
   ,@blbCompanyLogo = imgCompanyLogo
 FROM tblSMCompanySetup     
 

   
SELECT 
    -- @strCompanyName +     
    --+ CHAR(13) + CHAR(10)     
    ISNULL(@strAddress, '') +     
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
,@strCompanyName AS strCompanyName
,@strPhone AS strPhone
,@strFax AS strFax
,SC.strTicketNumber
,@strReceiptNumber AS strReceiptNumber
,@strCompanyName AS strEntityName
,imgCompanyLogo  = dbo.fnSMGetCompanyLogo('Header')  --@blbCompanyLogo
,SC.dblGrossWeight AS 'Weight(MT)'
,SC.dblTareWeight AS 'Vehicle Weight'
,[dbo].[fnRemoveTrailingZeroes](@dblUnloadedGrain) AS strUnloadedGrain
,[dbo].[fnRemoveTrailingZeroes](@dblDockage) AS dblDockage
,[dbo].[fnRemoveTrailingZeroes](dblUnitPrice) AS dblUnitPrice
,[dbo].[fnRemoveTrailingZeroes](@dblDockagePercent) AS dblDockagePercent    
,[dbo].[fnRemoveTrailingZeroes](@dblCheckOff) AS dblCheckOff
,[dbo].[fnRemoveTrailingZeroes](@dblNetAmtPayable) AS dblNetAmtPayable
, CAST((ISNULL(dblUnitPrice,0) * ISNULL(dblNetUnits,0)) AS DECIMAL(18,2)) AS dblTotalPurchasePrice
,EL.strLocationName AS strFarmName, 
[dbo].[fnRemoveTrailingZeroes](SPD.dblSplitPercent) AS dblSplitPercent
,ITEM.strItemNo AS strGrain
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
,ISNULL(CT.strContractNumber,'') AS strContractNumber
  FROM tblSCTicket SC
  INNER JOIN vyuCTEntity EY ON EY.intEntityId = SC.intEntityId
  LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = SC.intFarmFieldId
  LEFT JOIN  tblEMEntitySplit SP ON SP.intSplitId = SC.intSplitId
  LEFT JOIN tblEMEntitySplitDetail SPD ON SPD.intSplitId = SP.intSplitId AND SPD.intEntityId = SC.intEntityId
  LEFT JOIN tblICItem ITEM ON ITEM.intItemId = SC.intItemId
  LEFT JOIN tblCTContractHeader CT ON CT.intContractHeaderId = SC.intContractId 
  WHERE SC.intTicketId = @intScaleTicketId

END TRY

BEGIN CATCH    
 SET @ErrMsg = ERROR_MESSAGE()    
 RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')    
END CATCH