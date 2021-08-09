CREATE PROCEDURE uspMFGetSanitizationOrderOutputSKUs @intLocationId INT
	,@intBatchId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT WP.intLotId
	,C.intContainerId
	,C.strContainerNo
	,S.intSKUId
	,S.strSKUNo
	,S.dblQty
	,S.dtmExpiryDate
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,WP.intWorkOrderProducedSKUId
	,S.intSKUStatusId
	,SS.strSKUStatus
	,SL.intStorageLocationId
	,SL.strName
	,SL.intSubLocationId
	,CSL.strSubLocationName
	,WP.intBatchId
FROM dbo.tblMFWorkOrderProducedSKU WP
JOIN dbo.tblWHSKU S ON WP.intSKUId = S.intSKUId
	AND WP.intBatchId = @intBatchId
JOIN dbo.tblWHContainer C ON C.intContainerId = S.intContainerId
JOIN dbo.tblICStorageLocation SL ON C.intStorageLocationId = SL.intStorageLocationId
JOIN dbo.tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = SL.intSubLocationId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = S.intUOMId
JOIN tblWHSKUStatus SS ON SS.intSKUStatusId = S.intSKUStatusId
ORDER BY WP.intBatchId
