CREATE PROCEDURE [dbo].[uspCTTransferSequence]
	
	@intContractDetailId	INT,
	@intDestinationHeaderId INT

AS

BEGIN TRY
	
	DECLARE @SQL NVARCHAR(MAX) = '',
			@ErrMsg  NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#tblRefByHeader') IS NOT NULL  					
		DROP TABLE #tblRefByHeader					

	SELECT	t.name AS TableWithForeignKey,c.name AS ForeignKeyColumn 	 
	INTO	#tblRefByHeader														
	FROM	sys.foreign_key_columns AS fk																
	JOIN	sys.tables AS t ON fk.parent_object_id = t.OBJECT_ID																
	JOIN	sys.columns AS c ON fk.parent_object_id = c.OBJECT_ID AND fk.parent_column_id = c.column_id																
	WHERE	fk.referenced_object_id = (SELECT OBJECT_ID FROM sys.tables WHERE name = 'tblCTContractHeader')																
	ORDER BY TableWithForeignKey;			
													
	IF OBJECT_ID('tempdb..#tblRefByDetail') IS NOT NULL  					
		DROP TABLE #tblRefByDetail					
												
	SELECT	t.name AS TableWithForeignKey,c.name AS ForeignKeyColumn 	 
	INTO	#tblRefByDetail																
	FROM	sys.foreign_key_columns AS fk																
	JOIN	sys.tables AS t ON fk.parent_object_id = t.OBJECT_ID																
	JOIN	sys.columns AS c ON fk.parent_object_id = c.OBJECT_ID AND fk.parent_column_id = c.column_id																
	WHERE	fk.referenced_object_id = (SELECT OBJECT_ID FROM sys.tables WHERE name = 'tblCTContractDetail')																
	ORDER BY TableWithForeignKey;																

	
	SELECT	 @SQL +=
			'IF EXISTS(SELECT * FROM '+d.TableWithForeignKey + ' WHERE '+d.ForeignKeyColumn + '  = '+LTRIM(@intContractDetailId)+')
			BEGIN ' +
			'SET @ErrMsg = '+	CASE	WHEN d.TableWithForeignKey = 'tblAPBillDetail' THEN '''Selected sequence is used in Voucher. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblARInvoiceDetail' THEN '''Selected sequence is used in Invoice. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblCFTransaction' THEN '''Selected sequence is used in Card Fueling. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblPOPurchaseDetail' THEN '''Selected sequence is used in Purchase Order. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblQMSample' THEN '''Selected sequence is used in Sample. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblRKAssignFuturesToContractSummary' THEN '''Selected sequence is used in Assign Futures To Contract. Cannot transfer sequence.'''
										WHEN d.TableWithForeignKey = 'tblSOSalesOrderDetail' THEN '''Selected sequence is used in Sales Order. Cannot transfer sequence.'''
										ELSE '''Selected sequence is in use. Cannot transfer sequence.'''
								END +
			' RAISERROR(@ErrMsg,16,1) 
			END '
	FROM		#tblRefByHeader h
	LEFT JOIN	#tblRefByDetail d on d.TableWithForeignKey = h.TableWithForeignKey
	WHERE d.TableWithForeignKey IS NOT NULL AND h.TableWithForeignKey NOT IN ('tblQMSample','tblRKAssignFuturesToContractSummary')

	SELECT @SQL = 'DECLARE @ErrMsg NVARCHAR(MAX) '+ @SQL
	exec sp_executesql @SQL

	IF EXISTS	(	
					SELECT * FROM tblICInventoryReceipt IR
					JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = IR.intInventoryReceiptId
					WHERE IR.strReceiptType = 'Purchase Contract' AND RI.intLineNo = @intContractDetailId
				)
	BEGIN
		SET @ErrMsg = 'Selected sequence is used in Inventory Receipt. Cannot transfer sequence.'
		RAISERROR(@ErrMsg,16,1) 
	END

	IF EXISTS	(	
					SELECT * FROM tblICInventoryShipment SH
					JOIN tblICInventoryShipmentItem SI ON SI.intInventoryShipmentId = SH.intInventoryShipmentId
					WHERE SH.intOrderType = 4 AND SI.intLineNo = @intContractDetailId
				)
	BEGIN
		SET @ErrMsg = 'Selected sequence is used in Inventory Shipment. Cannot transfer sequence.'
		RAISERROR(@ErrMsg,16,1) 
	END

	UPDATE	CH
	SET		CH.dblQuantity	=	CH.dblQuantity - dbo.fnCTConvertQuantityToTargetCommodityUOM(CU.intCommodityUnitMeasureId,CH.intCommodityUOMId,CD.dblQuantity)
	FROM	tblCTContractHeader CH
	JOIN	tblCTContractDetail	CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
	JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CH.intCommodityId AND CU.intUnitMeasureId	=	QU.intUnitMeasureId
	WHERE	CD.intContractDetailId = @intContractDetailId
		
	UPDATE	tblCTContractDetail 
	SET		intContractHeaderId = @intDestinationHeaderId,
			intContractSeq = (SELECT ISNULL(MAX(intContractSeq),0) + 1 FROM tblCTContractDetail WHERE intContractHeaderId = @intDestinationHeaderId)
	WHERE intContractDetailId = @intContractDetailId

	UPDATE	CH
	SET		CH.dblQuantity	=	CH.dblQuantity + dbo.fnCTConvertQuantityToTargetCommodityUOM(CU.intCommodityUnitMeasureId,CH.intCommodityUOMId,CD.dblQuantity)
	FROM	tblCTContractHeader CH
	JOIN	tblCTContractDetail	CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId
	JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId = CH.intCommodityId AND CU.intUnitMeasureId	=	QU.intUnitMeasureId
	WHERE	CD.intContractDetailId = @intContractDetailId

	UPDATE	tblQMSample
	SET		intContractHeaderId = @intDestinationHeaderId
	WHERE	intContractDetailId = @intContractDetailId

	UPDATE	tblRKAssignFuturesToContractSummary
	SET		intContractHeaderId = @intDestinationHeaderId
	WHERE	intContractDetailId = @intContractDetailId

	UPDATE	tblCTPriceFixation
	SET		intContractHeaderId = @intDestinationHeaderId
	WHERE	intContractDetailId = @intContractDetailId

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH