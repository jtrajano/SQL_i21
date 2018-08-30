CREATE PROCEDURE [dbo].[uspHDCreateTicket]
	@Subject nvarchar(100)
	,@CustomerNumber nvarchar(100)
	,@Product nvarchar(100)
	,@Version nvarchar(100)
	,@Module nvarchar(100)
	,@Description nvarchar(max) = null
	,@Resolution nvarchar(max) = null
	,@Comments nvarchar(max) = null
	,@Priority nvarchar(100) = null
	,@Type nvarchar(100) = null
	,@Status nvarchar(100) = null
	,@ErrorMessage			nvarchar(max)	= '' OUTPUT
	,@CreatedTicketNumber	nvarchar(50)	= '' OUTPUT
AS

declare @newLine nvarchar(5) = '</br>';
declare @message nvarchar(max) = '';
declare @intEntityId int;
declare @intEntityCurrencyId int;
declare @intRateTypeId int;
declare @dblForexRate numeric(18,6);
declare @dtmTransactionDate datetime = getdate();
declare @EntityNo nvarchar(100);
declare @intEntityContactId int;
declare @intTicketPriorityId int;
declare @intTicketTypeId int;
declare @intTicketStatusId int;
declare @intTicketProductId int;
declare @intVersionId int;
declare @intModuleId int;
declare @intGroupId int;
declare @intOwnerId int;
declare @strTicketNumber nvarchar(100);
declare @intTicketId int;

declare @intErrorCount int = 0;

/*Validate Subject - required*/
if (@Subject is null or ltrim(rtrim(@Subject)) = '')
begin
	set @intErrorCount = @intErrorCount + 1;
	set @message = convert(nvarchar(20), @intErrorCount) + '. Subject is required.' + @newLine;
end

/*Get Currency Rate Type*/
set @intRateTypeId = (select top 1 intAccountsPayableRateTypeId from tblSMMultiCurrency);

/*Validate Customer Number - required*/
/*Will get the default contact - if no default contact, will get 1 from its contact*/
select top 1
	@intEntityId = a.intEntityId
	,@EntityNo = a.strCustomerNumber
	,@intEntityContactId = b.intEntityContactId
	,@intEntityCurrencyId = a.intCurrencyId
from
	tblARCustomer a
	,tblEMEntityToContact b
where
	lower(rtrim(ltrim(a.strCustomerNumber))) = lower(rtrim(ltrim(@CustomerNumber)))
	and b.intEntityId = a.intEntityId
	and b.ysnDefaultContact = convert(bit,1)

if (@intEntityId is null or @intEntityId < 1)
begin
	set @intErrorCount = @intErrorCount + 1;
	set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @CustomerNumber + ' customer number does not exists.' + @newLine;
end
else
begin
	if (@intEntityContactId is null or @intEntityContactId < 1)
	begin
		select top 1
			@intEntityId = a.intEntityId
			,@EntityNo = a.strCustomerNumber
			,@intEntityContactId = b.intEntityContactId
			,@intEntityCurrencyId = a.intCurrencyId
		from
			tblARCustomer a
			,tblEMEntityToContact b
		where
			lower(rtrim(ltrim(a.strCustomerNumber))) = lower(rtrim(ltrim(@CustomerNumber)))
			and b.intEntityId = a.intEntityId
	end
end

