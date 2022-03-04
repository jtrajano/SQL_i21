CREATE VIEW [dbo].[vyuMBILDeliveryDetail]      
AS      
SELECT detail.intDeliveryDetailId        
      ,detail.intDeliveryHeaderId        
      ,detail.intLoadDetailId    
      ,detail.intItemId        
      ,item.strDescription        
      ,item.strItemNo      
      ,detail.dblQuantity        
      ,detail.dblDeliveredQty        
      ,detail.strTank        
      ,detail.dblStickStartReading        
      ,detail.dblStickEndReading        
      ,detail.ysnDelivered
	  ,detail.intShiftId      
FROM tblMBILDeliveryDetail detail            
INNER JOIN tblICItem item ON detail.intItemId = item.intItemId 