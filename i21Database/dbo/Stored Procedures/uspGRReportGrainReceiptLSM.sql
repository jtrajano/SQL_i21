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
	 ,@strItemStockUOMSymbol NVARCHAR(30) 
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
	 ,@intInventoryReceiptId int
	 ,@intFeeItemId int   
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
    SET strGrainReceiptNumber = @strReceiptNumber    
    WHERE intTicketId = @intScaleTicketId    
 END         


 SELECT 
 @strItemStockUOM = UnitMeasure.strUnitMeasure,  
 @strItemStockUOMSymbol = UnitMeasure.strSymbol,
 @dblUnloadedGrain =  ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)),4)
 ,@dblDockage = ROUND(SC.dblShrink,4)
 ,@dblDockagePercent = ROUND((SC.dblShrink*100.0/(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight)))),2)  
 ,@dblNetWeight=ROUND(dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM1.intItemUOMId,SC.intItemUOMIdTo,(SC.dblGrossWeight-SC.dblTareWeight))-SC.dblShrink,4) 

 ,@intInventoryReceiptId = SC.intInventoryReceiptId
 ,@intFeeItemId = SS.intDefaultFeeItemId
 ,@intCommodityId = SC.intCommodityId
 FROM   tblICUnitMeasure UnitMeasure    
 JOIN   tblICItemUOM ItemUOM ON ItemUOM.intUnitMeasureId=UnitMeasure.intUnitMeasureId    
 JOIN   tblSCTicket SC ON SC.intItemUOMIdTo=ItemUOM.intItemUOMId    
 JOIN   tblSCScaleSetup SS ON SS.intScaleSetupId = SC.intScaleSetupId    
 JOIN   tblICItemUOM ItemUOM1 ON ItemUOM1.intUnitMeasureId=SS.intUnitMeasureId AND  ItemUOM1.intItemId=SC.intItemId    
 WHERE  SC.intTicketId = @intScaleTicketId

  SET @GrainUnloadedDecimal=ROUND(@dblUnloadedGrain-FLOOR(@dblUnloadedGrain),4)    
 
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
   WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL    
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
 

 -- We need to know where to get the discount information
 declare @GetDiscountFromIR bit = 0
	,@TotalDiscount decimal(24, 10) = 0
	,@TotalPremiumDiscount decimal(24, 10) = 0
	, @GRRMarketingFee DECIMAL(24,10) = 0
	, @dblMarketingUnits DECIMAL(24,10) = 0
	, @dblDockageLessMarketingUnits DECIMAL(24,10) = 0
	, @intMarketingFeeId int 
 if exists(select top 1 1from tblSCTicket Ticket
			join tblGRStorageType StorageType
				on Ticket.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId
			where (	StorageType.intStorageScheduleTypeId < = 0 or 
						(StorageType.intStorageScheduleTypeId > 0 and StorageType.ysnDPOwnedType = 1)
				)
				and Ticket.intTicketId = @intScaleTicketId
		)
begin 
	set @GetDiscountFromIR = 1
end


