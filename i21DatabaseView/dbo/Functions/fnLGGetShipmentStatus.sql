CREATE FUNCTION [dbo].[fnLGGetShipmentStatus] 
	(@intContractDetailId INT)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @strStatus AS NVARCHAR(100)
	DECLARE @intContractTypeId INT

	SELECT @intContractTypeId = intContractTypeId FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE CD.intContractDetailId = @intContractDetailId

	IF(ISNULL(@intContractTypeId,0) = 2)
		RETURN ''

	SELECT @strStatus = (
			SELECT TOP 1 CASE 
					WHEN C <> ''
						AND W <> ''
						THEN W + ',' + C
					ELSE CASE 
							WHEN C <> ''
								THEN C
							ELSE CASE 
									WHEN W <> ''
										THEN W
									ELSE CASE 
											WHEN L <> ''
												THEN L
											ELSE CASE 
													WHEN A <> ''
														THEN A
													ELSE CASE 
															WHEN O <> ''
																THEN O
															ELSE CASE 
																	WHEN E <> ''
																		THEN E
																	ELSE ''
																	END
															END
													END
											END
									END
							END
					END
			FROM (
				SELECT CASE 
						WHEN ISNULL(CD.dblInvoicedQty, 0) > 0
							THEN 'C'
						END AS C
					,CASE 
						WHEN (
								(
									SELECT COUNT(*)
									FROM tblICInventoryReceiptItem
									WHERE intLineNo = CD.intContractDetailId
									)
								) > 0
								AND (ISNULL(CD.dblInvoicedQty, 0) <> ISNULL(CD.dblQuantity, 0) )
							THEN 'W'
						END AS W
					,CASE 
						WHEN ISNULL(SLD.intPContractDetailId, 0) <> 0
							AND (SLD.dtmDocsReceivedDate IS NOT NULL)
							THEN 'L'
						END AS L
					,CASE 
						WHEN ISNULL(SLD.intPContractDetailId, 0) <> 0
							AND SLD.dtmDocsReceivedDate IS NULL
							THEN 'A'
						END AS A
					,CASE 
						WHEN ISNULL(SILD.intPContractDetailId, 0) <> 0 AND ISNULL(SLD.intPContractDetailId, 0) = 0
							THEN 'O'
						END AS O
					,CASE 
						WHEN ISNULL(SILD.intPContractDetailId, 0) = 0
							THEN 'E'
						END AS E
					,CD.intContractDetailId
				FROM tblCTContractDetail CD
				LEFT JOIN (
					SELECT LSI.strLoadNumber
						,LSID.*
					FROM tblLGLoadDetail LSID
					JOIN tblLGLoad LSI ON LSID.intLoadId = LSI.intLoadId
						AND LSI.intShipmentType = 2
					) SILD ON SILD.intPContractDetailId = CD.intContractDetailId
				LEFT JOIN (
					SELECT L.strLoadNumber
						,L.dtmDocsReceivedDate
						,LD.*
					FROM tblLGLoadDetail LD
					JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
						AND L.intShipmentType = 1
					) SLD ON SLD.intPContractDetailId = CD.intContractDetailId
				WHERE CD.intContractDetailId IN (@intContractDetailId)
				) tbl
			)

	RETURN ISNULL(@strStatus, '');
END