CREATE Proc [dbo].[uspRKDPRInvDailyPositionDetail]	 
		 @intCommodityId int,
		 @intLocationId int= null
	
	AS

IF ISNULL(@intLocationId,0) <> 0
BEGIN

SELECT  @intCommodityId as intCommodityId,'In-House' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t   
       
UNION ALL
SELECT @intCommodityId as intCommodityId,'Off-Site' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t         

UNION ALL
SELECT @intCommodityId as intCommodityId,'Purchase In-Transit' as [strType],         
	    ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t 

UNION ALL
SELECT @intCommodityId as intCommodityId,'Sales In-Transit' as [strType],         
	    ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t    

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Open Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t      

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Grain Bank' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t 

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Condo Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t   

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Other Third Party Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t             

UNION ALL           
SELECT @intCommodityId as intCommodityId,'dblTotal Non-Receipted' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t   

UNION ALL           

	SELECT @intCommodityId as intCommodityId,'Collatral Receipts - Sales' as [strType], SUM(dblOriginalQuantity)- sum(dblAdjustmentAmount) dblTotal FROM (
	SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount,intContractHeaderId,SUM(dblOriginalQuantity) dblOriginalQuantity FROM tblRKCollateral c
	JOIN tblRKCollateralAdjustment ca ON c.intCollateralId=ca.intCollateralId WHERE strType='Sale'
	AND c.intCommodityId=@intCommodityId AND c.intLocationId=@intLocationId
	GROUP BY intContractHeaderId
	) t
	 WHERE dblAdjustmentAmount <> dblOriginalQuantity

UNION ALL           
	SELECT @intCommodityId as intCommodityId,'Collatral Receipts - Purchase' as [strType], SUM(dblOriginalQuantity)- sum(dblAdjustmentAmount) dblTotal FROM (
	SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount,intContractHeaderId,SUM(dblOriginalQuantity) dblOriginalQuantity FROM tblRKCollateral c
	JOIN tblRKCollateralAdjustment ca ON c.intCollateralId=ca.intCollateralId WHERE strType='Purchase'
AND c.intCommodityId=@intCommodityId AND c.intLocationId=@intLocationId
	GROUP BY intContractHeaderId
	) t
	 WHERE dblAdjustmentAmount <> dblOriginalQuantity

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Warehouse Receipts' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t       

UNION ALL           
SELECT @intCommodityId as intCommodityId,'DP' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t     

UNION ALL           
SELECT @intCommodityId as intCommodityId,'Purchase Basis Deliveries' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT 
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i 		
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId     
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i 
		JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		JOIN tblICItemLocation il on il.intItemLocationId=it1.intItemLocationId    
		WHERE i.intCommodityId= @intCommodityId and il.intLocationId=@intLocationId) as ReserveQty     
 ) t      

END
ELSE

BEGIN


			SELECT @intCommodityId as intCommodityId,'In-House' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					 
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t   
			       
			UNION ALL
			SELECT @intCommodityId as intCommodityId,'Off-Site' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t         

			UNION ALL
			SELECT @intCommodityId as intCommodityId,'Purchase In-Transit' as [strType],         
					ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t 

			UNION ALL
			SELECT @intCommodityId as intCommodityId,'Sales In-Transit' as [strType],         
					ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId  
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t    

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Open Storage' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId  
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t      

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Grain Bank' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t 

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Condo Storage' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t   

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Other Third Party Storage' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t             

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'dblTotal Non-Receipted' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId  
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t   

			UNION ALL           

				SELECT @intCommodityId as intCommodityId,'Collatral Receipts - Sales' as [strType], SUM(dblOriginalQuantity)- sum(dblAdjustmentAmount) dblTotal FROM (
				SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount,intContractHeaderId,SUM(dblOriginalQuantity) dblOriginalQuantity FROM tblRKCollateral c
				JOIN tblRKCollateralAdjustment ca ON c.intCollateralId=ca.intCollateralId WHERE strType='Sale'
				AND c.intCommodityId=@intCommodityId
				GROUP BY intContractHeaderId
				) t
				 WHERE dblAdjustmentAmount <> dblOriginalQuantity

			UNION ALL           
				SELECT @intCommodityId as intCommodityId,'Collatral Receipts - Purchase' as [strType], SUM(dblOriginalQuantity)- sum(dblAdjustmentAmount) dblTotal FROM (
				SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount,intContractHeaderId,SUM(dblOriginalQuantity) dblOriginalQuantity FROM tblRKCollateral c
				JOIN tblRKCollateralAdjustment ca ON c.intCollateralId=ca.intCollateralId WHERE strType='Purchase'
				AND c.intCommodityId=@intCommodityId GROUP BY intContractHeaderId
				) t
				 WHERE dblAdjustmentAmount <> dblOriginalQuantity

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Warehouse Receipts' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					 
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId  
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t       

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'DP' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t     

			UNION ALL           
			SELECT @intCommodityId as intCommodityId,'Purchase Basis Deliveries' as [strType],         
					ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
			FROM(            
			SELECT 
					(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
					FROM tblICItem i 		
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					WHERE i.intCommodityId= @intCommodityId ) as invQty
					,(SELECT SUM(isnull(sr1.dblQty,0))  	   
					FROM tblICItem i 
					JOIN tblICItemStock it1 ON it1.intItemId = i.intItemId   
					JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId 
					WHERE i.intCommodityId= @intCommodityId ) as ReserveQty     
			 ) t      

END