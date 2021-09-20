CREATE PROCEDURE [dbo].[uspGRAPISettlementReportExport]
	@guiApiUniqueId UniqueIdentifier
	,@VoucherId int
AS
	set nocount on
	DECLARE @intBillId int


	declare @UQ uniqueidentifier = @guiApiUniqueId

	select @intBillId =  @VoucherId
	
	declare @Ids Id
	declare @PaymentIds Id
	declare @PaymentRecords table
	(
		intId int not null identity(1,1)
		,strRecord nvarchar(100)
		,intPaymentId int

	)
	
	
	insert into @PaymentRecords (strRecord, intPaymentId )
	select distinct strPaymentRecordNum, intPaymentId from (
		-- this is based from AP's fnAPGetSettlementStatus
		SELECT PYMT.strPaymentRecordNum, PYMT.intPaymentId
		FROM tblAPPayment PYMT
			INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
		WHERE  INVRCPTITEM.intSourceId IS NOT NULL
			AND PYMT.intEntityVendorId = INVRCPT.intEntityVendorId 
			and Bill.intBillId = @intBillId
			
		UNION
		SELECT PYMT.strPaymentRecordNum, PYMT.intPaymentId
		FROM tblAPPayment PYMT
			INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			INNER JOIN tblSCTicket TKT ON BillDtl.intScaleTicketId = TKT.intTicketId
		WHERE  PYMT.intEntityVendorId = TKT.intEntityId 
			and Bill.intBillId = @intBillId
		UNION
		SELECT PYMT.strPaymentRecordNum, PYMT.intPaymentId
		FROM tblAPPayment PYMT 
			INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			INNER JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
			WHERE Bill.intBillId = @intBillId
	) A
	
	insert into @Ids(intId)
		SELECT intBillDetailId 
			from tblAPBillDetail 
				where intBillId = @intBillId

	declare @current_pay_record nvarchar(100)
	declare @current_payment_record_id int
	declare @current_pay_id int
	declare @bank_account_id int

	declare @uidReport nvarchar(50) 
	declare @xmlParamValue nvarchar(max)
	select @current_pay_id = min(intId) from @PaymentRecords

	
	while(@current_pay_id is not null)
	begin
		
		select @current_pay_record = strRecord 
			,@uidReport = convert(nvarchar(50), newid())
			,@current_payment_record_id  = intPaymentId
		from @PaymentRecords	
			where intId = @current_pay_id
		

		
		IF OBJECT_ID('tempdb..#tmpReportHolder') IS NOT NULL DROP TABLE #tmpReportHolder
		select top 0 * into #tmpReportHolder from tblGRAPISettlementReport

		alter table #tmpReportHolder drop column guiApiUniqueId
		alter table #tmpReportHolder drop column intSettlementReportId

		
		select @bank_account_id = intBankAccountId
			from tblAPPayment
				where intPaymentId = @current_payment_record_id

		set @xmlParamValue = '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intBankAccountId</fieldname><condition>EQUAL TO</condition><from>' + convert(nvarchar, @bank_account_id ) + '</from><join>AND</join><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>strTransactionId</fieldname><condition>EQUAL TO</condition><from>' + convert(nvarchar, @current_pay_record) + '</from><join>AND</join><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>intSrLanguageId</fieldname><condition>Dummy</condition><from>0</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter></filters><sorts /><dummies><filter><fieldname>strReportLogId</fieldname><condition>Dummy</condition><from>' + @uidReport + '</from><join /><begingroup /><endgroup /><datatype>string</datatype></filter></dummies></xmlparam>'
		

		print @xmlParamValue
		insert into #tmpReportHolder
		exec "dbo"."uspGRSettlementReport" @xmlParam=@xmlParamValue
		
		delete from @PaymentIds
		insert into @PaymentIds(intId)
		select @current_payment_record_id

		

		insert into tblGRAPISettlementReport
		select @UQ as guiApiUniqueId, Holder.* from #tmpReportHolder Holder
			join @Ids Ids
				on Holder.intBillDetailId = Ids.intId

		insert into tblGRAPISettlementSubReport
		select @UQ as guiApiUniqueId,* from vyuGRSettlementSubReport Report
			join @Ids Ids
				on Report.intBillDetailId = Ids.intId
	
		insert into tblGRAPISettlementTaxDetailsSubReport
		select @UQ as guiApiUniqueId,* from vyuGRSettlementTaxDetailsSubReport Report
			join @Ids Ids
				on Report.intBillDetailId = Ids.intId

		insert into tblGRAPISettlementSummaryReport
		select @UQ as guiApiUniqueId,*  from vyuGRSettlementSummaryReport Report
			join @PaymentIds Ids
				on Report.intPaymentId = Ids.intId

		insert into tblGRAPISettlementInboundSubReport
		select @UQ as guiApiUniqueId,* from vyuGRSettlementInboundSubReport Report
			join @PaymentIds Ids
				on Report.intPaymentId = Ids.intId

		insert into tblGRAPISettlementOutboundSubReport
		select @UQ as guiApiUniqueId,* from vyuGRSettlementOutboundSubReport Report
			join @PaymentIds Ids
				on Report.intPaymentId = Ids.intId

		
		select @current_pay_id = min(intId) 
			from @PaymentRecords
				where intId > @current_pay_id
			
	end 
	



	--select * from tblGRAPISettlementReport where guiApiUniqueId = @UQ

	--select * from tblGRAPISettlementSubReport where guiApiUniqueId = @UQ
	--select * from tblGRAPISettlementTaxDetailsSubReport where guiApiUniqueId = @UQ
	--select * from tblGRAPISettlementSummaryReport where guiApiUniqueId = @UQ
	--select * from tblGRAPISettlementInboundSubReport where guiApiUniqueId = @UQ
	--select * from tblGRAPISettlementOutboundSubReport where guiApiUniqueId = @UQ


RETURN 0
GO