/*Validate Priority - if no supplied priority, it will get the default for ticket.*/
if (@Priority is null or ltrim(rtrim(@Priority)) = '')
begin
	set @intTicketPriorityId = (select top 1 a.intTicketPriorityId from tblHDTicketPriority a where a.ysnTicket = convert(bit,1) and a.ysnDefaultTicket = convert(bit,1));
	if (@intTicketPriorityId is null or @intTicketPriorityId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. There is no default setup for ticket priority.' + @newLine;
	end
end
else
begin
	set @intTicketPriorityId = (select top 1 a.intTicketPriorityId from tblHDTicketPriority a where a.ysnTicket = convert(bit,1) and lower(ltrim(rtrim(a.strPriority))) = lower(rtrim(ltrim(@Priority))));
	if (@intTicketPriorityId is null or @intTicketPriorityId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Priority + ' ticket priority does not exists.' + @newLine;
	end
end

/*Validate Type - if no supplied type, it will get the default for ticket.*/
if (@Type is null or ltrim(rtrim(@Type)) = '')
begin
	set @intTicketTypeId = (select top 1 a.intTicketTypeId from tblHDTicketType a where a.ysnTicket = convert(bit,1) and a.ysnDefaultTicket = convert(bit,1));
	if (@intTicketTypeId is null or @intTicketTypeId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. There is no default setup for ticket type.' + @newLine;
	end
end
else
begin
	set @intTicketTypeId = (select top 1 a.intTicketTypeId from tblHDTicketType a where a.ysnTicket = convert(bit,1) and lower(ltrim(rtrim(a.strType))) = lower(rtrim(ltrim(@Type))));
	if (@intTicketTypeId is null or @intTicketTypeId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Type + ' ticket type does not exists.' + @newLine;
	end
end

/*Validate Status - if no supplied status, it will get the default for ticket.*/
if (@Status is null or ltrim(rtrim(@Status)) = '')
begin
	set @intTicketStatusId = (select top 1 a.intTicketStatusId from tblHDTicketStatus a where a.ysnTicket = convert(bit,1) and a.ysnDefaultTicket = convert(bit,1));
	if (@intTicketStatusId is null or @intTicketStatusId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. There is no default setup for ticket status.' + @newLine;
	end
end
else
begin
	set @intTicketStatusId = (select top 1 a.intTicketStatusId from tblHDTicketStatus a where a.ysnTicket = convert(bit,1) and lower(ltrim(rtrim(a.strStatus))) = lower(rtrim(ltrim(@Status))));
	if (@intTicketStatusId is null or @intTicketStatusId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Status + ' ticket status does not exists.' + @newLine;
	end
end

/*Validate Product - required*/
if (@Product is null or ltrim(rtrim(@Product)) = '')
begin
	set @intErrorCount = @intErrorCount + 1;
	set @message = @message + convert(nvarchar(20), @intErrorCount) + '. Product is required.' + @newLine;
end
else
begin
	set @intTicketProductId = (select top 1 a.intTicketProductId from tblHDTicketProduct a where lower(ltrim(rtrim(a.strProduct))) = lower(rtrim(ltrim(@Product))) and a.ysnSupported = convert(bit,1))
	if (@intTicketProductId is null or @intTicketProductId < 1)
	begin
		set @intErrorCount = @intErrorCount + 1;
		set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Product + ' ticket product does not exists.' + @newLine;
	end
end

/*Validate Version - required*/
if (@Version is null or ltrim(rtrim(@Version)) = '')
begin
	set @intErrorCount = @intErrorCount + 1;
	set @message = @message + convert(nvarchar(20), @intErrorCount) + '. Version is required.' + @newLine;
end
else
begin
	if (@intTicketProductId is not null and @intTicketProductId > 0)
	begin
		set @intVersionId = (select top 1 a.intVersionId from tblHDVersion a where a.intTicketProductId = @intTicketProductId and lower(rtrim(ltrim(a.strVersionNo))) = lower(rtrim(ltrim(@Version))));
		if (@intVersionId is null or @intVersionId < 1)
		begin
			set @intErrorCount = @intErrorCount + 1;
			set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Version + ' version does not exists in ' + @Product + ' product.' + @newLine;
		end
	end
end

/*Validate Module - required*/
if (@Module is null or ltrim(rtrim(@Module)) = '')
begin
	set @intErrorCount = @intErrorCount + 1;
	set @message = @message + convert(nvarchar(20), @intErrorCount) + '. Module is required.' + @newLine;
end
else
begin
	if (@intTicketProductId is not null and @intTicketProductId > 0)
	begin
		select top 1 @intModuleId = a.intModuleId, @intGroupId = a.intTicketGroupId from tblHDModule a, tblSMModule b where a.intTicketProductId = @intTicketProductId and b.intModuleId = a.intSMModuleId and b.strModule = lower(rtrim(ltrim(@Module)));
		if (@intModuleId is null or @intModuleId < 1)
		begin
			set @intErrorCount = @intErrorCount + 1;
			set @message = @message + convert(nvarchar(20), @intErrorCount) + '. ' + @Module + ' module does not exists in ' + @Product + ' product.' + @newLine;
		end
	end
end

if (@intGroupId is not null and @intGroupId > 0)
begin
	set @intOwnerId = (select top 1 a.intUserSecurityEntityId from tblHDGroupUserConfig a where a.intTicketGroupId = @intGroupId and a.ysnOwner = convert(bit,1));
	if (@intOwnerId is null or @intOwnerId < 1)
	begin
		set @intOwnerId = (select top 1 a.intUserSecurityEntityId from tblHDGroupUserConfig a where a.intTicketGroupId = @intGroupId and a.ysnEscalation = convert(bit,1));
	end
	if (@intOwnerId is null or @intOwnerId < 1)
	begin
		set @intOwnerId = (select top 1 a.intUserSecurityEntityId from tblHDGroupUserConfig a where a.intTicketGroupId = @intGroupId);
	end
end

if (@intOwnerId is null or @intOwnerId < 1)
begin
	set @intOwnerId = (select top 1 a.intEntityId from tblSMUserSecurity a where a.ysnAdmin = convert(bit,1) and a.ysnDisabled <> convert(bit,1));
end

if (@intEntityCurrencyId is not null and @intEntityCurrencyId > 0 and @intRateTypeId is not null and @intRateTypeId > 0)
begin
	exec uspSMGetForexRate @dtmTransactionDate, @intEntityCurrencyId, @intRateTypeId, @dblForexRate out;
end
else
begin
	set @dblForexRate = 1.00;
end

if (ltrim(rtrim(@message)) = '')
begin
	set @strTicketNumber = (select top 1 a.strPrefix + convert(nvarchar(20), (a.intNumber + 1)) from tblSMStartingNumber a where a.strModule = 'Help Desk' and a.strTransactionType = 'Ticket Number');
	update tblSMStartingNumber set intNumber = intNumber + 1 where strModule = 'Help Desk' and strTransactionType = 'Ticket Number';

	INSERT INTO [dbo].[tblHDTicket]
           (
		   [strTicketNumber]
           ,[strSubject]
           ,[strCustomerNumber]
           ,[intCustomerContactId]
           ,[intCustomerId]
           ,[intTicketTypeId]
           ,[intTicketStatusId]
           ,[intTicketPriorityId]
           ,[intTicketProductId]
           ,[intModuleId]
           ,[intVersionId]
           ,[intAssignedTo]
           ,[intAssignedToEntity]
           ,[intCreatedUserId]
           ,[intCreatedUserEntityId]
           ,[dtmCreated]
           ,[intLastModifiedUserId]
           ,[intLastModifiedUserEntityId]
           ,[intLastCommentedByEntityId]
           ,[dtmLastModified]
           ,[dtmLastCommented]
           ,[strType]
           ,[intCurrencyId]
           ,[intCurrencyExchangeRateId]
           ,[intCurrencyExchangeRateTypeId]
           ,[dtmExchangeRateDate]
           ,[dblCurrencyRate]
           ,[strDescription]
           ,[strResolution]
           ,[strImageId]
           ,[intConcurrencyId]
		   )
     SELECT
		   strTicketNumber = @strTicketNumber
           ,strSubject = @Subject
           ,strCustomerNumber = @EntityNo
           ,intCustomerContactId = @intEntityContactId
           ,intCustomerId = @intEntityId
           ,intTicketTypeId = @intTicketTypeId
           ,intTicketStatusId = @intTicketStatusId
           ,intTicketPriorityId = @intTicketPriorityId
           ,intTicketProductId = @intTicketProductId
           ,intModuleId = @intModuleId
           ,intVersionId = @intVersionId
           ,intAssignedTo = @intOwnerId
           ,intAssignedToEntity = @intOwnerId
           ,intCreatedUserId = @intOwnerId
           ,intCreatedUserEntityId = @intOwnerId
           ,dtmCreated = getdate()
           ,intLastModifiedUserId = @intOwnerId
           ,intLastModifiedUserEntityId = @intOwnerId
           ,intLastCommentedByEntityId = (case when @Comments is not null and ltrim(rtrim(@Comments)) <> '' then @intOwnerId else null end)
           ,dtmLastModified = getdate()
           ,dtmLastCommented = (case when @Comments is not null and ltrim(rtrim(@Comments)) <> '' then getdate() else null end)
           ,strType = 'HD'
           ,intCurrencyId = @intEntityCurrencyId
           ,intCurrencyExchangeRateId = null
           ,intCurrencyExchangeRateTypeId = @intRateTypeId
           ,dtmExchangeRateDate = @dtmTransactionDate
           ,dblCurrencyRate = @dblForexRate
           ,strDescription = @Description
           ,strResolution = @Resolution
           ,strImageId = NEWID()
           ,intConcurrencyId = 1

	if (@Comments is not null and ltrim(rtrim(@Comments)) <> '')
	begin
		set @intTicketId = (select top 1 intTicketId from tblHDTicket where strTicketNumber = @strTicketNumber);

		INSERT INTO [dbo].[tblHDTicketComment]
				   ([intTicketId]
				   ,[strTicketNumber]
				   ,[strTicketCommentImageId]
				   ,[strComment]
				   ,[intCreatedUserId]
				   ,[intCreatedUserEntityId]
				   ,[dtmCreated]
				   ,[intLastModifiedUserId]
				   ,[intLastModifiedUserEntityId]
				   ,[dtmLastModified]
				   ,[ysnSent]
				   ,[ysnCreatedByAgent]
				   ,[intConcurrencyId])
		Select
					intTicketId = @intTicketId
				   ,strTicketNumber = @strTicketNumber
				   ,strTicketCommentImageId = NEWID()
				   ,strComment = @Comments
				   ,intCreatedUserId = @intOwnerId
				   ,intCreatedUserEntityId = @intOwnerId
				   ,dtmCreated = getdate()
				   ,intLastModifiedUserId = @intOwnerId
				   ,intLastModifiedUserEntityId = @intOwnerId
				   ,dtmLastModified = GETDATE()
				   ,ysnSent = convert(bit,0)
				   ,ysnCreatedByAgent = convert(bit,1)
				   ,intConcurrencyId = 1
	end
end


set @ErrorMessage = @message;
set @CreatedTicketNumber = @strTicketNumber;