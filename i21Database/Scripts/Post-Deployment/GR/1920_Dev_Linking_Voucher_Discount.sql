
PRINT ('*****BEGIN Updating the link of voucher to discount*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Updating the link of voucher to discount')
begin
	PRINT ('*****RUNNING Updating the link of voucher to discount*****')
	
	


	declare @BillIds as Id

	insert into @BillIds 
	select 

		distinct Bill.intBillId
		--Has_Contract_Item.*,Discount_Link.*, Discount_Count.* , * 
		from tblAPBill  Bill
		outer apply (
			select intBillDetailId, intBillId, 'a' as Flag
				from tblAPBillDetail DetailItem
					JOIN tblICItem Item 
						ON DetailItem.intItemId = Item.intItemId 
							AND Item.strType <> 'Other Charge' 
					where intContractHeaderId is not null  
						and Bill.intBillId = DetailItem.intBillId
						

		) Has_Contract_Item
		outer apply (
			select intBillDetailId discount_detail_id, 'a' as Flagger
				from tblAPBillDetail DetailContract
					JOIN tblICItem DiscountItem 
						ON DetailContract.intItemId = DiscountItem.intItemId 
							AND DiscountItem.strType = 'Other Charge' 
					where Bill.intBillId = DetailContract.intBillId
						

		) Discount_Link
		outer apply (
			select count(intBillDetailId) as DiscountNumber
				from tblAPBillDetail DetailContract
					JOIN tblICItem DiscountItem 
						ON DetailContract.intItemId = DiscountItem.intItemId 
							AND DiscountItem.strType = 'Other Charge' 
					where Bill.intBillId = DetailContract.intBillId
						

		) Discount_Count
		where 
			strVendorOrderNumber like '%STR-%' 
			and Discount_Link.Flagger is not null 
			and Has_Contract_Item.Flag is not null
			and Discount_Count.DiscountNumber > 1

	
	declare @Plaging table
	(
		intBillId			int
		,intBillDetailId	int
		,intNewLinkingId	int

	)

	insert  into @Plaging ( 
		intBillId
		,intBillDetailId
		,intNewLinkingId
	)
	select
		
		intBillId
		,intBillDetailId
		,ROW_NUMBER() OVER(PARTITION BY  BillDetail.intBillId, BillDetail.intItemId ORDER BY BillDetail.intBillId) As intRecordNo
	from tblAPBillDetail BillDetail
	where BillDetail.intBillId in ( select intId from @BillIds )
	order by BillDetail.intBillId


	update 
		BillDetail 
			set intLinkingId = intNewLinkingId
		
	from tblAPBillDetail BillDetail
		join @Plaging pg
			on pg.intBillDetailId = BillDetail.intBillDetailId
				and pg.intBillId = BillDetail.intBillId
	where BillDetail.intLinkingId is null

	/*
	select intBillId
		,intBillDetailId
		, dblQtyReceived
		, strMiscDescription
		, intContractHeaderId
		, intContractDetailId
		, intLinkingId 
	from tblAPBillDetail BillDetail
	where BillDetail.intBillId in ( select intId from @BillIds )
	order by BillDetail.intBillId 
	*/

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Updating the link of voucher to discount', '1'
	

end
PRINT ('*****END Updating the link of voucher to discount*****')