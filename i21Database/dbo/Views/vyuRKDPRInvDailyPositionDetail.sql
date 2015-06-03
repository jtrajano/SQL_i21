CREATE VIEW [dbo].[vyuRKDPRInvDailyPositionDetail]
	AS 
	
SELECT intCommodityId,'In-House' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT  c.intCommodityId
		,(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t   
       
UNION ALL
SELECT intCommodityId,'Off-Site' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t      

UNION ALL
SELECT intCommodityId,'Purchase In-Transit' as [strType],         
	    ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
		(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t 

UNION ALL
SELECT intCommodityId,'Sales In-Transit' as [strType],         
	    ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty        
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t   

UNION ALL           
SELECT intCommodityId,'Open Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
			(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty       
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t     

UNION ALL           
SELECT intCommodityId,'Grain Bank' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty      
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t  

UNION ALL           
SELECT intCommodityId,'Condo Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t     

UNION ALL           
SELECT intCommodityId,'Other Third Party Storage' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
			(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty      
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t            

UNION ALL           
SELECT intCommodityId,'dblTotal Non-Receipted' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty       
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t  

UNION ALL           
SELECT intCommodityId,'Collatral Receipts - Sales' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t 

UNION ALL           
SELECT intCommodityId,'Collatral Receipts - Purchases' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty     
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t  

UNION ALL           
SELECT intCommodityId,'Warehouse Receipts' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
			(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty      
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t         

UNION ALL           
SELECT intCommodityId,'DP' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
				(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty      
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t      

UNION ALL           
SELECT intCommodityId,'Purchase Basis Deliveries' as [strType],         
	    ISNULL(invQty,0)-ISNULL(ReserveQty,0) AS dblTotal
FROM(            
SELECT   c.intCommodityId,
			(SELECT sum(isnull(it1.dblUnitOnHand,0)) 		   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   and
		i1.intCommodityId= c.intCommodityId) as invQty
		,(SELECT SUM(isnull(sr1.dblQty,0))  	   
		FROM tblICItem i1 
		JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId   
		JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId   
		WHERE 
		i1.intCommodityId=c.intCommodityId ) as ReserveQty      
FROM tblICCommodity c            
LEFT JOIN tblICCommodityUnitMeasure um on c.intCommodityId=um.intCommodityId            
LEFT JOIN tblICUnitMeasure u on um.intUnitMeasureId=u.intUnitMeasureId            
LEFT JOIN tblICItem i on i.intCommodityId= c.intCommodityId            
LEFT JOIN tblICItemStock it on it.intItemId=i.intItemId             
LEFT JOIN tblICStockReservation sr on it.intItemId=sr.intItemId            
GROUP BY c.intCommodityId) t     

