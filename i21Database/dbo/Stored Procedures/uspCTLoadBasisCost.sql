Create PROCEDURE [dbo].[uspCTLoadBasisCost]  
 @ysnLoad INT  
AS  
  
 TRUNCATE TABLE tblCTBasisCost

 MERGE INTO tblCTBasisCost AS destination  
  USING  
  (  
    SELECT   
     ICI.strItemNo ,  
     ICI.intItemId,  
     ROW_NUMBER() OVER (ORDER BY CC.intPriority DESC) as [intPriority] ,  
     ROW_NUMBER() OVER (ORDER BY CC.intPriority DESC) as [intSort],  
     ISNULL(CC.[intConcurrencyId],1) as [intConcurrencyId]  ,
	 ICI.strCostMethod
   FROM [dbo].[vyuICGetCompactItem]  ICI  
   LEFT JOIN tblCTBasisCost CC ON CC.intItemId = ICI.intItemId  
   WHERE 1 = ICI.[ysnBasisContract]  
  )  
  AS SourceData  
  ON destination.intItemId = SourceData.intItemId  
  WHEN NOT MATCHED THEN  
  INSERT  
  (  
    [strItemNo]  
    ,[intItemId]  
    ,[intPriority]  
    ,[intSort]  
    ,[intConcurrencyId]  
	, strCostMethod
  )  
  VALUES  
  (  
   SourceData.strItemNo  
   ,SourceData.intItemId  
   ,SourceData.[intPriority]  
   ,SourceData.[intSort]  
   ,SourceData.[intConcurrencyId]  
   , SourceData.strCostMethod
  );
