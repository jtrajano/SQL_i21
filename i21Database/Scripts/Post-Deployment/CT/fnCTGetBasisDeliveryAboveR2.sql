GO
	DECLARE @version NVARCHAR(50)
	SELECT @version = @@VERSION

	IF @version NOT LIKE '%2008 R2%'
	BEGIN
		EXEC
		('
			ALTER FUNCTION [dbo].[fnCTGetBasisDelivery]
			(
				@dtmDate DATE = NULL
			)
			RETURNS @Transaction TABLE 
			(  
				-- Filtering Values
				intUniqueId		        INT IDENTITY(1,1),
				intContractHeaderId		INT,  
				intContractDetailId		INT,        
				intTransactionId		INT,
				strTransactionType		NVARCHAR(20),
				intEntityId				INT,
				-- Display Values
				strContractType			NVARCHAR(20),
				strContractNumber		NVARCHAR(50),
				intContractSeq			INT,
				strCustomerVendor		NVARCHAR(150),
				strCommodityCode		NVARCHAR(50),
				dtmDate					DATETIME,
				dblQuantity				NUMERIC(38,20),
				dblRunningBalance		NUMERIC(38,20)	
			)
			AS
			BEGIN

				DECLARE @TemporaryTable TABLE 
				(  
					intTransactionKey       INT IDENTITY(1,1),
					intContractHeaderId		INT,  
					intContractDetailId		INT,        
					intTransactionId		INT,
					strContractType			NVARCHAR(20),
					strContractNumber		NVARCHAR(50),
					intContractSeq			INT,
					intEntityId				INT,
					strEntityName			NVARCHAR(150),
					strCommodityCode		NVARCHAR(50),
					dtmDate					DATETIME,
					dblQuantity				NUMERIC(38,20),
					strTransactionType		NVARCHAR(20)
				)

				-- INVENTORY RECEIPT
				INSERT INTO @TemporaryTable
				(
					intContractHeaderId	
					,intContractDetailId	
					,intTransactionId	
					,strContractType		
					,strContractNumber	
					,intContractSeq	
					,intEntityId
					,strEntityName		
					,strCommodityCode	
					,dtmDate				
					,dblQuantity			
					,strTransactionType				
				)
				SELECT CH.intContractHeaderId
				,CD.intContractDetailId
				,Receipt.intInventoryReceiptId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,InvTran.dtmDate
				,SUM(ReceiptItem.dblOpenReceive)
				,''Inventory Receipt''
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 1
				INNER JOIN tblICInventoryReceiptItem ReceiptItem ON CD.intContractDetailId = ReceiptItem.intLineNo
				INNER JOIN tblICInventoryReceipt Receipt ON Receipt.strReceiptType = ''Purchase Contract''
					AND ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
				INNER JOIN tblICInventoryTransaction InvTran ON Receipt.intInventoryReceiptId = InvTran.intTransactionId
					AND ReceiptItem.intInventoryReceiptId = InvTran.intTransactionId
					AND ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
					AND InvTran.strTransactionForm = ''Inventory Receipt''
					AND InvTran.intTransactionTypeId = 4
				INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
				INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
				INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN ''Vendor'' ELSE ''Customer'' END)
				GROUP BY CH.intContractHeaderId
				,CD.intContractDetailId
				,Receipt.intInventoryReceiptId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,InvTran.dtmDate

				-- VOUCHER
				INSERT INTO @TemporaryTable
				(
					intContractHeaderId	
					,intContractDetailId	
					,intTransactionId	
					,strContractType		
					,strContractNumber	
					,intContractSeq	
					,intEntityId
					,strEntityName		
					,strCommodityCode	
					,dtmDate				
					,dblQuantity			
					,strTransactionType				
				)
				SELECT CH.intContractHeaderId
				,CD.intContractDetailId
				,BD.intBillDetailId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,B.dtmDateCreated
				,SUM(BD.dblQtyReceived) * -1
				,''Voucher''
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 1
				INNER JOIN tblAPBillDetail BD ON BD.intContractDetailId  = CD.intContractDetailId AND BD.intContractSeq IS NOT NULL
				INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
				INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
				INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
				INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN ''Vendor'' ELSE ''Customer'' END)
				WHERE B.ysnPosted = 1
				GROUP BY CH.intContractHeaderId
				,CD.intContractDetailId
				,BD.intBillDetailId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,B.dtmDateCreated

				-- INVENTORY SHIPMENT
				INSERT INTO @TemporaryTable
				(
					intContractHeaderId	
					,intContractDetailId	
					,intTransactionId	
					,strContractType		
					,strContractNumber	
					,intContractSeq		
					,intEntityId
					,strEntityName		
					,strCommodityCode	
					,dtmDate				
					,dblQuantity			
					,strTransactionType				
				)	
				SELECT CH.intContractHeaderId
				,CD.intContractDetailId
				,Shipment.intInventoryShipmentId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,InvTran.dtmDate
				,dblQuantity = SUM(ISNULL(ShipmentItem.dblQuantity,0))
				,''Inventory Shipment''
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
					AND intContractTypeId = 2
				INNER JOIN tblICInventoryShipmentItem ShipmentItem ON ShipmentItem.intLineNo = CD.intContractDetailId
					AND CH.intContractHeaderId = ShipmentItem.intOrderId
				INNER JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId	
					AND Shipment.intOrderType = 1
				INNER JOIN tblICInventoryTransaction InvTran ON InvTran.intTransactionId = ShipmentItem.intInventoryShipmentId 
					AND InvTran.intTransactionId = Shipment.intInventoryShipmentId
					AND InvTran.intTransactionDetailId = ShipmentItem.intInventoryShipmentItemId
					AND InvTran.strTransactionForm = ''Inventory Shipment''
					AND InvTran.ysnIsUnposted = 0
					AND InvTran.intInTransitSourceLocationId IS NULL
				INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
				INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
				INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN ''Vendor'' ELSE ''Customer'' END)
				GROUP BY CH.intContractHeaderId
				,CD.intContractDetailId
				,Shipment.intInventoryShipmentId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,InvTran.dtmDate

				-- INVOICE
				INSERT INTO @TemporaryTable
				(
					intContractHeaderId	
					,intContractDetailId	
					,intTransactionId	
					,strContractType		
					,strContractNumber	
					,intContractSeq		
					,intEntityId
					,strEntityName		
					,strCommodityCode	
					,dtmDate				
					,dblQuantity			
					,strTransactionType				
				)	
				SELECT CH.intContractHeaderId
				,CD.intContractDetailId
				,ID.intInvoiceDetailId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,I.dtmDate
				,SUM(ID.dblQtyShipped) * -1
				,''Invoice''
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 2
				INNER JOIN tblARInvoiceDetail ID ON ID.intContractDetailId  = CD.intContractDetailId
				INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
				INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
				INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
				INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN ''Vendor'' ELSE ''Customer'' END)
				WHERE I.ysnPosted = 1
				GROUP BY CH.intContractHeaderId
				,CD.intContractDetailId
				,ID.intInvoiceDetailId
				,CT.strContractType
				,CH.strContractNumber
				,CD.intContractSeq
				,E.intEntityId
				,E.strEntityName
				,C.strCommodityCode
				,I.dtmDate

				-- RESULT TABLE
				INSERT INTO @Transaction
				(
					intContractHeaderId
					,intContractDetailId
					,intTransactionId
					,strTransactionType
					,intEntityId
					,strContractType
					,strContractNumber
					,intContractSeq		
					,strCustomerVendor
					,strCommodityCode
					,dtmDate
					,dblQuantity
					,dblRunningBalance
				)
				SELECT 	
				T.intContractHeaderId
				,T.intContractDetailId
				,T.intTransactionId
				,T.strTransactionType
				,T.intEntityId
				,T.strContractType
				,T.strContractNumber
				,T.intContractSeq	
				,T.strEntityName
				,T.strCommodityCode	
				,ISNULL(T.dtmDate, CD.dtmCreated)
				,dblQuantity = ISNULL(T.dblQuantity, 0)
				,dblRunningBalance = CASE WHEN T.strTransactionType = ''Voucher'' OR T.strTransactionType = ''Invoice''  THEN CD.dblQuantity + SUM(T.dblQuantity) OVER (PARTITION BY T.intContractDetailId, T.strTransactionType ORDER BY T.dtmDate ASC)
											ELSE SUM(T.dblQuantity) OVER (PARTITION BY T.intContractDetailId, T.strTransactionType ORDER BY T.dtmDate ASC)
											END
				---- ORIGINAL APPROACH WITH PERFOMANCE HIT FOR R2 ONLY
				--,dblRunningBalance = CASE 
				--						WHEN T.strTransactionType = ''Voucher'' 
				--							THEN CD.dblQuantity + 
				--							(SELECT ISNULL(SUM(dblQuantity),0)
				--								FROM @TemporaryTable TIR
				--								WHERE TIR.dtmDate <= T.dtmDate
				--								AND TIR.intContractDetailId = CD.intContractDetailId
				--								AND TIR.strTransactionType = ''Voucher'')
				--						ELSE (SELECT ISNULL(SUM(dblQuantity),0) -- Inventory Receipt
				--								FROM @TemporaryTable TIR
				--								WHERE TIR.dtmDate <= T.dtmDate
				--								AND TIR.intContractDetailId = CD.intContractDetailId
				--								AND TIR.strTransactionType = ''Inventory Receipt'')
				--						END
				FROM tblCTContractDetail CD
				INNER JOIN @TemporaryTable T ON CD.intContractDetailId = T.intContractDetailId

				-- TEMPORARY SOLUTION
				IF @dtmDate IS NOT NULL
				BEGIN
					DELETE FROM @Transaction WHERE dtmDate > @dtmDate
				END

				RETURN
			END
		')
	END
GO