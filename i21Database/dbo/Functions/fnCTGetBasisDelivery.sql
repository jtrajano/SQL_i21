﻿-- ANY CHANGES APPLIED HERE MUST BE APPLIED ALSO IN fnCTGetBasisDeliveryAboveR2 POST SCRIPT

CREATE FUNCTION [dbo].[fnCTGetBasisDelivery]
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
	strTransactionType		NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	intEntityId				INT,
	intCommodityId			INT,
	intItemId				INT,
	intCompanyLocationId	INT,
	intFutureMarketId		INT,
	intFutureMonthId		INT,
	intCurrencyId			INT,
	dtmEndDate				DATETIME,
	-- Display Values
	strContractType			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	strContractNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intContractSeq			INT,
	strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strCustomerVendor		NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strCommodityCode		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
    strCompanyLocation		NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
	dtmDate					DATETIME,
	dblQuantity				NUMERIC(38,20),
	dblRunningBalance		NUMERIC(38,20),
	ysnOpenGetBasisDelivery	bit DEFAULT(0)
)
AS
BEGIN
	DECLARE @OpenBasisContract TABLE
	(
		intContractHeaderId		INT,
		intContractDetailId		INT
	)

	insert into @OpenBasisContract	(intContractDetailId, intContractHeaderId)
	select 		
		CD.intContractDetailId,
		CH.intContractHeaderId
	from tblCTContractHeader CH
	join tblCTContractDetail CD on CH.intContractHeaderId = CD.intContractHeaderId
	left JOIN (
		
		SELECT intRowId = ROW_NUMBER() OVER(PARTITION BY a.intContractHeaderId, a.intContractDetailId ORDER BY a.dtmHistoryCreated DESC)
			, a.intPricingTypeId
			, a.intContractHeaderId
			, a.intContractDetailId
			, dtmHistoryCreated
		from tblCTSequenceHistory a
			join tblCTContractHeader b
				on a.intContractHeaderId = b.intContractHeaderId
		where dtmHistoryCreated < DATEADD(DAY, 1, @dtmDate)
		
	) tbl ON tbl.intContractDetailId = CD.intContractDetailId
		AND tbl.intContractHeaderId = CD.intContractHeaderId
		AND tbl.intRowId = 1
	where CH.intPricingTypeId = 2	and tbl.intPricingTypeId = 2

	DECLARE @TemporaryTable TABLE 
	(  
		intTransactionKey       INT IDENTITY(1,1),
		intContractHeaderId		INT,  
		intContractDetailId		INT,        
		intTransactionId		INT,
		strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strContractType			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
		strContractNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		intContractSeq			INT,
		intEntityId				INT,
		strEntityName			NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
		strCommodityCode		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		intCommodityId			INT,
		dtmDate					DATE,
		dblQuantity				NUMERIC(38,20),
		strTransactionType		NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
		intTimeE				BIGINT
	)

	-- SETTLEMENT STORAGE
	INSERT INTO @TemporaryTable
	(
		intContractHeaderId	
		,intContractDetailId	
		,intTransactionId
		,strTransactionId	
		,strContractType		
		,strContractNumber	
		,intContractSeq	
		,intEntityId
		,strEntityName		
		,strCommodityCode
		,intCommodityId	
		,dtmDate				
		,dblQuantity			
		,strTransactionType
		,intTimeE				
	)
	SELECT 
		CH.intContractHeaderId
		,CD.intContractDetailId
		,SS.intSettleStorageId
		,SS.strStorageTicket
		,CT.strContractType
		,CH.strContractNumber
		,CD.intContractSeq
		,E.intEntityId
		,E.strName
		,C.strCommodityCode
		,C.intCommodityId
		,SS.dtmCreated
		,dblQuantity = SUM(SC.dblUnits)
		,'Settlement Storage'
		,(CAST(replace(convert(varchar, SS.dtmCreated,101),'/','') + replace(convert(varchar, SS.dtmCreated,108),':','')AS BIGINT)	+ CAST(SS.intSettleStorageId AS bigint))
	FROM tblGRSettleContract SC
	JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
	JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId AND CH.intContractTypeId = 1 AND CH.intPricingTypeId = 2
	JOIN @OpenBasisContract OC ON CD.intContractDetailId = OC.intContractDetailId and CD.intContractHeaderId = OC.intContractHeaderId
	JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
	WHERE
		SS.ysnPosted = 1
		AND SS.intParentSettleStorageId IS NOT NULL
	GROUP BY
		CH.intContractHeaderId
		,CD.intContractDetailId
		,SS.intSettleStorageId
		,SS.strStorageTicket
		,CT.strContractType
		,CH.strContractNumber
		,CD.intContractSeq
		,E.intEntityId
		,E.strName
		,C.strCommodityCode
		,C.intCommodityId
		,SS.dtmCreated

	-- INVENTORY RECEIPT
	INSERT INTO @TemporaryTable
	(
		intContractHeaderId	
		,intContractDetailId	
		,intTransactionId
		,strTransactionId	
		,strContractType		
		,strContractNumber	
		,intContractSeq	
		,intEntityId
		,strEntityName		
		,strCommodityCode
		,intCommodityId	
		,dtmDate				
		,dblQuantity			
		,strTransactionType
		,intTimeE				
	)
	SELECT CH.intContractHeaderId
	,CD.intContractDetailId
	,Receipt.intInventoryReceiptId
	,Receipt.strReceiptNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,InvTran.dtmDate
	,SUM(ReceiptItem.dblOpenReceive)
	,'Inventory Receipt'
	,(CAST(replace(convert(varchar, InvTran.dtmDate,101),'/','') + replace(convert(varchar, InvTran.dtmDate,108),':','')AS BIGINT)	+ CAST(Receipt.intInventoryReceiptId AS bigint))
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1 AND CH.intPricingTypeId = 2
	JOIN @OpenBasisContract OC
		ON CD.intContractDetailId = OC.intContractDetailId and CD.intContractHeaderId = OC.intContractHeaderId
	INNER JOIN tblICInventoryReceiptItem ReceiptItem ON CD.intContractDetailId = ReceiptItem.intLineNo
	INNER JOIN tblICInventoryReceipt Receipt ON Receipt.strReceiptType = 'Purchase Contract'
		AND ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
	INNER JOIN tblICInventoryTransaction InvTran ON Receipt.intInventoryReceiptId = InvTran.intTransactionId
		AND ReceiptItem.intInventoryReceiptId = InvTran.intTransactionId
		AND ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
		AND InvTran.strTransactionForm = 'Inventory Receipt'
		AND InvTran.intTransactionTypeId = 4
	INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
	INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
	INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	GROUP BY CH.intContractHeaderId
	,CD.intContractDetailId
	,Receipt.intInventoryReceiptId
	,Receipt.strReceiptNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,InvTran.dtmDate

	-- VOUCHER
	INSERT INTO @TemporaryTable
	(
		intContractHeaderId	
		,intContractDetailId	
		,intTransactionId
		,strTransactionId	
		,strContractType		
		,strContractNumber	
		,intContractSeq	
		,intEntityId
		,strEntityName		
		,strCommodityCode
		,intCommodityId	
		,dtmDate				
		,dblQuantity			
		,strTransactionType
		,intTimeE				
	)
	SELECT CH.intContractHeaderId
	,CD.intContractDetailId
	,BD.intBillDetailId
	,B.strBillId
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,B.dtmDateCreated
	,SUM(BD.dblQtyReceived) * -1
	,'Voucher'
	,CAST(replace(convert(varchar, B.dtmDateCreated,101),'/','') + replace(convert(varchar, B.dtmDateCreated,108),':','') AS BIGINT)	+  CAST(BD.intBillDetailId AS BIGINT)
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1 AND CH.intPricingTypeId = 2
	JOIN @OpenBasisContract OC
		ON CD.intContractDetailId = OC.intContractDetailId and CD.intContractHeaderId = OC.intContractHeaderId
	INNER JOIN tblAPBillDetail BD ON BD.intContractDetailId  = CD.intContractDetailId AND BD.intContractSeq IS NOT NULL  and BD.intInventoryReceiptItemId is not null
		AND BD.intItemId = CD.intItemId
	INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
	INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
	INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
	INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	WHERE B.ysnPosted = 1
	GROUP BY CH.intContractHeaderId
	,CD.intContractDetailId
	,BD.intBillDetailId
	,B.strBillId
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,B.dtmDateCreated

	-- INVENTORY SHIPMENT
	INSERT INTO @TemporaryTable
	(
		intContractHeaderId	
		,intContractDetailId	
		,intTransactionId
		,strTransactionId	
		,strContractType		
		,strContractNumber	
		,intContractSeq		
		,intEntityId
		,strEntityName		
		,strCommodityCode
		,intCommodityId	
		,dtmDate				
		,dblQuantity			
		,strTransactionType				
		,intTimeE
	)	
	SELECT CH.intContractHeaderId
	,CD.intContractDetailId
	,Shipment.intInventoryShipmentId
	,Shipment.strShipmentNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,InvTran.dtmDate
	,dblQuantity = SUM(ISNULL(ABS(dbo.fnICConvertUOMtoStockUnit( InvTran.intItemId, InvTran.intItemUOMId, isnull(InvTran.dblQty,0))     ),0)) --dblQuantity = SUM(ISNULL(ABS(InvTran.dblQty),0))
	,'Inventory Shipment'
	,CAST(replace(convert(varchar, InvTran.dtmDate,101),'/','') + replace(convert(varchar, InvTran.dtmDate,108),':','')	 AS BIGINT) + CAST( Shipment.intInventoryShipmentId AS BIGINT)
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
		AND intContractTypeId = 2 AND CH.intPricingTypeId = 2
	JOIN @OpenBasisContract OC
		ON CD.intContractDetailId = OC.intContractDetailId and CD.intContractHeaderId = OC.intContractHeaderId
	INNER JOIN tblICInventoryShipmentItem ShipmentItem ON ShipmentItem.intLineNo = CD.intContractDetailId
		AND CH.intContractHeaderId = ShipmentItem.intOrderId
	INNER JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId	
		AND Shipment.intOrderType = 1
	INNER JOIN tblICInventoryTransaction InvTran ON InvTran.intTransactionId = ShipmentItem.intInventoryShipmentId 
		AND InvTran.intTransactionId = Shipment.intInventoryShipmentId
		AND InvTran.intTransactionDetailId = ShipmentItem.intInventoryShipmentItemId
		AND InvTran.strTransactionForm = 'Inventory Shipment'
		AND InvTran.ysnIsUnposted = 0
		AND InvTran.intInTransitSourceLocationId IS NULL
	INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
	INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
	INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	GROUP BY CH.intContractHeaderId
	,CD.intContractDetailId
	,Shipment.intInventoryShipmentId
	,Shipment.strShipmentNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,InvTran.dtmDate

	-- INVOICE
	INSERT INTO @TemporaryTable
	(
		intContractHeaderId	
		,intContractDetailId	
		,intTransactionId
		,strTransactionId	
		,strContractType		
		,strContractNumber	
		,intContractSeq		
		,intEntityId
		,strEntityName		
		,strCommodityCode
		,intCommodityId	
		,dtmDate				
		,dblQuantity			
		,strTransactionType				
		,intTimeE
	)	
	SELECT CH.intContractHeaderId
	,CD.intContractDetailId
	,ID.intInvoiceDetailId
	,I.strInvoiceNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,I.dtmDate
	,SUM(dbo.fnICConvertUOMtoStockUnit( ID.intItemId, ID.intItemUOMId, ID.dblQtyShipped )    ) * -1 --SUM(ID.dblQtyShipped) * -1
	,'Invoice'
	,CAST(replace(convert(varchar, I.dtmDate,101),'/','') + replace(convert(varchar, I.dtmDate,108),':','')	AS BIGINT) + CAST(ID.intInvoiceDetailId AS BIGINT)
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2 AND CH.intPricingTypeId = 2
	JOIN @OpenBasisContract OC
		ON CD.intContractDetailId = OC.intContractDetailId and CD.intContractHeaderId = OC.intContractHeaderId
	INNER JOIN tblARInvoiceDetail ID ON ID.intContractDetailId  = CD.intContractDetailId AND ID.intInventoryShipmentItemId is not null	
		AND ID.intItemId = CD.intItemId
	INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblICCommodity C ON CH.intCommodityId = C.intCommodityId
	INNER JOIN tblCTContractType CT ON CH.intContractTypeId = CT.intContractTypeId
	INNER JOIN vyuCTEntity E ON E.intEntityId = CH.intEntityId and E.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	--WHERE I.ysnPosted = 1
	GROUP BY CH.intContractHeaderId
	,CD.intContractDetailId
	,ID.intInvoiceDetailId
	,I.strInvoiceNumber
	,CT.strContractType
	,CH.strContractNumber
	,CD.intContractSeq
	,E.intEntityId
	,E.strEntityName
	,C.strCommodityCode
	,C.intCommodityId
	,I.dtmDate

	-- RESULT TABLE
	INSERT INTO @Transaction
	(
		intContractHeaderId
		,intContractDetailId
		,intTransactionId
		,strTransactionId
		,strTransactionType
		,intEntityId
		,strContractType
		,strContractNumber
		,intContractSeq		
		,strCustomerVendor
		,strCommodityCode
		,intCommodityId
		,strItemNo
		,intItemId
		,strCompanyLocation
		,intCompanyLocationId
		,dtmEndDate
		,intFutureMarketId
		,intFutureMonthId
		,intCurrencyId
		,dtmDate
		,dblQuantity
		,dblRunningBalance
	)
	SELECT 	
	T.intContractHeaderId
	,T.intContractDetailId
	,T.intTransactionId
	,T.strTransactionId
	,T.strTransactionType
	,T.intEntityId
	,T.strContractType
	,T.strContractNumber
	,T.intContractSeq	
	,T.strEntityName
	,T.strCommodityCode
	,T.intCommodityId
	,I.strItemNo
	,I.intItemId
	,CL.strLocationName
	,CL.intCompanyLocationId
	,CD.dtmEndDate
	,CD.intFutureMarketId
	,CD.intFutureMonthId
	,CD.intCurrencyId	
	,ISNULL(T.dtmDate, CD.dtmCreated)
	,dblQuantity = ISNULL(T.dblQuantity, 0)
	--,dblRunningBalance = CASE WHEN T.strTransactionType = 'Voucher' OR T.strTransactionType = 'Invoice'  THEN CD.dblQuantity + SUM(T.dblQuantity) OVER (PARTITION BY T.intContractDetailId, T.strTransactionType ORDER BY T.dtmDate ASC)
	--							ELSE SUM(T.dblQuantity) OVER (PARTITION BY T.intContractDetailId, T.strTransactionType ORDER BY T.dtmDate ASC)
	--							END
	-- ORIGINAL APPROACH WITH PERFOMANCE HIT FOR R2 ONLY
	,dblRunningBalance = RunningBalanceSource.dblSumValue
	/*,dblRunningBalance =  (SELECT ISNULL(SUM(dblQuantity),0)
									FROM @TemporaryTable TIR
									WHERE 
									TIR.dtmDate <= T.dtmDate and 
									TIR.intTransactionKey < T.intTransactionKey AND 
									TIR.intContractDetailId = CD.intContractDetailId AND 
									TIR.strTransactionType in ('Voucher', 'Inventory Receipt')
									)*/
							/*CASE 
							WHEN T.strTransactionType = 'Voucher' 
								THEN CD.dblQuantity + 
								(SELECT ISNULL(SUM(dblQuantity),0)
									FROM @TemporaryTable TIR
									WHERE TIR.dtmDate <= T.dtmDate
									AND TIR.intContractDetailId = CD.intContractDetailId
									AND TIR.strTransactionType = 'Voucher')
							ELSE (SELECT ISNULL(SUM(dblQuantity),0) -- Inventory Receipt
									FROM @TemporaryTable TIR
									WHERE TIR.dtmDate <= T.dtmDate
									AND TIR.intContractDetailId = CD.intContractDetailId
									AND TIR.strTransactionType = 'Inventory Receipt')
							END*/
	FROM tblCTContractDetail CD
	INNER JOIN @TemporaryTable T ON CD.intContractDetailId = T.intContractDetailId
	INNER JOIN tblICItem I ON I.intItemId = CD.intItemId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	outer apply (

		(SELECT ISNULL(SUM(dblQuantity),0) as dblSumValue
									FROM @TemporaryTable TIR
									WHERE 
									TIR.dtmDate <= T.dtmDate and 
									TIR.intTransactionKey < T.intTransactionKey AND 
									TIR.intContractDetailId = CD.intContractDetailId AND 
									TIR.strTransactionType in ('Voucher', 'Inventory Receipt')
									)
	) as RunningBalanceSource


	update a set ysnOpenGetBasisDelivery = 1 FROM 
		@Transaction a
			join (select intContractHeaderId
		from @Transaction
			where @dtmDate is null or dtmDate <= @dtmDate
		--group by intContractHeaderId 
		--having(sum(dblQuantity) > 0)) b
		and dblQuantity > 0) b
			on a.intContractHeaderId = b.intContractHeaderId
	-- TEMPORARY SOLUTION
	IF @dtmDate IS NOT NULL
	BEGIN
		DELETE FROM @Transaction WHERE dtmDate > @dtmDate
	END

	RETURN
END
