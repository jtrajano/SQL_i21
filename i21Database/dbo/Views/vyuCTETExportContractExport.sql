CREATE VIEW [dbo].[vyuCTETExportContractExport]    
     
AS     
 SELECT *,    
   bkdelu * bkpric    AS bkusp    
 FROM    
 (    
  SELECT bkloc  = CL.strLocationNumber ,    
    bkcust  = EY.strEntityNo ,    
    bkitem  = IM.strItemNo ,    
    bkseq  = CD.intContractSeq ,    
    bkunit  = CD.dblQuantity ,    
    bkpric  = ISNULL(B.dblPrice,CD.dblCashPrice),    
    bkppd  = NULL ,    
    bkdelu  = CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalance,0)    
        ELSE ISNULL(CD.dblQuantity,0) - ISNULL(CD.dblBalance,0)                
         END ,    
    bkterm  = LEFT(ISNULL(TM.strTermCode,''),2) ,    
    bkdelt  = NULL ,    
    chrTaxable = 'N' ,    
    bknum  = strContractNumber ,    
    bkstart  = REPLACE(CONVERT(NVARCHAR(50),dtmStartDate,101),'/','') ,    
    bkend  = REPLACE(CONVERT(NVARCHAR(50),dtmEndDate,101),'/','')    
    ,contractPrice = dbo.fnCTGetContractPrice(CD.intContractDetailId)    
    ,maxprice = CH.ysnMaxPrice    
    ,CD.dblCashPrice     
    ,B.strPricing    
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
       ,NULL --@CurrencyExchangeRate --18.3    
       ,NULL --@CurrencyExchangeRateTypeId --18.3    
       ,0 --@ysnFromItemSelection--18.3
       ,0 --@ysnDisregardContractQty    
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