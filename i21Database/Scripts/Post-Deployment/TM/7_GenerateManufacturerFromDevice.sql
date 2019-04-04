print N'BEGIN Generate Manufacturer from Device.'
GO

declare @devices cursor;
declare @intDeviceId int;
declare @intManufacturerId int;
declare @strManufacturerId nvarchar(50);
declare @strManufacturerName nvarchar(100);
declare @ysnDefault bit = convert(bit,0);
declare @intConcurrencyId int = 1;

set @devices = cursor for

	select
		intDeviceId
		,strManufacturerId
		,strManufacturerName
		,ysnDefault
		,intConcurrencyId
	from
	(
		select
			intDeviceId = intDeviceId
			,strManufacturerId = (
									case
										when ltrim(rtrim(isnull(strManufacturerID,''))) <> ''
											then strManufacturerID
										when ltrim(rtrim(isnull(strManufacturerName,''))) <> ''
											then strManufacturerName
											else null
									end
									)
			,strManufacturerName = (
									case
										when ltrim(rtrim(isnull(strManufacturerName,''))) <> ''
											then strManufacturerName
										when ltrim(rtrim(isnull(strManufacturerID,''))) <> ''
											then strManufacturerID
											else null
									end
									)
			,ysnDefault = convert(bit,0)
			,intConcurrencyId = 1
		from
			tblTMDevice
		where intManufacturerId is null
	)
	as rawData
	where strManufacturerId is not null


OPEN @devices
fetch next
from
	@devices
into
	@intDeviceId
	,@strManufacturerId
	,@strManufacturerName
	,@ysnDefault
	,@intConcurrencyId

while @@FETCH_STATUS = 0
begin
	if not exists (select * from tblTMManufacturer where strManufacturerId = @strManufacturerId)
	begin
		insert into tblTMManufacturer
			(
				strManufacturerId
				,strManufacturerName
				,ysnDefault
				,intConcurrencyId
			)
		select
			strManufacturerId = @strManufacturerId
			,strManufacturerName = @strManufacturerName
			,ysnDefault = @ysnDefault
			,intConcurrencyId = @intConcurrencyId

		set @intManufacturerId = SCOPE_IDENTITY();

		update
			tblTMDevice
			set intManufacturerId = @intManufacturerId
		where
			(
				case
					when ltrim(rtrim(isnull(strManufacturerID,''))) <> ''
						then strManufacturerID
					when ltrim(rtrim(isnull(strManufacturerName,''))) <> ''
						then strManufacturerName
						else null
				end
			) = @strManufacturerId;
	end

	fetch next
	from
		@devices
	into
		@intDeviceId
		,@strManufacturerId
		,@strManufacturerName
		,@ysnDefault
		,@intConcurrencyId

end

close @devices
deallocate @devices

GO
print N'END Generate Manufacturer from Device.'
GO