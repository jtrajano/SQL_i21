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

	)
	
	
	insert into @PaymentRecords (strRecord)
	select DISTINCT Payment.strPaymentRecordNum
	
		from tblAPPayment Payment	
		join tblAPPaymentDetail PaymentDetail
			on Payment.intPaymentId = PaymentDetail.intPaymentId
		join tblAPBill Bill
			on PaymentDetail.intBillId = Bill.intBillId
		join tblAPBillDetail BillDetail
			on Bill.intBillId = BillDetail.intBillId
		where BillDetail.intSettleStorageId is not null
			and Bill.intBillId  = @intBillId
	
	insert into @Ids(intId)
		SELECT intBillDetailId 
			from tblAPBillDetail 
				where intBillId = @intBillId

	declare @current_pay_record nvarchar(100)
	declare @current_pay_id int
	declare @uidReport nvarchar(50) 
	declare @xmlParamValue nvarchar(max)
	select @current_pay_id = min(intId) from @PaymentRecords

	
	while(@current_pay_id is not null)
	begin
		
		select @current_pay_record = strRecord 
			,@uidReport = convert(nvarchar(50), newid())
		from @PaymentRecords	
			where intId = @current_pay_id
		

		
		IF OBJECT_ID('tempdb..#tmpReportHolder') IS NOT NULL DROP TABLE #tmpReportHolder
		select top 0 * into #tmpReportHolder from tblGRAPISettlementReport

		alter table #tmpReportHolder drop column guiApiUniqueId
		alter table #tmpReportHolder drop column intSettlementReportId

		

		set @xmlParamValue = '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intBankAccountId</fieldname><condition>EQUAL TO</condition><from>1</from><join>AND</join><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>strTransactionId</fieldname><condition>EQUAL TO</condition><from>' + convert(nvarchar, @current_pay_record) + '</from><join>AND</join><begingroup /><endgroup /><datatype>Int32</datatype></filter><filter><fieldname>intSrCurrentUserId</fieldname><condition>Dummy</condition><from>1</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter><filter><fieldname>intSrLanguageId</fieldname><condition>Dummy</condition><from>0</from><join>OR</join><begingroup /><endgroup /><datatype>int</datatype></filter></filters><sorts /><dummies><filter><fieldname>strReportLogId</fieldname><condition>Dummy</condition><from>' + @uidReport + '</from><join /><begingroup /><endgroup /><datatype>string</datatype></filter></dummies></xmlparam>'
		

		print @xmlParamValue
		insert into #tmpReportHolder
		exec "dbo"."uspGRSettlementReport" @xmlParam=@xmlParamValue
		
		insert into @PaymentIds(intId)
		select  DISTINCT  Payment.intPaymentId
			from tblAPPayment Payment	
			join tblAPPaymentDetail PaymentDetail
				on Payment.intPaymentId = PaymentDetail.intPaymentId
			join tblAPBill Bill
				on PaymentDetail.intBillId = Bill.intBillId
			join tblAPBillDetail BillDetail
				on Bill.intBillId = BillDetail.intBillId
			where BillDetail.intSettleStorageId is not null
				and Bill.intBillId = @intBillId
				and Payment.strPaymentRecordNum = @current_pay_record

		

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



