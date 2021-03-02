﻿CREATE FUNCTION [dbo].[fnCTGetSampleDetail]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	strSampleNumber		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContainerNumber	NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strSampleTypeName	NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	strSampleStatus		NVARCHAR(100)  COLLATE Latin1_General_CI_AS,
	dtmTestingEndDate	DATETIME,
	dblApprovedQty		NUMERIC(18,6) 
)
AS
BEGIN
	DECLARE @dblRepresentingQty NUMERIC(18,6),
			@dblQuantity		NUMERIC(18,6),
			@strSampleStatus	NVARCHAR(100),
			@intUnitMeasureId	INT,
			@intItemId			INT,
			@ysnHasConfig		BIT
	
	SELECT @ysnHasConfig = (select CASE WHEN strContractApprovalIncrements IS NULL THEN 0 WHEN strContractApprovalIncrements = '' THEN 0 ELSE 1 END from tblCTCompanyPreference)
	SELECT @dblQuantity = dblQuantity, @intUnitMeasureId = intUnitMeasureId ,@intItemId = intItemId FROM tblCTContractDetail WHERE  intContractDetailId = @intContractDetailId

	IF EXISTS(SELECT TOP 1 1 FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 3)
	BEGIN
		IF @ysnHasConfig = 0
		BEGIN 
			SELECT @dblRepresentingQty = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intRepresentingUOMId,@intUnitMeasureId, dblRepresentingQty)) FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 3
			IF @dblRepresentingQty >= @dblQuantity
			SET @dblRepresentingQty = @dblQuantity
		END
		ELSE
		BEGIN
			SELECT @dblRepresentingQty = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intRepresentingUOMId,@intUnitMeasureId, S.dblRepresentingQty)) FROM tblQMSample  S
			INNER JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
			INNER JOIN dbo.fnSplitString((select strContractApprovalIncrements from tblCTCompanyPreference),',') STT ON TRIM(STT.Item) COLLATE Latin1_General_CI_AS = ST.strSampleTypeName COLLATE Latin1_General_CI_AS
			WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 3
		END

		IF @dblRepresentingQty >= @dblQuantity
			SET @strSampleStatus = 'Approved'
		ELSE
			SET @strSampleStatus = 'Partially Approved'
	END		
	ELSE IF EXISTS(SELECT TOP 1 1 FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 4)
	BEGIN
		SELECT @dblRepresentingQty = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,intRepresentingUOMId,@intUnitMeasureId, dblRepresentingQty)) FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 4
		IF @dblRepresentingQty >= @dblQuantity
			SET @strSampleStatus = 'Rejected'
		ELSE
			SET @strSampleStatus = 'Partially Rejected'
		SET @dblRepresentingQty = NULL
	END
	
	INSERT	INTO @returntable
	SELECT	TOP 1 SA.strSampleNumber,
			SA.strContainerNumber,
			ST.strSampleTypeName,
			@strSampleStatus,
			SA.dtmTestingEndDate,
			@dblRepresentingQty	
	FROM	tblQMSample			SA
	JOIN	tblQMSampleType		ST  ON ST.intSampleTypeId	= SA.intSampleTypeId AND SA.intContractDetailId = @intContractDetailId
	JOIN	tblQMSampleStatus	SS  ON SS.intSampleStatusId = SA.intSampleStatusId
	ORDER BY SA.intSampleId DESC

	RETURN;
END