Create PROCEDURE [dbo].[uspCTUpdateIntegrationPrice]    
 @strContractNumber NVARCHAR(20)    
 , @intContractSeq INT    
 , @dblPurchasePrice NUMERIC(18, 6)    
 , @dblLandedPrice NUMERIC(18, 6)    
 , @dblSalesPrice NUMERIC(18, 6)    
 , @intUserId INT    
AS    
    
BEGIN    
 DECLARE @intContractDetailId INT    
  , @intContractHeaderId INT    
  , @prevPurchasePrice NUMERIC(18, 6)    
  , @prevLandedPrice NUMERIC(18, 6)    
  , @prevSalesPrice NUMERIC(18, 6)    
    
 DECLARE @Message NVARCHAR(250)     
    
 SELECT TOP 1 @intContractDetailId = cd.intContractDetailId    
  , @intContractHeaderId = cd.intContractHeaderId    
  , @prevPurchasePrice = cd.dblPurchasePrice    
  , @prevLandedPrice = cd.dblLandedPrice    
  , @prevSalesPrice = cd.dblSalesPrice    
 FROM tblCTContractDetail cd    
 JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId    
 WHERE ch.strContractNumber = @strContractNumber AND cd.intContractSeq = @intContractSeq    
    
 IF (ISNULL(@intContractDetailId, 0) = 0)    
 BEGIN    
  SET @Message = 'Contract ' + @strContractNumber + ' with sequence ' + CAST(@intContractSeq AS NVARCHAR) + ' does not exist.'    
  RAISERROR(@Message, 16, 1)    
 END    
 ELSE IF (    
  ISNULL(@prevPurchasePrice, 0) = ISNULL(@dblPurchasePrice, 0)    
  AND ISNULL(@prevLandedPrice, 0) = ISNULL(@dblLandedPrice, 0)    
  AND ISNULL(@prevSalesPrice, 0) = ISNULL(@dblSalesPrice, 0)    
 )    
 BEGIN    
  SET @Message = 'No price change detected.'    
  RAISERROR(@Message, 16, 1)    
 END    
 ELSE    
 BEGIN    
      
    
  UPDATE tblCTContractDetail    
  SET dblPurchasePrice = @dblPurchasePrice    
   , dblLandedPrice = @dblLandedPrice    
   , dblSalesPrice = @dblSalesPrice    
  WHERE intContractDetailId = @intContractDetailId    
    
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