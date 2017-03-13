CREATE PROCEDURE uspValidateShippingAdvice
	@intLoadId INT,
	@strMessage  NVARCHAR(MAX) = '' OUTPUT 
AS
DECLARE @intMinRecordId INT
DECLARE @intContractDetailId INT
DECLARE @strContractNumber NVARCHAR(100)
DECLARE @intContractSeq INT
DECLARE @strContractSeq NVARCHAR(100)
DECLARE @dblLoadQty NUMERIC(18, 6)
DECLARE @dblContainerQty NUMERIC(18, 6)
DECLARE @strSampleNumber NVARCHAR(100)
DECLARE @strSampleStatus NVARCHAR(100)
DECLARE @strErrorMessage NVARCHAR(MAX)
DECLARE @tblContractSampleDetail TABLE 
	(intRecordId INT Identity(1, 1)
	,intContractDetailId INT
	,strContractNumber NVARCHAR(100)
	,intContractSeq INT
	,strContractSeq NVARCHAR(100)
	,dblLoadQty NUMERIC(18, 6)
	,dblContainerQty NUMERIC(18, 6)
	,strSampleNumber NVARCHAR(100)
	,strSampleStatus NVARCHAR(100))

INSERT INTO @tblContractSampleDetail
SELECT C.intContractDetailId
	,C.strContractNumber
	,C.intContractSeq
	,C.strContractNumber +'/' + CONVERT(NVARCHAR,C.intContractSeq) AS strContractSeq
	,LD.dblQuantity AS dblLoadQty
	,dblContainerQty
	,strSampleNumber
	,strSampleStatus
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
JOIN vyuLGLoadOpenContracts C ON LD.intPContractDetailId = C.intContractDetailId
WHERE L.intLoadId = @intLoadId
	AND ISNULL(C.ysnSampleRequired,0) = 1
	AND C.intShipmentType = 1

SELECT @intMinRecordId = MIN(intRecordId) FROM @tblContractSampleDetail
WHILE (@intMinRecordId IS NOT NULL)
BEGIN
	SET @intContractDetailId = NULL
	SET @strContractNumber = NULL
	SET @intContractSeq = NULL
	SET @strContractSeq = NULL
	SET @dblLoadQty = NULL
	SET @dblContainerQty = NULL
	SET @strSampleNumber = NULL
	SET @strSampleStatus = NULL

	SELECT @intContractDetailId = intContractDetailId,
	       @strContractNumber = strContractNumber,
		   @intContractSeq =intContractSeq,
		   @strContractSeq = strContractSeq,
		   @dblLoadQty = dblLoadQty,
		   @dblContainerQty = dblContainerQty,
		   @strSampleNumber = strSampleNumber,
		   @strSampleStatus = strSampleStatus
	FROM @tblContractSampleDetail WHERE intRecordId = @intMinRecordId

	IF(ISNULL(@strSampleNumber,'') = '')
	BEGIN
		SET @strErrorMessage = 'Sample(s) have not been received for the contract '+ @strContractSeq + '.'
	END
	ELSE IF(ISNULL(@strSampleStatus,'') = 'Rejected')
	BEGIN
		SET @strErrorMessage = 'Sample(s) were rejected for the contract '+ @strContractSeq + '.'
	END
	ELSE IF ((@dblLoadQty > @dblContainerQty) Or ISNULL(@strSampleStatus,'') = 'Received')
	BEGIN
		SET @strErrorMessage = 'Shipment qty is more than the approved sample qty for the contract '+ @strContractSeq + '.'		
	END

	IF(ISNULL(@strMessage,'') = '')
	BEGIN
		SET @strMessage = @strErrorMessage
	END
	ELSE 
	BEGIN
		SET @strMessage = @strMessage + '<br>' + @strErrorMessage
	END
	SELECT @intMinRecordId = MIN(intRecordId) FROM @tblContractSampleDetail WHERE intRecordId > @intMinRecordId
END