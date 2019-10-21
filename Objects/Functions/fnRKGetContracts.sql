CREATE FUNCTION [dbo].[fnRKGetContracts] (
	@intTransactionId INT
	, @intItemId INT
	, @strTransactionType NVARCHAR(100))

RETURNS @returntable TABLE (intContractNumber INT
	,strContractIds NVARCHAR(1500) COLLATE Latin1_General_CI_AS
	,strContractNumbers NVARCHAR(1500) COLLATE Latin1_General_CI_AS
	,strDeliveryDates NVARCHAR(1500) COLLATE Latin1_General_CI_AS
	,strFutureMonth NVARCHAR(1500) COLLATE Latin1_General_CI_AS)

AS

BEGIN
	IF(@intTransactionId = 0 OR RTRIM(LTRIM(@strTransactionType)) = '' OR @intItemId = 0)
	RETURN

	IF(@strTransactionType = 'Storage Settlement')
	BEGIN
		INSERT INTO @returntable(intContractNumber
			, strContractIds
			, strContractNumbers
			, strDeliveryDates
			, strFutureMonth)
		SELECT TOP 1 intContractHeaderId = CONVERT(INT, LEFT(strContractIds, CHARINDEX('|', strContractIds) - 1))
			, strContractIds
			, strContractNumber = LTRIM(RTRIM(strContractNumbers)) collate Latin1_General_CS_AS
			, CT.strDeliveryDates
			, CT.strFutureMonth
		FROM vyuGRGetSettleStorage
		OUTER APPLY (
			SELECT intContractHeaderId
				, strDeliveryDates
				, strFutureMonth
			FROM dbo.fnRKGetContractInfo(CONVERT(INT, LEFT(strContractIds, CHARINDEX('|', strContractIds) - 1)), LTRIM(RTRIM(strContractNumbers)))
		) CT WHERE intSettleStorageId = @intTransactionId AND intItemId IS NOT NULL AND intItemId = @intItemId
			AND ISNULL(LTRIM(RTRIM(strContractIds)), '') <> '' AND ISNULL(LTRIM(RTRIM(strContractNumbers)),'') <> ''
	END

	IF(@strTransactionType = 'Inventory Shipment')
	BEGIN
		INSERT INTO @returntable(intContractNumber
			, strContractIds
			, strContractNumbers
			, strDeliveryDates
			, strFutureMonth)
		SELECT TOP 1 intOrderId
			, ''
			, strContractNumbers = (strOrderNumber + '-' + CONVERT(NVARCHAR(100), intContractSeq)) COLLATE Latin1_General_CI_AS
			, CT.strDeliveryDates
			, CT.strFutureMonth
		FROM vyuICGetInventoryShipmentItem
		OUTER APPLY (
			SELECT intContractHeaderId
				, strDeliveryDates
				, strFutureMonth 
			FROM dbo.fnRKGetContractInfo(intOrderId, LTRIM(RTRIM(strOrderNumber + '-' + CONVERT(NVARCHAR(100), intContractSeq))))
		) CT
		WHERE intOrderId IS NOT NULL AND intContractSeq IS NOT NULL AND intItemId IS NOT NULL
			AND intInventoryShipmentId = @intTransactionId AND intItemId = @intItemId
	END

	IF(@strTransactionType = 'Inventory Receipt')
	BEGIN
		INSERT INTO @returntable(intContractNumber
			, strContractIds
			, strContractNumbers
			, strDeliveryDates
			, strFutureMonth)
		SELECT TOP 1 intOrderId
			, ''
			, (strOrderNumber + '-' + CONVERT(NVARCHAR(100), intContractSeq)) COLLATE Latin1_General_CI_AS
			, CT.strDeliveryDates
			, CT.strFutureMonth
		FROM vyuICGetInventoryReceiptItem
		OUTER APPLY(
			SELECT intContractHeaderId
				, strDeliveryDates
				, strFutureMonth 
			FROM dbo.fnRKGetContractInfo(intOrderId, LTRIM(RTRIM(strOrderNumber + '-' + CONVERT(NVARCHAR(100), intContractSeq))))
		) CT
		WHERE intInventoryReceiptId IS NOT NULL AND intOrderId IS NOT NULL AND intContractSeq IS NOT NULL AND intItemId IS NOT NULL
			AND intInventoryReceiptId = @intTransactionId AND intItemId = @intItemId
	END

	IF(@strTransactionType = 'Scale')
	BEGIN
		INSERT INTO @returntable(intContractNumber
			, strContractIds
			, strContractNumbers
			, strDeliveryDates
			, strFutureMonth)
		SELECT TOP 1 t.intContractHeaderId
			, ''
			, (strContractNumber + '-' + CONVERT(NVARCHAR(100), intContractSequence)) COLLATE Latin1_General_CI_AS
			, CT.strDeliveryDates
			, CT.strFutureMonth
		FROM vyuSCTicketScreenView t
		OUTER APPLY(
			SELECT intContractHeaderId
				, strDeliveryDates
				, strFutureMonth 
			FROM dbo.fnRKGetContractInfo(intContractHeaderId, LTRIM(RTRIM(strContractNumber + '-' + CONVERT(NVARCHAR(100), intContractSequence))))
		) CT
		WHERE intTicketId IS NOT NULL AND t.intContractHeaderId IS NOT NULL AND intContractSequence IS NOT NULL AND intItemId IS NOT NULL
			AND intTicketId = @intTransactionId AND intItemId = @intItemId 
	END

	IF(@strTransactionType = 'Outbound Shipment')
	BEGIN
		INSERT INTO @returntable(intContractNumber
			, strContractIds
			, strContractNumbers
			, strDeliveryDates
			, strFutureMonth)
		SELECT intContractHeaderId = CASE WHEN ISNULL(T.intSalesContractNumber, 0) <> 0 THEN T.intSalesContractNumber
										WHEN ISNULL(T.intPurchaseContractNumber, 0) <> 0 THEN T.intPurchaseContractNumber END
			, strContractIds = ''
			, strContractNumbers = CASE WHEN ISNULL(T.intSalesContractNumber, 0) <> 0 THEN T.strSalesContractNumber
										WHEN ISNULL(T.intPurchaseContractNumber, 0) <> 0 THEN T.strPurchaseContractNumber END
			, CT.strDeliveryDates
			, CT.strFutureMonth
		FROM (
			SELECT TOP 1 intLoadId
				, intSContractDetailId
				, intPContractDetailId
				, intItemId
				, intSalesContractNumber = SCT.intContractHeaderId
				, strSalesContractNumber = SCT.strContractNumber 
				, intPurchaseContractNumber = PCT.intContractHeaderId
				, strPurchaseContractNumber = PCT.strContractNumber 
			FROM tblLGLoadDetail LD
			LEFT JOIN (
				SELECT CH.intContractHeaderId
					, strContractNumber = (CH.strContractNumber + '-' + CONVERT(NVARCHAR(100), CD.intContractSeq)) COLLATE Latin1_General_CI_AS
					, CD.intContractDetailId 
				FROM tblCTContractHeader CH
				INNER JOIN (
					SELECT intContractHeaderId
						, intContractDetailId
						, intContractSeq 
					FROM tblCTContractDetail
				) CD ON CH.intContractHeaderId = CD.intContractHeaderId
			) SCT ON SCT.intContractDetailId = LD.intSContractDetailId
			LEFT JOIN (
				SELECT CH.intContractHeaderId
					, strContractNumber = (CH.strContractNumber + '-' + CONVERT(NVARCHAR(100), CD.intContractSeq)) COLLATE Latin1_General_CI_AS
					, CD.intContractDetailId 
				FROM tblCTContractHeader CH
				INNER JOIN (
					SELECT intContractHeaderId
						, intContractDetailId
						, intContractSeq 
					FROM tblCTContractDetail
				) CD ON CH.intContractHeaderId = CD.intContractHeaderId
			) PCT ON PCT.intContractDetailId = LD.intPContractDetailId
			WHERE intLoadId = @intTransactionId
		) T
		OUTER APPLY (
			SELECT intContractHeaderId
				, strDeliveryDates
				, strFutureMonth 
			FROM dbo.fnRKGetContractInfo(CASE WHEN ISNULL(T.intSalesContractNumber, 0) <> 0 THEN T.intSalesContractNumber
											WHEN ISNULL(T.intPurchaseContractNumber, 0) <> 0 THEN T.intPurchaseContractNumber END
										, LTRIM(RTRIM(CASE WHEN ISNULL(T.intSalesContractNumber, 0) <> 0 THEN T.strSalesContractNumber
															WHEN ISNULL(T.intPurchaseContractNumber, 0) <> 0 THEN T.strPurchaseContractNumber END)))
		) CT
	END

	RETURN;
END