--- Client side discount computation

	Declare @TotalWetShrink decimal(24, 10)
	Declare @TotalNetShrink decimal(24, 10)
	Declare @TotalGrossShrink decimal(24, 10)
	
	Declare @TicketGrossWeight decimal(24,10)
	Declare @TicketGrossWeight1 decimal(24,10)
	Declare @TicketGrossWeight2 decimal(24,10)


	Declare @TicketComputedGross decimal(24,10)
	Declare @TicketComputedWet decimal(24,10)
	Declare @TicketComputedNet decimal(24,10)
	
	Declare @FinalGrossWeight decimal(24,10)
	Declare @ConvertUOM decimal(24,10)

	Declare @ysnMultipleWeight bit
	declare @ysnMarketingFeeComputeGross bit




	select @TotalGrossShrink  = sum (Discount.dblShrinkPercent)
	from tblSCTicket Ticket			
		join tblQMTicketDiscount Discount
			on Ticket.intTicketId = Discount.intTicketId		
	where Ticket.intTicketId = @intScaleTicketId
		and strShrinkWhat = 'Gross Weight' or strShrinkWhat = 'P'
				
	select @TotalNetShrink  = sum (Discount.dblShrinkPercent)
	from tblSCTicket Ticket			
		join tblQMTicketDiscount Discount
			on Ticket.intTicketId = Discount.intTicketId		
	where Ticket.intTicketId = @intScaleTicketId
		and strShrinkWhat = 'Net Weight' or strShrinkWhat = 'N'
				

	select @TotalWetShrink  = sum (Discount.dblShrinkPercent)
	from tblSCTicket Ticket			
		join tblQMTicketDiscount Discount
			on Ticket.intTicketId = Discount.intTicketId		
	where Ticket.intTicketId = @intScaleTicketId
		and strShrinkWhat = 'Wet Weight' or strShrinkWhat = 'W'
				
	---
	select @TotalGrossShrink = isnull(@TotalGrossShrink, 0)
	select @TotalNetShrink = isnull(@TotalNetShrink, 0)
	select @TotalWetShrink = isnull(@TotalWetShrink, 0)


select 
		@intMarketingFeeId = DiscountCode.intItemId
		, @dblMarketingUnits = Discount.dblShrinkPercent 		
		, @ysnMarketingFeeComputeGross = case when strShrinkWhat = 'Gross Weight' or strShrinkWhat = 'P' then 1 else 0 end
		

		, @TicketGrossWeight = Ticket.dblGrossWeight - Ticket.dblTareWeight
		, @TicketGrossWeight1 = isnull(Ticket.dblGrossWeight1, 0) - isnull(Ticket.dblTareWeight1, 0)
		, @TicketGrossWeight2 = isnull(Ticket.dblGrossWeight2, 0) - isnull(Ticket.dblTareWeight2, 0)
		

		, @ysnMultipleWeight = ScaleSetup.ysnMultipleWeights
		, @ConvertUOM = Ticket.dblConvertedUOMQty
	
	from tblSCTicket Ticket			
		join tblQMTicketDiscount Discount
			on Ticket.intTicketId = Discount.intTicketId
		join tblGRDiscountScheduleCode DiscountCode
			on Discount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId
				and DiscountCode.ysnMarketingFee = 1		
		join tblSCScaleSetup ScaleSetup
			on Ticket.intScaleSetupId = ScaleSetup.intScaleSetupId
	where Ticket.intTicketId = @intScaleTicketId


	if @ysnMultipleWeight = 0
	begin
		select @TicketGrossWeight1 = 0, @TicketGrossWeight2 = 0
	end

	select @FinalGrossWeight = @TicketGrossWeight + @TicketGrossWeight1 + @TicketGrossWeight2
	

	select @TicketComputedGross = @FinalGrossWeight * (@TotalGrossShrink/ 100)
	select @TicketComputedWet = (@FinalGrossWeight - @TicketComputedGross) * (@TotalWetShrink / 100)
	select @TicketComputedNet = (@FinalGrossWeight - @TicketComputedGross - @TicketComputedWet) * (@TotalNetShrink / 100) 
		

		
	--select @FinalGrossWeight, @TotalGrossShrink, @TotalNetShrink, @TotalWetShrink, @TicketComputedGross, @TicketComputedWet, @TicketComputedNet, @ConvertUOM --, (@TicketComputedNet * @ConvertUOM)  * (@dblMarketingUnits / @TotalNetShrink)
		

	set @dblMarketingUnits = round(isnull( (case when @ysnMarketingFeeComputeGross = 1 then @TicketComputedGross else @TicketComputedNet end  * @ConvertUOM)  * (@dblMarketingUnits / case when @ysnMarketingFeeComputeGross = 1 then isnull(nullif(@TotalGrossShrink, 0), 1) else isnull(nullif(@TotalNetShrink, 0), 1) end ), 0), 4)
	
	
	



