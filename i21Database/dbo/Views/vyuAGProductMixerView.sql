CREATE VIEW [dbo].[vyuAGProductMixerView]  
AS  
SELECT   
    PM.intProductMixerId  
    ,PM.intConcurrencyId  
    ,PM.intLocationId  
    ,CL.strLocationName  
    ,PM.strMixerNumber  
    ,PM.strDescription  
    ,PM.strType  
    ,PM.strRestrictedBatches  
      
    ,PM.dblSize  
    ,PM.intSizeUOMId  
    ,[strSizeUOM] = SIZE_AGUOM.strUnitMeasure  
  
    ,PM.dblVolume  
    ,PM.intVolumeUOMId  
    ,[strVolumeUOM] = VOLUME_AGUOM.strUnitMeasure  
  
    ,PM.dblMaxBatchSize  
    ,PM.intMaxBatchSizeUOMId  
    ,[strMaxBatchSizeUOM] = MBS_AGUOM.strUnitMeasure

  
FROM tblAGProductMixer PM  
INNER JOIN tblSMCompanyLocation CL  
    ON CL.intCompanyLocationId = PM.intLocationId  
LEFT JOIN tblAGUnitMeasure SIZE_AGUOM  
    ON SIZE_AGUOM.intAGUnitMeasureId = PM.intSizeUOMId  
LEFT JOIN tblAGUnitMeasure VOLUME_AGUOM  
    ON VOLUME_AGUOM.intAGUnitMeasureId = PM.intVolumeUOMId  
LEFT JOIN tblAGUnitMeasure MBS_AGUOM  
    ON MBS_AGUOM.intAGUnitMeasureId = PM.intMaxBatchSizeUOMId
