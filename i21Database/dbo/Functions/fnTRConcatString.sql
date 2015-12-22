CREATE FUNCTION [dbo].fnTRConcatString (
      @strReceiptLink               VARCHAR(50),
	  @intLoadHeaderId              int,
      @Delimiter                    VARCHAR(50),
	  @Type                         VARCHAR(50)
)

RETURNS VARCHAR(MAX)

AS
BEGIN
     declare @rowsCount INT
declare @i INT = 1
declare @names varchar(max) = ''

DECLARE @MyTable TABLE
(
  Id int identity,
  Name varchar(max)
)

if @Type = 'strBillOfLading'
BEGIN
    insert into @MyTable select distinct strBillOfLading from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
if @Type = 'strSupplyPoint'
BEGIN
    insert into @MyTable select distinct strSupplyPoint from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
if @Type = 'strFuelSupplier'
BEGIN
    insert into @MyTable select distinct strFuelSupplier from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
if @Type = 'strReceiptCompanyLocation'
BEGIN
    insert into @MyTable select distinct strReceiptCompanyLocation from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
if @Type = 'strReceiptNumber'
BEGIN
    insert into @MyTable select distinct strReceiptNumber from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
if @Type = 'strTransferNo'
BEGIN
    insert into @MyTable select distinct strTransferNo from  dbo.fnTRLinkedReceipt(@strReceiptLink,@intLoadHeaderId)
    set @rowsCount = (select COUNT(Id) from @MyTable)
END
while @i <= @rowsCount
begin
 if @i = 1
 BEGIN
    set @names = (select name from @MyTable where Id = @i)
 END
 ELSE
 BEGIN
      set @names = @names + @Delimiter + (select name from @MyTable where Id = @i)
 END
 set @i = @i + 1
end
return @names

END 
GO