if @GetDiscountFromIR = 1 
begin
	--select @GetDiscountFromIR = sum(dblAmount) 
	--	from tblICInventoryReceiptCharge 
	--		where intInventoryReceiptId = @intInventoryReceiptId

	select 
		@TotalDiscount = @TotalDiscount + case when TicketDiscount.dblDiscountAmount >= 0 then ReceiptCharge.dblAmount else 0 end
		,@TotalPremiumDiscount = @TotalPremiumDiscount + case when TicketDiscount.dblDiscountAmount < 0 then ReceiptCharge.dblAmount else 0 end		
	from tblSCTicket Ticket			
		join tblICInventoryReceiptItem ReceiptItem
			on ReceiptItem.intSourceId = Ticket.intTicketId
		join tblICInventoryReceipt Receipt
			on ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
				and Receipt.intSourceType = 1
		join tblQMTicketDiscount TicketDiscount
			on Ticket.intTicketId = TicketDiscount.intTicketId	
		join tblGRDiscountScheduleCode DiscountCode
			on TicketDiscount.intDiscountScheduleCodeId = DiscountCode.intDiscountScheduleCodeId

		join tblICInventoryReceiptCharge ReceiptCharge
			on Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				and DiscountCode.intItemId = ReceiptCharge.intChargeId
				and (@intFeeItemId is null or ReceiptCharge.intChargeId <> @intFeeItemId)
	where Ticket.intTicketId = @intScaleTicketId

	
	--
	if @intMarketingFeeId is not null
	select 
		@GRRMarketingFee = @GRRMarketingFee + ReceiptCharge.dblAmount
	from tblSCTicket Ticket					
		join tblICInventoryReceiptItem ReceiptItem
			on ReceiptItem.intSourceId = Ticket.intTicketId
		join tblICInventoryReceipt Receipt
			on ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
				and Receipt.intSourceType = 1		
		join tblICInventoryReceiptCharge ReceiptCharge
			on Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId								
	where Ticket.intTicketId = @intScaleTicketId
		and ReceiptCharge.intChargeId = @intMarketingFeeId
	

end
else
begin
	
	select 
		@GRRMarketingFee = @GRRMarketingFee + BillDetail.dblTotal
	 from tblSCTicket Ticket 
	join tblGRCustomerStorage CustomerStorage
		on Ticket.intTicketId = CustomerStorage.intTicketId
	join tblGRSettleStorageTicket StorageTicket
		on CustomerStorage.intCustomerStorageId = StorageTicket.intCustomerStorageId
	join tblGRSettleStorage SettleStorage
		on StorageTicket.intSettleStorageId = SettleStorage.intSettleStorageId
		and SettleStorage.intParentSettleStorageId is not null
	join tblAPBillDetail BillDetail
		on CustomerStorage.intCustomerStorageId = BillDetail.intCustomerStorageId
			and SettleStorage.intSettleStorageId = BillDetail.intSettleStorageId		
	where Ticket.intTicketId = @intScaleTicketId
		and BillDetail.intItemId = @intMarketingFeeId

	set @GRRMarketingFee = abs(@GRRMarketingFee)
end


declare @SettleStorageTickets nvarchar(250)
select @SettleStorageTickets = ''
select @SettleStorageTickets = @SettleStorageTickets + SettleStorage.strStorageTicket + ',' from tblSCTicket Ticket
	join tblGRCustomerStorage CustomerStorage
		on Ticket.intTicketId = CustomerStorage.intTicketId
	join tblGRSettleStorageTicket StorageTicket
		on CustomerStorage.intCustomerStorageId = StorageTicket.intCustomerStorageId
	join tblGRSettleStorage SettleStorage
		on StorageTicket.intSettleStorageId = SettleStorage.intSettleStorageId
		and SettleStorage.intParentSettleStorageId is not null
	where Ticket.intTicketId = @intScaleTicketId


if @SettleStorageTickets <> ''
begin
	declare @len as int 
	set @len = len(@SettleStorageTickets) - 1
	if @len < = 0
	begin
		set @len = 1
	end 

	set @SettleStorageTickets = substring(@SettleStorageTickets, 1, @len)
