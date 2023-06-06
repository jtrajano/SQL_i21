  
Create PROCEDURE [dbo].[uspCTGetSampleDetail]  
 @intContractHeaderId INT  
  
AS  
  
BEGIN TRY  
   
  
 DECLARE @ErrMsg NVARCHAR(300),  
   @dblRepresentingQty NUMERIC(18,6),  
   @dblQuantity  NUMERIC(18,6),  
   @strSampleStatus NVARCHAR(100),  
   @intUnitMeasureId INT,  
   @intItemId   INT,  
   @ysnHasConfig  BIT  
  
 SELECT @ysnHasConfig = (select CASE WHEN strContractApprovalIncrements IS NULL THEN 0 WHEN strContractApprovalIncrements = '' THEN 0 ELSE 1 END from tblCTCompanyPreference)  
  
 DECLARE @contractDetail TABLE (  
   intContractDetailId INT  
  , dblQuantity NUMERIC(18,6)  
  , intUnitMeasureId INT  
  , intItemId INT  
  , dblRepresentingQty NUMERIC(18,6)  
  ,   strSampleStatus NVARCHAR(100)  
 );  

  DECLARE @tmpDetail TABLE (  
   intContractDetailId INT  
  , dblRepresentingQty NUMERIC(18,6)  
 ); 
  
  
  
  
  
 INSERT INTO @contractDetail  
 SELECT  intContractDetailId, dblQuantity, intUnitMeasureId , intItemId , NULL, NULL  
 FROM tblCTContractDetail   
 WHERE intContractHeaderId = @intContractHeaderId  
  
 INSERT INTO @tmpDetail
 SELECT intContractDetailId, SUM(dblRepresentingQty) dblRepresentingQty
 FROM (
	 select T.intContractDetailId,
	 CASE WHEN QM.intSampleStatusId = 3 AND QM.intTypeId = 1 THEN    
			  (SELECT (dbo.fnCTConvertQuantityToTargetItemUOM(T.intItemId,QM.intRepresentingUOMId,T.intUnitMeasureId, QM.dblRepresentingQty)))   
			   WHEN QM.intSampleStatusId = 4 AND QM.intTypeId = 1 THEN   
			  (SELECT (dbo.fnCTConvertQuantityToTargetItemUOM(T.intItemId,QM.intRepresentingUOMId,T.intUnitMeasureId, QM.dblRepresentingQty)))  
          
			 END  dblRepresentingQty
	  FROM @contractDetail T     
	  INNER JOIN tblQMSample QM on T.intContractDetailId = QM.intContractDetailId AND QM.intSampleStatusId = 3 AND QM.intTypeId = 1  
	  INNER JOIN tblQMSampleType ST ON ST.intSampleTypeId = QM.intSampleTypeId  
	  LEFT JOIN dbo.fnSplitString((select strContractApprovalIncrements from tblCTCompanyPreference),',') STT ON RTRIM(LTRIM(STT.Item)) COLLATE Latin1_General_CI_AS = ST.strSampleTypeName COLLATE Latin1_General_CI_AS  
  )		a
  GROUP BY intContractDetailId


  UPDATE T   
  SET dblRepresentingQty = TD.dblRepresentingQty
     FROM @contractDetail T     
  INNER JOIN @tmpDetail TD on T.intContractDetailId = TD.intContractDetailId 
  
     
  UPDATE T   
  SET dblRepresentingQty = CASE WHEN QM.intSampleStatusId = 3 AND QM.intTypeId = 1 THEN    
          CASE WHEN T.dblRepresentingQty >= dblQuantity THEN dblQuantity ELSE T.dblRepresentingQty END  
           WHEN QM.intSampleStatusId = 4 AND QM.intTypeId = 1 THEN   
          NULL  
         END,  
   strSampleStatus = CASE WHEN QM.intSampleStatusId = 3 AND QM.intTypeId = 1 THEN    
          CASE WHEN T.dblRepresentingQty >= dblQuantity THEN 'Approved' ELSE 'Partially Approved' END  
           WHEN QM.intSampleStatusId = 4 AND QM.intTypeId = 1 THEN   
          CASE WHEN T.dblRepresentingQty >= dblQuantity THEN 'Rejected' ELSE 'Partially Rejected' END  
         END  
     FROM @contractDetail T     
  INNER JOIN tblQMSample QM on T.intContractDetailId = QM.intContractDetailId AND QM.intSampleStatusId = 3 AND QM.intTypeId = 1  
     INNER JOIN tblQMSampleType ST ON ST.intSampleTypeId = QM.intSampleTypeId  
    
  

   
 SELECT  CT.intContractDetailId,   
   SA.strSampleNumber,  
   SA.strContainerNumber,  
   ST.strSampleTypeName,  
   CT.strSampleStatus,  
   SA.dtmTestingEndDate,  
   CT.dblRepresentingQty   
 FROM tblQMSample   SA  
 JOIN tblQMSampleType  ST  ON ST.intSampleTypeId = SA.intSampleTypeId   
 JOIN tblQMSampleStatus SS  ON SS.intSampleStatusId = SA.intSampleStatusId  
 JOIN @contractDetail  CT ON CT.intContractDetailId = SA.intContractDetailId  
 WHERE SA.intTypeId = 1  
 ORDER BY SA.intSampleId DESC  
  
  
  
END TRY  
BEGIN CATCH  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 18, 1, 'WITH NOWAIT')  
END CATCH
