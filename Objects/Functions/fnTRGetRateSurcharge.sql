CREATE FUNCTION [dbo].[fnTRGetRateSurcharge](
	@intShipViaId int
	,@dtmTransportLoadDate datetime
	,@intItemId int
	,@intEntityCustomerId int
	,@intBulkLocationId int
	,@ysnLocationOrigin bit
)
RETURNS numeric(18,6)
AS
BEGIN

declare @intEntityTariffId int;
declare @intEntityTariffTypeId int;
declare @strBulkZipCode nvarchar(10);

declare @dblSurcharge numeric(18,6);
set @dblSurcharge = null;

if (@ysnLocationOrigin = convert(bit,1))
begin

	select top 1 @strBulkZipCode = strZipPostalCode from tblSMCompanyLocation where intCompanyLocationId = @intBulkLocationId

	if (@strBulkZipCode is not null)
	begin
		if not exists
		(
			select
				* 
			from
				tblARCustomerFreightXRef a
				,tblICItem b 
			where
				a.intEntityCustomerId = @intEntityCustomerId
				and a.strZipCode = @strBulkZipCode
				and a.intCategoryId = b.intCategoryId
				and b.intItemId = @intItemId
		)
		begin
			set @intEntityCustomerId = 0;
		end
	end

end

select top 1 @intEntityTariffId = intEntityTariffId, @intEntityTariffTypeId = intEntityTariffTypeId
from
(
select
intEntityShipViaId = a.intEntityId
,a.strShipVia
,b.intEntityTariffId
,strEntityTarrifDescription = b.strDescription
,dtmEntityTarrifEffectiveDate = b.dtmEffectiveDate
,c.intEntityTariffTypeId
,c.strTariffType
,d.intEntityTariffCategoryId
,e.intCategoryId
,e.strCategoryCode
,strCategoryDescription = e.strDescription
,f.intItemId
,f.strItemNo
,strItemDescription = f.strDescription
,strItemType = f.strType
,strItemShortName = f.strShortName
,g.intFreightXRefId
,g.intSupplyPointId
,g.ysnFreightOnly
,g.strFreightType
,g.dblFreightRate
,g.dblFreightAmount
,intEntityCustomerId = h.intEntityId
,h.strCustomerNumber
,strCustomerType = h.strType
from
tblSMShipVia a
join tblEMEntityTariff b on b.intEntityId = a.intEntityId and b.dtmEffectiveDate <= @dtmTransportLoadDate
join tblEMEntityTariffType c on c.intEntityTariffTypeId = b.intEntityTariffTypeId
join tblEMEntityTariffCategory d on d.intEntityTariffId = b.intEntityTariffId
join tblICCategory e on e.intCategoryId = d.intCategoryId
join tblICItem f on f.intCategoryId = e.intCategoryId and f.intItemId = @intItemId
join tblARCustomerFreightXRef g on g.intCategoryId = e.intCategoryId and lower(strFreightType) in ('rate', 'miles')
join tblARCustomer h on h.intEntityId = g.intEntityCustomerId and h.intEntityTariffTypeId = c.intEntityTariffTypeId and h.intEntityId = @intEntityCustomerId
where
a.intEntityId = @intShipViaId
) as rawData
order by dtmEntityTarrifEffectiveDate desc

if (@intEntityTariffId > 0 and @intEntityTariffTypeId > 0)
begin

select top 1 @dblSurcharge = dblFuelSurcharge
from
(
select
intEntityShipViaId = a.intEntityId
,a.strShipVia
,b.intEntityTariffId
,strEntityTarrifDescription = b.strDescription
,dtmEntityTarrifEffectiveDate = b.dtmEffectiveDate
,c.intEntityTariffTypeId
,c.strTariffType
,d.intEntityTariffFuelSurchargeId
,d.dblFuelSurcharge
,d.dtmEffectiveDate
from
tblSMShipVia a
join tblEMEntityTariff b on b.intEntityId = a.intEntityId and b.intEntityTariffId = @intEntityTariffId
join tblEMEntityTariffType c on c.intEntityTariffTypeId = b.intEntityTariffTypeId and c.intEntityTariffTypeId = @intEntityTariffTypeId
join tblEMEntityTariffFuelSurcharge d on d.intEntityTariffId = b.intEntityTariffId and d.dtmEffectiveDate <= @dtmTransportLoadDate
where
a.intEntityId = @intShipViaId
) as rawData2
order by dtmEffectiveDate desc

end

return @dblSurcharge;

END