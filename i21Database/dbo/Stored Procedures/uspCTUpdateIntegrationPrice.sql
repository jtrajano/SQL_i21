CREATE PROCEDURE [dbo].[uspCTUpdateIntegrationPrice]    
 @strContractNumber NVARCHAR(20)    
 , @intContractSeq INT    
 , @dblPurchasePrice NUMERIC(18, 6)    
 , @dblLandedPrice NUMERIC(18, 6)    
 , @dblSalesPrice NUMERIC(18, 6)    
 , @intUserId INT    
 , @intFeedPriceItemUOMId INT    
 , @intFeedPriceCurrencyId INT    
AS    
    
BEGIN    
 DECLARE @intContractDetailId INT    
  , @intContractHeaderId INT    
  , @prevPurchasePrice NUMERIC(18, 6)    
  , @prevLandedPrice NUMERIC(18, 6)    
  , @prevSalesPrice NUMERIC(18, 6)   
  , @intItemId INT    
  , @prevFeedPriceItemUOMId INT    
  , @prevFeedPriceCurrencyId INT   
  , @prevFeedPriceItemUOM nvarchar(100)
  , @prevFeedPriceCurrency nvarchar(100)
  , @newFeedPriceItemUOM nvarchar(100)
  , @newFeedPriceCurrency nvarchar(100)
    
 DECLARE @Message NVARCHAR(250)     
    
 SELECT TOP 1 @intContractDetailId = cd.intContractDetailId    
  , @intContractHeaderId = cd.intContractHeaderId    
  , @prevPurchasePrice = cd.dblPurchasePrice    
  , @prevLandedPrice = cd.dblLandedPrice    
  , @prevSalesPrice = cd.dblSalesPrice    
  , @prevFeedPriceItemUOMId = cd.intFeedPriceItemUOMId 
  , @prevFeedPriceCurrencyId = cd.intFeedPriceCurrencyId
  , @prevFeedPriceItemUOM = um.strUnitMeasure
  , @prevFeedPriceCurrency = cu.strCurrency
  , @intItemId = cd.intItemId
 FROM tblCTContractDetail cd    
 JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId    
 left join tblICItemUOM iu on iu.intItemUOMId = cd.intFeedPriceItemUOMId
 left join tblICUnitMeasure um on um.intUnitMeasureId = iu.intUnitMeasureId
 left join tblSMCurrency cu on cu.intCurrencyID = cd.intFeedPriceCurrencyId
 WHERE ch.strContractNumber = @strContractNumber AND cd.intContractSeq = @intContractSeq    
    
 
 IF ((ISNULL(@intContractDetailId, 0) > 0) and (
   ISNULL(@prevPurchasePrice, 0) <> ISNULL(@dblPurchasePrice, 0)    
   OR ISNULL(@prevLandedPrice, 0) <> ISNULL(@dblLandedPrice, 0)    
   OR ISNULL(@prevSalesPrice, 0) <> ISNULL(@dblSalesPrice, 0)      
   OR ISNULL(@prevFeedPriceItemUOMId, 0) <> ISNULL(@intFeedPriceItemUOMId, 0)      
   OR ISNULL(@prevFeedPriceCurrencyId, 0) <> ISNULL(@intFeedPriceCurrencyId, 0)   
 ))
 BEGIN
    
  UPDATE tblCTContractDetail    
  SET dblPurchasePrice = @dblPurchasePrice    
   , dblLandedPrice = @dblLandedPrice    
   , dblSalesPrice = @dblSalesPrice    
   , intFeedPriceItemUOMId = @intFeedPriceItemUOMId
   , intFeedPriceCurrencyId = @intFeedPriceCurrencyId
  WHERE intContractDetailId = @intContractDetailId    

  if (ISNULL(@intFeedPriceItemUOMId,0) <> ISNULL(@prevFeedPriceItemUOMId,0))
  begin
   select top 1 @newFeedPriceItemUOM = um.strUnitMeasure
   from tblICItemUOM iu
   join tblICUnitMeasure um on um.intUnitMeasureId = iu.intUnitMeasureId
   where iu.intItemUOMId = @intFeedPriceItemUOMId and iu.intItemId = @intItemId
  end

  if (ISNULL(@intFeedPriceCurrencyId,0) <> ISNULL(@prevFeedPriceCurrencyId,0))
  begin
   select top 1 @newFeedPriceCurrency = strCurrency from tblSMCurrency where intCurrencyID = @intFeedPriceCurrencyId
  end
    
  DECLARE @strDetails NVARCHAR(MAX)    
    
  SET @strDetails ='{      
       "action":"Updated",    
       "change":"Updated - Record: Sequence - ' + CAST(@intContractSeq AS NVARCHAR) + '",    
       "keyValue":' + CAST(@intContractSeq AS NVARCHAR) + ',    
       "iconCls":"small-tree-modified",    
       "children":    
        [   '    
      + CASE WHEN ISNULL(@prevPurchasePrice, 0) != ISNULL(@dblPurchasePrice, 0) THEN    
         '{      
         "change":"dblPurchasePrice",    
         "from":"' + ISNULL(CAST(@prevPurchasePrice AS NVARCHAR) ,'') + '",    
         "to":"' + ISNULL(CAST(@dblPurchasePrice AS NVARCHAR),'') + '",    
         "leaf":true,    
         "iconCls":"small-gear",    
         "isField":true,    
         "keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',    
         "associationKey":"tblCTContractDetails",    
         "changeDescription":"Purchase Price"    
         },'     
        ELSE '' END    
      + CASE WHEN ISNULL(@prevLandedPrice, 0) != ISNULL(@dblLandedPrice, 0) THEN    
         '{      
         "change":"dblLandedPrice",    
         "from":"' + ISNULL(CAST(@prevLandedPrice AS NVARCHAR),'') + '",    
         "to":"' + ISNULL(CAST(@dblLandedPrice AS NVARCHAR),'') + '",    
         "leaf":true,    
         "iconCls":"small-gear",    
         "isField":true,    
         "keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',    
         "associationKey":"tblCTContractDetails",    
         "changeDescription":"Landed Price"    
         },'    
        ELSE '' END    
      + CASE WHEN ISNULL(@prevSalesPrice, 0) != ISNULL(@dblSalesPrice, 0) THEN    
         '{      
         "change":"dblSalesPrice",    
         "from":"' + ISNULL(CAST(@prevSalesPrice AS NVARCHAR), '') + '",    
         "to":"' + ISNULL(CAST(@dblSalesPrice AS NVARCHAR), '') + '",    
         "leaf":true,    
         "iconCls":"small-gear",    
         "isField":true,    
         "keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',    
         "associationKey":"tblCTContractDetails",    
         "changeDescription":"Sales Price"    
         },'    
        ELSE '' END    
      + CASE WHEN ISNULL(@prevFeedPriceItemUOMId, 0) != ISNULL(@intFeedPriceItemUOMId, 0) THEN    
         '{      
         "change":"intFeedPriceItemUOMId",    
         "from":"' + isnull(@prevFeedPriceItemUOM,'') + '",    
         "to":"' + isnull(@newFeedPriceItemUOM,'') + '",    
         "leaf":true,    
         "iconCls":"small-gear",    
         "isField":true,    
         "keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',    
         "associationKey":"tblCTContractDetails",    
         "changeDescription":"Feed Price UOM"    
         },'    
        ELSE '' END    
      + CASE WHEN ISNULL(@prevFeedPriceCurrencyId, 0) != ISNULL(@intFeedPriceCurrencyId, 0) THEN    
         '{      
         "change":"intFeedPriceCurrencyId",    
         "from":"' + isnull(@prevFeedPriceCurrency,'') + '",    
         "to":"' + isnull(@newFeedPriceCurrency,'') + '",    
         "leaf":true,    
         "iconCls":"small-gear",    
         "isField":true,    
         "keyValue":' + CAST(@intContractDetailId AS NVARCHAR) + ',    
         "associationKey":"tblCTContractDetails",    
         "changeDescription":"Feed Currency"    
         },'    
        ELSE '' END 
      + ']    
      }'    
    
    EXEC    
    [uspSMAuditLog]    
    @screenName         = 'ContractManagement.view.Contract'       
   ,@keyValue           =  @intContractHeaderId       
   ,@entityId          =  @intUserId      
   ,@actionType      = 'Updated'       
   ,@actionIcon      = 'small-tree-modified'      
   ,@changeDescription  = ''      
   ,@fromValue    = ''       
   ,@toValue    = ''       
   ,@details    = @strDetails    
 END    
END  