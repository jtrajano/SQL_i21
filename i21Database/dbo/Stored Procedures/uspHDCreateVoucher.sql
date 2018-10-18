CREATE PROCEDURE [dbo].[uspHDCreateVoucher]
	@intCreatedUserId int,
	@intTicketHoursWorkedId int,
	@intBillId INT OUTPUT,
	@strError NVARCHAR(1000) = NULL OUTPUT,
	@strVoucherNumber NVARCHAR(50) = NULL OUTPUT 
AS
	BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		BEGIN TRY

			DECLARE @error nvarchar(1000);
			DECLARE @billId int = null;
			DECLARE @intVendorId int = null;
			DECLARE @intShipFromEntityId int = null;
			DECLARE @intShipFromLocationId int = null;
			DECLARE @intShipToLocationId int = null;
			DECLARE @strVendorOrderNumber nvarchar(100) = '';
			DECLARE @dtmVoucherDate datetime = null;
			DECLARE @intCurrencyId int = null;
			DECLARE @intAccountId int = null;
			DECLARE @intItemId int = null;
			DECLARE @strMiscDescription nvarchar(max) = '';
			DECLARE @dblQtyReceived numeric(18,6);
			DECLARE @dblDiscount numeric(18,6) = 0.00;
			DECLARE @dblCost numeric(18,6);
			DECLARE @intTaxGroupId int = null;
			DECLARE @intInvoiceId int = null;

			DECLARE @VoucherDetailNonInventory as VoucherDetailNonInventory;

			select
				@intVendorId = a.intAgentEntityId
				,@intShipFromEntityId = a.intAgentEntityId
				,@intShipFromLocationId = f.intShipFromId
				,@intShipToLocationId = h.intCompanyLocationId
				,@strVendorOrderNumber = c.strTicketNumber
				,@dtmVoucherDate = a.dtmDate
				,@intCurrencyId = a.intCurrencyId
				,@intAccountId = null
				,@intItemId = a.intItemId
				,@strMiscDescription = a.strDescription
				,@dblQtyReceived = a.intHours
				,@dblDiscount = 0.00
				,@dblCost = a.dblRate
				,@intTaxGroupId = null
				,@intInvoiceId = a.intInvoiceId
			from
				tblHDTicketHoursWorked a
				join tblEMEntityType b on b.intEntityId = a.intAgentEntityId and b.strType = 'Vendor' 
				join tblHDTicket c on c.intTicketId = a.intTicketId
				join tblAPVendor f on f.intEntityId = a.intAgentEntityId
				join tblSMUserSecurity g on g.intEntityId = a.intAgentEntityId
				left join tblSMCompanyLocation h on h.intCompanyLocationId = g.intCompanyLocationId
				left join tblEMEntityLocation d on d.intEntityId = a.intAgentEntityId and d.ysnDefaultLocation = convert(bit,1)
				left join tblEMEntityLocation e on e.intEntityId = c.intCustomerId and e.ysnDefaultLocation = convert(bit,1)
			where
				a.intTicketHoursWorkedId = @intTicketHoursWorkedId

			BEGIN TRANSACTION;

			insert into @VoucherDetailNonInventory
			(
			    [intAccountId]
				,[intItemId]
				,[strMiscDescription]
				,[dblQtyReceived]
				,[dblDiscount]
				,[dblCost]
				,[intTaxGroupId]
				,[intInvoiceId]
			)
			select
			    [intAccountId] = @intAccountId
				,[intItemId] = @intItemId
				,[strMiscDescription] = @strMiscDescription
				,[dblQtyReceived] = @dblQtyReceived
				,[dblDiscount] = @dblDiscount
				,[dblCost] = @dblCost
				,[intTaxGroupId] = @intTaxGroupId
				,[intInvoiceId] = @intInvoiceId

			exec uspAPCreateBillData
				 @userId = @intCreatedUserId
				 ,@vendorId = @intVendorId
				 ,@type = 1
				 ,@voucherNonInvDetails = @VoucherDetailNonInventory
				 ,@shipTo = @intShipToLocationId
				 ,@shipFrom = @intShipFromLocationId
				 ,@shipFromEntityId  = @intShipFromEntityId
				 ,@vendorOrderNumber  = @strVendorOrderNumber
				 ,@voucherDate = @dtmVoucherDate
				 ,@currencyId = @intCurrencyId
				 ,@billId = @billId out
				 ,@error = @error out

			update tblHDTicketHoursWorked set intBillId = @billId where intTicketHoursWorkedId = @intTicketHoursWorkedId;
			select @strVoucherNumber = strBillId, @intBillId = intBillId from tblAPBill where intBillId = @billId;

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION;
			set @strError = @error;

		END CATCH

	END
