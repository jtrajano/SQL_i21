CREATE FUNCTION [dbo].[fnCTGetSampleDetail]
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
			@strSampleStatus	NVARCHAR(100)
	
	SELECT @dblQuantity = dblQuantity FROM tblCTContractDetail WHERE  intContractDetailId = @intContractDetailId

	IF EXISTS(SELECT * FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 3)
	BEGIN
		SELECT @dblRepresentingQty = SUM(dblRepresentingQty) FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 3
		IF @dblRepresentingQty >= @dblQuantity
			SET @strSampleStatus = 'Approved'
		ELSE
			SET @strSampleStatus = 'Partially Approved'
	END		
	ELSE IF EXISTS(SELECT * FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 4)
	BEGIN
		SELECT @dblRepresentingQty = SUM(dblRepresentingQty) FROM tblQMSample WHERE intContractDetailId = @intContractDetailId AND intSampleStatusId = 4
		IF @dblRepresentingQty >= @dblQuantity
			SET @strSampleStatus = 'Rejected'
		ELSE
			SET @strSampleStatus = 'Partially Rejected'
		SET @dblRepresentingQty = NULL
	END

	INSERT	INTO @returntable
	SELECT	strSampleNumber,
			strContainerNumber,
			strSampleTypeName ,
			@strSampleStatus,
			dtmTestingEndDate,
			@dblRepresentingQty	
	FROM 
	(
		SELECT	ROW_NUMBER() OVER (PARTITION BY SA.intContractDetailId ORDER BY SA.intSampleId DESC) intRowNum,
				SA.strSampleNumber,
				SA.strContainerNumber,
				ST.strSampleTypeName,
				SS.strStatus AS strSampleStatus,
				SA.dtmTestingEndDate
		FROM	tblQMSample			SA
		JOIN	tblQMSampleType		ST  ON ST.intSampleTypeId	= SA.intSampleTypeId AND SA.intContractDetailId = @intContractDetailId
		JOIN	tblQMSampleStatus	SS  ON SS.intSampleStatusId = SA.intSampleStatusId
	) t WHERE intRowNum = 1
		
	RETURN;
END