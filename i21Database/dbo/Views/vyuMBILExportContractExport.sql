CREATE VIEW [dbo].[vyuMBILExportContractExport]
     
AS     
 SELECT 
	ROW_NUMBER() OVER(ORDER BY strLocationNumber) AS intContractExportId,
	*,    
   dblContractUnitDelivered * dblContractPrice    AS dblContractCashSpent    
 FROM    
 (    
  SELECT 
	CL.strLocationNumber,    
    EY.strEntityNo,
    IM.strItemNo,    
	IM.intItemId,    
	IM.strDescription,
    CD.intContractSeq,
    CD.dblQuantity,
    ISNULL(B.dblPrice,CD.dblCashPrice) as dblContractPrice,
    CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalance,0)    
        ELSE ISNULL(CD.dblQuantity,0) - ISNULL(CD.dblBalance,0)                
         END as dblContractUnitDelivered,
    TM.strTermCode,
    strContractNumber,
    dtmStartDate,
    dtmEndDate,
    dbo.fnCTGetContractPrice(CD.intContractDetailId) as dblContractPriceCT,
    CH.ysnMaxPrice,
    CD.dblCashPrice,
    B.strPricing
  FROM tblCTContractDetail    CD     
  INNER JOIN tblCTContractStatus CS ON CD.intContractStatusId = CS.intContractStatusId AND   
   CS.strContractStatus NOT IN('Cancelled', 'Unconfirmed', 'Complete')   
    JOIN tblCTContractHeader  CH ON CH.intContractHeaderId  = CD.intContractHeaderId      
    
  LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId  = CD.intCompanyLocationId      
  LEFT JOIN tblSMTerm    TM ON TM.intTermID    = CH.intTermId        
  LEFT JOIN tblICItem    IM ON CD.intItemId    = IM.intItemId    
  LEFT JOIN tblEMEntity    EY ON EY.intEntityId    = CH.intEntityId    
  CROSS APPLY (    
      SELECT  dblPrice, strPricing, intContractDetailId FROM dbo.fnARGetItemPricingDetails(    
       IM.intItemId    
       ,EY.intEntityId    
       ,CD.intCompanyLocationId    
       ,NULL -- @ItemUOMId TODO Contract's UOM -->> price UOM    
       ,(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference  ) -- TODO contracts currency    
       ,GETDATE()    
       ,1    
       ,CH.intContractHeaderId  --@ContractHeaderId  INT    
       ,CD.intContractDetailId  --@ContractDetailId  INT    
       ,NULL  --@ContractNumber  NVARCHAR(50)    
       ,NULL  --@ContractSeq   INT
       ,NULL  --@ItemContractHeaderId  INT    
       ,NULL  --@ItemContractDetailId  INT    
       ,NULL  --@ItemContractNumber  NVARCHAR(50)    
       ,NULL  --@ItemContractSeq   INT    
       ,NULL  --@AvailableQuantity  NUMERIC(18,6)    
       ,NULL  --@UnlimitedQuantity     BIT    
       ,NULL  --@OriginalQuantity  NUMERIC(18,6)    
       ,0 -- 1     --@CustomerPricingOnly BIT    
       ,NULL  --@ItemPricingOnly    
       ,0     --@ExcludeContractPricing    
       ,NULL  --@VendorId    INT    
       ,NULL  --@SupplyPointId   INT    
       ,NULL  --@LastCost    NUMERIC(18,6)    
       ,NULL  --@ShipToLocationId      INT    
       ,NULL  --@VendorLocationId  INT    
       ,NULL -- TODO check this >>>> intCompanyLocationPricingLevelId -- @PricingLevelId    
       ,NULL -- @AllowQtyToExceed    
       ,NULL -- @InvoiceType    
       ,NULL --TermId    
       ,0 --NULL --@GetAllAvailablePricing    
       ,NULL --@CurrencyExchangeRate 
       ,NULL --@CurrencyExchangeRateTypeId 
       ,0 --@ysnFromItemSelection
       )    
     ) B    
      
  WHERE ISNULL(B.dblPrice,ISNULL(CD.dblCashPrice,0)) > 0  AND    
    ISNULL(EY.strEntityNo,'') <> ''  AND    
    CD.dtmEndDate >= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE()))     
    AND IM.strStatus = 'Active'         
    AND    
    (    
     IM.intItemId IN (SELECT intItemId FROM tblETExportFilterItem) OR     
     IM.intCategoryId IN (SELECT intCategoryId FROM tblETExportFilterCategory)    
    )    
   AND CD.intContractDetailId = B.intContractDetailId -- added.. other contract that possible get from the function will not be used.
   
 )t