end 
--Grain Receipt item Mapping
declare 
	@GRRTestWeight DECIMAL(24,10)
	 ,@GRRCCFM DECIMAL(24,10)
	 ,@GRRGrade DECIMAL(24,10)
	 ,@GRRFactor DECIMAL(24,10)
	 ,@GRRProtein DECIMAL(24,10)
	 ,@GRRMoisture DECIMAL(24,10)
	 ,@GRRSplit DECIMAL(24,10)

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
	@GRRTestWeight = isnull(TestWeight.dblGradeReading, 0)
	,@GRRCCFM = isnull(CCFM.dblGradeReading, 0)
	,@GRRGrade = isnull(Grade.dblGradeReading, 0)
	,@GRRFactor = isnull(Factor.dblGradeReading, 0)
	,@GRRProtein = isnull(Protein.dblGradeReading, 0)
	,@GRRMoisture = isnull(Moisture.dblGradeReading, 0)
	,@GRRSplit = isnull(Split.dblGradeReading, 0)

from tblSCGrainReceiptDiscountMapping Preference
	--left join TicketDiscountInfo MarketingFee
	--	on Preference.[intGRRItemMarketingFeeId] = MarketingFee.intItemId
	left join TicketDiscountInfo TestWeight
		on Preference.[intTestWeightId] = TestWeight.intItemId
	left join TicketDiscountInfo CCFM
		on Preference.[intCCFMId] = CCFM.intItemId
	left join TicketDiscountInfo Grade
		on Preference.[intGradeId] = Grade.intItemId
	left join TicketDiscountInfo Factor
		on Preference.[intFactorId] = Factor.intItemId
	left join TicketDiscountInfo Protein
		on Preference.[intProteinId] = Protein.intItemId
	left join TicketDiscountInfo Moisture
		on Preference.[intMoistureId] = Moisture.intItemId
	left join TicketDiscountInfo Split
		on Preference.[intSplitId] = Split.intItemId
where Preference.intCommodityId = @intCommodityId
		
--+ @GRRMarketingFee
declare @dblComputedNetWeight decimal(24,10)
set @dblComputedNetWeight = @dblUnloadedGrain - (@dblDockage )

SET @NetWeightDecimal=ROUND(@dblComputedNetWeight-FLOOR(@dblComputedNetWeight),3)    

set @dblDockageLessMarketingUnits = @dblDockage - @dblMarketingUnits
SELECT 
    -- @strCompanyName +     
    --+ CHAR(13) + CHAR(10)     
    ISNULL(@strAddress, '') +     
    + CHAR(13) + CHAR(10)     
    + ISNULL(@strCity, '') + ISNULL(', ' + @strState, '') +' '+ISNULL(@strZip, '')    
    AS strCompanyAddress    
  ,LTRIM(RTRIM(EY.strEntityName)) +   ' ' +  
  + CHAR(13) + CHAR(10)     
  + ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') + 
	+ ' '     
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
,ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') +      
	+ ' '
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
    AS strEntityAddressDetail
,@strCompanyName AS strCompanyName
,@strPhone AS strPhone
,@strFax AS strFax
,SC.strTicketNumber
,@strReceiptNumber AS strReceiptNumber
,EY.strEntityName AS strEntityName
,imgCompanyLogo  = dbo.fnSMGetCompanyLogo('Header')  --@blbCompanyLogo
,ItemUnitMeasure.strSymbol  as [FromUOM]
,@strItemStockUOMSymbol as [ToUOM]
,cast(SC.dblGrossWeight as decimal(18, 4 )) AS 'Weight(MT)'
,cast(SC.dblTareWeight as decimal(18,4)) AS 'Vehicle Weight'
,cast(@dblUnloadedGrain as decimal(18,4))  dblUnloadedGrain
,cast(@dblDockage as decimal(18,4)) AS dblDockage
,dblUnitPrice AS dblUnitPrice
,@dblDockagePercent AS dblDockagePercent    
,@dblCheckOff AS dblCheckOff
,@dblNetAmtPayable AS dblNetAmtPayable
, CAST((ISNULL(dblUnitPrice,0) * ISNULL(dblNetUnits,0)) AS DECIMAL(18,4)) AS dblTotalPurchasePrice
, EL.strLocationName AS strFarmName
, EL.strFarmFieldNumber as strFarmFieldNumber
, @GRRSplit as dblSplitPercent -- [dbo].[fnRemoveTrailingZeroes](SPD.dblSplitPercent) AS dblSplitPercent
,ITEM.strItemNo AS strGrain
,[dbo].[fnGRConvertNumberToWords](@dblUnloadedGrain)     
  + CASE     
   WHEN @GrainUnloadedDecimal >0 THEN ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@dblUnloadedGrain)    
   ELSE ''    
    END       
  + ' '+@strItemStockUOM AS strGrainUnloadedInWords    
  ,[dbo].[fnGRConvertNumberToWords](@dblComputedNetWeight)     
  +CASE     
    WHEN @NetWeightDecimal >0 THEN + ' point ' + [dbo].[fnGRConvertDecimalPartToWords](@NetWeightDecimal)    
    ELSE ''    
   END        
  + ' ' + @strItemStockUOM AS strNetWeightInWords
