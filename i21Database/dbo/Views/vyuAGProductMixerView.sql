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
    ,[strSizeUOM] = SIZE_UOM.strUnitMeasure

    ,PM.dblVolume
    ,PM.intVolumeUOMId
    ,[strVolumeUOM] = VOLUME_UOM.strUnitMeasure

    ,PM.dblMaxBatchSize
    ,PM.intMaxBatchSizeUOMId
    ,[strMaxBatchSizeUOM] = MBS_UOM.strUnitMeasure

FROM tblAGProductMixer PM
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = PM.intLocationId
INNER JOIN tblICUnitMeasure SIZE_UOM
    ON SIZE_UOM.intUnitMeasureId = PM.intSizeUOMId
INNER JOIN tblICUnitMeasure VOLUME_UOM
    ON VOLUME_UOM.intUnitMeasureId = PM.intVolumeUOMId
INNER JOIN tblICUnitMeasure MBS_UOM
    ON MBS_UOM.intUnitMeasureId = PM.intMaxBatchSizeUOMId