,ISNULL(CT.strContractNumber,'') AS strContractNumber
,cast(isnull(@dblComputedNetWeight, 0) as decimal(18,4))  as dblNetAfterDeduct
,cast(isnull(@GRRMarketingFee, 0) as decimal(18,4)) as dblMarketingFee
,cast(isnull(@dblMarketingUnits, 0) as decimal(18,4)) as dblMarketingUnits
,cast(isnull(@dblDockageLessMarketingUnits, 0) as decimal(18,4)) as dblDockageLessMarketingUnits
,@GRRTestWeight as dblTestWeight
,@GRRCCFM as dblCCFM
,@GRRGrade as dblGrade
,@GRRFactor as dblFactor
,@GRRProtein as dblProtein
,@GRRMoisture as dblMoisture
,ITEM.strShortName as strVarietyCode

,@TotalDiscount  as dblTotalDiscount
,@TotalPremiumDiscount as dblTotalPremiumDiscount

,@SettleStorageTickets as strSettleTickets
,SC.strCustomerReference as strReference 
,SC.strTicketComment as strComment
,SC.strDiscountComment as strDiscountComment

  FROM tblSCTicket SC
  INNER JOIN vyuCTEntity EY ON EY.intEntityId = SC.intEntityId
	AND EY.strEntityType = CASE WHEN SC.strInOutFlag = 'I' THEN 'Vendor' ELSE 'Customer' end
  LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = SC.intFarmFieldId
  LEFT JOIN  tblEMEntitySplit SP ON SP.intSplitId = SC.intSplitId
  LEFT JOIN tblEMEntitySplitDetail SPD ON SPD.intSplitId = SP.intSplitId AND SPD.intEntityId = SC.intEntityId
  LEFT JOIN tblICItem ITEM ON ITEM.intItemId = SC.intItemId
  left join tblCTContractDetail ContractDetail
		on SC.intContractId = ContractDetail.intContractDetailId
  LEFT JOIN tblCTContractHeader CT ON CT.intContractHeaderId = ContractDetail.intContractHeaderId

  left join tblICItemUOM ItemUOM
	on SC.intItemUOMIdFrom = ItemUOM.intItemUOMId
		and SC.intItemId = ItemUOM.intItemId
	left join tblICUnitMeasure ItemUnitMeasure
		on ItemUOM.intUnitMeasureId = ItemUnitMeasure.intUnitMeasureId

  left join tblICItemUOM ItemToUOM
	on SC.intItemUOMIdTo = ItemToUOM.intItemUOMId
		and SC.intItemId = ItemToUOM.intItemId
	left join tblICUnitMeasure ItemToUnitMeasure
		on ItemToUOM.intUnitMeasureId = ItemToUnitMeasure.intUnitMeasureId


  WHERE SC.intTicketId = @intScaleTicketId

END TRY

BEGIN CATCH    
 SET @ErrMsg = ERROR_MESSAGE()    
 RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')    
END CATCH
